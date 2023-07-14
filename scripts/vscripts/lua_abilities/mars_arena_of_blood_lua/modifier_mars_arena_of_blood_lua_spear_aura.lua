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
LinkLuaModifier( "modifier_mars_arena_of_blood_lua_knockback_cd", "lua_abilities/mars_arena_of_blood_lua/modifier_mars_arena_of_blood_lua_spear_aura", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
modifier_mars_arena_of_blood_lua_spear_aura = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mars_arena_of_blood_lua_spear_aura:IsHidden()
	return true
end

function modifier_mars_arena_of_blood_lua_spear_aura:IsDebuff()
	return true
end

function modifier_mars_arena_of_blood_lua_spear_aura:IsPurgable()
	return false
end

modifier_mars_arena_of_blood_lua_knockback_cd = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mars_arena_of_blood_lua_knockback_cd:IsHidden()
	return true
end

function modifier_mars_arena_of_blood_lua_knockback_cd:IsDebuff()
	return true
end

function modifier_mars_arena_of_blood_lua_knockback_cd:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_mars_arena_of_blood_lua_spear_aura:OnCreated( kv )
	-- references
	if self:GetAbility() == nil then return end
	local caster = self:GetCaster()
	if caster == nil then return end
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.width = self:GetAbility():GetSpecialValueFor( "spear_distance_from_wall" )
	self.damage = self:GetAbility():GetSpecialValueFor( "spear_damage" ) + (self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multiplier"))
	self.challenge_mult = self:GetAbility():GetSpecialValueFor( "challenge_mult" ) / 100
	self.knockback_duration = 0.1
	self.parent = self:GetParent()
	self.spear_radius = self.radius-self.width
	local has_ss = caster:HasModifier("modifier_super_scepter")
	if has_ss then
		self.duration = self:GetAbility():GetSpecialValueFor( "ss_spear_attack_interval" )
	else
		self.duration = self:GetAbility():GetSpecialValueFor( "spear_attack_interval" )
	end	
	if _G._challenge_bosss and _G._challenge_bosss > 0 then
		self.damage = self.damage * (1 + _G._challenge_bosss * self.challenge_mult)
		print("challenge boss tier: " .._G._challenge_bosss)
	end	
	print("mars dmg: ".. self.damage)
	if not IsServer() then return end
	self.owner = kv.isProvidedByAura~=1
	self.aura_origin = self:GetParent():GetOrigin()

	if not self.owner then
		self.aura_origin = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )
		local direction = self.aura_origin-self:GetParent():GetOrigin()
		direction.z = 0
		
		-- damage
		local damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}
		ApplyDamage(damageTable)
		local back_duration = 4
		if has_ss then
			caster:PerformAttack(self:GetParent(), true, true, true, false, false, false, true)
			back_duration = 2
		end	
		-- animate soldiers
		local arena_walls = Entities:FindAllByClassnameWithin( "npc_dota_phantomassassin_gravestone", self.parent:GetOrigin(), 680 )
		for _,arena_wall in pairs(arena_walls) do
			if arena_wall:HasModifier( "modifier_mars_arena_of_blood_lua_blocker" ) and arena_wall.model then
				arena_wall:FadeGesture( ACT_DOTA_ATTACK )
				arena_wall:StartGesture( ACT_DOTA_ATTACK )
				break
			end
		end

		-- play effects
		self:PlayEffects( direction:Normalized() )

		-- knockback if not having spear buff or CD limiter
		if self:GetParent():HasModifier( "modifier_mars_spear_of_mars_lua" ) then return end
		if self:GetParent():HasModifier( "modifier_mars_spear_of_mars_lua_debuff" ) then return end
		if self:GetParent():HasModifier( "modifier_mars_arena_of_blood_lua_knockback_cd" ) then return end
		self:GetParent():AddNewModifier(
			self:GetCaster(), -- player source
			self:GetAbility(), -- ability source
			"modifier_generic_knockback_lua", -- modifier name
			{
				duration = self.knockback_duration,
				distance = 400,
				height = 30,
				direction_x = direction.x,
				direction_y = direction.y,
			} -- kv
		)
		self:GetParent():AddNewModifier(caster, self:GetAbility(), "modifier_mars_arena_of_blood_lua_knockback_cd", {duration = back_duration})
	end
end

function modifier_mars_arena_of_blood_lua_spear_aura:OnRefresh( kv )
	--self:OnCreated()
end

function modifier_mars_arena_of_blood_lua_spear_aura:OnRemoved()
end

function modifier_mars_arena_of_blood_lua_spear_aura:OnDestroy()
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_mars_arena_of_blood_lua_spear_aura:IsAura()
	return self.owner
end

function modifier_mars_arena_of_blood_lua_spear_aura:GetModifierAura()
	return "modifier_mars_arena_of_blood_lua_spear_aura"
end

function modifier_mars_arena_of_blood_lua_spear_aura:GetAuraRadius()
	return self.radius
end

function modifier_mars_arena_of_blood_lua_spear_aura:GetAuraDuration()
	return self.duration
end

function modifier_mars_arena_of_blood_lua_spear_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_mars_arena_of_blood_lua_spear_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_mars_arena_of_blood_lua_spear_aura:GetAuraSearchFlags()
	return 0
end
function modifier_mars_arena_of_blood_lua_spear_aura:GetAuraEntityReject( unit )
	if not IsServer() then return end

	-- check flying
	--if unit:HasFlyMovementCapability() then return true end

	-- check if already own this aura
	if unit:FindModifierByNameAndCaster( "modifier_mars_arena_of_blood_lua_spear_aura", self:GetCaster() ) then
		return true
	end

	-- check distance
	local distance = (unit:GetOrigin()-self.aura_origin):Length2D()
	if (distance-self.spear_radius)<0 then
		return true
	end

	return false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_mars_arena_of_blood_lua_spear_aura:PlayEffects( direction )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_mars/mars_arena_of_blood_spear.vpcf"
	local sound_cast = "Hero_Mars.Phalanx.Attack"
	local sound_target = "Hero_Mars.Phalanx.Target"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
	EmitSoundOn( sound_target, self:GetParent() )
end