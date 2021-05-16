LinkLuaModifier("modifier_mjz_broodmother_spiderlings", "abilities/hero_broodmother/mjz_broodmother_spawn_spiderlings.lua", LUA_MODIFIER_MOTION_NONE)


-----------------------------------------------------------------------------------------
mjz_broodmother_spawn_spiderlings = class({})
function mjz_broodmother_spawn_spiderlings:OnSpellStart()
    if not IsServer() then return end
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local projectile_speed = self:GetSpecialValueFor("projectile_speed")
    --self.count = self:GetTalentSpecialValueFor("count")
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
        local chace_srike = self:GetSpecialValueFor("true_strike_chance")
        local spiderling_duration = self:GetTalentSpecialValueFor( "spiderling_duration")
        local extra_damage = self:GetTalentSpecialValueFor("extra_damage")
        local count = self:GetTalentSpecialValueFor("count")
        --local count = self.count
        
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
            local icon_strike = "true_strike"
            local ability_trist = "bloodseeker_thirst"
            --local ability_trist = "lycan_shapeshift"
            local searing = spider:AddAbility(ability_trist)
            searing:UpgradeAbility(true)
            searing:SetLevel( hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel() )
            if RandomInt( 0,100 ) < chace_srike then
                local strike_tru = "special_bonus_truestrike"
                local strik = spider:AddAbility(strike_tru)
                strik:UpgradeAbility(true)
                strik:SetLevel(1)
                local ad_icon = spider:AddAbility(icon_strike)
                ad_icon:UpgradeAbility(true)
                ad_icon:SetLevel(1)
            end
            local newAbilityName = GetRandomAbilityName(hero)
            local link_a = spider:AddAbility(newAbilityName)
            link_a:UpgradeAbility(true)
            link_a:SetLevel(hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel())
            local newAbilityNameb = GetRandomAbilityName(hero)
            local link_b = spider:AddAbility(newAbilityNameb)
            link_b:UpgradeAbility(true)
            link_b:SetLevel(hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel())

            spider:AddNewModifier(hCaster, self, M_NAME, {})
            if hCaster:HasScepter() then
                spider:AddNewModifier(hCaster, self, aghbuf, {})
            end
            local caster_damage = hCaster:GetAverageTrueAttackDamage(hCaster) * 1.3
            local spider_lvl = hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings"):GetLevel()
            if spider_lvl > 6 then
                caster_damage = caster_damage + ((hCaster:GetMaxHealth() + hCaster:GetMaxMana()) * 0.33) + (hCaster:GetSpellAmplification(false) * 5000) + (hCaster:GetPhysicalArmorValue(false) * 200)
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


---------------------------------------------------------------------------------------
modifier_mjz_broodmother_spiderlings = class({})
function modifier_mjz_broodmother_spiderlings:IsHidden() return true end
function modifier_mjz_broodmother_spiderlings:IsPurgable() return false end
function modifier_mjz_broodmother_spiderlings:CheckState()
    return {
        -- [MODIFIER_STATE_STUNNED] = true,
        -- [MODIFIER_STATE_ROOTED] = true,
        -- [MODIFIER_STATE_FROZEN] = true,
        -- [MODIFIER_STATE_INVISIBLE] = false,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end
if IsServer() then
    function modifier_mjz_broodmother_spiderlings:OnCreated()
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()
        self.target = self:GetParent()

        local interval = -1
        self:OnIntervalThink()
        self:StartIntervalThink(interval)
    end
    function modifier_mjz_broodmother_spiderlings:OnIntervalThink()
        if self.ability then
        end
    end
end

function GetRandomAbilityName(hero)
    local abilityList = {
        "beastmaster_inner_beast",
        "skeleton_king_vampiric_aura",
        "skeleton_king_mortal_strike",
        "spirit_breaker_greater_bash",
        "sven_great_cleave",
        "mjz_obsidian_destroyer_essence_aura",
        --"antimage_custom_mana_break",
        "mjz_night_stalker_hunter_in_the_night",
        --"phantom_assassin_blur",
        "tidehunter_anchor_smash",
        "mjz_omniknight_degen_aura",
		"mjz_vengefulspirit_vengeance",
        "mjz_troll_warlord_fervor",
        "chaos_knight_chaos_strike",
        "mars_bulwark",
        "magnataur_empower",
        "legion_commander_custom_duel",
        "alchemist_chemical_rage",
        "lone_druid_rabid",
		"lone_druid_spirit_link",
        "juggernaut_healing_ward",
        "lone_druid_spirit_bear_demolish",
        "templar_assassin_psi_blades",
        "mjz_vengefulspirit_vengeance",
        "monkey_king_custom_jingu_mastery",
        "mjz_omniknight_repel",
        "lycan_feral_impulse",
        "mjz_ursa_overpower",
        "ursa_fury_swipes",
        "lich_custom_cold_soul",
        "lycan_feral_impulse",
        "brewmaster_drunken_brawler",
        "mjz_broodmother_insatiable_hunger",
        "abyssal_underlord_atrophy_aura",
        "meepo_ransack",
        "brewmaster_fire_permanent_immolation",           -- bug
        "faceless_void_time_lock",
        "ogre_magi_bloodlust",
        "mjz_clinkz_soul_pact",
        "luna_lunar_blessing",
        "elder_titan_natural_order",
        "nyx_assassin_custom_vendetta",
        "skywrath_mage_ancient_seal",
        "disruptor_custom_ion_hammer",        -- crash on snowball
        "dark_willow_bedlam",
        "rubick_arcane_supremacy",
        "jakiro_liquid_fire",
        "obsidian_destroyer_arcane_orb",
        "mjz_crystal_maiden_brilliance_aura",
        "naga_siren_rip_tide",
        "imba_phantom_assassin_coup_de_grace",
        "dazzle_bad_juju",
        "ancient_apparition_chilling_touch",
        "visage_soul_assumption",
        "medusa_stone_gaze",
        "enchantress_impetus",
        "wisp_overcharge",
        "tusk_walrus_punch",

        "dark_willow_shadow_realm",
        "bane_enfeeble",
        "ryze_arcane_mastery",
        "elder_titan_natural_order_spirit",
        "oracle_false_promise",
        "mars_gods_rebuke",
        "void_spirit_astral_step",
        "big_thunder_lizard_wardrums_aura",
        "phantom_reflex",
        "mjz_general_megamorph",
        "ogre_magi_multicast_lua",
        "juggernaut_omni_slash",
        "mjz_clinkz_death_pact",
        "mjz_night_stalker_darkness",
        "mjz_phantom_assassin_coup_de_grace",
        "mjz_phantom_assassin_phantom_strike",
        "mjz_spectre_desolate",
        "mjz_templar_assassin_refraction",
        "mjz_templar_assassin_proficiency",
        "mjz_void_spirit_astral_atlas",
        "mjz_windrunner_powershot",
        "mjz_windrunner_focusfire",
        "omniknight_guardian_angel",
        "huskar_burning_spear",
        "bloodseeker_custom_thirst",
        "bloodseeker_custom_rampage",
        --"dark_seer_custom_dark_clone",
        "disruptor_custom_ion_hammer",
        "legion_commander_custom_duel",
        "life_stealer_custom_deny",
        "monkey_king_custom_jingu_mastery",
        "rattletrap_custom_battery_assault",
        "sven_gods_strength",
        "tiny_custom_toss",
        "treant_custom_ultimate_sacrifice",
        "witch_doctor_maledict",
        --"mjz_bloodseeker_rupture",
       -- "dragon_knight_elder_dragon_form",
        "mjz_faceless_the_world",
        "mjz_axe_berserkers_call",
        "mjz_doom_bringer_doom",
        "mjz_monkey_king_jingu_mastery",
        "mjz_silencer_global_silence",
        "mjz_mirana_arrow",
        "mjz_drow_ranger_marksmanship",
        "mjz_ember_spirit_flame_guard",
        "weaver_the_swarm",
        "mjz_furion_power_of_nature",
        "mjz_io_overcharge",
        "enigma_black_hole",
        "tinker_march_of_the_machines",
        "tusk_tag_team",
        "winter_wyvern_arctic_burn",
        "wisp_tether",
        "tidehunter_ravage",
        "viper_poison_attack",
        "viper_nethertoxin",
        "viper_viper_strike",
        "mjz_troll_warlord_battle_trance",
        "vengefulspirit_command_aura",
        "enigma_midnight_pulse",
        "sniper_headshot",
        "mjz_chaos_knight_chaos_strike",
        "chen_custom_avatar",
        "lich_chain_frost",
        "weaver_the_swarm",
        "hoodwink_acorn_shot",
    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]
end


-- talent 
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or 'value'
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end

