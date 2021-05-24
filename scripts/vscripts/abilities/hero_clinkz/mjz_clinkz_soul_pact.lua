local THIS_LUA = "abilities/hero_clinkz/mjz_clinkz_soul_pact.lua"
LinkLuaModifier("modifier_mjz_clinkz_soul_pact", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_soul_pact_health", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_soul_pact_permanent_buff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_soul_pact_debuff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_soul_pact_enemy", THIS_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_clinkz_soul_pact = mjz_clinkz_soul_pact or class({}) 
local ability_class = mjz_clinkz_soul_pact


function ability_class:OnSpellStart( )
	if not IsServer() then return end

	local ability = self
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = ability:GetSpecialValueFor('duration')

	local modifier_name = 'modifier_mjz_clinkz_soul_pact'
	local modifier = caster:FindModifierByName(modifier_name)
	if modifier then
		modifier:SetDuration(duration, true)
		modifier:ForceRefresh()
	else
		caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
	end

	local permanent_bonus = self:GetSpecialValueFor( "permanent_bonus" )
	local modifier_stack_name = "modifier_mjz_clinkz_soul_pact_permanent_buff"
	if not caster:HasModifier(modifier_stack_name) then
		caster:AddNewModifier(caster, ability, modifier_stack_name, {})
	end
	local hBuff = caster:FindModifierByName(modifier_stack_name)
	if hBuff then
		hBuff:SetStackCount( hBuff:GetStackCount() + permanent_bonus )
		caster:CalculateStatBonus()
	end

	caster:EmitSound("Hero_Clinkz.DeathPact.Cast")
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf", PATTACH_POINT_FOLLOW, caster)
                ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(nfx, 5, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(nfx)


end

function ability_class:OnEnemyDied( hVictim, hKiller, kv )
	if hVictim == nil or hKiller == nil or hVictim:IsIllusion()  then
		return
	end
	if hVictim:GetTeamNumber() == self:GetCaster():GetTeamNumber()then
		return 
	end

	local ability = self
	local caster = self:GetCaster()

	if not ability:IsCooldownReady() then
		if hVictim:IsRealHero() then
			ability:EndCooldown()
		else
			local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce")
			local flCooldown = ability:GetCooldownTimeRemaining() - cooldown_reduce
			ability:EndCooldown()
			ability:StartCooldown(flCooldown)
		end
	end
end

function ability_class:TargetIsEnemy( target )
	local caster = self:GetCaster()
	local ability = self
	local nTargetTeam = ability:GetAbilityTargetTeam()
	local nTargetType = ability:GetAbilityTargetType()
	local nTargetFlags = ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact = class({})
local modifier_class = modifier_mjz_clinkz_soul_pact

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		-- MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,			-- 按百分比修改攻击力，负数降低攻击，正数提高攻击
		-- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,					-- 增加护甲
		MODIFIER_PROPERTY_MODEL_SCALE,							-- 设定模型大小
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

-- function modifier_class:GetModifierDamageOutgoing_Percentage( )
-- 	return self:GetAbility():GetSpecialValueFor('bonus_damage_pct')
-- end
-- function modifier_class:GetModifierPhysicalArmorBonus( )
-- 	return self:GetAbility():GetSpecialValueFor('armor_reduction')
-- end

function modifier_class:GetModifierModelScale( )
	return self:GetAbility():GetSpecialValueFor('model_scale')
end

if IsServer() then
	function modifier_class:OnAttackLanded(keys)
		if keys.attacker ~= self:GetParent() then return end

		local caster = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
		local target = keys.target

		if target and IsValidEntity(target) and target:IsAlive() then
			if ability:TargetIsEnemy(target) then
				local modifier_enemy = "modifier_mjz_clinkz_soul_pact_enemy"
				local modifier_debuff = "modifier_mjz_clinkz_soul_pact_debuff"
				local debuff_duration = ability:GetSpecialValueFor("debuff_duration")
				target:AddNewModifier(caster, ability, modifier_enemy, { duration = debuff_duration})
				target:AddNewModifier(caster, ability, modifier_debuff, { duration = debuff_duration})
			end
		end
	end

	function modifier_class:OnCreated(table)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.m_health_name = "modifier_mjz_clinkz_soul_pact_health"
		self:OnRefresh()
	end

	function modifier_class:OnRefresh(table)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not caster:HasModifier(self.m_health_name) then
			caster:AddNewModifier(caster, ability, self.m_health_name, {})
		end
		local m_health = caster:FindModifierByName(self.m_health_name)
		if m_health then
			local health_gain = GetTalentSpecialValueFor(ability, "health_gain")
			if m_health:GetStackCount() ~= health_gain then
				m_health:SetStackCount(health_gain)
			end

			Timers:CreateTimer(0.1, function( )
				caster:Heal(health_gain, ability)
			end)

			local duration = ability:GetSpecialValueFor("duration")
			m_health:SetDuration(duration, true)
			m_health:ForceRefresh()
		end

	end

	function modifier_class:OnDestroy(table)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if caster and IsValidEntity(caster) then
			caster:RemoveModifierByName( self.m_health_name )
		end
	end
end


---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact_enemy = class({})

function modifier_mjz_clinkz_soul_pact_enemy:IsHidden() return true end
function modifier_mjz_clinkz_soul_pact_enemy:IsPurgable() return false end

if IsServer() then 
	function modifier_mjz_clinkz_soul_pact_enemy:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_DEATH, -- OnDeath
		}
		return funcs
	end

	function modifier_mjz_clinkz_soul_pact_enemy:OnDeath(event)
		if event.unit ~= self:GetParent() then return end

		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local hVictim = event.unit
		local hKiller = event.attacker
		ability:OnEnemyDied(hVictim, hKiller, event)
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact_health = class({})

function modifier_mjz_clinkz_soul_pact_health:IsHidden() return false end
function modifier_mjz_clinkz_soul_pact_health:IsPurgable() return false end

function modifier_mjz_clinkz_soul_pact_health:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,	-- GetModifierExtraHealthBonus
		MODIFIER_PROPERTY_TOOLTIP,	-- OnTooltip
	}
	return funcs
end

function modifier_mjz_clinkz_soul_pact_health:GetModifierExtraHealthBonus( )
	return self:GetStackCount() or 0
end
function modifier_mjz_clinkz_soul_pact_health:OnTooltip()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("armor_reduction")
	end
	return 0
end


---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact_permanent_buff = class({})

function modifier_mjz_clinkz_soul_pact_permanent_buff:IsHidden() return false end
function modifier_mjz_clinkz_soul_pact_permanent_buff:IsPurgable() return false end
function modifier_mjz_clinkz_soul_pact_permanent_buff:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end
function modifier_mjz_clinkz_soul_pact_permanent_buff:DeclareFunctions()
	local funcs = {
		-- MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,	-- GetModifierPreAttack_BonusDamage
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,	-- GetModifierBaseAttack_BonusDamage
	}
	return funcs
end
-- function modifier_mjz_clinkz_soul_pact_permanent_buff:GetModifierPreAttack_BonusDamage( )
-- 	return self:GetStackCount()
-- end
function modifier_mjz_clinkz_soul_pact_permanent_buff:GetModifierBaseAttack_BonusDamage( )
	return self:GetStackCount()
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact_debuff = class({})

function modifier_mjz_clinkz_soul_pact_debuff:IsHidden() return false end
function modifier_mjz_clinkz_soul_pact_debuff:IsPurgable() return false end

function modifier_mjz_clinkz_soul_pact_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,	-- GetModifierPhysicalArmorBonus
	}
	return funcs
end
function modifier_mjz_clinkz_soul_pact_debuff:GetModifierPhysicalArmorBonus( )
	if self:GetAbility() then
		local armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction")
		if armor_reduction > 0 then
			return 0 - armor_reduction
		else
			return armor_reduction
		end
	end
	return 0
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