-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
doom_devour_lua = class({})
doom_devour_lua_slot1 = class({})
doom_devour_lua_slot2 = class({})

LinkLuaModifier("modifier_doom_devour_lua", "lua_abilities/doom_devour_lua/modifier_doom_devour_lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- AOE Radius
function doom_devour_lua:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end
--------------------------------------------------------------------------------
--- Disable Refresh
function doom_devour_lua:IsRefreshable()
    return false
end
--------------------------------------------------------------------------------
-- Ability Start
function doom_devour_lua:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- load data
    local duration = self:GetSpecialValueFor("devour_time")
    local radius = self:GetSpecialValueFor("radius")
    local damage = caster:GetStrength() * self:GetSpecialValueFor("str_multiplier")

    -- Find Units in Radius
    local targets = FindUnitsInRadius(
            caster:GetTeamNumber(), -- int, your team number
            target:GetOrigin(), -- point, center point
            nil, -- handle, cacheUnit. (not known)
            radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, -- int, flag filter
            0, -- int, order filter
            false    -- bool, can grow cache
    )

    -- damage target
    self.damageTable = {
        attacker = caster,
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self, --Optional.
    }

    for _, devourTarget in pairs(targets) do
        -- Play effects and no draw
        self:PlayEffects(devourTarget)
        devourTarget:SetOrigin(devourTarget:GetOrigin() + Vector(0, 0, -200))

        self.damageTable.victim = devourTarget
        ApplyDamage(self.damageTable)

        -- add modifier
        caster:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_doom_devour_lua", -- modifier name
                { duration = duration } -- kv
        )
    end
end

--------------------------------------------------------------------------------
function doom_devour_lua:PlayEffects(target)
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf"
    local sound_cast = "Hero_DoomBringer.Devour"
    local sound_target = "Hero_DoomBringer.DevourCast"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(
            effect_cast,
            1,
            self:GetCaster(),
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            Vector(0, 0, 0), -- unknown
            true -- unknown, true
    )
    ParticleManager:ReleaseParticleIndex(effect_cast)

    -- Create Sound
    EmitSoundOn(sound_cast, self:GetCaster())
    EmitSoundOn(sound_target, target)
end
