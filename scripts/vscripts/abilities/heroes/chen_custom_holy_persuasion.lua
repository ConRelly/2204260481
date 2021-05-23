--[[Author: Pizzalol, Beaglepleaser9000
	Date: 30.12.2015.
	Takes ownership of the target unit]]
-- Modifier Effects
LinkLuaModifier("modifier_extra_stuf_mana", "abilities/heroes/chen_custom_holy_persuasion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_extra_stuf_mana = class({})


function modifier_extra_stuf_mana:IsHidden() return true end
function modifier_extra_stuf_mana:IsPurgable() return false end
function modifier_extra_stuf_mana:IsDebuff() return false end

function modifier_extra_stuf_mana:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_BONUS,
		--MODIFIER_PROPERTY_BASE_MANA_REGEN,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end
function modifier_extra_stuf_mana:GetModifierManaBonus()
	return 40420
end
--function modifier_extra_stuf_mana:GetModifierBaseManaRegen()
--	return 3500
--end
function modifier_extra_stuf_mana:GetModifierBaseAttackTimeConstant()	 
	return 0.9
end

function HolyPersuasion( keys )
    
	local caster = keys.caster
	local hCaster = keys.caster 
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local talent = caster:FindAbilityByName("special_bonus_unique_chen_custom_2")
	local aghbuf = "modifier_item_ultimate_scepter_consumed"
	local chace_srike = ability:GetSpecialValueFor("true_strike_chance")
	local modif_n = "modifier_extra_stuf_mana"

	-- Initialize the tracking data
	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count or 0
	ability.holy_persuasion_table = ability.holy_persuasion_table or {}
	ability.holy_persuasion_ancient_unit_count = ability.holy_persuasion_ancient_unit_count or 0
	ability.holy_persuasion_ancient_table = ability.holy_persuasion_ancient_table or {}
	--local has_talent = false;
	-- Ability variables
	local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)
	local max_ancients = caster:FindAbilityByName("chen_custom_avatar"):GetLevel() + 1
	print(caster:GetTeamNumber())
	print(target:GetAbsOrigin())
	--[[local units = FindUnitsInRadius(
				DOTA_TEAM_GOODGUYS,
                target:GetAbsOrigin(),
                nil,
				ability:GetSpecialValueFor("talent_radius"),
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
                0,
                false
            )]]
	if talent and talent:GetLevel() > 0 then
		max_units = max_units + talent:GetSpecialValueFor("value")
		--has_talent = true
			
	end

	-- Change the ownership of the unit and restore its mana to full
	if not target:IsAncient() or caster:HasScepter() and caster:FindAbilityByName("chen_custom_avatar"):GetLevel() > 0 and target:IsAncient() then
		target:SetTeam(caster_team)
		target:SetOwner(caster)
		target:SetControllableByPlayer(player, true)
		local icon_strike = "true_strike"
		local ability_trist = "bloodseeker_thirst"
		--local ability_trist = "nevermore_custom_necromastery"
		local searing = target:AddAbility(ability_trist)
		searing:UpgradeAbility(true)
		searing:SetLevel( hCaster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel() )
		if RandomInt( 0,100 ) < chace_srike then
			local strike_tru = "special_bonus_truestrike"
			local strik = target:AddAbility(strike_tru)
			strik:UpgradeAbility(true)
			strik:SetLevel(1)
			local ad_icon = target:AddAbility(icon_strike)
			ad_icon:UpgradeAbility(true)
			ad_icon:SetLevel(1)

		end            
		local newAbilityName = GetRandomAbilityName(hero)
		local link_a = target:AddAbility(newAbilityName)
		link_a:UpgradeAbility(true)
		link_a:SetLevel( hCaster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel() ) 
		local newAbilityNameb = GetRandomAbilityName(hero)
		local link_b = target:AddAbility(newAbilityNameb)
		link_b:UpgradeAbility(true)
		link_b:SetLevel( hCaster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel() )

		local kill_me_master = target:AddAbility("kill_me_master")
		kill_me_master:UpgradeAbility(true)
		kill_me_master:SetLevel(1)
		
		target:AddNewModifier( hCaster, hAbility, modif_n, {})
		if hCaster:HasScepter() then
			target:AddNewModifier( hCaster, ability, aghbuf, {})
		end
		local caster_damage = hCaster:GetAverageTrueAttackDamage(hCaster) * 1.3
		local chen_skill_lvl = hCaster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel()
		if chen_skill_lvl > 3 then
			caster_damage = caster_damage + ((hCaster:GetMaxHealth() + hCaster:GetMaxMana()) / 3) + (hCaster:GetSpellAmplification(false) * 5000) + (hCaster:GetPhysicalArmorValue(false) * 200)
		end           
		target:SetBaseDamageMin(caster_damage)
		target:SetBaseDamageMax(caster_damage)
		target:SetBaseMoveSpeed(800)
		target:SetAcquisitionRange(2900)
		target:SetBaseAttackTime(0.9)		
		target:GiveMana(target:GetMaxMana())
		target:SetBaseMagicalResistanceValue(target:GetBaseMagicalResistanceValue() + (100 - target:GetBaseMagicalResistanceValue()) * 0.01 * ability:GetSpecialValueFor("magic_resistance"))
		ability:ApplyDataDrivenModifier(caster, target, "modifier_chen_custom_holy_persuasion_buff", {duration = -1})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_invulnerable", {duration = -1})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_phased", {duration = -1})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_fountain_aura_buff", {duration = -1})
		FindClearSpaceForUnit( target, target:GetAbsOrigin(), true )
		-- Track the unit
		--[[if target:IsAncient() then
			ability.holy_persuasion_ancient_unit_count = ability.holy_persuasion_ancient_unit_count + 1
			table.insert(ability.holy_persuasion_ancient_table, target)

			-- If the maximum amount of units is reached then kill the oldest unit
			if ability.holy_persuasion_ancient_unit_count > max_ancients then
				ability.holy_persuasion_ancient_table[1]:ForceKill(true) 
			end
		else]]
		ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
		table.insert(ability.holy_persuasion_table, target)

		-- If the maximum amount of units is reached then kill the oldest unit
		if ability.holy_persuasion_unit_count > max_units then
			ability.holy_persuasion_table[1]:ForceKill(true) 
		end
		--end
	--[[else
		for _,target2 in ipairs(units) do
			if not target2:IsAncient() then
				target2:SetTeam(caster_team)
				target2:SetOwner(caster)
				target2:SetControllableByPlayer(player, true)
				local icon_strike = "true_strike"
				local ability_trist = "bloodseeker_thirst"
				--local ability_trist = "nevermore_custom_necromastery"
				local searing = target2:AddAbility(ability_trist)
				searing:UpgradeAbility(true)
				searing:SetLevel( hCaster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel() )
				if RandomInt( 0,100 ) < chace_srike then
					local strike_tru = "special_bonus_truestrike"
					local strik = target2:AddAbility(strike_tru)
					strik:UpgradeAbility(true)
					strik:SetLevel(1)
					local ad_icon = target2:AddAbility(icon_strike)
					ad_icon:UpgradeAbility(true)
					ad_icon:SetLevel(1)

				end            
				local newAbilityName = GetRandomAbilityName(hero)
				local link_a = target2:AddAbility(newAbilityName)
				link_a:UpgradeAbility(true)
				link_a:SetLevel( hCaster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel() ) 
				local newAbilityNameb = GetRandomAbilityName(hero)
				local link_b = target2:AddAbility(newAbilityNameb)
				link_b:UpgradeAbility(true)
				link_b:SetLevel( hCaster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel() )                
				
				target2:AddNewModifier( hCaster, hAbility, modif_n, {})
				if hCaster:HasScepter() then
					target2:AddNewModifier( hCaster, ability, aghbuf, {})
				end
				local caster_damage = hCaster:GetAverageTrueAttackDamage(hCaster) * 1.3
				local chen_skill_lvl = hCaster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel()
				if chen_skill_lvl > 6 then
					caster_damage = caster_damage + ((hCaster:GetMaxHealth() + hCaster:GetMaxMana()) / 4) + (hCaster:GetSpellAmplification(false) * 5000) + (hCaster:GetPhysicalArmorValue(false) * 150)
				end           
				target2:SetBaseDamageMin(caster_damage)
				target2:SetBaseDamageMax(caster_damage)
				target2:SetBaseMoveSpeed(800)
				target2:SetAcquisitionRange(2900)			
				target2:SetBaseAttackTime(0.9)				
				target2:GiveMana(target:GetMaxMana())
				target2:SetBaseMagicalResistanceValue(target2:GetBaseMagicalResistanceValue() + (100 - target2:GetBaseMagicalResistanceValue()) * 0.01 * ability:GetSpecialValueFor("magic_resistance"))
				ability:ApplyDataDrivenModifier(caster, target2, "modifier_chen_custom_holy_persuasion_buff", {duration = -1})
				ability:ApplyDataDrivenModifier(caster, target2, "modifier_invulnerable", {duration = -1})
				ability:ApplyDataDrivenModifier(caster, target2, "modifier_phased", {duration = -1})
				ability:ApplyDataDrivenModifier(caster, target2, "modifier_fountain_aura_buff", {duration = -1})
				--ability:AddNewModifier(caster, target2, "modifier_extra_stuf_mana", {duration = -1})
				FindClearSpaceForUnit( target2, target2:GetAbsOrigin(), true ) 
				-- Track the unit
				ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
				table.insert(ability.holy_persuasion_table, target2)

				-- If the maximum amount of units is reached then kill the oldest unit
				if ability.holy_persuasion_unit_count > max_units then
					ability.holy_persuasion_table[1]:ForceKill(true) 
				end
			end
		
		end]]
	end
end

--[[Author: Pizzalol
	Date: 06.04.2015.
	Removes the target from the table]]
function HolyPersuasionRemove( keys )
	local target = keys.target
	local ability = keys.ability

	-- Find the unit and remove it from the table
	--[[if target:IsAncient() then
		for i = 1, #ability.holy_persuasion_ancient_table do
			if ability.holy_persuasion_ancient_table[i] == target then
				table.remove(ability.holy_persuasion_ancient_table, i)
				ability.holy_persuasion_ancient_unit_count = ability.holy_persuasion_ancient_unit_count - 1
				break
			end
		end
	else]]
	for i = 1, #ability.holy_persuasion_table do
		if ability.holy_persuasion_table[i] == target then
			table.remove(ability.holy_persuasion_table, i)
			ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count - 1
			break
		end
	end
	--end
end

function GetRandomAbilityName( hero )                 
    local abilityList = {
        "beastmaster_inner_beast",      -- 兽王    野性之心
        --"skeleton_king_vampiric_aura",      --骷髅王2
        "skeleton_king_mortal_strike",      --骷髅王3
        "spirit_breaker_greater_bash",            --发条2
        "sven_great_cleave",                -- sven 2
        "mjz_obsidian_destroyer_essence_aura",                      -- 全能 3
        --"antimage_custom_mana_break",          -- 伐木机 3
        "mjz_night_stalker_hunter_in_the_night",                  -- 潮汐 1
        --"phantom_assassin_blur",          -- 潮汐 2
        "tidehunter_anchor_smash",          -- 潮汐 3
        "mjz_omniknight_degen_aura",        -- 夜魔 3
		"mjz_vengefulspirit_vengeance",			-- 老奶奶 2
        "troll_warlord_fervor",            -- 老奶奶 3
        "chaos_knight_chaos_strike",        -- 混沌3
        "mars_bulwark",              -- 猛犸 1
        "magnataur_empower",                -- 猛犸 2
        "legion_commander_custom_duel",                 -- 猛犸 3
        "alchemist_chemical_rage",                 -- 马尔斯 2
        "lone_druid_rabid",       -- 龙骑3
		"lone_druid_spirit_link",					-- 小骷髅 扫射
        "juggernaut_healing_ward",          -- 剑圣2
        "lone_druid_spirit_bear_demolish",           -- 剑圣3
        "templar_assassin_psi_blades",      -- TA 3
        "mjz_vengefulspirit_vengeance",      -- VS 3
        "monkey_king_custom_jingu_mastery",          -- 小娜迦 1
        "mjz_omniknight_repel",           -- 影魔 4
        "lycan_feral_impulse",              -- 影魔 5
        "mjz_ursa_overpower",                   -- 拍拍熊 2
        --"ursa_fury_swipes",                 -- 拍拍熊 3
        "lich_custom_cold_soul",                  -- 火枪 3
        "lycan_feral_impulse",           -- 飞机 3
        "brewmaster_drunken_brawler",                -- 美杜莎 1
        "mjz_broodmother_insatiable_hunger",                      -- 白虎 3
        "abyssal_underlord_atrophy_aura",             -- 滚滚 3
        "meepo_ransack",                    -- 米波 3
        "brewmaster_fire_permanent_immolation",           -- 蚂蚁 3    bug
        "faceless_void_time_lock",          -- 虚空 3
        "ogre_magi_bloodlust",            -- 血魔 1
        --"mjz_clinkz_soul_pact",                -- 赏金 2
        "luna_lunar_blessing",              -- 露娜 3
        "elder_titan_natural_order",                 -- 蝙蝠 3
        "nyx_assassin_custom_vendetta",             -- 先知 2
        "skywrath_mage_ancient_seal",       -- 天怒 3
        --"disruptor_custom_ion_hammer",        -- 冰龙 1 crash on snowball
        "dark_willow_bedlam",                 
        "rubick_arcane_supremacy",          -- 拉比克 3
        "jakiro_liquid_fire",               -- 双头龙 3
        "obsidian_destroyer_arcane_orb",    -- 黑鸟 1
        "mjz_crystal_maiden_brilliance_aura",   -- 冰女 3
        "naga_siren_rip_tide",     -- 沉默 1
        "imba_phantom_assassin_coup_de_grace",                -- 女王 2
        "dazzle_bad_juju",                  -- 丽娜 3
        "ancient_apparition_chilling_touch",    -- 冰魂 3
        "visage_soul_assumption",            -- 蓝猫 3
        "medusa_stone_gaze",              -- 蓝胖 3
        "enchantress_impetus",              -- 小鹿 1
        "wisp_overcharge",                  -- 黑贤 3
        "tusk_walrus_punch",          -- 哈斯卡 3
        "dark_willow_shadow_realm",     
        "bane_enfeeble",           -- 2
        "ryze_arcane_mastery",     --4
        "elder_titan_natural_order_spirit",      -- 熊怪 迅捷光环
        "oracle_false_promise",             -- 坚韧光环
        "mars_gods_rebuke",     -- 龙肤光环 没有光环
        "void_spirit_astral_step",       -- 溅射攻击
        "big_thunder_lizard_wardrums_aura",   --战鼓光环
        "phantom_reflex",
        "mjz_general_megamorph",            --巨大化
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
        --"mjz_troll_warlord_battle_trance",
        "vengefulspirit_command_aura",
        "enigma_midnight_pulse",
		"sniper_headshot",
		"mjz_chaos_knight_chaos_strike",
        "lich_chain_frost",
        "weaver_the_swarm",
        "hoodwink_acorn_shot",
		"clinkz_infernal_breath",
		"nevermore_dark_lord",		

        
    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]   
end


function KillMePls(keys)
	keys.caster:Kill(keys.ability, keys.caster)
end