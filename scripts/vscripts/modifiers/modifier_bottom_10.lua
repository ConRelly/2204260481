modifier_bottom_10 = class({})

function modifier_bottom_10:IsHidden()
    return false
end

function modifier_bottom_10:IsDebuff()
    return false
end

function modifier_bottom_10:IsPurgable()
    return false
end
function modifier_bottom_10:IsPermanent()
    return true
end
function modifier_bottom_10:RemoveOnDeath()
    return false
end
function modifier_bottom_10:GetTexture()
    return "bottom_underdogs3"
end

function modifier_bottom_10:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        --MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_EXP_RATE_BOOST
    }

    return funcs
end

function modifier_bottom_10:CheckState()
	local state = {
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
	
	return state
end

function modifier_bottom_10:GetModifierBonusStats_Strength()
    return self:GetParent():GetLevel() * 30
end

function modifier_bottom_10:GetModifierBonusStats_Agility()
    return self:GetParent():GetLevel() * 30
end

function modifier_bottom_10:GetModifierBonusStats_Intellect()
    return self:GetParent():GetLevel() * 30
end

--[[ function modifier_bottom_10:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetParent():GetLevel() * 0.6
end ]]

function modifier_bottom_10:GetModifierSpellAmplify_Percentage()
    return self:GetParent():GetLevel() * 6
end

function modifier_bottom_10:GetModifierDamageOutgoing_Percentage()
    return self:GetParent():GetLevel() * 0.6
end

function modifier_bottom_10:GetModifierPhysicalArmorBonus()
    return self:GetParent():GetLevel() * 5
end

function modifier_bottom_10:GetModifierMagicalResistanceBonus()
    return 60
end
function modifier_bottom_10:GetModifierPercentageExpRateBoost()
    return 40
end