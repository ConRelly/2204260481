modifier_item_mjz_rage_moon_shard = class({})

local modifier = modifier_item_mjz_rage_moon_shard

function modifier:IsHidden()
    return true
end

function modifier:IsPurgable()
    return false
end

function modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier:GetTexture()
	return "modifiers/mjz_rage_moon_shard"  -- "item_mjz_rage_moon_shard"
end

function modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier:GetBonusNightVision(htable)
    return self:GetAbility():GetSpecialValueFor("bonus_night_vision")
end

function modifier:GetModifierAttackSpeedBonus_Constant(htable)
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

