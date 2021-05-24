LinkLuaModifier( "modifier_item_mjz_kaya", "items/item_mjz_kaya", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------

item_mjz_kaya_2 = class({})

function item_mjz_kaya_2:GetIntrinsicModifierName()
	return "modifier_item_mjz_kaya"
end

---------------------------------------------------------------------------------------

item_mjz_kaya_3 = class({})

function item_mjz_kaya_3:GetIntrinsicModifierName()
	return "modifier_item_mjz_kaya"
end

---------------------------------------------------------------------------------------

item_mjz_kaya_4 = class({})

function item_mjz_kaya_4:GetIntrinsicModifierName()
	return "modifier_item_mjz_kaya"
end

---------------------------------------------------------------------------------------

item_mjz_kaya_5 = class({})

function item_mjz_kaya_5:GetIntrinsicModifierName()
	return "modifier_item_mjz_kaya"
end

---------------------------------------------------------------------------------------

if modifier_item_mjz_kaya == nil then modifier_item_mjz_kaya = class({}) end
-- function modifier_item_mjz_kaya:IsPassive() return true end
function modifier_item_mjz_kaya:IsHidden() return true end
function modifier_item_mjz_kaya:IsPurgable() return false end

function modifier_item_mjz_kaya:DeclareFunctions()
	local decFuncs = {
		-- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		-- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        -- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        -- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
	return decFuncs
end

-- function modifier_item_mjz_kaya:GetModifierMoveSpeedBonus_Percentage()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
-- end
-- function modifier_item_mjz_kaya:GetModifierBonusStats_Strength()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_strength")
-- end
-- function modifier_item_mjz_kaya:GetModifierBonusStats_Agility()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_agility")
-- end
function modifier_item_mjz_kaya:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end
-- function modifier_item_mjz_kaya:GetModifierAttackSpeedBonus_Constant()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
-- end
-- function modifier_item_mjz_kaya:GetModifierPhysicalArmorBonus()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_armor")
-- end
function modifier_item_mjz_kaya:GetModifierPercentageManacost()
	return self:GetAbility():GetSpecialValueFor("manacost_reduction")
end

function modifier_item_mjz_kaya:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp")
end