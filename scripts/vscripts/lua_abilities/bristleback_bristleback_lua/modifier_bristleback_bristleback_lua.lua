

modifier_bristleback_bristleback_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_bristleback_bristleback_lua:IsHidden()
    return true
end

function modifier_bristleback_bristleback_lua:IsDebuff()
    return false
end

function modifier_bristleback_bristleback_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_bristleback_bristleback_lua:OnCreated(kv)
    if not IsServer() then return end
    -- references
    self.reduction_back = self:GetAbility():GetSpecialValueFor("back_damage_reduction")
    self.reduction_side = self:GetAbility():GetSpecialValueFor("side_damage_reduction")
    self.max_threshold = self:GetAbility():GetSpecialValueFor("quill_release_threshold")
    self.ability_proc = "bristleback_quill_spray_lua"

    self.threshold = 0

    self:StartIntervalThink(3.0)
      
end

function modifier_bristleback_bristleback_lua:OnRefresh(kv)
    -- references
    if not IsServer() then return end
    self.reduction_back = self:GetAbility():GetSpecialValueFor("back_damage_reduction")
    self.reduction_side = self:GetAbility():GetSpecialValueFor("side_damage_reduction")
    self.max_threshold = self:GetAbility():GetSpecialValueFor("quill_release_threshold")
end

function modifier_bristleback_bristleback_lua:OnDestroy(kv)

end
function modifier_bristleback_bristleback_lua:OnIntervalThink()
    if IsServer() then
        local current_challenge_boss = _G._challenge_bosss or 0
        if current_challenge_boss > 0 then
            self:SetStackCount(current_challenge_boss)
            self:StartIntervalThink(-1) -- Stop the interval think
        end
    end
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_bristleback_bristleback_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
    return funcs
end

function modifier_bristleback_bristleback_lua:GetModifierPhysicalArmorBonus()
    local hero_level = self:GetParent():GetLevel()
    return 3 * self:GetStackCount() * hero_level
end
function modifier_bristleback_bristleback_lua:GetModifierIncomingDamage_Percentage(keys)
    if IsServer() and (not self:GetParent():PassivesDisabled()) then
        if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
           return 0
        else   
            self:ThresholdLogic(keys.damage)
            self:PlayEffects()
            return -self.reduction_back
        end    
    end
end

--------------------------------------------------------------------------------
-- helper
function modifier_bristleback_bristleback_lua:ThresholdLogic(damage)
    self.threshold = math.floor(self.threshold + math.floor(damage))
    if self.threshold > self.max_threshold then
        -- reset threshold
        self.threshold = 0

        -- cast quill spray if found
        if self:GetParent() and self:GetParent():IsAlive() then
            local ability = self:GetParent():FindAbilityByName(self.ability_proc)
            if ability ~= nil and ability:GetLevel() >= 1 then
                ability:OnSpellStart()
            end
        end    
    end
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_bristleback_bristleback_lua:PlayEffects()
    -- Get Resources
    local particle_cast_back = "particles/units/heroes/hero_bristleback/bristleback_back_dmg.vpcf"
    --local particle_cast_side = "particles/units/heroes/hero_bristleback/bristleback_side_dmg.vpcf"
    local sound_cast = "Hero_Bristleback.Bristleback"
    local caster = self:GetCaster()

    local effect_cast = ParticleManager:CreateParticle(particle_cast_back, PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        1,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        self:GetParent():GetOrigin(), -- unknown
        true -- unknown, true
    )
    caster:EmitSoundParams(sound_cast, 0, 0.4, 0)
    --EmitSoundOn(sound_cast, self:GetParent())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

