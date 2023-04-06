modifier_bottom_50 = class({})

function modifier_bottom_50:IsHidden()
    return false
end

function modifier_bottom_50:IsDebuff()
    return false
end

function modifier_bottom_50:IsPurgable()
    return false
end
function modifier_bottom_50:IsPermanent()
    return true
end
function modifier_bottom_50:RemoveOnDeath()
    return false
end

function modifier_bottom_50:GetTexture()
    return "bottom_underdogs"
end

function modifier_bottom_50:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_EXP_RATE_BOOST
    }

    return funcs
end

function modifier_bottom_50:GetModifierBonusStats_Strength()
    return self:GetParent():GetLevel() * 15
end

function modifier_bottom_50:GetModifierBonusStats_Agility()
    return self:GetParent():GetLevel() * 15
end

function modifier_bottom_50:GetModifierBonusStats_Intellect()
    return self:GetParent():GetLevel() * 15
end

function modifier_bottom_50:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetParent():GetLevel() * 0.3
end

function modifier_bottom_50:GetModifierSpellAmplify_Percentage()
    return self:GetParent():GetLevel() * 3
end

function modifier_bottom_50:GetModifierDamageOutgoing_Percentage()
    return self:GetParent():GetLevel() * 0.3
end

function modifier_bottom_50:GetModifierPhysicalArmorBonus()
    return self:GetParent():GetLevel() * 3
end

function modifier_bottom_50:GetModifierMagicalResistanceBonus()
    return 35
end
function modifier_bottom_50:GetModifierPercentageExpRateBoost()
    return 25
end