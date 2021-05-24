modifier_item_mjz_rage_moon_shard_bat = class({})

local modifier = modifier_item_mjz_rage_moon_shard_bat

function modifier:IsHidden()
	return true
end

function modifier:IsPurgable()
	return false
end

function modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
    }
end

function modifier:GetModifierBaseAttackTimeConstant()
	return self:GetStackCount() * 0.1
end