modifier_sniper_shrapnel_lua_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sniper_shrapnel_lua_thinker:IsHidden()
    return true
end

function modifier_sniper_shrapnel_lua_thinker:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sniper_shrapnel_lua_thinker:OnCreated(kv)
    -- references
    self.delay = self:GetAbility():GetSpecialValueFor("damage_delay") -- special value
    self.radius = self:GetAbility():GetSpecialValueFor("radius") -- special value
    self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration") -- special value
    self.interval = 1.0

    self.start = false

    if IsServer() then
        self.direction = (self:GetParent():GetOrigin() - self:GetCaster():GetOrigin()):Normalized()

        -- Start interval
        self:StartIntervalThink(self.delay)

        -- effects
        self.sound_cast = "Hero_Sniper.ShrapnelShatter"
        EmitSoundOn(self.sound_cast, self:GetParent())
    end
end

function modifier_sniper_shrapnel_lua_thinker:OnDestroy(kv)
    if not IsServer() then
        return
    end
    self:StopEffects()
    UTIL_Remove(self:GetParent())
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_sniper_shrapnel_lua_thinker:OnIntervalThink()
    if not self.start then
        self.start = true
        self:StartIntervalThink(self.interval)
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self.radius, self:GetDuration(), false)

        -- effects
        self:PlayEffects()
    else
        local caster = self:GetCaster()
        -- apply debuff around
        local targets = FindUnitsInRadius(
                caster:GetTeamNumber(), -- int, your team number
                self:GetParent():GetOrigin(), -- point, center point
                nil, -- handle, cacheUnit. (not known)
                self.radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
                self:GetAbility():GetAbilityTargetTeam(), -- int, team filter
                self:GetAbility():GetAbilityTargetType(), -- int, type filter
                self:GetAbility():GetAbilityTargetFlags(), -- int, flag filter
                0, -- int, order filter
                false    -- bool, can grow cache
        )

        for _, enemy in pairs(targets) do
            enemy:AddNewModifier(
                    caster, -- player source
                    self:GetAbility(), -- ability source
                    "modifier_sniper_shrapnel_lua", -- modifier name
                    { duration = self.slow_duration } -- kv
            )
        end
    end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_sniper_shrapnel_lua_thinker:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf"

    -- Create Particle
    self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.radius, 1, 1))
    ParticleManager:SetParticleControlForward(self.effect_cast, 2, self.direction + Vector(0, 0, 0.1))
end

function modifier_sniper_shrapnel_lua_thinker:StopEffects()
    ParticleManager:DestroyParticle(self.effect_cast, false)
    ParticleManager:ReleaseParticleIndex(self.effect_cast)

    StopSoundOn(self.sound_cast, self:GetParent())
end