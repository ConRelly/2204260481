-----------------------------------
--      FLURRY       --
-----------------------------------
leesin_flurry = class({})
LinkLuaModifier("modifier_flurry", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flurry_stacks", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)

function leesin_flurry:GetIntrinsicModifierName()
    return "modifier_flurry"
end

modifier_flurry = class({})
function modifier_flurry:IsDebuff() return false end
function modifier_flurry:IsHidden() return true end
function modifier_flurry:IsPurgable() return false end
function modifier_flurry:IsPurgeException() return false end
function modifier_flurry:RemoveOnDeath() return false end
function modifier_flurry:DeclareFunctions()
    local decFuns =
    {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }
    return decFuns
end
function modifier_flurry:OnAbilityFullyCast( params )
	if params.unit == self:GetCaster() and not params.ability:IsItem() then
		local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_flurry_stacks", {duration = self:GetAbility():GetSpecialValueFor("duration")})
		modifier:SetStackCount(self:GetAbility():GetSpecialValueFor("max_attacks"))
	end
end
function modifier_flurry:GetModifierManaBonus()
	return self:GetCaster():GetIntellect() * (-1) * 12
end
function modifier_flurry:GetModifierConstantManaRegen()
	return self:GetCaster():GetIntellect() * (-1) * 0.05
end

modifier_flurry_stacks = class({})
function modifier_flurry_stacks:IsDebuff() return false end
function modifier_flurry_stacks:IsHidden() return false end
function modifier_flurry_stacks:IsPurgable() return true end
function modifier_flurry_stacks:DeclareFunctions()
    local decFuns =
    {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return decFuns
end
function modifier_flurry_stacks:OnAttack( params)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local energy = ability:GetSpecialValueFor("energy")
		local target = params.target if target==nil then target = params.unit end
		if target:GetTeamNumber()==self:GetParent():GetTeamNumber() then
			return false
		end
		
		if not self:GetParent():PassivesDisabled() and params.attacker == caster and self:GetStackCount() > 0 then
			caster:GiveMana(energy)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, energy, nil)
			if caster:HasScepter() then
				for i = 0, 8, 1 do
					local spell = self:GetCaster():GetAbilityByIndex(i)
					local cooldown = spell:GetCooldownTimeRemaining()
					local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce")
					spell:EndCooldown()
					spell:StartCooldown(cooldown - cooldown_reduce)
				end
			end
			self:DecrementStackCount()
			if self:GetStackCount() == 0 then
				self:Destroy()
			end
		end
	end
end
function modifier_flurry_stacks:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster():HasScepter() then
		return 700
	end
	return self:GetAbility():GetSpecialValueFor("attackspeed")
end

-----------------------------------
--      SONIC WAVE       --
-----------------------------------
leesin_sonic_wave = class({})
LinkLuaModifier("modifier_sonic_wave_mark", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)

function leesin_sonic_wave:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end
function leesin_sonic_wave:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()
	local sound_cast = "Hero_Abaddon.DeathCoil.Cast"
	local width = ability:GetSpecialValueFor( "proj_width" )
	local speed = ability:GetSpecialValueFor( "proj_speed" )
	local range = ability:GetSpecialValueFor( "range" )

	EmitSoundOn(sound_cast, caster)
	local direction = (target_point - caster:GetAbsOrigin()):Normalized() 
	local spawn_point = caster:GetAbsOrigin()
	
	local sonic_proj = {
		Ability = ability,
		EffectName = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf",
		vSpawnOrigin = spawn_point,
		fDistance = range + caster:GetCastRangeBonus(),
		fStartRadius = width,
		fEndRadius = width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,                                                          
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,                           
		bDeleteOnHit = true,
		vVelocity = direction * speed * Vector(1, 1, 0),
		bProvidesVision = true,
		iVisionRadius = width,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}
	self.id = ProjectileManager:CreateLinearProjectile(sonic_proj)
end

function leesin_sonic_wave:OnProjectileHit( target, location )
	if not target then return end
	
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor( "damage" )
	local duration = self:GetSpecialValueFor( "mark_duration" )
	local realdamage = damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = realdamage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)
	if target:IsAlive() then
		caster:GetAbilityByIndex(6):SetLevel(self:GetLevel())
		caster:SwapAbilities("leesin_sonic_wave", "leesin_resonating_strike", false, true)
		target:AddNewModifier(caster, self, "modifier_sonic_wave_mark", {duration = duration})
	end
	EmitSoundOnLocationWithCaster( target:GetAbsOrigin(), "Hero_Abaddon.DeathCoil.Target", caster )
	
	return true
end

modifier_sonic_wave_mark = class({})
function modifier_sonic_wave_mark:IsDebuff() return true end
function modifier_sonic_wave_mark:IsHidden() return false end
function modifier_sonic_wave_mark:IsPurgable() return true end
function modifier_sonic_wave_mark:GetEffectName()
	return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
end
function modifier_sonic_wave_mark:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_sonic_wave_mark:OnDestroy()
	self:GetCaster():SwapAbilities("leesin_resonating_strike", "leesin_sonic_wave", false, true)
end
function modifier_sonic_wave_mark:CheckState()	
	local state = {[MODIFIER_STATE_INVISIBLE] = false}
	return state
end
function modifier_sonic_wave_mark:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

-----------------------------------
--      RESONATING STRIKE       --
-----------------------------------
leesin_resonating_strike = class({})
LinkLuaModifier( "modifier_resonating_strike", "abilities/leesin", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_resonating_strike_check", "abilities/leesin", LUA_MODIFIER_MOTION_NONE )

function leesin_resonating_strike:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
	local target = nil
    local modifier_movement = "modifier_resonating_strike"
	local dash_range = ability:GetSpecialValueFor("range")
	
	if IsServer() then
		--Begin moving to target point
		caster:AddNewModifier(caster, ability, modifier_movement, {})
	end
end

function leesin_resonating_strike:GetIntrinsicModifierName()
    return "modifier_resonating_strike_check"
end

modifier_resonating_strike_check = class({})
function modifier_resonating_strike_check:IsDebuff() return false end
function modifier_resonating_strike_check:IsHidden() return true end
function modifier_resonating_strike_check:IsPurgable() return false end
function modifier_resonating_strike_check:IsPurgeException() return false end
function modifier_resonating_strike_check:RemoveOnDeath() return false end
function modifier_resonating_strike_check:OnCreated()
	self:StartIntervalThink(0.03)
end
function modifier_resonating_strike_check:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local range = ability:GetSpecialValueFor("range")
	local target = false
	local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			caster:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			FIND_FARTHEST,	-- int, order filter
			false	-- bool, can grow cache
		)
		
		for _,enemy in pairs(enemies) do
			if enemy:HasModifier("modifier_sonic_wave_mark") then
				target = true
			end
		end
		
		if target == true then
			ability:SetActivated(true)
		else
			ability:SetActivated(false)
		end
end

modifier_resonating_strike = class({})
function modifier_resonating_strike:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.range = self.ability:GetSpecialValueFor("range")
		
		self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
		
		local target = nil
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_FARTHEST,	-- int, order filter
			false	-- bool, can grow cache
		)
		
		for _,enemy in pairs(enemies) do
			if enemy:HasModifier("modifier_sonic_wave_mark") then
				target = enemy
			end
		end
		
		self.point = target:GetAbsOrigin()
		local startpoint = self.caster:GetAbsOrigin()
		
		self.target = target --save target
		self.startpoint = startpoint --save starting point

		--Ability specials
		self.dash_speed = self.ability:GetSpecialValueFor("dash_speed")
		
		--variables
		self.time_elapsed = 0

		--calculate distance
		self.distance = (self.caster:GetAbsOrigin() - self.point):Length2D()
		self.dash_time = self.distance / self.dash_speed
		self.direction = (self.point - self.caster:GetAbsOrigin()):Normalized()
		
		self.caster:SetForwardVector(self.direction)
		
		self:ApplyHorizontalMotionController()
	end
end

function modifier_resonating_strike:IsHidden() return true end
function modifier_resonating_strike:IsPurgable() return false end
function modifier_resonating_strike:IsDebuff() return false end
function modifier_resonating_strike:IgnoreTenacity() return true end
function modifier_resonating_strike:IsMotionController() return true end
function modifier_resonating_strike:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_resonating_strike:UpdateHorizontalMotion( me, dt)
	if IsServer() then
		self.distance = (self.caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
		self.dash_time = self.distance / self.dash_speed
		self.direction = (self.target:GetOrigin() - self.caster:GetAbsOrigin()):Normalized()
		
		-- Check if we're still dashing
		self.time_elapsed = self.time_elapsed + dt
		if self.distance > 80 then

			-- Go forward
			local new_location = self.caster:GetAbsOrigin() + self.direction * self.dash_speed * dt
			self.caster:SetAbsOrigin(new_location)       
		else            
			self:Destroy()
		end
	end 
end

function modifier_resonating_strike:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_resonating_strike:OnRemoved()
	if IsServer() then
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		local damageamp = self:GetAbility():GetSpecialValueFor("low_health_mult")
		
		local caster = self:GetParent()
		local ability = self:GetAbility()
		
		self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
		
		local realdamage = MissingHealthAmp( self.target, damage, damageamp )

		local damageTable = {
			victim = self.target,
			attacker = caster,
			damage = realdamage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability, --Optional.
		}
		ApplyDamage(damageTable)
		self.target:RemoveModifierByName("modifier_sonic_wave_mark")
		caster:SetAttacking(self.target)
		
		if self.EndCallback then
		self.EndCallback()
		end
		
		self:GetParent():InterruptMotionControllers( true )
	end
end
function modifier_resonating_strike:CheckState()	
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state	
end

function modifier_resonating_strike:SetEndCallback( func ) 
	self.EndCallback = func
end

-----------------------------------
--      SAFEGUARD       --
-----------------------------------
--[[leesin_safeguard = class({})
LinkLuaModifier("modifier_safeguard", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_safeguard_dash", "abilities/leesin", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_safeguard_switch", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)

function leesin_safeguard:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local spell_duration= ability:GetSpecialValueFor("spell_duration")
	local duration= ability:GetSpecialValueFor("duration")
	
	caster:AddNewModifier(caster, ability, "modifier_safeguard_switch", {duration = spell_duration})
	caster:GetAbilityByIndex(7):SetLevel(self:GetLevel())
	caster:SwapAbilities("leesin_safeguard", "leesin_iron_will", false, true)
	
	local origin = caster:GetOrigin()
    local target = caster:GetCursorCastTarget()
	local point = target:GetOrigin()
    local modifier_movement = "modifier_safeguard_dash"
	local dash_range = ability:GetSpecialValueFor("range")
	local speed = ability:GetSpecialValueFor("dash_speed")
	
	if target ~= caster then
		--face toward target
		local direction = (point - caster:GetAbsOrigin()):Normalized()
		caster:SetForwardVector(direction)
		
		--Begin moving to target point
		caster:AddNewModifier(caster, ability, modifier_movement, {})
	else
		caster:AddNewModifier(caster, ability, "modifier_safeguard", {duration = duration})
	end
end

modifier_safeguard_switch = class({})
function modifier_safeguard_switch:IsDebuff() return false end
function modifier_safeguard_switch:IsHidden() return true end
function modifier_safeguard_switch:IsPurgable() return false end
function modifier_safeguard_switch:IsPurgeException() return false end
function modifier_safeguard_switch:OnDestroy()
	self:GetCaster():SwapAbilities("leesin_iron_will", "leesin_safeguard", false, true)
end

modifier_safeguard = class({})
function modifier_safeguard:IsDebuff() return false end
function modifier_safeguard:IsHidden() return false end
function modifier_safeguard:IsPurgable() return false end
function modifier_safeguard:IsPurgeException() return true end
function modifier_safeguard:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
	}
	return funcs
end
function modifier_safeguard:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local shield_size = target:GetModelRadius() * 0.7
		local ability = self:GetAbility()
		local target_origin = target:GetAbsOrigin()
		local attach_hitloc = "attach_hitloc"

		self.shield_init_value = ability:GetSpecialValueFor( "shield" )
		self.shield_remaining = self.shield_init_value
		self.target_current_health = target:GetHealth()

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		local common_vector = Vector(shield_size,0,shield_size)
		ParticleManager:SetParticleControl(particle, 1, common_vector)
		ParticleManager:SetParticleControl(particle, 2, common_vector)
		ParticleManager:SetParticleControl(particle, 4, common_vector)
		ParticleManager:SetParticleControl(particle, 5, Vector(0,0,0))

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, attach_hitloc, target_origin, true)
		self:AddParticle(particle, false, false, -1, false, false)
	end
end

function modifier_safeguard:GetModifierTotal_ConstantBlock(kv)
	if IsServer() then
		local target 					= self:GetParent()
		local original_shield_amount	= self.shield_remaining
		local shield_hit_particle 		= "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_hit.vpcf"

		if kv.damage > 0 then
			self.shield_remaining = self.shield_remaining - kv.damage
			
			if kv.damage < original_shield_amount then
				--Emit damage blocking effect
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, kv.damage, nil)
				return kv.damage
			--Else, reduce what you can and blow up the shield
			else
				--Emit damage block effect
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, original_shield_amount, nil)
				self:Destroy()
				return original_shield_amount
			end
		end
	end
end

modifier_safeguard_dash = class({})
function modifier_safeguard_dash:OnCreated()
	--Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	
	self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
	
	local target = self.caster:GetCursorCastTarget()
	local point = target:GetOrigin()
	local startpoint = self.caster:GetOrigin()
	
	self.target = target --save target
	self.startpoint = startpoint --save starting point

	--Ability specials
	self.dash_speed = self.ability:GetSpecialValueFor("dash_speed")
	self.range = self.ability:GetSpecialValueFor("range")
	local duration = self.range / self.dash_speed

	if IsServer() then

		--variables
		self.time_elapsed = 0

		--calculate distance
		self.distance = (self.caster:GetAbsOrigin() - point):Length2D()
		self.dash_time = self.distance / self.dash_speed
		self.direction = (point - self.caster:GetAbsOrigin()):Normalized()
		
		self:ApplyHorizontalMotionController()
	end
end

function modifier_safeguard_dash:IsHidden() return true end
function modifier_safeguard_dash:IsPurgable() return false end
function modifier_safeguard_dash:IsDebuff() return false end
function modifier_safeguard_dash:IgnoreTenacity() return true end
function modifier_safeguard_dash:IsMotionController() return true end
function modifier_safeguard_dash:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_safeguard_dash:UpdateHorizontalMotion( me, dt)
	if IsServer() then
		self.dash_time = self.distance / self.dash_speed
		-- Check if we're still dashing
		self.time_elapsed = self.time_elapsed + dt
		if self.time_elapsed < self.dash_time then

			-- Go forward
			local new_location = self.caster:GetAbsOrigin() + self.direction * self.dash_speed * dt
			self.caster:SetAbsOrigin(new_location)
		else
			self:Destroy()
		end
	end
end

function modifier_safeguard_dash:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_safeguard_dash:OnRemoved()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		
		self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_5)
		
		if self.target:IsRealHero() then
			caster:AddNewModifier(caster, ability, "modifier_safeguard", {duration = duration})
			self.target:AddNewModifier(caster, ability, "modifier_safeguard", {duration = duration})
			local cooldown = ability:GetCooldownTimeRemaining()
			ability:EndCooldown()
			ability:StartCooldown(cooldown * (ability:GetSpecialValueFor("cooldown_reduce") / 100))
		end
		
		if self.EndCallback then
		self.EndCallback()
		end
		
		caster:InterruptMotionControllers( true )
	end
end

function modifier_safeguard_dash:SetEndCallback( func ) 
	self.EndCallback = func
end]]

-----------------------------------
--      IRON WILL       --
-----------------------------------
leesin_iron_will = class({})
LinkLuaModifier("modifier_iron_will", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)

function leesin_iron_will:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local duration = self:GetSpecialValueFor("duration")
	local lifesteal = self:GetSpecialValueFor("lifesteal")
	
	caster:AddNewModifier(caster, self, "modifier_iron_will", {duration = duration})
	caster:RemoveModifierByName("modifier_safeguard_switch")
end

modifier_iron_will = class({})
function modifier_iron_will:IsDebuff() return false end
function modifier_iron_will:IsHidden() return false end
function modifier_iron_will:IsPurgable() return false end
function modifier_iron_will:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end
function modifier_iron_will:OnTakeDamage( params )
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local lifesteal = ability:GetSpecialValueFor("lifesteal")
		local target = params.target if target==nil then target = params.unit end
		if target:GetTeamNumber()==self:GetParent():GetTeamNumber() then
			return false
		end
		
		if params.attacker == caster and not target:IsBuilding() then
			-- get heal value
			local heal = params.damage * lifesteal/100
			caster:Heal( heal, ability )
			self:PlayEffects( caster )
		end
	end
end
function modifier_iron_will:PlayEffects( target )
	-- get resource
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"

	-- play effects
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

-----------------------------------
--      TEMPEST       --
-----------------------------------
leesin_tempest = class({})
LinkLuaModifier("modifier_tempest_switch", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tempest_mark", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)

function leesin_tempest:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end
function leesin_tempest:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local effect_radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("mark_duration")
	local check = false
	
	EmitSoundOn("Hero_Ursa.Earthshock", caster)
	local part = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(part, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(part, 1, Vector(1,1,1))
	ParticleManager:ReleaseParticleIndex(part)
	
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetCaster():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		effect_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		damageTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}
		ApplyDamage( damageTable )
		enemy:AddNewModifier(caster, ability, "modifier_tempest_mark", {duration = duration})
		check = true
	end
	
	if check then
		caster:AddNewModifier(caster, ability, "modifier_tempest_switch", {duration = duration})
		caster:GetAbilityByIndex(8):SetLevel(self:GetLevel())
		caster:SwapAbilities("leesin_tempest", "leesin_cripple", false, true)
	end
end

modifier_tempest_switch = class({})
function modifier_tempest_switch:IsDebuff() return false end
function modifier_tempest_switch:IsHidden() return true end
function modifier_tempest_switch:IsPurgable() return false end
function modifier_tempest_switch:IsPurgeException() return false end
function modifier_tempest_switch:OnDestroy()
	self:GetCaster():SwapAbilities("leesin_cripple", "leesin_tempest", false, true)
end

modifier_tempest_mark = class({})
function modifier_tempest_mark:IsDebuff() return true end
function modifier_tempest_mark:IsHidden() return false end
function modifier_tempest_mark:IsPurgable() return false end
function modifier_tempest_mark:IsPurgeException() return false end
function modifier_tempest_mark:GetEffectName()
	return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
end
function modifier_tempest_mark:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

-----------------------------------
--      CRIPPLE       --
-----------------------------------
leesin_cripple = class({})
LinkLuaModifier("modifier_cripple_slow", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)

function leesin_cripple:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end
function leesin_cripple:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local effect_radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("slow_duration")
	local particle_circle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_circle.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_circle_fx, 0, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_circle_fx)
	
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetCaster():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		effect_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	
	caster:RemoveModifierByName("modifier_tempest_switch")

	for _,enemy in pairs(enemies) do
		if enemy:HasModifier("modifier_tempest_mark") then
			enemy:AddNewModifier(caster, ability, "modifier_cripple_slow", {duration = duration})
			enemy:RemoveModifierByName("modifier_tempest_mark")
		end
	end
end

modifier_cripple_slow = class({})
function modifier_cripple_slow:IsHidden() return false end
function modifier_cripple_slow:IsDebuff() return true end
function modifier_cripple_slow:IsPurgable() return true end
function modifier_cripple_slow:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
end
function modifier_cripple_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_cripple_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_cripple_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "slow" ) * (-1)
end

-----------------------------------
--      DRAGON'S RAGE       --
-----------------------------------
leesin_dragons_rage = class({})
LinkLuaModifier("modifier_dragons_rage_cast", "abilities/leesin", LUA_MODIFIER_MOTION_NONE)

function leesin_dragons_rage:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local root_duration = ability:GetSpecialValueFor("root_duration")
	local damage = ability:GetSpecialValueFor("damage")
	local targetmaxhealth = target:GetMaxHealth()
	
	if target:TriggerSpellAbsorb( self ) then return end
	
	caster:AddNewModifier(caster, ability, "modifier_dragons_rage_cast", {duration = root_duration})
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	target:AddNewModifier(caster, ability, "modifier_rooted", {duration = root_duration})
	
	local knockbackProperties = {
		center_x = caster:GetAbsOrigin().x,
		center_y = caster:GetAbsOrigin().y,
		center_z = caster:GetAbsOrigin().z,
		duration = self:GetSpecialValueFor("knockback_duration"),
		knockback_duration = self:GetSpecialValueFor("knockback_duration"),
		knockback_distance = self:GetSpecialValueFor("distance"),
		knockback_height = 0
	}
	EmitSoundOn("Hero_Tusk.WalrusPunch.Cast", caster)
	
	Timers:CreateTimer(root_duration, function()
		target:AddNewModifier(caster, ability, "modifier_knockback", knockbackProperties)
		EmitSoundOn("Hero_Tusk.WalrusKick.Target", target)
		damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}
		ApplyDamage( damageTable )
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damage, nil)
		
		if target:IsAlive() then
			local info = {
				Source = target,
				Ability = self,
				vSpawnOrigin = caster:GetAbsOrigin(),
				
				bDeleteOnHit = false,
				
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				
				EffectName = "",
				fDistance = self:GetSpecialValueFor("distance"),
				fStartRadius = 400,
				fEndRadius = 400,
				vVelocity = (target:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized() * (self:GetSpecialValueFor("distance") / self:GetSpecialValueFor("knockback_duration")),
				ExtraData = {maxhealth = targetmaxhealth, selftarget = target}
				}
			ProjectileManager:CreateLinearProjectile(info)
		end
	end)
end

function leesin_dragons_rage:OnProjectileHit_ExtraData( target, location, extra_data )
	if IsServer() then
		if not target then return end
		if target == extra_data.selftarget then return end

		-- load data
		local damage = self:GetSpecialValueFor( "damage" )
		local health_damage = self:GetSpecialValueFor( "health_damage" )
		local realdamage = damage + (extra_data.maxhealth * (health_damage / 100))
		local caster = self:GetCaster()

		-- damage
		local damageTable = {
			victim = target,
			attacker = self:GetCaster(),
			damage = realdamage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}
		ApplyDamage(damageTable)
		local knockbackProperties = {
			center_x = caster:GetAbsOrigin().x,
			center_y = caster:GetAbsOrigin().y,
			center_z = caster:GetAbsOrigin().z,
			duration = self:GetSpecialValueFor("knockup_duration"),
			knockback_duration = self:GetSpecialValueFor("knockup_duration"),
			knockback_distance = 0,
			knockback_height = 300
		}
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, realdamage, nil)
		target:AddNewModifier(caster, ability, "modifier_knockback", knockbackProperties)
		EmitSoundOn("Hero_Tusk.WalrusKick.Target", target)
	end
end
	
modifier_dragons_rage_cast = class({})
function modifier_dragons_rage_cast:IsHidden() return true end
function modifier_dragons_rage_cast:IsDebuff() return false end
function modifier_dragons_rage_cast:IsPurgable() return true end
function modifier_dragons_rage_cast:CheckState()	
	local state = {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
	return state
end