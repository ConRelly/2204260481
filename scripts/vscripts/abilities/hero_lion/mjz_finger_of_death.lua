require("lib/timers")

LinkLuaModifier("modifier_mjz_finger_of_death_bonus", "abilities/hero_lion/mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_finger_of_death_death", "abilities/hero_lion/mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)

mjz_finger_of_death = class({})
function mjz_finger_of_death:GetIntrinsicModifierName() return "modifier_mjz_finger_of_death_bonus" end
function mjz_finger_of_death:GetAbilityTextureName()
	if self:GetCaster():HasScepter() then
		return "mjz_lion_finger_of_death_immortal"
	end
	return "mjz_finger_of_death"
end
function mjz_finger_of_death:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end
function mjz_finger_of_death:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("splash_radius_scepter")
	end
	return self:GetSpecialValueFor("cast_range")
end
function mjz_finger_of_death:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cast_range_scepter")
	end
	return self:GetSpecialValueFor("cast_range")
end
function mjz_finger_of_death:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cooldown_scepter")
	end
	return self.BaseClass.GetCooldown(self, iLevel)
end
function mjz_finger_of_death:GetManaCost(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("mana_cost_scepter")
	end
	return self.BaseClass.GetManaCost(self, iLevel)
end

--[[
function mjz_finger_of_death:GetAbilityTargetFlags()
	if self:GetCaster():HasScepter() then
		return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function mjz_finger_of_death:GetDamageType()
	if self:GetCaster():HasScepter() then
		return DAMAGE_TYPE_PURE
	end
	return DAMAGE_TYPE_MAGICAL
end
function mjz_finger_of_death:GetAbilityDamageType()
	return self:GetDamageType()
end
function mjz_finger_of_death:GetUnitDamageType()
	return self:GetDamageType()
end
]]

if IsServer() then
	function mjz_finger_of_death:OnSpellStart()
		local caster = self:GetCaster()
		self.damage_delay = self:GetSpecialValueFor("damage_delay")
	 
		local damage = self:_CalcDamage()

		local sound ="Hero_Lion.FingerOfDeath" 
		if caster:HasScepter() then
			-- sound = "Hero_Lion.FingerOfDeath.Immortal"
		end
		caster:EmitSound(sound)
		local targets = self:_GetTargets()
		for _, target in ipairs(targets) do
			self:_PlayEffect(target)
			self:_AddDeathMonitor(target)
			self:_ApplyDamage(target, damage)
		end
	end

	function mjz_finger_of_death:_CalcDamage()
		local caster = self:GetCaster()
		local base_damage = self:GetSpecialValueFor(value_if_scepter(caster, "damage_scepter", "damage"))
		local damage_per_kill = self:GetSpecialValueFor("damage_per_kill")
		local extra_int = GetTalentSpecialValueFor(self, "damage_per_int") * caster:GetIntellect() or 0
		local kill_count = caster:GetModifierStackCount("modifier_mjz_finger_of_death_bonus", nil)
		local damage = math.ceil((base_damage + extra_int + damage_per_kill * kill_count) / 2)
		return damage
	end

	function mjz_finger_of_death:_GetTargets()
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		if caster:HasScepter() then
			local splash_radius = ability:GetSpecialValueFor("splash_radius_scepter")
			return FindUnitsInRadius(
				caster:GetTeamNumber(),
				target:GetAbsOrigin(),
				nil, splash_radius,
				ability:GetAbilityTargetTeam(),
				ability:GetAbilityTargetType(),
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				FIND_ANY_ORDER,
				false
			)
		end

		local targets = {}
		table.insert(targets, target)
		return targets
	end

	function mjz_finger_of_death:_PlayEffect(target)
		local caster = self:GetCaster()
		local ability = self

		local particle_name_normal = "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf"
		local particle_name_ti8 = "particles/econ/items/lion/lion_ti8/lion_spell_finger_of_death_charge_ti8.vpcf"
		particle_name_ti8 = particle_name_normal
		local particle_name = value_if_scepter(caster, particle_name_ti8, particle_name_normal)
		
		local particle_finger_fx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(particle_finger_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle_finger_fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(particle_finger_fx, 2, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_finger_fx, 3, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_finger_fx, 4, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_finger_fx, 5, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_finger_fx, 6, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_finger_fx, 7, target:GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(particle_finger_fx, 10, caster, PATTACH_ABSORIGIN, "attach_attack2", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle_finger_fx)
	end

	function mjz_finger_of_death:_AddDeathMonitor(target)
		if target:IsIllusion() then return nil end

		local ability = self
		local caster = self:GetCaster()
		local kill_grace_duration = ability:GetSpecialValueFor("kill_grace_duration")
		local creature_enabled = ability:GetSpecialValueFor("creature_enabled")
		-- self.creature_health = ability:GetSpecialValueFor("creature_health")
		local modifier_death = "modifier_mjz_finger_of_death_death"
		
		local can = false
		if target:IsRealHero() then
			can = true
		else
			if creature_enabled and creature_enabled > 0 then
				can = true
			end
		end

		--添加死亡监听器
		if can then
			target:AddNewModifier(caster, ability, modifier_death, {duration=kill_grace_duration})
		end
	end

	function mjz_finger_of_death:_ApplyDamage(target, damage)
		local caster = self:GetCaster()
		local ability = self

		local sound_default = "Hero_Lion.FingerOfDeathImpact"
		local sound_immortal = "Hero_Lion.FingerOfDeathImpact.Immortal"
		local sound_name = value_if_scepter(caster, sound_immortal, sound_default)
		target:EmitSound(sound_name)

		-- 林肯法球
		if target:TriggerSpellAbsorb(ability) then return nil end
		Timers:CreateTimer(
			self.damage_delay,
			function()		
				if target ~= nil and IsValidEntity(target) and target:IsAlive() and (not target:IsMagicImmune() or caster:HasScepter()) then
					local damage_type = DAMAGE_TYPE_MAGICAL
					--print("lion dmg 1")
					ApplyDamage({
						attacker = caster,
						victim = target,
						damage = damage,
						damage_type = damage_type,
						ability = ability,
					})
				end
			end	
	   ) 
		Timers:CreateTimer(
			self.damage_delay + 0.05,
			function()		
				if target ~= nil and IsValidEntity(target) and target:IsAlive() and (not target:IsMagicImmune() or caster:HasScepter()) then
					local damage_type = DAMAGE_TYPE_MAGICAL
					--print("lion dmg 2")
					ApplyDamage({
						attacker = caster,
						victim = target,
						damage = damage,
						damage_type = damage_type,
						ability = ability,
					})
				end
			end	
	   )		  
	end
end

--------------------------------------------------------------------------------
LinkLuaModifier("modifier_mjz_finger_of_death_creature", "abilities/hero_lion/mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_finger_of_death_bonus = class({})
function modifier_mjz_finger_of_death_bonus:IsBuff() return true end
function modifier_mjz_finger_of_death_bonus:IsPermanent() return true end
function modifier_mjz_finger_of_death_bonus:IsPurgable() return false end
function modifier_mjz_finger_of_death_bonus:RemoveOnDeath() return false end
function modifier_mjz_finger_of_death_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP} 
end
function modifier_mjz_finger_of_death_bonus:OnTooltip()
	local ability = self:GetAbility()
	local damage_per_k = ability:GetSpecialValueFor("damage_per_kill")
	local total = damage_per_k * self:GetStackCount()
	return total
end

---------------------------------------------------------------------------------
modifier_mjz_finger_of_death_creature = class({})
function modifier_mjz_finger_of_death_creature:IsHidden() return true end
function modifier_mjz_finger_of_death_creature:IsPermanent() return true end
function modifier_mjz_finger_of_death_creature:IsPurgable() return false end
function modifier_mjz_finger_of_death_creature:RemoveOnDeath() return false end

---------------------------------------------------------------------------------
modifier_mjz_finger_of_death_death = class({})
function modifier_mjz_finger_of_death_death:IsDebuff() return true end
function modifier_mjz_finger_of_death_death:IsPurgable() return false end
function modifier_mjz_finger_of_death_death:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_mjz_finger_of_death_death:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP, MODIFIER_EVENT_ON_DEATH}
end
function modifier_mjz_finger_of_death_death:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_per_kill")
end
function modifier_mjz_finger_of_death_death:OnDeath(event)
	if IsServer() then
		if event.unit == self:GetParent() then
			local unit = event.unit
			self:OnTargetDeath(unit)
		end
	end
end
if IsServer() then
	function modifier_mjz_finger_of_death_death:OnTargetDeath(target)
		if target:IsIllusion() then return end

		local owner = self:GetCaster()
		local ability = self:GetAbility()
		local victim = target
		local can_charge = false

		if victim:IsRealHero() then
			can_charge = true
		else
			can_charge = self:OnCreatureDeath(victim)
		end

		if can_charge then
			local modifier_name = "modifier_mjz_finger_of_death_bonus"
			local kill_count = owner:GetModifierStackCount(modifier_name, nil)
			kill_count = kill_count + 1
			
			SetModifierStackCount(owner, ability, modifier_name, kill_count)		 
		end
	end

	function modifier_mjz_finger_of_death_death:OnCreatureDeath(target)
		local owner = self:GetCaster()
		local ability = self:GetAbility()
		local victim = target
		local can_charge = false
		local creature_enabled = ability:GetSpecialValueFor("creature_enabled")
		local creature_health = ability:GetSpecialValueFor("creature_health")
		local modifier_creature_name = "modifier_mjz_finger_of_death_creature"

		if creature_enabled and creature_enabled > 0 then
			local victim_health = victim:GetMaxHealth()
			if victim_health > creature_health then
				can_charge = true
			else
				local creature_total = owner:GetModifierStackCount(modifier_creature_name, nil)

				if (creature_total + victim_health) > creature_health then
					can_charge = true
					creature_total = 0
				else
					can_charge = false
					creature_total = creature_total + victim_health
				end

				SetModifierStackCount(owner, ability, modifier_creature_name, creature_total)  
			end
		end
		return can_charge
	end
end

--------------------------------------------------------------------------------

function SetModifierStackCount(owner, ability, modifier_name, count)
	if not owner:HasModifier(modifier_name) then
		owner:AddNewModifier(owner, ability, modifier_name, {})			
	end
	owner:SetModifierStackCount(modifier_name, owner, count)	
end

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end

--talents
function HasTalent(unit, talentName)
	if unit:HasAbility(talentName) then
		if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

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
			valueName = valueName or "value"
			base = base + talent:GetSpecialValueFor(valueName) 
		end
	end
	return base
end
