-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
local THIS_LUA = "abilities/hero_mars/mjz_mars_spear.lua"
LinkLuaModifier( "modifier_mjz_mars_spear", THIS_LUA, LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_mjz_mars_spear_checker", THIS_LUA, LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_mjz_mars_spear_debuff", THIS_LUA, LUA_MODIFIER_MOTION_NONE )

mjz_mars_spear = mjz_mars_spear or class({})
local ability_class = mjz_mars_spear

--------------------------------------------------------------------------------
function ability_class:OnSpellStart()
    if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self
    local point = self:GetCursorPosition()
    
    self:SpellPoint(caster, point)

    if caster:HasScepter() then
        local p = caster:GetAbsOrigin()
        local fv = caster:GetForwardVector()

        local mode = {}

        -- 模式1: 左右90度
        mode[1] = {}
        mode[1].p3 = p + 150 * self:RotateVector2D(fv, math.rad(90))
        mode[1].p2 = p - 150 * self:RotateVector2D(fv, math.rad(90))

        -- 模式2: 向前15度
        mode[2] = {}
        mode[2].p3 = p + 150 * self:RotateVector2D(fv, math.rad(15))
        mode[2].p2 = p - 150 * self:RotateVector2D(fv, math.rad(180 - 15))


        local p3 = mode[2].p3
        local p2 = mode[2].p2

        self:SpellPoint(caster, p2)
        self:SpellPoint(caster, p3)
    end

    self:PlaySound(caster)  
end

function ability_class:PlaySound( source )
    local sound_cast = "Hero_Mars.Spear.Cast"
	EmitSoundOn( sound_cast, source )
	local sound_cast = "Hero_Mars.Spear"
    EmitSoundOn( sound_cast, source )
end

function ability_class:SpellPoint( source, point )
    local caster = self:GetCaster()
    local ability = self
    
    local projectile_name = "particles/units/heroes/hero_mars/mars_spear.vpcf"
	local projectile_distance = self:GetSpecialValueFor("spear_range") + caster:GetCastRangeBonus()
	local projectile_speed = self:GetSpecialValueFor("spear_speed")
	local projectile_radius = self:GetSpecialValueFor("spear_width")
	local projectile_vision = self:GetSpecialValueFor("spear_vision")

    local origin = source:GetOrigin()
    	-- calculate direction
	local direction = point - origin
	direction.z = 0
	direction = direction:Normalized()

	local info = {
		Source = caster,    --source
		Ability = ability,
		vSpawnOrigin = origin,
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = ability:GetAbilityTargetTeam(),
	    iUnitTargetType = ability:GetAbilityTargetType(),
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius =projectile_radius,
		vVelocity = direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		-- fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		fVisionDuration = 10,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)


end

function ability_class:CalcDamage( target )
    local caster = self:GetCaster()
    local ability = self
    
    local base_damage = GetTalentSpecialValueFor(ability, "damage")
    local strength_damage = GetTalentSpecialValueFor(ability, "strength_damage")
    local damage = base_damage + caster:GetStrength() * (strength_damage / 100)
    return damage
end


function ability_class:RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end

--------------------------------------------------------------------------------
-- Projectile
-- projectile management
--[[
Fields:
- location
- direction
- init_pos
- unit
- modifier
- active
]]
local mars_projectiles = {}
function mars_projectiles:Init( projectileID )
	self[projectileID] = {}

	-- set location
	self[projectileID].location = ProjectileManager:GetLinearProjectileLocation( projectileID )
	self[projectileID].init_pos = self[projectileID].location

	-- set direction
	local direction = ProjectileManager:GetLinearProjectileVelocity( projectileID )
	direction.z = 0
	direction = direction:Normalized()
	self[projectileID].direction = direction
end

function mars_projectiles:Destroy( projectileID )
	self[projectileID] = nil
end
ability_class.projectiles = mars_projectiles

-- projectile hit
function ability_class:OnProjectileHitHandle( target, location, iProjectileHandle )
	-- init in case it isn't initialized from below (if projectile launched very close to target)
	if not self.projectiles[iProjectileHandle] then
		self.projectiles:Init( iProjectileHandle )
	end
	if not target then
		-- add viewer
		local projectile_vision = self:GetSpecialValueFor("spear_vision")
		AddFOWViewer( self:GetCaster():GetTeamNumber(), location, projectile_vision, 1, false)

		-- destroy data
		self.projectiles:Destroy( iProjectileHandle )
		return
	end

    -- get stun and damage
    local ability = self
	local stun = GetTalentSpecialValueFor(ability, "stun_duration")
	self.damage = self:GetSpecialValueFor("damage")
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_mars_spear_bonus_damage")

    if talent and talent:GetLevel() > 0 then
        self.damage = self.damage + talent:GetSpecialValueFor("value")
    end

	-- apply damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:CalcDamage(target),
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
	}
	ApplyDamage(damageTable)

	-- check if it has skewered a unit, or target is not a hero


	-- add modifier to skewered unit
	local modifier = target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_mjz_mars_spear", -- modifier name
		{
            projectile = iProjectileHandle,
            -- duration   = 10
		} -- kv
	)
	self.arenaChecker = target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_mjz_mars_spear_checker", -- modifier name
		{
		    duration = 2
		} -- kv
	)
	self.projectiles[iProjectileHandle].unit = target
	self.projectiles[iProjectileHandle].modifier = modifier
	self.projectiles[iProjectileHandle].active = false

	-- play effects
	local sound_cast = "Hero_Mars.Spear.Target"
	EmitSoundOn( sound_cast, target )
end

-- projectile think
function ability_class:OnProjectileThinkHandle( iProjectileHandle )
	-- init for the first time
	if not self.projectiles[iProjectileHandle] then
		self.projectiles:Init( iProjectileHandle )
	end

	local data = self.projectiles[iProjectileHandle]

	-- init data
	local tree_radius = 120
	local wall_radius = 50
	local building_radius = 30
	local blocker_radius = 70

	-- save location
	local location = ProjectileManager:GetLinearProjectileLocation( iProjectileHandle )
	data.location = location

	-- check skewered unit, and dragged (caught unit not necessarily dragged)
	if not data.unit then return end
	if not data.active then
		-- check distance, mainly to avoid being pinned while behind the tree/cliffs
		local difference = (data.unit:GetOrigin()-data.init_pos):Length2D() - (data.location-data.init_pos):Length2D()
		if difference>0 then return end
		data.active = true
	end


	-- search for blocker
	local thinkers = Entities:FindAllByClassnameWithin( "npc_dota_thinker", data.location, wall_radius )
	for _,thinker in pairs(thinkers) do
		if thinker:IsPhantomBlocker() then
			self:Pinned( iProjectileHandle )
			return
		end
	end

	-- search for high ground
	local base_loc = GetGroundPosition( data.location, data.unit )
	local search_loc = GetGroundPosition( base_loc + data.direction*wall_radius, data.unit )
	if search_loc.z-base_loc.z>10 and (not GridNav:IsTraversable( search_loc )) then
		self:Pinned( iProjectileHandle )
		return
	end

	-- search for tree
	if GridNav:IsNearbyTree( data.location, tree_radius, false) then
		-- pinned
		self:Pinned( iProjectileHandle )
		return
	end
	
	if not data.unit:HasModifier("modifier_mjz_mars_spear_checker") and data.unit:IsAlive() then
		ApplyDamage({
			victim = data.unit,
			attacker = self:GetCaster(),
			damage = self:CalcDamage(data.unit),           -- self.damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		})
		self:Pinned( iProjectileHandle )
		return
	end

	-- search for buildings
	local buildings = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		data.location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		building_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_BUILDING,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if #buildings>0 then
		-- pinned
		self:Pinned( iProjectileHandle )
		return
	end
end

function ability_class:Pinned( iProjectileHandle )
    local ability = self
	local data = self.projectiles[iProjectileHandle]
	local duration = GetTalentSpecialValueFor(ability, "stun_duration")
	-- local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_mars_spear_stun_duration")

    -- if talent and talent:GetLevel() > 0 then
    --     duration = duration + talent:GetSpecialValueFor("value")
    -- end
	local projectile_vision = self:GetSpecialValueFor("spear_vision")

	-- add viewer
	AddFOWViewer( self:GetCaster():GetTeamNumber(), data.unit:GetOrigin(), projectile_vision, duration, false)


	data.unit:AddNewModifier(
	self:GetCaster(), -- player source
	self, -- ability source
	"modifier_mjz_mars_spear_debuff", -- modifier name
	{
		duration = duration,
		projectile = iProjectileHandle,
	} -- kv
	)
	ProjectileManager:DestroyLinearProjectile( iProjectileHandle )
	if data.modifier then
		if not data.modifier:IsNull() then
			data.modifier:Destroy()

			data.unit:SetOrigin( GetGroundPosition( data.location, data.unit ) )
		end
	end
	


	-- play effects
	self:PlayEffects( iProjectileHandle, duration )

	-- delete data
	self.projectiles:Destroy( iProjectileHandle )
end
--------------------------------------------------------------------------------
function ability_class:PlayEffects( projID, duration )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_mars/mars_spear_impact.vpcf"
	local sound_cast = "Hero_Mars.Spear.Root"

	-- Get Data
	local data = self.projectiles[projID]
	local delta = 50
	local location = GetGroundPosition( data.location, data.unit ) + data.direction*delta

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, location )
	ParticleManager:SetParticleControl( effect_cast, 1, data.direction*1000 )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:SetParticleControlForward( effect_cast, 0, data.direction )
	ParticleManager:DestroyParticle(effect_cast, false)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, data.unit )
end


modifier_mjz_mars_spear = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mjz_mars_spear:IsHidden()
	return not IsInToolsMode()
end

function modifier_mjz_mars_spear:IsDebuff()
	return true
end

function modifier_mjz_mars_spear:IsStunDebuff()
	return true
end

function modifier_mjz_mars_spear:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_mjz_mars_spear:OnCreated( kv )
	-- references
	self.ability = self:GetAbility()

	if IsServer() then
		self.projectile = kv.projectile

		-- face towards
		self:GetParent():SetForwardVector( -self:GetAbility().projectiles[kv.projectile].direction )
		self:GetParent():FaceTowards( self.ability.projectiles[self.projectile].init_pos )

		-- try apply
		if self:ApplyHorizontalMotionController() == false then
			if self:IsNull() then return end
			self:Destroy()
		end
	end
end

function modifier_mjz_mars_spear:OnRefresh( kv )
	
end

function modifier_mjz_mars_spear:OnRemoved()
	if not IsServer() then return end
	-- Compulsory interrupt
	self:GetParent():InterruptMotionControllers( false )
end

function modifier_mjz_mars_spear:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_mjz_mars_spear:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_mjz_mars_spear:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_mjz_mars_spear:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_mjz_mars_spear:OnIntervalThink()
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_mjz_mars_spear:UpdateHorizontalMotion( me, dt )
	-- check projectile data
	if not self.ability.projectiles[self.projectile] then
		if self:IsNull() then return end
		self:Destroy()
		return
	end

	-- get location
	local data = self.ability.projectiles[self.projectile]

	if not data.active then return end

	-- move parent to projectile location
	self:GetParent():SetOrigin( data.location + data.direction*60 )
end

function modifier_mjz_mars_spear:OnHorizontalMotionInterrupted()
	if IsServer() then
		if self:IsNull() then return end
		self:Destroy()
	end
end


modifier_mjz_mars_spear_checker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mjz_mars_spear_checker:IsHidden()
	return true
end

function modifier_mjz_mars_spear_checker:IsDebuff()
	return true
end

function modifier_mjz_mars_spear_checker:IsPurgable()
	return true
end

function modifier_mjz_mars_spear_checker:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end
if IsServer() then
function modifier_mjz_mars_spear_checker:OnTakeDamage(keys)
	local parent = self:GetParent()	
	if keys.inflictor and keys.unit then
		if keys.unit == parent and keys.inflictor:GetAbilityName() == "mars_arena_of_blood" then
			if self:IsNull() then return end
			self:Destroy()
		end
	end
end
end

modifier_mjz_mars_spear_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mjz_mars_spear_debuff:IsHidden()
	return false
end

function modifier_mjz_mars_spear_debuff:IsDebuff()
	return true
end

function modifier_mjz_mars_spear_debuff:IsStunDebuff()
	return true
end

function modifier_mjz_mars_spear_debuff:IsPurgable()
	return true
end

function modifier_mjz_mars_spear_debuff:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_mjz_mars_spear_debuff:OnCreated( kv )
	if not IsServer() then return end
	self.projectile = kv.projectile
end

function modifier_mjz_mars_spear_debuff:OnRefresh( kv )
end

function modifier_mjz_mars_spear_debuff:OnRemoved()
	if not IsServer() then return end
	-- destroy tree
	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), 120, false )
end

function modifier_mjz_mars_spear_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_mjz_mars_spear_debuff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_TOOLTIP,
	}

	return funcs
end

function modifier_mjz_mars_spear_debuff:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end
function modifier_mjz_mars_spear_debuff:OnTooltip( params )
	return self:GetDuration()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_mjz_mars_spear_debuff:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_mjz_mars_spear_debuff:GetEffectName()
	return "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf"
end

function modifier_mjz_mars_spear_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_mjz_mars_spear_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_mars_spear.vpcf"
end


---------------------------------------------------------------------------------------------------------------

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
