LinkLuaModifier("modifier_custom_special_bonus_attributes", "abilities/custom_special_bonus_attributes", LUA_MODIFIER_MOTION_NONE)

special_bonus_attributes = class({})
function special_bonus_attributes:GetIntrinsicModifierName() return "modifier_custom_special_bonus_attributes" end

modifier_custom_special_bonus_attributes = class({})
function modifier_custom_special_bonus_attributes:IsHidden() return true end
function modifier_custom_special_bonus_attributes:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_custom_special_bonus_attributes:GetModifierBonusStats_Intellect() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_attributes") end end
function modifier_custom_special_bonus_attributes:GetModifierBonusStats_Agility() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_attributes") end end
function modifier_custom_special_bonus_attributes:GetModifierBonusStats_Strength() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_attributes") end end
