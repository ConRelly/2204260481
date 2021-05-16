if item_upgraded_octarine_core == nil then item_upgraded_octarine_core = class({}) end
LinkLuaModifier("modifier_item_upgraded_octarine_core", "items/upgraded_octarine_core.lua", LUA_MODIFIER_MOTION_NONE)
function item_upgraded_octarine_core:GetIntrinsicModifierName() return "modifier_item_upgraded_octarine_core" end
if modifier_item_upgraded_octarine_core == nil then modifier_item_upgraded_octarine_core = class({}) end
function modifier_item_upgraded_octarine_core:IsHidden() return true end
function modifier_item_upgraded_octarine_core:IsPurgable() return false end
function modifier_item_upgraded_octarine_core:RemoveOnDeath() return false end
function modifier_item_upgraded_octarine_core:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_upgraded_octarine_core:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end
function modifier_item_upgraded_octarine_core:GetModifierHealthBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("hp")
	end
end
function modifier_item_upgraded_octarine_core:GetModifierManaBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("mana")
	end
end
function modifier_item_upgraded_octarine_core:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_cast_range")
	end
end
function modifier_item_upgraded_octarine_core:GetModifierPercentageCooldown()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("cooldown")
	end
end
function modifier_item_upgraded_octarine_core:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("all_stats")
	end
end
function modifier_item_upgraded_octarine_core:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("all_stats")
	end
end
function modifier_item_upgraded_octarine_core:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("all_stats")
	end
end
function modifier_item_upgraded_octarine_core:GetModifierConstantManaRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("mana_regen")
	end
end