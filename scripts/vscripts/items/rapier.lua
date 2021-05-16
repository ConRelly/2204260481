LinkLuaModifier("modifier_divine_rapier_cus", "items/rapier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arcane_rapier_cus", "items/rapier.lua", LUA_MODIFIER_MOTION_NONE)
-----------------
--DIVINE RAPIER--
-----------------
item_rapier_cus = class({})
function item_rapier_cus:OnOwnerDied(params)
	local owner = self:GetOwner()
	if not owner:IsRealHero() then
		owner:DropItem(self, true, true)
		return
	end
	if not owner:IsReincarnating() then
		owner:DropItem(self, true, true)
	end
end
function item_rapier_cus:IsRapier() return true end
function item_rapier_cus:GetIntrinsicModifierName() return "modifier_divine_rapier_cus" end
function item_rapier_cus:GetAbilityTextureName() return "item_rapier" end

modifier_divine_rapier_cus = class({})
function modifier_divine_rapier_cus:IsHidden() return true end
function modifier_divine_rapier_cus:IsPurgable() return false end
function modifier_divine_rapier_cus:RemoveOnDeath() return false end
function modifier_divine_rapier_cus:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_divine_rapier_cus:OnDestroy()
	if IsServer() then
		self:StartIntervalThink(-1)
	end
end
function modifier_divine_rapier_cus:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_divine_rapier_cus:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	if self:GetAbility() and not self:GetCaster():IsIllusion() then
		self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	else
		self.bonus_damage = 0
	end
end
--[[function modifier_divine_rapier_cus:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end]]
function modifier_divine_rapier_cus:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self.bonus_damage end
end

-----------------
--ARCANE RAPIER--
-----------------
item_arcane_rapier_cus = class({})
function item_arcane_rapier_cus:OnOwnerDied(params)
	local owner = self:GetOwner()
	if not owner:IsRealHero() then
		owner:DropItem(self, true, true)
		return
	end
	if not owner:IsReincarnating() then
		owner:DropItem(self, true, true)
	end
end
function item_arcane_rapier_cus:IsRapier() return true end
function item_arcane_rapier_cus:GetIntrinsicModifierName() return "modifier_arcane_rapier_cus" end
function item_arcane_rapier_cus:GetAbilityTextureName() return "custom/rapier_magic" end

modifier_arcane_rapier_cus = class({})
function modifier_arcane_rapier_cus:IsHidden() return true end
function modifier_arcane_rapier_cus:IsPurgable() return false end
function modifier_arcane_rapier_cus:RemoveOnDeath() return false end
function modifier_arcane_rapier_cus:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_arcane_rapier_cus:OnDestroy()
	if IsServer() then
		self:StartIntervalThink(-1)
	end
end
function modifier_arcane_rapier_cus:DeclareFunctions()
	return { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
function modifier_arcane_rapier_cus:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	if self:GetAbility() and not self:GetParent():IsIllusion() then
		self.spell_power = self:GetAbility():GetSpecialValueFor("spell_power")
	else
		self.spell_power = 0
	end
end
function modifier_arcane_rapier_cus:GetModifierSpellAmplify_Percentage() return self.spell_power end


local function based(orig)
	local copy = {}
	for orig_key, orig_value in pairs(orig) do
		copy[orig_key] = orig_value
	end
	return copy
end
