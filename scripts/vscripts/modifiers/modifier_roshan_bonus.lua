-- Provide buffs to the killer of 4+ roshan
if modifier_roshan_bonus == nil then
	modifier_roshan_bonus = class({})
end

-- Configuration
local BONUS_DAMAGE_PERCENTAGE = 20.0
local BURNING_DURATION = 8.0

-- Returns the attributes and functions that the modifier will have
function modifier_roshan_bonus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

-- True/false if this modifier is active on illusions.
function modifier_roshan_bonus:AllowIllusionDuplicate()
    return true
end

-- Return the types of attributes applied to this modifier (enum value from DOTAModifierAttribute_t)
function modifier_roshan_bonus:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

-- Return the attach type of the particle system from GetEffectName.
function modifier_roshan_bonus:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

-- Return the name of the particle system that is created while this modifier is active.
function modifier_roshan_bonus:GetEffectName()
    return 'particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf'
end

-- Return the priority of the modifier, see MODIFIER_PRIORITY_*.
function modifier_roshan_bonus:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

-- Return the name of the buff icon to be shown for this modifier.
function modifier_roshan_bonus:GetTexture()
    return 'roshan_spell_block'
end

-- True/false if this modifier should be displayed as a debuff.
function modifier_roshan_bonus:IsDebuff()
    return false
end

-- True/false if this modifier should be displayed on the buff bar.
function modifier_roshan_bonus:IsHidden()
    return false
end

-- True/false if this modifier can be purged.
function modifier_roshan_bonus:IsPurgable()
    return false
end

-- True/false if this modifier is considered a stun for purge reasons.
function modifier_roshan_bonus:IsStunDebuff()
    return false
end

-- Called when the modifier is applied on the hero
function modifier_roshan_bonus:OnCreated(tData)
    if IsServer() then
        local hParent = self:GetParent()

        -- Create the effect
        hParent:SetRenderColor(255, 225, 225)
    end
end

-- Called when the modifier is removed
function modifier_roshan_bonus:OnDestroy()
    if IsServer() then
        local hParent = self:GetParent()

        -- Destroy the effect
        hParent:SetRenderColor(255, 255, 255)
    end
end

-- 
function modifier_roshan_bonus:GetModifierBaseDamageOutgoing_Percentage()
    return BONUS_DAMAGE_PERCENTAGE
end

--
function modifier_roshan_bonus:OnAttackLanded(tData)
    local hParent = self:GetParent()
    local hVictim = tData.target
    local hAttacker = tData.attacker

    if ( not hAttacker or not hVictim ) then
        return
    end

    -- We are only interested in attacks made by the owner
    if ( hAttacker ~= hParent ) then
        return
    end

    -- Does not apply to structures
    if ( hVictim:IsBuilding() ) then
        return
    end

    -- 
    local hModifier = hVictim:FindModifierByName('modifier_roshan_bonus_burn')

    -- We apply the debuff
    if hModifier then
        hModifier:ForceRefresh()
    else
        hVictim:AddNewModifier(hAttacker, nil, 'modifier_roshan_bonus_burn', {duration = BURNING_DURATION})
    end
end