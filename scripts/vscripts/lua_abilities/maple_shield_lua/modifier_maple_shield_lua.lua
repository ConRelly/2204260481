--------------------------------------------------------------------------------
modifier_maple_shield_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_maple_shield_lua:IsHidden()
    return true
end

function modifier_maple_shield_lua:IsDebuff()
    return false
end

function modifier_maple_shield_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_maple_shield_lua:OnCreated(kv)
    -- references
    self.armor_str_multiplier = self:GetAbility():GetSpecialValueFor("armor_str_multiplier")
    self.hp_str_multiplier = self:GetAbility():GetSpecialValueFor("hp_str_multiplier")
    self.speed_cap = self:GetAbility():GetSpecialValueFor("speed_cap")
    self.cooldown_increment = self:GetAbility():GetSpecialValueFor("cooldown_increment")
    self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
    self.size = self:GetAbility():GetSpecialValueFor("size")
end

function modifier_maple_shield_lua:OnRefresh(kv)
    -- references
    self:OnCreated(kv)
end

function modifier_maple_shield_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_maple_shield_lua:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = not self:GetParent():PassivesDisabled(),
    }

    return state
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_maple_shield_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }

    return funcs
end

function modifier_maple_shield_lua:GetModifierPhysicalArmorBonus()
    -- cancel if break
    if self:GetParent():PassivesDisabled() then
        return 0
    end

    return math.floor(self:GetParent():GetStrength() * self.armor_str_multiplier)
end

function modifier_maple_shield_lua:GetModifierHealthBonus()
    -- cancel if break
    if self:GetParent():PassivesDisabled() then
        return 0
    end

    return math.floor(self:GetParent():GetStrength() * self.hp_str_multiplier)
end

function modifier_maple_shield_lua:GetModifierMoveSpeed_Limit()
    -- cancel if break
    if self:GetParent():PassivesDisabled() then
        return 0
    end

    return self.speed_cap
end

function modifier_maple_shield_lua:GetModifierModelScale()
    -- cancel if break
    if self:GetParent():PassivesDisabled() then
        return 1
    end

    return self.size
end

-- Increases cooldown
function modifier_maple_shield_lua:GetModifierPercentageCooldown()
    -- cancel if break
    if self:GetParent():PassivesDisabled() then
        return 0
    end

    return -self.cooldown_increment
end
--------------------------------------------------------------------------------
-- Aura
function modifier_maple_shield_lua:IsAura()
    return not self:GetParent():PassivesDisabled()
end

function modifier_maple_shield_lua:GetModifierAura()
    return "modifier_maple_shield_lua_aura"
end

function modifier_maple_shield_lua:GetAuraRadius()
    return self.aura_radius
end

function modifier_maple_shield_lua:GetAuraSearchTeam()
    return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_maple_shield_lua:GetAuraSearchType()
    return self:GetAbility():GetAbilityTargetType()
end

function modifier_maple_shield_lua:GetAuraSearchFlags()
    return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_maple_shield_lua:GetAuraEntityReject(hEntity)
    -- Those that also has this modifier will not receive shield aura
    if hEntity and hEntity:HasModifier("modifier_maple_shield_lua") then
        return true
    end

    return false
end