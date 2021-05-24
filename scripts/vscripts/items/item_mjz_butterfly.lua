
LinkLuaModifier('modifier_item_mjz_butterfly', "items/item_mjz_butterfly.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_item_mjz_butterfly_evasion', "items/item_mjz_butterfly.lua", LUA_MODIFIER_MOTION_NONE)
local MODIFIIER_BUTTERFLY_NAME = 'modifier_item_mjz_butterfly'
local MODIFIIER_BUTTERFLY_EVASION_NAME = 'modifier_item_mjz_butterfly_evasion'

----------------------------------------------------------

item_mjz_butterfly_green_2 = class({})
function item_mjz_butterfly_green_2:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_green_3 = class({})
function item_mjz_butterfly_green_3:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_green_4 = class({})
function item_mjz_butterfly_green_4:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_green_5 = class({})
function item_mjz_butterfly_green_5:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

----------------------------------------------------------

item_mjz_butterfly_red_1 = class({})
function item_mjz_butterfly_red_1:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_red_2 = class({})
function item_mjz_butterfly_red_2:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_red_3 = class({})
function item_mjz_butterfly_red_3:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_red_4 = class({})
function item_mjz_butterfly_red_4:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_red_5 = class({})
function item_mjz_butterfly_red_5:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

----------------------------------------------------------

item_mjz_butterfly_blue_1 = class({})
function item_mjz_butterfly_blue_1:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_blue_2 = class({})
function item_mjz_butterfly_blue_2:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_blue_3 = class({})
function item_mjz_butterfly_blue_3:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_blue_4 = class({})
function item_mjz_butterfly_blue_4:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

item_mjz_butterfly_blue_5 = class({})
function item_mjz_butterfly_blue_5:GetIntrinsicModifierName()
    return MODIFIIER_BUTTERFLY_NAME
end

----------------------------------------------------------------------------------------

modifier_item_mjz_butterfly = class({})
modifier_class = modifier_item_mjz_butterfly

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_class:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end
function modifier_class:GetModifierBonusStats_Strength( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_strength" )
end
function modifier_class:GetModifierBonusStats_Agility( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_agility" )
end
function modifier_class:GetModifierBonusStats_Intellect( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end
function modifier_class:GetModifierPreAttack_BonusDamage( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end
function modifier_class:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

if IsServer() then
    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, ability, MODIFIIER_BUTTERFLY_EVASION_NAME, {})

        self:StartIntervalThink(1.0)
    end

    function modifier_class:OnIntervalThink()
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        if not caster:HasModifier(MODIFIIER_BUTTERFLY_EVASION_NAME) then
            caster:AddNewModifier(caster, ability, MODIFIIER_BUTTERFLY_EVASION_NAME, {})
        end

        self:StartIntervalThink(-1)
    end

    function modifier_class:OnDestroy()
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        caster:RemoveModifierByName(MODIFIIER_BUTTERFLY_EVASION_NAME)
    end
end

----------------------------------------------------------------------------------------

modifier_item_mjz_butterfly_evasion = class({})
modifier_evasion = modifier_item_mjz_butterfly_evasion

function modifier_evasion:IsHidden() return true end
function modifier_evasion:IsPurgable() return false end

function modifier_evasion:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
	return funcs
end
function modifier_evasion:GetModifierEvasion_Constant( params )
    if self:GetParent():HasModifier('modifier_item_butterfly') then
        return 0
    end
	return self:GetAbility():GetSpecialValueFor( "bonus_evasion" )
end