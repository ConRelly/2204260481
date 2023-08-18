LinkLuaModifier("modifier_mjz_bounty_hunter_jinada", "abilities/hero_bounty_hunter/mjz_bounty_hunter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jinada_crit", "abilities/hero_bounty_hunter/mjz_bounty_hunter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jinada_gold_tracker", "abilities/hero_bounty_hunter/mjz_bounty_hunter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jinada_gold_tracker_hide", "abilities/hero_bounty_hunter/mjz_bounty_hunter.lua", LUA_MODIFIER_MOTION_NONE)


-------------------
-- Shuriken Toss --
-------------------
shuriken_toss = shuriken_toss or class({})
function shuriken_toss:GetCastRange(location, target)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cast_range") + talent_value(self:GetCaster(), "special_bonus_bh_shuriken_toss_1")
	else
		return self:GetSpecialValueFor("cast_range") + talent_value(self:GetCaster(), "special_bonus_bh_shuriken_toss_1")
	end
end
function shuriken_toss:GetCooldown(level)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cooldown")
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end
function shuriken_toss:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local projectile_speed = self:GetSpecialValueFor("speed") + talent_value(caster, "special_bonus_bh_shuriken_toss_1")

	EmitSoundOn("Hero_BountyHunter.Shuriken", caster)

	local enemy_table = {}
	table.insert(enemy_table, target)
	local enemy_table_string = TableToStringCommaEnt(enemy_table)

	local shuriken_projectile
	shuriken_projectile = {
		Target = target,
		Source = caster,
		Ability = self,
		EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
		iMoveSpeed = projectile_speed,
		bDodgeable = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		bProvidesVision = false,
		ExtraData = {enemy_table_string = enemy_table_string}
	}
	ProjectileManager:CreateTrackingProjectile(shuriken_projectile)
end
function shuriken_toss:OnProjectileHit_ExtraData(target, location, extradata)
	if IsServer() then
		local caster = self:GetCaster()
		local enemy_table_string = extradata.enemy_table_string
		local enemy_table = StringToTableEnt(enemy_table_string, ",")

		local projectile_speed = self:GetSpecialValueFor("speed") + talent_value(caster, "special_bonus_bh_shuriken_toss_1")
		local damage = self:GetSpecialValueFor("bonus_damage") + talent_value(caster, "special_bonus_unique_bounty_hunter_2")
		local bounce_aoe = self:GetSpecialValueFor("bounce_aoe")
		local ministun = self:GetSpecialValueFor("ministun")
		local bonus = self:GetSpecialValueFor("super_base_stats")
		if caster:IsRealHero() then
			local stats = (caster:GetAgility() + caster:GetStrength()) * self:GetSpecialValueFor("str_agi_damage")
			damage = damage + stats
		end	
		if not target then return end

		target:EmitSound("Hero_BountyHunter.Shuriken.Impact")

		if target:IsMagicImmune() then return end
		if caster:GetTeamNumber() ~= target:GetTeamNumber() then if target:TriggerSpellAbsorb(self) then return end end

		target:AddNewModifier(caster, self, "modifier_stunned", {duration = ministun * (1 - target:GetStatusResistance())})

		if caster:HasScepter() then
			if target:IsAlive() and caster:HasAbility("mjz_bounty_hunter_jinada") and caster:FindAbilityByName("mjz_bounty_hunter_jinada"):IsTrained() then
				Jinada(caster, target, self, true)
				local jinada_stats = caster:GetAgility() + caster:GetIntellect() + caster:GetStrength()
				local jinada_damage = caster:CustomValue("mjz_bounty_hunter_jinada", "bonus_damage") + (jinada_stats * caster:CustomValue("mjz_bounty_hunter_jinada", "stats_mult"))
				ApplyDamage({
					victim		= target,
					damage		= jinada_damage,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					attacker	= caster,
					ability		= self
				})
			end
		end
		if caster:HasSuperScepter() then
			caster:PerformAttack(target, true, true, true, true, false, true, true)
			if caster:IsRealHero() then
				caster:ModifyAgility(bonus)
				caster:ModifyStrength(bonus)
			end	
		end
		if target:HasModifier("modifier_bounty_hunter_track") then
			damage = damage * caster:CustomValue("bounty_hunter_track", "toss_crit_multiplier") / 100
		end
		ApplyDamage({
			victim		= target,
			damage		= damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			attacker	= caster,
			ability		= self
		})

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, bounce_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

		local projectile_fired = false
		for _,enemy in pairs(enemies) do
			local enemy_found = false
			for _,enemy_in_table in pairs(enemy_table) do
				if enemy == enemy_in_table then
					enemy_found = true
					break
				end
			end

			if enemy:HasModifier("modifier_bounty_hunter_track") and not enemy_found then
				table.insert(enemy_table, enemy)
				enemy_table_string = TableToStringCommaEnt(enemy_table)

				local shuriken_projectile
				shuriken_projectile = {
					Target = enemy,
					Source = target,
					Ability = self,
					EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
					iMoveSpeed = projectile_speed,
					bDodgeable = true,
					bVisibleToEnemies = true,
					bReplaceExisting = false,
					bProvidesVision = false,
					ExtraData = {enemy_table_string = enemy_table_string}
				}

				ProjectileManager:CreateTrackingProjectile(shuriken_projectile)

				projectile_fired = true
				break
			end
		end
	end
end



------------
-- Jinada --
------------
mjz_bounty_hunter_jinada = class({})
function mjz_bounty_hunter_jinada:GetIntrinsicModifierName() if self:GetCaster():IsIllusion() then return end return "modifier_mjz_bounty_hunter_jinada" end
function mjz_bounty_hunter_jinada:GetCooldown(Level)
	return self.BaseClass.GetCooldown(self, Level) / self:GetCaster():GetCooldownReduction()
end

---------------------
-- Jinada Modifier --
---------------------
modifier_mjz_bounty_hunter_jinada = class({})
function modifier_mjz_bounty_hunter_jinada:IsPassive() return true end
function modifier_mjz_bounty_hunter_jinada:IsHidden() return true end
function modifier_mjz_bounty_hunter_jinada:IsPurgable() return false end
function modifier_mjz_bounty_hunter_jinada:OnCreated()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jinada_gold_tracker", {})
	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jinada_gold_tracker_hide", {})
	self:StartIntervalThink(FrameTime())
end
function modifier_mjz_bounty_hunter_jinada:OnIntervalThink()
	if self:GetAbility():IsCooldownReady() and not self:GetCaster():HasModifier("modifier_jinada_crit") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jinada_crit", {})
	end
	if self:GetAbility():GetAutoCastState() then
		self:GetCaster():RemoveModifierByName("modifier_jinada_gold_tracker_hide")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jinada_gold_tracker_hide", {})
	end
end

--------------------------
-- Jinada Crit Modifier --
--------------------------
modifier_jinada_crit = modifier_jinada_crit or class({})
function modifier_jinada_crit:IsHidden() return true end
function modifier_jinada_crit:IsPurgable() return false end
function modifier_jinada_crit:IsDebuff() return false end
function modifier_jinada_crit:OnCreated()
	if IsServer() then
		self.particle_glow_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_hand_r.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.particle_glow_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon1", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(self.particle_glow_fx, false, false, -1, false, false)

		self.particle_glow_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_hand_l.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.particle_glow_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon2", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(self.particle_glow_fx, false, false, -1, false, false)
	end
	self:StartIntervalThink(FrameTime())
end
function modifier_jinada_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_jinada_crit:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if parent:PassivesDisabled() then return end
	if parent:IsIllusion() then return end
	if IsServer() then
		hp_mp = (parent:GetMaxHealth() + parent:GetMaxMana()) * ability:GetSpecialValueFor("hp_mp") / 100
		stats = parent:GetAgility() + parent:GetIntellect() + parent:GetStrength()
		if ability:IsCooldownReady() then
			self:SetStackCount(ability:GetSpecialValueFor("bonus_damage") + (stats * ability:GetSpecialValueFor("stats_mult")))
			if ability:GetLevel() > 5 then
				self:SetStackCount(self:GetStackCount() + hp_mp)
			end
		end
	end
end
function modifier_jinada_crit:GetModifierPreAttack_BonusDamage(keys)
	if not self:GetParent():PassivesDisabled() and keys.target and keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		return self:GetStackCount()
	end
end
function modifier_jinada_crit:OnAttackLanded(keys)
	if IsServer() then
		local target = keys.target
		local parent = self:GetParent()
		local ability = self:GetAbility()

		if keys.attacker ~= parent then return end
		if not parent:IsRealHero() then return end
		if parent:PassivesDisabled() then return end

		if target:GetTeamNumber() ~= parent:GetTeamNumber() and not parent:IsIllusion() then
			if ability:IsCooldownReady() then
				if not target:IsBuilding() and not target:IsTower() then
					Jinada(parent, target, ability, false)
				end
				ability:UseResources(true, true, true, true)
				if self:IsNull() then return end
				self:Destroy()
			end
		end
	end
end

-------------------------
-- Jinada Gold Tracker --
-------------------------
modifier_jinada_gold_tracker = modifier_jinada_gold_tracker or class({})
function modifier_jinada_gold_tracker:IsHidden() return (self:GetCaster():HasModifier("modifier_jinada_gold_tracker_hide")) end
function modifier_jinada_gold_tracker:IsPurgable() return false end
function modifier_jinada_gold_tracker:RemoveOnDeath() return false end
function modifier_jinada_gold_tracker:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_jinada_gold_tracker:OnTooltip()
	return self:GetStackCount()
end

modifier_jinada_gold_tracker_hide = modifier_jinada_gold_tracker_hide or class({})
function modifier_jinada_gold_tracker_hide:IsHidden() return true end
function modifier_jinada_gold_tracker_hide:IsPurgable() return false end
function modifier_jinada_gold_tracker_hide:RemoveOnDeath() return false end



--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
function Jinada(parent, target, ability, track)
	if not track then
		parent:EmitSound("Hero_BountyHunter.Jinada")
		local particle_hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf", PATTACH_ABSORIGIN, parent)
		ParticleManager:SetParticleControl(particle_hit_fx, 0, target:GetAbsOrigin())
		ParticleManager:DestroyParticle(particle_hit_fx, false)
		ParticleManager:ReleaseParticleIndex(particle_hit_fx)
	end
--	if target:IsHero() or target:IsCreature() then
		local gold_steal = parent:CustomValue("mjz_bounty_hunter_jinada", "gold_steal") + talent_value(parent, "special_bonus_unique_bounty_hunter_custom_gold")
		
		local gold_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
--		ParticleManager:SetParticleControl(gold_pfx, 0, target:GetAbsOrigin())
--		ParticleManager:SetParticleControl(gold_pfx, 1, parent:GetAbsOrigin())
--		ParticleManager:SetParticleControlEnt(gold_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(gold_pfx, 0, target, PATTACH_POINT_FOLLOW, nil, target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(gold_pfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:DestroyParticle(gold_pfx, false)
		ParticleManager:ReleaseParticleIndex(gold_pfx)

		parent:ModifyGold(gold_steal, false, DOTA_ModifyGold_Unspecified)
		target:EmitSound("DOTA_Item.Hand_Of_Midas")
		SendOverheadEventMessage(parent, OVERHEAD_ALERT_GOLD, target, gold_steal, nil)
		
		if parent:HasModifier("modifier_jinada_gold_tracker") then
			local gold_tracker = parent:FindModifierByName("modifier_jinada_gold_tracker")
			gold_tracker:SetStackCount(gold_tracker:GetStackCount() + gold_steal)
		end
--	end
end
