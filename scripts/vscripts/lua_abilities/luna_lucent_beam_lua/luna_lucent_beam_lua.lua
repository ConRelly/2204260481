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
luna_lucent_beam_lua = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "lua_abilities/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Phase Start
function luna_lucent_beam_lua:OnAbilityPhaseInterrupted()

end

function luna_lucent_beam_lua:OnAbilityPhaseStart()
	-- play effects
	self:PlayEffects1()
	return true -- if success
end

--------------------------------------------------------------------------------
-- AOE Radius
function luna_lucent_beam_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
if IsServer() then
	function luna_lucent_beam_lua:OnSpellStart()
		-- unit identifier
		
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local sound_cast = "Hero_Luna.LucentBeam.Cast"
		local sound_target = "Hero_Luna.LucentBeam.Target"	
		local modifier_buffa = "modifier_mjz_luna_under_the_moonlight_buff"
		local mbuf = caster:FindModifierByName(modifier_buffa)	

		-- cancel if linken
		if target:TriggerSpellAbsorb( self ) then return end

		-- load data
		local duration = self:GetSpecialValueFor("stun_duration")
		local damage = self:GetTalentSpecialValueFor("beam_damage") + (caster:GetAgility() * self:GetTalentSpecialValueFor("agi_multiplier"))
	
		-- damage
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self, --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}

		local search = self:GetSpecialValueFor( "radius" )
		targets = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			target:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			search,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(targets) do
			damageTable.victim = enemy
			ApplyDamage(damageTable)

			-- stun
			enemy:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_generic_stunned_lua", -- modifier name
				{ duration = duration } -- kv
			)
			local random_nr = math.random(100)
			if random_nr < 35 then
				if mbuf ~= nil then
					mbuf:SetStackCount( mbuf:GetStackCount() + 1 )
				end
			end	 
			-- effects
			self:PlayEffects2( enemy )
		end
		EmitSoundOn( sound_cast, self:GetCaster() )
		EmitSoundOn( sound_target, target )
	end
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function luna_lucent_beam_lua:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_luna/luna_lucent_beam_precast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(0.4,0,0) )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- ParticleManager:SetParticleControlEnt(
	-- 	effect_cast,
	-- 	2,
	-- 	self:GetCaster(),
	-- 	PATTACH_POINT_FOLLOW,
	-- 	"attach_attack1",
	-- 	Vector(0,0,0), -- unknown
	-- 	true -- unknown, true
	-- )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	--EmitSoundOn( sound_cast, self:GetCaster() )
end

function luna_lucent_beam_lua:PlayEffects2( target )
	local particle_cast = "particles/econ/items/luna/luna_lucent_ti5_gold/luna_lucent_beam_moonfall_gold.vpcf" --"particles/units/heroes/hero_luna/luna_lucent_beam.vpcf"
	local sound_cast = "Hero_Luna.LucentBeam.Cast"
	local sound_target = "Hero_Luna.LucentBeam.Target"

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		5,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		6,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	--EmitSoundOn( sound_cast, self:GetCaster() )
	--EmitSoundOn( sound_target, target )
end

--talents
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or 'value'
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end