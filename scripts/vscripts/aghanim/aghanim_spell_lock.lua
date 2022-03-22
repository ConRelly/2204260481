require("lib/timers")

aghanim_spell_lock = class({})

LinkLuaModifier( "modifier_aghanim_spell_lock", "aghanim/aghanim_spell_lock", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghanim_spell_lock_handler", "aghanim/aghanim_spell_lock", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghanim_spell_lock_debuff", "aghanim/aghanim_spell_lock", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghanim_spell_lock_crystal", "aghanim/aghanim_spell_lock", LUA_MODIFIER_MOTION_BOTH )

function aghanim_spell_lock:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_channel.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_spell_swap_beam.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_spellswap_replenish.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_spellswap_ambient.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_destroy.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_impact.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_attack.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_wisp/wisp_tether_hit.vpcf", context)

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_silencer.vsndevts", context )

	PrecacheResource( "model", "models/props_gameplay/aghanim_gem.vmdl", context )
end

function aghanim_spell_lock:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not target or target:TriggerSpellAbsorb(self) or target:TriggerSpellReflect( self ) then return false end

	EmitSoundOn( "Hero_Pugna.LifeDrain.Cast", caster )
    EmitSoundOn( "Hero_Pugna.LifeDrain.Loop", caster )
    
	target:AddNewModifier(caster, self, "modifier_aghanim_spell_lock_debuff", {duration = self:GetSpecialValueFor("link_duration")} )
	caster:AddNewModifier(caster, self, "modifier_aghanim_spell_lock_handler", {duration = self:GetSpecialValueFor("link_duration"), target = target:entindex() })
end

function aghanim_spell_lock:TalentCrystal( level, destination )
	local origin = self:GetCaster():GetAbsOrigin()
	local distance = (origin-destination):Length2D()
    local speed = distance / 0.5

	-- Init the level based stats
	local pass_damage = {60,80,100}
	local proc_damage = {100,120,150}
	local stun_duration = {0.1,0.2,0.5}

    local info = {
		Source = self:GetCaster(),
		Ability = self,
		vSpawnOrigin = origin,
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = "particles/creatures/aghanim/aghanim_crystal_attack.vpcf",
	    fDistance = distance,
	    fStartRadius = 110,
	    fEndRadius = 110,
		vVelocity = (destination-origin):Normalized() * speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		
		ExtraData = {
			pass_damage = pass_damage[level],
			proc_damage = proc_damage[level],
			stun_duration = stun_duration[level]
		}
    }
    local handle = ProjectileManager:CreateLinearProjectile( info )
end

function aghanim_spell_lock:OnProjectileHit_ExtraData( hTarget, vLocation, data )
    if not IsServer() then return end

    if not hTarget or hTarget:IsHero() then
        self:Erupt( vLocation, data.proc_damage, data.stun_duration )
        return true
    end

    -- Deal pass through / trigger damage
    local damageInfo = {
        victim = hTarget,
        attacker = self:GetCaster(),
        damage = data.pass_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }
    ApplyDamage( damageInfo )

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, vLocation)

    EmitSoundOn("Hero_DarkWillow.WillOWisp.Damage", hTarget)

    return false
end

function aghanim_spell_lock:Erupt( position, damage, duration )
    local caster = self:GetCaster()
    local damageInfo = {
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }

    local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		position,
		nil,
		250,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		0,
		false
	)

    for _,target in pairs(enemies) do
        damageInfo.victim = target
        ApplyDamage( damageInfo )

        target:AddNewModifier(caster, self, "modifier_stunned", {duration = duration})
    end

    local particle = ParticleManager:CreateParticle("particles/creatures/aghanim/aghanim_crystal_attack_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, position)

    EmitSoundOnLocationWithCaster(position, "Hero_Silencer.LastWord.Damage", self:GetCaster() )

    return true
end

--=================================================================================================

modifier_aghanim_spell_lock_handler = class({})
function modifier_aghanim_spell_lock_handler:IsHidden() return true end
function modifier_aghanim_spell_lock_handler:IsPurgable() return false end
function modifier_aghanim_spell_lock_handler:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_aghanim_spell_lock_handler:OnCreated(kv)
	if IsServer() then
		self.target = EntIndexToHScript(kv.target)
		self.broken = false

		if not self.target or self.target:IsIllusion() then
			if self.target:IsIllusion() then self.target:ForceKill(false) end
			self.broken = true
			if self:IsNull() then return end
			self:Destroy()
			return
		end

		self.beamFX = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_spell_swap_beam.vpcf", PATTACH_CUSTOMORIGIN, caster )

		local szAttachment = "attach_hand_R"
		if RandomInt( 0, 1 ) == 1 then
			szAttachment = "attach_lower_hand_R"
		end
		ParticleManager:SetParticleControlEnt( self.beamFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, szAttachment, self:GetParent():GetAbsOrigin(), true )
		ParticleManager:SetParticleControlEnt( self.beamFX, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true )
		ParticleManager:SetParticleControl( self.beamFX, 11, Vector( 1, 0, 0 ) )

		self:StartIntervalThink(0.1)
	end
end

function modifier_aghanim_spell_lock_handler:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local caster_pos = caster:GetAbsOrigin()
		local target_pos = self.target:GetAbsOrigin()

		local range_mult = self:GetAbility():GetSpecialValueFor("link_threshold_mult")
		local link_threshold = (self:GetAbility():GetCastRange(caster_pos, self.target) + caster:GetCastRangeBonus())*range_mult

		-- Add filters for range, vision, caster and target state
		if (caster_pos - target_pos):Length2D() > link_threshold then
			self.broken = true

		elseif self.target:IsMagicImmune() or (not self.target:IsAlive()) or (not caster:IsAlive()) or self.stuff then
			self.broken = true	
		end

		if self.broken then self:Destroy() end
	end
end

function modifier_aghanim_spell_lock_handler:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		if self.beamFX == nil then return end

		-- Remove the particles
		ParticleManager:DestroyParticle( self.beamFX, true )

		StopSoundOn( "Hero_Pugna.LifeDrain.Loop", self:GetParent() )

		-- Remove the slow debuff
		self.target:RemoveModifierByName( "modifier_aghanim_spell_lock_debuff" )

		-- Add the crystals on successful link completion
		if not self.broken then
			if not self.target:IsAlive() or not self.target:IsRealHero() then return end

			local crystal_duration = ability:GetSpecialValueFor("crystal_duration")
			self.target:AddNewModifier( self:GetParent(), ability, "modifier_aghanim_spell_lock", { duration = crystal_duration } )
		end
	end
end

-- Change the animation to the succ 
function modifier_aghanim_spell_lock_handler:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION, 
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT
	}
end

function modifier_aghanim_spell_lock_handler:GetOverrideAnimation()	return ACT_DOTA_CHANNEL_ABILITY_5 end
function modifier_aghanim_spell_lock_handler:GetOverrideAnimationWeight() return 1000 end

--=================================================================================================

-- Channel slow debuff
modifier_aghanim_spell_lock_debuff = class({})
function modifier_aghanim_spell_lock_debuff:IsHidden() return true end
function modifier_aghanim_spell_lock_debuff:IsPurgable() return true end
function modifier_aghanim_spell_lock_debuff:IsDebuff() return true end

function modifier_aghanim_spell_lock_debuff:OnCreated()
	if IsServer() then
		local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_aghanim_7")
		if talent and talent:GetLevel() > 0 then
			self:SetStackCount( talent:GetSpecialValueFor("value") )
		end
	end
	
	local think_rate = 0.1
	local slow_amount = self:GetAbility():GetSpecialValueFor("move_speed_slow_perc")
	if self:GetStackCount() > 0 then 
		slow_amount = slow_amount + self:GetStackCount()
	end

    self.slow_increment = slow_amount / (self:GetDuration() / think_rate)
	self.current_slow = -1 * self.slow_increment

	self:StartIntervalThink( think_rate )
end

function modifier_aghanim_spell_lock_debuff:OnIntervalThink()
	self.current_slow = self.current_slow - self.slow_increment
end

function modifier_aghanim_spell_lock_debuff:CheckState()
	return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end

function modifier_aghanim_spell_lock_debuff:DeclareFunctions() 
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } 
end

function modifier_aghanim_spell_lock_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.current_slow
end

--=================================================================================================

modifier_aghanim_spell_lock = class({})
function modifier_aghanim_spell_lock:IsHidden()	return false end
function modifier_aghanim_spell_lock:IsPurgable() return false end
function modifier_aghanim_spell_lock:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_aghanim_spell_lock:GetTexture() return "aghanim_spell_locked" end

function modifier_aghanim_spell_lock:OnCreated( kv )
	if IsServer() then
		local parent = self:GetParent()
		if parent and not parent:IsNull() then
			local skills_nr = 0
			for i=0, 31 do
				local hAbility = self:GetParent():GetAbilityByIndex( i )
				if hAbility and not hAbility:IsCosmetic( nil ) then
					--print( "Counting Ability: ".. skills_nr .. " ".. hAbility:GetAbilityName() .. "  slot " .. i )
					skills_nr = skills_nr + 1
				end
			end
			print("number skills " .. skills_nr)
			if skills_nr < 32 then 
				self:DisableSpell()
				self:StartIntervalThink(0.2)
			end	
		end		
	end
end

function modifier_aghanim_spell_lock:OnIntervalThink()
	if self and not self:IsNull() and self:GetCaster() ~= nil then
		local caster_pos = self:GetCaster():GetAbsOrigin()
		local my_pos = self:GetParent():GetAbsOrigin()
		local max_distance = self:GetAbility():GetSpecialValueFor("max_distance")

		if (caster_pos - my_pos):Length2D() >= max_distance then
			self:RestoreSpell()
		end
		if self.stuff then
			self:RestoreSpell()
		end	
	end	
end

function modifier_aghanim_spell_lock:OnDestroy()
	if IsServer() then
		self:RestoreSpell()
	end
end

function modifier_aghanim_spell_lock:DeclareFunctions()
	return { MODIFIER_EVENT_ON_DEATH, MODIFIER_EVENT_ON_ATTACKED }
end

function modifier_aghanim_spell_lock:OnDeath( keys )
	if IsServer() then
		if keys.unit == self.hCrystal then
			if self:IsNull() then return end
			self:Destroy()
		end
	end
end

function modifier_aghanim_spell_lock:OnAttacked(keys)
	if keys.target == self:GetParent() and keys.attacker == self:GetCaster() then
		local damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
		local damageInfo = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
		}
		ApplyDamage( damageInfo )

		EmitSoundOn( "Hero_Wisp.Spirits.Destroy", self:GetParent() )
	end
end

function modifier_aghanim_spell_lock:DisableSpell()
	if IsServer() then
        local NormalAbilities = {}
		
		local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_aghanim_4")
		local exclude_table = {
			mjz_ember_spirit_sleight_of_fist = true,
			spirit_breaker_greater_bash = true,
			lion_custom_finger_of_death = true,
			mjz_finger_of_death = true,
			mjz_lina_laguna_blade = true,
			keeper_of_the_light_illuminate = true,
			keeper_of_the_light_spirit_form_illuminate = true,
			mjz_riki_backstab = true,
			mjz_invoker_magic_master = true,
			sourcery = true,
			lesser_cancel = true,
			divine_cancel = true,
			sniper_shoot = true,
			reload_bullet = true,
			change_bullets_type = true,
			kardels_skills = true,

		}      

		for i=0,DOTA_MAX_ABILITIES-1 do
			local hAbility = self:GetParent():GetAbilityByIndex( i )

            
			if hAbility and not hAbility:IsCosmetic(nil) and -- Dunno
				not hAbility:IsAttributeBonus() and -- Talent
				hAbility:GetAssociatedPrimaryAbilities() == nil and -- Dunno
				not hAbility:IsHidden() and -- Actually an ability
				not exclude_table[hAbility:GetAbilityName()] and
				not hAbility.bAghDisabled == true and  -- Already disabled
				--bit.band( hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_TOGGLE ) ~= 0 and
				not hAbility.bAghDummy == true and  -- Dummy?
				not hAbility:IsToggle() and
				hAbility:IsActivated() and -- Can be used by target
				hAbility:GetLevel() > 0 and -- Is Levelled
				not string.find(hAbility:GetAbilityName(), "empty") then -- Filter out empty abilities (like doom and rubick slots)

				-- Talent prioritises ults
				if talent and talent:GetLevel() > 0 and hAbility:GetAbilityType() == 1 then
					NormalAbilities = {}
					table.insert( NormalAbilities, hAbility )
					break
				end
                
				if hAbility:GetAbilityType() == 0 then
					table.insert( NormalAbilities, hAbility )
				end
				--[[local skip = false
				if self:GetParent():HasModifier( hAbility:GetIntrinsicModifierName() ) then
					local stacks = self:GetParent():FindModifierByName( hAbility:GetIntrinsicModifierName() )
					if stacks > 0 then
						skip = true
					end
				end]]		

			end
		end

		local nNextAghDummy = nil
		for j=1,4 do		
			local szName = tostring( "aghanim_empty_spell" .. j )
			local hDummyAbility = self:GetParent():FindAbilityByName( szName )
			nNextAghDummy = j
			if not hDummyAbility then
				break
			end
		end	

	
		local nIndexToDisable = math.random( 1, #NormalAbilities )
		local hAbilityToDisable = NormalAbilities[ nIndexToDisable ]

		if nNextAghDummy == nil or hAbilityToDisable == nil then
			if self:IsNull() then return end
			self:Destroy()
			return
		end
		local hNewDummyAbility = self:GetParent():AddAbility( tostring( "aghanim_empty_spell" .. nNextAghDummy ) )
		if hNewDummyAbility then
			--print( "adding dummy ability for disable: " .. hNewDummyAbility:GetAbilityName() )
			hNewDummyAbility:UpgradeAbility( true )
			hNewDummyAbility:SetActivated( true )
			hNewDummyAbility.bAghDummy = true
			hNewDummyAbility.nOriginalIndex = hNewDummyAbility:GetAbilityIndex()
		end
		

		hAbilityToDisable.bAghDisabled = true
		--print( "disabling " .. hAbilityToDisable:GetAbilityName() )
		if hAbilityToDisable:GetToggleState() then
			hAbilityToDisable:OnToggle()
		end

		hAbilityToDisable:SetActivated( false )
		hAbilityToDisable.nOriginalIndex = hAbilityToDisable:GetAbilityIndex()

		self.hDisabledAbility = hAbilityToDisable
		self.hDummyAbility = hNewDummyAbility
        self.stuff = false
		self:GetParent():SwapAbilities( self.hDisabledAbility:GetAbilityName(), self.hDummyAbility:GetAbilityName(), false, true )
		if self.hDisabledAbility:GetIntrinsicModifierName() then
			if self:GetParent():HasModifier( self.hDisabledAbility:GetIntrinsicModifierName() ) then
				local modifier = self:GetParent():FindModifierByName( self.hDisabledAbility:GetIntrinsicModifierName() )
				self.intrinsicStacks = 0
				if modifier:GetStackCount() > 0 and not self.stuff then
					self.intrinsicStacks = modifier:GetStackCount()
					Timers:CreateTimer({
						endTime = 0.2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
						callback = function()
							self.broken = true
						end
					})
					self.stuff = true					 
                end
				self:GetParent():RemoveModifierByName( self.hDisabledAbility:GetIntrinsicModifierName() )
			end
		end

		self.hDummyAbility:SetActivated( false )

		self.hCrystal = CreateUnitByName( 
            "npc_dota_boss_aghanim_crystal", 
            self:GetCaster():GetAbsOrigin(), 
            true, 
            self:GetCaster(), 
            self:GetCaster():GetOwner(), 
            self:GetCaster():GetTeamNumber() 
        )

		if self.hCrystal then
			self.hCrystal:SetOwner( self:GetCaster() )
			self.hCrystal:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_aghanim_spell_lock_crystal", { spell = self.hDisabledAbility:entindex() } )
		end

		-- Shoot the crystal with the talent
		local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_aghanim_8")
		if talent and talent:GetLevel() > 0 then
			local crystal_source = self:GetCaster():FindAbilityByName("aghanim_shard_toss")
			local level = 1
			if crystal_source and crystal_source:GetLevel() > 1 then level = crystal_source:GetLevel() end
			self:GetAbility():TalentCrystal( level, self:GetParent():GetAbsOrigin() )
		end
	end
end

function modifier_aghanim_spell_lock:RestoreSpell()
	if IsServer() then
		if self.hDisabledAbility and self.hDummyAbility then
			self.hDisabledAbility:SetActivated( true )
			if self.hDisabledAbility:GetIntrinsicModifierName() then
				local parent = self:GetParent()
				local passive = parent:AddNewModifier(self:GetParent(), self.hDisabledAbility, self.hDisabledAbility:GetIntrinsicModifierName(), {})
				if self.intrinsicStacks > 0 then
					passive:SetStackCount( self.intrinsicStacks )
				end
			end
			self.hDisabledAbility.bAghDisabled = false
			self.hDisabledAbility:SetHidden( false )
			self:GetParent():RemoveAbilityFromIndexByName( self.hDisabledAbility:GetAbilityName() )
			self:GetParent():SetAbilityByIndex( self.hDisabledAbility, self.hDisabledAbility.nOriginalIndex ) -- this destroys the dummy spell
			
			if self.hCrystal then
				self.hCrystal:AddEffects( EF_NODRAW )
				if self.hCrystal:IsAlive() then
					self.hCrystal:ForceKill( false )
				end

				local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_destroy.vpcf", PATTACH_CUSTOMORIGIN, nil )
				ParticleManager:SetParticleControl( nFXIndex, 0, self.hCrystal:GetAbsOrigin() )
				ParticleManager:ReleaseParticleIndex( nFXIndex )

				EmitSoundOn( "Hero_Wisp.Spirits.Destroy", self.hCrystal )

				local nFXIndex2 = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_spellswap_replenish.vpcf", PATTACH_CUSTOMORIGIN, nil )	
				ParticleManager:SetParticleControlEnt( nFXIndex2, 0, self.hCrystal, PATTACH_POINT_FOLLOW, "attach_attack1", self.hCrystal:GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( nFXIndex2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex2 )
			end
		end
	end
end

--=================================================================================================

modifier_aghanim_spell_lock_crystal = class({})
function modifier_aghanim_spell_lock_crystal:IsHidden()	return false end
function modifier_aghanim_spell_lock_crystal:IsPurgable() return false end
function modifier_aghanim_spell_lock_crystal:GetEffectName() 
    return "particles/creatures/aghanim/aghanim_crystal_spellswap_ambient.vpcf" 
end

-- Make sure the client knows what spell texture to use
function modifier_aghanim_spell_lock_crystal:AddCustomTransmitterData()	return { spell_name = self.spell } end
function modifier_aghanim_spell_lock_crystal:HandleCustomTransmitterData( data )
	if data.spell_name ~= nil and self.spell ~= data.spell_name then
		self.spell = data.spell_name
	end
end
function modifier_aghanim_spell_lock_crystal:GetTexture()
	return self.spell
end

function modifier_aghanim_spell_lock_crystal:OnCreated( kv )
	self:SetHasCustomTransmitterData( true )

	if IsServer() then
		self.num_crystal_hits = self:GetAbility():GetSpecialValueFor( "num_crystal_hits" )

		-- Increase crystal hp w/ talent
		local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_aghanim_3")
		if talent and talent:GetLevel() > 0 then
			self.num_crystal_hits = self.num_crystal_hits + talent:GetSpecialValueFor("value")
		end

		self.spell = EntIndexToHScript(kv.spell):GetAbilityName()

		self:GetParent():SetBaseMaxHealth( self.num_crystal_hits )
		self:GetParent():SetMaxHealth( self.num_crystal_hits )
		self:GetParent():SetHealth( self.num_crystal_hits  )

		self.flRotationTime = 12.0
		self.flRotationDist = 275.0
		self.flHeight = 0.0 --RandomFloat( 0.0, 20.0 ) - 20.0 --Left in case I want to randomize height 
		self.flRotation = RandomFloat( 0, 360 )
		self.flRecoverTime = -1

		self:StartIntervalThink( 0.25 )
		
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			if self:IsNull() then return end
			self:Destroy()
			return
		end
	end
end

function modifier_aghanim_spell_lock_crystal:OnIntervalThink()
	if IsServer() then
		if GameRules:GetGameTime() > self.flRecoverTime then
			self.flRotationTime = 12.0
		end
	end
end

function modifier_aghanim_spell_lock_crystal:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )
	end
end

function modifier_aghanim_spell_lock_crystal:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACKED,
	}
	return funcs
end

function modifier_aghanim_spell_lock_crystal:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_FLYING] = true,
	}
	return state
end

function modifier_aghanim_spell_lock_crystal:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_aghanim_spell_lock_crystal:GetAbsoluteNoDamageMagical() return 1 end
function modifier_aghanim_spell_lock_crystal:GetAbsoluteNoDamagePure() return 1 end
function modifier_aghanim_spell_lock_crystal:GetDisableHealing() return 1 end

function modifier_aghanim_spell_lock_crystal:OnAttacked( keys )
    if IsServer() then
        if keys.target == self:GetParent() and keys.attacker ~= nil then
            local nDamage = 1
			if keys.attacker:IsRealHero() then 
				nDamage = 3
			end

			self.flRotationTime = 36.0
			self.flRecoverTime = GameRules:GetGameTime() + 1.0
			self:GetParent():ModifyHealth( self:GetParent():GetHealth() - nDamage, nil, true, 0 )

			EmitSoundOn( "Hero_Wisp.Spirits.Target", self:GetParent() )

			local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_impact.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
	return 0
end

-- Motion Controller functions
function modifier_aghanim_spell_lock_crystal:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		self.flRotation = self.flRotation + ( 2.0 * dt * math.pi / self.flRotationTime )
		local flX = self.flRotationDist * math.sin( self.flRotation )
		local flY = self.flRotationDist * math.cos( self.flRotation )
		if self:GetCaster() and self:GetParent() then
			local vNewLocation = self:GetCaster():GetAbsOrigin() + Vector( flX, flY, self:GetParent():GetAbsOrigin().z )
			me:SetOrigin( vNewLocation )
		end
	end
end

function modifier_aghanim_spell_lock_crystal:OnHorizontalMotionInterrupted()
	if IsServer() then
		if self:IsNull() then return end
		self:Destroy()
	end
end

function modifier_aghanim_spell_lock_crystal:UpdateVerticalMotion( me, dt )
	if IsServer() then
		local flHeight = GetGroundHeight( self:GetParent():GetAbsOrigin(), self:GetParent() ) + self.flHeight
		local vNewLocation = self:GetParent():GetAbsOrigin()
		vNewLocation.z = flHeight
		me:SetOrigin( vNewLocation )
	end
end

function modifier_aghanim_spell_lock_crystal:OnVerticalMotionInterrupted()
	if IsServer() then
		if self:IsNull() then return end
		self:Destroy()
	end
end