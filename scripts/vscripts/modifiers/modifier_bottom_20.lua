modifier_bottom_20 = class({})

function modifier_bottom_20:IsHidden()
    return false
end

function modifier_bottom_20:IsDebuff()
    return false
end

function modifier_bottom_20:IsPurgable()
    return false
end
function modifier_bottom_20:IsPermanent()
    return true
end
function modifier_bottom_20:RemoveOnDeath()
    return false
end
function modifier_bottom_20:GetTexture()
    return "bottom_underdogs2"
end

function modifier_bottom_20:DeclareFunctions()
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

function modifier_bottom_20:CheckState()
	local state = {
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
	
	return state
end

function modifier_bottom_20:GetModifierBonusStats_Strength()
    return self:GetParent():GetLevel() * 22
end

function modifier_bottom_20:GetModifierBonusStats_Agility()
    return self:GetParent():GetLevel() * 22
end

function modifier_bottom_20:GetModifierBonusStats_Intellect()
    return self:GetParent():GetLevel() * 22
end

--[[ function modifier_bottom_20:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetParent():GetLevel() * 0.5
end ]]

function modifier_bottom_20:GetModifierSpellAmplify_Percentage()
    return self:GetParent():GetLevel() * 5
end

function modifier_bottom_20:GetModifierDamageOutgoing_Percentage()
    return self:GetParent():GetLevel() * 0.5
end

function modifier_bottom_20:GetModifierPhysicalArmorBonus()
    return self:GetParent():GetLevel() * 5
end

function modifier_bottom_20:GetModifierMagicalResistanceBonus()
    return 45
end
function modifier_bottom_20:GetModifierPercentageExpRateBoost()
    return 30
end

function modifier_bottom_20:GetModifierAvoidDamageAfterReductions(params)
    if not IsServer() then return 0 end

    local parent = self:GetParent()
    if params.damage >= parent:GetHealth() then
        local chance = math.min(35, parent:GetLevel() * 0.25)
        if RollPercentage(chance) then
            local part = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CENTER_FOLLOW, parent)
            ParticleManager:DestroyParticle(part, false)
            ParticleManager:ReleaseParticleIndex(part)
            return 1
        end
    end

    return 0
end

function modifier_bottom_20:OnTooltip()
    return math.min(35, self:GetParent():GetLevel() * 0.25)
end
