modifier_item_mjz_aether_lens = class({})

local modifier = modifier_item_mjz_aether_lens


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
	return "modifiers/mjz_aether_lens"  -- "item_mjz_aether_lens"
end

function modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_CAST_RANGE_BONUS
    }
    return funcs
end

function modifier:GetModifierCastRangeBonus(htable)
    return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
    -- return 250
end