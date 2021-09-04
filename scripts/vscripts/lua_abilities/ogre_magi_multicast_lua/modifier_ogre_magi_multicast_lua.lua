-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
require("lib/my")
--------------------------------------------------------------------------------
modifier_ogre_magi_multicast_lua = class({})
modifier_ogre_magi_multicast_lua.singles = {
	["ogre_magi_fireblast_lua"] = true,
	["ogre_magi_unrefined_fireblast_lua"] = true,
	--["omniknight_purification_lua"] = true,
	--["lion_custom_finger_of_death"] = true,
	--["phantom_assassin_stifling_dagger"] = true,
	--["mjz_finger_of_death"] = true,
	--["tiny_custom_toss"] = true,
	--["spirit_breaker_charge_of_darkness"] = true,
	--["mjz_necrolyte_reapers_scythe"] = true,
	--["mjz_zuus_lightning_bolt"] = true,

}
modifier_ogre_magi_multicast_lua.banned = {
	["item_blink"] = true,
	["invoker_quas"] = true,
	["invoker_wex"] = true,
	["invoker_exort"] = true,
	["invoker_invoke"] = true,
	["item_tpscroll"] = true,
	["item_travel_boots"] = true,
	["item_travel_boots_2"] = true,
	["item_dimensional_doorway"] = true,
	["item_ward_observer"] = true,
	["item_ward_sentry"] = true,
	["item_smoke_of_deceit"] = true,
	["item_custom_refresher"] = true,
	["mjz_tinker_quick_arm"] = true,
	["phoenix_fire_spirits"] = true,
	["phoenix_launch_fire_spirit"] = true,
	["mjz_phoenix_sun_ray"] = true,
	["mjz_phoenix_sun_ray_toggle_move"] = true,
	["mjz_phoenix_sun_ray_cancel"] = true,
	["mjz_phoenix_supernova"] = true,
	["naga_siren_song_of_the_siren"] = true,
	["naga_siren_song_of_the_siren_cancel"] = true,
	["keeper_of_the_light_illuminate"] = true,
	["keeper_of_the_light_illuminate_end"] = true,
	["keeper_of_the_light_spirit_form_illuminate_end"] = true,
	["mjz_phantom_assassin_phantom_strike"] = true,
	["pangolier_gyroshell"] = true,
	["pangolier_gyroshell_stop"] = true,
	["ancient_apparition_ice_blast_release"] = true,
	["item_god_slayer"] = true,
	["rubick_telekinesis"] = true,
	["rubick_telekinesis_land"] = true,
	["bane_nightmare"] = true,
	["bane_nightmare_end"] = true,
	["tusk_launch_snowball"] = true,
	["chen_custom_holy_persuasion"] = true,
	["mjz_templar_assassin_trap_teleport"] = true,
	["mjz_ember_spirit_sleight_of_fist"] = true,
	["item_pocket_rax"] = true,
	["item_pocket_rax_ranged"] = true,
	["item_pocket_tower"] = true,
	["riki_blink_strike"] = true,
	["dark_seer_custom_dark_clone"] = true,
	["dark_seer_custom_dark_clone_2"] = true,
	["undying_tombstone"] = true,
	["riki_tricks_of_the_trade"] = true,
	["rubick_spell_steal"] = true,
	["juggernaut_omni_slash"] = true,
	["juggernaut_swift_slash"] = true,
	["mjz_windrunner_powershot"] = true,
	["antimage_blink"] = true,
	["frostivus2018_faceless_void_time_walk"] = true,
	["oracle_fates_edict"] = true,
	["item_custom_octarine_core2"] = true,
	["oracle_purifying_flames"] = true,
	["spirit_breaker_charge_of_darkness"] = true,
	["broodmother_spin_web"] = true,
	["mjz_broodmother_spawn_spiderlings"] = true,
	["shredder_chakram"] = true,
	["shredder_chakram_2"] = true,
	["shredder_return_chakram"] = true,
	["shredder_return_chakram_2"] = true,
	["item_echo_wand"] = true,
	["alchemist_unstable_concoction"] = true,
	["alchemist_unstable_concoction_throw"] = true,
	["item_remove_ability"] = true,
	["hoodwink_sharpshooter"] = true,
	["hoodwink_sharpshooter_release"] = true,
	["brewmaster_primal_split"] = true,
	["keeper_of_the_light_spirit_form"] = true,
	["life_stealer_infest"] = true,
	["item_conduit"] = true,  
	["obsidian_destroyer_astral_imprisonment"] = true, 
	["tinker_custom_heat_seeking_missile"] = true,
	["mjz_techies_suicide"] = true,
	["obs_replay"] = true,
	["item_video_file"] = true,
	["mjz_zuus_lightning"] = true,
	["dawnbreaker_celestial_hammer"] = true,
	["dawnbreaker_converge"] = true,
	["wisp_tether"] = true,
	["wisp_tether_break"] = true,
	["ancient_apparition_ice_blast"] = true,
	["ancient_apparition_ice_blast_release"] = true,
	["zanto_gari"] = true,
	["arcane_supremacy"] = true,
	["hw_sharpshooter"] = true,
	["hw_sharpshooter_release"] = true,
	["item_crit_edible"] = true,
}

--------------------------------------------------------------------------------
-- Classifications
function modifier_ogre_magi_multicast_lua:IsHidden() return (self:GetAbility():GetLevel() == 0) end

function modifier_ogre_magi_multicast_lua:IsDebuff()
	return false
end

function modifier_ogre_magi_multicast_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ogre_magi_multicast_lua:OnCreated( kv )
	-- references
	self.chance_2 = self:GetAbility():GetSpecialValueFor( "multicast_2_times" ) * 100
	self.chance_3 = self:GetAbility():GetSpecialValueFor( "multicast_3_times" ) * 100
	self.chance_4 = self:GetAbility():GetSpecialValueFor( "multicast_4_times" ) * 100
	self.chance_10 = self:GetAbility():GetSpecialValueFor( "multicast_9_times" )

	self.buffer_range = 6500
end

function modifier_ogre_magi_multicast_lua:OnRefresh( kv )
	-- references
	self.chance_2 = self:GetAbility():GetSpecialValueFor( "multicast_2_times" ) * 100
	self.chance_3 = self:GetAbility():GetSpecialValueFor( "multicast_3_times" ) * 100
	self.chance_4 = self:GetAbility():GetSpecialValueFor( "multicast_4_times" ) * 100
	self.chance_10 = self:GetAbility():GetSpecialValueFor( "multicast_9_times" )
end

function modifier_ogre_magi_multicast_lua:OnRemoved()
end

function modifier_ogre_magi_multicast_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ogre_magi_multicast_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}

	return funcs
end

function modifier_ogre_magi_multicast_lua:OnAbilityFullyCast( params )
	if params.unit~=self:GetCaster() then return end
	if params.ability==self:GetAbility() then return end
	local hAbility = params.ability

	-- cancel if break
	if self:GetCaster():PassivesDisabled() then return end

	-- only spells that have target
	-- if not params.target then return end

	-- check if spell is banned
	local abilityName = params.ability:GetAbilityName()
	if self.banned[abilityName] then return end
	--if not params.ability:ProcsMagicStick() then return end

	-- if the spell can do both target and point, it should not trigger
	--if bit.band( params.ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT ) ~= 0 then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_CHANNELLED ) ~= 0 then return end

	-- Ensure it is not a passive ability
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_PASSIVE ) ~= 0 then return end
	--if params.ability:GetCooldown(0) <= 0  then return end

	-- Talent Tree
	local special_multicast_ten_chance_lua = self:GetCaster():FindAbilityByName("special_multicast_ten_chance_lua")
	if special_multicast_ten_chance_lua and special_multicast_ten_chance_lua:GetLevel() ~= 0 then
		self.chance_10 = special_multicast_ten_chance_lua:GetSpecialValueFor("value")
	end

	-- roll multicasts
	local casts = 1
	if RandomInt( 0,100 ) < self.chance_2 then casts = 2 end
	if RandomInt( 0,100 ) < self.chance_3 then casts = 3 end
	if RandomInt( 0,100 ) < self.chance_4 then casts = 4 end
	if RandomInt( 0,100 ) < self.chance_10 then casts = 9 end

	-- check delay
	local delay = params.ability:GetSpecialValueFor( "multicast_delay" ) or 0.3

	-- only for fireblast multicast to single target
	local single = self.singles[abilityName] or false
	local pass = false
	local behavior = params.ability:GetBehavior()

	if params.target then
		-- multicast
		self:GetCaster():AddNewModifier(
			self:GetCaster(), -- player source
			self:GetAbility(), -- ability source
			"modifier_ogre_magi_multicast_lua_proc", -- modifier name
			{
				ability = params.ability:entindex(),
				target = params.target:entindex(),
				targetPoint = false,
				multicast = casts,
				delay = delay,
				single = single,
			} -- kv
		)
	else
		--print("ability" .. ability_behavior_includes(params.ability, DOTA_ABILITY_BEHAVIOR_POINT))
		if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_POINT ) ~= 0 then
		--if not IsValid(hAbility) or bit.band(GetAbilityBehavior(hAbility), DOTA_ABILITY_BEHAVIOR_POINT) ~= DOTA_ABILITY_BEHAVIOR_POINT then
		--if ability_behavior_includes(params.ability, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then	
			-- multicast point based spell
			self:GetCaster():AddNewModifier(
				self:GetCaster(), -- player source
				self:GetAbility(), -- ability source
				"modifier_ogre_magi_multicast_lua_proc", -- modifier name
				{
					ability = params.ability:entindex(),
					target_point = true,
					multicast = casts,
					delay = delay,
					single = single,
				} -- kv
			)
		else
			-- Don't allow non-targetting items as spells purchased can be activated
			if params.ability:IsItem() then return end

			self:GetCaster():AddNewModifier(
				self:GetCaster(), -- player source
				self:GetAbility(), -- ability source
				"modifier_ogre_magi_multicast_lua_self_cast_proc", -- modifier name
				{
					ability = params.ability:entindex(),
					multicast = casts,
					delay = delay,
				} -- kv
			)
		end
	end
end