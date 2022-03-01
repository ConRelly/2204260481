aghanim_shard_toss = class({})
LinkLuaModifier("modifier_aghanim_shard_hide", "aghanim/aghanim_shard_toss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_shard_proj", "aghanim/aghanim_shard_toss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_shard_toss_handler", "aghanim/aghanim_shard_toss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanim_shard_toss_stun", "aghanim/aghanim_shard_toss", LUA_MODIFIER_MOTION_NONE)

function aghanim_shard_toss:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_attack.vpcf", context )
    PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_shard_proj.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_wisp/wisp_tether_hit.vpcf", context )
    PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_attack_impact.vpcf", context )
    PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_shard_channel.vpcf", context )
    
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_silencer.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts", context )
    
    PrecacheResource( "model", "models/props_gameplay/aghanim_gem.vmdl", context )
end

function aghanim_shard_toss:GetAOERadius()
    return self:GetSpecialValueFor("trigger_radius")
end

function aghanim_shard_toss:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    self.point = self:GetCursorPosition()

    -- Cap the minimum travel distance
    local vDistance = self.point-caster:GetAbsOrigin()
    if vDistance:Length2D() < self:GetSpecialValueFor("min_range") then
        self.point = caster:GetAbsOrigin() + ( vDistance:Normalized() * self:GetSpecialValueFor("min_range") )
    end

    caster:AddNewModifier(caster, self, "modifier_aghanim_shard_toss_handler", { castX = self.point.x, castY = self.point.y, castZ = self.point.z })
end

function aghanim_shard_toss:GetPositions( cast_position )
    local caster = self:GetCaster()
    local caster_pos = caster:GetAbsOrigin()
    local point_table = { left_pos, cast_position, right_pos }

    -- not actually midpoint anymore, just a shrinking factor
    local midpoint = LerpVectors(caster_pos, cast_position, 0.8)

    -- Constrain the oDist between the points to the given range
    local oDist = (midpoint-caster_pos):Length2D()*0.6
    oDist = math.max( self:GetSpecialValueFor("min_width"), math.min(oDist, (self:GetSpecialValueFor("max_width") / 2)))

    -- Calculate the aDist and angle of the sub shards
    local aDist = (midpoint-caster_pos):Length2D()
    local swing_angle = ( math.atan( oDist / aDist ) ) * (180/math.pi) -- tan^-1 ( O/A )

    -- Get points either side of the sub shards for the talent
    local talent = caster:FindAbilityByName("special_bonus_unique_aghanim_5")
    if talent and talent:GetLevel() > 0 then
        swing_angle = swing_angle * 3/4

        local swing_vector = LerpVectors(caster_pos, cast_position, 0.7)
        point_table.pos1 = RotatePosition( caster_pos, QAngle( 0, swing_angle*2.5, 0 ), swing_vector )
        point_table.pos2 = RotatePosition( caster_pos, QAngle( 0, -swing_angle*2.5, 0 ), swing_vector )
    end

    -- Add the sub shard positions to the point table
    point_table.left_pos = RotatePosition( caster_pos, QAngle( 0, swing_angle, 0 ), midpoint )
    point_table.right_pos = RotatePosition( caster_pos, QAngle( 0, -swing_angle, 0 ), midpoint )

    return point_table
end

function aghanim_shard_toss:FireProjectile( origin, destination, identifier )

    local handlers = self:GetCaster():FindAllModifiersByName("modifier_aghanim_shard_toss_handler")
    local handler
    for _,mod in pairs(handlers) do
        if mod.identifier == identifier then
            handler = mod
            break
        end
    end
    if handler == nil then return end

    local distance = (origin-destination):Length2D()
    local speed = distance / handler.travel_time
    
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
	    fStartRadius = self:GetSpecialValueFor("trigger_radius"),
	    fEndRadius = self:GetSpecialValueFor("trigger_radius"),
		vVelocity = (destination-origin):Normalized() * speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        
        ExtraData = {
            identifier = identifier
        }
    }
    local handle = ProjectileManager:CreateLinearProjectile( info )
    info.ExtraData.handle = handle
    return info
end

function aghanim_shard_toss:FireCosmeticProjectile( origin, destination, identifier )

    local distance = (origin-destination):Length2D()
    local speed = distance / self:GetSpecialValueFor("init_time")

    local info = {
		Source = self:GetCaster(),
		Ability = self,
		vSpawnOrigin = origin,
	    bDeleteOnHit = false,
	    
	    fDistance = distance,
	    fStartRadius = 1,
	    fEndRadius = 1,
		vVelocity = (destination-origin):Normalized() * speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        
        ExtraData = {
            spawn = 1,
            cosmetic = 1,
            identifier = identifier
        }
    }

    -- Create unit and add them to the projectile info
    local unit = CreateUnitByName( 
        "npc_dota_aghanim_shard", 
        origin, 
        false, 
        self:GetCaster(), 
        self:GetCaster(), 
        self:GetCaster():GetTeamNumber()
    )
    unit:AddNewModifier(caster, self, "modifier_aghanim_shard_proj", {})
    info.ExtraData.ent = unit:entindex()

    -- Create the unit's attached particle
    local particle_width = 80
    info.ExtraData.particle = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_shard_proj.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControlEnt( 
        info.ExtraData.particle, 
        0, 
        unit, 
        PATTACH_ABSORIGIN_FOLLOW, 
        nil, 
        origin, 
        false 
    )
	ParticleManager:SetParticleControl( info.ExtraData.particle, 1, Vector( particle_width, particle_width, 0 ) )
	ParticleManager:SetParticleControl( info.ExtraData.particle, 2, Vector( 6, 6, 6 ) )

    info.pHandle = ProjectileManager:CreateLinearProjectile( info )
    return info
end

function aghanim_shard_toss:OnProjectileThinkHandle(iProjectileHandle)
    if not IsServer() then return end

    local info = nil
    for _,mod in pairs( self:GetCaster():FindAllModifiersByName("modifier_aghanim_shard_toss_handler") ) do
        for k,v in pairs ( mod.projectiles ) do
		    if v.pHandle == iProjectileHandle then
                info = v
			    break
		    end
        end
    end
	if info == nil then return end

    -- Update the entity's position to that of the projectile
    local current_pos
    if info.ExtraData.tracking then
        current_pos = ProjectileManager:GetTrackingProjectileLocation(iProjectileHandle)
    else
        current_pos = ProjectileManager:GetLinearProjectileLocation(iProjectileHandle)
    end

    if info.ExtraData.ent then
        EntIndexToHScript( info.ExtraData.ent ):SetOrigin(GetGroundPosition(current_pos, nil))
    end
end

function aghanim_shard_toss:OnProjectileHit_ExtraData( hTarget, vLocation, data )
    if not IsServer() then return end

    -- If its a setup or return projectile, delete it's particle entity and don't deal damage
    if data.cosmetic then
        if data.ent then
            ParticleManager:DestroyParticle(data.particle, true)
            EntIndexToHScript( data.ent ):ForceKill(false)
            UTIL_Remove( EntIndexToHScript( data.ent ) )
        end

        if data.spawn and data.spawn == 1 then
            self:SpawnCrystal( vLocation, data.identifier )
        end

        return true
    end

    if not hTarget or hTarget:IsHero() then
        self:Erupt( vLocation, data.handle )
        return true
    end

    -- Deal pass through / trigger damage
    local amp = self:GetCaster():GetSpellAmplification(false)
    local base = self:GetSpecialValueFor("pass_damage")

    local damageInfo = {
        victim = hTarget,
        attacker = self:GetCaster(),
        damage = (base * amp) + base,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }
    ApplyDamage( damageInfo )

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, vLocation)

    EmitSoundOn("Hero_DarkWillow.WillOWisp.Damage", hTarget)

    return false
end

function aghanim_shard_toss:SpawnCrystal( position, identifier )

    local handlers = self:GetCaster():FindAllModifiersByName("modifier_aghanim_shard_toss_handler")
    local handler
    for _,mod in pairs(handlers) do
        if mod.identifier == identifier then
            handler = mod
            break
        end
    end
    if handler == nil then return end
    
    local caster = self:GetCaster()
    crystal = CreateUnitByName(
        "npc_dota_aghanim_shard", 
        position, 
        false, 
        caster, 
        caster:GetOwner(), 
        caster:GetTeamNumber() 
    )
    EmitSoundOnLocationWithCaster(position, "Hero_KeeperOfTheLight.Wisp.Destroy", caster)
    crystal:AddNewModifier(caster, self, "modifier_aghanim_shard_hide", { handler = identifier })

    handler.crystal_pos[ crystal:entindex() ] = position

end

function aghanim_shard_toss:ReturnCrystals( identifier )
    if not IsServer() then return end

    local handlers = self:GetCaster():FindAllModifiersByName("modifier_aghanim_shard_toss_handler")
    local handler
    for _,mod in pairs(handlers) do
        if mod.identifier == identifier then
            handler = mod
            break
        end
    end
    if handler == nil then return end

    local caster = self:GetCaster()
    for entindex,position in pairs(handler.crystal_pos) do
        local crystal = EntIndexToHScript(entindex)

        if crystal and crystal:IsAlive() then
            table.insert(handler.projectiles, self:ReturnCrystalProjectile( crystal ))

            EmitSoundOnLocationWithCaster(position, "Hero_KeeperOfTheLight.Wisp.Destroy", caster)
            table.remove( handler.crystal_pos, entindex )
            crystal:ForceKill(false)
            UTIL_Remove(crystal)
        end
    end

    handler:StartIntervalThink(-1)
    handler:SetDuration(1.1, false)
end

function aghanim_shard_toss:ReturnCrystalProjectile( crystal )
    local caster = self:GetCaster()

    local distance = (caster:GetOrigin() - crystal:GetOrigin()):Length2D()

    local info = {
        Ability = self,
        Target = caster,
        Source = crystal,
        iMoveSpeed = distance / 0.5,
        vSourceLoc = crystal:GetAbsOrigin(),
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDodgeable = false,

        ExtraData = {
            tracking = 1,
            cosmetic = 1
        }
    }

    -- Create attachment entity
    local unit = CreateUnitByName(
        "npc_dota_aghanim_shard", 
        crystal:GetOrigin(), 
        false, 
        caster, 
        caster, 
        caster:GetTeamNumber()
    )
    unit:AddNewModifier(caster, self, "modifier_aghanim_shard_proj", {})
    info.ExtraData.ent = unit:entindex()

    -- Create the unit's attached particle
    local particle_width = 80
    info.ExtraData.particle = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_shard_proj.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControlEnt( 
        info.ExtraData.particle, 
        0, 
        unit, 
        PATTACH_ABSORIGIN_FOLLOW, 
        nil, 
        crystal:GetOrigin(), 
        false 
    )
	ParticleManager:SetParticleControl( info.ExtraData.particle, 1, Vector( particle_width, particle_width, 0 ) )
    ParticleManager:SetParticleControl( info.ExtraData.particle, 2, Vector( 6, 6, 6 ) )

    info.pHandle = ProjectileManager:CreateTrackingProjectile(info)
    return info
end

function aghanim_shard_toss:Erupt( position, iProjectileHandle )
    if iProjectileHandle then 
        ProjectileManager:DestroyLinearProjectile(iProjectileHandle)
    end

    local caster = self:GetCaster()
    local amp = caster:GetSpellAmplification(false)
    local base = self:GetSpecialValueFor("proc_damage")

    local damageInfo = {
        attacker = caster,
        damage = (base * amp) + base,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }

    local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		position,
		nil,
		self:GetSpecialValueFor("erupt_radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		0,
		false
	)

    for _,target in pairs(enemies) do
        damageInfo.victim = target
        ApplyDamage( damageInfo )

        target:AddNewModifier(caster, self, "modifier_aghanim_shard_toss_stun", {duration = self:GetSpecialValueFor("stun_duration")})
    end

    local particle = ParticleManager:CreateParticle("particles/creatures/aghanim/aghanim_crystal_attack_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, position)

    EmitSoundOnLocationWithCaster(position, "Hero_Silencer.LastWord.Damage", self:GetCaster() )

    return true
end

function aghanim_shard_toss:ShardTrigger( position )
    local caster = self:GetCaster()
    local amp = caster:GetSpellAmplification(false)
    local base = self:GetSpecialValueFor("shard_bonus_damage") + self:GetSpecialValueFor("proc_damage")

    local damageInfo = {
        attacker = caster,
        damage = (base * amp) + base,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }

    local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		position,
		nil,
		self:GetSpecialValueFor("shard_erupt_radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		0,
		false
	)

    for _,target in pairs(enemies) do
        damageInfo.victim = target
        ApplyDamage( damageInfo )

        target:AddNewModifier(caster, self, "modifier_aghanim_shard_toss_stun", {duration = self:GetSpecialValueFor("stun_duration")*2})
    end

    local particle = ParticleManager:CreateParticle("particles/creatures/aghanim/aghanim_crystal_attack_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, position)

    EmitSoundOnLocationWithCaster(position, "Hero_Silencer.LastWord.Damage", self:GetCaster() )

    return true
end

--=================================================================================================

modifier_aghanim_shard_toss_handler = class({})
function modifier_aghanim_shard_toss_handler:IsHidden() return true end
function modifier_aghanim_shard_toss_handler:IsPermanent() return true end
function modifier_aghanim_shard_toss_handler:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_aghanim_shard_toss_handler:GetEffectName() return "particles/creatures/aghanim/aghanim_shard_channel.vpcf" end
function modifier_aghanim_shard_toss_handler:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_aghanim_shard_toss_handler:OnCreated(kv)
    if not IsServer() then return end

    self.projectiles = {}
    self.crystal_pos = {}
    self.identifier = DoUniqueString("pp_big")
    self.cast_position = Vector(kv.castX, kv.castY, kv.castZ)
    self.finished = false
    self.parent = self:GetParent()

    self.pulses = 0
    self.max_pulses = self:GetAbility():GetSpecialValueFor("pulses")

    self.phase_delay = self:GetAbility():GetSpecialValueFor("phase_delay")
    self.travel_time = self:GetAbility():GetSpecialValueFor("travel_time")

    -- Talent stuff
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_aghanim_6")
    if talent and talent:GetLevel() > 0 then
        self.max_pulses = self.max_pulses + talent:GetSpecialValueFor("bonus_pulses")
        self.phase_delay = self.phase_delay * talent:GetSpecialValueFor("timer_reduction")
        self.travel_time = self.travel_time * talent:GetSpecialValueFor("timer_reduction")
    end

    self:MakeCosmeticProjectileDo()
end

function modifier_aghanim_shard_toss_handler:OnIntervalThink()
    local ability = self:GetAbility()

    if self.finished then
        ability:ReturnCrystals( self.identifier )
        self:StartIntervalThink(-1)
        return
    end

    -- Check if the caster is too far away
    local max_range = ability:GetSpecialValueFor("max_range") + ability:GetCastRange(self.cast_position, nil) + self.parent:GetCastRangeBonus()
    if (self.parent:GetAbsOrigin()-self.cast_position):Length2D() > max_range then
        ability:ReturnCrystals( self.identifier )
        return
    end

    local all_dead = true
    for entindex,_ in pairs(self.crystal_pos) do
        if EntIndexToHScript(entindex):IsAlive() then
            all_dead = false
            break
        end
    end
    if all_dead then 
        self:SetDuration(1.5, false)
        self:StartIntervalThink(-1)
    end

    -- Count the pulses, and update the return timer if needed
    local interval = 0.1
    if self.pulses < self.max_pulses then
        self.pulses = self.pulses + 1

        self:MakeProjectileDo()
        interval = self.phase_delay
    end

    if self.pulses >= self.max_pulses then
        self.finished = true
        interval = self.travel_time + self.phase_delay
    end

    self:StartIntervalThink(interval)
end

function modifier_aghanim_shard_toss_handler:MakeProjectileDo()
    if not IsServer() then return end

    for _,point in pairs(self.crystal_pos) do
        self:GetAbility():FireProjectile( self.parent:GetOrigin(), point, self.identifier )
    end

    EmitSoundOn("Hero_Wisp.Tether.Stun", self.parent)
end

function modifier_aghanim_shard_toss_handler:MakeCosmeticProjectileDo()
    if not IsServer() then return end

    local ability = self:GetAbility()
    local positions = ability:GetPositions( self.cast_position )
    for _,point in pairs(positions) do
        table.insert(
            self.projectiles,
            ability:FireCosmeticProjectile( GetGroundPosition(self.parent:GetAbsOrigin(),nil) , point, self.identifier )
        )
    end

    self:StartIntervalThink( ability:GetSpecialValueFor("init_time") + ability:GetSpecialValueFor("phase_delay") )
end

function modifier_aghanim_shard_toss_handler:DeclareFunctions() 
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_DEATH } 
end

function modifier_aghanim_shard_toss_handler:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_aghanim_shard_toss_handler:OnDeath(keys)
    if not IsServer() then return end
    if keys.unit == self:GetParent() then
        self:GetAbility():ReturnCrystals( self.identifier )
    end
end

--=================================================================================================

modifier_aghanim_shard_hide = class({})
function modifier_aghanim_shard_hide:GetEffectName() return "particles/creatures/aghanim/aghanim_shard_proj.vpcf" end
function modifier_aghanim_shard_hide:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING] = true
	}
end

function modifier_aghanim_shard_hide:OnCreated(kv)
    if not IsServer() then return end

    local handlers = self:GetCaster():FindAllModifiersByName("modifier_aghanim_shard_toss_handler")
    self.handler = nil
    for _,mod in pairs(handlers) do
        if mod.identifier == kv.handler then
            self.handler = mod
            break
        end
    end
    if self.handler == nil then
        if self:IsNull() then return end
        self:Destroy()
        return 
    end

    EmitSoundOn( "Hero_Dark_Seer.Wall_of_Replica_lp", self:GetParent() )

    self:StartIntervalThink(0.1)
end

function modifier_aghanim_shard_hide:OnIntervalThink()

    local targets = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		self:GetAbility():GetSpecialValueFor("trigger_radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		0,
		false
    )
    
    if targets and #targets > 0 then
        self:GetAbility():ShardTrigger( self:GetParent():GetAbsOrigin(), nil )

        self.handler.crystal_pos[ self:GetParent():entindex() ] = nil
        self:GetParent():ForceKill(false)
        UTIL_Remove(self:GetParent())
    end
end

function modifier_aghanim_shard_hide:OnDestroy()
    if IsServer() then 
        StopSoundOn( "Hero_Dark_Seer.Wall_of_Replica_lp", self:GetParent() )
    end
end

--=================================================================================================

modifier_aghanim_shard_proj = class({})
function modifier_aghanim_shard_proj:OnCreated()
    if IsServer() then
        EmitSoundOn( "Hero_Dark_Seer.Wall_of_Replica_lp", self:GetParent() )
    end
end
function modifier_aghanim_shard_proj:OnDestroy()
    if IsServer() then 
        StopSoundOn( "Hero_Dark_Seer.Wall_of_Replica_lp", self:GetParent() )
    end
end
function modifier_aghanim_shard_proj:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end


--=================================================================================================

modifier_aghanim_shard_toss_stun = class({})
function modifier_aghanim_shard_toss_stun:IsPurgable() return true end
function modifier_aghanim_shard_toss_stun:IsDebuff() return true end
function modifier_aghanim_shard_toss_stun:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_aghanim_shard_toss_stun:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_aghanim_shard_toss_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end

function modifier_aghanim_shard_toss_stun:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION, 
    }
end

function modifier_aghanim_shard_toss_stun:GetOverrideAnimation() return ACT_DOTA_DISABLED end