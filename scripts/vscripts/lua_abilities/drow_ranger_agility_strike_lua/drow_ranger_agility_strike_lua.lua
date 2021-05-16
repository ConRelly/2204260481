drow_ranger_agility_strike_lua = class({})
LinkLuaModifier( "modifier_drow_ranger_agility_strike_lua", "lua_abilities/drow_ranger_agility_strike_lua/modifier_drow_ranger_agility_strike_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function drow_ranger_agility_strike_lua:GetIntrinsicModifierName()
	return "modifier_drow_ranger_agility_strike_lua"
end
