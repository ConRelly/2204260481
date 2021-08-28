require("lib/my")
require("lib/popup")

LinkLuaModifier("modifier_item_high_tech_boots2", "items/high_tech_boots2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_high_tech_boots2_active", "items/high_tech_boots2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_high_tech_boots2_effect", "items/high_tech_boots2.lua", LUA_MODIFIER_MOTION_NONE)


item_high_tech_boots2 = class({})
function item_high_tech_boots2:GetIntrinsicModifierName() return "modifier_item_high_tech_boots2" end
function item_high_tech_boots2:OnSpellStart()
    local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_high_tech_boots2_active", {duration = self:GetSpecialValueFor("duration")})
	caster:AddNewModifier(caster, nil, "modifier_item_high_tech_boots2_effect", {duration = 1})
end


modifier_item_high_tech_boots2 = class({})
function modifier_item_high_tech_boots2:IsHidden() return true end
function modifier_item_high_tech_boots2:IsPurgable() return false end
function modifier_item_high_tech_boots2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_high_tech_boots2:CheckState() 
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_UNSLOWABLE] = true}
end
function modifier_item_high_tech_boots2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_TURN_RATE_OVERRIDE,
    }
end
function modifier_item_high_tech_boots2:GetModifierMoveSpeedBonus_Special_Boots()
	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end
function modifier_item_high_tech_boots2:GetModifierEvasion_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_evasion")
end
function modifier_item_high_tech_boots2:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("all_stats")
end
function modifier_item_high_tech_boots2:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("all_stats")
end
function modifier_item_high_tech_boots2:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("all_stats")
end
function modifier_item_high_tech_boots2:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_movement")
end
function modifier_item_high_tech_boots2:GetModifierPreAttack_BonusDamage()
	return self:GetParent():GetIdealSpeed() * self:GetAbility():GetSpecialValueFor("ms_dmg_pct") / 100
end
function modifier_item_high_tech_boots2:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_high_tech_boots2:GetModifierIgnoreMovespeedLimit() return 1 end
function modifier_item_high_tech_boots2:GetModifierTurnRate_Override() return 1 end


modifier_item_high_tech_boots2_active = class({})
function modifier_item_high_tech_boots2_active:IsHidden() return false end
function modifier_item_high_tech_boots2_active:IsPurgable() return false end
function modifier_item_high_tech_boots2_active:GetTexture() return "speedsters" end
function modifier_item_high_tech_boots2_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end
function modifier_item_high_tech_boots2_active:GetModifierTotal_ConstantBlock(keys)
	local parent = self:GetParent()
	local finalBlock = (parent:GetIdealSpeed() * self:GetAbility():GetSpecialValueFor("speed_as_block"))  * 0.01
	parent:AddNewModifier(parent, nil, "modifier_item_high_tech_boots2_effect", {duration = 1})
	return finalBlock
end


modifier_item_high_tech_boots2_effect = class({})
function modifier_item_high_tech_boots2_effect:IsHidden() return true end
function modifier_item_high_tech_boots2_effect:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end
function modifier_item_high_tech_boots2_effect:GetEffectAttachType() return PATTACH_POINT_FOLLOW end
