-- Debuff: Burns the victim and reduces his physical armor.
if modifier_burn == nil then
	modifier_burn = class({})
end

-- Configuration
local BURN_DAMAGE_PER_TICK = 12
local BURN_DAMAGE_TYPE = DAMAGE_TYPE_PURE

--
modifier_burn._nFX = nil

-- Returns the attributes and functions that the modifier will have

-- True/false if this modifier is active on illusions.
function modifier_burn:AllowIllusionDuplicate()
    return false
end

-- Return the types of attributes applied to this modifier (enum value from DOTAModifierAttribute_t)
function modifier_burn:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

-- Return the attach type of the particle system from GetEffectName.


-- Return the name of the particle system that is created while this modifier is active.


-- Return the priority of the modifier, see MODIFIER_PRIORITY_*.
function modifier_burn:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

-- Return the name of the buff icon to be shown for this modifier.


-- True/false if this modifier should be displayed as a debuff.
function modifier_burn:IsDebuff()
    return true
end

-- True/false if this modifier should be displayed on the buff bar.
function modifier_burn:IsHidden()
    return true
end

-- True/false if this modifier can be purged.
function modifier_burn:IsPurgable()
    return false
end

-- True/false if this modifier is considered a stun for purge reasons.
function modifier_burn:IsStunDebuff()
    return false
end

-- Think!
function modifier_burn:OnIntervalThink()
    -- Apply burn damage
    self:BurnHP()

    -- Next...
    self:StartIntervalThink(2.0)
end

-- Apply damage by burn
function modifier_burn:BurnHP()
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
function modifier_burn:OnCreated(tData)
    if IsServer() then
        --local hParent = self:GetParent()

        -- Create the effect
        --self._nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", PATTACH_ROOTBONE_FOLLOW, hParent)

        -- Damage over Time
        self:OnIntervalThink()
    end
end

-- Called when the modifier is removed

-- Returns the amount of additional armor
