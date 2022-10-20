----------------
--PURIFICATION--
----------------
purification = class({})
LinkLuaModifier("modifier_purification_buff", "heroes/hero_omniknight.lua", LUA_MODIFIER_MOTION_NONE)
function purification:GetAbilityTextureName() return "omniknight_purification" end
function purification:IsHiddenWhenStolen() return false end
function purification:GetAOERadius()
	if not IsServer() then return end
	local radius = self:GetSpecialValueFor("radius")
	if self:GetCaster():HasTalent("special_bonus_omniknight_purifiception_radius") then
		radius = radius + self:GetCaster():FindTalentValue("special_bonus_omniknight_purifiception_radius")
		return radius
	end
	return radius
end

function purification:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local rare_cast_response = "omniknight_omni_ability_purif_03"
	local target_cast_response = {"omniknight_omni_ability_purif_01", "omniknight_omni_ability_purif_02", "omniknight_omni_ability_purif_04", "omniknight_omni_ability_purif_05", "omniknight_omni_ability_purif_06", "omniknight_omni_ability_purif_07", "omniknight_omni_ability_purif_08"}
	local self_cast_response = {"omniknight_omni_ability_purif_01", "omniknight_omni_ability_purif_05", "omniknight_omni_ability_purif_06", "omniknight_omni_ability_purif_07", "omniknight_omni_ability_purif_08"}
	local bkb_duration = 1
	if caster == target then
		if RollPercentage(50) then
			EmitSoundOn(self_cast_response[math.random(1, #self_cast_response)], caster)
		end
	else
		if RollPercentage(5) then
			EmitSoundOn(rare_cast_response, caster)
		elseif RollPercentage(50) then
			EmitSoundOn(target_cast_response[math.random(1,#target_cast_response)], caster)
		end
	end
--[[ 	if IsServer() then
		if HasSuperScepter(caster) then
			local super_scepter_duration = 1.75
			if caster:HasModifier("modifier_purification_buff") then
				stacks = caster:FindModifierByName("modifier_purification_buff"):GetStackCount()
			else
				stacks = 0
			end
			local duration = super_scepter_duration + (stacks * 0.2)
			target:AddNewModifier(caster, self, "modifier_black_king_bar_immune", {duration = duration})
		end
	end ]]
	Purification(caster, self, target, bkb_duration)

	if caster:HasTalent("special_bonus_omniknight_purifiception_double") then
		local allies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,ally in pairs(allies) do
			if RollPercentage(20) then
				if ally ~= target then
					Purification(caster, self, ally)
					break
				end
			end
		end
	end
end

function Purification(caster, ability, target, bkb_duration)
	local particle_cast = "particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf"
	local particle_aoe = "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf"
	local particle_hit = "particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf"
	local modifier_purifiception = "modifier_purification_buff"
	local heal_amount = ability:GetSpecialValueFor("heal_amount")
	local radius = ability:GetSpecialValueFor("radius")
	local purifiception_duration = ability:GetSpecialValueFor("purifiception_duration")
	EmitSoundOn("Hero_Omniknight.Purification", caster)

	heal_amount = heal_amount + (caster:FindTalentValue("special_bonus_omniknight_purifiception_heal") * target:GetMaxHealth() / 100)
	local damage = heal_amount
	radius = radius + (caster:FindTalentValue("special_bonus_omniknight_purifiception_radius"))
	if IsServer() then
		if HasSuperScepter(caster) then
			if bkb_duration and bkb_duration > 0 then
				local super_scepter_duration = 1.75
				if caster:HasModifier("modifier_purification_buff") then
					stacks = caster:FindModifierByName("modifier_purification_buff"):GetStackCount()
				else
					stacks = 0
				end
				local duration = super_scepter_duration + (stacks * 0.2)
				target:AddNewModifier(caster, self, "modifier_black_king_bar_immune", {duration = duration})
			elseif bkb_duration and bkb_duration < 1 then
				local super_scepter_duration = 0.90
				if caster:HasModifier("modifier_purification_buff") then
					stacks = caster:FindModifierByName("modifier_purification_buff"):GetStackCount()
				else
					stacks = 0
				end
				local duration = super_scepter_duration + (stacks * 0.1)
				target:AddNewModifier(caster, self, "modifier_black_king_bar_immune", {duration = duration})				
			end	
			damage = heal_amount + (caster:FindTalentValue("special_bonus_omniknight_purifiception_heal") * target:GetMaxHealth() / 100)
		end
	end

	local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particle_cast_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle_cast_fx, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_cast_fx)

	local particle_aoe_fx = ParticleManager:CreateParticle(particle_aoe, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_aoe_fx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_aoe_fx, 1, Vector(radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_aoe_fx)    

	local spell_power = caster:GetSpellAmplification(false)

	local heal = heal_amount

	damage = damage * (1 + spell_power / 4)
	target:Heal(heal, caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, nil)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		if not enemy:IsMagicImmune() then
			ApplyDamage({victim = enemy, attacker = caster, damage = damage/2, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = ability })
			ApplyDamage({victim = enemy, attacker = caster, damage = damage/2, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = ability })

			local particle_hit_fx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(particle_hit_fx, 3, Vector(radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(particle_hit_fx)
		end
	end
	if not target:HasModifier(modifier_purifiception) then
		target:AddNewModifier(caster, ability, modifier_purifiception, {duration = purifiception_duration})
	end

	local modifier_purifiception_handler = target:FindModifierByName(modifier_purifiception)
	if modifier_purifiception_handler then
	   modifier_purifiception_handler:ForceRefresh()
	end
end

---------------------
--PURIFICATION BUFF--
---------------------
modifier_purification_buff = class({})
function modifier_purification_buff:OnCreated()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.buff_heal_amp_pct = self:GetAbility():GetSpecialValueFor("buff_heal_amp_pct")
	self.buff_max_stacks = self:GetAbility():GetSpecialValueFor("buff_max_stacks")
	self.buff_stack_threshold = self:GetAbility():GetSpecialValueFor("buff_stack_threshold")

	self:SetStackCount(1)
end

function modifier_purification_buff:IsHidden() return false end
function modifier_purification_buff:IsPurgable() return true end
function modifier_purification_buff:IsDebuff() return false end
function modifier_purification_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_HEALTH_GAINED, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_purification_buff:GetModifierHPRegenAmplify_Percentage(keys)
	local stacks = self:GetStackCount()
	return self.buff_heal_amp_pct * stacks
end
function modifier_purification_buff:OnHealthGained(keys)
	if IsServer() then
		if keys.unit == self.parent then
			if keys.gain and keys.gain >= self.buff_stack_threshold then
				self:IncrementStackCount()
			end
		end
	end
end
function modifier_purification_buff:OnStackCountChanged()
	if IsServer() then
		local stacks = self:GetStackCount()
		if stacks > self.buff_max_stacks then
			self:SetStackCount(self.buff_max_stacks)
		end
	end
end
function modifier_purification_buff:OnTooltip() return self:GetStackCount() * self.buff_heal_amp_pct end


------------------------
--PURIFICATION TALANTS--
------------------------
LinkLuaModifier("modifier_special_bonus_omniknight_purifiception_heal", "heroes/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_special_bonus_omniknight_purifiception_radius", "heroes/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_special_bonus_omniknight_purifiception_double", "heroes/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
modifier_special_bonus_omniknight_purifiception_heal = class({})
modifier_special_bonus_omniknight_purifiception_radius = class({})
modifier_special_bonus_omniknight_purifiception_double = class({})
function modifier_special_bonus_omniknight_purifiception_heal:IsHidden() 		return true end
function modifier_special_bonus_omniknight_purifiception_heal:IsPurgable() 		return false end
function modifier_special_bonus_omniknight_purifiception_heal:RemoveOnDeath() 	return false end
function modifier_special_bonus_omniknight_purifiception_radius:IsHidden()			return true end
function modifier_special_bonus_omniknight_purifiception_radius:IsPurgable() 		return false end
function modifier_special_bonus_omniknight_purifiception_radius:RemoveOnDeath() 	return false end
function modifier_special_bonus_omniknight_purifiception_double:IsHidden()			return true end
function modifier_special_bonus_omniknight_purifiception_double:IsPurgable() 		return false end
function modifier_special_bonus_omniknight_purifiception_double:RemoveOnDeath() 	return false end
function purification:OnOwnerSpawned()
	if self:GetCaster():HasTalent("special_bonus_omniknight_purifiception_radius") and not self:GetCaster():HasModifier("modifier_special_bonus_omniknight_purifiception_radius") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:FindAbilityByName("special_bonus_omniknight_purifiception_radius"), "modifier_special_bonus_omniknight_purifiception_radius", {})
	end
	if self:GetCaster():HasTalent("special_bonus_omniknight_purifiception_heal") and not self:GetCaster():HasModifier("modifier_special_bonus_omniknight_purifiception_heal") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:FindAbilityByName("special_bonus_omniknight_purifiception_heal"), "modifier_special_bonus_omniknight_purifiception_heal", {})
	end
	if self:GetCaster():HasTalent("special_bonus_omniknight_purifiception_double") and not self:GetCaster():HasModifier("modifier_special_bonus_omniknight_purifiception_double") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:FindAbilityByName("special_bonus_omniknight_purifiception_double"), "modifier_special_bonus_omniknight_purifiception_double", {})
	end
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------
--GUARDIAN ANGEL--
------------------
guardian_angel = class({})
LinkLuaModifier("modifier_ga", "heroes/hero_omniknight.lua", LUA_MODIFIER_MOTION_NONE)
function guardian_angel:GetAbilityTextureName() return "omniknight_guardian_angel" end
function guardian_angel:IsHiddenWhenStolen() return false end
function guardian_angel:GetCooldown(level)
	if not IsServer() then return end
	local cooldown = self.BaseClass.GetCooldown(self, level)
	if self:GetCaster():HasTalent("special_bonus_omniknight_ga_cd") then
		scepter_cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_omniknight_ga_cd")
		return scepter_cooldown
	end
	return cooldown
end
function guardian_angel:GetCastAnimation() return ACT_DOTA_CAST_ABILITY_4 end
function guardian_angel:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local cast_response = {"omniknight_omni_ability_guard_04", "omniknight_omni_ability_guard_05", "omniknight_omni_ability_guard_06", "omniknight_omni_ability_guard_10"}
	local sound_cast = "Hero_Omniknight.GuardianAngel.Cast"
	local modifier_angel = "modifier_ga"
	local scepter = caster:HasScepter()
	local duration = ability:GetSpecialValueFor("duration")
	local scepter_duration = ability:GetSpecialValueFor("scepter_duration")
	local radius = ability:GetSpecialValueFor("radius")
	local cooldown = ability:GetSpecialValueFor("cooldown")
	cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_omniknight_ga_cd")

	self:StartCooldown(cooldown)
	EmitSoundOn(cast_response[math.random(1, #cast_response)], caster)
	EmitSoundOn(sound_cast, caster)
	if scepter then
		duration = scepter_duration
		radius = 20000
	end
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, ability, modifier_angel, {duration = duration})
	end
end

---------------------------
--GUARDIAN ANGEL MODIFIER--
---------------------------
modifier_ga = class({})
function modifier_ga:IsHidden() return false end
function modifier_ga:IsPurgable() return true end
function modifier_ga:IsDebuff() return false end
function modifier_ga:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.particle_wings = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"
	self.particle_ally = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
	self.particle_halo = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_halo_buff.vpcf"
	self.shield_duration = self.ability:GetSpecialValueFor("shield_duration")
	self.scepter_regen = self.ability:GetSpecialValueFor("scepter_regen")

	if self.parent == self.caster then
		self.particle_wings_fx = ParticleManager:CreateParticle(self.particle_wings, PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(self.particle_wings_fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(self.particle_wings_fx, 5, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		self:AddParticle(self.particle_wings_fx, false, false, -1, false, false)

		self.particle_halo_fx = ParticleManager:CreateParticle(self.particle_halo, PATTACH_OVERHEAD_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.particle_halo_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		self:AddParticle(self.particle_halo_fx, false, false, -1, false, false)
	else
		self.particle_ally_fx = ParticleManager:CreateParticle(self.particle_ally, PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(self.particle_ally_fx, 0, self.parent:GetAbsOrigin())
		self:AddParticle(self.particle_ally_fx, false, false, -1, false, false)
	end
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end
function modifier_ga:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasScepter() then
			local caster = self:GetCaster()
			local ability = self:GetCaster():FindAbilityByName("purification")
			local parent = self:GetParent()
			local bkb_duration = 0
			local allies = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, 1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _,ally in pairs(allies) do
				if RollPseudoRandom(20, caster) then
					Purification(caster, ability, ally, bkb_duration)
					break
				end
			end
		end
	end
end

function modifier_ga:GetStatusEffectName() return "particles/status_fx/status_effect_guardian_angel.vpcf" end
function modifier_ga:DeclareFunctions()
	return { MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end
function modifier_ga:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_ga:GetModifierConstantHealthRegen()
	if self:GetCaster():HasScepter() then
		return self.scepter_regen
	end
end


--------------------------
--GUARDIAN ANGEL TALANTS--
--------------------------
LinkLuaModifier("modifier_special_bonus_omniknight_ga_cd", "heroes/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
modifier_special_bonus_omniknight_ga_cd = modifier_special_bonus_omniknight_ga_cd or class({})
function modifier_special_bonus_omniknight_ga_cd:IsHidden() 		return true end
function modifier_special_bonus_omniknight_ga_cd:IsPurgable() 		return false end
function modifier_special_bonus_omniknight_ga_cd:RemoveOnDeath() 	return false end
function guardian_angel:OnOwnerSpawned()
	if self:GetCaster():HasTalent("special_bonus_omniknight_ga_cd") and not self:GetCaster():HasModifier("modifier_special_bonus_omniknight_ga_cd") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("special_bonus_omniknight_ga_cd"), "modifier_special_bonus_omniknight_ga_cd", {})
	end
end
