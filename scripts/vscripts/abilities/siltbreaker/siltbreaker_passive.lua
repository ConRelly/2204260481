
siltbreaker_passive = class({})
LinkLuaModifier( "modifier_siltbreaker_passive", "modifiers/siltbreaker/modifier_siltbreaker_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_siltbreaker_attack", "modifiers/siltbreaker/modifier_siltbreaker_attack", LUA_MODIFIER_MOTION_NONE )

-----------------------------------------------------------------------------------------

function siltbreaker_passive:GetIntrinsicModifierName()
	return "modifier_siltbreaker_passive"
end

-----------------------------------------------------------------------------------------

