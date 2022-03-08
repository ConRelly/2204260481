LinkLuaModifier("modifier_pa_stifling_dagger_slow", "heroes/hero_phantom_assassin/stifling_dagger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pa_stifling_dagger_bonus_damage", "heroes/hero_phantom_assassin/stifling_dagger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pa_stifling_dagger_dmg_manipulation", "heroes/hero_phantom_assassin/stifling_dagger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pa_stifling_dagger_marker", "heroes/hero_phantom_assassin/stifling_dagger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pa_stifling_dagger_buff", "heroes/hero_phantom_assassin/stifling_dagger", LUA_MODIFIER_MOTION_NONE)

---------------------
-- Stifling Dagger --
---------------------
pa_stifling_dagger = class({})
function pa_stifling_dagger:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("cast_range") end
function pa_stifling_dagger:GetBehavior()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end
function pa_stifling_dagger:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return self.BaseClass.GetCooldown(self, level) - 2
	end
	return self.BaseClass.GetCooldown(self, level)
end
function pa_stifling_dagger:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return "phantom_assassin/ti8_immortal_helmet/phantom_assassin_stifling_dagger_immortal"	
	end
	return "phantom_assassin_stifling_dagger"
end
function pa_stifling_dagger:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local radius = self:GetSpecialValueFor("search_radius")
	self.super_scepter = false
	self.blink = false
	
	StartSoundEvent("Hero_PhantomAssassin.Dagger.Cast", caster)

	self.hitten_targets = {}
	
	target:AddNewModifier(caster, self, "modifier_pa_stifling_dagger_marker", {})
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		self.super_scepter = true
	end
	if self:GetAutoCastState() then
		if self.super_scepter then
			self.blink = true
		end
	end
	self:LaunchDagger(target, self.super_scepter, self.blink)

--[[
	local count = 1
	if self:GetCaster():HasScepter() then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		
		for _, enemy in pairs(enemies) do
			if count < 5 and enemy ~= target then
				count = count + 1
				self:LaunchDagger(enemy)
			end
		end
	end
]]
end

function pa_stifling_dagger:LaunchDagger(enemy, super_scepter, blink)
	if enemy == nil then return end
	local dagger_speed = self:GetSpecialValueFor("dagger_speed") + talent_value(self:GetCaster(), "special_bonus_pa_stifling_dagger_speed")

	if super_scepter then
		Effect_Name = "particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_stifling_dagger.vpcf"
	else
		Effect_Name = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf"
	end
	self.blink = blink
	self.super_scepter = super_scepter

	local dagger_projectile = {
		Target = enemy,
		Source = self:GetCaster(),
		Ability = self,
		iMoveSpeed = dagger_speed,
		EffectName = Effect_Name,
		vSourceLoc= self:GetCaster():GetAbsOrigin(),
		bDodgeable = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		ProvidesVision = true,
		VisionRadius = self:GetSpecialValueFor("search_radius"),
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		ExtraData = {}
	}

	ProjectileManager:CreateTrackingProjectile(dagger_projectile)
end

function pa_stifling_dagger:OnProjectileThink_ExtraData(location, ExtraData)
	local caster = self:GetCaster()
	if self.blink and self.super_scepter then
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, self:GetSpecialValueFor("search_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

		for _, target in pairs(targets) do
			if target then
				if not self.hitten_targets[target] and not target:HasModifier("modifier_pa_stifling_dagger_marker") then
					self.hitten_targets[target] = true
					self:Blink(target)
					break
				end
			end
		end
	end
end
function pa_stifling_dagger:OnProjectileHit_ExtraData(target, location, ExtraData)
	local caster = self:GetCaster()
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local bonus_as_duration = self:GetSpecialValueFor("bonus_as_duration") + talent_value(caster, "special_bonus_pa_stifling_dagger_buff_duration")
	if not target then return false end

	if target:GetTeamNumber() ~= caster:GetTeamNumber() then if target:TriggerSpellAbsorb(self) then return false end end

	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, self, "modifier_pa_stifling_dagger_slow", {duration = slow_duration * (1 - target:GetStatusResistance())})
	end

	caster:AddNewModifier(caster, self, "modifier_pa_stifling_dagger_dmg_manipulation", {})

	local initial_pos = caster:GetAbsOrigin()
	local target_pos = target:GetAbsOrigin()
	local distance_vector = Vector(target_pos.x - initial_pos.x, target_pos.y - initial_pos.y, 0)
	distance_vector = distance_vector:Normalized()

	target_pos.x = target_pos.x - 125 * distance_vector.x
	target_pos.y = target_pos.y - 125 * distance_vector.y

--	caster:SetAbsOrigin(target_pos)
	caster:PerformAttack(target, true, true, true, true, false, false, true)
	if caster:HasModifier("modifier_item_aghanims_shard") then
		caster:PerformAttack(target, true, true, true, true, true, true, true)
	end
--	caster:SetAbsOrigin(initial_pos)

	if target:HasModifier("modifier_pa_stifling_dagger_marker") then
		self:Blink(target)
		caster:AddNewModifier(caster, self, "modifier_pa_stifling_dagger_buff", {duration = bonus_as_duration})

		target:RemoveModifierByName("modifier_pa_stifling_dagger_marker")
	end

	caster:RemoveModifierByName("modifier_pa_stifling_dagger_dmg_manipulation")
	return true
end

function pa_stifling_dagger:Blink(target)
	local caster = self:GetCaster()
	local blink_start_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_start.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(blink_start_fx)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_PhantomAssassin.Strike.Start", caster)

	local point = target:GetAbsOrigin() + (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * 50
	FindClearSpaceForUnit(caster, point, false)

	local blink_end_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(blink_end_fx, 0, point)
	ParticleManager:ReleaseParticleIndex(blink_end_fx)
	EmitSoundOnLocationWithCaster(point, "Hero_PhantomAssassin.Strike.End", caster)

	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
--	caster:SetForwardVector(direction)
	caster:PerformAttack(target, true, true, true, true, true, false, true)
	caster:MoveToTargetToAttack(target)
end


----------------------------
-- Stifling Dagger marker --
----------------------------
modifier_pa_stifling_dagger_marker = class({})
function modifier_pa_stifling_dagger_marker:IsHidden() return true end
function modifier_pa_stifling_dagger_marker:IsDebuff() return true end
function modifier_pa_stifling_dagger_marker:IsPurgable() return false end


--------------------------
-- Stifling Dagger slow --
--------------------------
modifier_pa_stifling_dagger_slow = class({})
function modifier_pa_stifling_dagger_slow:IsHidden() return false end
function modifier_pa_stifling_dagger_slow:GetModifierProvidesFOWVision() return true end
function modifier_pa_stifling_dagger_slow:IsDebuff() return true end
function modifier_pa_stifling_dagger_slow:IsPurgable() return true end
function modifier_pa_stifling_dagger_slow:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local dagger_vision = 400
		local duration = self:GetAbility():GetSpecialValueFor("slow_duration")
		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

		AddFOWViewer(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), dagger_vision, 3.34, false)
	end
end
function modifier_pa_stifling_dagger_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_STATE_PROVIDES_VISION}
end
function modifier_pa_stifling_dagger_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_slow") * (-1)
end
function modifier_pa_stifling_dagger_slow:OnDestroy()
	if not IsServer() then return end

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end


-----------------------------------------
-- Stifling Dagger damage manipulation --
-----------------------------------------
modifier_pa_stifling_dagger_dmg_manipulation = class({})
function modifier_pa_stifling_dagger_dmg_manipulation:IsHidden() return true end
function modifier_pa_stifling_dagger_dmg_manipulation:IsBuff() return true end
function modifier_pa_stifling_dagger_dmg_manipulation:IsPurgable() return false end
function modifier_pa_stifling_dagger_dmg_manipulation:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_pa_stifling_dagger_dmg_manipulation:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("attack_factor") - 100
end
function modifier_pa_stifling_dagger_dmg_manipulation:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


---------------------------------------
-- Stifling Dagger attack speed buff --
---------------------------------------
modifier_pa_stifling_dagger_buff = class({})
function modifier_pa_stifling_dagger_buff:IsHidden() return false end
function modifier_pa_stifling_dagger_buff:IsBuff() return true end
function modifier_pa_stifling_dagger_buff:IsPurgable() return true end
function modifier_pa_stifling_dagger_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_pa_stifling_dagger_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_as") + talent_value(self:GetCaster(), "special_bonus_pa_stifling_dagger_attack_speed")
end
