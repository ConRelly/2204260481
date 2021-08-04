
local MODIFIER_LUA = "modifiers/hero_huskar/modifier_mjz_huskar_berserkers_blood.lua"
local MODIFIER_ATTACK_SPEED_NAME = 'modifier_mjz_huskar_berserkers_blood_attack_speed'
local MODIFIER_HEALTH_REGEN_NAME = 'modifier_mjz_huskar_berserkers_blood_health_regen'
local MODIFIER_MAGICAL_RESISTANCE_NAME = 'modifier_mjz_huskar_berserkers_blood_magical_resistance'

-- LinkLuaModifier(MODIFIER_ATTACK_SPEED_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier(MODIFIER_HEALTH_REGEN_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier(MODIFIER_MAGICAL_RESISTANCE_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

modifier_mjz_huskar_berserkers_blood = class({})
local modifier_class = modifier_mjz_huskar_berserkers_blood

function modifier_class:IsPassive() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:IsHidden() 
    local hp_threshold_effect = self:GetAbility():GetSpecialValueFor('hp_threshold_effect')
    if self:GetParent():GetHealthPercent() < hp_threshold_effect then
        return false 
    end
    return true
end

function modifier_class:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

function modifier_class:GetModifierAttackSpeedBonus_Constant()
    local hp = self:GetParent():GetHealthPercent() - self.max_threshold
	local pct = math.max(hp / self.range, 0)
	return (1 - pct) * self.max_as
end

function modifier_class:GetModifierIncomingDamage_Percentage()
    local hp = self:GetParent():GetHealthPercent() - self.max_threshold
    local pct = math.max(hp / self.range, 0)
    local bonus = (1 - pct) * self.max_mr
	return bonus * (-1)
end

function modifier_class:GetModifierConstantHealthRegen()
    local hp = self:GetParent():GetHealthPercent() - self.max_threshold
    local pct = math.max(hp / self.range, 0)
    local str = self:GetParent():GetStrength() * (self.max_hr / 100)
	return (1 - pct) * str
end

function modifier_class:GetModifierModelScale()
    local hp = self:GetParent():GetHealthPercent() - self.max_threshold
    local pct = math.max(hp / self.range, 0)
	return (1 - pct) * self.max_size    
end

function modifier_class:OnCreated( kv )
    self:_Init()
    
    if IsServer() then
        self:StartIntervalThink(0.5)
    end
end

function modifier_class:OnRefresh(table)
    self:_Init()
end

function modifier_class:_Init( )
    local ability = self:GetAbility()
    if ability and IsValidEntity(ability) then
        self.max_as = ability:GetSpecialValueFor( "maximum_attack_speed" )
        self.max_mr = ability:GetSpecialValueFor( "maximum_resistance" )
        self.max_hr = ability:GetSpecialValueFor( "maximum_health_regen" )
        self.max_threshold = ability:GetSpecialValueFor( "hp_threshold_max" )
        self.max_size = ability:GetSpecialValueFor( "model_multiplier" )
        self.range = 100 - self.max_threshold
    end    
end

if IsServer() then
    function modifier_class:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility() 
        local hp_threshold_effect = self:GetAbility():GetSpecialValueFor('hp_threshold_effect')
        local p_name = "particles/units/heroes/hero_huskar/huskar_inner_vitality.vpcf"

        if self:GetParent():GetHealthPercent() < hp_threshold_effect then
            if not self.nFXIndex then
                self.nFXIndex = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, parent)
            end
        else
            if self.nFXIndex then
                ParticleManager:DestroyParticle(self.nFXIndex, false)
                ParticleManager:ReleaseParticleIndex(self.nFXIndex)
            end
        end
    end
end



---------------------------------------------------------------------------------------

modifier_mjz_huskar_berserkers_blood_attack_speed = class({})
local modifier_attack_speed = modifier_mjz_huskar_berserkers_blood_attack_speed

function modifier_attack_speed:IsHidden() return true end
function modifier_attack_speed:IsPurgable() return false end

function modifier_attack_speed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end
function modifier_attack_speed:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end

---------------------------------------------------------------------------------------

modifier_mjz_huskar_berserkers_blood_health_regen = class({})
local modifier_health_regen = modifier_mjz_huskar_berserkers_blood_health_regen

function modifier_health_regen:IsHidden() return true end
function modifier_health_regen:IsPurgable() return false end

function modifier_health_regen:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end
function modifier_health_regen:GetModifierConstantHealthRegen()
    return self:GetStackCount()
end

---------------------------------------------------------------------------------------

modifier_mjz_huskar_berserkers_blood_magical_resistance = class({})
local modifier_magical_resistance = modifier_mjz_huskar_berserkers_blood_magical_resistance

function modifier_magical_resistance:IsHidden() return true end
function modifier_magical_resistance:IsPurgable() return false end

function modifier_magical_resistance:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end
function modifier_magical_resistance:GetModifierMagicalResistanceBonus()
    return self:GetStackCount()
end


---------------------------------------------------------------------------------------


