LinkLuaModifier("modifier_mjz_phoenix_sun_ray_thinker","modifiers/hero_phoenix/modifier_mjz_phoenix_sun_ray_thinker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_phoenix_sun_ray_rooted","modifiers/hero_phoenix/modifier_mjz_phoenix_sun_ray_move.lua", LUA_MODIFIER_MOTION_NONE)

local SUB_ABILITY_NAME = 'mjz_phoenix_sun_ray_cancel'
local MODIFIER_THINKER_NAME = 'modifier_mjz_phoenix_sun_ray_thinker'
local MODIFIER_ROOTED_NAME = 'modifier_mjz_phoenix_sun_ray_rooted'



modifier_mjz_phoenix_sun_ray_caster = class({})
local modifier_class = modifier_mjz_phoenix_sun_ray_caster

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return true end

function modifier_class:CheckState() 
	local state = {
		-- [MODIFIER_STATE_NO_UNIT_COLLISION] 	= true,
		[MODIFIER_STATE_DISARMED] 			= true,
		-- [MODIFIER_STATE_ROOTED] 			= true,
		-- [MODIFIER_STATE_FLYING]				= true,
	}
	return state
end

function modifier_class:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_EVENT_ON_STATE_CHANGED,
	}
end

function modifier_class:GetModifierTurnRate_Percentage()
	return self:GetAbility():GetSpecialValueFor("turn_rate")
end

function modifier_class:OnStateChanged(event)
	if IsServer() then
		local parent = self:GetParent()
		local caster = parent
		if caster:IsSilenced() or caster:IsStunned() 
			or caster:IsHexed() or caster:IsFrozen() 
			or caster:IsNightmared() or caster:IsOutOfGame() then
			-- Interrupt the ability
			if self:IsNull() then return end
			self:Destroy()
		end
	end
end

if IsServer() then
	function modifier_class:OnCreated(table)
		local parent = self:GetParent()
		local caster = parent
		local ability = self:GetAbility()
		local originParent = parent:GetAbsOrigin()
		local tick_interval = ability:GetSpecialValueFor('tick_interval')

		parent:AddNewModifier(caster, ability, MODIFIER_ROOTED_NAME, {})

		-- play the sound
		parent:EmitSound( "Hero_Phoenix.SunRay.Loop" )

		-- Create particle FX
		local particleName = "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf"
		local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
		self.pfx = pfx

		self:_InitSunRay()

		self:StartIntervalThink(tick_interval)
	end

	function modifier_class:OnIntervalThink()
		self:_SpendHealthCost()
	end

	function modifier_class:OnDestroy()
		self:_SwapAbilities()
		self:_EndAbility()
		self:_DestroySunRay()
	end

	function modifier_class:_SwapAbilities( )
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		-- Swap the sub_ability back to normal
		local MAIN_ABILITY_NAME = ability:GetAbilityName()
		caster:SwapAbilities( MAIN_ABILITY_NAME, SUB_ABILITY_NAME, true, false )
	end

	function modifier_class:_EndAbility()
		local parent = self:GetParent()
		local originParent = parent:GetAbsOrigin()

		parent:RemoveModifierByName(MODIFIER_ROOTED_NAME)

		-- stop the sound
		parent:StopSound( "Hero_Phoenix.SunRay.Loop" )
		
		-- delete the active particle
		if self.pfx then
			ParticleManager:DestroyParticle( self.pfx, false )
			ParticleManager:ReleaseParticleIndex( self.pfx )
		end
	end

	function modifier_class:_SpendHealthCost()
		local parent = self:GetParent()
		local caster = parent
		local ability = self:GetAbility()
		local hp_cost_perc_per_second = ability:GetSpecialValueFor('hp_cost_perc_per_second')
		local tick_interval = ability:GetSpecialValueFor('tick_interval')

		local hpCost = caster:GetHealth() * (hp_cost_perc_per_second / 100.0)
		hpCost = hpCost * tick_interval
		caster:SetHealth( caster:GetHealth() - hpCost)
	end
	
	function  modifier_class:_InitSunRay()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local numThinkers = ability:GetSpecialValueFor('num_thinkers')
		local thinkerRadius = ability:GetSpecialValueFor('thinker_radius')
		local modifierThinkerName = MODIFIER_THINKER_NAME
		local casterOrigin = caster:GetAbsOrigin()

		-- Create thinkers
		if self.vThinkers == nil then
			local vThinkers = {}
			for i=1, numThinkers do
				local thinker = CreateUnitByName( "npc_dota_invisible_vision_source", casterOrigin, false, caster, caster, caster:GetTeam() )
				vThinkers[i] = thinker

				thinker:SetDayTimeVisionRange( thinkerRadius )
				thinker:SetNightTimeVisionRange( thinkerRadius )

				-- ability:ApplyDataDrivenModifier( caster, thinker, modifierThinkerName, {} )
				thinker:AddNewModifier(caster, ability, modifierThinkerName, {})
			end

			-- Attach a loop sound to the endcap
			local endcapSoundName = "Hero_Phoenix.SunRay.Beam"
			StartSoundEvent( endcapSoundName, vThinkers[numThinkers] )

			self.vThinkers = vThinkers
		end

		local deltaTime = 0.03
		caster:SetContextThink( DoUniqueString( "updateSunRay" ), function ( )
			if self and not self:IsNull() then
				self:_UpdateRate()
				self:_UpdateSunRay()
			end
			return deltaTime
		end, 0.0 )
	end

	function modifier_class:_UpdateSunRay()
		local parent = self:GetParent()
		local caster = parent
		local ability = self:GetAbility()
		local numThinkers = ability:GetSpecialValueFor('num_thinkers')
		local pathLength = ability:GetSpecialValueFor('beam_range')
		local thinkerStep = ability:GetSpecialValueFor('thinker_step')

		local deltaTime = 0.03
		local vThinkers = self.vThinkers
		local endcap = vThinkers[numThinkers]
		
		-- Current position & direction
		local casterOrigin	= caster:GetAbsOrigin()
		local casterForward	= caster:GetForwardVector()

		-- Update thinker positions
		local endcapPos = casterOrigin + casterForward * pathLength
		endcapPos = GetGroundPosition( endcapPos, nil )
		endcapPos.z = endcapPos.z + 92
		endcap:SetAbsOrigin( endcapPos )

		for i=1, numThinkers-1 do
			local thinker = vThinkers[i]
			thinker:SetAbsOrigin( casterOrigin + casterForward * ( thinkerStep * (i-1) ) )
		end

		-- Update particle FX
		ParticleManager:SetParticleControl(self.pfx, 1, endcapPos )


		return deltaTime

	end

	function modifier_class:_UpdateRate()
		local parent = self:GetParent()
		local caster = parent
		local ability = self:GetAbility()
		local lastAngles 		= self.lastAngles or caster:GetAngles()
		local elapsedTime 		= self.elapsedTime or 0.0
		local isInitialTurn 	= self.isInitialTurn or true
		local deltaTime 		= 0.03
		local initTurnDuration	= ability:GetSpecialValueFor('initial_turn_max_duration')
		local turnRateInitial	= ability:GetSpecialValueFor('turn_rate_initial')
		local turnRate			= ability:GetSpecialValueFor('turn_rate')
		local modifierIgnoreTurnRateName = 'modifier_ignore_turn_rate_limit_datadriven'
		--
		-- Note: The turn speed
		--
		--  Original's actual turn speed = 277.7735 (at initial) and 22.2218 [deg/s].
		--  We can achieve this weird value by using this formula.
		--	  actual_turn_rate = turn_rate / (0.0333..) * 0.03
		--
		--  And, initial turn buff ends when the delta yaw gets 0 or 0.75 seconds elapsed.
		--
		turnRateInitial	= turnRateInitial	/ (1/30) * 0.03
		turnRate		= turnRate			/ (1/30) * 0.03

		--
		-- "MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE" is seems to be broken.
		-- So here we fix the yaw angle manually in order to clamp the turn speed.
		--
		-- If the hero has "modifier_ignore_turn_rate_limit_datadriven" modifier,
		-- we shouldn't change yaw from here.
		--


		-- Calculate the turn speed limit.
		local deltaYawMax
		if isInitialTurn then
			deltaYawMax = turnRateInitial * deltaTime
		else
			deltaYawMax = turnRate * deltaTime
		end

		-- Calculate the delta yaw
		local currentAngles	= caster:GetAngles()
		local deltaYaw		= RotationDelta( lastAngles, currentAngles ).y
		local deltaYawAbs	= math.abs( deltaYaw )

		if deltaYawAbs > deltaYawMax and not caster:HasModifier( modifierIgnoreTurnRateName ) then
			-- Clamp delta yaw
			local yawSign = (deltaYaw < 0) and -1 or 1
			local yaw = lastAngles.y + deltaYawMax * yawSign

			currentAngles.y = yaw	-- Never forget!

			-- Update the yaw
			caster:SetAngles( currentAngles.x, currentAngles.y, currentAngles.z )
		end

		lastAngles = currentAngles

		-- Update the turning state.
		elapsedTime = elapsedTime + deltaTime

		if isInitialTurn then
			if deltaYawAbs == 0 then
				isInitialTurn = false
			end
			if elapsedTime >= initTurnDuration then
				isInitialTurn = false
			end
		end

		self.isInitialTurn = isInitialTurn
		self.elapsedTime = elapsedTime
		self.lastAngles = lastAngles
	end
	
	function modifier_class:_DestroySunRay()
		local parent = self:GetParent()
		local caster = parent
		local ability = self:GetAbility()
		local numThinkers = ability:GetSpecialValueFor('num_thinkers')
		local vThinkers = self.vThinkers
		local endcap = vThinkers[numThinkers]

		local endcapSoundName = "Hero_Phoenix.SunRay.Beam"
		StopSoundEvent( endcapSoundName, endcap )

		for i=1, numThinkers do
			vThinkers[i]:RemoveSelf()
		end
	end
end


