LinkLuaModifier("modifier_mjz_broodmother_spiderlings", "abilities/hero_broodmother/mjz_broodmother_spawn_spiderlings.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_broodmother_spiderlings_updater", "abilities/hero_broodmother/mjz_broodmother_spawn_spiderlings.lua", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------------------
mjz_broodmother_spawn_spiderlings = class({})
local caster_damage = 0
local M_updater = "modifier_mjz_broodmother_spiderlings_updater"
function mjz_broodmother_spawn_spiderlings:OnSpellStart()
    if not IsServer() then return end
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local projectile_speed = self:GetSpecialValueFor("projectile_speed")
    EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsCast", hCaster)

    local pName = "particles/units/heroes/hero_broodmother/broodmother_web_cast.vpcf"
	self:FireTrackingProjectile(pName, hTarget, projectile_speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 50)

end

function mjz_broodmother_spawn_spiderlings:OnProjectileHit(hTarget, vLocation)
	local hCaster = self:GetCaster()
	if hTarget then --and not hTarget:TriggerSpellAbsorb( self )
		EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsCast", hTarget)
	   
        self:KillSpiders()
        self:SpawnSpiderlings(hTarget)
	end
end

function mjz_broodmother_spawn_spiderlings:GetSpiderUnitName()
    return "npc_dota_broodmother_spiderling"
end

function mjz_broodmother_spawn_spiderlings:GetSpiders()
    self._spiders = self._spiders or {}
    return self._spiders
end

function mjz_broodmother_spawn_spiderlings:KillSpiders()
    self._spiders = self._spiders or {}
    for i,spider in ipairs(self._spiders) do
        if spider and IsValidEntity(spider) then
            spider:ForceKill(false)
        end
    end
    self._spiders = {}
end

function mjz_broodmother_spawn_spiderlings:RegisterSpider(spider)
    if spider and IsValidEntity(spider) then
        self._spiders = self._spiders or {}
        table.insert( self._spiders, spider)
    end
end

function mjz_broodmother_spawn_spiderlings:SpawnSpiderlings(hTarget)
    if IsServer() then 
        local hCaster = self:GetCaster()
        local unitName = self:GetSpiderUnitName()
        local M_NAME = "modifier_mjz_broodmother_spiderlings"
        local aghbuf = "modifier_item_ultimate_scepter_consumed"
        local chance_strike = self:GetSpecialValueFor("true_strike_chance") 
        local spiderling_duration = self:GetSpecialValueFor("spiderling_duration")
        local spiderling_no_duration = hCaster:FindAbilityByName("special_bonus_unique_mjz_broodmother_spawn_spiderlings_duration") 
        if spiderling_no_duration and spiderling_no_duration:GetLevel() ~= 0 then
            spiderling_duration = 0
        end        
        local extra_damage = talent_value(hCaster, "special_bonus_unique_mjz_broodmother_spawn_spiderlings_damage")
        local count = self:GetSpecialValueFor("count") + talent_value(hCaster, "special_bonus_unique_mjz_broodmother_spawn_spiderlings_count")
        
        EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", hTarget)
        ParticleManager:FireParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_POINT, hTarget, {})
    

        for i=1, count do
            local position = hTarget:GetAbsOrigin() + ActualRandomVector(150, 50)
            local spider = hCaster:CreateSummon(unitName, position, spiderling_duration)
            FindClearSpaceForUnit(spider, position, false)

            self:RegisterSpider(spider)

            spider:SetControllableByPlayer(hCaster:GetPlayerID(), true)
            spider:SetOwner(hCaster)

            spider:RemoveAbility("broodmother_poison_sting")
            spider:RemoveAbility("broodmother_spawn_spiderite")
            --local ability_trist = "custom_thrist_like"
            --local ability_trist = "luna_lunar_blessing"   --testing skills
            --local searing = spider:AddAbility(ability_trist)
            --searing:UpgradeAbility(true)
            --searing:SetLevel( hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel() )
			if RandomInt(0,100) <= chance_strike then
				local true_strike = spider:AddAbility("true_strike")
				true_strike:UpgradeAbility(true)
			end

            local newAbilityName = GetRandomAbilityName(hero)
            local link_a = spider:AddAbility(newAbilityName)
            if link_a then
                link_a:UpgradeAbility(true)
                link_a:SetLevel(hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel())
            end

			local not_same_abilities = false
			while not not_same_abilities do
				local newAbilityNameb = GetRandomAbilityName(hero)
				if newAbilityNameb ~= newAbilityName then
					link_b = spider:AddAbility(newAbilityNameb)
					not_same_abilities = true
				end
			end
            if link_b then
                link_b:UpgradeAbility(true)
                link_b:SetLevel(hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel())
            end

			local not_same_abilitiesb = false
            local link_c = false
			while not not_same_abilitiesb do
				local newAbilityNamec = GetRandomAbilityName(hero)
				if newAbilityNamec ~= newAbilityName and newAbilityNamec ~= newAbilityNameb then
					link_c = spider:AddAbility(newAbilityNamec)
					not_same_abilitiesb = true
				end
			end
            if link_c then
                link_c:UpgradeAbility(true)
                link_c:SetLevel(hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel())
            end    

            spider:AddNewModifier(hCaster, self, M_NAME, {})
            spider:AddNewModifier(hCaster, self, M_updater, {duration = 10})
            if hCaster:HasScepter() then
                spider:AddNewModifier(hCaster, self, aghbuf, {})
            end
            caster_damage = hCaster:GetAverageTrueAttackDamage(hCaster) * (self:GetSpecialValueFor("parent_attack_ptc") / 100)
            local spider_lvl = hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel()
            if spider_lvl > 5 then
                caster_damage = caster_damage + ((hCaster:GetMaxHealth() + hCaster:GetMaxMana())) + (hCaster:GetSpellAmplification(false) * 7000) + (hCaster:GetPhysicalArmorValue(false) * 500)
            end
            spider:SetBaseDamageMin(caster_damage + extra_damage)
            spider:SetBaseDamageMax(caster_damage + extra_damage)
            spider:SetBaseAttackTime(0.7)
            --spider:SetBaseAttackTime(hCaster:GetBaseAttackTime() - self.flAttackTimeReduce)
            --spider:SetBaseAttackSpeed(caster_as)

            -- spider:SetForceAttackTarget(hTarget)
        end
    end  
end



local function Update_attack(parent, hCaster, caster_damage)
	if IsServer() then
        local extra_damage = talent_value(hCaster, "special_bonus_unique_mjz_broodmother_spawn_spiderlings_damage")
        local spider_lvl = hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel()
        if spider_lvl > 5 then
            caster_damage = caster_damage + ((hCaster:GetMaxHealth() + hCaster:GetMaxMana())) + (hCaster:GetSpellAmplification(false) * 7000) + (hCaster:GetPhysicalArmorValue(false) * 500)
        end
        parent:SetBaseDamageMin(caster_damage + extra_damage)
        parent:SetBaseDamageMax(caster_damage + extra_damage)
	end
end

----------------------------------------------------------------------------------------
modifier_mjz_broodmother_spiderlings_updater = class({})
function modifier_mjz_broodmother_spiderlings_updater:IsHidden() return false end
function modifier_mjz_broodmother_spiderlings_updater:IsPurgable() return false end
function modifier_mjz_broodmother_spiderlings_updater:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        local hCaster = self:GetCaster()
        if parent and parent:IsAlive() then
            parent:AddNewModifier(hCaster, self:GetAbility(), M_updater, {duration = 10})
            local caster_damage = hCaster:GetAverageTrueAttackDamage(hCaster) * (self:GetAbility():GetSpecialValueFor("parent_attack_ptc") / 100)
            Update_attack(parent, hCaster, caster_damage)        
        end 
    end      
end   
---------------------------------------------------------------------------------------
modifier_mjz_broodmother_spiderlings = class({})
function modifier_mjz_broodmother_spiderlings:IsHidden() return true end
function modifier_mjz_broodmother_spiderlings:IsPurgable() return false end
function modifier_mjz_broodmother_spiderlings:CheckState()
    return {
        -- [MODIFIER_STATE_STUNNED] = true,
        -- [MODIFIER_STATE_ROOTED] = true,
        -- [MODIFIER_STATE_FROZEN] = true,
        --[MODIFIER_STATE_INVISIBLE] = false,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end
function modifier_mjz_broodmother_spiderlings:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,

	}
end

function modifier_mjz_broodmother_spiderlings:GetModifierIgnoreMovespeedLimit() return 1 end
  

function GetRandomAbilityName(hero)
    local abilityList = {
-- Passive:
        --"vengefulspirit_command_aura",  
        "beastmaster_inner_beast",
        "skeleton_king_mortal_strike",
        "spirit_breaker_greater_bash",
        "sven_great_cleave",
        "mjz_obsidian_destroyer_essence_aura",
        "mjz_night_stalker_hunter_in_the_night",
        "mjz_omniknight_degen_aura",
        "troll_warlord_fervor",
        "chaos_knight_chaos_strike",
        "mars_bulwark",
--		"lone_druid_spirit_link",
        "templar_assassin_psi_blades",
		"mjz_vengefulspirit_vengeance",
        "mjz_vengefulspirit_vengeance",
        "monkey_king_custom_jingu_mastery",
        "lycan_feral_impulse",
        "lycan_feral_impulse",
        "lich_custom_cold_soul",
        --"abyssal_underlord_atrophy_aura",
        "meepo_ransack",
        --"brewmaster_fire_permanent_immolation",
        "faceless_void_time_lock",
        "luna_lunar_blessing",
        "elder_titan_natural_order",
        --"mjz_crystal_maiden_brilliance_aura",
        "naga_siren_rip_tide",
        "imba_phantom_assassin_coup_de_grace",
        --"dazzle_bad_juju",
        "ryze_arcane_mastery",
        "big_thunder_lizard_wardrums_aura",
        "phantom_reflex",
        "mjz_general_megamorph",
        "ogre_magi_multicast_lua",
        "mjz_phantom_assassin_coup_de_grace",
        "mjz_spectre_desolate",
        "monkey_king_custom_jingu_mastery",
        "life_stealer_custom_deny",
        "mjz_monkey_king_jingu_mastery",
		"sniper_headshot",
		"mjz_chaos_knight_chaos_strike",
        "weaver_the_swarm",
        "weaver_the_swarm",
		"clinkz_infernal_breath",
		"nevermore_dark_lord",
        "rubick_arcane_supremacy",
-- Active:
        "enchantress_impetus",
        "jakiro_liquid_fire",
        "huskar_burning_spear",
        "tusk_walrus_punch",
        "obsidian_destroyer_arcane_orb",
        "ancient_apparition_chilling_touch",
        "viper_poison_attack",

        "mars_gods_rebuke",
        "tidehunter_anchor_smash",
        "magnataur_empower",
        "legion_commander_custom_duel",
        --"alchemist_chemical_rage",
        --"lone_druid_rabid",
        "juggernaut_healing_ward",
        "mjz_omniknight_repel",
        "mjz_ursa_overpower",
        "brewmaster_drunken_brawler",
        "mjz_broodmother_insatiable_hunger",
        "ogre_magi_bloodlust",
        "nyx_assassin_custom_vendetta",
        "skywrath_mage_ancient_seal",
        --"dark_willow_bedlam",
        "visage_soul_assumption",
        "medusa_stone_gaze",
        "wisp_overcharge",
        "dark_willow_shadow_realm",
        --"bane_enfeeble",
        --"elder_titan_natural_order_spirit",
        "oracle_false_promise",
        "void_spirit_astral_step",
        "juggernaut_omni_slash",
        "mjz_clinkz_death_pact",
        "mjz_night_stalker_darkness",
        "mjz_phantom_assassin_phantom_strike",
        "mjz_templar_assassin_refraction",
        "mjz_templar_assassin_proficiency",
        "mjz_void_spirit_astral_atlas",
        "mjz_windrunner_powershot",
        "mjz_windrunner_focusfire",
        "omniknight_guardian_angel",
        "bloodseeker_custom_thirst",
        "bloodseeker_custom_rampage",
        "disruptor_custom_ion_hammer",
        "legion_commander_custom_duel",
        "rattletrap_custom_battery_assault",
        "sven_gods_strength",
        "tiny_custom_toss",
        "treant_custom_ultimate_sacrifice",
        "witch_doctor_maledict",
        "mjz_faceless_the_world",
        "mjz_axe_berserkers_call",
        "mjz_doom_bringer_doom",
        "mjz_silencer_global_silence",
        "mjz_mirana_arrow",
        "mjz_drow_ranger_marksmanship",
        "mjz_ember_spirit_flame_guard",
        "mjz_furion_power_of_nature",
        "mjz_io_overcharge",
        "enigma_black_hole",
        "tinker_march_of_the_machines",
        "tusk_tag_team",
        "winter_wyvern_arctic_burn",
        "wisp_tether",
        "tidehunter_ravage",
        "viper_nethertoxin",
        "viper_viper_strike",
        "enigma_midnight_pulse",
        "lich_chain_frost",
        "hoodwink_acorn_shot",
    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]
end
