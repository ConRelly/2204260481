LinkLuaModifier("modifier_mjz_stifling_dagger_slow", "abilities/hero_phantom_assassin/mjz_phantom_assassin_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_stifling_dagger_attack_factor", "abilities/hero_phantom_assassin/mjz_phantom_assassin_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_stifling_dagger_attack_bonus", "abilities/hero_phantom_assassin/mjz_phantom_assassin_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------------
mjz_phantom_assassin_stifling_dagger = class({})
function mjz_phantom_assassin_stifling_dagger:GetAOERadius() return self:GetSpecialValueFor("search_radius") end
function mjz_phantom_assassin_stifling_dagger:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("cast_range") end
function mjz_phantom_assassin_stifling_dagger:OnSpellStart()
	if not IsServer() then return nil end
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()

	local search_radius = GetTalentSpecialValueFor(ability, "search_radius")
	local target_count =  GetTalentSpecialValueFor(ability, "target_count")
	local dagger_speed = ability:GetSpecialValueFor("dagger_speed")

	local effect_name = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf"
	local projectile_info =
	{
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = effect_name,
		iMoveSpeed = dagger_speed,
		vSourceLoc= caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = true,
		iVisionRadius = 400,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile(projectile_info)
	caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")

	local count = 1
	local units = GetTargets(caster, ability, target, search_radius)
	for _,unit in pairs(units) do
		if count < target_count and unit ~= target then
			count = count + 1
			projectile_info.Target = unit
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end
end

function mjz_phantom_assassin_stifling_dagger:OnProjectileHit(target, location)
	if not IsServer() then return nil end
	local caster = self:GetCaster()
	local ability = self

	local base_damage = GetTalentSpecialValueFor(ability, "base_damage")
	local slow_duration = GetTalentSpecialValueFor(ability, "slow_duration")

	if target:TriggerSpellAbsorb(ability) then return nil end

	caster:AddNewModifier(caster, ability, "modifier_mjz_stifling_dagger_attack_factor", {duration = 0.03})
	caster:AddNewModifier(caster, ability, "modifier_mjz_stifling_dagger_attack_bonus", {duration = 0.03})
	caster:PerformAttack (target, true, true, true, false, false, false, true)
	caster:RemoveModifierByName("modifier_mjz_stifling_dagger_attack_factor")
	caster:RemoveModifierByName("modifier_mjz_stifling_dagger_attack_bonus")

	target:AddNewModifier(caster, ability, "modifier_mjz_stifling_dagger_slow", {duration = slow_duration})
end

--------------------------------------------------------------------------------------
modifier_mjz_stifling_dagger_slow = class({})
function modifier_mjz_stifling_dagger_slow:IsHidden() return false end
function modifier_mjz_stifling_dagger_slow:IsPurgable() return true end
function modifier_mjz_stifling_dagger_slow:IsDebuff() return true end
function modifier_mjz_stifling_dagger_slow:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf"
end
function modifier_mjz_stifling_dagger_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_mjz_stifling_dagger_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_mjz_stifling_dagger_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_slow")
end

--------------------------------------------------------------------------------------
modifier_mjz_stifling_dagger_attack_factor = class({})
function modifier_mjz_stifling_dagger_attack_factor:IsHidden() return true end
function modifier_mjz_stifling_dagger_attack_factor:IsPurgable() return false end
function modifier_mjz_stifling_dagger_attack_factor:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end
function modifier_mjz_stifling_dagger_attack_factor:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end
function modifier_mjz_stifling_dagger_attack_factor:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("attack_factor")
end

--------------------------------------------------------------------------------------
modifier_mjz_stifling_dagger_attack_bonus = class({})
function modifier_mjz_stifling_dagger_attack_bonus:IsHidden() return true end
function modifier_mjz_stifling_dagger_attack_bonus:IsPurgable() return false end
function modifier_mjz_stifling_dagger_attack_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end
function modifier_mjz_stifling_dagger_attack_bonus:GetModifierBaseAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("base_damage")
end

----------------------------------------------------------------------------------------------
function GetTargets(caster, ability, target, radius)
	return FindUnitsInRadius(
		caster:GetTeam(),
		target:GetAbsOrigin(),
		nil, radius,
		ability:GetAbilityTargetTeam(),
		ability:GetAbilityTargetType(),
		ability:GetAbilityTargetFlags(),
		FIND_ANY_ORDER, false)
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
	local base = ability:GetSpecialValueFor(value)
	local talentName
	local kv = ability:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then
		local talent = ability:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end
