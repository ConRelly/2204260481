LinkLuaModifier("modifier_faerie_dream_coil", "heroes/hero_puck/dream_coil", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_faerie_dream_coil_thinker", "heroes/hero_puck/dream_coil", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_faerie_dream_coil_rapid_fire", "heroes/hero_puck/dream_coil", LUA_MODIFIER_MOTION_NONE)

----------------
-- DREAM COIL --
----------------
faerie_dream_coil = class({})
function faerie_dream_coil:GetAOERadius() return self:GetSpecialValueFor("coil_radius") end
function faerie_dream_coil:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level) - talent_value(self:GetCaster(), "special_bonus_faerie_dream_coil_cooldown")
end

function faerie_dream_coil:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local coil_initial_stun = self:GetSpecialValueFor("coil_initial_stun")
	local radius = self:GetSpecialValueFor("coil_radius")
	local latch_duration = self:GetSpecialValueFor("coil_duration")
	local latch_duration_scepter = self:GetSpecialValueFor("coil_duration_scepter")
	local init_damage = self:GetSpecialValueFor("coil_initial_damage") * caster:GetIntellect()
	local target_flag = DOTA_UNIT_TARGET_FLAG_NONE
	
	if caster:HasScepter() then
		target_flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		latch_duration = latch_duration_scepter
	end

	EmitSoundOnLocationWithCaster(target, "Hero_Puck.Dream_Coil", caster)

	local coil_base = CreateUnitByName("npc_dota_invisible_vision_source", target, false, caster, caster, caster:GetTeamNumber())
	coil_base:AddNewModifier(caster, self, "modifier_phased", {})
	coil_base:AddNewModifier(caster, self, "modifier_kill", {duration = latch_duration})
	coil_base:AddNewModifier(caster, self, "modifier_faerie_dream_coil_thinker", {duration = latch_duration})
	
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_flag, FIND_ANY_ORDER, false)

	for _, enemy in pairs(enemies) do
		if not caster:HasScepter() then if enemy:IsMagicImmune() then return end end
		ApplyDamage({
			ability 		= self,
			victim 			= enemy,
			attacker 		= caster,
			damage 			= init_damage,
			damage_type		= self:GetAbilityDamageType(),
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		})
		
		enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = coil_initial_stun * (1 - enemy:GetStatusResistance())})
	
		enemy:AddNewModifier(caster, self, "modifier_faerie_dream_coil", {duration = latch_duration, coil_base = coil_base:entindex()})

		if caster:HasTalent("special_bonus_faerie_dream_coil_rapid_fire") then
			enemy:AddNewModifier(caster, self, "modifier_faerie_dream_coil_rapid_fire", {duration = latch_duration, coil_base = coil_base:entindex()})
		end
	end
end


-- Repid Fire Talent
function faerie_dream_coil:OnProjectileHit_ExtraData(target, location, data)
	if not IsServer() then return end
	
	if target and IsValidEntity(target) then
		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Puck.ProjectileImpact", self:GetCaster())
	
		self:GetCaster():PerformAttack(target, false, true, true, false, false, false, false)

		if not self:GetCaster():IsHero() then return end
		if not self:GetCaster():HasModifier("modifier_super_scepter") then return end
		if target and IsValidEntity(target) then 
			if target:GetTeam() ~= self:GetCaster():GetTeam() then
				ApplyDamage({
					victim = target,
					attacker = self:GetCaster(),
					damage = self:_CalcDamage(),
					damage_type = self:GetAbilityDamageType(),
					ability = self,
				})
			end
		end		
	end
end

function faerie_dream_coil:_GetPrimaryStatValue()
	if not IsServer() then return end
	-- STRENGTH = 0
	-- AGILITY = 1
	-- INTELLIGENCE = 2
	local unit = self:GetCaster()
	local pa = unit:GetPrimaryAttribute()
	local PrimaryStatValue = 0
	if pa == 0  then
		PrimaryStatValue = unit:GetStrength()
	elseif pa == 1  then
		PrimaryStatValue = unit:GetAgility()
	elseif pa == 2  then
		PrimaryStatValue = unit:GetIntellect()
	end
	return PrimaryStatValue
end

function faerie_dream_coil:_CalcDamage()
	if not IsServer() then return end
	local stats = self:GetCaster():GetIntellect() + self:GetCaster():GetAgility() + self:GetCaster():GetStrength() + self:_GetPrimaryStatValue()
	local bonus_dmg = stats * self:GetSpecialValueFor("ss_talent_stats_dmg")	
	return math.floor(bonus_dmg)
end


-------------------------
-- DREAM COIL MODIFIER --
-------------------------
modifier_faerie_dream_coil = class({})
function modifier_faerie_dream_coil:IsPurgable() return not self:GetCaster():HasScepter() end
function modifier_faerie_dream_coil:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faerie_dream_coil:OnCreated(params)
	if self:GetAbility() then
		local caster = self:GetCaster()
		self.coil_break_radius			= self:GetAbility():GetSpecialValueFor("coil_break_radius")
		self.coil_stun_duration			= self:GetAbility():GetSpecialValueFor("coil_stun_duration")
		self.coil_break_damage			= self:GetAbility():GetSpecialValueFor("coil_break_damage") * caster:GetIntellect()
		self.coil_break_damage_scepter	= self:GetAbility():GetSpecialValueFor("coil_break_damage_scepter") * caster:GetIntellect()
		self.coil_stun_duration_scepter	= self:GetAbility():GetSpecialValueFor("coil_stun_duration_scepter")
		if caster and caster:HasModifier("modifier_super_scepter") then
			self.coil_break_radius = self:GetAbility():GetSpecialValueFor("coil_break_radius") + self:GetAbility():GetSpecialValueFor("coil_break_radius_ss_bonus")
		end 	
	end

	if not IsServer() then return end
	
	self.ability_damage_type	= self:GetAbility():GetAbilityDamageType()
	self.coil_base				= EntIndexToHScript(params.coil_base)
	self.coil_base_loc		= self.coil_base:GetAbsOrigin()

	local coil_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil_tether.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(coil_particle, 0, self.coil_base, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.coil_base_loc, true)
	ParticleManager:SetParticleControlEnt(coil_particle, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(coil_particle, false, false, -1, false, false)
	
	self:StartIntervalThink(0.1)
end

function modifier_faerie_dream_coil:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility() then self:Destroy() return end
	
	if (self:GetParent():GetAbsOrigin() - self.coil_base_loc):Length2D() >= self.coil_break_radius then
		self:GetParent():EmitSound("Hero_Puck.Dream_Coil_Snap")

		local stun_duration	= self.coil_stun_duration
		local break_damage	= self.coil_break_damage
		
		if self:GetCaster():HasScepter() then
			stun_duration	= self.coil_stun_duration_scepter
			break_damage	= self.coil_break_damage_scepter
		end

		ApplyDamage({
			ability 		= self:GetAbility(),
			victim 			= self:GetParent(),
			attacker 		= self:GetCaster(),
			damage 			= break_damage,
			damage_type		= self.ability_damage_type,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		})
		
		local stun_modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = stun_duration * (1 - self:GetParent():GetStatusResistance())})
		
		self:Destroy()
	end
end

function modifier_faerie_dream_coil:CheckState()
	return {[MODIFIER_STATE_TETHERED] = true}
end

---------------------------
-- DREAM COIL rapid_fire --
---------------------------
modifier_faerie_dream_coil_rapid_fire = class({})
function modifier_faerie_dream_coil_rapid_fire:IsPurgable() return not self:GetCaster():HasScepter() end
function modifier_faerie_dream_coil_rapid_fire:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faerie_dream_coil_rapid_fire:OnCreated(params)
	if not IsServer() then return end

	self.coil_base = EntIndexToHScript(params.coil_base)
	self.coil_base_loc = self.coil_base:GetAbsOrigin()
	
	self:StartIntervalThink(self:GetCaster():FindTalentCustomValue("special_bonus_faerie_dream_coil_rapid_fire", "rapid_fire_interval"))
end

function modifier_faerie_dream_coil_rapid_fire:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility() then self:Destroy() return end
	if not self:GetParent():HasModifier("modifier_faerie_dream_coil") then self:Destroy() return end
	if self:GetCaster():IsAlive() then
		local rapid_fire_max_distance = self:GetCaster():Script_GetAttackRange()	--775
		local direction	= (self:GetParent():GetAbsOrigin() - self.coil_base_loc):Normalized()
		if (self:GetCaster():GetAbsOrigin() - self.coil_base_loc):Length2D() <= rapid_fire_max_distance then
			EmitSoundOnLocationWithCaster(self.coil_base_loc, "Hero_Puck.Attack", self:GetCaster())

			ProjectileManager:CreateTrackingProjectile({
				Target 				= self:GetParent(),
				Source 				= self.coil_base,
				Ability 			= self:GetAbility(),
				EffectName 			= self:GetCaster():GetRangedProjectileName() or "particles/units/heroes/hero_puck/puck_base_attack.vpcf",
				iMoveSpeed			= self:GetCaster():GetProjectileSpeed() or 900,
				bDrawsOnMinimap 	= false,
				bDodgeable 			= true,
				bIsAttack 			= true,
				bVisibleToEnemies 	= true,
				bReplaceExisting 	= false,
				flExpireTime 		= GameRules:GetGameTime() + 10,
				bProvidesVision 	= false,
			})
		end
	end
end

---------------------------------
-- DREAM COIL THINKER MODIFIER --
---------------------------------
modifier_faerie_dream_coil_thinker = class({})
function modifier_faerie_dream_coil_thinker:OnCreated()
	if not IsServer() then return end

	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.pfx, 0, self:GetParent():GetAbsOrigin())
end
function modifier_faerie_dream_coil_thinker:OnDestroy()
	if not IsServer() then return end

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	if self:GetParent():HasModifier("modifier_kill") then
		self:GetParent():RemoveModifierByName("modifier_kill")
	end
end
function modifier_faerie_dream_coil_thinker:CheckState()
	if not self:GetAbility() then self:Destroy() return end
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
end
