LinkLuaModifier("modifier_mjz_brewmaster_drunken_brawler_active", "modifiers/hero_brewmaster/modifier_mjz_brewmaster_drunken_brawler_active.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_brewmaster_drunken_brawler", "modifiers/hero_brewmaster/modifier_mjz_brewmaster_drunken_brawler.lua", LUA_MODIFIER_MOTION_NONE)


mjz_brewmaster_drunken_brawler = class({})
local ability_class = mjz_brewmaster_drunken_brawler


function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_brewmaster_drunken_brawler"
end

function ability_class:OnSpellStart( )
	if not IsServer() then return nil end

	local caster = self:GetCaster()
	local ability = self
	local duration = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1  ) 
	local dodge_chance = ability:GetLevelSpecialValueFor( "dodge_chance" , ability:GetLevel() - 1  )

	local modifier_name = "modifier_mjz_brewmaster_drunken_brawler_active"
	caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
end

function ability_class:_Refresh( )
	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName('modifier_mjz_brewmaster_drunken_brawler')
	if modifier then
		modifier:ForceRefresh()
	end
end
