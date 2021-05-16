modifier_juggernaut_blade_dance_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_juggernaut_blade_dance_lua:IsHidden()
    return true
end

function modifier_juggernaut_blade_dance_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_juggernaut_blade_dance_lua:OnCreated(kv)
    -- references
    self.crit_chance = self:GetAbility():GetSpecialValueFor("blade_dance_crit_chance")
    self.max_crit_chance = self:GetAbility():GetSpecialValueFor("max_crit_chance")
    self.crit_mult = self:GetAbility():GetSpecialValueFor("blade_dance_crit_mult")
    self.crit_chance_agi_multiplier = self:GetAbility():GetSpecialValueFor("crit_chance_agi_multiplier")
end

function modifier_juggernaut_blade_dance_lua:OnRefresh(kv)
    -- references
    self.crit_chance = self:GetAbility():GetSpecialValueFor("blade_dance_crit_chance")
    self.max_crit_chance = self:GetAbility():GetSpecialValueFor("max_crit_chance")
    self.crit_mult = self:GetAbility():GetSpecialValueFor("blade_dance_crit_mult")
    self.crit_chance_agi_multiplier = self:GetAbility():GetSpecialValueFor("crit_chance_agi_multiplier")
end

function modifier_juggernaut_blade_dance_lua:OnDestroy(kv)

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_juggernaut_blade_dance_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        --MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    }

    return funcs
end
function modifier_juggernaut_blade_dance_lua:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() and (not self:GetParent():PassivesDisabled()) then
        -- Throw dice
        local crit_chance = math.min(self.crit_chance + math.floor(self:GetParent():GetAgility() * self.crit_chance_agi_multiplier), self.max_crit_chance)
        if RandomInt(0, 100) < crit_chance then
            self.record = params.record
            return self.crit_mult
        end
    end
end
--[[function modifier_juggernaut_blade_dance_lua:GetModifierProcAttack_Feedback(params)
    if IsServer() then
        if self.record and self.record == params.record then
            self.record = nil

            -- Play effects
            local sound_cast = "Hero_Juggernaut.BladeDance"
            EmitSoundOn(sound_cast, params.target)
        end
    end
end]]