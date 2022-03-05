LinkLuaModifier( "modifier_tinker_laser_lua", "lua_abilities/tinker_laser_lua/tinker_laser_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_silenced_lua", "lua_abilities/generic/modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE )

tinker_laser_lua = class({})

function tinker_laser_lua:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Tinker.LaserAnim", self:GetCaster())
	return true
end

function tinker_laser_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb(self) then return end

	local duration_hero = self:GetSpecialValueFor("duration_hero")
	local duration_creep = self:GetSpecialValueFor("duration_creep")
	local int_multiplier = self:GetSpecialValueFor("int_multiplier") + talent_value(caster, "special_laser_int_multiplier_lua")

	local damage = self:GetSpecialValueFor("laser_damage")
	if caster:IsRealHero() then
		damage = damage + (caster:GetIntellect() * int_multiplier)
	end	
	local silence_duration = talent_value(caster, "special_laser_silence_duration_lua")

	self.miss_rate = self:GetSpecialValueFor("miss_rate") + talent_value(caster, "special_laser_miss_rate_lua")

	local targets = {}
	table.insert(targets, target)
	if caster:HasScepter() then
		self:Refract(targets, 1)
	end

	local damage = {attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self}

	for _,enemy in pairs(targets) do
		damage.victim = enemy
		ApplyDamage(damage)

		local duration = duration_hero
		if enemy:IsCreep() then
			duration = duration_creep
		end
		enemy:AddNewModifier(caster, self, "modifier_tinker_laser_lua", {duration = duration})

		if silence_duration > 0 then
			enemy:AddNewModifier(caster, self, "modifier_generic_silenced_lua", {duration = silence_duration})
		end
	end

	self:PlayEffects(targets)
end

function tinker_laser_lua:Refract(targets, jumps)
	local scepter_range = self:GetSpecialValueFor("scepter_bounce_range")

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), targets[jumps]:GetOrigin(), nil, scepter_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)

	local next_target = nil
	for _,enemy in pairs(enemies) do
		local candidate = true
		for _,target in pairs(targets) do
			if enemy==target then
				candidate = false
				break
			end
		end
		if candidate then
			next_target = enemy
			break
		end
	end

	if next_target then
		table.insert( targets, next_target )
		self:Refract( targets, jumps+1 )
	end
end

--------------------------------------------------------------------------------
function tinker_laser_lua:PlayEffects(targets)
	local particle_cast = "particles/units/heroes/hero_tinker/tinker_laser.vpcf"
	local sound_cast = "Hero_Tinker.Laser"
	local sound_target = "Hero_Tinker.LaserImpact"

	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	local attach = "attach_attack1"
	if self:GetCaster():ScriptLookupAttachment("attach_attack2")~=0 then attach = "attach_attack2" end
	ParticleManager:SetParticleControlEnt(effect_cast, 9, self:GetCaster(), PATTACH_POINT_FOLLOW, attach, Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, targets[1], PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitSoundOn(sound_cast, self:GetCaster())
	EmitSoundOn(sound_target, targets[1])

	if #targets>1 then
		for i=2,#targets do
			local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(effect_cast, 9, targets[i-1], PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
			ParticleManager:SetParticleControlEnt(effect_cast, 1, targets[i], PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
			ParticleManager:ReleaseParticleIndex(effect_cast)

			EmitSoundOn(sound_target, targets[i])
		end
	end
end


modifier_tinker_laser_lua = class({})
function modifier_tinker_laser_lua:IsHidden() return false end
function modifier_tinker_laser_lua:IsDebuff() return true end
function modifier_tinker_laser_lua:IsStunDebuff() return false end
function modifier_tinker_laser_lua:IsPurgable() return true end
function modifier_tinker_laser_lua:OnCreated(kv)
	if IsServer() then
		self.miss_rate = self:GetAbility().miss_rate
--		self:SetStackCount(kv.miss_rate)
	end
end
function modifier_tinker_laser_lua:OnRefresh(kv)
    self:OnCreated(kv)
end
function modifier_tinker_laser_lua:DeclareFunctions()
    return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end
function modifier_tinker_laser_lua:GetModifierMiss_Percentage()
    return self.miss_rate--self:GetStackCount()
end

