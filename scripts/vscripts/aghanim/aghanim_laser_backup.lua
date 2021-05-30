aghanim_laser = class({})
LinkLuaModifier("modifier_aghanim_laser_thinker", "aghanim/aghanim_laser.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_laser_burn_thinker", "aghanim/aghanim_laser.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_laser_debuff", "aghanim/aghanim_laser.lua", LUA_MODIFIER_MOTION_NONE)

-- Precache resources
function aghanim_laser:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_channel.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_burn.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam_linger.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam_tgt_ring.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_debug_ring.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context )
end

-- Create the beam on the target
function aghanim_laser:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- Particle Creation
	if IsServer() then
        local beamName = "particles/creatures/aghanim/aghanim_beam_channel.vpcf"
        local warningName = "particles/creatures/aghanim/aghanim_debug_ring.vpcf"

		self.channelParticle = ParticleManager:CreateParticle( beamName, PATTACH_ABSORIGIN_FOLLOW, caster )
		target.warningParticle = ParticleManager:CreateParticle( warningName, PATTACH_CUSTOMORIGIN, caster ) --
		self.target_pos = target:GetAbsOrigin()
		ParticleManager:SetParticleControl( target.warningParticle, 0, self.target_pos )
        
        StartSoundEventFromPositionReliable( "Aghanim.StaffBeams.WindUp", caster:GetAbsOrigin() )
	end
	return true
end

--Remove castpoint effects on cancel
function aghanim_laser:OnAbilityPhaseInterrupted()
	if IsServer() then
    	ParticleManager:DestroyParticle(self.channelParticle, false)
		ParticleManager:DestroyParticle(self:GetCursorTarget().warningParticle, false)
	end
end

function aghanim_laser:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
		local target = self:GetCursorTarget()

        -- Remove the warning particle on the target
		ParticleManager:DestroyParticle( target.warningParticle, false )
		
		if not target or target:TriggerSpellAbsorb( self ) or target:TriggerSpellReflect( self ) then return end

		EmitSoundOn( "Hero_Phoenix.SunRay.Cast", caster )
		EmitSoundOn( "Hero_Phoenix.SunRay.Loop", caster )

        -- Create the laser thinker
		local laserThinker = CreateModifierThinker( 
            caster, 
            self, 
            "modifier_aghanim_laser_thinker", 
            { duration = self:GetChannelTime() }, 
            self.target_pos, 
            caster:GetTeamNumber(), 
            false 
        )
		
		local beamSpeed
		local talent = caster:FindAbilityByName("special_bonus_unique_aghanim_2")
		if talent and talent:GetLevel() > 0 then 
			beamSpeed = caster:GetIdealSpeed() 
		else
			beamSpeed = self:GetSpecialValueFor("beam_speed")
		end

        -- Create the tracking projectile
		self.beamProjectile = {
			Target = target,
			Source = laserThinker,
			Ability = self,
			EffectName = "",
			iMoveSpeed = beamSpeed,
			vSourceLoc = self.target_pos,
			bDodgeable = false,
			bProvidesVision = false,
			flExpireTime = GameRules:GetGameTime() + self:GetChannelTime(),
			bIgnoreObstructions = true,
			bSuppressTargetCheck = true,
		}

		self.beamProjectile.hThinker = laserThinker

		local nProjectileHandle = ProjectileManager:CreateTrackingProjectile( self.beamProjectile )
		self.beamProjectile.nProjectileHandle = nProjectileHandle

		local nBeamFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/staff_beam.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControlEnt( nBeamFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_staff_fx", caster:GetAbsOrigin(), true )
		ParticleManager:SetParticleControlEnt( nBeamFXIndex, 1, self.beamProjectile.hThinker, PATTACH_ABSORIGIN_FOLLOW, nil, self.beamProjectile.hThinker:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nBeamFXIndex, 2, caster, PATTACH_ABSORIGIN_FOLLOW, nil, self.beamProjectile.hThinker:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nBeamFXIndex, 9, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
		self.beamProjectile.nFXIndex = nBeamFXIndex
	end
end

-- ¯\_(ツ)_/¯
function aghanim_laser:OnProjectileThinkHandle( nProjectileHandle )
	if IsServer() then
		if self.beamProjectile == nil then return end
        local Projectile = self.beamProjectile

		local vLocation = ProjectileManager:GetTrackingProjectileLocation( nProjectileHandle )
		if Projectile.hThinker ~= nil and not Projectile.hThinker:IsNull() then
			vLocation = GetGroundPosition( vLocation, Projectile.hThinker )
            Projectile.hThinker:SetOrigin( vLocation )

			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 1, vLocation )
			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 9, self:GetCaster():GetAbsOrigin() )
		end
	end
end

-- Cap the max beam range
function aghanim_laser:OnChannelThink() 
	if IsServer() then
		if self.beamProjectile == nil then 
			self:GetCaster():InterruptChannel()
			return 
		end

        if self.beamProjectile.hThinker ~= nil and not self.beamProjectile.hThinker:IsNull() then
            local caster = self:GetCaster()

            local projectile_position = ProjectileManager:GetTrackingProjectileLocation( self.beamProjectile.nProjectileHandle )
            local ground_position = GetGroundPosition( projectile_position, self.beamProjectile.hThinker )

            local distance = (caster:GetAbsOrigin()-ground_position):Length2D()
            local cast_range = self:GetCastRange(caster:GetAbsOrigin(), self:GetCursorTarget()) + caster:GetCastRangeBonus()
            local leash_range = cast_range + ((self:GetSpecialValueFor("leash_range")/100)*cast_range)

            if distance > leash_range then
                caster:InterruptChannel()
            end
        end
    end
end

function aghanim_laser:OnChannelFinish( bInterrupted )
	if IsServer() then
		if self.beamProjectile == nil then return end

		ParticleManager:DestroyParticle( self.channelParticle, false )
		StopSoundOn( "Hero_Phoenix.SunRay.Cast", self:GetCaster() )
		StopSoundOn( "Hero_Phoenix.SunRay.Loop", self:GetCaster() )
		EmitSoundOn( "Hero_Phoenix.SunRay.Stop", self:GetCaster() )

		
		ParticleManager:DestroyParticle( self.beamProjectile.nFXIndex, false )
		if self.beamProjectile.hThinker and self.beamProjectile.hThinker:IsNull() == false then
            UTIL_Remove( self.beamProjectile.hThinker )
		end
			
        -- Fuck you valve remove your projectiles you pricks
        ProjectileManager:DestroyTrackingProjectile( self.beamProjectile.nProjectileHandle )
	end
end

--=================================================================================================

modifier_aghanim_laser_thinker = class({})
function modifier_aghanim_laser_thinker:IsHidden() return true end
function modifier_aghanim_laser_thinker:IsPurgable() return false end

function modifier_aghanim_laser_thinker:OnCreated( kv )
    if IsServer() then
		self.linger_time = self:GetAbility():GetSpecialValueFor( "linger_time" )
        self.linger_create_interval = self:GetAbility():GetSpecialValueFor( "linger_create_interval" )

        -- Create the initial burn patch
        CreateModifierThinker( 
            self:GetCaster(), 
            self:GetAbility(), 
            "modifier_aghanim_laser_burn_thinker", 
            { duration = self.linger_time }, 
            self:GetParent():GetAbsOrigin(), 
            self:GetCaster():GetTeamNumber(), 
            false 
        )
		self:StartIntervalThink( self.linger_create_interval )
	end
end

-- Create new burn patch every think interval
function modifier_aghanim_laser_thinker:OnIntervalThink()
	if IsServer() then
		CreateModifierThinker( 
            self:GetCaster(), 
            self:GetAbility(), 
            "modifier_aghanim_laser_burn_thinker", 
            { duration = self.linger_time }, 
            self:GetParent():GetAbsOrigin(), 
            self:GetCaster():GetTeamNumber(), 
            false 
        )
	end
end

function modifier_aghanim_laser_thinker:OnDestroy()
    --print("Thinker Removed")
end

--=================================================================================================

modifier_aghanim_laser_burn_thinker = class({})
function modifier_aghanim_laser_burn_thinker:IsHidden() return true end

-- Aura functions
function modifier_aghanim_laser_burn_thinker:IsAura() return true end
function modifier_aghanim_laser_burn_thinker:GetModifierAura() return "modifier_aghanim_laser_debuff" end
function modifier_aghanim_laser_burn_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_aghanim_laser_burn_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_aghanim_laser_burn_thinker:GetAuraRadius() return self.beam_radius end

function modifier_aghanim_laser_burn_thinker:OnCreated()
	self.beam_radius = self:GetAbility():GetSpecialValueFor( "beam_radius" )
	if IsServer() then
        EmitSoundOn( "n_black_dragon.Fireball.Target", self:GetParent() )
        
        local particleName = "particles/creatures/aghanim/staff_beam_linger.vpcf"
		self.burnPatch = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.burnPatch, 0, self:GetParent():GetAbsOrigin() )
		ParticleManager:SetParticleControl( self.burnPatch, 1, Vector( self.beam_radius, 1, 1 ) )
	end
end

function modifier_aghanim_laser_burn_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn( "n_black_dragon.Fireball.Target", self:GetParent() )
		ParticleManager:DestroyParticle( self.burnPatch, false )
        UTIL_Remove( self:GetParent() )
	end
end

function modifier_aghanim_laser_burn_thinker:OnRefresh()
	self.beam_radius = self:GetAbility():GetSpecialValueFor( "beam_radius" )
end

--=================================================================================================

modifier_aghanim_laser_debuff = class({})
function modifier_aghanim_laser_debuff:IsHidden() return false end
function modifier_aghanim_laser_debuff:IsDebuff() return true end

function modifier_aghanim_laser_debuff:OnCreated( kv )
	if IsServer() then
		self.beam_dps = self:GetAbility():GetSpecialValueFor( "beam_dps" )
		self.beam_dps_pct = self:GetAbility():GetSpecialValueFor( "beam_dps_pct" )
		self.damage_interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )
		self:OnIntervalThink()
		self:StartIntervalThink( self.damage_interval )

		--EmitSoundOn( "Hero_Huskar.Burning_Spear", self:GetParent() )
	end
end

function modifier_aghanim_laser_debuff:OnDestroy()
	if IsServer() then
		--StopSoundOn( "Hero_Huskar.Burning_Spear", self:GetParent() )
	end
end

function modifier_aghanim_laser_debuff:OnIntervalThink()
    if IsServer() then

        -- Calculate and deal the damage
		local flHealthPctDamage = self.beam_dps_pct * self:GetParent():GetMaxHealth() / 100
		local flDamage = self.beam_dps + flHealthPctDamage
		local damageInfo = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = flDamage * self.damage_interval,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(),
		}
		ApplyDamage( damageInfo )

        -- Create the burn effect
        local particleName = "particles/creatures/aghanim/aghanim_beam_burn.vpcf"
		local burnParticle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( 
            burnParticle, 
            1, 
            self:GetParent(), 
            PATTACH_POINT_FOLLOW, 
            "attach_hitloc", 
            self:GetParent():GetAbsOrigin(), 
            true 
        )
		ParticleManager:ReleaseParticleIndex( burnParticle )
	end
end