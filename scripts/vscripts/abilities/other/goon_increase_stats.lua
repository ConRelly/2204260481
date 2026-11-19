require("lib/my")
local FormatScriptError = require("lib/script_error")

LinkLuaModifier("modifier_goon_guard", "abilities/other/goon_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)

local GetGoonAbilityName
local roundUpgrades = {
	{round = 5, item = "item_lesser_crit", skillLevel = 2},
	{round = 10, item = "item_plain_ring"},
	{round = 15, item = "item_mjz_heart_4", replaces = "item_heart", skillLevel = 3},
	{round = 20, skillLevel = 4},
	{round = 25, item = "item_mjz_heart_5", replaces = "item_mjz_heart_4", skillLevel = 5},
	{round = 30, item = "item_greater_crit", replaces = "item_lesser_crit", skillLevel = 6},
	{round = 35, item = "item_mjz_shivas_guard_5", replaces = "item_greater_crit", skillLevel = 7},
}

local function GiveItem(unit, name, replaces)
	if find_item(unit, name) then return end
	if replaces then
		local previousItem = find_item(unit, replaces)
		if previousItem then unit:TakeItem(previousItem) end
	end
	if not unit:AddItemByName(name) then
		error("Could not equip " .. name)
	end
end

local function UpdateRound(guard, unit, ability)
	local round = GameRules.GLOBAL_roundNumber
	if not round then return end
	if GameRules.GLOBAL_endlessHard_started then
		round = round + 82
	elseif GameRules.GLOBAL_endlessMode_started then
		round = round + 44
	end
	if round == guard.previousRound then return end
	local levels = round - unit:GetLevel()
	if levels > 0 then unit:CreatureLevelUp(levels) end

	while roundUpgrades[guard.nextUpgrade] and round > roundUpgrades[guard.nextUpgrade].round do
		local upgrade = roundUpgrades[guard.nextUpgrade]
		if upgrade.item then
			unit:SetHasInventory(true)
			GiveItem(unit, upgrade.item, upgrade.replaces)
			if upgrade.round == 25 then GiveItem(unit, "item_ultimate_scepter") end
			unit:SetHasInventory(false)
		end
		if upgrade.round == 25 and not unit:HasModifier("modifier_goon_increase_stats") then
			unit:AddNewModifier(unit, ability, "modifier_goon_increase_stats", {})
		end
		guard.skillLevel = upgrade.skillLevel or guard.skillLevel
		guard.nextUpgrade = guard.nextUpgrade + 1
	end
	guard.previousRound = round
end

local function LearnSkill(unit, name, level)
	if unit:HasAbility(name) then return false end
	local ability = unit:AddAbility(name)
	if not ability or ability:IsNull() then return false end
	ability:SetLevel(level)
	return true
end

local function SetStartingAbilities(unit, skillLevel)
	if RandomInt(0, 100) < 75 and not unit:HasAbility("special_bonus_truestrike") then
		LearnSkill(unit, "special_bonus_truestrike", 1)
		LearnSkill(unit, "true_strike", 1)
	end
	for _, placeholder in ipairs({"goon_placeholder1", "goon_placeholder2"}) do
		if unit:HasAbility(placeholder) then unit:RemoveAbility(placeholder) end
	end
	if LearnSkill(unit, GetGoonAbilityName(), skillLevel) then
		LearnSkill(unit, GetGoonAbilityName(), skillLevel)
		if RollPercentage(75) or skillLevel == 7 then
			unit:AddNewModifier(unit, nil, "modifier_item_ultimate_scepter_consumed", {})
		end
	end
end

function goon_guard_on_created(keys)
	local unit = keys.caster
	if unit and not unit:IsNull() and not unit:HasModifier("modifier_goon_guard") then
		unit:AddNewModifier(unit, keys.ability, "modifier_goon_guard", {})
	end
end

modifier_goon_guard = class({})
function modifier_goon_guard:IsHidden() return true end
function modifier_goon_guard:IsPurgable() return false end

function modifier_goon_guard:OnCreated()
	if not IsServer() then return end
	self.previousRound = 1
	self.nextUpgrade = 1
	self.skillLevel = 1
	self:StartIntervalThink(0.1)
end

function modifier_goon_guard:OnIntervalThink()
	local unit = self:GetParent()
	local ability = self:GetAbility()
	if not unit or unit:IsNull() or not unit:IsAlive() or not ability or ability:IsNull() then
		self:StartIntervalThink(-1)
		return
	end
	-- Guard's datadriven modifier can be created before the spawn callback assigns ownership.
	local owner = unit:GetOwner()
	if not owner or owner:IsNull() then return end

	if not self.equipped then
		unit:SetHasInventory(true)
		local ok, err = pcall(function()
			GiveItem(unit, "item_force_blade")
			GiveItem(unit, "item_heart")
			GiveItem(unit, "item_boss_resistance_25")
		end)
		unit:SetHasInventory(false)
		unit:SetCanSellItems(false)
		if not ok then
			print("[Hired Goon] Starting equipment failed: " .. FormatScriptError(err))
			self:StartIntervalThink(2)
			return
		end
		self.equipped = true
	end

	local ok, err = pcall(UpdateRound, self, unit, ability)
	if not ok then
		unit:SetHasInventory(false)
		print("[Hired Goon] Round upgrade failed: " .. FormatScriptError(err))
		self:StartIntervalThink(2)
		return
	end
	if not self.skillsAssigned then
		self.skillsAssigned = true
		ok, err = pcall(SetStartingAbilities, unit, self.skillLevel)
		if not ok then print("[Hired Goon] Starting abilities failed: " .. FormatScriptError(err)) end
	end
	self:StartIntervalThink(2)
end

GetGoonAbilityName = function()
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
        --"dark_willow_bedlam",
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
