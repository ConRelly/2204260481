-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
ogre_magi_unrefined_fireblast_lua = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "lua_abilities/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
function ogre_magi_unrefined_fireblast_lua:GetManaCost( level )
	local pct = self:GetSpecialValueFor( "scepter_mana" )

	return math.floor( self:GetCaster():GetMana() * pct )
end
function ogre_magi_unrefined_fireblast_lua:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end
  
--------------------------------------------------------------------------------
-- Ability Start
function ogre_magi_unrefined_fireblast_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if linken
	if not target then return end
	if target:IsNull() then return end
	if target:GetTeamNumber() == caster:GetTeamNumber() then return end
	if target:TriggerSpellAbsorb( self ) then
		return
	end

	-- load data
	local stats = caster:GetIntellect(true) + caster:GetAgility() + caster:GetStrength()
	local duration = self:GetSpecialValueFor( "stun_duration" )
	local damage = self:GetSpecialValueFor( "fireblast_damage" ) + stats * self:GetSpecialValueFor( "stats_multiplier" ) + (self:GetCaster():GetMana() * self:GetSpecialValueFor( "mana_bonus_dmg" ))

	-- Apply damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage( damageTable )

	-- stun
	target:AddNewModifier(
		self:GetCaster(),
		self, 
		"modifier_generic_stunned_lua", 
		{duration = duration}
	)

	-- play effects
	self:PlayEffects( target )
end

--------------------------------------------------------------------------------
function ogre_magi_unrefined_fireblast_lua:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_unr_fireblast.vpcf"
	local sound_cast = "Hero_OgreMagi.Fireblast.Cast"
	local sound_target = "Hero_OgreMagi.Fireblast.Target"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_target, target )
end