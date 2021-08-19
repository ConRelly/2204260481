-- Project Name: 	Siltbreaker Hard Mode
-- Author:			BroFrank
-- SteamAccountID:	144490770

LinkLuaModifier("modifier_item_mjz_preserved_skull", "items/item_mjz_preserved_skull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_preserved_skull_buff", "items/item_mjz_preserved_skull", LUA_MODIFIER_MOTION_NONE)

---------------------
-- Preserved Skull --
---------------------
item_mjz_preserved_skull = class({})
function item_mjz_preserved_skull:GetIntrinsicModifierName() return "modifier_item_mjz_preserved_skull" end
function item_mjz_preserved_skull:Spawn()
	self.required_level = self:GetSpecialValueFor("required_level")
end
function item_mjz_preserved_skull:OnHeroLevelUp()
	if IsServer() then
		if self:GetCaster():GetLevel() == self.required_level and self:IsInBackpack() == false then
			self:OnUnequip()
			self:OnEquip()
		end
	end
end
function item_mjz_preserved_skull:IsMuted()	
	if self.required_level > self:GetCaster():GetLevel() then
		return true
	end
	if not self:GetCaster():IsHero() then
		return true
	end
	return self.BaseClass.IsMuted(self)
end

------------------------------
-- Preserved Skull Modifier --
------------------------------
modifier_item_mjz_preserved_skull = class({})
function modifier_item_mjz_preserved_skull:IsHidden() return true end
function modifier_item_mjz_preserved_skull:IsPurgable() return false end
function modifier_item_mjz_preserved_skull:OnCreated(kv)
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.bonus_intelligence = self:GetAbility():GetSpecialValueFor("bonus_intelligence")
end
function modifier_item_mjz_preserved_skull:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_item_mjz_preserved_skull:GetModifierBonusStats_Intellect(params) return self.bonus_intelligence end
function modifier_item_mjz_preserved_skull:GetModifierHealthBonus(params) return self.bonus_health end

function modifier_item_mjz_preserved_skull:IsAura() return true end
function modifier_item_mjz_preserved_skull:GetAuraRadius() return self.radius end
function modifier_item_mjz_preserved_skull:GetModifierAura()
	return  "modifier_item_mjz_preserved_skull_buff"
end
function modifier_item_mjz_preserved_skull:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_item_mjz_preserved_skull:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end
function modifier_item_mjz_preserved_skull:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------
-- Preserved Skull Aura --
--------------------------
modifier_item_mjz_preserved_skull_buff = class({})
function modifier_item_mjz_preserved_skull_buff:IsHidden() return false end
function modifier_item_mjz_preserved_skull_buff:GetTexture() return "item_mjz_preserved_skull" end
function modifier_item_mjz_preserved_skull_buff:OnCreated(kv)
	self.cooldown_reduction_pct = self:GetAbility():GetSpecialValueFor("cooldown_reduction_pct")
	self.aura_mana_regen = self:GetAbility():GetSpecialValueFor("aura_mana_regen")
end
function modifier_item_mjz_preserved_skull_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_item_mjz_preserved_skull_buff:GetModifierConstantManaRegen(params) return self.aura_mana_regen end
function modifier_item_mjz_preserved_skull_buff:GetModifierPercentageCooldown(params) return self.cooldown_reduction_pct end
