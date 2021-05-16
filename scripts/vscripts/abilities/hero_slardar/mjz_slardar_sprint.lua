LinkLuaModifier( "modifier_mjz_slardar_sprint", "abilities/hero_slardar/mjz_slardar_sprint.lua",LUA_MODIFIER_MOTION_NONE )

mjz_slardar_sprint = class({})
local ability_class = mjz_slardar_sprint

function ability_class:OnToggle()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		if ability:GetToggleState() then
			EmitSoundOn("Hero_Slardar.Sprint", caster)
			caster:AddNewModifier(caster, ability, 'modifier_mjz_slardar_sprint', {})
		else
			caster:RemoveModifierByName('modifier_mjz_slardar_sprint')
		end
	end
end

----------------------------------------------------------------------------

modifier_mjz_slardar_sprint = class({})
local modifier_class = modifier_mjz_slardar_sprint

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
end
function modifier_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_class:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_class:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_class:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor('bonus_move_speed')
end

if IsServer() then
	function modifier_class:OnCreated(table)
		local ability = self:GetAbility()
		local health_cost_per_second = ability:GetSpecialValueFor('health_cost_per_second')
		local tick_interval = ability:GetSpecialValueFor('tick_interval')

		self:StartIntervalThink(tick_interval)
	end

	function modifier_class:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local health_cost_per_second = ability:GetSpecialValueFor('health_cost_per_second')
		local tick_interval = ability:GetSpecialValueFor('tick_interval')

		local health_cost = health_cost_per_second * tick_interval

		local iDesiredHealthValue = parent:GetHealth() - health_cost
		parent:ModifyHealth(iDesiredHealthValue, ability, false, 0)
	end
end