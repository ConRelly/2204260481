modifier_bristleback_quill_spray_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_bristleback_quill_spray_lua:IsHidden()
    return false
end

function modifier_bristleback_quill_spray_lua:IsDebuff()
    return true
end

function modifier_bristleback_quill_spray_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_bristleback_quill_spray_lua:OnCreated(kv)
    -- set stack
    self:SetStackCount(1)

    if IsServer() then
        --self:PlayEffects()
    end
end

function modifier_bristleback_quill_spray_lua:OnRefresh(kv)
    if IsServer() then
        --self:PlayEffects()
    end
end

--[[function modifier_bristleback_quill_spray_lua:PlayEffects()
    local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray_hit_creep.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

    ParticleManager:SetParticleControlEnt(effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(effect_cast, false, false, -1, false, false)
end]]