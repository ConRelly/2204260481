-- Project Name: 	Siltbreaker Hard Mode
-- Author:			BroFrank
-- SteamAccountID:	144490770

item_mjz_preserved_skull = class({})
LinkLuaModifier( "modifier_item_mjz_preserved_skull", "modifiers/modifier_item_mjz_preserved_skull", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_preserved_skull_buff", "modifiers/modifier_item_mjz_preserved_skull_buff", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------

function item_mjz_preserved_skull:GetIntrinsicModifierName()
	return "modifier_item_mjz_preserved_skull"
end

--------------------------------------------------------------------------------

function item_mjz_preserved_skull:Spawn()
	self.required_level = self:GetSpecialValueFor( "required_level" )
end

--------------------------------------------------------------------------------

function item_mjz_preserved_skull:OnHeroLevelUp()
	if IsServer() then
		if self:GetCaster():GetLevel() == self.required_level and self:IsInBackpack() == false then
			self:OnUnequip()
			self:OnEquip()
		end
	end
end

--------------------------------------------------------------------------------

function item_mjz_preserved_skull:IsMuted()	
	if self.required_level > self:GetCaster():GetLevel() then
		return true
	end
	if not self:GetCaster():IsHero() then
		return true
	end
	return self.BaseClass.IsMuted( self )
end
