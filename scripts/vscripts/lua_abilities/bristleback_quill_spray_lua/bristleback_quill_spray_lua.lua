bristleback_quill_spray_lua = class({})
LinkLuaModifier("modifier_bristleback_quill_spray_lua", "lua_abilities/bristleback_quill_spray_lua/modifier_bristleback_quill_spray_lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Start
function bristleback_quill_spray_lua:OnSpellStart()
    -- unit identifier
    caster = self:GetCaster()

    -- load data
    local radius = self:GetSpecialValueFor("radius")
    local stack_damage = self:GetSpecialValueFor("quill_stack_damage") + (self:GetCaster():GetStrength() * self:GetSpecialValueFor("str_multiplier")) 
    local base_damage = self:GetSpecialValueFor("quill_base_damage") + (self:GetCaster():GetStrength() * self:GetSpecialValueFor("str_multiplier")) * 100
    local stack_duration = self:GetSpecialValueFor("quill_stack_duration")

    -- Find Units in Radius
    local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(), -- int, your team number
            caster:GetOrigin(), -- point, center point
            nil, -- handle, cacheUnit. (not known)
            radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, -- int, flag filter
            0, -- int, order filter
            false    -- bool, can grow cache
    )

    -- Apply Damage
    local damageTable = {
        attacker = caster,
        damage_type = self:GetAbilityDamageType(),
        ability = self, --Optional.
    }

    for _, enemy in pairs(enemies) do
        -- find stack
        local stack = 0
        local modifier = enemy:FindModifierByNameAndCaster("modifier_bristleback_quill_spray_lua", caster)
        if modifier ~= nil then
            stack = modifier:GetStackCount()
            modifier:IncrementStackCount()
            modifier:ForceRefresh()
        else
            -- Add modifier
            enemy:AddNewModifier(
                    caster, -- player source
                    self, -- ability source
                    "modifier_bristleback_quill_spray_lua", -- modifier name
                    { duration = stack_duration } -- kv
            )
        end

        -- damage
        damageTable.victim = enemy
        damageTable.damage = base_damage + stack * stack_damage
        ApplyDamage(damageTable)

        -- Effects
        self:PlayEffects2(enemy)
    end

    -- Effects
    --self:PlayEffects1()
end

--------------------------------------------------------------------------------
-- Effects
--[[function bristleback_quill_spray_lua:PlayEffects1()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf"
    local sound_cast = "Hero_Bristleback.QuillSpray.Cast"

    -- Create Particle
    -- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetCaster() )
    local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(effect_cast)

    -- Create Sound
    EmitSoundOn(sound_cast, self:GetCaster())
end]]

function bristleback_quill_spray_lua:PlayEffects2(target)
    --local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf"
    --local sound_cast = "Hero_Bristleback.QuillSpray.Target"
    local sound_cast = "Hero_Bristleback.QuillSpray.Cast"
    local caster = self:GetCaster()
    -- Create Particle
    --local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
    --ParticleManager:ReleaseParticleIndex(effect_cast)

    -- Create Sound
    caster:EmitSoundParams(sound_cast, 0, 0.6, 0)
    --EmitSoundOn(sound_cast, self:GetCaster())
end
