LinkLuaModifier("modifier_phantom_reflex", "heroes/hero_phantom_assassin/phantom_reflex", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flash_double_attack", "heroes/hero_phantom_assassin/phantom_reflex", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_counter_slash_trigger", "heroes/hero_phantom_assassin/phantom_reflex", LUA_MODIFIER_MOTION_NONE)

phantom_reflex = phantom_reflex or class({})

function phantom_reflex:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return self.BaseClass.GetCooldown(self, level)
	end
	return 0
end
function phantom_reflex:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return self.BaseClass.GetManaCost(self, level)
	end
	return 0
end
function phantom_reflex:GetBehavior()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end
function phantom_reflex:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_counter_slash_trigger", {duration = self:GetSpecialValueFor("activity_duration")})
	
    local reflect = ParticleManager:CreateParticle("particles/custom/items/durandal/mana_shield_act_sphere.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(reflect, 0, self:GetCaster():GetOrigin())
	ParticleManager:ReleaseParticleIndex(reflect)
end
function phantom_reflex:GetIntrinsicModifierName() return "modifier_phantom_reflex" end

modifier_phantom_reflex = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	--RemoveOnDeath = function() return false end,
	IsDebuff = function() return false end
})


function modifier_phantom_reflex:OnCreated()
	if self:GetAbility() then
		local dodge_chance_pct = self:GetAbility():GetSpecialValueFor("dodge_chance_pct")	
		if IsServer() then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_faceless_void_backtrack", {dodge_chance_pct = dodge_chance_pct})
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_flash_double_attack", nil)
		end
	end	
end
function modifier_phantom_reflex:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_faceless_void_backtrack")
		self:GetParent():RemoveModifierByName("modifier_flash_double_attack")
	end
end

modifier_flash_double_attack = class({
	IsHidden = function() return true end,
	--RemoveOnDeath = function() return false end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
})

function modifier_flash_double_attack:OnAttackLanded(params)
	local roll = self:GetAbility():GetSpecialValueFor("double_attack_chance")
	if params.attacker == self:GetParent() and params.attacker:PassivesDisabled() == false and params.target:IsMagicImmune() == false and RollPercentage(roll) and IsServer() then
		self:GetCaster():PerformAttack(params.target, true, true, true, false, false, false, false)
		--EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", params.target)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle)
	end
end

phantom_reflex_boss = class(phantom_reflex)



--------------------------------------------------------------------------------
modifier_counter_slash_trigger = modifier_counter_slash_trigger or class({})
function modifier_counter_slash_trigger:IsHidden() return false end
function modifier_counter_slash_trigger:IsDebuff() return false end
function modifier_counter_slash_trigger:IsPurgable() return false end
function modifier_counter_slash_trigger:RemoveOnDeath() return false end
function modifier_counter_slash_trigger:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_PROPERTY_AVOID_DAMAGE, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE} end
function modifier_counter_slash_trigger:GetModifierAvoidDamage()
	return 1
end
function modifier_counter_slash_trigger:OnAttack(keys)
	if IsServer() then
		local attacker = keys.attacker
		local victim = keys.target
		local radius = self:GetAbility():GetSpecialValueFor("radius")
		local angle = self:GetAbility():GetSpecialValueFor("angle") / 2
		local cooldown = self:GetAbility():GetSpecialValueFor("passive_cd")
		if self:GetParent() == victim and attacker:GetTeamNumber() ~= victim:GetTeamNumber() then
			local enemies = FindUnitsInRadius(victim:GetTeamNumber(), victim:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
			local origin = victim:GetOrigin()
			local cast_direction = (attacker:GetOrigin() - origin):Normalized()

			local cast_range = (attacker:GetOrigin() - victim:GetAbsOrigin()):Length2D()
			local max_range = self:GetAbility():GetCastRange(attacker:GetOrigin(), self:GetParent())
--			if cast_range > max_range then return end

			local cast_angle = VectorToAngles(cast_direction).y
			for _,enemy in pairs(enemies) do
				local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
				local enemy_angle = VectorToAngles(enemy_direction).y
				local angle_diff = math.abs(AngleDiff(cast_angle, enemy_angle))
				if angle_diff <= angle then
					if attacker == enemy then
						victim:SetCursorCastTarget(attacker)
						Hit(victim, self:GetAbility(), origin, radius, angle)
						self:GetAbility():StartCooldown(cooldown)
					end
				end
			end
			self:GetParent():RemoveModifierByName("modifier_counter_slash_trigger")
		end
	end
end
--[[
function modifier_counter_slash_trigger:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end
]]
function modifier_counter_slash_trigger:GetModifierOverrideAbilitySpecial(params)
	if self:GetParent() == nil or params.ability == nil then return 0 end

	if params.ability:GetAbilityName() == "mjz_phantom_assassin_coup_de_grace" and params.ability_special_value == "crit_chance" then
		return 1
	end

	return 0
end
function modifier_counter_slash_trigger:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability:GetAbilityName() == "mjz_phantom_assassin_coup_de_grace" and params.ability_special_value == "crit_chance" then
		local nSpecialLevel = params.ability_special_level
		return params.ability:GetLevelSpecialValueNoOverride("crit_chance", nSpecialLevel) + 50
	end

	return 0
end

function Hit(caster, ability, origin, radius, angle)
	local point = ability:GetCursorPosition()
	local cast_direction = (point - origin):Normalized()
	local cast_angle = VectorToAngles(cast_direction).y

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)

	for _,enemy in pairs(enemies) do
		local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
		local enemy_angle = VectorToAngles(enemy_direction).y
		local angle_diff = math.abs(AngleDiff(cast_angle, enemy_angle))

		if angle_diff <= angle then
			if not ability:IsOwnersManaEnough() then return end
			ability:UseResources(true, false, false)
			caster:PerformAttack(enemy, true, true, true, true, false, false, true)

			PlayEffects2(enemy, origin, cast_direction)
		end
	end
	PlayEffects1(caster, (point - origin):Normalized(), radius)
end


--------------------------------------------------------------------------------
function PlayEffects1(caster, direction, radius)
	local effect_cast = ParticleManager:CreateParticle("particles/custom/abilities/heroes/phantom_assassin_counter_swing/pa_counter_swing.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_PhantomAssassin.PreAttack", caster)
	EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_PhantomAssassin.Arcana_Layer", caster)
end

function PlayEffects2(target, origin, direction)
	local particle_cast = "particles/custom/abilities/heroes/phantom_assassin_counter_swing/pa_counter_swing_hit.vpcf"

	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
	ParticleManager:SetParticleControlForward(effect_cast, 1, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitSoundOn("Hero_PhantomAssassin.Dagger.Target", target)
end
