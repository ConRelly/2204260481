legion_commander_duel_lua = class({})
LinkLuaModifier( "modifier_legion_commander_duel_lua", "lua_abilities/legion_commander_duel_lua/modifier_legion_commander_duel_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function legion_commander_duel_lua:GetIntrinsicModifierName()
	return "modifier_legion_commander_duel_lua"
end
 
--------------------------------------------------------------------------------

function legion_commander_duel_lua:GetDuelKills()
	if self.nKills == nil then
		self.nKills = 0
	end
	return self.nKills
end

function legion_commander_duel_lua:IncrementDuelKills()
	self.nKills = self:GetDuelKills() + 1
end