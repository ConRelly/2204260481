LinkLuaModifier( "modifier_item_mjz_kaya", "items/item_mjz_kaya", LUA_MODIFIER_MOTION_NONE )

item_mjz_kaya_2 = class({})
item_mjz_kaya_3 = class({})
item_mjz_kaya_4 = class({})
item_mjz_kaya_5 = class({})
function item_mjz_kaya_2:GetIntrinsicModifierName() return "modifier_item_mjz_kaya" end
function item_mjz_kaya_3:GetIntrinsicModifierName() return "modifier_item_mjz_kaya" end
function item_mjz_kaya_4:GetIntrinsicModifierName() return "modifier_item_mjz_kaya" end
function item_mjz_kaya_5:GetIntrinsicModifierName() return "modifier_item_mjz_kaya" end

---------------------------------------------------------------------------------------
if modifier_item_mjz_kaya == nil then modifier_item_mjz_kaya = class({}) end
function modifier_item_mjz_kaya:IsHidden() return true end
function modifier_item_mjz_kaya:IsPurgable() return false end
function modifier_item_mjz_kaya:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_item_mjz_kaya:GetModifierBonusStats_Intellect() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_intellect") end end
function modifier_item_mjz_kaya:GetModifierMPRegenAmplify_Percentage() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_multiplier") end end
function modifier_item_mjz_kaya:GetModifierSpellLifestealRegenAmplify_Percentage() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_lifesteal_amp") end end
function modifier_item_mjz_kaya:GetModifierSpellAmplify_Percentage() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_amp") end end