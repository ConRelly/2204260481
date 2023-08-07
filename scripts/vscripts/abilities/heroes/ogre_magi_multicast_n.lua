LinkLuaModifier("modifier_ogre_magi_multicast_n", "abilities/heroes/ogre_magi_multicast_n", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ogre_magi_multicast_n_no_animation", "abilities/heroes/ogre_magi_multicast_n", LUA_MODIFIER_MOTION_NONE)

ogre_magi_multicast_n = class({})
function ogre_magi_multicast_n:GetIntrinsicModifierName() return "modifier_ogre_magi_multicast_n" end
function ogre_magi_multicast_n:GetCooldown(lvl)
	if not IsServer() then return end
	return self:GetCaster():CustomValue("ogre_magi_custom_bonus_unique_2", "risk_cooldown") / self:GetCaster():GetCooldownReduction()
end
function ogre_magi_multicast_n:OnInventoryContentsChanged(params)
	if IsServer() then
		local caster = self:GetCaster()

		local FireBlast = caster:FindAbilityByName("ogre_magi_unrefined_fireblast_lua")
		if not FireBlast then return end

		FireBlast:SetActivated(caster:HasScepter())
		FireBlast:SetHidden(not caster:HasScepter())

		if FireBlast:GetLevel() < 1 then FireBlast:SetLevel(1) end

	end
end


modifier_ogre_magi_multicast_n = class({})
function modifier_ogre_magi_multicast_n:IsHidden() return true end
function modifier_ogre_magi_multicast_n:IsDebuff() return false end
function modifier_ogre_magi_multicast_n:IsPurgable() return false end
function modifier_ogre_magi_multicast_n:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ogre_magi_multicast_n:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end
function modifier_ogre_magi_multicast_n:OnAbilityFullyCast(params)
	if not IsServer() then return end
	local unit = params.unit
	local caster = self:GetCaster()
	if unit ~= caster then return end
	if unit ~= self:GetParent() then return end
	if caster:IsIllusion() then return end
	if params.ability:IsNull() then return end
	if params.ability == self:GetAbility() then return end
	if IsExcludeAbility(params.ability) then return end
	if caster:PassivesDisabled() then return end
	if params.ability:IsToggle() then return end
	if params.ability:GetCooldown(params.ability:GetLevel()) <= 0 then return end
	if params.ability:GetCaster() ~= caster then return end
	local casts = 1
	local used_ability = params.ability
	local original_target = params.target
	local cursor_position = used_ability:GetCursorPosition()
	local cursor_target = used_ability:GetCursorTarget()
	local marci_add = 0


	local delay = self:GetAbility():GetSpecialValueFor("interval")
	if used_ability:IsItem() then
		delay = 0.03
	end

	if self:GetAbility():GetAbilityName() == "ogre_magi_multicast_n" then
		if used_ability:GetAbilityType() == 1 then return end
		if IsExcludeAbilityN(used_ability) then return end
		if caster:HasModifier("modifier_super_scepter") then
			if caster:HasModifier("modifier_marci_unleash_flurry") then
				marci_add = 2
			end
		end
		local two_times = self:GetAbility():GetSpecialValueFor("multicast_2_times") + talent_value(caster, "ogre_magi_custom_bonus_unique_1")
		local three_times = self:GetAbility():GetSpecialValueFor("multicast_3_times") + talent_value(caster, "ogre_magi_custom_bonus_unique_1")
		local four_times = self:GetAbility():GetSpecialValueFor("multicast_4_times") + talent_value(caster, "ogre_magi_custom_bonus_unique_1")
		if RollPseudoRandomPercentage(two_times, 0, caster) then
			casts = 2 + marci_add
		end
		if RollPseudoRandomPercentage(three_times, 0, caster) then
			casts = 3 + marci_add
		end
		if RollPseudoRandomPercentage(four_times, 0, caster) then
			casts = 4 + marci_add
		end

		if self:GetAbility():IsCooldownReady() and caster:HasTalent("ogre_magi_custom_bonus_unique_2") then
			if casts == 1 then
				caster:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
				local particleFail = ParticleManager:CreateParticle("particles/base_attacks/ranged_tower_bad_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:ReleaseParticleIndex(particleFail)
			else
				casts = casts * 2
				local set_cooldown = caster:CustomValue("ogre_magi_custom_bonus_unique_2", "risk_cooldown")  or 5
				--print("ogre self cd: "..set_cooldown)
				self:GetAbility():StartCooldown(set_cooldown)
				local particleSuccess = ParticleManager:CreateParticle("particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff_ground_ray.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:ReleaseParticleIndex(particleSuccess)
			end
		end
	elseif self:GetAbility():GetAbilityName() == "ogre_magi_multicast_lua" then
		if IsExcludeAbility9(used_ability) then return end
		local two_times = self:GetAbility():GetSpecialValueFor("multicast_2_times")
		local three_times = self:GetAbility():GetSpecialValueFor("multicast_3_times")
		local four_times = self:GetAbility():GetSpecialValueFor("multicast_4_times")
		local nine_times = self:GetAbility():GetSpecialValueFor("multicast_9_times")
		if RollPseudoRandomPercentage(two_times, 0, caster) then
			casts = 2
		end
		if RollPseudoRandomPercentage(three_times, 0, caster) then
			casts = 3
		end
		if RollPseudoRandomPercentage(four_times, 0, caster) then
			casts = 4
		end
		if RollPseudoRandomPercentage(nine_times, 0, caster) then
			casts = 9
		end
	end

	if SingleTargetAbility(used_ability) then single = true else single = false end

	local proced_targets = {}
	if original_target ~= nil then
		proced_targets[original_target] = true
	end

	if casts > 1 then
		local target_flags = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
		if bit.band(used_ability:GetAbilityTargetFlags(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) ~= 0 then
			target_flags = target_flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		end
		local ability = used_ability
		local origin_timer_target = original_target
		for count = 1, casts - 1 do
			count = count + 1
			if origin_timer_target ~= nil and ability ~= nil then
				local radius = ability:GetCastRange(origin_timer_target:GetOrigin(), origin_timer_target) + 300
				if origin_timer_target:GetTeamNumber() ~= caster:GetTeamNumber() then
					if ability then
						Timers:CreateTimer((count - 1) * delay, function()
							if not caster:IsAlive() then return end
							if ability == nil then return end
							if ability:IsNull() then return end
							local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_flags, FIND_ANY_ORDER, false)

							if single then
								if origin_timer_target:IsNull() then return end
								if not origin_timer_target:IsAlive() then return end
								if origin_timer_target:GetTeamNumber() == caster:GetTeamNumber() then return end
								caster:SetCursorCastTarget(origin_timer_target)
							else
								for _, target in pairs(targets) do
									if target and not target:IsNull() then
										caster:SetCursorCastTarget(target)
									end
								end
								for _, target in pairs(targets) do
									if target and not target:IsNull() then
										if not proced_targets[target] then
											proced_targets[target] = true
											caster:SetCursorCastTarget(target)
											break
										end
									end
								end
							end
							if IsValidEntity(ability) and not ability:IsNull() then
								self:Multicast_FX(count, casts)
								ability:OnSpellStart()
							end	
						end)
					end
				else
					Timers:CreateTimer((count - 1) * delay, function()
						if not caster:IsAlive() then return end
						if ability == nil then return end
						if ability:IsNull() then return end
						local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_flags, FIND_ANY_ORDER, false)
						for _, target in pairs(targets) do
							if target and not target:IsNull() then
								caster:SetCursorCastTarget(target)
							end
						end
						for _, target in pairs(targets) do
							if target and not target:IsNull() then
								if not proced_targets[target] then
									proced_targets[target] = true
									caster:SetCursorCastTarget(target)
									break
								end
							end
						end
						if IsValidEntity(ability) and not ability:IsNull() then
							self:Multicast_FX(count, casts)
							ability:OnSpellStart()
						end						
					end)
				end
			else
				Timers:CreateTimer((count - 1) * delay, function()
					if not caster:IsAlive() then return end
					if ability == nil then return end
					if ability:IsNull() then return end
					if ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then return end
					if cursor_position ~= nil then
						caster:SetCursorPosition(cursor_position)
					else
						caster:SetCursorTargetingNothing(true)
					end
					if IsValidEntity(ability) and not ability:IsNull() then
						self:Multicast_FX(count, casts)
						ability:OnSpellStart()
					end	
				end)
			end
		end
	end
end


modifier_ogre_magi_multicast_n_no_animation = class({})
function modifier_ogre_magi_multicast_n_no_animation:IsHidden() return true end
function modifier_ogre_magi_multicast_n_no_animation:IsPurgable() return false end

local count_number = 0
function modifier_ogre_magi_multicast_n:Multicast_FX(count, casts)
	local caster = self:GetCaster()
	local ten = 0
	local counter_speed = 2
	if caster:HasModifier("modifier_ogre_magi_multicast_n_no_animation") then return end

	if not caster:HasModifier("modifier_ogre_magi_multicast_n_no_animation") and count_number > 11 then	
		local duration = (100 / _G._effect_rate) + 1		
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_ogre_magi_multicast_n_no_animation", {duration = duration})
		count_number = 0 
	end
	count_number = count_number + 1
	if count == casts then counter_speed = 1 end
	if count - 1 > 3 then sound = 3 else sound = count end


--[[
	if effect_cast and (count - 1) > 1 and (count - 1) < (casts + 1) then
		ParticleManager:DestroyParticle(effect_cast, false)
		ParticleManager:ReleaseParticleIndex(effect_cast)
	end
]]

	if count <= 9 then
		count = count
	elseif count > 9 and count <= 19 then
		count = count - 10
		ten = 1
	elseif count > 19 and count <= 29 then
		count = count - 20
		ten = 2
	elseif count > 29 and count <= 39 then
		count = count - 30
		ten = 3
	elseif count > 39 and count <= 49 then
		count = count - 40
		ten = 4
	elseif count > 49 and count <= 59 then
		count = count - 50
		ten = 5
	elseif count > 59 and count <= 69 then
		count = count - 60
		ten = 6
	end

	local effect_cast = ParticleManager:CreateParticle("particles/custom/abilities/heroes/ogre_magi_multicast/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(count, counter_speed, 0))
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(ten, counter_speed, 0))

	local sound_line = math.min(sound -1, 3)
	local sound_cast = "Hero_OgreMagi.Fireblast.x" .. sound_line
	if sound_line > 0 then
		caster:EmitSoundParams(sound_cast, 0, 0.3, 0)
	end
end


function IsExcludeAbility(ability)
	local list = {
-- Items
		"item_dimensional_doorway",
		"item_ward_observer",
		"item_ward_sentry",
		"item_smoke_of_deceit",
		"item_tpscroll",
		"item_travel_boots",
		"item_travel_boots_2",
		"item_conduit",
		"item_god_slayer",
		"item_pocket_rax",
		"item_pocket_rax_ranged",
		"item_pocket_tower",
		"item_echo_wand",
		"item_remove_ability",
		"item_video_file",
		"item_custom_ex_machina",
		"item_custom_octarine_core2",
		"item_crit_edible",
		"item_auto_cast",
		"item_auto_cast2",
		"item_aegis_lua",
		"item_hammer_of_the_divine",
		"item_spellbook_destruction",
		"item_blink",
		"item_custom_refresher",
		"item_random_get_ability_3",
		"item_random_get_ability3",
		"item_random_get_ability_spell",
		"item_random_get_ability",
		"item_random_get_ability_onlvl",
		"item_imba_ultimate_scepter_synth2",
		"item_ritual_shovel",
		"item_custom_seer_stone",
		"item_master_of_weapons_sword",
		"item_master_of_weapons_sword2",
		"item_master_of_weapons_sword3",
		"item_master_of_weapons_sword4",
		"item_master_of_weapons_sword5",
		"item_mjz_bloodstone_ultimate_edible",
		"item_thunder_hammer",
		"item_thunder_gods_might",
		"item_thunder_gods_might2",	
		"item_pipe_of_dezun",
		"item_all_essence",	
-- Abilities
		"phoenix_fire_spirits",
		"mjz_phoenix_sun_ray",
		"mjz_phoenix_sun_ray_toggle_move",
		"mjz_phoenix_sun_ray_cancel",
		"mjz_phoenix_supernova",
		"phoenix_launch_fire_spirit",
		"rubick_telekinesis",
		"rubick_telekinesis_land",
		"tusk_launch_snowball",
		"shadow_shaman_shackles",
		"chen_custom_holy_persuasion",
		"mjz_ember_spirit_sleight_of_fist",
		"riki_blink_strike",
		"mjz_phantom_assassin_phantom_strike",
		"dark_seer_custom_dark_clone",
		"undying_tombstone",
		"mjz_windrunner_powershot",
		"antimage_blink",
		"frostivus2018_faceless_void_time_walk",
		"obsidian_destroyer_astral_imprisonment",
		"obsidian_destroyer_arcane_orb",
		"obs_replay",
		"dawnbreaker_celestial_hammer",
		"dawnbreaker_converge",
		"wisp_tether",
		"wisp_tether_break",
		"arcane_supremacy",
		"hw_sharpshooter",
		"hw_sharpshooter_release",
		"invoker_invoke",
		"phantom_lancer_phantom_edge",
		"dazzle_good_juju",
		"primal_beast_onslaught",
		"primal_beast_onslaught_release",
		"queenofpain_blink",
		"amalgamation",
		"enchantress_enchant",
		"rubick_spell_steal",
		"chaos_knight_phantasm",
		"terrorblade_custom_reflection",
		"dazzle_shadow_wave",
		"pocket_portal",
		"reload_bullet",
		"enigma_black_hole",
		"muerta_pierce_the_veil",
		"true_master",
	}
	local abilityName = ability:GetAbilityName()
	for _,name in pairs(list) do
		if abilityName == name then
			return true
		end
	end
	return false
end
function IsExcludeAbilityN(ability)
	local list = {
-- Items
		"item_custom_ex_machina",
		"item_spellbook_destruction",
-- Abilities
		"shadow_shaman_shackles",
		"obsidian_destroyer_arcane_orb",
	}
	local abilityName = ability:GetAbilityName()
	for _,name in pairs(list) do
		if abilityName == name then
			return true
		end
	end
	return false
end

function IsExcludeAbility9(ability)
	local list = {
-- Items
		"item_master_of_weapons_sword",
		"item_master_of_weapons_sword2",
		"item_master_of_weapons_sword3",
		"item_master_of_weapons_sword4",
		"item_master_of_weapons_sword5",
		"item_mjz_bloodstone_ultimate_edible",
		"item_thunder_hammer",	
		"item_thunder_gods_might",
		"item_thunder_gods_might2",	
		"item_pipe_of_dezun",
-- Abilities
		"mjz_tinker_quick_arm",
		"naga_siren_song_of_the_siren",
		"naga_siren_song_of_the_siren_cancel",
		"keeper_of_the_light_illuminate",
		"keeper_of_the_light_illuminate_end",
		"keeper_of_the_light_spirit_form_illuminate_end",
		"pangolier_gyroshell",
		"pangolier_gyroshell_stop",
		"bane_nightmare",
		"bane_nightmare_end",
		"mjz_templar_assassin_trap_teleport",
		"dark_seer_custom_dark_clone_2",
		"riki_tricks_of_the_trade",
		"rubick_spell_steal",
		"juggernaut_omni_slash",
		"juggernaut_swift_slash",
		"oracle_fates_edict",
		"oracle_purifying_flames",
		"spirit_breaker_charge_of_darkness",
		"broodmother_spin_web",
		"mjz_broodmother_spawn_spiderlings",
		"shredder_chakram",
		"shredder_chakram_2",
		"shredder_return_chakram",
		"shredder_return_chakram_2",
		"alchemist_unstable_concoction",
		"alchemist_unstable_concoction_throw",
		"hoodwink_sharpshooter",
		"hoodwink_sharpshooter_release",
		"brewmaster_primal_split",
		"keeper_of_the_light_spirit_form",
		"life_stealer_infest",
		"tinker_custom_heat_seeking_missile",
		"mjz_techies_suicide",
		"mjz_zuus_lightning",
		"ancient_apparition_ice_blast",
		"ancient_apparition_ice_blast_release",
		"zanto_gari",
		"enchantress_enchant",
		"rubick_spell_steal",
		"chaos_knight_phantasm",
		"terrorblade_custom_reflection",
		"dazzle_shadow_wave",
		"pocket_portal",
		"reload_bullet",
	}
	local abilityName = ability:GetAbilityName()
	for _,name in pairs(list) do
		if abilityName == name then
			return true
		end
	end
	return false
end

function SingleTargetAbility(ability)
	local list = {
		"ogre_magi_fireblast",
		"ogre_magi_unrefined_fireblast",
		--"grimstroke_custom_ink_creature",
	}
	local abilityName = ability:GetAbilityName()
	for _,name in pairs(list) do
		if abilityName == name then
			return true
		end
	end
	return false
end
