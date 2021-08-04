require("lib/my")
require("lib/timers")
--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Determines the multicast multiplier and applies it to the necessary spell]]
function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local used_ability = keys.event_ability
	local two_times = ability:GetLevelSpecialValueFor( "multicast_2_times", ability:GetLevel() - 1 )
	local three_times = ability:GetLevelSpecialValueFor( "multicast_3_times", ability:GetLevel() - 1 )
	local four_times = ability:GetLevelSpecialValueFor( "multicast_4_times", ability:GetLevel() - 1 )
	local talent = caster:FindAbilityByName("ogre_magi_custom_bonus_unique_1")
	local talentRisk = caster:FindAbilityByName("ogre_magi_custom_bonus_unique_2")

	if IsExcludeAbility(used_ability) then return false end

	if talent and talent:GetLevel() > 0 then
		four_times = four_times + talent:GetSpecialValueFor("value")
		three_times = three_times + talent:GetSpecialValueFor("value")
		two_times = two_times + talent:GetSpecialValueFor("value")
	end

	local rand = RandomInt(1,100)
	local multicast = 1
    local cursor = used_ability:GetCursorPosition()
	if rand < two_times then
		multicast = 2
	end
	if rand < three_times then
		multicast = 3
	end
	if rand < four_times then	
		multicast = 4
	end
	if multicast ~= 1 then
		local abilityName = used_ability:GetAbilityName()
		if used_ability:GetCooldown(0) > 0 and abilityName ~= "item_conduit" then
			local delay = ability:GetSpecialValueFor("interval")
			if multicast > 3 then
				ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControl(ability.particle, 1, Vector(4, 0, 4))
				--EmitSoundOn(keys.sound1, caster)
				caster:EmitSoundParams(keys.sound1, 0, 0.3, 0)
			elseif multicast == 3 then
				ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControl(ability.particle, 1, Vector(3, 0, 2))
				--EmitSoundOn(keys.sound2, caster)
				caster:EmitSoundParams(keys.sound2, 0, 0.3, 0)
			elseif multicast == 2 then
				ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControl(ability.particle, 1, Vector(2, 0, 0))
				caster:EmitSoundParams(keys.sound3, 0, 0.3, 0)
				--EmitSoundOn(keys.sound3, caster)
			end


		if ability:IsCooldownReady() and talentRisk and talentRisk:GetLevel() > 0  then
			if multicast == 1 then
				ApplyDamage({
					ability = ability,
					attacker = caster,
					damage = (caster:GetMaxHealth() * ability:GetSpecialValueFor("fail_cost") * 0.01),
					damage_type = DAMAGE_TYPE_PURE,
					damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
					victim = caster,
				})
				caster:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
				local particleFail = ParticleManager:CreateParticle("particles/base_attacks/ranged_tower_bad_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:ReleaseParticleIndex(particleFail)
				-- Frees the specified particle index
			else 
				multicast = multicast * 2
				ability_start_true_cooldown(ability)
				local particleSuccess = ParticleManager:CreateParticle("particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff_ground_ray.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:ReleaseParticleIndex(particleSuccess)
			end	
		end

		
		local count = 1
		
		if abilityName ~= "ogre_magi_bloodlust" and abilityName ~= "item_health_bag_2" and abilityName ~= "item_health_bag" and abilityName ~= "item_spirit_vessel" and abilityName ~= "item_urn_of_shadows" then
			if used_ability and used_ability:GetCaster() == caster and used_ability:GetAbilityType() ~= 1 then  -- not ultimate
				Timers:CreateTimer(
					delay,
					function()
						if used_ability and IsValidEntity(used_ability) and caster:IsAlive() then  -- test again, object may have been deleted.
							if ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and keys.target then
								caster:SetCursorCastTarget(keys.target)
							elseif ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
								caster:SetCursorPosition(cursor)
							else
								caster:SetCursorTargetingNothing(true)
							end
							used_ability:OnSpellStart()
						end
						count = count + 1
						if multicast > count then 
							return delay
						end
					end
					)
				end

		else
			local targets = FindUnitsInRadius(
				caster:GetTeamNumber(),	-- int, your team number
				caster:GetAbsOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				800,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)
			Timers:CreateTimer(
				delay,
				function()
					for _,target in pairs(targets) do
						if target ~= keys.target then
							caster:SetCursorCastTarget(target)
							used_ability:OnSpellStart()
							multicast = multicast - 1
							if multicast < 2 then
								break
							end
						end
					end
				end
			)
		end
	end
	end
end

function IsExcludeAbility( ability )
	local list = {
		"item_dimensional_doorway",		-- 空间之门
		"item_ward_observer",
		"item_ward_sentry",
		"item_smoke_of_deceit",
		"item_tpscroll",
		"item_conduit",
		"phoenix_fire_spirits",
		"mjz_phoenix_sun_ray",
		"mjz_phoenix_sun_ray_toggle_move",
		"mjz_phoenix_sun_ray_cancel",
		"mjz_phoenix_supernova",
		"phoenix_launch_fire_spirit",
		"item_god_slayer",
		"rubick_telekinesis",
		"rubick_telekinesis_land",
		"tusk_launch_snowball",
		"shadow_shaman_shackles",
		"chen_custom_holy_persuasion",
		"mjz_ember_spirit_sleight_of_fist",
		"item_pocket_rax",
		"item_pocket_rax_ranged",
		"item_pocket_tower",
		"riki_blink_strike",
		"mjz_phantom_assassin_phantom_strike",
		"dark_seer_custom_dark_clone",
		"undying_tombstone",
		"mjz_windrunner_powershot",
		"antimage_blink",
		"item_echo_wand",
		"item_remove_ability",
		"frostivus2018_faceless_void_time_walk",
		"obsidian_destroyer_astral_imprisonment",
		"obsidian_destroyer_arcane_orb",
		"obs_replay",
		"item_video_file",
		"item_custom_ex_machina",
		"dawnbreaker_celestial_hammer",
		"dawnbreaker_converge",
		"wisp_tether",
		"wisp_tether_break",
		"arcane_supremacy",
		"item_custom_octarine_core2",
		"hw_sharpshooter",
		"hw_sharpshooter_release",
		"lesser_cancel",
		"divine_cancel",
		"item_crit_edible",
	}
	local abilityName = ability:GetAbilityName()
	for _,name in pairs(list) do
		if abilityName == name then
			return true
		end
	end
	return false
end