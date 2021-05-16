drow_ranger_frost_arrows_lua = class({})
LinkLuaModifier("modifier_drow_ranger_frost_arrows_lua", "lua_abilities/drow_ranger_frost_arrows_lua/modifier_drow_ranger_frost_arrows_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
function drow_ranger_frost_arrows_lua:GetIntrinsicModifierName()
    return "modifier_generic_orb_effect_lua"
end

--------------------------------------------------------------------------------

--[[function drow_ranger_frost_arrows_lua:CastFilterResultTarget(hTarget)
    if IsServer() and hTarget ~= nil and hTarget.GetUnitName ~= nil then
        return UnitFilter(
                hTarget,
                self:GetAbilityTargetTeam(),
                self:GetAbilityTargetType(),
                self:GetAbilityTargetFlags(),
                self:GetCaster():GetTeamNumber()
        )
    end
    return UF_FAIL_OTHER
end]]
--------------------------------------------------------------------------------
-- Ability Start
function drow_ranger_frost_arrows_lua:OnSpellStart()
end

--------------------------------------------------------------------------------
-- Orb Effects
function drow_ranger_frost_arrows_lua:GetProjectileName()
    return "particles/units/heroes/hero_drow/drow_frost_arrow.vpcf"
end

function drow_ranger_frost_arrows_lua:OnOrbFire(params)
    -- play effects
    local sound_cast = "Hero_DrowRanger.FrostArrows"
    EmitSoundOn(sound_cast, self:GetCaster())
end

function drow_ranger_frost_arrows_lua:OnOrbImpact(params)
    local duration = self:GetDuration()

    params.target:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_drow_ranger_frost_arrows_lua", -- modifier name
            { duration = duration } -- kv
    )
end