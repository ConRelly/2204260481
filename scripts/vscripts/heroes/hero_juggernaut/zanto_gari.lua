LinkLuaModifier("modifier_zanto_gari", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_debuff", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_crit", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_invis", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_armor_pierce", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_grace_time", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_grace_time_shift", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_bonus_dmg", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
----------------
-- Zanto Gari --
----------------
zanto_gari = zanto_gari or class({})
function zanto_gari:GetIntrinsicModifierName() return "modifier_zanto_gari" end
if modifier_zanto_gari == nil then modifier_zanto_gari = class({}) end
function modifier_zanto_gari:IsHidden() return true end
function modifier_zanto_gari:IsPurgable() return false end
function modifier_zanto_gari:RemoveOnDeath() return false end
function modifier_zanto_gari:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_zanto_gari:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() return end
		self:StartIntervalThink(FrameTime())
--		local ability = self:GetCaster():FindAbilityByName("zanto_gari")
--		ability:SetCurrentAbilityCharges(10)
	end
end
function modifier_zanto_gari:OnIntervalThink()
	if IsServer() then
		local as = GameRules:GetGameModeEntity():GetMaximumAttackSpeed()
		self:SetStackCount(as)
	end
end
function zanto_gari:GetManaCost(level)
	if self:GetCaster():HasScepter() then
		local cooldown = self.BaseClass.GetManaCost(self, level) + (self:GetCaster():GetLevel() * 50)
		return cooldown
	end
	return self.BaseClass.GetManaCost(self, level)
end
--[[
function zanto_gari:GetCooldown(level)
	if self:GetCaster():HasScepter() then
		local cooldown = self.BaseClass.GetCooldown(self, level) - 5
		return cooldown
	end
	return self.BaseClass.GetCooldown(self, level)
end
]]
function zanto_gari:GetCastRange(location, target)
	if IsClient() then
		return self:GetSpecialValueFor("max_travel_distance")
	end
end

function zanto_gari:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	end
	return self.BaseClass.GetBehavior(self)
end
function zanto_gari:OnSpellStart(recastVector, warpVector, Interrupted)
	if IsServer() then
		local caster = self:GetCaster()
		local bHeroHit = false
		local self_target = false
		if self:GetCursorPosition() == caster:GetAbsOrigin() then
			caster:SetCursorPosition(self:GetCursorPosition() + caster:GetForwardVector())
		end
		if self:GetCursorTarget() and self:GetCursorTarget() == self:GetCaster() then
			local cursor = caster:GetAbsOrigin() + self:GetCaster():GetForwardVector()
			self:GetCaster():SetCursorPosition(cursor + self:GetCaster():GetForwardVector())
			self.selfcast = true
		end

		target_flag = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local ability_level = self:GetCaster():FindAbilityByName("zanto_gari"):GetLevel()
		if self:GetCaster():HasScepter() and self:GetCaster():HasShard() and ability_level == 7 then
			target_flag = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		end

		local original_position	= caster:GetAbsOrigin()
		local final_position = caster:GetAbsOrigin() + ((self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized() * math.max(math.min(((self:GetCursorPosition() - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Length2D(), self:GetSpecialValueFor("max_travel_distance") + caster:GetCastRangeBonus()), self:GetSpecialValueFor("min_travel_distance")))

		local slash_radius = self:GetSpecialValueFor("radius")
		local distance = (final_position - original_position):Length2D()
		local around = self:GetSpecialValueFor("max_travel_distance") / 2
		if distance <= 50 and caster:HasScepter() then slash_radius = around self_target = true end
		if recastVector then final_position = caster:GetAbsOrigin() + recastVector end
		if warpVector then final_position = GetGroundPosition(caster:GetAbsOrigin() + warpVector, nil) end

		caster:EmitSound("Hero_VoidSpirit.AstralStep.Start")
		if self_target then
			local particle = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_around.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 2, Vector(slash_radius, slash_radius, slash_radius))
			ParticleManager:ReleaseParticleIndex(particle)
		else
			self.original_vector = (final_position - caster:GetAbsOrigin()):Normalized() * (self:GetSpecialValueFor("max_travel_distance") + caster:GetCastRangeBonus())
			caster:SetForwardVector(self.original_vector:Normalized())
			local step_particle = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(step_particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(step_particle, 1, final_position)
			ParticleManager:ReleaseParticleIndex(step_particle)
		end

		for _, enemy in pairs(FindUnitsInLine(caster:GetTeamNumber(), caster:GetAbsOrigin(), final_position, nil, slash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, target_flag)) do
			self.impact_particle = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControlEnt(self.impact_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(self.impact_particle)
			caster:SetAbsOrigin(enemy:GetAbsOrigin() - caster:GetForwardVector())
			
--			caster:AddNewModifier(caster, self, "modifier_zanto_gari_crit", {})
--[[
			if warpVector and not Interrupted then
				enemy:AddNewModifier(caster, self, "modifier_zanto_gari_armor_pierce", {})
			end
]]
			caster:PerformAttack(enemy, false, true, true, false, false, false, false)
--			caster:RemoveModifierByName("modifier_zanto_gari_crit")
--			enemy:RemoveModifierByName("modifier_zanto_gari_armor_pierce")

			local attack_speed_multi = self:GetSpecialValueFor("attack_speed_multi")
			local shard_as = self:GetSpecialValueFor("shard_as")
			if self:GetCaster():HasShard() then
				attack_speed_multi = self:GetSpecialValueFor("attack_speed_multi") + (shard_as / 100)
			end
			local grace_time_as = (1 / caster:GetAttackSpeed()) / attack_speed_multi
			local grace_time_duration = GameRules:GetGameModeEntity():GetMaximumAttackSpeed() / 10
			local duration = self:GetSpecialValueFor("pop_damage_delay")
			local shift_duration = duration * 1.5
			caster:AddNewModifier(caster, self, "modifier_zanto_gari_grace_time_shift", {duration = shift_duration})
			if not caster:HasModifier("modifier_item_echo_wand") and HasSuperScepter(caster) then
				caster:AddNewModifier(caster, self, "modifier_zanto_gari_bonus_dmg", {duration = grace_time_duration})
			end
			enemy:AddNewModifier(caster, self, "modifier_zanto_gari_debuff", {duration = duration, grace_time_as = grace_time_as, grace_time_duration = grace_time_duration})
			if not bHeroHit then
				bHeroHit = true
			end
		end
		self.impact_particle = nil
		if not warpVector then
			FindClearSpaceForUnit(caster, final_position, false)
		else
			FindClearSpaceForUnit(caster, original_position, false)
		end
		caster:EmitSound("Hero_VoidSpirit.AstralStep.End")
		if bHeroHit then
			caster:EmitSound("Zanto_Gari.Swift")
		end
--[[
		if bHeroHit and not recastVector then
			if not caster:HasModifier("modifier_zanto_gari_invis") then
				caster:AddNewModifier(caster, self, "modifier_zanto_gari_invis", {duration = self:GetSpecialValueFor("hidden_ones_duration")})
			else
				caster:FindModifierByName("modifier_zanto_gari_invis"):SetDuration(caster:FindModifierByName("modifier_zanto_gari_invis"):GetRemainingTime() + self:GetSpecialValueFor("hidden_ones_duration"), true)
			end
		end
]]
		if caster:HasScepter() then
			ProjectileManager:ProjectileDodge(caster)
		end
	end
end

-----------------------
-- Zanto Gari Debuff --
-----------------------
modifier_zanto_gari_debuff = modifier_zanto_gari_debuff or class({})
function modifier_zanto_gari_debuff:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_zanto_gari_debuff:OnCreated(keys)
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.grace_time_duration = keys.grace_time_duration
		self.grace_time_as = keys.grace_time_as
		self:GetCaster():EmitSound("Zanto_Gari.Prepare")
	end
end
function modifier_zanto_gari_debuff:OnDestroy()
	if IsServer() then
		local damage = self:GetAbility():GetSpecialValueFor("pop_damage")
		if self:GetCaster():HasTalent("special_bonus_zanto_gari_dmg") then
			damage = self:GetAbility():GetSpecialValueFor("pop_damage") + (self:GetCaster():GetAttackDamage() * self:GetCaster():FindTalentValue("special_bonus_zanto_gari_dmg") / 100)
		end
		local prepare = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_slash_prepare.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(prepare)
		
		local dmg_type = DAMAGE_TYPE_MAGICAL
		local ability_level = self:GetCaster():FindAbilityByName("zanto_gari"):GetLevel()
		if self:GetCaster():HasScepter() and self:GetCaster():HasShard() and ability_level == 7 then
			dmg_type = DAMAGE_TYPE_PURE
		end
		ApplyDamage({
			victim 			= self:GetParent(),
			damage 			= damage,
			damage_type		= dmg_type,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self:GetAbility()
		})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), damage, nil)
		if self:GetParent():IsAlive() then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_zanto_gari_grace_time", {duration = self.grace_time_duration, grace_time_as = self.grace_time_as})
		end
		if not self:GetParent():IsAlive() and self:GetCaster():HasScepter() and self:GetCaster():HasShard() then
			local impact_kill = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_impact_kill.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(impact_kill, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(impact_kill)

			local charges = self:GetCaster():FindAbilityByName("zanto_gari"):GetCurrentAbilityCharges()
			if charges < 2 then
				self:GetCaster():FindAbilityByName("zanto_gari"):SetCurrentAbilityCharges(charges + 1)
			end
			self:GetCaster():FindAbilityByName("zanto_gari"):EndCooldown()
			self:GetCaster():EmitSound("Zanto_Gari.Impact")
		else
			local impact = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(impact, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(impact)
		end
	end
end

-----------------------------
-- Zanto Gari Armor Pierce --
-----------------------------
modifier_zanto_gari_armor_pierce = modifier_zanto_gari_armor_pierce or class({})
function modifier_zanto_gari_armor_pierce:IsHidden() return true end
function modifier_zanto_gari_armor_pierce:IsPurgable() return false end
function modifier_zanto_gari_armor_pierce:DeclareFunctions() return {MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR} end
function modifier_zanto_gari_armor_pierce:GetModifierIgnorePhysicalArmor() return 1 end

---------------------------------
-- Zanto Gari Grace Time Shift --
---------------------------------
modifier_zanto_gari_grace_time_shift = modifier_zanto_gari_grace_time_shift or class({})
function modifier_zanto_gari_grace_time_shift:IsHidden() return true end
function modifier_zanto_gari_grace_time_shift:IsPurgable() return false end
function modifier_zanto_gari_grace_time_shift:RemoveOnDeath() return false end
function modifier_zanto_gari_grace_time_shift:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_zanto_gari_grace_time_shift:GetOverrideAnimation() return ACT_DOTA_CAST_ABILITY_2 end
function modifier_zanto_gari_grace_time_shift:OnCreated()
	if IsServer() then
		self:GetCaster():EmitSound("Zanto_Gari.Grace_Time")
		local pfx = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_slash_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, self:GetCaster():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
	end
end
function modifier_zanto_gari_grace_time_shift:OnDestroy()
	if IsServer() then
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
	end
end
function modifier_zanto_gari_grace_time_shift:CheckState()
	return {[MODIFIER_STATE_FROZEN] = true,[MODIFIER_STATE_STUNNED] = true}
end

---------------------------
-- Zanto Gari Grace Time --
---------------------------
modifier_zanto_gari_grace_time = modifier_zanto_gari_grace_time or class({})
function modifier_zanto_gari_grace_time:IsHidden() return false end
function modifier_zanto_gari_grace_time:IsPurgable() return false end
function modifier_zanto_gari_grace_time:RemoveOnDeath() return false end
function modifier_zanto_gari_grace_time:OnCreated(keys)
	if IsServer() then
		self.grace_time_as = keys.grace_time_as
		Attack(self:GetParent(), self:GetCaster())
		self:StartIntervalThink(self.grace_time_as)
	end
end
function modifier_zanto_gari_grace_time:OnIntervalThink()
	if not self:GetParent():IsAlive() then self:Destroy() end
	Attack(self:GetParent(), self:GetCaster())
end
function modifier_zanto_gari_grace_time:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_zanto_gari_grace_time:GetModifierMoveSpeedBonus_Percentage() return self:GetCaster():FindAbilityByName("zanto_gari"):GetSpecialValueFor("movement_slow_pct") * (-1) end
function modifier_zanto_gari_grace_time:OnDestroy() if IsServer() then end end

function Attack(target, caster)
	caster:PerformAttack(target, false, false, true, false, false, false, true)
	local hit_pfx = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(hit_pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(hit_pfx, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(hit_pfx)
end

--------------------------
-- Zanto Gari Bonus Dmg --
--------------------------
modifier_zanto_gari_bonus_dmg = modifier_zanto_gari_bonus_dmg or class({})
function modifier_zanto_gari_bonus_dmg:IsPurgable() return false end
function modifier_zanto_gari_bonus_dmg:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_INVULNERABLE] = true}
end
function modifier_zanto_gari_bonus_dmg:GetEffectName() return "particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_vibr.vpcf" end
function modifier_zanto_gari_bonus_dmg:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_zanto_gari_bonus_dmg:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_zanto_gari_bonus_dmg:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetCaster():FindAbilityByName("zanto_gari"):GetSpecialValueFor("pt_base_attack")
end

---------------------
-- Zanto Gari Crit --
---------------------
modifier_zanto_gari_crit = modifier_zanto_gari_crit or class({})
function modifier_zanto_gari_crit:IsPurgable() return false end
function modifier_zanto_gari_crit:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_INVULNERABLE] = true}
end
function modifier_zanto_gari_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_zanto_gari_crit:GetModifierPreAttack_CriticalStrike()
	if self:GetCaster():HasTalent("special_bonus_zanto_gari_dmg") then
		return self:GetCaster():FindTalentValue("special_bonus_zanto_gari_dmg")
	end
end
function modifier_zanto_gari_crit:GetModifierTotalDamageOutgoing_Percentage(keys)
	if not keys.no_attack_cooldown and keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and keys.damage_flags == DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION then
		return -100
	end
end

----------------------
-- Zanto Gari Invis --
----------------------
modifier_zanto_gari_invis = modifier_zanto_gari_invis or class({})
function modifier_zanto_gari_invis:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true} end
function modifier_zanto_gari_invis:DeclareFunctions() return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_zanto_gari_invis:GetModifierInvisibilityLevel() return 1 end


---------------------
-- TALENT HANDLERS --
---------------------
LinkLuaModifier("modifier_special_bonus_zanto_gari_cooldown", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_special_bonus_zanto_gari_dmg", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
modifier_special_bonus_zanto_gari_cooldown	= modifier_special_bonus_zanto_gari_cooldown or class({})
modifier_special_bonus_zanto_gari_dmg = modifier_special_bonus_zanto_gari_dmg or class({})

function modifier_special_bonus_zanto_gari_cooldown:IsHidden() return true end
function modifier_special_bonus_zanto_gari_cooldown:IsPurgable() return false end
function modifier_special_bonus_zanto_gari_cooldown:RemoveOnDeath() return false end

function modifier_special_bonus_zanto_gari_dmg:IsHidden() return true end
function modifier_special_bonus_zanto_gari_dmg:IsPurgable() return false end
function modifier_special_bonus_zanto_gari_dmg:RemoveOnDeath() return false end
