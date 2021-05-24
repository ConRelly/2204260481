
local THIS_LUA = "abilities/hero_faceless_void/mjz_faceless_time_dilation.lua"

local MODIFIER_SLOW_NAME = 'modifier_mjz_faceless_time_dilation_slow'
-- local MODIFIER_ATTACK_SPEED_NAME = 'modifier_mjz_faceless_time_dilation_attack_speed'

LinkLuaModifier(MODIFIER_SLOW_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier(MODIFIER_ATTACK_SPEED_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

mjz_faceless_time_dilation = class({})
local ability_class = mjz_faceless_time_dilation

function ability_class:GetAOERadius()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor('radius')
	return radius
end

if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local radius = ability:GetSpecialValueFor('radius')
		local duration = ability:GetSpecialValueFor('duration')
		
		EmitSoundOn("Hero_FacelessVoid.TimeDilation.Cast", caster)

		local p_name = "particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf"
		local p_index = ParticleManager:CreateParticle(p_name, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(p_index, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(p_index, 1, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(p_index)

		local unit_list = FindUnitsInRadius(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil, radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false
        )
        
        for _,unit in pairs(unit_list) do
			if unit then
				EmitSoundOn("Hero_FacelessVoid.TimeDilation.Target", unit)	
				unit:AddNewModifier(caster, ability, MODIFIER_SLOW_NAME, {duration = duration})
            end
        end
	end

end

----------------------------------------------------------------------

modifier_mjz_faceless_time_dilation_slow = class({})

function modifier_mjz_faceless_time_dilation_slow:IsDebuff() return true end
function modifier_mjz_faceless_time_dilation_slow:IsHidden() return false end
function modifier_mjz_faceless_time_dilation_slow:IsPurgable() return true end

function modifier_mjz_faceless_time_dilation_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_mjz_faceless_time_dilation_slow:GetModifierMoveSpeedBonus_Percentage( )
	return self:GetAbility():GetSpecialValueFor('move_speed_slow')
end

function modifier_mjz_faceless_time_dilation_slow:GetModifierAttackSpeedBonus_Constant( )
	return self:GetAbility():GetSpecialValueFor('attack_speed_slow')
end


if IsServer() then
	--[[
	function modifier_mjz_faceless_time_dilation_slow:OnCreated(table)
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local slow = ability:GetSpecialValueFor('slow')
		local duration = ability:GetSpecialValueFor('duration')
		parent:AddNewModifier(caster, ability, MODIFIER_ATTACK_SPEED_NAME, {duration = duration})
	end
	]]
end

----------------------------------------------------------------------

modifier_mjz_faceless_time_dilation_attack_speed = class({})

function modifier_mjz_faceless_time_dilation_attack_speed:IsDebuff() return true end
function modifier_mjz_faceless_time_dilation_attack_speed:IsHidden() return true end
function modifier_mjz_faceless_time_dilation_attack_speed:IsPurgable() return true end

function modifier_mjz_faceless_time_dilation_attack_speed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_mjz_faceless_time_dilation_attack_speed:GetModifierAttackSpeedBonus_Constant( )
	return self:GetStackCount()
end

if IsServer() then
	function modifier_mjz_faceless_time_dilation_attack_speed:OnCreated(table)
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local slow = ability:GetSpecialValueFor('slow')
		local attack_speed = parent:GetAttackSpeed() * (slow / 100.0)
		parent:SetStackCount(attack_speed)
	end
end


----------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end

function HasTalentBy(ability, value)
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
        return talent and talent:GetLevel() > 0 
    end
    return false
end


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
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or 'value'
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end
