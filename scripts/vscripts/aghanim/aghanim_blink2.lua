aghanim_blink2 = class{}
aghanim_blink5 = aghanim_blink2
LinkLuaModifier("modifier_aghanim_blink_slow", "aghanim/aghanim_blink2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_blink_debuff", "aghanim/aghanim_blink2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_blink_talent", "aghanim/aghanim_blink2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_blink_invul", "aghanim/aghanim_blink2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_blink_slayer", "aghanim/aghanim_blink2", LUA_MODIFIER_MOTION_NONE)

function aghanim_blink5:GetIntrinsicModifierName()
    return "modifier_aghanim_blink_slayer"
end

function aghanim_blink2:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_preimage.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_self_dmg.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_pulse_nova.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_iceblast.vpcf", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lich.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_leshrac.vsndevts", context )
end

function aghanim_blink2:GetCastRange(location, target)
	return self:GetSpecialValueFor("blink_range") + self:GetCaster():GetCastRangeBonus()
end

function aghanim_blink2:GetCastPoint()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cast_point")
	else
		return self:GetSpecialValueFor("normal_cast_point")
	end
end

function aghanim_blink2:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_aoe")
	else
		return self:GetSpecialValueFor("debuff_aoe")
	end
end

function aghanim_blink2:OnSpellStart()
	if IsServer() == false then
		return
	end
	
	local vPos =  self:GetCursorPosition()
	local vDirection = vPos - self:GetCaster():GetOrigin()
	local flDist = vDirection:Length2D()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	local max_range = self:GetSpecialValueFor("blink_range") + self:GetCaster():GetCastRangeBonus()

	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_aghanim_1")
	if talent and talent:GetLevel() > 0 then 
		max_range = max_range + talent:GetSpecialValueFor("value")
	end

	if flDist > max_range then flDist = max_range end

	self.vStartLocation = self:GetCaster():GetAbsOrigin()

	local info = {
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = 0,
		fEndRadius = 0,
		vVelocity = vDirection * flDist * 5,
		fDistance = flDist,
		Source = self:GetCaster(),
	}

	self.projectile = ProjectileManager:CreateLinearProjectile( info )
end

function aghanim_blink2:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		local vDirection = vLocation - self:GetCaster():GetAbsOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		EmitSoundOn( "Hero_FacelessVoid.TimeWalk", self:GetCaster() )

		self:GetCaster():Purge(false, true, false, false, false)
		FindClearSpaceForUnit( self:GetCaster(), vLocation, true )

		ProjectileManager:ProjectileDodge( self:GetCaster() )

		local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_preimage.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self.vStartLocation )
		ParticleManager:SetParticleControl( nFXIndex, 1, self:GetCaster():GetAbsOrigin() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self.vStartLocation, true )
		ParticleManager:SetParticleFoWProperties( nFXIndex, 0, 2, 64.0 )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		self:DebuffEnemies()
	end

	return true
end

function aghanim_blink2:DebuffEnemies()
	local caster = self:GetCaster()
	local scepter = caster:HasScepter()
	local radius 
	if scepter == true then
		radius = self:GetSpecialValueFor("scepter_aoe")
	else
		radius = self:GetSpecialValueFor("debuff_aoe")
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_self_dmg.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( nFXIndex, 2, Vector( radius, radius, radius ) )

	EmitSoundOn( "Hero_Lich.IceAge.Tick", caster )

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		0,
		false
	)	

	if #enemies < 1 then return end

	--local amp = caster:GetSpellAmplification(false)
	local caster_stats = caster:GetStrength() + caster:GetAgility() + caster:GetIntellect(true)
	local damage = self:GetSpecialValueFor("debuff_damage") + caster_stats * self:GetSpecialValueFor("stats_mult") 

	local damageInfo = {
		victim = "placeholder",
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}

	for _,enemy in pairs(enemies) do
		if not enemy:IsOutOfGame() then
			damageInfo.victim = enemy
			ApplyDamage( damageInfo )

			enemy:AddNewModifier(caster, self, "modifier_aghanim_blink_slow", {duration = self:GetSpecialValueFor("slow_duration")})
			enemy:AddNewModifier(caster, self, "modifier_aghanim_blink_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
			caster:AddNewModifier(caster, self, "modifier_aghanim_blink_invul", {duration = self:GetSpecialValueFor("invul_duration")})
			
			local nFXIndex2 = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_pulse_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
			ParticleManager:ReleaseParticleIndex( nFXIndex2 )

			--[[if scepter == true then
				if enemy:IsHero() then 
					local spell_lock = caster:FindAbilityByName("aghanim_spell_lock")
					if spell_lock and spell_lock:GetLevel() > 0 then
						caster:SetCursorCastTarget(enemy)
						spell_lock:OnSpellStart()
					end
				end
			end]]

			EmitSoundOn( "Hero_Leshrac.Pulse_Nova_Strike", enemy )
		end
	end
end

--=================================================================================================

modifier_aghanim_blink_slow = class({})
function modifier_aghanim_blink_slow:IsHidden() return true end
function modifier_aghanim_blink_slow:IsDebuff() return true end
function modifier_aghanim_blink_slow:IsPurgable() return false end
function modifier_aghanim_blink_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_aghanim_blink_slow:GetModifierMoveSpeedBonus_Percentage() 
	return -1*self:GetAbility():GetSpecialValueFor("slow_amount") 
end

--=================================================================================================
modifier_aghanim_blink_invul = class({})
function modifier_aghanim_blink_invul:IsHidden() return false end
function modifier_aghanim_blink_invul:IsDebuff() return false end
function modifier_aghanim_blink_invul:IsPurgable() return false end
function modifier_aghanim_blink_invul:CheckState() 
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        --[MODIFIER_STATE_CANNOT_MISS] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSLOWABLE] = true,
    } 
end
function modifier_aghanim_blink_invul:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
	return funcs	 
end
function modifier_aghanim_blink_invul:GetModifierExtraHealthPercentage() 
	return self:GetAbility():GetSpecialValueFor("health_increase") 
end
function modifier_aghanim_blink_invul:GetModifierAttackRangeBonus() 
	return self:GetAbility():GetSpecialValueFor("attack_range") 
end
--=================================================================================================
modifier_aghanim_blink_slayer = class({})
function modifier_aghanim_blink_slayer:IsHidden() return true end
function modifier_aghanim_blink_slayer:IsDebuff() return false end
function modifier_aghanim_blink_slayer:IsPurgable() return false end
function modifier_aghanim_blink_slayer:OnCreated()
	if IsServer() then
		self:GetParent().bAbsoluteNoStun = true
	end
end
function modifier_aghanim_blink_slayer:CheckState()
	local state = {}
	if not self:GetParent():PassivesDisabled() then
		if self:GetParent() ~= nil and self:GetParent():HasModifier("modifier_mystery_cyclone_active") then
			state = {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_CANNOT_MISS] = true}
		else
			state = {[MODIFIER_STATE_STUNNED] = false, [MODIFIER_STATE_CANNOT_MISS] = true}
		end
	end
    return state
end
function modifier_aghanim_blink_slayer:DeclareFunctions()
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_aghanim_blink_slayer:GetModifierMagicalResistanceBonus()
	if not self:GetParent():PassivesDisabled() then
		if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_resist") end
	end
end
function modifier_aghanim_blink_slayer:GetModifierPhysicalArmorBonus()
	if not self:GetParent():PassivesDisabled() then
		if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_bonus") end
	end
end
function modifier_aghanim_blink_slayer:GetModifierHealthBonus()
	if not self:GetParent():PassivesDisabled() then
		if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("health_bonus") end
	end
end
--=================================================================================================

modifier_aghanim_blink_debuff = class({})
function modifier_aghanim_blink_debuff:IsHidden() return false end
function modifier_aghanim_blink_debuff:IsDebuff() return true end
function modifier_aghanim_blink_debuff:IsPurgable() return false end
function modifier_aghanim_blink_debuff:GetTexture()	return "ancient_apparition_ice_blast" end

function modifier_aghanim_blink_debuff:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_aghanim_blink_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_iceblast.vpcf"
end

function modifier_aghanim_blink_debuff:OnCreated()
	self.reduction = -1 * self:GetAbility():GetSpecialValueFor("heal_reduction")
end

function modifier_aghanim_blink_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET
	}
	return funcs
end

function modifier_aghanim_blink_debuff:GetModifierHealAmplify_PercentageTarget() return self.reduction end
function modifier_aghanim_blink_debuff:GetModifierHPRegenAmplify_Percentage() return self.reduction end
function modifier_aghanim_blink_debuff:GetModifierLifestealRegenAmplify_Percentage() return self.reduction end
function modifier_aghanim_blink_debuff:GetModifierSpellLifestealRegenAmplify_Percentage() return self.reduction end