LinkLuaModifier("modifier_mjz_vengefulspirit_vengeance","abilities/hero_vengefulspirit/mjz_vengefulspirit_vengeance.lua", LUA_MODIFIER_MOTION_NONE)

mjz_vengefulspirit_vengeance = class({})
local ability_class = mjz_vengefulspirit_vengeance

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_vengefulspirit_vengeance"
end

---------------------------------------------------------------------------------------

modifier_mjz_vengefulspirit_vengeance = class({})
local modifier_class = modifier_mjz_vengefulspirit_vengeance

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function modifier_class:GetModifierBaseAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor('bonus_damage')
end

function modifier_class:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_class:GetModifierAttackRangeBonus()
	if self:GetAbility() then
        local attack_range = self:GetAbility():GetSpecialValueFor("bonus_attack_range")
        if self:GetParent():IsRangedAttacker() then
            return attack_range
        else
            return attack_range / 2
        end
	end 
end



-----------------------------------------------------------------------------------------

-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end