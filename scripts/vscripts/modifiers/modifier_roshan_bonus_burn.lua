-- Debuff: Burns the victim and reduces his physical armor.
if modifier_roshan_bonus_burn == nil then
	modifier_roshan_bonus_burn = class({})
end

-- Configuration
local BONUS_ARMOR = -8
local BURN_DAMAGE_PER_TICK = 30
local BURN_DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL

--
modifier_roshan_bonus_burn._nFX = nil

-- Returns the attributes and functions that the modifier will have
function modifier_roshan_bonus_burn:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

-- True/false if this modifier is active on illusions.
function modifier_roshan_bonus_burn:AllowIllusionDuplicate()
    return false
end

-- Return the types of attributes applied to this modifier (enum value from DOTAModifierAttribute_t)
function modifier_roshan_bonus_burn:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

-- Return the attach type of the particle system from GetEffectName.
function modifier_roshan_bonus_burn:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

-- Return the name of the particle system that is created while this modifier is active.
function modifier_roshan_bonus_burn:GetEffectName()
    return 'particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf'
end

-- Return the priority of the modifier, see MODIFIER_PRIORITY_*.
function modifier_roshan_bonus_burn:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

-- Return the name of the buff icon to be shown for this modifier.
function modifier_roshan_bonus_burn:GetTexture()
    return 'huskar_burning_spear'
end

-- True/false if this modifier should be displayed as a debuff.
function modifier_roshan_bonus_burn:IsDebuff()
    return true
end

-- True/false if this modifier should be displayed on the buff bar.
function modifier_roshan_bonus_burn:IsHidden()
    return false
end

-- True/false if this modifier can be purged.
function modifier_roshan_bonus_burn:IsPurgable()
    return true
end

-- True/false if this modifier is considered a stun for purge reasons.
function modifier_roshan_bonus_burn:IsStunDebuff()
    return false
end

-- Think!
function modifier_roshan_bonus_burn:OnIntervalThink()
    -- Apply burn damage
    self:BurnHP()

    -- Next...
    self:StartIntervalThink(1.0)
end

-- Apply damage by burn
function modifier_roshan_bonus_burn:BurnHP()
    -- Damage table
    local tDamage = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = BURN_DAMAGE_PER_TICK,
        damage_type = BURN_DAMAGE_TYPE
    }

    -- Apply!
    ApplyDamage(tDamage)
end

-- Called when the modifier is applied on the hero
function modifier_roshan_bonus_burn:OnCreated(tData)
    if IsServer() then
        --local hParent = self:GetParent()

        -- Create the effect
        --self._nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", PATTACH_ROOTBONE_FOLLOW, hParent)

        -- Damage over Time
        self:OnIntervalThink()
    end
end

-- Called when the modifier is removed
function modifier_roshan_bonus_burn:OnDestroy()
    if IsServer() then
        -- Destroy the effect
        if ( self._nFX ~= nil ) then
            ParticleManager:DestroyParticle(self._nFX, false)
            ParticleManager:ReleaseParticleIndex(self._nFX)
            self._nFX = nil
        end
    end
end

-- Returns the amount of additional armor
function modifier_roshan_bonus_burn:GetModifierPhysicalArmorBonus()
    return BONUS_ARMOR
end