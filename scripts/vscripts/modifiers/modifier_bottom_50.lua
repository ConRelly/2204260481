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
        --MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_EXP_RATE_BOOST,
        MODIFIER_PROPERTY_AVOID_DAMAGE_AFTER_REDUCTIONS,
        MODIFIER_PROPERTY_TOOLTIP,
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

--[[ function modifier_bottom_50:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetParent():GetLevel() * 0.3
end ]]

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

function modifier_bottom_50:GetModifierAvoidDamageAfterReductions(params)
    if not IsServer() then return 0 end

    local parent = self:GetParent()
    if params.damage >= parent:GetHealth() then
        local chance = math.min(30, parent:GetLevel() * 0.20)
        if RollPercentage(chance) then
            local part = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CENTER_FOLLOW, parent)
            ParticleManager:DestroyParticle(part, false)
            ParticleManager:ReleaseParticleIndex(part)
            return 1
        end
    end

    return 0
end

function modifier_bottom_50:OnTooltip()
    return math.min(30, self:GetParent():GetLevel() * 0.20)
end
