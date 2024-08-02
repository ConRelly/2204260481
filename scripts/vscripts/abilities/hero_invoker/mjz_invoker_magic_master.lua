LinkLuaModifier("modifier_mjz_invoker_magic_master","abilities/hero_invoker/mjz_invoker_magic_master.lua", LUA_MODIFIER_MOTION_NONE)

mjz_invoker_magic_master = class({})
local ability_class = mjz_invoker_magic_master

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_invoker_magic_master"
end


---------------------------------------------------------------------------------------

modifier_mjz_invoker_magic_master = class({})
local modifier_class = modifier_mjz_invoker_magic_master

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
--		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,			-- 冷却时间减少			
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,		-- 技能增强
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,          -- 魔法消耗和损失降低
	}
	return funcs
end

function modifier_class:GetCustomStackingCDR( )
	if self:GetCaster():HasScepter() then
		return self:GetAbility():GetSpecialValueFor('bonus_cooldown_scepter')
	end
end

function modifier_class:GetModifierSpellAmplify_Percentage( )
	if self:GetCaster():HasScepter() then
		return self:GetAbility():GetSpecialValueFor('spell_amp_scepter')
	end
end

function modifier_class:GetModifierPercentageManacost()
	if self:GetCaster():HasScepter() then
		return self:GetAbility():GetSpecialValueFor('manacost_reduction_scepter')
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