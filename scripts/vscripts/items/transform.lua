function ChangeHeroPiety(keys)
	local caster = keys.caster
	local ability = keys.ability
	local generic_hidden = false
	if caster:HasAbility("sourcery") then return end
	if caster:GetUnitName() == "npc_dota_hero_lina" and caster:GetLevel() < 2 then
		if caster:GetAbilityPoints() == 0 then
			caster:SetAbilityPoints(1)
		end
-- Abilities
	--1
		if caster:HasAbility("mjz_phoenix_icarus_dive") then
			caster:AddAbility("sacred_blink")
			caster:SwapAbilities("mjz_phoenix_icarus_dive", "sacred_blink", false, true)
			caster:RemoveAbility("mjz_phoenix_icarus_dive")
		end
	--2
		if caster:HasAbility("lina_light_strike_array") then
			caster:AddAbility("willpower")
			caster:SwapAbilities("lina_light_strike_array", "willpower", false, true)
			caster:RemoveAbility("lina_light_strike_array")
		end
	--3
		if caster:HasAbility("mjz_lina_fiery_soul") then
			caster:AddAbility("gegenstrom")
			caster:SwapAbilities("mjz_lina_fiery_soul", "gegenstrom", false, true)
			caster:RemoveAbility("mjz_lina_fiery_soul")
		end
	--4
		if caster:HasAbility("generic_hidden") then
			caster:AddAbility("sourcery")
			caster:SwapAbilities("generic_hidden", "sourcery", false, true)
			caster:RemoveAbility("generic_hidden")
		end
	--5
		caster:AddAbility("generic_hidden")
--[[
		if caster:HasAbility("generic_hidden") then
			caster:AddAbility("")
			caster:SwapAbilities("generic_hidden", "", false, true)
			caster:RemoveAbility("generic_hidden")
		end
]]
	--6
		if caster:HasAbility("mjz_lina_laguna_blade") then
			caster:AddAbility("lesser_cancel")
			caster:SwapAbilities("mjz_lina_laguna_blade", "lesser_cancel", false, true)
			caster:RemoveAbility("mjz_lina_laguna_blade")
		end

-- Talents
	-- 10 Level
		--right
		if caster:HasAbility("special_bonus_intelligence_30") then
			caster:AddAbility("special_bonus_unique_sourcery_health_regen_pct")
			caster:SwapAbilities("special_bonus_intelligence_30", "special_bonus_unique_sourcery_health_regen_pct", false, true)
			caster:RemoveAbility("special_bonus_intelligence_30")
		end
		--left
		if caster:HasAbility("special_bonus_unique_mjz_phoenix_icarus_dive_cdr") then
			caster:AddAbility("special_bonus_intelligence_30")
			caster:SwapAbilities("special_bonus_unique_mjz_phoenix_icarus_dive_cdr", "special_bonus_intelligence_30", false, true)
			caster:RemoveAbility("special_bonus_unique_mjz_phoenix_icarus_dive_cdr")
		end
	-- 15 Level
		--right
		if caster:HasAbility("special_bonus_mp_400") then
			caster:AddAbility("special_bonus_armor_20")
			caster:SwapAbilities("special_bonus_mp_400", "special_bonus_armor_20", false, true)
			caster:RemoveAbility("special_bonus_mp_400")
		end
		--left
		if caster:HasAbility("special_bonus_cooldown_reduction_25") then
			caster:AddAbility("special_bonus_unique_willpower_separate")
			caster:SwapAbilities("special_bonus_cooldown_reduction_25", "special_bonus_unique_willpower_separate", false, true)
			caster:RemoveAbility("special_bonus_cooldown_reduction_25")
		end
	-- 20 Level
		--right
		if caster:HasAbility("special_bonus_spell_amplify_65") then
			caster:AddAbility("special_bonus_unique_unsilenced")
			caster:SwapAbilities("special_bonus_spell_amplify_65", "special_bonus_unique_unsilenced", false, true)
			caster:RemoveAbility("special_bonus_spell_amplify_65")
		end
		--left
		if caster:HasAbility("special_bonus_unique_mjz_lina_fiery_soul") then
			caster:AddAbility("special_bonus_unique_sacred_blink_building")
			caster:SwapAbilities("special_bonus_unique_mjz_lina_fiery_soul", "special_bonus_unique_sacred_blink_building", false, true)
			caster:RemoveAbility("special_bonus_unique_mjz_lina_fiery_soul")
		end

--[[
	-- 25 Level
		--right
		if caster:HasAbility("special_bonus_magic_resistance_40") then
			caster:AddAbility("")
			caster:SwapAbilities("special_bonus_magic_resistance_40", "", false, true)
			caster:RemoveAbility("special_bonus_magic_resistance_40")
		end
]]
		--left
		if caster:HasAbility("special_bonus_spell_block_18") then
			caster:AddAbility("special_bonus_unique_sourcery_health_recovery")
			caster:SwapAbilities("special_bonus_spell_block_18", "special_bonus_unique_sourcery_health_recovery", false, true)
			caster:RemoveAbility("special_bonus_spell_block_18")
		end

-- Change Ranged Projectile Attack Effect
		caster:SetRangedProjectileName("particles/custom/abilities/sourcery/sourcery_attack_effect.vpcf")
	end

	caster:RemoveItem(ability)
end



function ChangeHeroKardel(keys)
	local caster = keys.caster
	local ability = keys.ability
	local generic_hidden = false
	if caster:HasAbility("modifier_kardels_skills") then return end
	if caster:GetUnitName() == "npc_dota_hero_sniper" and caster:GetLevel() < 2 then
		if caster:GetAbilityPoints() == 0 then
			caster:SetAbilityPoints(1)
		end
-- Abilities
	--1
		if caster:HasAbility("sniper_shrapnel_lua") then
			caster:AddAbility("sniper_shoot")
			caster:SwapAbilities("sniper_shrapnel_lua", "sniper_shoot", false, true)
			caster:RemoveAbility("sniper_shrapnel_lua")
		end
	--2
		if caster:HasAbility("sniper_headshot_lua") then
			caster:AddAbility("pocket_portal")
			caster:SwapAbilities("sniper_headshot_lua", "pocket_portal", false, true)
			caster:RemoveAbility("sniper_headshot_lua")
		end
	--3
		if caster:HasAbility("mjz_sniper_take_aim") then
			caster:AddAbility("kardels_skills")
			caster:SwapAbilities("mjz_sniper_take_aim", "kardels_skills", false, true)
			caster:RemoveAbility("mjz_sniper_take_aim")
		end
	--4
		if caster:HasAbility("mjz_sniper_quick_draw") then
			caster:AddAbility("reload_bullet")
			caster:SwapAbilities("mjz_sniper_quick_draw", "reload_bullet", false, true)
			caster:RemoveAbility("mjz_sniper_quick_draw")
		end
	--5
		if caster:HasAbility("generic_hidden") then
			caster:AddAbility("change_bullets_type")
			caster:SwapAbilities("generic_hidden", "change_bullets_type", false, true)
			caster:RemoveAbility("generic_hidden")
		end
	--6
		if caster:HasAbility("mjz_sniper_assassinate") then
			caster:AddAbility("hunting_mark")
			caster:SwapAbilities("mjz_sniper_assassinate", "hunting_mark", false, true)
			caster:RemoveAbility("mjz_sniper_assassinate")
		end



-- Talents
--[[
	-- 10 Level
		--right
		if caster:HasAbility("special_bonus_agility_100") then
			caster:AddAbility("")
			caster:SwapAbilities("special_bonus_agility_100", "", false, true)
			caster:RemoveAbility("special_bonus_agility_100")
		end
]]
		--left
		if caster:HasAbility("special_bonus_unique_sniper_3") then
			caster:AddAbility("special_bonus_sniper_shoot_bullet_dmg")
			caster:SwapAbilities("special_bonus_unique_sniper_3", "special_bonus_sniper_shoot_bullet_dmg", false, true)
			caster:RemoveAbility("special_bonus_unique_sniper_3")
		end

	-- 15 Level
		--right
		if caster:HasAbility("special_bonus_attack_damage_400") then
			caster:AddAbility("special_bonus_kardel_reloading")
			caster:SwapAbilities("special_bonus_attack_damage_400", "special_bonus_kardel_reloading", false, true)
			caster:RemoveAbility("special_bonus_attack_damage_400")
		end
		--left
		if caster:HasAbility("special_bonus_unique_sniper_6") then
			caster:AddAbility("special_bonus_pocket_portal_cooldown")
			caster:SwapAbilities("special_bonus_unique_sniper_6", "special_bonus_pocket_portal_cooldown", false, true)
			caster:RemoveAbility("special_bonus_unique_sniper_6")
		end

	-- 20 Level
		--right
		if caster:HasAbility("special_bonus_hp_4000") then
			caster:AddAbility("special_bonus_attack_range_400")
			caster:SwapAbilities("special_bonus_hp_4000", "special_bonus_attack_range_400", false, true)
			caster:RemoveAbility("special_bonus_hp_4000")
		end
		--left
		if caster:HasAbility("special_bonus_unique_mjz_sniper_assassinate_damage") then
			caster:AddAbility("special_bonus_hunting_mark_direct_shot_bonus")
			caster:SwapAbilities("special_bonus_unique_mjz_sniper_assassinate_damage", "special_bonus_hunting_mark_direct_shot_bonus", false, true)
			caster:RemoveAbility("special_bonus_unique_mjz_sniper_assassinate_damage")
		end

	-- 25 Level
		--right
		if caster:HasAbility("special_bonus_spell_immunity") then
			caster:AddAbility("special_bonus_pocket_portal_evasion")
			caster:SwapAbilities("special_bonus_spell_immunity", "special_bonus_pocket_portal_evasion", false, true)
			caster:RemoveAbility("special_bonus_spell_immunity")
		end
		--left
		if caster:HasAbility("special_bonus_unique_sniper_5") then
			caster:AddAbility("special_bonus_kardels_skills_dmg")
			caster:SwapAbilities("special_bonus_unique_sniper_5", "special_bonus_kardels_skills_dmg", false, true)
			caster:RemoveAbility("special_bonus_unique_sniper_5")
		end

-- Change Ranged Projectile Attack Effect
--		caster:SetRangedProjectileName("particles/custom/abilities/sourcery/sourcery_attack_effect.vpcf")

		EmitSoundOn("sniper_snip_attack_04", caster)
	end
	caster:RemoveItem(ability)
end
