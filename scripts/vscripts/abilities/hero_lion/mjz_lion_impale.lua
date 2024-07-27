
-- local THIS_LUA = "abilities/hero_lion/mjz_lion_impale.lua"
-- LinkLuaModifier( "modifier_mjz_lion_impale_slow", THIS_LUA, LUA_MODIFIER_MOTION_NONE )

mjz_lion_impale = mjz_lion_impale or class({})

--------------------------------------------------------------------------------

-- function mjz_lion_impale:GetCastRange(vLocation, hTarget)
-- 	return self:GetSpecialValueFor("")
-- end
-- function mjz_lion_impale:GetAOERadius()
-- 	return self:GetSpecialValueFor("")
-- end

function mjz_lion_impale:GetAbilityTextureName()
    if self:GetCaster():HasScepter() then
		return "mjz_lion_impale_immortal"
	end	 
	return "mjz_lion_impale"
end

function mjz_lion_impale:OnAbilityPhaseStart()
	local hCaster = self:GetCaster()
    ParticleManager:FireParticle("particles/units/heroes/hero_lion/lion_spell_impale_staff.vpcf", PATTACH_POINT_FOLLOW, hCaster, {[0]="attach_attack1"})
    return true
end

function mjz_lion_impale:OnSpellStart()
    if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self
	local point = self:GetCursorPosition()
	if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
	end
	
	-- local shock_range = ability:GetTalentSpecialValueFor("")
	-- local point = (caster:GetForwardVector() * 1200):Normalized()
	-- local point =  caster:GetAbsOrigin() + 150 * self:RotateVector2D(caster:GetForwardVector(), math.rad(0))

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

function mjz_lion_impale:PlaySound( source )
    local sound_cast = "Hero_Lion.Impale"
	EmitSoundOn( sound_cast, source )
end

function mjz_lion_impale:SpellPoint( source, point )
    local caster = self:GetCaster()
    local ability = self
    
    local projectile_name = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf"
	local projectile_distance = self:CalcDistance(source, point)	
	local projectile_speed = self:GetSpecialValueFor("speed")
	local projectile_radius = self:GetSpecialValueFor("width")
	local projectile_vision = self:GetSpecialValueFor("vision") or 0
	local bProvidesVision = (projectile_vision > 0)

	local origin = source:GetAbsOrigin()

    -- calculate direction
	local direction = (point - origin):Normalized()
	direction.z = 0
	local vVelocity = direction * projectile_speed

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
	    fEndRadius = projectile_radius,
		vVelocity = vVelocity,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		-- fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = bProvidesVision,
		iVisionRadius = projectile_vision,
		fVisionDuration = 10,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function mjz_lion_impale:OnProjectileHitHandle( target, location, iProjectileHandle )
	local hCaster = self:GetCaster()
	local hAbility = self
	local ability = self
	local hTarget = target
	if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then

		local damage = self:CalcDamage(hTarget)

		EmitSoundOn("Hero_Lion.ImpaleHitTarget", hTarget)

		local p_hit = "particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf"
		ParticleManager:FireParticle(p_hit, PATTACH_POINT, hTarget, {})

		self:_ApplyDebuff(hTarget, location, iProjectileHandle)

		Timers:CreateTimer(0.5, function()
			local damageTable = {
				victim = hTarget,
				attacker = hCaster,
				damage = damage,
				damage_type = hAbility:GetAbilityDamageType(),
				ability = hAbility, --Optional.
				damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			}
			ApplyDamage(damageTable)
		end)

	end
end

function mjz_lion_impale:_ApplyDebuff(hTarget, vLocation, iProjectileHandle)
	local hCaster = self:GetCaster()
	local hAbility = self
	

	local duration = hAbility:GetTalentSpecialValueFor("duration")
	hTarget:AddNewModifier(hCaster, hAbility, "modifier_stunned", { duration = duration } )
end

function mjz_lion_impale:CalcDistance(source, point)
	local hCaster = self:GetCaster()
	local hAbility = self
	local length_buffer = hAbility:GetTalentSpecialValueFor("length_buffer")
	local distance = hAbility:GetCastRange(hCaster:GetAbsOrigin(), hCaster) + length_buffer + hCaster:GetCastRangeBonus()
	-- local distance = (point - hCaster:GetAbsOrigin()):Length2D()
	return distance
end

function mjz_lion_impale:CalcDamage( target )
    local caster = self:GetCaster()
    local ability = self
    
    local base_damage = ability:GetTalentSpecialValueFor( "base_damage")
    local int_damage = ability:GetTalentSpecialValueFor( "int_damage")
	local damage = base_damage
	if caster:IsHero() then
		damage = base_damage + caster:GetIntellect(false) * (int_damage / 100)
	end
    return damage
end


function mjz_lion_impale:RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end



--------------------------------------------------------------------------------
--[[
modifier_mjz_lion_impale_slow = class({})

function modifier_mjz_lion_impale_slow:IsHidden()
	return true
end

function modifier_mjz_lion_impale_slow:IsDebuff()
	return true
end

function modifier_mjz_lion_impale_slow:IsPurgable()
	return true
end

function modifier_mjz_lion_impale_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_mjz_lion_impale_slow:GetModifierMoveSpeedBonus_Percentage(keys)
	return self:GetAbility():GetSpecialValueFor("movement_slow")
end
]]