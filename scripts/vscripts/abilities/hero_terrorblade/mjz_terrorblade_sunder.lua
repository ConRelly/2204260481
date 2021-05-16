
local THIS_LUA = "abilities/hero_terrorblade/mjz_terrorblade_sunder.lua"
local TALENT_COOLDOWN_NAME = 'special_bonus_unique_terrorblade'
local TALENT_COOLDOWN_VALUE = -35
local MODIFIER_TALENT_COOLDOWN_NAME = 'modifier_' .. TALENT_COOLDOWN_NAME

LinkLuaModifier(MODIFIER_TALENT_COOLDOWN_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------------------------

mjz_terrorblade_sunder = class({})
local ability_class = mjz_terrorblade_sunder

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('cast_range')
end

function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('cast_range')
end

function ability_class:GetCooldown(iLevel)
	local caster = self:GetCaster()
	local ability = self

	if IsServer() then
		local talent_ability = caster:FindAbilityByName(TALENT_COOLDOWN_NAME)
		local has_talent = talent_ability and talent_ability:GetLevel() > 0
		if has_talent then
			if not caster:HasModifier(MODIFIER_TALENT_COOLDOWN_NAME)  then
				caster:AddNewModifier(caster, abiltiy, MODIFIER_TALENT_COOLDOWN_NAME, nil)
			end
		else
			if caster:HasModifier(MODIFIER_TALENT_COOLDOWN_NAME) then
				caster:RemoveModifierByName(MODIFIER_TALENT_COOLDOWN_NAME)
			end
		end
	end

	if caster:HasModifier(MODIFIER_TALENT_COOLDOWN_NAME) then
		local cooldown = ability:GetSpecialValueFor('cooldown')
		cooldown = cooldown + TALENT_COOLDOWN_VALUE
		return cooldown
	else
		return self.BaseClass.GetCooldown(self, iLevel)
	end
end


if IsServer() then
	function ability_class:OnSpellStart(  )
		local caster = self:GetCaster()
		local ability = self
		local target = self:GetCursorTarget()

		self:_SwapHealth()

		self:_PlayEffect()

		EmitSoundOn("Hero_Terrorblade.Sunder.Cast", caster)
		EmitSoundOn("Hero_Terrorblade.Sunder.Target", target)
	end

	function ability_class:_SwapHealth(  )
		local caster = self:GetCaster()
		local ability = self
		local target = self:GetCursorTarget()
		local hit_point_minimum_pct = ability:GetSpecialValueFor('hit_point_minimum_pct')
		hit_point_minimum_pct = hit_point_minimum_pct * 0.01

		local caster_maxHealth = caster:GetMaxHealth()
		local target_maxHealth = target:GetMaxHealth()
		local casterHP_percent = caster:GetHealth() / caster_maxHealth
		local targetHP_percent = target:GetHealth() / target_maxHealth

		-- Swap the HP of the caster
		if targetHP_percent <= hit_point_minimum_pct then
			caster:SetHealth(caster_maxHealth * hit_point_minimum_pct)
		else
			caster:SetHealth(caster_maxHealth * targetHP_percent)
		end

		if TargetIsFriendly(caster, target) then
			-- Swap the HP of the target
			if casterHP_percent <= hit_point_minimum_pct then
				target:SetHealth(target_maxHealth * hit_point_minimum_pct)
			else
				target:SetHealth(target_maxHealth * casterHP_percent)
			end
		end
	end

	function ability_class:_PlayEffect( )
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		-- Show the particle caster-> target
		local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"	
		local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, target )

		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)

		-- Show the particle target-> caster
		local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"	
		local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )

		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)
	end

end

-----------------------------------------------------------------------------

modifier_special_bonus_unique_terrorblade = class({})
function modifier_special_bonus_unique_terrorblade:IsHidden() return true end
function modifier_special_bonus_unique_terrorblade:IsPurgable() return false end

------------------------------------------------------------------------------------------

function TargetIsFriendly(caster, target )
	local nTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY 	-- ability:GetAbilityTargetTeam()
	local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
	local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end

function TargetIsEnemy(caster, target )
	local nTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY 	-- ability:GetAbilityTargetTeam()
	local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
	local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end
