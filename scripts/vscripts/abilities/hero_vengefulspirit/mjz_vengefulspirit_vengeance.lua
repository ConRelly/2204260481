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
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end

function modifier_class:GetModifierPreAttack_BonusDamage( )
	return self:GetAbility():GetSpecialValueFor('bonus_damage')
end

function modifier_class:GetModifierAttackSpeedBonus_Constant( )
	return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_class:GetModifierAttackRangeBonus( )
	if IsServer() then
		local is_ranged = self:GetParent():IsRangedAttacker()
		if is_ranged then
			if self:GetStackCount() ~= 11 then
				self:SetStackCount(11)
			end
		else
			if self:GetStackCount() ~= 11 then
				self:SetStackCount(11)
			end
		end
	end
	
	if self:GetStackCount() == 11 then
		return self:GetAbility():GetSpecialValueFor('bonus_attack_range')
	else
		return 0		
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