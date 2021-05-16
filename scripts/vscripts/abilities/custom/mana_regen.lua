custom_mana_regen = class({})


function custom_mana_regen:GetIntrinsicModifierName()
    return "modifier_custom_mana_regen"
end


function modifier_custom_mana_regen:IsStealable()
    return false
end



LinkLuaModifier("modifier_custom_mana_regen", "abilities/custom/custom_mana_regen.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_mana_regen = class({})


function modifier_custom_mana_regen:IsHidden()
    return true
end
function modifier_custom_mana_regen:IsDebuff()
    return false
end    

function modifier_custom_mana_regen:DeclareFunctions()
    local funcs = {
        --MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE,
    }
    return funcs
end


function modifier_custom_mana_regen:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_custom_mana_regen:GetModifierExtraManaPercentage()
    return 50 --self:GetAbility():GetSpecialValueFor("mana_bonus")
end