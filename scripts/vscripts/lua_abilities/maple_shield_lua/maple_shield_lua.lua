--------------------------------------------------------------------------------
maple_shield_lua = class({})
LinkLuaModifier("modifier_maple_shield_lua", "lua_abilities/maple_shield_lua/modifier_maple_shield_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maple_shield_lua_aura", "lua_abilities/maple_shield_lua/modifier_maple_shield_lua_aura", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
function maple_shield_lua:GetIntrinsicModifierName()
    return "modifier_maple_shield_lua"
end