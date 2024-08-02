
LinkLuaModifier('modifier_mjz_sniper_take_aim', "abilities/hero_sniper/mjz_sniper_take_aim.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_sniper_take_aim_bonus', "abilities/hero_sniper/mjz_sniper_take_aim.lua", LUA_MODIFIER_MOTION_NONE)


mjz_sniper_take_aim = mjz_sniper_take_aim or class({})

function mjz_sniper_take_aim:GetIntrinsicModifierName()
	return "modifier_mjz_sniper_take_aim"
end

function mjz_sniper_take_aim:OnToggle()
	if IsServer() then
		
	end
end

----------------------------------------------------------------------------

modifier_mjz_sniper_take_aim = class({})

function modifier_mjz_sniper_take_aim:IsPurgable()
	return false
end
function modifier_mjz_sniper_take_aim:IsHidden()
	return not self:GetAbility():GetToggleState()
end
-- 效果永久，死亡不消失
-- function modifier_mjz_sniper_take_aim:GetAttributes() 
-- 	return MODIFIER_ATTRIBUTE_PERMANENT 
-- end

function modifier_mjz_sniper_take_aim:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_mjz_sniper_take_aim:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility():GetToggleState() then
		return self:GetAbility():GetSpecialValueFor("move_slow_pct")
	end
end


if IsServer() then
	function modifier_mjz_sniper_take_aim:OnCreated(table)
		self:StartIntervalThink(0.1)
	end

	function modifier_mjz_sniper_take_aim:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local bonus_attack_range = GetTalentSpecialValueFor(ability, "bonus_attack_range"  )
		local active_attack_range_multiplier = GetTalentSpecialValueFor(ability, "active_attack_range_multiplier"  )
		local mName = "modifier_mjz_sniper_take_aim_bonus"

		local bonus = bonus_attack_range
		if ability:GetToggleState() then
			bonus = bonus_attack_range * active_attack_range_multiplier
		end

		local modiifer = caster:FindModifierByName(mName)
		if modiifer == nil then
			if caster:IsAlive() then
				modiifer = caster:AddNewModifier(caster, ability, mName, {})
			end	
		end
		if modiifer then
			if modiifer:GetStackCount() ~= bonus then
				modiifer:SetStackCount(bonus)
			end
		end	

	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_sniper_take_aim_bonus = class({})
function modifier_mjz_sniper_take_aim_bonus:IsPurgable() return false end
function modifier_mjz_sniper_take_aim_bonus:IsHidden() return true end

function modifier_mjz_sniper_take_aim_bonus:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end

function modifier_mjz_sniper_take_aim_bonus:GetModifierAttackRangeBonus(  )
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


-- 是否学习了天赋技能
function HasTalentSpecialValueFor(ability, value)
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
		return talent and talent:GetLevel() > 0 
    end
    return false
end
