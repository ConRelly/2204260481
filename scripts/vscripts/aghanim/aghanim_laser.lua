aghanim_laser = class({})
LinkLuaModifier("modifier_aghanim_laser_thinker", "aghanim/aghanim_laser.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_laser_burn_thinker", "aghanim/aghanim_laser.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_laser_debuff", "aghanim/aghanim_laser.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_laser_channel", "aghanim/aghanim_laser.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hide", "modifier_hide.lua", LUA_MODIFIER_MOTION_NONE)

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

function aghanim_laser:GetAOERadius()
	return self:GetSpecialValueFor("beam_radius")
end

-- Create the beam on the target
function aghanim_laser:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    self.point = self:GetCursorPosition()

    -- Particle Creation
	if IsServer() then
        local beamName = "particles/creatures/aghanim/aghanim_beam_channel.vpcf"
        local warningName = "particles/creatures/aghanim/aghanim_debug_ring.vpcf"

		self.channelParticle = ParticleManager:CreateParticle( beamName, PATTACH_ABSORIGIN_FOLLOW, caster )
		self.warningParticle = ParticleManager:CreateParticle( warningName, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( self.warningParticle, 0, self.point)
        
        StartSoundEventFromPositionReliable( "Aghanim.StaffBeams.WindUp", caster:GetAbsOrigin() )
	end
	return true
end

--Remove castpoint effects on cancel
function aghanim_laser:OnAbilityPhaseInterrupted()
	if IsServer() then
    	ParticleManager:DestroyParticle(self.channelParticle, false)
		ParticleManager:DestroyParticle(self.warningParticle, false)
	end
end

function aghanim_laser:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        -- Remove the warning particle on the target
		ParticleManager:DestroyParticle( self.warningParticle, false )

		EmitSoundOn( "Hero_Phoenix.SunRay.Cast", caster )
		EmitSoundOn( "Hero_Phoenix.SunRay.Loop", caster )

		caster:AddNewModifier(caster, self, "modifier_aghanim_laser_channel", {})

		self.hTracking = CreateUnitByName( 
            "npc_dota_wisp_spirit",
            self.point,
            false, 
            caster, 
            caster:GetOwner(), 
            caster:GetTeamNumber() 
		)
		self.hTracking:AddNewModifier(caster, self, "modifier_hide", {})

        -- Create the laser thinker
		local laserThinker = CreateModifierThinker( 
            caster, 
            self, 
            "modifier_aghanim_laser_thinker", 
            { duration = self:GetChannelTime() }, 
            self.point, 
            caster:GetTeamNumber(), 
            false 
		)

        -- Create the tracking projectile
		self.beamProjectile = {
			Target = self.hTracking,
			Source = laserThinker,
			Ability = self,
			EffectName = "",
			iMoveSpeed = self:GetSpecialValueFor("beam_speed"),
			vSourceLoc = self.point,
			bDodgeable = false,
			bProvidesVision = true,
			iVisionRadius = self:GetSpecialValueFor("beam_radius") + 5,
			iVisionTeamNumber = caster:GetTeamNumber(),
			flExpireTime = GameRules:GetGameTime() + self:GetChannelTime(),
			bIgnoreObstructions = true,
			bSuppressTargetCheck = true,
		}

		local nProjectileHandle = ProjectileManager:CreateTrackingProjectile( self.beamProjectile )
		self.beamProjectile.nProjectileHandle = nProjectileHandle

		self.beamProjectile.hThinker = laserThinker
		
		local nBeamFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/staff_beam.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControlEnt( nBeamFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_staff_fx", caster:GetAbsOrigin(), true )
		ParticleManager:SetParticleControlEnt( nBeamFXIndex, 1, laserThinker, PATTACH_ABSORIGIN_FOLLOW, nil, self.point, true )
		ParticleManager:SetParticleControlEnt( nBeamFXIndex, 2, caster, PATTACH_ABSORIGIN_FOLLOW, nil, self.point, true )
		ParticleManager:SetParticleControlEnt( nBeamFXIndex, 9, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
		self.nBeamFXIndex = nBeamFXIndex

		-- Talent check
		local talent = caster:FindAbilityByName("special_bonus_unique_aghanim_2")
		if talent and talent:GetLevel() > 0 then
			self.beamProjectile.talentCheck = true
		end
	end
end

-- ¯\_(ツ)_/¯
function aghanim_laser:OnProjectileThinkHandle( nProjectileHandle )
	if IsServer() then
		if self.beamProjectile == nil then return end

		-- Game crashes when projectile is destroyed on same frame as another (projectile stun interupting channel)
		if not self:GetCaster():HasModifier("modifier_aghanim_laser_channel") then ProjectileManager:DestroyTrackingProjectile(nProjectileHandle) end
		
		if self.beamProjectile.talentCheck == true then
			ProjectileManager:ChangeTrackingProjectileSpeed(self, self:GetCaster():GetIdealSpeed())
		end
		
		local Projectile = self.beamProjectile
		local vLocation = ProjectileManager:GetTrackingProjectileLocation( nProjectileHandle )
		if Projectile.hThinker ~= nil and not Projectile.hThinker:IsNull() then
			vLocation = GetGroundPosition( vLocation, Projectile.hThinker )
            
			local caster_pos = self:GetCaster():GetAbsOrigin()

			-- Restricting the max travel distance
            local distance = (caster_pos - vLocation):Length2D()
            local cast_range = self:GetCastRange(caster_pos, self:GetCursorTarget()) + self:GetCaster():GetCastRangeBonus()
            local leash_range = self:GetSpecialValueFor("leash_range") / 100 * cast_range

			-- Cap the distance if needed
			if distance > leash_range then
				local direction = ( self.hTracking:GetOrigin() - caster_pos ):Normalized()
				local new_pos = caster_pos + ( direction * leash_range )

				self.hTracking:SetOrigin( new_pos )
			end

			-- Update the beam position
			Projectile.hThinker:SetOrigin( vLocation )

			-- Particle stuff I don't understand
			ParticleManager:SetParticleControlFallback( self.nBeamFXIndex, 0, caster_pos )
			ParticleManager:SetParticleControlFallback( self.nBeamFXIndex, 1, vLocation )
			ParticleManager:SetParticleControlFallback( self.nBeamFXIndex, 9, caster_pos )

			-- Destroy trees near the laser
			GridNav:DestroyTreesAroundPoint( vLocation, self:GetSpecialValueFor("beam_radius"), true )
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
    end
end

function aghanim_laser:OnChannelFinish( bInterrupted )
	if IsServer() then
		ParticleManager:DestroyParticle( self.channelParticle, false )
		StopSoundOn( "Hero_Phoenix.SunRay.Cast", self:GetCaster() )
		StopSoundOn( "Hero_Phoenix.SunRay.Loop", self:GetCaster() )
		EmitSoundOn( "Hero_Phoenix.SunRay.Stop", self:GetCaster() )

		self:GetCaster():RemoveModifierByName("modifier_aghanim_laser_channel")
		self.hTracking:ForceKill(false)
		UTIL_Remove( self.hTracking )
		self.hTracking = nil

		if self.beamProjectile == nil then return end

		ParticleManager:DestroyParticle( self.nBeamFXIndex, false )
		if self.beamProjectile.hThinker and self.beamProjectile.hThinker:IsNull() == false then
            UTIL_Remove( self.beamProjectile.hThinker )
		end
	end
end

--=================================================================================================

modifier_aghanim_laser_channel = class({})
function modifier_aghanim_laser_channel:IsHidden() return true end
function modifier_aghanim_laser_channel:IsPurgable() return false end
function modifier_aghanim_laser_channel:DeclareFunctions() return {MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT} end
function modifier_aghanim_laser_channel:GetModifierIgnoreMovespeedLimit() return 1 end

--=================================================================================================

modifier_aghanim_laser_thinker = class({})

function modifier_aghanim_laser_thinker:IsHidden() return true end
function modifier_aghanim_laser_thinker:IsPurgable() return false end

function modifier_aghanim_laser_thinker:OnCreated()
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

--=================================================================================================

modifier_aghanim_laser_burn_thinker = class({})
function modifier_aghanim_laser_burn_thinker:IsHidden() return true end

-- Aura functions
function modifier_aghanim_laser_burn_thinker:IsAura() return true end
function modifier_aghanim_laser_burn_thinker:GetModifierAura() return "modifier_aghanim_laser_debuff" end
function modifier_aghanim_laser_burn_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_aghanim_laser_burn_thinker:GetAuraSearchType()
	local targets = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	if IsServer() then
		local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_aghanim_1")
		if talent and talent:GetLevel() > 0 then
			targets = targets + DOTA_UNIT_TARGET_BUILDING
		end
	end
	return targets
end
function modifier_aghanim_laser_burn_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_aghanim_laser_burn_thinker:GetAuraRadius() return self.beam_radius end

function modifier_aghanim_laser_burn_thinker:OnCreated()
	
	if IsServer() then
		self.beam_radius = self:GetAbility():GetSpecialValueFor( "beam_radius" )
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
		self.beam_dps = self:GetAbility():GetSpecialValueFor( "beam_damage" )
		self.beam_dps_pct = self:GetAbility():GetSpecialValueFor( "beam_damage_pct" )
		if string.find(self:GetParent():GetUnitName(), "roshan") then
			self.beam_dps_pct = self.beam_dps_pct / 2
		end

		self.damage_interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )
		self:OnIntervalThink()
		self:StartIntervalThink( self.damage_interval )

		EmitSoundOn( "Hero_Huskar.Burning_Spear", self:GetParent() )
	end
end

function modifier_aghanim_laser_debuff:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Huskar.Burning_Spear", self:GetParent() )
	end
end

function modifier_aghanim_laser_debuff:OnIntervalThink()
	if IsServer() then

		-- Calculate and deal the damage
		local amp = self:GetCaster():GetSpellAmplification(false)
		local flHealthPctDamage = self.beam_dps_pct * self:GetParent():GetMaxHealth() / 100
		local flDamage = self.beam_dps + flHealthPctDamage

		local ampDamage = (flDamage*amp) + flDamage

		local damageInfo = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = ampDamage * self.damage_interval,
			damage_type = self:GetAbility():GetAbilityDamageType(),
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