LinkLuaModifier("modifier_mjz_general_megamorph", "abilities/mjz_general/mjz_general_megamorph.lua", LUA_MODIFIER_MOTION_NONE)


mjz_general_megamorph = class({})

function mjz_general_megamorph:GetIntrinsicModifierName()
    return "modifier_mjz_general_megamorph"
end


-----------------------------------------------------------------------------------------

modifier_mjz_general_megamorph = class({})
function modifier_mjz_general_megamorph:IsHidden() return true end
function modifier_mjz_general_megamorph:IsPurgable() return false end

function modifier_mjz_general_megamorph:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,       --GetModifierBaseAttack_BonusDamage
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,							-- 设定模型大小
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,

    } 
end

function modifier_mjz_general_megamorph:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() == nil or not IsValidEntity(self:GetAbility()) then return 0 end
	return self:GetAbility():GetSpecialValueFor('bonus_damage')
end
function modifier_mjz_general_megamorph:GetModifierAttackRangeBonus( )
	if self:GetAbility() == nil or not IsValidEntity(self:GetAbility()) then return 0 end
	return self:GetAbility():GetSpecialValueFor('attack_range')
end

function modifier_mjz_general_megamorph:GetModifierCastRangeBonusStacking()
	if self:GetAbility() == nil or not IsValidEntity(self:GetAbility()) then return 0 end
    return self:GetAbility():GetSpecialValueFor("cast_range")
end

function modifier_mjz_general_megamorph:GetModifierModelScale( )
	if self:GetAbility() == nil or not IsValidEntity(self:GetAbility()) then return 0 end
	return self:GetAbility():GetSpecialValueFor('model_scale')
end
