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