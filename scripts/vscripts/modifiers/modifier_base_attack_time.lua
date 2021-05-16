modifier_base_attack_time = class({})

local modifier = modifier_base_attack_time

function modifier:IsHidden()
	return true
end

function modifier:IsDebuff()
	return false
end

function modifier:IsPurgable()
	return false
end

function modifier:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
    }
end

function modifier:GetModifierBaseAttackTimeConstant()
	return self:GetStackCount() * 0.1
end