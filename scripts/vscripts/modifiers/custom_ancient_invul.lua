LinkLuaModifier("modifier_custom_ancient_invul", "modifiers/custom_ancient_invul.lua", LUA_MODIFIER_MOTION_NONE)
custom_ancient_invul = class({})
function custom_ancient_invul:GetIntrinsicModifierName()
    return "modifier_custom_ancient_invul"
end

modifier_custom_ancient_invul = class({})
function modifier_custom_ancient_invul:IsHidden()
    return false
end

function modifier_custom_ancient_invul:GetTexture()
    return "absolute_defense"
end

function modifier_custom_ancient_invul:IsPurgable()
    return false
end

function modifier_custom_ancient_invul:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end