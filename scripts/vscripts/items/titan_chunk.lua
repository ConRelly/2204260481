if item_titan_chunk == nil then item_titan_chunk = class({}) end
LinkLuaModifier("modifier_item_titan_chunk", "items/titan_chunk.lua", LUA_MODIFIER_MOTION_NONE)
function item_titan_chunk:GetAbilityTextureName() return "custom/titan_chunk" end
function item_titan_chunk:GetIntrinsicModifierName() return "modifier_item_titan_chunk" end
if modifier_item_titan_chunk == nil then modifier_item_titan_chunk = class({}) end
function modifier_item_titan_chunk:IsHidden() return true end
function modifier_item_titan_chunk:IsPurgable() return false end
function modifier_item_titan_chunk:RemoveOnDeath() return false end
function modifier_item_titan_chunk:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_titan_chunk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_item_titan_chunk:GetModifierStatusResistanceStacking()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("status_resistance")
	end
end
function modifier_item_titan_chunk:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("magic_resistance")
	end
end
function modifier_item_titan_chunk:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("armor")
	end
end