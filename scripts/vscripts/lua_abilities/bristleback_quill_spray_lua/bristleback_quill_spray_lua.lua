bristleback_quill_spray_lua = class({})
LinkLuaModifier("modifier_bristleback_quill_spray_lua", "lua_abilities/bristleback_quill_spray_lua/modifier_bristleback_quill_spray_lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Start
function bristleback_quill_spray_lua:OnSpellStart()
    -- unit identifier
    caster = self:GetCaster()

    -- load data
	local radius = self:GetSpecialValueFor("radius")
	local str_bonus = caster:GetStrength() * self:GetSpecialValueFor("str_multiplier") / 1000
	local stack_damage = self:GetSpecialValueFor("quill_stack_damage") + str_bonus
	local base_damage = self:GetSpecialValueFor("quill_base_damage") + (str_bonus * 100)
	local stack_duration = self:GetSpecialValueFor("quill_stack_duration")
    local armor_bonus = caster:GetPhysicalArmorValue(false)
    if HasSuperScepter(caster) then
        stack_damage = stack_damage + armor_bonus
        stack_duration = stack_duration + math.ceil(armor_bonus / 300)
    end

    -- Find Units in Radius
    local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), -- int, your team number
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
        local modifier = enemy:FindModifierByName("modifier_bristleback_quill_spray_lua")
        if modifier ~= nil then
            stack = modifier:GetStackCount()
            if HasSuperScepter(caster) then
                modifier:SetStackCount(stack + 2)
            else
                modifier:IncrementStackCount()
            end
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
    self:PlayEffects1()
end

--------------------------------------------------------------------------------
-- Effects
function bristleback_quill_spray_lua:PlayEffects1()
    -- Get Resources
--	local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf"
    local sound_cast = "Hero_Bristleback.QuillSpray.Cast"

    -- Create Particle
--	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self:GetCaster())
--	ParticleManager:ReleaseParticleIndex(effect_cast)

    -- Create Sound
--	EmitSoundOn(sound_cast, self:GetCaster())
	self:GetCaster():EmitSoundParams(sound_cast, 1, 0.5, 0)
end

function bristleback_quill_spray_lua:PlayEffects2(target)
    --local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf"
    local sound_cast = "Hero_Bristleback.QuillSpray.Target"
    -- Create Particle
    --local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
    --ParticleManager:ReleaseParticleIndex(effect_cast)

    target:EmitSoundParams(sound_cast, 1, 0.4, 0)
    --EmitSoundOn(sound_cast, self:GetCaster())
end
