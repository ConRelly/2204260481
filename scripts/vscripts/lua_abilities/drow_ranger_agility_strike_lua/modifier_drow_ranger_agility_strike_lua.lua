modifier_drow_ranger_agility_strike_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_drow_ranger_agility_strike_lua:IsHidden()
    -- actual true
    return false
end

function modifier_drow_ranger_agility_strike_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_drow_ranger_agility_strike_lua:OnCreated(kv)
    -- references
    self.crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
    self.agi_multiplier = self:GetAbility():GetSpecialValueFor("agi_multiplier")
end

function modifier_drow_ranger_agility_strike_lua:OnRefresh(kv)
    -- references
    self.crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
    self.agi_multiplier = self:GetAbility():GetSpecialValueFor("agi_multiplier")
end

function modifier_drow_ranger_agility_strike_lua:OnDestroy(kv)

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_drow_ranger_agility_strike_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    }

    return funcs
end

function modifier_drow_ranger_agility_strike_lua:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() and not self:GetParent():PassivesDisabled() and self:GetAbility():IsFullyCastable() then
        -- Talent tree
        local crit_chance = self.crit_chance
        local special_agility_strike_chance_lua = self:GetParent():FindAbilityByName("special_agility_strike_chance_lua")
        if (special_agility_strike_chance_lua and special_agility_strike_chance_lua:GetLevel() ~= 0) then
            crit_chance = crit_chance + special_agility_strike_chance_lua:GetSpecialValueFor("value")
        end
        if self:RollChance(crit_chance) then
            local crit_bonus = 100 + self.agi_multiplier * self:GetCaster():GetAgility()
            self.record = params.record
            -- cooldown
            self:GetAbility():UseResources(false, false, true)
            return crit_bonus
        end
    end
end

function modifier_drow_ranger_agility_strike_lua:GetModifierProcAttack_Feedback(params)
    if IsServer() then
        if self.record then
            self.record = nil
            self:PlayEffects(params.target)
        end
    end
end
--------------------------------------------------------------------------------
-- Helper
function modifier_drow_ranger_agility_strike_lua:RollChance(chance)
    local rand = math.random()
    if rand < chance / 100 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_drow_ranger_agility_strike_lua:PlayEffects(target)
    -- Load effects
    local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
    local sound_cast = "Hero_PhantomAssassin.CoupDeGrace"

    -- if target:IsMechanical() then
    -- 	particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_mechanical.vpcf"
    -- 	sound_cast = "Hero_PhantomAssassin.CoupDeGrace.Mech"
    -- end

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(
            effect_cast,
            0,
            target,
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            target:GetOrigin(), -- unknown
            true -- unknown, true
    )
    ParticleManager:SetParticleControlForward(effect_cast, 1, (self:GetParent():GetOrigin() - target:GetOrigin()):Normalized())
    ParticleManager:ReleaseParticleIndex(effect_cast)

    EmitSoundOn(sound_cast, target)
end