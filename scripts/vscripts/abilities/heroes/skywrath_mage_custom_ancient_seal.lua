require("lib/my")
skywrath_mage_custom_ancient_seal = class({})

-- function skywrath_mage_custom_ancient_seal:GetCooldown(iLevel)
-- 	local caster = self:GetCaster()
-- 	-- if caster:HasAbility("special_bonus_unique_skywrath") then
-- 	-- 	local talent = caster:FindAbilityByName("special_bonus_unique_skywrath")
-- 	-- 	if talent and talent:GetLevel() > 0 then
-- 	-- 		return (self.BaseClass.GetCooldown(self, iLevel) - talent:GetSpecialValueFor("value"))
-- 	-- 	end
-- 	-- end
-- 	-- return self.BaseClass.GetCooldown(self, iLevel)
-- end

--------------------------------------------------------------------------------
-- Ability Start
function skywrath_mage_custom_ancient_seal:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- load data
	local duration = self:GetSpecialValueFor( "seal_duration" )

	-- add debuff
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_skywrath_mage_custom_ancient_seal", -- modifier name
		{ duration = duration } -- kv
	)
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_skywrath_mage_custom_ancient_seal_silence", -- modifier name
		{ duration = duration/5 } -- kv
	)

	-- scepter effect
	if caster:HasScepter() then
		local scepter_radius = self:GetSpecialValueFor( "scepter_radius" )
		
		-- find nearby enemies
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			target:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			scepter_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local target_2 = nil
		-- prioritize hero
		for _,enemy in pairs(enemies) do
			if enemy~=target and enemy:IsHero() then
				target_2 = enemy
				break
			end
		end

		-- no secondary hero found, find creep
		if not target_2 then
			-- 'enemies' will only have at max 1 hero (others are creeps), which would be 'target'
			target_2 = enemies[1]		-- could be nil
			if target_2==target then
				target_2 = enemies[2]	-- could be nil
			end
		end

		if target_2 then
			-- add debuff
			target_2:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_skywrath_mage_custom_ancient_seal", -- modifier name
				{ duration = duration } -- kv
			)
			target_2:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_skywrath_mage_custom_ancient_seal_silence", -- modifier name
				{ duration = duration/5 } -- kv
			)			
		end
	
	end
end

LinkLuaModifier( "modifier_skywrath_mage_custom_ancient_seal", "abilities/heroes/skywrath_mage_custom_ancient_seal.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_skywrath_mage_custom_ancient_seal_silence", "abilities/heroes/skywrath_mage_custom_ancient_seal.lua", LUA_MODIFIER_MOTION_NONE )
modifier_skywrath_mage_custom_ancient_seal = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_skywrath_mage_custom_ancient_seal:IsHidden()
	return false
end

function modifier_skywrath_mage_custom_ancient_seal:IsDebuff()
	return true
end

function modifier_skywrath_mage_custom_ancient_seal:IsStunDebuff()
	return false
end

function modifier_skywrath_mage_custom_ancient_seal:IsPurgable()
	return false
end

modifier_skywrath_mage_custom_ancient_seal_silence = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_skywrath_mage_custom_ancient_seal_silence:IsHidden()
	return false
end

function modifier_skywrath_mage_custom_ancient_seal_silence:IsDebuff()
	return true
end

function modifier_skywrath_mage_custom_ancient_seal_silence:IsStunDebuff()
	return false
end

function modifier_skywrath_mage_custom_ancient_seal_silence:IsPurgable()
	return true
end
function modifier_skywrath_mage_custom_ancient_seal_silence:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end
function modifier_skywrath_mage_custom_ancient_seal_silence:OnCreated( kv )

	-- play effect
	self:PlayEffects()
	
end


--if IsServer() then
--------------------------------------------------------------------------------
-- Initializations
	function modifier_skywrath_mage_custom_ancient_seal:OnCreated( kv )
		-- references
		if self:GetAbility() then
			self.magic_resist = self:GetAbility():GetSpecialValueFor( "resist_debuff" ) + talent_value(self:GetCaster(), "special_bonus_unique_skywrath_3")

		end
	end

	function modifier_skywrath_mage_custom_ancient_seal:OnRefresh( kv )
		-- references
		if self:GetAbility() then
			self.magic_resist = self:GetAbility():GetSpecialValueFor( "resist_debuff" ) + talent_value(self:GetCaster(), "special_bonus_unique_skywrath_3")

			-- play effect
			local sound_cast = "Hero_SkywrathMage.AncientSeal.Target"
			EmitSoundOn( sound_cast, self:GetParent() )
		end
	end

	function modifier_skywrath_mage_custom_ancient_seal:OnRemoved()
	end

	function modifier_skywrath_mage_custom_ancient_seal:OnDestroy()
	end

	--------------------------------------------------------------------------------
	-- Modifier Effects
	function modifier_skywrath_mage_custom_ancient_seal:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		}

		return funcs
	end

	function modifier_skywrath_mage_custom_ancient_seal:GetModifierMagicalResistanceBonus()
		if self:GetAbility() then
			return self.magic_resist
		end
	end
--end
--------------------------------------------------------------------------------
-- Status Effects
--[[ function modifier_skywrath_mage_custom_ancient_seal:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end
 ]]
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_skywrath_mage_custom_ancient_seal_silence:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff.vpcf"
	local sound_cast = "Hero_SkywrathMage.AncientSeal.Target"

	local parent = self:GetParent()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, parent )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		parent,
		PATTACH_OVERHEAD_FOLLOW,
		"",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, parent )
end