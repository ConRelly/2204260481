--------------------------------
--      ARCANE MASTERY       --
--------------------------------
ryze_arcane_mastery = class({})
LinkLuaModifier("modifier_arcane_mastery", "abilities/custom/ryze", LUA_MODIFIER_MOTION_NONE)

function ryze_arcane_mastery:GetIntrinsicModifierName()
    return "modifier_arcane_mastery"
end

modifier_arcane_mastery = class({})
function modifier_arcane_mastery:IsDebuff() return false end
function modifier_arcane_mastery:IsHidden() return true end
function modifier_arcane_mastery:IsPurgable() return false end
function modifier_arcane_mastery:IsPurgeException() return false end
function modifier_arcane_mastery:RemoveOnDeath() return false end

function modifier_arcane_mastery:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}

	return funcs
end
function modifier_arcane_mastery:GetModifierSpellAmplify_Percentage()
	local ability = self:GetAbility()
	if ability:GetLevel() > 0 then
		local mana = self:GetCaster():GetMaxMana()
		local multiplier = self:GetAbility():GetSpecialValueFor("mana_pct")
		local per_mana = self:GetAbility():GetSpecialValueFor("mana_per")
		local amp = (mana / per_mana) * multiplier
		if amp < 1 then
			amp = 1
		end	
		return amp
	end	
end

----------------------------
--      OVERLOAD       --
----------------------------
ryze_overload = class({})
LinkLuaModifier("modifier_ryze_rune", "abilities/custom/ryze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overload", "abilities/custom/ryze", LUA_MODIFIER_MOTION_NONE)

function ryze_overload:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end
function ryze_overload:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()
	local sound_cast = "Hero_StormSpirit.BallLightning"
	local width = ability:GetSpecialValueFor( "proj_width" )
	local speed = ability:GetSpecialValueFor( "proj_speed" )
	local range = ability:GetSpecialValueFor( "proj_range" )

	EmitSoundOn(sound_cast, caster)
	local direction = (target_point - caster:GetAbsOrigin()):Normalized() 
	local spawn_point = caster:GetAbsOrigin()
	
	local overload_proj = {
		Ability = ability,
		EffectName = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf",
		vSpawnOrigin = spawn_point,
		fDistance = range + caster:GetCastRangeBonus(),
		fStartRadius = width,
		fEndRadius = width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,                                                          
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,                           
		bDeleteOnHit = true,
		vVelocity = direction * speed * Vector(1, 1, 0),
		bProvidesVision = false,
		ExtraData = {split = false}
	}
	self.id = ProjectileManager:CreateLinearProjectile(overload_proj)
end

function ryze_overload:OnProjectileHit_ExtraData( target, location, extradata )
	if not target then return end
	
	local caster = self:GetCaster()
	local ult = caster:GetAbilityByIndex(5)
	local speed = self:GetSpecialValueFor( "proj_speed" )
	local radius = self:GetSpecialValueFor( "radius" )
	local flux_amp = self:GetSpecialValueFor("flux_damage")
	if ult:GetLevel() > 0 then
		flux_amp = ult:GetSpecialValueFor("overload_damage")
	end
	
	if caster:HasModifier("modifier_ryze_rune") then
		if caster:FindModifierByName("modifier_ryze_rune"):GetStackCount() == self:GetSpecialValueFor("max_runes") then
			caster:AddNewModifier(caster, self, "modifier_overload", {duration = self:GetSpecialValueFor("movespeed_duration")})
		end
	end
	caster:RemoveModifierByName("modifier_ryze_rune")
	
	-- load data
	local damage = self:GetSpecialValueFor( "damage" )
	local realdamage = damage
	local damageTable = {
		-- victim = target,
		attacker = caster,
		damage = realdamage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	
	if target:HasModifier("modifier_spell_flux") then
		realdamage = damage * ((flux_amp / 100) + 1)
		target:RemoveModifierByName("modifier_spell_flux")
		
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			target:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)
		for _,enemy in pairs(enemies) do
			if enemy:HasModifier("modifier_spell_flux") then
				damageTable.victim = enemy
				damageTable.damage = realdamage
				ApplyDamage(damageTable)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, realdamage, nil)
				EmitSoundOnLocationWithCaster( enemy:GetAbsOrigin(), "Hero_StormSpirit.StaticRemnantExplode", caster )
				enemy:RemoveModifierByName("modifier_spell_flux")
			end
		end
	end
	
	damageTable.victim = target
	damageTable.damage = realdamage
	ApplyDamage(damageTable)
	
	if caster:HasScepter() then
		caster:GetAbilityByIndex(2):Flux(target, target:GetOrigin())
	end
	EmitSoundOnLocationWithCaster( target:GetAbsOrigin(), "Hero_StormSpirit.StaticRemnantExplode", caster )
	
	return true
end

modifier_ryze_rune = class({})
function modifier_ryze_rune:IsHidden() return false end
function modifier_ryze_rune:IsDebuff() return false end
function modifier_ryze_rune:IsPurgable() return false end
function modifier_ryze_rune:GetTexture() return "ryze_rune" end

modifier_overload = class({})
function modifier_overload:IsDebuff() return false end
function modifier_overload:IsHidden() return false end
function modifier_overload:IsPurgable() return true end
function modifier_overload:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_dialatedebuf.vpcf" end
function modifier_overload:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW end
function modifier_overload:DeclareFunctions()
    local decFuns =
    {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return decFuns
end
function modifier_overload:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

----------------------------
--      RUNE PRISON       --
----------------------------
ryze_rune_prison = class({})
LinkLuaModifier("modifier_rune_prison", "abilities/custom/ryze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rune_prison_root", "abilities/custom/ryze", LUA_MODIFIER_MOTION_NONE)

function ryze_rune_prison:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end
function ryze_rune_prison:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local mana = caster:GetMaxMana()
	local mana_damage = self:GetSpecialValueFor("mana_damage")
	local realdamage = damage + (mana*mana_damage/100)
	local particle	=	"particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf"
	
	if target:TriggerSpellAbsorb( self ) then return end
	
	local overload = caster:GetAbilityByIndex(0)
	overload:EndCooldown()
	local rune = caster:AddNewModifier(caster, overload, "modifier_ryze_rune", {duration = overload:GetSpecialValueFor("rune_duration")})
	if rune:GetStackCount() < overload:GetSpecialValueFor("max_runes") then
		rune:IncrementStackCount()
	end
	
	local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_fx)
	
	local damageTable = {victim = target,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		attacker = caster,
		ability = self
	}
	if target:HasModifier("modifier_spell_flux") then
		target:AddNewModifier(caster, self, "modifier_rune_prison_root", {duration = duration * (1-target:GetStatusResistance())})
		target:RemoveModifierByName("modifier_spell_flux")
	else
		target:AddNewModifier(caster, self, "modifier_rune_prison", {duration = duration})
	end
	ApplyDamage(damageTable)
	
	if caster:HasScepter() then
		caster:GetAbilityByIndex(2):Flux(target, target:GetOrigin())
	end
	target:EmitSound("Hero_StormSpirit.ElectricVortex")
end

modifier_rune_prison = class({})
function modifier_rune_prison:IsDebuff() return true end
function modifier_rune_prison:IsHidden() return false end
function modifier_rune_prison:IsPurgable() return true end
function modifier_rune_prison:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_dialatedebuf.vpcf" end
function modifier_rune_prison:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW end
function modifier_rune_prison:DeclareFunctions()
    local decFuns =
    {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return decFuns
end
function modifier_rune_prison:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow") * (-1)
end

modifier_rune_prison_root = class({})
function modifier_rune_prison_root:IsDebuff() return true end
function modifier_rune_prison_root:IsHidden() return false end
function modifier_rune_prison_root:IsPurgable() return true end
function modifier_rune_prison_root:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_dialatedebuf.vpcf" end
function modifier_rune_prison_root:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW end
function modifier_rune_prison_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

----------------------------
--      SPELL FLUX       --
----------------------------
ryze_spell_flux = class({})
LinkLuaModifier("modifier_spell_flux", "abilities/custom/ryze", LUA_MODIFIER_MOTION_NONE)

function ryze_spell_flux:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end
function ryze_spell_flux:GetAOERadius()
	local radius = self:GetSpecialValueFor("radius")    
	return radius
end

function ryze_spell_flux:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	if target:HasModifier("modifier_spell_flux") then
		radius = self:GetSpecialValueFor("flux_radius")
	end
	
	if target:TriggerSpellAbsorb( self ) then return end
	
	local overload = caster:GetAbilityByIndex(0)
	overload:EndCooldown()
	local rune = caster:AddNewModifier(caster, overload, "modifier_ryze_rune", {duration = overload:GetSpecialValueFor("rune_duration")})
	if rune:GetStackCount() < overload:GetSpecialValueFor("max_runes") then
		rune:IncrementStackCount()
	end
	
	local damageTable = {victim = target,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		attacker = caster,
		ability = self
	}
	ApplyDamage(damageTable)
	
	self:Flux(nil, target:GetOrigin())
end

function ryze_spell_flux:Flux(notme, location)
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
		location,
		nil,
		self:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)
	
	local projectile = 
	{
		Target 				= nil,
		Source 				= caster,
		Ability 			= self,
		EffectName 			= "particles/units/heroes/hero_zuus/zuus_base_attack.vpcf",
		iMoveSpeed			= 2000,
		vSpawnOrigin 		= location,
		bDrawsOnMinimap 	= false,
		bDodgeable 			= false,
		bIsAttack 			= false,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		bProvidesVision 	= false,
	}
	for _,enemy in pairs(enemies) do
		if enemy ~= notme then
			projectile.Target = enemy
			ProjectileManager:CreateTrackingProjectile(projectile)
		end
	end
end

function ryze_spell_flux:OnProjectileHit(target, location)
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local mana = caster:GetMaxMana()
	local mana_damage = self:GetSpecialValueFor("mana_damage")
	local realdamage = damage + (mana*mana_damage/100)
	
	target:AddNewModifier(caster, self, "modifier_spell_flux", {duration = duration})
	target:EmitSound("Hero_StormSpirit.StaticRemnantPlant")
end

modifier_spell_flux = class({})
function modifier_spell_flux:IsDebuff() return true end
function modifier_spell_flux:IsHidden() return false end
function modifier_spell_flux:IsPurgable() return false end
function modifier_spell_flux:IsPurgeException() return true end
function modifier_spell_flux:GetEffectName()
	return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_buff.vpcf"
end
function modifier_spell_flux:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

----------------------------
--      REALM WARP       --
----------------------------
ryze_realm_warp = class({})
LinkLuaModifier("modifier_realm_warp", "abilities/custom/ryze", LUA_MODIFIER_MOTION_NONE)

function ryze_realm_warp:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end
function ryze_realm_warp:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local target = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("channel_duration")
	local radius = self:GetSpecialValueFor("radius")
	
	caster:AddNewModifier(caster, self, "modifier_realm_warp", {duration = duration})
	AddFOWViewer(caster:GetTeamNumber(), target, radius, duration, false)
end

modifier_realm_warp = class({})
function modifier_realm_warp:IsDebuff() return false end
function modifier_realm_warp:IsHidden() return true end
function modifier_realm_warp:IsPurgable() return false end
function modifier_realm_warp:IsPurgeException() return false end
function modifier_realm_warp:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local origin = caster:GetAbsOrigin()
	self.origin = origin
	local target = self:GetAbility():GetCursorPosition()
	self.target = target
	
	self:PlayEffects1( origin, false )
	self:PlayEffects1( target, true )
	
	self.direction = target - origin
end
function modifier_realm_warp:OnDestroy()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor("radius")
	local allies = FindUnitsInRadius(caster:GetTeamNumber(),
		self.origin,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)
	
	for _,ally in pairs(allies) do
		local allyorigin = ally:GetAbsOrigin()
		FindClearSpaceForUnit( ally, allyorigin + self.direction, true )
		self:PlayEffects2( allyorigin, self.direction, ally )
		ally:AddNewModifier( caster, ability, "modifier_invulnerable", {duration = ability:GetSpecialValueFor("phase_duration")})
		
		if caster:HasScepter() then
			caster:GetAbilityByIndex(2):Flux(nil, self.target)
		end
	end
end

function modifier_realm_warp:PlayEffects1( point, main )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate.vpcf"
	local sound_cast = "Hero_VoidSpirit.Dissimilate.Portals"

	-- adjustments
	local radius = self:GetAbility():GetSpecialValueFor("radius")

	-- Create Particle for this team
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 0, 1 ) )
	if main then
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
	end

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Play Sound
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )

	return effect_cast
end
function modifier_realm_warp:PlayEffects2( origin, direction, unit )
	-- Get Resources
	local particle_cast_a = "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf"
	local sound_cast_a = "Hero_Antimage.Blink_out"

	local particle_cast_b = "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf"
	local sound_cast_b = "Hero_Antimage.Blink_in"

	-- At original position
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN, unit )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	EmitSoundOnLocationWithCaster( origin, sound_cast_a, unit )

	-- At original position
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN_FOLLOW, unit )
	ParticleManager:SetParticleControl( effect_cast_b, 0, unit:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	EmitSoundOnLocationWithCaster( unit:GetOrigin(), sound_cast_b, unit )
end