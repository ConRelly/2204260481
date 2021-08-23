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
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end