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
ogre_magi_multicast_lua = class({})
LinkLuaModifier( "modifier_ogre_magi_multicast_lua", "lua_abilities/ogre_magi_multicast_lua/modifier_ogre_magi_multicast_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ogre_magi_multicast_lua_proc", "lua_abilities/ogre_magi_multicast_lua/modifier_ogre_magi_multicast_lua_proc", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ogre_magi_multicast_lua_self_cast_proc", "lua_abilities/ogre_magi_multicast_lua/modifier_ogre_magi_multicast_lua_self_cast_proc", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier("modifier_ogre_magi_multicast_n", "abilities/heroes/ogre_magi_multicast_n", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
function ogre_magi_multicast_lua:GetIntrinsicModifierName()
	return "modifier_ogre_magi_multicast_n"
end

--------------------------------------------------------------------------------
-- Item Events
function ogre_magi_multicast_lua:OnInventoryContentsChanged( params )

	local caster = self:GetCaster()
	-- get data
	local scepter = caster:HasScepter()
	local ability = caster:FindAbilityByName( "ogre_magi_unrefined_fireblast_lua" )

	-- if there's no ability, then add it
	if not ability then 
		ability = caster:AddAbility( "ogre_magi_unrefined_fireblast_lua" )
	end

	ability:SetActivated( scepter )
	ability:SetHidden( not scepter )

	if ability:GetLevel()~=1 then
		ability:SetLevel( 1 )
	end

end