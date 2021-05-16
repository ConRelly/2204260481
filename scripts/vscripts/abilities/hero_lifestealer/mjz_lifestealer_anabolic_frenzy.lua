LinkLuaModifier("modifier_mjz_lifestealer_anabolic_frenzy", "abilities/hero_lifestealer/mjz_lifestealer_anabolic_frenzy.lua", LUA_MODIFIER_MOTION_NONE)

mjz_lifestealer_anabolic_frenzy = class({})
local ability_class = mjz_lifestealer_anabolic_frenzy

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_lifestealer_anabolic_frenzy"
end


modifier_mjz_lifestealer_anabolic_frenzy = class({})
local modifier_class = modifier_mjz_lifestealer_anabolic_frenzy

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return false end

function modifier_class:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	} 
end

function modifier_class:GetModifierMoveSpeedBonus_Percentage()	
	if IsServer() then
		self:_UpdateMoveSpeed()
	end
	return self:GetStackCount()
end

function modifier_class:GetModifierAttackSpeedBonus_Constant() 
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") 
end

if IsServer() then
    function modifier_class:OnCreated(table)
        self:_UpdateMoveSpeed()
    end

    function modifier_class:OnRefresh(table)
        self:_UpdateMoveSpeed()
    end

    function modifier_class:_UpdateMoveSpeed()	
        local ability = self:GetAbility()
        local bonus_move_speed_pct = GetTalentSpecialValueFor(ability, 'bonus_move_speed_pct')
        self:SetStackCount(bonus_move_speed_pct)
    end
end


---------------------------------------------------------------------------------------

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