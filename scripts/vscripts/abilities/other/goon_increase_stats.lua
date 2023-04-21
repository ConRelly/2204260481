require("lib/my")
require("AOHGameMode")





function on_created(keys)
	local caster = keys.caster
	local ability = keys.ability

	local round = 0
	local armor_base = caster:GetPhysicalArmorBaseValue()
	local magical_armor_base = caster:Script_GetMagicalArmorValue(false, caster)
	local armor_per_round = ability:GetSpecialValueFor("armor_per_round")
	local previous_round = 1
	local aghbuf = "modifier_item_ultimate_scepter_consumed"
	local chace_srike = 75
	local icon_strike = "true_strike"	
    local skill_lvl = 1
	caster:AddItemByName("item_force_blade")
	caster:AddItemByName("item_heart")
	caster:AddItemByName("item_boss_resistance_25")
	caster:SetHasInventory(false)
	caster:SetCanSellItems(false)

    --print("gon stats stuff 26")
	local has5 = false
	local has10 = false
	local has15 = false
	local has20 = false
	local has25 = false
	local has30 = false
	local has35 = false
	Timers:CreateTimer(
		function()
			round = GameRules.GLOBAL_roundNumber
			if round ~= previous_round and round then
				if caster and not caster:IsNull() and caster:IsAlive() and caster:FindAbilityByName("goon_increase_stats") then
					local level = caster:GetLevel()
					caster:CreatureLevelUp(round - level)

					if round > 5 and not has5 then
						caster:SetHasInventory(true)
						caster:AddItemByName("item_lesser_crit")
						caster:SetHasInventory(false)
						skill_lvl = 2
						has5 = true
					end
					if round > 10 and not has10 then
						caster:SetHasInventory(true)
						caster:AddItemByName("item_plain_ring")
						caster:SetHasInventory(false)
						has10 = true
					end
					if round > 15 and not has15 then
						caster:SetHasInventory(true)
						caster:RemoveItem(find_item(caster, "item_heart"))
						caster:AddItemByName("item_mjz_heart_4")
						caster:SetHasInventory(false)
						skill_lvl = 3
						has15 = true
					end
					if round > 20 and not has20 then
						caster:SetHasInventory(true)
						caster:AddItemByName("item_satanic")
						caster:SetHasInventory(false)
						skill_lvl = 4
						has20 = true
					end
					if round > 25 and not has25 then
						caster:SetHasInventory(true)
						caster:AddNewModifier(caster, ability, "modifier_goon_increase_stats", {})
						caster:RemoveItem(find_item(caster, "item_mjz_heart_5"))
						caster:AddItemByName("item_mjz_heart_5")
						caster:AddItemByName("item_ultimate_scepter")
						caster:SetHasInventory(false)
						skill_lvl = 5
						has25 = true
					end
					if round > 30 and not has30 then
						caster:SetHasInventory(true)
						caster:RemoveItem(find_item(caster, "item_lesser_crit"))
						caster:AddItemByName("item_greater_crit")
						caster:SetHasInventory(false)
						skill_lvl = 6
						has30 = true
					end
					if round > 35 and not has35 then
						caster:SetHasInventory(true)
						caster:RemoveItem(find_item(caster, "item_greater_crit"))
						caster:AddItemByName("item_mjz_shivas_guard_5")
						caster:SetHasInventory(false)
						skill_lvl = 7
						has35 = true
					end
					
					previous_round = round
					
				end
			end
		return 2.0
	end
	)
    Timers:CreateTimer({
        endTime = 0.1, 
        callback = function()
            if RandomInt( 0,100 ) < chace_srike then
                local strike_tru = "special_bonus_truestrike"
                if not caster:HasAbility(strike_tru) then
                    local strik = caster:AddAbility(strike_tru)
                    strik:UpgradeAbility(true)
                    strik:SetLevel(1)
                    local ad_icon = caster:AddAbility(icon_strike)
                    ad_icon:UpgradeAbility(true)
                    ad_icon:SetLevel(1)
                end    
            end
            local hAbility = caster:GetAbilityByIndex(0):GetAbilityName()
            local hAbility2 = caster:GetAbilityByIndex(1):GetAbilityName()
            caster:RemoveAbility(hAbility)
            caster:RemoveAbility(hAbility2)					
            local newAbilityName = GetRandomAbilityName(hero)
            local link_a = caster:AddAbility(newAbilityName)
            link_a:UpgradeAbility(true)
            link_a:SetLevel(skill_lvl)
            local newAbilityNameb = GetRandomAbilityName(hero)
            local link_b = caster:AddAbility(newAbilityNameb)
            link_b:UpgradeAbility(true)
            link_b:SetLevel(skill_lvl)
            if RollPercentage(75) or has35 then
                caster:AddNewModifier(caster, self, aghbuf, {})
            end
        end
    })    
	
end	

function GetRandomAbilityName(hero)
    local abilityList = {
        --"vengefulspirit_command_aura", -- crashes when the summon unit dies(aghanim effect) (if is not hero)
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
        "troll_warlord_fervor",
        "chaos_knight_chaos_strike",
        "mars_bulwark",
        "magnataur_empower",
        "legion_commander_custom_duel",
        "alchemist_chemical_rage",
        --"lone_druid_rabid",
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
        --"mjz_clinkz_soul_pact",
        "luna_lunar_blessing",
        "elder_titan_natural_order",
        "nyx_assassin_custom_vendetta",
        "skywrath_mage_ancient_seal",
        "disruptor_custom_ion_hammer",        -- crash on snowball
        "dark_willow_bedlam",
        "rubick_arcane_supremacy",
        "jakiro_liquid_fire",
        "obsidian_destroyer_arcane_orb",
        --"mjz_crystal_maiden_brilliance_aura",
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
        --"elder_titan_natural_order_spirit",
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
        "enigma_midnight_pulse",
        "sniper_headshot",
        "mjz_chaos_knight_chaos_strike",
        "chen_custom_avatar",
        "lich_chain_frost",
        "weaver_the_swarm",
        "hoodwink_acorn_shot",
		"clinkz_infernal_breath",
		"nevermore_dark_lord",
    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]
end


LinkLuaModifier("modifier_goon_increase_stats", "abilities/other/goon_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)

modifier_goon_increase_stats = class({})


function modifier_goon_increase_stats:GetTexture()
    return "dragon_knight_dragon_blood"
end

function modifier_goon_increase_stats:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_goon_increase_stats:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_goon_increase_stats:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
end

function modifier_goon_increase_stats:OnCreated()
	self.parent = self:GetParent()
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", PATTACH_POINT, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
end
function modifier_goon_increase_stats:OnDestroy()
	ParticleManager:DestroyParticle(self.particle, true)
end
