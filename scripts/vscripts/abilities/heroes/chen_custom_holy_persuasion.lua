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
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
	return funcs
end
function modifier_extra_stuf_mana:GetModifierManaBonus() return 40420 end
function modifier_extra_stuf_mana:GetModifierBaseAttackTimeConstant()	 
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("base_attack_time") end
end

function HolyPersuasion(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local player = caster:GetPlayerOwnerID()
	local max_units = ability:GetSpecialValueFor("max_units") + talent_value(caster, "special_bonus_unique_chen_custom_2")
	local chance_strike = ability:GetSpecialValueFor("true_strike_chance")
	local HP_Level = caster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel()
	EmitSoundOn("Hero_Chen.HolyPersuasionCast", caster)

	-- Initialize the tracking data
	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count or 0
	ability.holy_persuasion_table = ability.holy_persuasion_table or {}
	ability.holy_persuasion_ancient_unit_count = ability.holy_persuasion_ancient_unit_count or 0
	ability.holy_persuasion_ancient_table = ability.holy_persuasion_ancient_table or {}

	if caster:HasScepter() then
		if target:IsAncient() and caster:FindAbilityByName("chen_custom_avatar"):GetLevel() < 1 then return end
	else
		if target:IsAncient() then return end
	end
	if target:GetUnitName() == "npc_dota_inv_warrior" then return end
	EmitSoundOn("Hero_Chen.HolyPersuasionEnemy", target)
	target:SetTeam(caster:GetTeamNumber())
	target:SetOwner(caster)
	target:SetControllableByPlayer(player, true)
	target:AddNewModifier(caster, self, "modifier_kill", {})

	local kill_me_master = target:AddAbility("kill_me_master")
	kill_me_master:SetLevel(1)

	local searing = target:AddAbility("bloodseeker_thirst")

	local newAbilityName = GetRandomAbilityName(hero)
	local link_a = target:AddAbility(newAbilityName)

	local link_b
	local not_same_abilities = false
	while not not_same_abilities do
		local newAbilityNameb = GetRandomAbilityName(hero)
		if newAbilityNameb ~= newAbilityName then
			link_b = target:AddAbility(newAbilityNameb)
			not_same_abilities = true
		end
	end

	if RandomInt(0,100) < chance_strike then
		local true_strike = target:AddAbility("true_strike")
		true_strike:UpgradeAbility(true)
	end

	if target:FindAbilityByName("wisp_tether") then
		target:AddAbility("wisp_tether_break")
	end

	local nAbilities = target:GetAbilityCount()
	for i = 0, nAbilities do
		if searing and searing:CanAbilityBeUpgraded() == ABILITY_CAN_BE_UPGRADED then
			while searing:GetLevel() < HP_Level and searing:GetLevel() < searing:GetMaxLevel() do
				searing:UpgradeAbility(true)
			end
		end
		if link_a and link_a:CanAbilityBeUpgraded() == ABILITY_CAN_BE_UPGRADED then
			while link_a:GetLevel() < HP_Level and link_a:GetLevel() < link_a:GetMaxLevel() do
				link_a:UpgradeAbility(true)
			end
		end
		if link_b and link_b:CanAbilityBeUpgraded() == ABILITY_CAN_BE_UPGRADED then
			while link_b:GetLevel() < HP_Level and link_b:GetLevel() < link_b:GetMaxLevel() do
				link_b:UpgradeAbility(true)
			end
		end
	end
	
	target:AddNewModifier( caster, hAbility, "modifier_extra_stuf_mana", {})
	local caster_damage = caster:GetAverageTrueAttackDamage(caster) * ability:GetSpecialValueFor("casters_dmg") / 100
	local chen_skill_lvl = caster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel()
	if chen_skill_lvl > 3 then
		caster_damage = caster_damage + ((caster:GetMaxHealth() + caster:GetMaxMana()) * ability:GetSpecialValueFor("hp_mana_to_dmg") / 100) + (caster:GetSpellAmplification(false) * ability:GetSpecialValueFor("sp_amp_to_dmg") * 100) + (caster:GetPhysicalArmorValue(false) * ability:GetSpecialValueFor("armor_to_dmg"))
	end
	target:SetBaseDamageMin(caster_damage)
	target:SetBaseDamageMax(caster_damage)
	target:SetBaseMoveSpeed(ability:GetSpecialValueFor("base_ms"))
	target:SetAcquisitionRange(2900)
	target:SetBaseAttackTime(ability:GetSpecialValueFor("base_attack_time"))
	target:GiveMana(target:GetMaxMana())
--	target:SetBaseMagicalResistanceValue(target:GetBaseMagicalResistanceValue() + (100 - target:GetBaseMagicalResistanceValue()) * 0.01 * ability:GetSpecialValueFor("magic_resistance"))
	ability:ApplyDataDrivenModifier(caster, target, "modifier_chen_custom_holy_persuasion_buff", {})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_invulnerable", {})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_fountain_aura_buff", {})
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_item_ultimate_scepter_consumed", {})
	end	
	FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
	if target:HasModifier("modifier_boss") then
		target:RemoveModifierByName("modifier_boss")
	end	
	-- Track the unit
	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
	table.insert(ability.holy_persuasion_table, target)

	-- If the maximum amount of units is reached then kill the oldest unit
	if ability.holy_persuasion_unit_count > max_units then
		ability.holy_persuasion_table[1]:ForceKill(true) 
	end
end


--LinkLuaModifier("modifier_agha_scepter_aura", "abilities/heroes/chen_custom_holy_persuasion", LUA_MODIFIER_MOTION_NONE)

update_chen_holy_persuasion = class({})
--function update_chen_holy_persuasion:GetIntrinsicModifierName()	return "modifier_agha_scepter_aura" end
function update_chen_holy_persuasion:GetCooldown(lvl)
	return self.BaseClass.GetCooldown(self, lvl) / self:GetCaster():GetCooldownReduction()
end
function update_chen_holy_persuasion:GetManaCost(lvl)
	return self:GetCaster():GetMaxMana()
end
function update_chen_holy_persuasion:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local unit_position = 0
		local ability = self
		local search_controlled = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
		for _, unit in pairs(search_controlled) do
			if unit ~= caster and unit:GetUnitName() ~= "npc_dota_courier" then
				if unit:GetMainControllingPlayer() == caster:GetPlayerOwnerID() and unit:IsCreep() then

					local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
					ParticleManager:SetParticleControl(particle, 1, unit:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(particle)

					local caster_damage = caster:GetAverageTrueAttackDamage(caster) * caster:CustomValue("chen_custom_holy_persuasion", "casters_dmg") / 100
					local chen_skill_lvl = caster:FindAbilityByName("chen_custom_holy_persuasion"):GetLevel()
					if chen_skill_lvl > 3 then
						caster_damage = caster_damage + ((caster:GetMaxHealth() + caster:GetMaxMana()) * caster:CustomValue("chen_custom_holy_persuasion", "hp_mana_to_dmg") / 100) + (caster:GetSpellAmplification(false) * caster:CustomValue("chen_custom_holy_persuasion", "sp_amp_to_dmg") * 100) + (caster:GetPhysicalArmorValue(false) * caster:CustomValue("chen_custom_holy_persuasion", "armor_to_dmg"))
					end
					unit:SetBaseDamageMin(caster_damage)
					unit:SetBaseDamageMax(caster_damage)

					if caster:HasScepter() then
						if unit:FindAbilityByName("wisp_tether") then
							local wisp_talent = unit:AddAbility("special_bonus_unique_wisp_4")
							wisp_talent:UpgradeAbility(true)
							wisp_talent:SetLevel(1)
						end
						if not unit:HasModifier("modifier_item_ultimate_scepter_consumed") then
							unit:AddNewModifier(caster, ability, "modifier_item_ultimate_scepter_consumed", {})
						end								
					end

					local nAbilities = unit:GetAbilityCount() - 1
					for i = 0, nAbilities do
						local hAbility = unit:GetAbilityByIndex(i)
						if hAbility and hAbility:CanAbilityBeUpgraded() == ABILITY_CAN_BE_UPGRADED then
							while hAbility:GetLevel() < chen_skill_lvl and hAbility:GetLevel() < hAbility:GetMaxLevel() do
								hAbility:UpgradeAbility(true)
							end
						end
					end
					unit_position = unit_position + 1
					if unit_position == 1 then
						side = 45
						forward = 150
					elseif unit_position == 2 then
						side = -45
						forward = 150
					elseif unit_position == 3 then
						side = 45
						forward = -150
					elseif unit_position == 4 then
						side = -45
						forward = -150
					elseif unit_position == 5 then
						side = 0
						forward = 250
					else
						side = 0
						forward = -250
					end
					local location = RotatePosition(caster:GetAbsOrigin(), QAngle(0, side, 0), caster:GetAbsOrigin() + caster:GetForwardVector() * forward)
					FindClearSpaceForUnit(unit, location, false)

					EmitSoundOn("Hero_Chen.TeleportIn", unit)
					EmitSoundOn("Hero_Chen.HandOfGodHealCreep", unit)
				end
			end
		end
	end
end

--[[ modifier_agha_scepter_aura = class({})
function modifier_agha_scepter_aura:IsHidden() return true end
function modifier_agha_scepter_aura:IsAura() return self:GetCaster():HasScepter() end
function modifier_agha_scepter_aura:IsAuraActiveOnDeath() return false end
function modifier_agha_scepter_aura:GetAuraRadius() return FIND_UNITS_EVERYWHERE end
function modifier_agha_scepter_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_agha_scepter_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_agha_scepter_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_agha_scepter_aura:GetModifierAura() return "modifier_item_ultimate_scepter_consumed" end
function modifier_agha_scepter_aura:GetAuraDuration() return 0.5 end
function modifier_agha_scepter_aura:GetAuraEntityReject(target)
	if target:GetMainControllingPlayer() ~= self:GetCaster():GetPlayerOwnerID() or target == self:GetCaster() then
		return true
	end
	return false
end
 ]]
--[[Author: Pizzalol
	Date: 06.04.2015.
	Removes the target from the table]]
function HolyPersuasionRemove(keys)
	local target = keys.target
	local ability = keys.ability
	for i = 1, #ability.holy_persuasion_table do
		if ability.holy_persuasion_table[i] == target then
			table.remove(ability.holy_persuasion_table, i)
			ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count - 1
			break
		end
	end
end

function GetRandomAbilityName(hero)
    local abilityList = {
-- Passive:
		--"vengefulspirit_command_aura",  -- crashes when the summon unit dies(aghanim effect) (if is not hero)
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
        "abyssal_underlord_atrophy_aura",
        "meepo_ransack",
        "brewmaster_fire_permanent_immolation",
        "faceless_void_time_lock",
        "luna_lunar_blessing",
        "elder_titan_natural_order",
        --"mjz_crystal_maiden_brilliance_aura",
        "naga_siren_rip_tide",
        "imba_phantom_assassin_coup_de_grace",
        "dazzle_bad_juju",
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
        "alchemist_chemical_rage",
        --"lone_druid_rabid",
        "juggernaut_healing_ward",
        "mjz_omniknight_repel",
        "mjz_ursa_overpower",
        "brewmaster_drunken_brawler",
        "mjz_broodmother_insatiable_hunger",
        "ogre_magi_bloodlust",
        "nyx_assassin_custom_vendetta",
        "skywrath_mage_ancient_seal",
        "dark_willow_bedlam",
        "visage_soul_assumption",
        "medusa_stone_gaze",
        "wisp_overcharge",
        "dark_willow_shadow_realm",
        "bane_enfeeble",
        "elder_titan_natural_order_spirit",
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


function KillMePls(keys)
	if keys.ability:GetAutoCastState() then
		keys.caster:Kill(keys.ability, keys.caster)
	end
end