
local THIS_LUA = "abilities/hero_storm_spirit/mjz_storm_spirit_overload.lua"
LinkLuaModifier('modifier_mjz_storm_spirit_overload', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_storm_spirit_overload_aura', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_storm_spirit_overload_buff', THIS_LUA, LUA_MODIFIER_MOTION_NONE)

local MODIFIER_BALL_BUFF = 'modifier_mjz_storm_spirit_ball_lightning_buff'
local MODIFIER_OVERLOAD_BUFF = 'modifier_mjz_storm_spirit_overload_buff'
local MODIFIER_OVERLOAD_DEBUFF = 'modifier_mjz_storm_spirit_overload_debuff'
----------------------------------------------------------------------------

mjz_storm_spirit_overload = class({})

function mjz_storm_spirit_overload:GetIntrinsicModifierName()
	return 'modifier_mjz_storm_spirit_overload'
end

-- function mjz_storm_spirit_overload:OnSpellStart()
-- 	if IsServer() then
-- 		local caster = self:GetCaster()
-- 		local ability = self

-- 	end
-- end

----------------------------------------------------------------------------

modifier_mjz_storm_spirit_overload = class({})

function modifier_mjz_storm_spirit_overload:IsPassive()
	return true
end
function modifier_mjz_storm_spirit_overload:IsPurgable()
	return false
end
function modifier_mjz_storm_spirit_overload:IsHidden()
	return true
end
function modifier_mjz_storm_spirit_overload:RemoveOnDeath()
	return false
end

if IsServer() then
	function modifier_mjz_storm_spirit_overload:DeclareFunctions(  )
		return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
	end
	
	function modifier_mjz_storm_spirit_overload:OnAbilityExecuted( params )
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local hAbility = params.ability
		if params.unit == caster then 
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			if hAbility ~= nil and ( not hAbility:IsItem() ) and ( not hAbility:IsToggle() ) then
				local ability_count = caster:GetAbilityCount()
				for i = 0, (ability_count - 1) do
					local ability_at_slot = caster:GetAbilityByIndex( i )
					if ability_at_slot and ability_at_slot:GetAbilityName() == hAbility:GetAbilityName() then
						self:AddBuff()
						break
					end
				end
			end
		end
		return 0
	end

	function modifier_mjz_storm_spirit_overload:OnCreated(table)
		local caster = self:GetCaster()
		self:StartIntervalThink(1.0)
	end

	function modifier_mjz_storm_spirit_overload:AddBuff( )
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if not caster:HasModifier(MODIFIER_OVERLOAD_BUFF) then
			parent:AddNewModifier(caster, ability, MODIFIER_OVERLOAD_BUFF, {})
		end
	end

	function modifier_mjz_storm_spirit_overload:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		if caster:HasModifier(MODIFIER_BALL_BUFF) then
			if not caster:HasModifier(MODIFIER_OVERLOAD_BUFF) then
				self:AddBuff()
			end
		end
	end
end

----------------------------------------------------------------------------

modifier_mjz_storm_spirit_overload_buff = class({})

function modifier_mjz_storm_spirit_overload_buff:IsPurgable()
	return false
end
function modifier_mjz_storm_spirit_overload_buff:IsHidden()
	return false
end

if IsServer() then
	function modifier_mjz_storm_spirit_overload_buff:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ATTACKED,
		}
	end

	function modifier_mjz_storm_spirit_overload_buff:OnCreated( ... )
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.id0 = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(self.id0, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), false)
		
	end

	function modifier_mjz_storm_spirit_overload_buff:OnDestroy(  )
		ParticleManager:DestroyParticle(self.id0, false)
	end

	function modifier_mjz_storm_spirit_overload_buff:OnAttacked(event)
		local target = event.target
		local attacker = event.attacker
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		if attacker ~= parent then return nil end
		if attacker:GetTeamNumber() == target:GetTeamNumber() then return nil end
		if parent:IsIllusion() then return nil end
		if caster:IsIllusion() then return nil end
		-- if caster:PassivesDisabled() then return nil end

		--target:EmitSound("Hero_StormSpirit.Overload")
		local id0 = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_ABSORIGIN, target)
		
		local radius = GetTalentSpecialValueFor(ability, 'overload_aoe')
		local slow_duration = GetTalentSpecialValueFor(ability, 'slow_duration')
		local base_damage = GetTalentSpecialValueFor(ability, 'overload_damage')
		local intelligence_damage = GetTalentSpecialValueFor(ability, 'intelligence_damage')
		local damage = base_damage + caster:GetIntellect() * intelligence_damage / 100

		local damageTable = {
			victim = nil,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability,
		}
		local unit_list = FindUnitsInRadius(
			caster:GetTeamNumber(), target:GetAbsOrigin(),
			nil, radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false
        )
        for _,unit in pairs(unit_list) do
			if unit then
				if not unit:IsMagicImmune() then
					unit:AddNewModifier(caster, ability, MODIFIER_OVERLOAD_DEBUFF, {duration = slow_duration})
					damageTable.victim = unit
					ApplyDamage(damageTable)
				end
            end
		end

		if not parent:HasModifier(MODIFIER_BALL_BUFF) then
			parent:RemoveModifierByName(MODIFIER_OVERLOAD_BUFF)
		end
	end

end

-----------------------------------------------------------------------------------------

if modifier_mjz_storm_spirit_overload_debuff == nil then 
	modifier_mjz_storm_spirit_overload_debuff = class({}) 
end

function modifier_mjz_storm_spirit_overload_debuff:IsDebuff() return true end
function modifier_mjz_storm_spirit_overload_debuff:IsPurgable() return true end
function modifier_mjz_storm_spirit_overload_debuff:IsHidden() return false end

function modifier_mjz_storm_spirit_overload_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_mjz_storm_spirit_overload_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("overload_move_slow")
end

function modifier_mjz_storm_spirit_overload_debuff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("overload_attack_slow")
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
