local THIS_LUA = "abilities/hero_clinkz/mjz_clinkz_soul_pact.lua"
LinkLuaModifier("modifier_mjz_clinkz_soul_pact", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_soul_pact_permanent_buff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_soul_pact_debuff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_mjz_clinkz_soul_pact_invis", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_soul_pact_strafe", THIS_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_clinkz_soul_pact = mjz_clinkz_soul_pact or class({})
function mjz_clinkz_soul_pact:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	local buff_modifier = "modifier_mjz_clinkz_soul_pact"
	local modifier = caster:FindModifierByName(buff_modifier)
	if modifier then
		modifier:SetDuration(duration, true)
		modifier:ForceRefresh()
	else
		caster:AddNewModifier(caster, self, buff_modifier, {duration = duration})
	end
	if caster:HasShard() then
		caster:AddNewModifier(caster, self, "modifier_mjz_clinkz_soul_pact_invis", {duration = duration})
		local invis_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(invis_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(invis_pfx)
	end

	local permanent_bonus = self:GetTalentSpecialValueFor("permanent_bonus")
	local modifier_stack_name = "modifier_mjz_clinkz_soul_pact_permanent_buff"
	if not caster:HasModifier(modifier_stack_name) then
		caster:AddNewModifier(caster, self, modifier_stack_name, {})
	end
	local hBuff = caster:FindModifierByName(modifier_stack_name)
	if hBuff then
		hBuff:SetStackCount(hBuff:GetStackCount() + permanent_bonus)
		caster:CalculateStatBonus(false)
	end

	caster:EmitSound("Hero_Clinkz.DeathPact.Cast")
	local particle_pact_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle_pact_fx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_pact_fx, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_pact_fx, 5, target:GetAbsOrigin())
end
function mjz_clinkz_soul_pact:OnEnemyDied(hVictim, hKiller, kv)
	local caster = self:GetCaster()

	if hVictim == nil or hKiller == nil or hVictim:IsIllusion() then return end
	if hVictim:GetTeamNumber() == caster:GetTeamNumber()then return end

	if not self:IsCooldownReady() then
		if hVictim:IsRealHero() then
			self:EndCooldown()
		else
			local cooldown_reduce = self:GetSpecialValueFor("cooldown_reduce")
			local flCooldown = self:GetCooldownTimeRemaining() - cooldown_reduce
			self:EndCooldown()
			self:StartCooldown(flCooldown)
		end
	end
end
function mjz_clinkz_soul_pact:TargetIsEnemy(target)
	local caster = self:GetCaster()
	local nTargetTeam = self:GetAbilityTargetTeam()
	local nTargetType = self:GetAbilityTargetType()
	local nTargetFlags = self:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact = class({})
function modifier_mjz_clinkz_soul_pact:IsHidden() return false end
function modifier_mjz_clinkz_soul_pact:IsPurgable() return false end
function modifier_mjz_clinkz_soul_pact:OnCreated()
	self.model_scale = self:GetAbility():GetSpecialValueFor("model_scale")
	self.bonus_damage_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health") + talent_value(self:GetCaster(), "special_bonus_unique_clinkz_6")
	self.self_armor = self:GetAbility():GetSpecialValueFor("self_armor")
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction")
	if IsServer() then
		Timers:CreateTimer(FrameTime(), function()
			self:GetParent():SetHealth(self:GetParent():GetHealth() + self.bonus_health)
		end)
	end
end
function modifier_mjz_clinkz_soul_pact:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,

		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_mjz_clinkz_soul_pact:GetModifierModelScale()
	return self.model_scale
end
function modifier_mjz_clinkz_soul_pact:GetModifierDamageOutgoing_Percentage()
	return self.bonus_damage_pct
end
function modifier_mjz_clinkz_soul_pact:GetModifierExtraHealthBonus()
	return self.bonus_health
end
function modifier_mjz_clinkz_soul_pact:GetModifierPhysicalArmorBonus()
	return self.self_armor
end
function modifier_mjz_clinkz_soul_pact:OnAttackLanded(keys)
	if IsServer() then
		if keys.attacker ~= self:GetParent() then return end

		local caster = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
		local target = keys.target

		if target and IsValidEntity(target) and target:IsAlive() then
			if ability:TargetIsEnemy(target) then
				local modifier_debuff = "modifier_mjz_clinkz_soul_pact_debuff"
				local debuff_duration = ability:GetSpecialValueFor("debuff_duration")
				target:AddNewModifier(caster, ability, modifier_debuff, {duration = debuff_duration})
			end
		end
	end
end
function modifier_mjz_clinkz_soul_pact:OnRefresh()
	if IsServer() then
		if self:GetParent():HasScepter() then
			local duration = self:GetAbility():GetSpecialValueFor("attack_speed_duration") + talent_value(self:GetCaster(), "special_bonus_unique_clinkz_2")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_clinkz_soul_pact_strafe", {duration = duration})
		end
		self:OnCreated()
	end
end
function modifier_mjz_clinkz_soul_pact:OnDestroy()
	if IsServer() then
		if self:GetParent():HasScepter() then
			local duration = self:GetAbility():GetSpecialValueFor("attack_speed_duration") + talent_value(self:GetCaster(), "special_bonus_unique_clinkz_2")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_clinkz_soul_pact_strafe", {duration = duration})
		end
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact_permanent_buff = class({})
function modifier_mjz_clinkz_soul_pact_permanent_buff:IsHidden() return false end
function modifier_mjz_clinkz_soul_pact_permanent_buff:IsPurgable() return false end
function modifier_mjz_clinkz_soul_pact_permanent_buff:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end
function modifier_mjz_clinkz_soul_pact_permanent_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end
function modifier_mjz_clinkz_soul_pact_permanent_buff:GetModifierBaseAttack_BonusDamage()
	return self:GetStackCount()
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact_debuff = class({})
function modifier_mjz_clinkz_soul_pact_debuff:IsHidden() return false end
function modifier_mjz_clinkz_soul_pact_debuff:IsPurgable() return false end
function modifier_mjz_clinkz_soul_pact_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_DEATH}
end
function modifier_mjz_clinkz_soul_pact_debuff:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		local armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction")
		if armor_reduction > 0 then
			return -armor_reduction
		else
			return armor_reduction
		end
	end
	return 0
end
function modifier_mjz_clinkz_soul_pact_debuff:OnDeath(event)
	if IsServer() then
		if event.unit ~= self:GetParent() then return end

		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local hVictim = event.unit
		local hKiller = event.attacker
		ability:OnEnemyDied(hVictim, hKiller, event)
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact_invis = class({})
function modifier_mjz_clinkz_soul_pact_invis:IsHidden() return true end
function modifier_mjz_clinkz_soul_pact_invis:IsPurgable() return false end
function modifier_mjz_clinkz_soul_pact_invis:CheckState()
    return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end
function modifier_mjz_clinkz_soul_pact_invis:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end
function modifier_mjz_clinkz_soul_pact_invis:GetModifierInvisibilityLevel(params) return 100 end
function modifier_mjz_clinkz_soul_pact_invis:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_speed_bonus_pct")
end
function modifier_mjz_clinkz_soul_pact_invis:OnAttack(event)
	if not IsServer() then return end
	if self:GetParent() ~= event.attacker then return end
	self:Destroy()
end
function modifier_mjz_clinkz_soul_pact_invis:OnAbilityExecuted(event)
	if not IsServer() then return end
	if self:GetParent() ~= event.unit then return end
	self:Destroy()
end
function modifier_mjz_clinkz_soul_pact_invis:OnDestroy()
	if IsServer() then
		if self:GetParent():HasScepter() then
			local duration = self:GetAbility():GetSpecialValueFor("attack_speed_duration") + talent_value(self:GetCaster(), "special_bonus_clinkz_soul_pact_strafe_duration")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_clinkz_soul_pact_strafe", {duration = duration})
		end
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_soul_pact_strafe = class({})
function modifier_mjz_clinkz_soul_pact_strafe:IsHidden() return false end
function modifier_mjz_clinkz_soul_pact_strafe:IsPurgable() return false end
function modifier_mjz_clinkz_soul_pact_strafe:OnCreated()
	self.attack_speed_bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus") + talent_value(self:GetCaster(), "special_bonus_clinkz_soul_pact_strafe_attack_speed")
	EmitSoundOn("Hero_Clinkz.Strafe", self:GetParent())
end
function modifier_mjz_clinkz_soul_pact_strafe:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_mjz_clinkz_soul_pact_strafe:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed_bonus
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