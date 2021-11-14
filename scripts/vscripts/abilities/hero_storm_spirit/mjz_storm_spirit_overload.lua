
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
function mjz_storm_spirit_overload:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
	return self.BaseClass.GetBehavior(self)
end
function mjz_storm_spirit_overload:GetCooldown(lvl)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then return self.BaseClass.GetCooldown(self, lvl) end
	return 0
end
function mjz_storm_spirit_overload:GetCastRange(location, target)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then return self:GetSpecialValueFor("shard_radius") end
	return 0
end
function mjz_storm_spirit_overload:GetManaCost(lvl)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then return self.BaseClass.GetManaCost(self, lvl) else return 0 end
end
function mjz_storm_spirit_overload:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local shard_radius = self:GetSpecialValueFor("shard_radius")
		local shard_stacks = self:GetSpecialValueFor("shard_stacks")
		local shard_duration = self:GetSpecialValueFor("shard_duration")
		local shard_search = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, shard_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        for _, ally in pairs(shard_search) do
			local buff = ally:AddNewModifier(caster, self, MODIFIER_OVERLOAD_BUFF, {duration = shard_duration})
			buff:SetStackCount(shard_stacks)
		end
	end
end

----------------------------------------------------------------------------

modifier_mjz_storm_spirit_overload = class({})

function modifier_mjz_storm_spirit_overload:IsPassive() return true end
function modifier_mjz_storm_spirit_overload:IsPurgable() return false end
function modifier_mjz_storm_spirit_overload:IsHidden() return true end
function modifier_mjz_storm_spirit_overload:RemoveOnDeath() return false end
function modifier_mjz_storm_spirit_overload:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

if IsServer() then
	function modifier_mjz_storm_spirit_overload:OnAbilityExecuted( params )
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local hAbility = params.ability
		if params.unit == caster then
			if self:GetParent():PassivesDisabled() then return end
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
		self:StartIntervalThink(FrameTime())
	end

	function modifier_mjz_storm_spirit_overload:AddBuff()
		local caster = self:GetCaster()
		if not caster:HasModifier(MODIFIER_OVERLOAD_BUFF) then
			caster:AddNewModifier(caster, self:GetAbility(), MODIFIER_OVERLOAD_BUFF, {})
		end
	end

	function modifier_mjz_storm_spirit_overload:OnIntervalThink()
		if self:GetCaster():HasModifier(MODIFIER_BALL_BUFF) then
			self:AddBuff()
		end
	end
end

----------------------------------------------------------------------------

modifier_mjz_storm_spirit_overload_buff = class({})

function modifier_mjz_storm_spirit_overload_buff:IsPurgable() return false end
function modifier_mjz_storm_spirit_overload_buff:IsHidden() return false end

function modifier_mjz_storm_spirit_overload_buff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,

		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end

function modifier_mjz_storm_spirit_overload_buff:OnCreated( ... )
	if IsServer() then
		local parent = self:GetParent()
		self.buff_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf", PATTACH_CUSTOMORIGIN, parent)
		ParticleManager:SetParticleControlEnt(self.buff_fx, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), true)
	end
end

function modifier_mjz_storm_spirit_overload_buff:OnAttacked(event)
	if IsServer() then
		local target = event.target
		local attacker = event.attacker
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		if attacker ~= parent then return nil end
		if attacker:GetTeamNumber() == target:GetTeamNumber() then return nil end
		if parent:IsIllusion() then return nil end
		if caster:IsIllusion() then return nil end
		if target:IsBuilding() then return end
		-- if caster:PassivesDisabled() then return nil end

		--target:EmitSound("Hero_StormSpirit.Overload")
		local discharge_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_ABSORIGIN, parent)
		ParticleManager:SetParticleControl(discharge_fx, 0, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(discharge_fx)

		local radius = GetTalentSpecialValueFor(ability, 'overload_aoe')
		local slow_duration = GetTalentSpecialValueFor(ability, 'slow_duration')
		local base_damage = GetTalentSpecialValueFor(ability, 'overload_damage')
		local intelligence_damage = GetTalentSpecialValueFor(ability, 'intelligence_damage')
		local damage = base_damage + caster:GetIntellect() * intelligence_damage / 100

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
					unit:AddNewModifier(parent, ability, MODIFIER_OVERLOAD_DEBUFF, {duration = slow_duration})
					ApplyDamage({
						victim = unit,
						attacker = parent,
						damage = damage,
						damage_type = ability:GetAbilityDamageType(),
						ability = ability,
					})
				end
            end
		end

		local stacks = self:GetStackCount()
		if stacks < 2 then
			parent:RemoveModifierByName(MODIFIER_OVERLOAD_BUFF)
		else
			self:SetStackCount(stacks - 1)
		end
	end
end
function modifier_mjz_storm_spirit_overload_buff:GetActivityTranslationModifiers()
	if self:GetParent():GetName() == "npc_dota_hero_storm_spirit" then return "overload" end
	return 0
end
function modifier_mjz_storm_spirit_overload_buff:GetOverrideAnimation()
	return ACT_STORM_SPIRIT_OVERLOAD_RUN_OVERRIDE
end
function modifier_mjz_storm_spirit_overload_buff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.buff_fx, false)
		ParticleManager:ReleaseParticleIndex(self.buff_fx)
	end
end
function modifier_mjz_storm_spirit_overload_buff:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") and self:GetStackCount() > 0 then return self:GetAbility():GetSpecialValueFor("shard_bonus_as") end
	return 0
end

-----------------------------------------------------------------------------------------

modifier_mjz_storm_spirit_overload_debuff = class({})

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
