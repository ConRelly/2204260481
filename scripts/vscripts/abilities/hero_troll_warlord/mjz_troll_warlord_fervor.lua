LinkLuaModifier("modifier_mjz_troll_warlord_fervor","abilities/hero_troll_warlord/mjz_troll_warlord_fervor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_troll_warlord_fervor_stack","abilities/hero_troll_warlord/mjz_troll_warlord_fervor.lua", LUA_MODIFIER_MOTION_NONE)

mjz_troll_warlord_fervor = class({})
local ability_class = mjz_troll_warlord_fervor

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_troll_warlord_fervor"
end

---------------------------------------------------------------------------------------

modifier_mjz_troll_warlord_fervor = class({})
local modifier_class = modifier_mjz_troll_warlord_fervor

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK,
		}
		return funcs
	end

	function modifier_class:OnAttack(keys )
		if keys.attacker ~= self:GetParent() then return nil end
		
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local max_stacks = GetTalentSpecialValueFor(ability, 'max_stacks')
		local attacker = keys.attacker
		local target = keys.target
		local modifier_name = 'modifier_mjz_troll_warlord_fervor_stack'
		local stk_chance = ability:GetSpecialValueFor("stack_chance")

		if caster:PassivesDisabled() then return nil end

		if ability.fervor_target then
			local modifier = caster:FindModifierByName(modifier_name)
			if modifier == nil then
				caster:AddNewModifier(caster, ability, modifier_name, {})
				modifier = caster:FindModifierByName(modifier_name)
			end
			local stack_count = modifier:GetStackCount()

			if ability.fervor_target == target then
				if stack_count < max_stacks then
					if RandomInt( 0,100 ) < stk_chance then
						modifier:SetStackCount(stack_count + 1)
					end	
				end
			else
				local new_stack_count = math.floor( stack_count / 2 ) or 0
				if new_stack_count <= 0 then
					caster:RemoveModifierByName(modifier_name)
				else
					modifier:SetStackCount(new_stack_count)
				end
			end
		end
		ability.fervor_target = target
	end

end

function modifier_class:OnDestroy()
	local modifier_name = 'modifier_mjz_troll_warlord_fervor_stack'
	if IsServer() then
		if self and not self:IsNull() then
			if self:GetParent() and not self:GetParent():IsNull() then
				if self:GetParent():HasModifier(modifier_name) then
					self:GetParent():RemoveModifierByName(modifier_name)
				end	
			end	
		end	
	end	
end
---------------------------------------------------------------------------------------

modifier_mjz_troll_warlord_fervor_stack = class({})
local modifier_stack = modifier_mjz_troll_warlord_fervor_stack

function modifier_stack:IsHidden() return false end
function modifier_stack:IsPurgable() return false end
function modifier_stack:IsBuff() return true end

function modifier_stack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
	return funcs
end

function modifier_stack:GetModifierBonusStats_Agility(  )
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor('bonus_agi') * self:GetStackCount()
	end	
end
function modifier_stack:GetModifierHealthBonus(  )
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor('bonus_hp') * self:GetStackCount()
	end	
end
function modifier_stack:GetModifierManaBonus(  )
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor('bonus_mana') * self:GetStackCount()
	end	
end
function modifier_stack:GetModifierAttackRangeBonus(  )
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor('bonus_range') * self:GetStackCount()
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