sand_king_burrowstrike_lua = class({})
LinkLuaModifier( "modifier_sand_king_burrowstrike_lua", "lua_abilities/sand_king_burrowstrike_lua/modifier_sand_king_burrowstrike_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "lua_abilities/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_knockback_lua", "lua_abilities/generic/modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )

--------------------------------------------------------------------------------
-- Custom KV
function sand_king_burrowstrike_lua:GetCastRange( vLocation, hTarget )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "cast_range_scepter" )
	end

	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

--------------------------------------------------------------------------------
-- Ability Start
function sand_king_burrowstrike_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()
	if target then point = target:GetOrigin() end
	local origin = caster:GetOrigin()

	-- load data
	local anim_time = self:GetSpecialValueFor("burrow_anim_time")

	-- projectile data
	local projectile_name = "particles/units/heroes/hero_sandking/sandking_burrowstrike.vpcf"
	local projectile_start_radius = self:GetSpecialValueFor("burrow_width")
	local projectile_end_radius = projectile_start_radius
	local projectile_direction = (point-origin)
	projectile_direction.z = 0
	projectile_direction:Normalized()
	local projectile_speed = self:GetSpecialValueFor("burrow_speed")
	if self:GetCaster():HasScepter() then
		projectile_speed = self:GetSpecialValueFor( "burrow_speed_scepter" )
	end
	local projectile_distance = (point-origin):Length2D()

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_start_radius,
	    fEndRadius =projectile_end_radius,
		vVelocity = projectile_direction * projectile_speed,
	}
	ProjectileManager:CreateLinearProjectile(info)

	-- add modifier to caster
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_sand_king_burrowstrike_lua", -- modifier name
		{ 
			duration = anim_time,
			pos_x = point.x,
			pos_y = point.y,
			pos_z = point.z,
		} -- kv
	)

	self:PlayEffects( origin, point )
end
--------------------------------------------------------------------------------
-- Projectile
function sand_king_burrowstrike_lua:OnProjectileHit( target, location )
	if not target then return end

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	local caster = self:GetCaster()

	-- apply stun
	local duration = self:GetSpecialValueFor( "burrow_duration" )
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = duration } -- kv
	)

	-- apply knockback
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_knockback_lua", -- modifier name
		{
			duration = 0.52,
			height = 350,
			IsStun = true,
		} -- kv
	)
	if IsServer() then
		if caster:HasScepter() then
			if caster:HasAbility("sandking_caustic_finale") and caster:FindAbilityByName("sandking_caustic_finale"):IsTrained() then
				local Caustic = caster:FindAbilityByName("sandking_caustic_finale")

				local radius = Caustic:GetTalentSpecialValueFor("caustic_finale_radius")
				local damage_base = Caustic:GetTalentSpecialValueFor("caustic_finale_damage_base")
				local damage_pct = Caustic:GetTalentSpecialValueFor("caustic_finale_damage_pct")
				local duration = Caustic:GetTalentSpecialValueFor("caustic_finale_duration")
				local slow = Caustic:GetTalentSpecialValueFor("caustic_finale_slow")

				target:AddNewModifier(caster, Caustic, "modifier_sand_king_caustic_finale_orb", {caustic_finale_radius = radius, caustic_finale_damage_base = damage_base, caustic_finale_damage_pct = damage_pct, caustic_finale_slow = slow, duration = duration})
			end
		end
	end

	-- apply damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetAbilityDamage() + (caster:GetStrength() * self:GetTalentSpecialValueFor("str_multiplier")),
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)
end

--------------------------------------------------------------------------------
function sand_king_burrowstrike_lua:PlayEffects( origin, target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_sandking/sandking_burrowstrike.vpcf"
	local sound_cast = "Ability.SandKing_BurrowStrike"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, origin )
	ParticleManager:SetParticleControl( effect_cast, 1, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end


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