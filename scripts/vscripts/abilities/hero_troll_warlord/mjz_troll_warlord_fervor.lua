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
					modifier:SetStackCount(stack_count + 1)
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

---------------------------------------------------------------------------------------

modifier_mjz_troll_warlord_fervor_stack = class({})
local modifier_stack = modifier_mjz_troll_warlord_fervor_stack

function modifier_stack:IsHidden() return false end
function modifier_stack:IsPurgable() return false end
function modifier_stack:IsBuff() return true end

function modifier_stack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_stack:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor('attack_speed') * self:GetStackCount()
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