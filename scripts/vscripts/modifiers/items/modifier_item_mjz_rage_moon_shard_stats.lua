modifier_item_mjz_rage_moon_shard_stats = class({})

local modifier = modifier_item_mjz_rage_moon_shard_stats


function modifier:IsHidden()
    return false
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
    -- return self:GetAbility():GetSpecialValueFor("consumed_bonus_night_vision")
    return 200
end

function modifier:GetModifierAttackSpeedBonus_Constant(htable)
    -- return self:GetAbility():GetSpecialValueFor("consumed_bonus_attack_speed")
    return 100 
end