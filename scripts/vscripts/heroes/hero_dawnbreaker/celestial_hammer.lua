LinkLuaModifier("modifier_db_celestial_hammer", "heroes/hero_dawnbreaker/celestial_hammer", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_db_celestial_hammer_nohammer", "heroes/hero_dawnbreaker/celestial_hammer", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_db_celestial_hammer_thinker", "heroes/hero_dawnbreaker/celestial_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_db_celestial_hammer_trail", "heroes/hero_dawnbreaker/celestial_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_db_celestial_hammer_debuff", "heroes/hero_dawnbreaker/celestial_hammer", LUA_MODIFIER_MOTION_NONE)


----------------------
-- Celestial Hammer --
----------------------
db_celestial_hammer = class({})
function db_celestial_hammer:Precache(context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_grounded.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_burning_trail.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_trail.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf", context)
end


--------------
-- Converge --
--------------
db_converge = class({})
function db_converge:OnSpellStart()
	local main = self:GetCaster():FindAbilityByName("db_celestial_hammer")
	if main then
		main:Converge()
	end
	self:SetActivated(false)
end


function db_celestial_hammer:Spawn() if not IsServer() then return end end
function db_celestial_hammer:GetCastRange(location, target)
	return self:GetSpecialValueFor("range") + TalentValue(self:GetCaster(), "special_bonus_unique_dawnbreaker_celestial_hammer_cast_range")
end
function db_celestial_hammer:OnUpgrade()
	local sub = self:GetCaster():FindAbilityByName("db_converge")
	if not sub then
		sub = self:GetCaster():AddAbility("db_converge")
	end
	sub:SetLevel(self:GetLevel())
end
function db_celestial_hammer:CastFilterResultLocation(vLoc)
	if self:GetCaster():HasModifier("modifier_db_celestial_hammer_nohammer") then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
function db_celestial_hammer:GetCustomCastErrorLocation(vLoc)
	if self:GetCaster():HasModifier("modifier_db_celestial_hammer_nohammer") then
		return "#dota_hud_error_nohammer"
	end
	return ""
end
function db_celestial_hammer:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local name = ""
	local radius = self:GetSpecialValueFor("projectile_radius")
	local speed = self:GetSpecialValueFor("projectile_speed")
	local distance = self:GetSpecialValueFor("range") + TalentValue(self:GetCaster(), "special_bonus_unique_dawnbreaker_celestial_hammer_cast_range")
	local direction = point-caster:GetOrigin()
	local len = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()
	distance = math.min(distance, len)

	local thinker = CreateModifierThinker(caster, self, "modifier_db_celestial_hammer_thinker", {},caster:GetOrigin(), self:GetCaster():GetTeamNumber(), false)

	if self:GetCaster() and self:GetCaster():IsHero() then
		local Hammer = self:GetCaster():GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON)
		if Hammer ~= nil then
			Hammer:AddEffects(EF_NODRAW)
		end
	end

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
	
		-- bDeleteOnHit = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	
		EffectName = name,
		fDistance = distance,
		fStartRadius = radius,
		fEndRadius = radius,
		vVelocity = direction * speed,
	}
	local data = {cast = 1, targets = {}, thinker = thinker}
	local id = ProjectileManager:CreateLinearProjectile(info)
	thinker.id = id
	self.projectiles[id] = data
	table.insert(self.thinkers, thinker)

	local ability = caster:FindAbilityByName("db_converge")
	if ability then
		ability:SetActivated(true)
		caster:SwapAbilities("db_celestial_hammer", "db_converge", false, true)
		ability:StartCooldown(ability:GetCooldown(-1))
	end

	caster:AddNewModifier(caster, self, "modifier_db_celestial_hammer_nohammer", {})

	data.effect = self:PlayEffects1(caster:GetOrigin(), distance, direction * speed)
end

db_celestial_hammer.projectiles = {}
db_celestial_hammer.thinkers = {}
function db_celestial_hammer:OnProjectileThinkHandle(handle)
	local data = self.projectiles[handle]
	if data.thinker:IsNull() then return end
	local radius = self:GetSpecialValueFor("projectile_radius")

	if data.cast == 1 then
		local location = ProjectileManager:GetLinearProjectileLocation(handle)
		data.thinker:SetOrigin(location)
		GridNav:DestroyTreesAroundPoint(location, radius, false)
	elseif data.cast == 2 then
		local location = ProjectileManager:GetTrackingProjectileLocation(handle)
		data.thinker:SetOrigin(location)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _,enemy in pairs(enemies) do
			if not data.targets[enemy] then
				data.targets[enemy] = true
				self:HammerHit(enemy, location)
			end
		end
		GridNav:DestroyTreesAroundPoint(location, radius, false)
	end
end
function db_celestial_hammer:OnProjectileHitHandle(target, location, handle)
	local data = self.projectiles[handle]
	if not handle then return end

	if data.cast == 1 then
		if target then
			self:HammerHit(target, location)
			return false
		end
		local loc = GetGroundPosition(location, self:GetCaster())
		data.thinker:SetOrigin(loc)
		local mod = data.thinker:FindModifierByName("modifier_db_celestial_hammer_thinker")
		mod:Delay()
		self:StopEffects(data.effect)
		self.projectiles[handle] = nil
	elseif data.cast == 2 then
		for i, thinker in pairs(self.thinkers) do
			if thinker == data.thinker then
				table.remove(self.thinkers, i)
				break
			end
		end
		local mod = data.thinker:FindModifierByName("modifier_db_celestial_hammer_thinker")
		mod:Destroy()

		local ability = self:GetCaster():FindAbilityByName("db_converge")
		if ability then
			self:GetCaster():SwapAbilities("db_celestial_hammer", "db_converge", true, false)
		end

		local nohammer = self:GetCaster():FindModifierByName("modifier_db_celestial_hammer_nohammer")
		if nohammer then
			nohammer:Decrement()
		end

		local converge = self:GetCaster():FindModifierByName("modifier_db_celestial_hammer")
		if converge then
			converge:Destroy()
		end

		self.projectiles[handle] = nil

		self:PlayEffects3()
	end
end
function db_celestial_hammer:HammerHit(target, location)
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor("hammer_damage"),
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}
	ApplyDamage(damageTable)

	self:PlayEffects2(target)
end
function db_celestial_hammer:Converge()
	local target
	for i, thinker in ipairs(self.thinkers) do
		target = thinker
		break
	end
	if not target then return end
	if self.projectiles[target.id] then
		self:StopEffects(self.projectiles[target.id].effect)
		self.projectiles[target.id] = nil
		ProjectileManager:DestroyLinearProjectile(target.id)
	end

	local mod = target:FindModifierByName("modifier_db_celestial_hammer_thinker")
	mod:Return()

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_db_celestial_hammer", {target = target:entindex()})

	EmitSoundOn("Hero_Dawnbreaker.Converge.Cast", self:GetCaster())
end
function db_celestial_hammer:PlayEffects1(start, distance, velocity)
	local min_rate = 1
	local duration = distance / velocity:Length2D()
	local rotation = 0.5

	local rate = rotation / duration
	while rate < min_rate do
		rotation = rotation + 1
		rate = rotation / duration
	end

	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(effect_cast, 0, start)
	ParticleManager:SetParticleControl(effect_cast, 1, velocity)
	ParticleManager:SetParticleControl(effect_cast, 4, Vector(rate, 0, 0))

	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Cast", self:GetCaster())

	return effect_cast
end
function db_celestial_hammer:PlayEffects2(target)
	local radius = self:GetSpecialValueFor("projectile_radius")

	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Damage", target)
end
function db_celestial_hammer:PlayEffects3()
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(effect_cast, 3, hTarget, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end
function db_celestial_hammer:StopEffects(effect)
	ParticleManager:DestroyParticle(effect, false)
	ParticleManager:ReleaseParticleIndex(effect)
end


-------------------------------
-- Celestial Hammer Modifier --
-------------------------------
modifier_db_celestial_hammer = class({})
function modifier_db_celestial_hammer:IsHidden() return false end
function modifier_db_celestial_hammer:IsDebuff() return false end
function modifier_db_celestial_hammer:IsPurgable() return true end
function modifier_db_celestial_hammer:OnCreated(kv)
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.speed = self:GetAbility():GetSpecialValueFor("projectile_speed")
	self.speed_pct = self:GetAbility():GetSpecialValueFor("travel_speed_pct")
	self.duration = self:GetAbility():GetSpecialValueFor("flare_debuff_duration")
	self.interval = 0.1
	self.max_range = self:GetAbility():GetTalentSpecialValueFor("range") + TalentValue(self:GetCaster(), "special_bonus_unique_dawnbreaker_celestial_hammer_cast_range")
	self.origin = self.parent:GetOrigin()

	self.prev_pos = self.parent:GetOrigin()
	self.actual_speed = self.speed * self.speed_pct / 100
	self.target = EntIndexToHScript(kv.target)

	local direction = self.target:GetOrigin() - self.parent:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()
	self.parent:SetForwardVector(direction)

	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end

	self:StartIntervalThink(self.interval)
	self:OnIntervalThink()

	self:PlayEffects()
end
function modifier_db_celestial_hammer:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController(self)
end
function modifier_db_celestial_hammer:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_TURNING}
end
function modifier_db_celestial_hammer:GetModifierDisableTurning() return 1 end
function modifier_db_celestial_hammer:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end
function modifier_db_celestial_hammer:OnIntervalThink()
	local thinker = CreateModifierThinker(self.parent, self.ability, "modifier_db_celestial_hammer_trail", {duration = self.duration, x = self.prev_pos.x, y = self.prev_pos.y}, self.parent:GetOrigin(), self.parent:GetTeamNumber(), false)
	self.prev_pos = self.parent:GetOrigin()
end
function modifier_db_celestial_hammer:UpdateHorizontalMotion(me, dt)
	local dist = (self.origin - me:GetOrigin()):Length2D()
	if dist > self.max_range then
		self:Destroy()
		return
	end

	local pos = me:GetOrigin() + me:GetForwardVector() * self.actual_speed * dt

	pos2 = GetGroundPosition(pos, me)
	me:SetOrigin(pos2)
end
function modifier_db_celestial_hammer:OnHorizontalMotionInterrupted() self:Destroy() end
function modifier_db_celestial_hammer:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_trail.vpcf", PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlForward(effect_cast, 0, self.parent:GetForwardVector())
	self:AddParticle(effect_cast, false, false, -1, false, false)
end


--------------------------------
-- Celestial Hammer No Hammer --
--------------------------------
modifier_db_celestial_hammer_nohammer = class({})
function modifier_db_celestial_hammer_nohammer:IsHidden() return true end
function modifier_db_celestial_hammer_nohammer:IsDebuff() return false end
function modifier_db_celestial_hammer_nohammer:IsPurgable() return false end
function modifier_db_celestial_hammer_nohammer:OnCreated(kv)
	if not IsServer() then return end
	self:IncrementStackCount()
	self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_dawnbreaker_celestial_hammer_caster", {})
end
function modifier_db_celestial_hammer_nohammer:OnRefresh(kv) self:OnCreated(kv) end
function modifier_db_celestial_hammer_nohammer:OnDestroy()
	if not IsServer() then return end
	if self:GetCaster() and self:GetCaster():IsHero() then
		local Hammer = self:GetCaster():GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON)
		if Hammer ~= nil then
			self:GetCaster():RemoveModifierByName("modifier_dawnbreaker_celestial_hammer_caster")
			Hammer:RemoveEffects(EF_NODRAW)
		end
	end
end
function modifier_db_celestial_hammer_nohammer:Decrement()
	self:DecrementStackCount()
	if self:GetStackCount() < 1 then
		self:Destroy()
	end
end


------------------------------
-- Celestial Hammer Thinker --
------------------------------
modifier_db_celestial_hammer_thinker = class({})
function modifier_db_celestial_hammer_thinker:IsHidden() return true end
function modifier_db_celestial_hammer_thinker:IsDebuff() return false end
function modifier_db_celestial_hammer_thinker:IsPurgable() return false end
function modifier_db_celestial_hammer_thinker:OnCreated(kv)
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.name = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_return.vpcf"
	self.speed = self:GetAbility():GetSpecialValueFor("projectile_speed")
	self.delay = self:GetAbility():GetSpecialValueFor("pause_duration")
	self.duration = self:GetAbility():GetSpecialValueFor("flare_debuff_duration")
	self.vision = 200
	self.interval = 0.1
	self.max_return = 1.5

	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Projectile", self.parent)
end
function modifier_db_celestial_hammer_thinker:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove(self:GetParent())
end
function modifier_db_celestial_hammer_thinker:OnIntervalThink()
	if not self.converge then self:Return() return end
	local thinker = CreateModifierThinker(self.caster, self.ability, "modifier_db_celestial_hammer_trail", {duration = self.duration, x = self.prev_pos.x, y = self.prev_pos.y}, self.parent:GetOrigin(), self.caster:GetTeamNumber(), false)
	self.prev_pos = self.parent:GetOrigin()
end
function modifier_db_celestial_hammer_thinker:Delay()
	self:PlayEffects1()
	self:StartIntervalThink(self.delay)
	AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.vision, self.delay, false)
end
function modifier_db_celestial_hammer_thinker:Return()
	if self.converge then return end

	self.converge = true
	self.prev_pos = self.parent:GetOrigin()
	self:StartIntervalThink(self.interval)
	self:OnIntervalThink()

	self.distance = (self.parent:GetOrigin() - self.caster:GetOrigin()):Length2D()
	if self.distance > self.speed * self.max_return then
		self.speed = self.distance / self.max_return
	end

	local info = {
		Target = self.caster,
		Source = self.parent,
		Ability = self.ability,	
		
		EffectName = self.name,
		iMoveSpeed = self.speed,
		bDodgeable = false,
	}
	local data = {
		cast = 2,
		targets = {},
		thinker = self.parent,
	}
	local id = ProjectileManager:CreateTrackingProjectile(info)
	self.ability.projectiles[id] = data

	self:PlayEffects2()
end
function modifier_db_celestial_hammer_thinker:PlayEffects1()
	local direction = self:GetParent():GetOrigin() - self:GetCaster():GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_grounded.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self:GetCaster():GetOrigin())
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction)
	self.effect_cast = effect_cast
	self:AddParticle(effect_cast, false, false, -1, false, false)

	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Impact", self.parent)
end
function modifier_db_celestial_hammer_thinker:PlayEffects2()
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
	end
	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Return", self.parent)
end


----------------------------
-- Celestial Hammer Trail --
----------------------------
modifier_db_celestial_hammer_trail = class({})
function modifier_db_celestial_hammer_trail:IsHidden() return true end
function modifier_db_celestial_hammer_trail:IsDebuff() return false end
function modifier_db_celestial_hammer_trail:IsPurgable() return false end
function modifier_db_celestial_hammer_trail:OnCreated(kv)
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor("flare_radius")

	self.prev_pos = Vector(kv.x, kv.y, 0)
	self.prev_pos = GetGroundPosition(self.prev_pos, self:GetParent())

	self:PlayEffects(kv.duration)
end
function modifier_db_celestial_hammer_trail:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove(self:GetParent())
end
function modifier_db_celestial_hammer_trail:IsAura() return true end
function modifier_db_celestial_hammer_trail:GetModifierAura() return "modifier_db_celestial_hammer_debuff" end
function modifier_db_celestial_hammer_trail:GetAuraRadius() return self.radius end
function modifier_db_celestial_hammer_trail:GetAuraDuration() return 0.5 end
function modifier_db_celestial_hammer_trail:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_db_celestial_hammer_trail:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_db_celestial_hammer_trail:GetAuraSearchFlags() return 0 end
function modifier_db_celestial_hammer_trail:PlayEffects(duration)
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_burning_trail.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.prev_pos)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(duration, 0, 0))
	ParticleManager:SetParticleControl(effect_cast, 3, Vector(self.radius, self.radius, self.radius))
	ParticleManager:ReleaseParticleIndex(effect_cast)
end


-----------------------------
-- Celestial Hammer Debuff --
-----------------------------
modifier_db_celestial_hammer_debuff = class({})
function modifier_db_celestial_hammer_debuff:IsHidden() return false end
function modifier_db_celestial_hammer_debuff:IsDebuff() return true end
function modifier_db_celestial_hammer_debuff:IsPurgable() return true end
function modifier_db_celestial_hammer_debuff:GetEffectName()
	return "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf"
end
function modifier_db_celestial_hammer_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_db_celestial_hammer_debuff:OnCreated(kv)
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("burn_damage")
	self.interval = self:GetAbility():GetSpecialValueFor("burn_interval")
	self.slow = self:GetAbility():GetSpecialValueFor("move_slow")
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.damage * self.interval,
		damage_type = self.abilityDamageType,
		ability = self:GetAbility(),
	}
	self:StartIntervalThink(self.interval)
	self:OnIntervalThink()
end
function modifier_db_celestial_hammer_debuff:OnIntervalThink()
	ApplyDamage(self.damageTable)
end
function modifier_db_celestial_hammer_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_db_celestial_hammer_debuff:GetModifierMoveSpeedBonus_Percentage() 
	if self.slow ~= nil then
		return -self.slow
	else
		return 0
	end		 
end



function TalentValue(caster, talent_name)
	local talent = caster:FindAbilityByName(talent_name)
	if talent and talent:GetLevel() > 0 then
		return talent:GetSpecialValueFor("value")
	end
	return 0
end