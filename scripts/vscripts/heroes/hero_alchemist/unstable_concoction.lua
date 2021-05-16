-------------------------------------------
--          UNSTABLE CONCOCTION
-------------------------------------------
-- Visible Modifiers:
LinkLuaModifier("modifier_imba_unstable_concoction_handler", "heroes/hero_alchemist/unstable_concoction", LUA_MODIFIER_MOTION_NONE)

alchemist_unstable_concoction_custom = alchemist_unstable_concoction_custom or class({})

function alchemist_unstable_concoction_custom:GetAbilityTextureName()
	return "alchemist_unstable_concoction"
end

function alchemist_unstable_concoction_custom:GetCastRange(location, target)
	-- local caster = self:GetCaster()
	
	-- if caster:HasModifier("modifier_imba_unstable_concoction_handler") then
		return self.BaseClass.GetCastRange(self, location, target)
	-- end
end

function alchemist_unstable_concoction_custom:IsHiddenWhenStolen()
	return false
end

function alchemist_unstable_concoction_custom:OnUnStolen()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_imba_unstable_concoction_handler")
end

function alchemist_unstable_concoction_custom:OnSpellStart()
	local caster = self:GetCaster()
	local cast_response = {"alchemist_alch_ability_concoc_01", "alchemist_alch_ability_concoc_02", "alchemist_alch_ability_concoc_03", "alchemist_alch_ability_concoc_04", "alchemist_alch_ability_concoc_05", "alchemist_alch_ability_concoc_06", "alchemist_alch_ability_concoc_07", "alchemist_alch_ability_concoc_08", "alchemist_alch_ability_concoc_10"}
	local last_second_throw_response = {"alchemist_alch_ability_concoc_16", "alchemist_alch_ability_concoc_17"}
	if caster:HasModifier("modifier_imba_unstable_concoction_handler") then
		local target = self:GetCursorTarget()
		-- Stops the charging sound
		caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")
		--Emit the throwing sound
		caster:EmitSound("Hero_Alchemist.UnstableConcoction.Throw")
		-- Last second throw responses
		local modifier_unstable_handler = caster:FindModifierByName("modifier_imba_unstable_concoction_handler")
		if modifier_unstable_handler then
			local remaining_time = modifier_unstable_handler:GetRemainingTime()
			if remaining_time < 1 then
				EmitSoundOn(last_second_throw_response[math.random(1,#last_second_throw_response)], caster)
			end
		end

		caster:RemoveModifierByName("modifier_imba_unstable_concoction_handler")

		caster:StartGesture(ACT_DOTA_ALCHEMIST_CONCOCTION_THROW)
		caster:FadeGesture(ACT_DOTA_ALCHEMIST_CONCOCTION)

		-- Set how much time the spell charged
		self.time_charged = GameRules:GetGameTime() - self.brew_start

		-- Remove the brewing modifier
		caster:RemoveModifierByName("modifier_imba_unstable_concoction_handler")

		Timers:CreateTimer(0.3, function()
			local projectile_speed = self:GetSpecialValueFor("movement_speed")
			local info =
			{
				Target = target,
				Source = caster,
				Ability = self,
				bDodgeable = false,
				EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf",
				iMoveSpeed = projectile_speed,
			}

			ProjectileManager:CreateTrackingProjectile(info)
		end)
		return
	end

	EmitSoundOn(cast_response[math.random(1,#cast_response)], caster)
	caster:StartGesture(ACT_DOTA_ALCHEMIST_CONCOCTION)
	self.brew_start = GameRules:GetGameTime()
	self.brew_time = self:GetSpecialValueFor("brew_time")
	local extra_brew_time = self:GetSpecialValueFor("extra_brew_time")
	local duration = self.brew_time + extra_brew_time
	self.stun = self:GetSpecialValueFor("stun")
	self.damage = self:GetSpecialValueFor("damage")
	local greed_modifier = caster:FindModifierByName("modifier_imba_goblins_greed_passive")
	if greed_modifier then
		local greed_stacks = greed_modifier:GetStackCount()
		local greed_multiplier = self:GetSpecialValueFor("time_per_stack")
		duration = duration + (greed_stacks * greed_multiplier)
	end

	-- #6 Talent : When in Chemical Rage, Alchemist brews Unstable Concoction faster.
	local speed_multiplier
	if caster:HasTalent("special_bonus_imba_alchemist_6")  and caster:FindModifierByName("modifier_imba_chemical_rage_buff_haste")  then
		speed_multiplier	=	caster:FindTalentValue("special_bonus_imba_alchemist_6")
	else speed_multiplier	=	1 		end

	duration = duration / speed_multiplier

	caster:AddNewModifier(caster, self, "modifier_imba_unstable_concoction_handler", {duration = duration,})
	self.radius = self:GetSpecialValueFor("radius")

	-- Play the sound, which will be stopped when the sub ability fires
	caster:EmitSound("Hero_Alchemist.UnstableConcoction.Fuse")
end

function alchemist_unstable_concoction_custom:OnProjectileHit(target, location)
	if IsServer() then

		local caster = self:GetCaster()
		local particle_acid_blast = "particles/hero/alchemist/acid_spray_blast.vpcf"
		local brew_duration = (GameRules:GetGameTime() - self.brew_start)
		caster:FadeGesture(ACT_DOTA_ALCHEMIST_CONCOCTION)
		--Emit blow up sound
		target:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")

		-- If the target is an enemy:
		if target:GetTeam() ~= caster:GetTeam() or target == caster then
			local damage_type = self:GetAbilityDamageType()
			local stun = self.stun
			local damage = self.damage
			local radius = self:GetAOERadius()
			local kill_response = {"alchemist_alch_ability_concoc_09", "alchemist_alch_ability_concoc_15"}

			if target then
				location = target:GetAbsOrigin()
			end
			local units = FindUnitsInRadius(caster:GetTeam(), location, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags() - DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, FIND_ANY_ORDER, false)

			local brew_percentage = brew_duration / self.brew_time

			-- #6 Talent : When in Chemical Rage, Alchemist brews Unstable Concoction faster.
			local speed_multiplier
			if caster:HasTalent("special_bonus_imba_alchemist_6") and caster:FindModifierByName("modifier_imba_chemical_rage_buff_haste")  then
				speed_multiplier	=	caster:FindTalentValue("special_bonus_imba_alchemist_6")
			else speed_multiplier	=	1 		end

			brew_percentage = brew_percentage * speed_multiplier

			local damage = damage * brew_percentage
			local stun_duration = stun * brew_percentage
			if stun_duration > stun then
				stun_duration = stun
			end

			if target then
				if target == caster then
					if not target:IsMagicImmune() then
						if not target:IsInvulnerable() then
							if not target:IsOutOfGame() then
								ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = damage_type,})
								target:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration})
							end
						end
					end
				else
					if target:TriggerSpellAbsorb(self) then
						return
					end
				end
			end

			-- Apply the AoE stun and damage with the variable duration
			local enemy_killed = false
			for _,unit in pairs(units) do
				if unit:GetTeam() ~= caster:GetTeam() then
					ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = damage_type,})
					unit:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration })

					-- See if enemy survive the impact to decide if to roll for a kill response
					Timers:CreateTimer(FrameTime(), function()
						if not unit:IsAlive() and RollPercentage(50) then
							EmitSoundOn(kill_response[math.random(1, #kill_response)], caster)
						end
					end)

				end
			end
		end
	end
end

function alchemist_unstable_concoction_custom:GetAbilityTextureName()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_imba_unstable_concoction_handler") then
		return "alchemist_unstable_concoction_throw"
	end
	return self.BaseClass.GetAbilityTextureName(self)
end

function alchemist_unstable_concoction_custom:GetCooldown(level)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_imba_unstable_concoction_handler") then
		if IsServer() then
			return self.BaseClass.GetCooldown(self, level) - (GameRules:GetGameTime() - self.brew_start)
		end
		return 0
	end
	if IsServer() then
		return 0
	end
	return self.BaseClass.GetCooldown(self, level)
end

function alchemist_unstable_concoction_custom:GetManaCost(level)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_imba_unstable_concoction_handler") then
		return 0
	end
	return self.BaseClass.GetManaCost(self, level)
end


function alchemist_unstable_concoction_custom:GetCastTime()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_imba_unstable_concoction_handler") then
		return self.BaseClass.GetCastTime(self)
	end
	return 0
end

function alchemist_unstable_concoction_custom:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_imba_unstable_concoction_handler") then
		return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end


function alchemist_unstable_concoction_custom:CastFilterResultTarget( target )
	-- Talent #2 : Unstable Concoction can now be cast on allies.
	if IsServer() then
		local caster = self:GetCaster()
		local hasTalent = caster:HasTalent("special_bonus_imba_alchemist_2")
		if target ~= nil then
			if target:GetTeam() == caster:GetTeam() and not hasTalent then
				return UF_FAIL_FRIENDLY
			end

			if caster == target then
				return UF_FAIL_CUSTOM
			end
		end

		local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), caster:GetTeamNumber() )
		return nResult
	end
end

function alchemist_unstable_concoction_custom:GetCustomCastErrorTarget(target)
	return "dota_hud_error_cant_cast_on_self"
end

function alchemist_unstable_concoction_custom:ProcsMagicStick()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_imba_unstable_concoction_handler") then
		return false
	end
	return true
end

function alchemist_unstable_concoction_custom:GetAOERadius()
	return self:GetSpecialValueFor("radius") 
end

modifier_imba_unstable_concoction_handler = modifier_imba_unstable_concoction_handler or class({})

function modifier_imba_unstable_concoction_handler:IsPurgable()
	return false
end


function modifier_imba_unstable_concoction_handler:IsHidden()
	return true
end

function modifier_imba_unstable_concoction_handler:OnDestroy()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if IsServer() then
		--Blow up the concoction on death
		if not caster:IsAlive() then
			caster:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
			caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")
			ability:OnProjectileHit(caster, caster:GetAbsOrigin())
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

function modifier_imba_unstable_concoction_handler:OnCreated()
	self:StartIntervalThink(FrameTime())
end

function modifier_imba_unstable_concoction_handler:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local last_second_response = {"alchemist_alch_ability_concoc_11", "alchemist_alch_ability_concoc_12", "alchemist_alch_ability_concoc_13", "alchemist_alch_ability_concoc_14", "alchemist_alch_ability_concoc_18", "alchemist_alch_ability_concoc_19", "alchemist_alch_ability_concoc_20"}
		local self_blow_response = {"alchemist_alch_ability_concoc_21", "alchemist_alch_ability_concoc_22", "alchemist_alch_ability_concoc_23", "alchemist_alch_ability_concoc_24", "alchemist_alch_ability_concoc_25"}
		local brew_time_passed	=	self:GetDuration()

		-- Show the particle to all allies
		local allHeroes = HeroList:GetAllHeroes()
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"
		local number = math.abs(GameRules:GetGameTime() - ability.brew_start - brew_time_passed)

		if caster:HasTalent("special_bonus_imba_alchemist_6") and caster:HasModifier("modifier_imba_chemical_rage_buff_haste") then
			number = number * caster:FindTalentValue("special_bonus_imba_alchemist_6")
		end

		-- Get the integer. Add a bit because the think interval isn't a perfect 0.5 timer
		local integer = math.floor(number)
		if integer <= 0 and not self.last_second_responded then
			self.last_second_responded = true
			EmitSoundOn(last_second_response[math.random(1,#last_second_response)], caster)
		end

		-- Get the amount of digits to show
		local digits = math.floor(math.log10(number)) + 2

		-- Round the decimal number to .0 or .5
		local decimal = number % 1

		if decimal < 0.04 then
			decimal = 1 -- ".0"
		elseif decimal > 0.5
			and decimal < 0.54 then
			decimal = 8 -- ".5"
		else
			return
		end

		-- Don't display the 0.0 message
		if not (integer == 0 and decimal <= 1) then
			for k, v in pairs(allHeroes) do
				if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
					local particle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, caster)
					ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
					ParticleManager:SetParticleControl(particle, 1, Vector(0, integer, decimal))
					ParticleManager:SetParticleControl(particle, 2, Vector(digits, 0, 0))

					if caster:HasTalent("special_bonus_imba_alchemist_6") and caster:HasModifier("modifier_imba_chemical_rage_buff_haste") then
						Timers:CreateTimer(0.5 / caster:FindTalentValue("special_bonus_imba_alchemist_6"), function()
							ParticleManager:DestroyParticle(particle, true)
							ParticleManager:ReleaseParticleIndex(particle)
						end)
					else
						ParticleManager:ReleaseParticleIndex(particle)
					end
				end
			end
		else

			-- Set how much time the spell charged
			ability.time_charged = GameRules:GetGameTime() - ability.brew_start

			-- Self-blow response
			EmitSoundOn(self_blow_response[math.random(1, #self_blow_response)], caster)

			local info =
				{
					Target = caster,
					Source = caster,
					Ability = ability,
					bDodgeable = false,
					EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf",
					iMoveSpeed = ability:GetSpecialValueFor("movement_speed"),
				}
			ProjectileManager:CreateTrackingProjectile(info)
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
			caster:RemoveModifierByName("modifier_imba_unstable_concoction_handler")
		end
	end
end
