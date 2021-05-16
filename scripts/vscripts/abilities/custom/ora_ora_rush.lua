

-----------------------------
--        UPHEAVAL         --
-----------------------------

jotaro_ora_ora_rush = class({})
LinkLuaModifier("modifier_jotaro_ora_ora_rush", "heroes/hero_jotaro/ora_ora_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jotaro_ora_ora_rush_debuff", "heroes/hero_jotaro/ora_ora_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jotaro_ora_ora_rush_buff", "heroes/hero_jotaro/ora_ora_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jotaro_ora_ora_rush_debuff_additive", "heroes/hero_jotaro/ora_ora_rush", LUA_MODIFIER_MOTION_NONE)


function jotaro_ora_ora_rush:GetChannelTime()
--	return self.BaseClass.GetChannelTime(self)
	return self:GetSpecialValueFor("duration")
end

function jotaro_ora_ora_rush:GetCastRange()
	local mult = 1
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_item_special_jotaro_upgrade") then
		mult = 10
	end	
	return self:GetSpecialValueFor("cast_range")*mult
end

function jotaro_ora_ora_rush:GetAOERadius()
	local mult = 1
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_item_special_jotaro_upgrade") then
		mult = 10
	end	
	return self:GetSpecialValueFor("radius")*mult
end

function jotaro_ora_ora_rush:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()
	local cast_response = "jotaro_ora_ora_rush"
	local sound_loop = "Hero_jotaro.Upheaval"
	local modifier_upheaval = "modifier_jotaro_ora_ora_rush"
	local modifier_duration = ability:GetSpecialValueFor("duration")

	-- Play cast response
	EmitSoundOn(cast_response, caster)

	-- Apply ModifierThinker on target location
	CreateModifierThinker(caster, ability, modifier_upheaval, {duration = modifier_duration}, target_point, caster:GetTeamNumber(), false)

	
end

function jotaro_ora_ora_rush:OnChannelFinish()
	local caster = self:GetCaster()
	local sound_loop = "jotaro_ora_ora_rush"
	local sound_end = "Hero_jotaro.Upheaval.Stop"

	-- Stop looping sound
	StopSoundOn(sound_loop, caster)

	-- Play stop sound instead
--	EmitSoundOn(sound_end, caster)

end

-- Upheaval modifier
modifier_jotaro_ora_ora_rush = class({})

function modifier_jotaro_ora_ora_rush:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.team = self.caster:GetTeamNumber()
	self.point = self.parent:GetAbsOrigin()
	self.particle_upheaval = "particles/units/heroes/hero_jotaro/jotaro_upheaval.vpcf"
	self.modifier_debuff = "modifier_jotaro_ora_ora_rush_debuff"
	self.modifier_additive = "modifier_jotaro_ora_ora_rush_debuff_additive"
	self.modifier_golem_buff = "modifier_jotaro_ora_ora_rush_buff"

	local mult = 1
	if self.caster:HasModifier("modifier_item_special_jotaro_upgrade") then
		mult = 5
	end	
	-- Ability specials
	self.radius = self.ability:GetSpecialValueFor("radius")
	local attack_per_second = self.caster:GetAttacksPerSecond()
	local aps_multiple = self.ability:GetSpecialValueFor("aps_multiple")
	self.tick_interval = 1/attack_per_second / aps_multiple/mult
	print(self.tick_interval)
	print(attack_per_second)

	if IsServer() then
		-- Add particle effects
--[[		
		self.particle_upheaval_fx = ParticleManager:CreateParticle(self.particle_upheaval, PATTACH_WORLDORIGIN, self.parent)
		ParticleManager:SetParticleControl(self.particle_upheaval_fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle_upheaval_fx, 1, Vector(self.radius, 1, 1))
		self:AddParticle(self.particle_upheaval_fx, false, false, -1, false, false)
]]
		-- Start thinking
		self:StartIntervalThink(self.tick_interval)
	end
end

function modifier_jotaro_ora_ora_rush:OnIntervalThink()
	if not self.caster:IsChanneling() then
		self:Destroy()
		return
	end

	-- Find all nearby enemies and apply the debuff
	local enemies = FindUnitsInRadius(self.team,
		self.point,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_ANY_ORDER,
		false)

	for _,enemy in pairs(enemies) do
		
		self:OraOraTarget(enemy)
	end

end

function modifier_jotaro_ora_ora_rush:OraOraTarget(target)
	local caster = self:GetCaster()
	EmitSoundOn("jotaro_counterattack", target)
--	if caster:HasTalent("special_bonus_unique_faceless_clock_stopper_1") and caster:HasModifier("modifier_faceless_clock_stopper_buff") then
--[[
				local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(nFX, 0, target:GetAbsOrigin() )
				ParticleManager:SetParticleControl(nFX, 1, target:GetAbsOrigin() )
				ParticleManager:SetParticleControl(nFX, 2, Vector(1,1,1) )
				ParticleManager:SetParticleControl(nFX, 4, target:GetAbsOrigin() )
				ParticleManager:SetParticleControl(nFX, 5, Vector(1,1,1) )
				ParticleManager:ReleaseParticleIndex(nFX)
		]]		
--		Timers:CreateTimer(0.2, function()
			caster:PerformAttack(target, false, false, true, true, false, false, true)
			self:GetAbility():Stun(target, 0.1, false)
--		end)
--		local clockstopper = caster:FindModifierByName("modifier_faceless_clock_stopper_buff")

--[[
	else
		ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash_hit.vpcf", PATTACH_POINT, target, {})
		self:Stun(target, self:GetTalentSpecialValueFor("duration"), false)
		self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
]]
end
