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
	if not self:GetAbility() then return end
	local max_threshold = self:GetAbility():GetSpecialValueFor("hp_threshold_max")
	local hp = self:GetParent():GetHealthPercent() - max_threshold
	local pct = math.max(hp / 100 - max_threshold, 0)
	return (1 - pct) * self:GetAbility():GetSpecialValueFor("maximum_attack_speed")
end

function modifier_class:GetModifierIncomingDamage_Percentage()
	if not self:GetAbility() then return end
	local max_threshold = self:GetAbility():GetSpecialValueFor("hp_threshold_max")
	local hp = self:GetParent():GetHealthPercent() - max_threshold
	local pct = math.max(hp / 100 - max_threshold, 0)
	local bonus = (1 - pct) * self:GetAbility():GetSpecialValueFor("maximum_resistance")
	return bonus * (-1)
end

function modifier_class:GetModifierConstantHealthRegen()
	if not self:GetAbility() then return end
	local max_threshold = self:GetAbility():GetSpecialValueFor("hp_threshold_max")
	local hp = self:GetParent():GetHealthPercent() - max_threshold
	local pct = math.max(hp / 100 - max_threshold, 0)
	local str = self:GetParent():GetStrength() * (self:GetAbility():GetSpecialValueFor("maximum_health_regen") / 100)
	return (1 - pct) * str
end

function modifier_class:GetModifierModelScale()
	if not self:GetAbility() then return end
	local max_threshold = self:GetAbility():GetSpecialValueFor("hp_threshold_max")
	local hp = self:GetParent():GetHealthPercent() - max_threshold
	local pct = math.max(hp / 100 - max_threshold, 0)
	return (1 - pct) * self:GetAbility():GetSpecialValueFor("model_multiplier")
end

function modifier_class:OnCreated(kv)
    if IsServer() then
        self:StartIntervalThink(0.5)
    end
end

function modifier_class:OnIntervalThink()
	if IsServer() then
		local hp_threshold_effect = self:GetAbility():GetSpecialValueFor('hp_threshold_effect')
		local p_name = "particles/units/heroes/hero_huskar/huskar_inner_vitality.vpcf"

        if self:GetParent():GetHealthPercent() < hp_threshold_effect then
            if not self.nFXIndex then
                self.nFXIndex = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            end
        else
            if self.nFXIndex then
                ParticleManager:DestroyParticle(self.nFXIndex, false)
                ParticleManager:ReleaseParticleIndex(self.nFXIndex)
            end
        end
    end
end
