LinkLuaModifier("modifier_mjz_phoenix_sun_ray_move","modifiers/hero_phoenix/modifier_mjz_phoenix_sun_ray_move.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_phoenix_sun_ray_toggle_move","abilities/hero_phoenix/mjz_phoenix_sun_ray_toggle_move.lua", LUA_MODIFIER_MOTION_NONE)

local MAIN_ABILITY_NAME = 'mjz_phoenix_sun_ray'
local MODIFIER_CASTER_NAME = 'modifier_mjz_phoenix_sun_ray_caster'
local MODIFIER_ROOTED_NAME = 'modifier_mjz_phoenix_sun_ray_rooted'
local MODIFIER_MOVE_NAME = 'modifier_mjz_phoenix_sun_ray_move'

mjz_phoenix_sun_ray_toggle_move = class({})
local ability_class = mjz_phoenix_sun_ray_toggle_move

function ability_class:OnToggle()
    if IsServer() then
        local ability = self
        local caster = self:GetCaster()
        local main_abilty = caster:FindAbilityByName(MAIN_ABILITY_NAME)
        local modifier_caster = caster:FindModifierByName(MODIFIER_CASTER_NAME)
        if main_abilty and modifier_caster then
            if caster:HasModifier(MODIFIER_ROOTED_NAME) then
                caster:RemoveModifierByName(MODIFIER_ROOTED_NAME)
                caster:AddNewModifier(caster, main_abilty, MODIFIER_MOVE_NAME, {})
                caster:AddNewModifier(caster, ability, 'modifier_mjz_phoenix_sun_ray_toggle_move', {})
            else
                caster:RemoveModifierByName(MODIFIER_MOVE_NAME)
                caster:AddNewModifier(caster, main_abilty, MODIFIER_ROOTED_NAME, {})
            end
        end
    end
end


modifier_mjz_phoenix_sun_ray_toggle_move = class({})
local modifier_toggle_move = modifier_mjz_phoenix_sun_ray_toggle_move
function modifier_toggle_move:IsHidden() return true end
function modifier_toggle_move:IsPurgable() return false end

if IsServer() then
    function modifier_toggle_move:OnCreated(table)
        self:StartIntervalThink(1.0)
    end

    function modifier_toggle_move:OnIntervalThink()
        local ability = self:GetAbility()
        local caster = self:GetCaster()

        if not caster:HasModifier(MODIFIER_CASTER_NAME) then
            if ability:GetToggleState() then
                ability:ToggleAbility()
            end

            self:StartIntervalThink(-1)
            self:Destroy()
        end
    end
end