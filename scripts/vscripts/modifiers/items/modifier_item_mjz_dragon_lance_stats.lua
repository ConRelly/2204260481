modifier_item_mjz_dragon_lance_stats = class({})

local modifier = modifier_item_mjz_dragon_lance_stats


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
	return "modifiers/mjz_dragon_lance"  -- "item_mjz_dragon_lance"
end

function modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
    return funcs
end

function modifier:GetModifierAttackRangeBonus(htable)
    -- return self:GetAbility():GetSpecialValueFor("base_attack_range")
    return 440
end