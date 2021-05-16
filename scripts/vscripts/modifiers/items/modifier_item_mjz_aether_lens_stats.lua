modifier_item_mjz_aether_lens_stats = class({})

local modifier = modifier_item_mjz_aether_lens_stats


function modifier:IsHidden()
    return false
end

function modifier:IsPurgable()
    return false
end
function modifier:AllowIllusionDuplicate()
    return true
end

function modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier:GetTexture()
	return "modifiers/mjz_aether_lens"  -- "item_mjz_aether_lens"
end

function modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_CAST_RANGE_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    }
    return funcs
end

function modifier:GetModifierCastRangeBonus(htable)
    -- return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
    return 250
end

function modifier:GetModifierSpellAmplify_Percentage()
    return 25
end    

function modifier:GetModifierPercentageCasttime()
    return 100
end    