

custom_mana_regen2 = class({})


function custom_mana_regen2:GetIntrinsicModifierName()
    return "modifier_custom_mana_regen2"
end


function custom_mana_regen2:IsStealable()
    return false
end



LinkLuaModifier("modifier_custom_mana_regen2", "abilities/custom/custom_mana_regen2.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_mana_regen2 = class({})


function modifier_custom_mana_regen2:IsHidden()
    return true
end
function modifier_custom_mana_regen2:IsDebuff()
    return false
end    

function modifier_custom_mana_regen2:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end


function modifier_custom_mana_regen2:GetModifierConstantManaRegen()
    local parent = self:GetParent()
    return self:GetAbility():GetSpecialValueFor("mana_regen") 
end

function modifier_custom_mana_regen2:GetModifierTotalPercentageManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_regen_ptc")
end

function modifier_custom_mana_regen2:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_int")
end