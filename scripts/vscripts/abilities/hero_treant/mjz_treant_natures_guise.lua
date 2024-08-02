LinkLuaModifier("modifier_mjz_treant_natures_guise","abilities/hero_treant/mjz_treant_natures_guise.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_treant_natures_guise_health","abilities/hero_treant/mjz_treant_natures_guise.lua", LUA_MODIFIER_MOTION_NONE)

mjz_treant_natures_guise = class({})
local ability_class = mjz_treant_natures_guise

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_treant_natures_guise"
end

---------------------------------------------------------------------------------------

modifier_mjz_treant_natures_guise = class({})
local modifier_class = modifier_mjz_treant_natures_guise

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:IsPermanent() return true end

function modifier_class:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_class:GetModifierConstantHealthRegen( )
	if self:GetAbility() then
		local lvl = 1 + (self:GetCaster():GetLevel() * (self:GetAbility():GetSpecialValueFor('bonus_lvl_ptc') /100 ))
		return self:GetAbility():GetSpecialValueFor('health_regen') * lvl
 	end
end

function modifier_class:GetModifierMoveSpeedBonus_Percentage( )
	if self:GetAbility() then
		local lvl = 1 + (self:GetCaster():GetLevel() * (self:GetAbility():GetSpecialValueFor('bonus_lvl_ptc') /100 ))	
		return self:GetAbility():GetSpecialValueFor('movement_speed') * lvl
	end	
end

if IsServer() then
	function modifier_class:OnCreated(table)
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), 'modifier_mjz_treant_natures_guise_health', {})
	end

	function modifier_class:OnDestroy()
		self:GetParent():RemoveModifierByName('modifier_mjz_treant_natures_guise_health')
	end
end

-----------------------------------------------------------------------------------------


modifier_mjz_treant_natures_guise_health = class({})
local modifier_health = modifier_mjz_treant_natures_guise_health

function modifier_health:IsPassive() return true end
function modifier_health:IsHidden() return true end
function modifier_health:IsPurgable() return false end
function modifier_health:RemoveOnDeath() return false end

function modifier_health:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,							-- 修改目前血量
	}
	return funcs
end

function modifier_health:GetModifierHealthBonus( )
	if IsServer() then
		local lvl = 1 + (self:GetCaster():GetLevel() * (self:GetAbility():GetSpecialValueFor('bonus_lvl_ptc') /100 ))
		local health = GetTalentSpecialValueFor(self:GetAbility(), 'health') * lvl

		if self:GetStackCount() ~= health then
			self:SetStackCount(health)
		end
	end
	return self:GetStackCount()
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