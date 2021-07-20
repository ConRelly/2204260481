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
LinkLuaModifier("modifier_generic_stunned_lua", "lua_abilities/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

function luna_lucent_beam_lua:OnAbilityPhaseStart()
	self:PlayEffects1()
	return true
end

function luna_lucent_beam_lua:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function luna_lucent_beam_lua:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		local cooldown = self.BaseClass.GetManaCost(self, level) - 50
		return cooldown
	end
	return self.BaseClass.GetManaCost(self, level)
end

function luna_lucent_beam_lua:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
end

--------------------------------------------------------------------------------

if IsServer() then
	function luna_lucent_beam_lua:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local position = self:GetCursorPosition()
		local modifier_buffa = "modifier_mjz_luna_under_the_moonlight_buff"
		local mbuf = caster:FindModifierByName(modifier_buffa)
		local duration = self:GetSpecialValueFor("stun_duration")
		local damage = self:GetTalentSpecialValueFor("beam_damage") + (caster:GetAgility() * self:GetTalentSpecialValueFor("agi_multiplier"))
		local search = self:GetSpecialValueFor("radius")
		local new_moon_chance = self:GetSpecialValueFor("new_moon_chance")

		-- cancel if linken
		if not caster:HasShard() and target:TriggerSpellAbsorb(self) then return end

		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if caster:HasShard() then
			point = position
			sound_point = position
			AddFOWViewer(self:GetCaster():GetTeamNumber(), position, self:GetSpecialValueFor("radius"), 1, false)
		else
			point = target:GetOrigin()
			sound_point = target
		end

		targets = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, search, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false)

		for _,enemy in pairs(targets) do
			damageTable.victim = enemy
			ApplyDamage(damageTable)

			enemy:AddNewModifier(
				caster,
				self,
				"modifier_generic_stunned_lua",
				{duration = duration}
			)
			local random_nr = math.random(100)
			if random_nr < new_moon_chance then
				if mbuf ~= nil then
					mbuf:SetStackCount(mbuf:GetStackCount() + 1)
				end
			end
			self:PlayEffects2(enemy)
		end
		EmitSoundOn("Hero_Luna.LucentBeam.Cast", caster)
		if caster:HasShard() then
			local enemy_count = 0
			targets = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
			for _,enemy in pairs(targets) do
				enemy_count = enemy_count + 1
				caster:PerformAttack(enemy, true, true, true, false, true, false, false)
				if enemy_count >= (#targets / 2) then
					break
				end
			end
			EmitSoundOnLocationWithCaster(position, "Hero_Luna.LucentBeam.Target", caster)
		else
			EmitSoundOn("Hero_Luna.LucentBeam.Target", target)
		end
	end
end

--------------------------------------------------------------------------------

function luna_lucent_beam_lua:PlayEffects1()
	local particle_cast = "particles/units/heroes/hero_luna/luna_lucent_beam_precast.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(0.4,0,0))
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function luna_lucent_beam_lua:PlayEffects2(target)
	local particle_cast = "particles/econ/items/luna/luna_lucent_ti5_gold/luna_lucent_beam_moonfall_gold.vpcf"

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
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
	ParticleManager:ReleaseParticleIndex(effect_cast)
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
	for k,v in pairs(kv) do
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