--------------------------------------------------------------------------------
drow_ranger_multishot_lua = class({})
LinkLuaModifier("modifier_drow_ranger_multishot_lua", "lua_abilities/drow_ranger_multishot_lua/modifier_drow_ranger_multishot_lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
function drow_ranger_multishot_lua:GetIntrinsicModifierName()
    return "modifier_drow_ranger_multishot_lua"
end

--------------------------------------------------------------------------------
-- Projectile
function drow_ranger_multishot_lua:OnProjectileHit_ExtraData(target, location, data)
    if not target then
        return
    end

    -- get value
    local damage_modifier = self:GetSpecialValueFor("damage_modifier")
    local agi_multiplier = self:GetSpecialValueFor("agi_multiplier")
    -- Talent tree
    local special_multishot_agi_multiplier_lua = self:GetCaster():FindAbilityByName("special_multishot_agi_multiplier_lua")
    if (special_multishot_agi_multiplier_lua and special_multishot_agi_multiplier_lua:GetLevel() ~= 0) then
        agi_multiplier = agi_multiplier + special_multishot_agi_multiplier_lua:GetSpecialValueFor("value")
    end
    -- Talent tree
    local special_multishot_damage_modifier_lua = self:GetCaster():FindAbilityByName("special_multishot_damage_modifier_lua")
    if (special_multishot_damage_modifier_lua and special_multishot_damage_modifier_lua:GetLevel() ~= 0) then
        damage_modifier = damage_modifier + special_multishot_damage_modifier_lua:GetSpecialValueFor("value")
    end
    local caster = self:GetCaster()
    local damage = (damage_modifier / 100) * caster:GetAverageTrueAttackDamage(caster) + math.floor(caster:GetAgility() * agi_multiplier)
    local slow = self:GetSpecialValueFor("arrow_slow_duration")

    -- check frost arrow ability
    if data.frost == 1 then
        local ability = self:GetCaster():FindAbilityByName("drow_ranger_frost_arrows_lua")
        target:AddNewModifier(
                self:GetCaster(), -- player source
                ability, -- ability source
                "modifier_drow_ranger_frost_arrows_lua", -- modifier name
                { duration = slow } -- kv
        )
    end

    -- damage
    local damageTable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self, --Optional.
        -- damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
    }
    ApplyDamage(damageTable)

    -- play effects
    local sound_cast = "Hero_DrowRanger.ProjectileImpact"
    EmitSoundOn(sound_cast, target)

    return true
end