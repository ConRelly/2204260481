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
modifier_ogre_magi_multicast_lua_self_cast_proc = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ogre_magi_multicast_lua_self_cast_proc:IsHidden()
	return false
end

function modifier_ogre_magi_multicast_lua_self_cast_proc:IsDebuff()
	return false
end

function modifier_ogre_magi_multicast_lua_self_cast_proc:IsStunDebuff()
	return false
end

function modifier_ogre_magi_multicast_lua_self_cast_proc:IsPurgable()
	return true
end

function modifier_ogre_magi_multicast_lua_self_cast_proc:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ogre_magi_multicast_lua_self_cast_proc:OnCreated( kv )
	if not IsServer() then return end
	-- load data
	self.caster = self:GetParent()
	self.ability = EntIndexToHScript( kv.ability )
	self.multicast = kv.multicast
	self.delay = kv.delay

	-- set stack count
	self:SetStackCount( self.multicast )

	-- init multicast
	self.casts = 0
	if self.multicast==1 then
		-- no multicast if just 1
		self:Destroy()
		return
	end

	-- play effects
	self:PlayEffects( self.casts )

	-- Start interval
	self:StartIntervalThink( self.delay )
end

function modifier_ogre_magi_multicast_lua_self_cast_proc:OnRefresh( kv )
	
end

function modifier_ogre_magi_multicast_lua_self_cast_proc:OnRemoved()
end

function modifier_ogre_magi_multicast_lua_self_cast_proc:OnDestroy()
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_ogre_magi_multicast_lua_self_cast_proc:OnIntervalThink()
	if self.ability:IsNull() then
		self:Destroy()
		return 
	end

	self.ability:OnSpellStart()

	-- increment count
	self.casts = self.casts + 1
	if self.casts>=(self.multicast-1) then
		self:StartIntervalThink( -1 )
		self:Destroy()
	end

	-- play effects
	self:PlayEffects( self.casts )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ogre_magi_multicast_lua_self_cast_proc:PlayEffects( value )
	value = value + 1

	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf"

	-- get data
	local counter_speed = 2
	if value==self.multicast then
		counter_speed = 1
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self.caster )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( value, counter_speed, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	local sound = math.min( value-1, 3 )
	local sound_cast = "Hero_OgreMagi.Fireblast.x" .. sound
	if sound>0 then
		EmitSoundOn( sound_cast, self.caster )
	end
end