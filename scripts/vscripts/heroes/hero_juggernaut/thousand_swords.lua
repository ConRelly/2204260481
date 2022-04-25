LinkLuaModifier("modifier_thousand_swords", "heroes/hero_juggernaut/thousand_swords", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_thousand_swords_thinker", "heroes/hero_juggernaut/thousand_swords", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thousand_swords_katana", "heroes/hero_juggernaut/thousand_swords", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thousand_swords_katanas_count", "heroes/hero_juggernaut/thousand_swords", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thousand_swords_katanas_limit", "heroes/hero_juggernaut/thousand_swords", LUA_MODIFIER_MOTION_NONE)


--------------
-- Converge --
--------------
thousand_swords_converge = class({})
function thousand_swords_converge:CastFilterResultLocation(loc)
	if not IsServer() then return end
	if self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_count"):GetStackCount() < 1 then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
function thousand_swords_converge:GetCustomCastErrorLocation(loc)
	if not IsServer() then return end
	if self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_count"):GetStackCount() < 1 then
		return "No Katanas"
	end
	return ""
end
function thousand_swords_converge:OnSpellStart()
	local teleport = nil
	local main = self:GetCaster():FindAbilityByName("thousand_swords")
	if main then
		local findng = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, 160, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_CLOSEST, false)
		for i, founded_katana in ipairs(findng) do
			if founded_katana:HasModifier("modifier_thousand_swords_katana") then
				teleport = founded_katana
				break
			end
		end
		self:SetActivated(false)
		main:Converge(teleport)
	end
end
--[[
function thousand_swords_converge:GetCustomCastError()
	if not IsServer() then return end
	if self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_count"):GetStackCount() < 1 then
		return "No Katanas"
	end
	return ""
end
function thousand_swords_converge:OnSpellStart()
	local main = self:GetCaster():FindAbilityByName("thousand_swords")
	if main then
		main:Converge(self:GetCursorPosition())
		self:SetActivated(false)
	end
end
]]

---------------------
-- Thousand Swords --
---------------------
thousand_swords = class({})
function thousand_swords:GetCooldown(lvl)
    return self:GetSpecialValueFor("cooldown") / self:GetCaster():GetCooldownReduction()
end
function thousand_swords:CastFilterResultLocation(loc)
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_thousand_swords_katanas_limit") then
		if self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_limit"):GetStackCount() < 1 then
			return UF_FAIL_CUSTOM
		end
	end
	return UF_SUCCESS
end
function thousand_swords:GetCustomCastErrorLocation(loc)
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_thousand_swords_katanas_limit") then
		if self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_limit"):GetStackCount() < 1 then
			return "No Katanas left"
		end
	end
	return ""
end
function thousand_swords:GetIntrinsicModifierName() return "modifier_thousand_swords_katanas_count" end
function thousand_swords:Spawn() if not IsServer() then return end end
function thousand_swords:GetCastRange(location, target)
	return self:GetSpecialValueFor("range")
end
function thousand_swords:OnUpgrade()
	local converge = self:GetCaster():FindAbilityByName("thousand_swords_converge")
	if not converge then
		converge = self:GetCaster():AddAbility("thousand_swords_converge")
	end
	converge:SetLevel(self:GetLevel())
end
function thousand_swords:OnSpellStart()
	if self:GetCaster():HasModifier("modifier_thousand_swords_katanas_limit") then
		if self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_limit"):GetStackCount() < 1 then
			return
		end
	end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("katana_radius")
	local speed = self:GetSpecialValueFor("katana_speed")
	local distance = self:GetSpecialValueFor("range")
	local direction = point - caster:GetOrigin()
	local Length = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()
	distance = math.min(distance, Length)

	local thinker = CreateModifierThinker(caster, self, "modifier_thousand_swords_thinker", {}, caster:GetOrigin(), self:GetCaster():GetTeamNumber(), false)

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
		-- bDeleteOnHit = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		
		EffectName = "",
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

	local ability = caster:FindAbilityByName("thousand_swords_converge")
	if ability then
		ability:StartCooldown(ability:GetCooldown(1))
	end
	
	local Katanas = self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_count")
	Katanas:SetStackCount(Katanas:GetStackCount() + 1)
	
	data.effect = self:PlayEffects1(caster:GetOrigin(), distance, direction * speed, radius, point)
end

thousand_swords.projectiles = {}
thousand_swords.thinkers = {}
function thousand_swords:OnProjectileThinkHandle(handle)
	local data = self.projectiles[handle]
	if data.thinker:IsNull() then return end
	local radius = self:GetSpecialValueFor("katana_radius")

	if data.cast == 1 then
		local location = ProjectileManager:GetLinearProjectileLocation(handle)
		data.thinker:SetOrigin(location)
--		GridNav:DestroyTreesAroundPoint(location, radius, false)
	elseif data.cast == 2 then
		local location = ProjectileManager:GetTrackingProjectileLocation(handle)
		data.thinker:SetOrigin(location)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _,enemy in pairs(enemies) do
			if not data.targets[enemy] then
				data.targets[enemy] = true
				self:HammerHit(enemy)
			end
		end
--		GridNav:DestroyTreesAroundPoint(location, radius, false)
	end
end
function thousand_swords:OnProjectileHitHandle(target, location, handle)
	local data = self.projectiles[handle]
	if not handle then return end

	if data.cast == 1 then
		if target then
			self:HammerHit(target)
			return false
		end
		local loc = GetGroundPosition(location, self:GetCaster())
		data.thinker:SetOrigin(loc)
		local mod = data.thinker:FindModifierByName("modifier_thousand_swords_thinker")
		mod:Delay()
		self:StopEffects(data.effect)
		self.projectiles[handle] = nil
	elseif data.cast == 2 then
		for i, thinker in pairs(self.thinkers) do
			if thinker == data.thinker then
				local mod = data.thinker:FindModifierByName("modifier_thousand_swords_thinker")
				if not mod:IsNull() then
					mod:Destroy()
				end
				table.remove(self.thinkers, i)
			end
		end

		local converge = self:GetCaster():FindModifierByName("modifier_thousand_swords")
		if converge and not converge:IsNull() then
			converge:Destroy()
		end

		self.projectiles[handle] = nil
		
		local Katanas = self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_count")
		Katanas:SetStackCount(Katanas:GetStackCount() - 1)
		if Katanas:GetStackCount() < 0 then
			Katanas:SetStackCount(0)
		end
	end
end
function thousand_swords:HammerHit(target)
	ApplyDamage({
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor("katana_damage"),
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	})

	self:PlayEffects2(target)
end
function thousand_swords:Converge(teleport)
	for i, thinker in ipairs(self.thinkers) do
		if not thinker then return end
		local place_again = false
		
		if teleport then
			if thinker:GetOrigin() == teleport:GetOrigin() then
			
				for _, enemy in pairs(FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), thinker:GetOrigin(), nil, self:GetSpecialValueFor("katana_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)) do
					
					ApplyDamage({
						victim		= enemy,
						attacker	= self:GetCaster(),
						ability		= self,
						damage		= self:GetSpecialValueFor("katana_damage"),
						damage_type	= self:GetAbilityDamageType(),
					})

					local impact_particle = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_kill_slash2.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
					ParticleManager:SetParticleControlEnt(impact_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(impact_particle)
				end
				
				self:GetCaster():SetAbsOrigin(thinker:GetOrigin())
				FindClearSpaceForUnit(self:GetCaster(), thinker:GetOrigin(), false)
				place_again = true
			end
		end
		
		if self.projectiles[thinker.id] then
			self:StopEffects(self.projectiles[thinker.id].effect)
			self.projectiles[thinker.id] = nil
			ProjectileManager:DestroyLinearProjectile(thinker.id)
		end
		
		local mod = thinker:FindModifierByName("modifier_thousand_swords_thinker")
		mod:Return(place_again)
		
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_thousand_swords", {target = thinker:entindex()})
	end

	EmitSoundOn("Hero_Dawnbreaker.Converge.Cast", self:GetCaster())
end
function thousand_swords:PlayEffects1(start, distance, velocity, radius, point)
	local duration = distance / velocity:Length2D()

	local effect_cast = ParticleManager:CreateParticle("particles/beta_particles_123123/throw_katana.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(effect_cast, 0, start + Vector(0, 0, 100))
	ParticleManager:SetParticleControl(effect_cast, 1, point + Vector(0, 0, 100))
	ParticleManager:SetParticleControl(effect_cast, 4, Vector(duration, radius, 0))
	ParticleManager:SetParticleControl(effect_cast, 5, Vector(self:GetSpecialValueFor("katana_speed"), 0, 0))

	EmitSoundOn("Hero_Centaur.DoubleEdge.TI9_layer", self:GetCaster())

	return effect_cast
end
function thousand_swords:PlayEffects2(target)
	local radius = self:GetSpecialValueFor("katana_radius")

	local impact = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(impact, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(impact)
	--[[
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(effect_cast)
	]]
	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Damage", target)
end
function thousand_swords:StopEffects(effect)
	ParticleManager:DestroyParticle(effect, false)
	ParticleManager:ReleaseParticleIndex(effect)
end


------------------------------
-- Thousand Swords Modifier --
------------------------------
modifier_thousand_swords = class({})
function modifier_thousand_swords:IsHidden() return false end
function modifier_thousand_swords:IsDebuff() return false end
function modifier_thousand_swords:IsPurgable() return true end
function modifier_thousand_swords:OnCreated(kv)
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.speed = self:GetAbility():GetSpecialValueFor("katana_speed")
	self.speed_pct = self:GetAbility():GetSpecialValueFor("travel_speed_pct")

	self.target = EntIndexToHScript(kv.target)

	self:PlayEffects()
end
function modifier_thousand_swords:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_trail.vpcf", PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlForward(effect_cast, 0, self.parent:GetForwardVector())
	self:AddParticle(effect_cast, false, false, -1, false, false)
end


-----------------------------
-- Thousand Swords Thinker --
-----------------------------
modifier_thousand_swords_thinker = class({})
function modifier_thousand_swords_thinker:IsHidden() return true end
function modifier_thousand_swords_thinker:IsDebuff() return false end
function modifier_thousand_swords_thinker:IsPurgable() return false end
function modifier_thousand_swords_thinker:OnCreated(kv)
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.name = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_return.vpcf"
	self.speed = self:GetAbility():GetSpecialValueFor("katana_speed")
	self.delay = self:GetAbility():GetSpecialValueFor("pause_duration")

	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Projectile", self.parent)
end
function modifier_thousand_swords_thinker:OnIntervalThink()
	AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), 350, 1, false)
end
function modifier_thousand_swords_thinker:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove(self:GetParent())
end
function modifier_thousand_swords_thinker:Delay()
	self:PlayEffects1()
	GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), 350, false)
	AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), 350, 1, false)

	self.karana = CreateUnitByName("npc_dota_invisible_vision_source", self.parent:GetAbsOrigin(), false, self.caster, self.caster, self.caster:GetTeam())
	self.karana:AddNewModifier(self.caster, self.ability, "modifier_phased", {})
	self.karana:AddNewModifier(self.caster, self.ability, "modifier_kill", {})
	self.karana:AddNewModifier(self.caster, self.ability, "modifier_thousand_swords_katana", {})

	self:StartIntervalThink(1)

	local converge = self.caster:FindAbilityByName("thousand_swords_converge")
	if converge and converge:IsActivated() == false then
		converge:SetActivated(true)
	end
end
function modifier_thousand_swords_thinker:Return(place_again)
	self.distance = (self.parent:GetOrigin() - self.caster:GetOrigin()):Length2D()
	local speed = self.distance * 2
	if speed < 1500 then
		speed = 1500
	end
	
	local info = {
		Target = self.caster,
		Source = self.parent,
		Ability = self.ability,	
		
		EffectName = "particles/econ/items/drow/drow_arcana/drow_arcana_base_attack_v2.vpcf",
		iMoveSpeed = speed,
		bDodgeable = false,
	}
	local data = {
		cast = 2,
		targets = {},
		thinker = self.parent,
	}
	local id = ProjectileManager:CreateTrackingProjectile(info)
	self.ability.projectiles[id] = data

	if self.karana then
		self.karana:RemoveModifierByName("modifier_kill")
	end

	self:PlayEffects2()

	if place_again then
		Timers:CreateTimer(0.1, function()
			local pass = true
			if self.caster:HasModifier("modifier_thousand_swords_katanas_limit") then
				if self.caster:FindModifierByName("modifier_thousand_swords_katanas_limit"):GetStackCount() < 1 then
					pass = false
				end
			end
			if pass == true then
				self.caster:SetCursorPosition(self.caster:GetOrigin())
				local main = self.caster:FindAbilityByName("thousand_swords")
				if main then
					main:OnSpellStart()
				end
				local converge = self.caster:FindAbilityByName("thousand_swords_converge")
				if converge then
					converge:StartCooldown(2)
				end
			end
		end)
	end
end
function modifier_thousand_swords_thinker:PlayEffects1()
	local direction = self:GetParent():GetOrigin() - self:GetCaster():GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

	self.effect_cast = ParticleManager:CreateParticle("particles/beta_particles_123123/throw_katana_grounded.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetOrigin())
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Impact", self.parent)
	EmitSoundOn("Hero_PhantomAssassin.Arcana_Layer", self.parent)
end
function modifier_thousand_swords_thinker:PlayEffects2()
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
	end
	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Return", self.parent)
end
















modifier_thousand_swords_katana = class({})
function modifier_thousand_swords_katana:IsHidden() return false end
function modifier_thousand_swords_katana:IsPurgable() return false end
function modifier_thousand_swords_katana:RemoveOnDeath() return false end
function modifier_thousand_swords_katana:OnCreated()
	if not IsServer() then return end
end
function modifier_thousand_swords_katana:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
--		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
end


modifier_thousand_swords_katanas_count = class({})
function modifier_thousand_swords_katanas_count:IsHidden() return true end
function modifier_thousand_swords_katanas_count:IsPurgable() return false end
function modifier_thousand_swords_katanas_count:RemoveOnDeath() return false end
function modifier_thousand_swords_katanas_count:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_thousand_swords_katanas_count:OnIntervalThink()
	if not self:GetCaster():HasModifier("modifier_thousand_swords_katanas_limit") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_thousand_swords_katanas_limit", {})
	end

	if self:GetStackCount() == 0 then
		local converge = self:GetCaster():FindAbilityByName("thousand_swords_converge")
		if converge and converge:IsActivated() == false then
			converge:SetActivated(true)
		end
	end
end
function modifier_thousand_swords_katanas_count:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end

function modifier_thousand_swords_katanas_count:GetModifierOverrideAbilitySpecial(params)
	if self:GetParent() == nil or params.ability == nil then return 0 end

	if self:GetCaster():HasScepter() and params.ability:GetAbilityName() == "thousand_swords" and params.ability_special_value == "limit" then return 1 end

	return 0
end

function modifier_thousand_swords_katanas_count:GetModifierOverrideAbilitySpecialValue(params)
	if self:GetCaster():HasScepter() and params.ability:GetAbilityName() == "thousand_swords" and params.ability_special_value == "limit" then
		local SpecialLevel = params.ability_special_level
		return params.ability:GetLevelSpecialValueNoOverride("limit", SpecialLevel) * 3
	end

	return 0
end


modifier_thousand_swords_katanas_limit = class({})
function modifier_thousand_swords_katanas_limit:IsHidden() return false end
function modifier_thousand_swords_katanas_limit:IsPurgable() return false end
function modifier_thousand_swords_katanas_limit:RemoveOnDeath() return false end
function modifier_thousand_swords_katanas_limit:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_thousand_swords_katanas_limit:OnIntervalThink()
	if not IsServer() then return end
	local limit = self:GetAbility():GetSpecialValueFor("limit") - self:GetCaster():FindModifierByName("modifier_thousand_swords_katanas_count"):GetStackCount()
	self:SetStackCount(limit)
end
