LinkLuaModifier("modifier_sniper_bullet", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_normal_bullets", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_explosive_bullets", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrapnel_bullets", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_change_bullets_type", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pocket_portal_duration", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pocket_portal_evasion", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kardels_skills", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hunting_mark", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_kardel_hit_stun", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)


-----------
-- Shoot --
-----------
sniper_shoot = class({})
function sniper_shoot:GetCastRange(location, target) return self:GetCaster():Script_GetAttackRange() - self:GetCaster():GetCastRangeBonus() end
function sniper_shoot:OnUpgrade()
	self:GetCaster():FindAbilityByName("reload_bullet"):SetLevel(1)
	self:GetCaster():FindAbilityByName("change_bullets_type"):SetLevel(1)
end
function sniper_shoot:GetBehavior()
--[[ 	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end ]]
	return self.BaseClass.GetBehavior(self)
end
--[[ function sniper_shoot:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("aoe_scepter")
	end
	return 0
end ]]
function sniper_shoot:OnSpellStart()	
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	caster:RemoveModifierByName("modifier_sniper_bullet")

	unit_counter = 0
	local enemy_table = {}
	table.insert(enemy_table, target)
	local enemy_table_string = TableToStringCommaEnt(enemy_table)

	if caster:HasModifier("modifier_normal_bullets") then
		Proj_Effect = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf"
		Dodgeable = false
	elseif caster:HasModifier("modifier_explosive_bullets") then
		Proj_Effect = "particles/custom/abilities/heroes/kardel_bullets/expl_bullet_projectile.vpcf"
		Dodgeable = true
	elseif caster:HasModifier("modifier_shrapnel_bullets") then
		Proj_Effect = "particles/custom/abilities/heroes/kardel_bullets/shrap_bullet_projectile.vpcf"
		Dodgeable = true
	end

	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = Proj_Effect,
		iMoveSpeed = caster:GetProjectileSpeed(),
		vSourceLoc = caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = Dodgeable,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 60,
		bProvidesVision = true,
		iVisionRadius = 400,
		iVisionTeamNumber = caster:GetTeamNumber(),
		ExtraData = {target = target:entindex(), enemy_table_string = enemy_table_string}
	}
	ProjectileManager:CreateTrackingProjectile(info)

	EmitSoundOn("Sniper_Shoot", caster)
	EmitSoundOn("Hero_Sniper.AssassinateProjectile", caster)
end
function sniper_shoot:OnProjectileHit_ExtraData(target, location, extradata)
	if not IsServer() then return nil end
	local caster = self:GetCaster()

	if target == nil then return end
	if target:IsOutOfGame() then return end
	if target:IsInvulnerable() then return end

	if caster:HasModifier("modifier_normal_bullets") then
		if target:TriggerSpellAbsorb(self) then return end
		instances_count = 2
		base_damage = caster:GetAttackDamage() * (self:GetSpecialValueFor("norm_bullet") + talent_value(self:GetCaster(), "special_bonus_sniper_shoot_bullet_dmg")) / 100 / instances_count
		Proj_Effect = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf"
		Dodgeable = false
	elseif caster:HasModifier("modifier_explosive_bullets") then
		instances_count = 1
		base_damage = caster:GetAttackDamage() * (self:GetSpecialValueFor("expl_bullet") + talent_value(self:GetCaster(), "special_bonus_sniper_shoot_bullet_dmg")) / 100 / instances_count
		Proj_Effect = "particles/custom/abilities/heroes/kardel_bullets/expl_bullet_projectile.vpcf"
		Dodgeable = true
	elseif caster:HasModifier("modifier_shrapnel_bullets") then
		if target:TriggerSpellAbsorb(self) then return end
		instances_count = 8
		base_damage = caster:GetAttackDamage() * (self:GetSpecialValueFor("shrap_bullet") + talent_value(self:GetCaster(), "special_bonus_sniper_shoot_bullet_dmg")) / 100 / instances_count
		Proj_Effect = "particles/custom/abilities/heroes/kardel_bullets/shrap_bullet_projectile.vpcf"
		Dodgeable = true
	end

	local enemy_table_string = extradata.enemy_table_string
	local enemy_table = StringToTableEnt(enemy_table_string, ",")

	unit_counter = unit_counter + 1
	if target:HasModifier("modifier_hunting_mark") and unit_counter == 1 then
		damage = base_damage * talent_value(self:GetCaster(), "special_bonus_hunting_mark_direct_shot_bonus") / 100
	else
		damage = base_damage
	end
	StopSoundOn("Hero_Sniper.AssassinateProjectile", caster)
	for i = 1, instances_count do
		Hit_Enemy(caster, target, self, damage)
		EmitSoundOn("Hero_Sniper.AssassinateDamage", target)
	end

	if unit_counter > caster:CustomValue("hunting_mark", "ricochet") then return end

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), caster, self:GetSpecialValueFor("target_search"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

	local projectile_fired = false
	for _, enemy in pairs(enemies) do
		local enemy_found = false
		for _, enemy_in_table in pairs(enemy_table) do
			if enemy == enemy_in_table then
				enemy_found = true
				break
			end
		end

		if enemy:HasModifier("modifier_hunting_mark") and not enemy_found then
			table.insert(enemy_table, enemy)
			enemy_table_string = TableToStringCommaEnt(enemy_table)

			local info = 
			{
				Target = enemy,
				Source = target,
				Ability = self,
				EffectName = Proj_Effect,
				iMoveSpeed = caster:GetProjectileSpeed(),
				vSourceLoc = target:GetAbsOrigin(),
				bDrawsOnMinimap = false,
				bDodgeable = Dodgeable,
				bIsAttack = false,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				flExpireTime = GameRules:GetGameTime() + 60,
				bProvidesVision = true,
				iVisionRadius = 400,
				iVisionTeamNumber = caster:GetTeamNumber(),
				ExtraData = {target = target:entindex(), enemy_table_string = enemy_table_string}
			}
			ProjectileManager:CreateTrackingProjectile(info)

			EmitSoundOn("Hero_Sniper.AssassinateProjectile", caster)
			projectile_fired = true
			break
		end
	end
end

function Hit_Enemy(caster, target, ability, damage)
	if caster:HasModifier("modifier_normal_bullets") then
		Normal_Shot(caster, target, ability, damage)
	elseif caster:HasModifier("modifier_explosive_bullets") then
		Explosive_Shot(caster, target, ability, damage)
	elseif caster:HasModifier("modifier_shrapnel_bullets") then
		Shrapnel_Shot(caster, target, ability, damage)
	end
end
function Normal_Shot(caster, target, ability, damage)
	caster:PerformAttack(target, true, true, true, false, false, true, true)
	ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		victim = target
	})
    if target and target:IsIllusion() and target:IsAlive() then
		Timers:CreateTimer(2, function()
			target:RemoveSelf()
		end)
		target:ForceKill(false)
    end
end
function Explosive_Shot(caster, target, ability, damage)
	local explosive_bullet_sm = caster:CustomValue("change_bullets_type", "expl_phys_radius")
	local enemies_sm = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, explosive_bullet_sm, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local explosive_bullet_bg = caster:CustomValue("change_bullets_type", "expl_magic_radius")
	local enemies_bg = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, explosive_bullet_bg, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy_sm in pairs(enemies_sm) do
		ApplyDamage({
			ability = ability,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			victim = enemy_sm
		})
	end
	for _, enemy_bg in pairs(enemies_bg) do
		ApplyDamage({
			ability = ability,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			victim = enemy_bg
		})
	end

	local expl_pfx = ParticleManager:CreateParticle("particles/custom/abilities/heroes/kardel_bullets/expl_bullet.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(expl_pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(expl_pfx, 2, Vector(explosive_bullet_bg, 1, 1))
	ParticleManager:ReleaseParticleIndex(expl_pfx)
	target:AddNewModifier(caster, ability, "modifier_kardel_hit_stun", {duration = 0.2})
	target:EmitSoundParams("Hero_Gyrocopter.HomingMissile.Destroy", 1, 0.5, 0)
end
function Shrapnel_Shot(caster, target, ability, damage)
	caster:PerformAttack(target, true, true, true, false, false, true, true)
	local DamageTypeList = {DAMAGE_TYPE_PHYSICAL, DAMAGE_TYPE_MAGICAL, DAMAGE_TYPE_PURE}
	local Roll = RandomInt(1, #DamageTypeList)
	ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = DamageTypeList[Roll],
		damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		victim = target
	})
end


modifier_kardel_hit_stun = class({})
function modifier_kardel_hit_stun:IsHidden() return true end
function modifier_kardel_hit_stun:IsDebuff() return true end
function modifier_kardel_hit_stun:IsStunDebuff() return true end
function modifier_kardel_hit_stun:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_kardel_hit_stun:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_kardel_hit_stun:GetOverrideAnimation(params) return ACT_DOTA_DISABLED end
function modifier_kardel_hit_stun:GetEffectName() return "particles/custom/abilities/heroes/kardel_bullets/kardel_hit_stun.vpcf" end
function modifier_kardel_hit_stun:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end


modifier_sniper_bullet = class({})
function modifier_sniper_bullet:IsHidden() return true end
function modifier_sniper_bullet:IsPurgable() return false end
function modifier_sniper_bullet:RemoveOnDeath() return false end

modifier_normal_bullets = class({})
function modifier_normal_bullets:IsHidden() return false end
function modifier_normal_bullets:IsPurgable() return false end
function modifier_normal_bullets:RemoveOnDeath() return false end
function modifier_normal_bullets:GetTexture() return "custom/abilities/norm_bullet" end

modifier_explosive_bullets = class({})
function modifier_explosive_bullets:IsHidden() return false end
function modifier_explosive_bullets:IsPurgable() return false end
function modifier_explosive_bullets:RemoveOnDeath() return false end
function modifier_explosive_bullets:GetTexture() return "custom/abilities/expl_bullet" end

modifier_shrapnel_bullets = class({})
function modifier_shrapnel_bullets:IsHidden() return false end
function modifier_shrapnel_bullets:IsPurgable() return false end
function modifier_shrapnel_bullets:RemoveOnDeath() return false end
function modifier_shrapnel_bullets:GetTexture() return "custom/abilities/shrap_bullet" end
function modifier_shrapnel_bullets:DeclareFunctions() return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE} end
function modifier_shrapnel_bullets:GetModifierTotalDamageOutgoing_Percentage() return -35 end


---------------
-- Reloading --
---------------
reload_bullet = class({})
function reload_bullet:GetChannelTime()
	return self:GetSpecialValueFor("reload_time") - talent_value(self:GetCaster(), "special_bonus_kardel_reloading")
end
function reload_bullet:OnAbilityPhaseStart() EmitSoundOn("Pre_Reload", self:GetCaster()) return true end
function reload_bullet:OnChannelFinish(Interrupted)
	if IsServer() then
		local caster = self:GetCaster()
		if not Interrupted then
			if not (caster:HasModifier("modifier_normal_bullets") or caster:HasModifier("modifier_explosive_bullets") or caster:HasModifier("modifier_shrapnel_bullets")) then
				caster:AddNewModifier(caster, self, "modifier_normal_bullets", {})
			end
			caster:AddNewModifier(caster, self, "modifier_sniper_bullet", {})
			EmitSoundOn("End_Reload", caster)
		else
			StopSoundOn("Pre_Reload", caster)
		end
	end
end


--------------------
-- Change Bullets --
--------------------
change_bullets_type = class({})
function change_bullets_type:GetAbilityTextureName()
	if IsClient() then
		if self:GetCaster():HasModifier("modifier_explosive_bullets") then
			return "custom/abilities/change_bullets_23"
		elseif self:GetCaster():HasModifier("modifier_shrapnel_bullets") then
			return "custom/abilities/change_bullets_31"
		else
			return "custom/abilities/change_bullets_12"
		end
	end
end
function change_bullets_type:GetChannelTime()
	return self:GetSpecialValueFor("changing_time") - talent_value(self:GetCaster(), "special_bonus_kardel_reloading")
end
function change_bullets_type:OnAbilityPhaseStart() EmitSoundOn("Ability.AssassinateLoad", self:GetCaster()) return true end
function change_bullets_type:OnChannelFinish(Interrupted)
	if IsServer() then
		local caster = self:GetCaster()
		if not Interrupted then
			if caster:HasModifier("modifier_normal_bullets") then
				caster:RemoveModifierByName("modifier_normal_bullets")
				caster:AddNewModifier(caster, self, "modifier_explosive_bullets", {})
			elseif caster:HasModifier("modifier_explosive_bullets") then
				caster:RemoveModifierByName("modifier_explosive_bullets")
				caster:AddNewModifier(caster, self, "modifier_shrapnel_bullets", {})
			elseif caster:HasModifier("modifier_shrapnel_bullets") then
				caster:RemoveModifierByName("modifier_shrapnel_bullets")
				caster:AddNewModifier(caster, self, "modifier_normal_bullets", {})
			end
		else
			StopSoundOn("Ability.AssassinateLoad", caster)
		end
	end
end
function change_bullets_type:GetIntrinsicModifierName() return "modifier_change_bullets_type" end
modifier_change_bullets_type = class({})
function modifier_change_bullets_type:IsHidden() return true end
function modifier_change_bullets_type:IsPurgable() return true end
function modifier_change_bullets_type:RemoveOnDeath() return false end
function modifier_change_bullets_type:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_change_bullets_type:OnIntervalThink()
	if self:GetCaster():HasModifier("modifier_sniper_bullet") then
		self:GetAbility():SetActivated(true)
		self:GetCaster():FindAbilityByName("sniper_shoot"):SetActivated(true)
		self:GetCaster():FindAbilityByName("reload_bullet"):SetActivated(false)
	else
		self:GetAbility():SetActivated(false)
		self:GetCaster():FindAbilityByName("sniper_shoot"):SetActivated(false)
		self:GetCaster():FindAbilityByName("reload_bullet"):SetActivated(true)
	end
end


---------------------
-- Pocket Teleport --
---------------------
if pocket_portal == nil then pocket_portal = class({}) end
function pocket_portal:IsStealable() return false end
function pocket_portal:GetBehavior()
	if self:GetCaster():HasModifier("modifier_pocket_portal_duration") then
		Behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET
	elseif self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		Behavior = DOTA_ABILITY_BEHAVIOR_POINT
	else
		Behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
	return Behavior
end
function pocket_portal:GetCooldown(lvl)
	local BaseCD = self.BaseClass.GetCooldown(self, lvl) - talent_value(self:GetCaster(), "special_bonus_pocket_portal_cooldown")
	if pressed == false then return BaseCD / 2 end
	return BaseCD
end
function pocket_portal:GetCastRange(location, target)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then return 800 end
	return 0
end
function pocket_portal:GetCastPoint()
	if not self:GetCaster():HasModifier("modifier_pocket_portal_duration") then return self.BaseClass.GetCastPoint(self) else return 0 end
end
function pocket_portal:GetManaCost(lvl)
	if self:GetCaster():HasModifier("modifier_pocket_portal_duration") then return self.BaseClass.GetManaCost(self, lvl) else return 0 end
end
function pocket_portal:OnSpellStart()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_pocket_portal_duration") then
		caster:AddNewModifier(caster, self, "modifier_pocket_portal_duration", {duration = self:GetSpecialValueFor("duration")})
		if caster:HasModifier("modifier_item_aghanims_shard") then
			origin_point = self:GetCursorPosition()
		else
			origin_point = caster:GetAbsOrigin()
		end
		portal = ParticleManager:CreateParticle("particles/custom/abilities/heroes/sniper_pocket_portal/pocket_potral.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(portal, 0, origin_point)
		EmitSoundOnLocationWithCaster(origin_point, "Blink_Layer.Arcane", caster)
		self:EndCooldown()
		self:StartCooldown(0.5)
		pressed = false
	elseif caster:HasModifier("modifier_pocket_portal_duration") then
		pressed = true
		caster:RemoveModifierByName("modifier_pocket_portal_duration")
	end
end

modifier_pocket_portal_duration = class({})
function modifier_pocket_portal_duration:IsHidden() return false end
function modifier_pocket_portal_duration:IsPurgable() return false end
function modifier_pocket_portal_duration:RemoveOnDeath() return false end
function modifier_pocket_portal_duration:OnDestroy()
	local caster = self:GetCaster()
	if pressed then
--		EmitSoundOnLocationWithCaster(target_point, "DOTA_Item.BlinkDagger.Activate", caster)
		if caster:HasModifier("modifier_item_aghanims_shard") then
			ProjectileManager:ProjectileDodge(caster)
		end
		ParticleManager:CreateParticle("particles/custom/abilities/heroes/sniper_pocket_portal/pocket_potral_start.vpcf", PATTACH_ABSORIGIN, caster)
		caster:EmitSound("Blink_Layer.Swift")
		caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
--		caster:SetAbsOrigin(target_point)
		FindClearSpaceForUnit(caster, origin_point, false)

		local portal_end = ParticleManager:CreateParticle("particles/custom/abilities/heroes/sniper_pocket_portal/pocket_potral_end.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(portal_end, 0, caster:GetOrigin())
		ParticleManager:ReleaseParticleIndex(portal_end)

		if IsServer() then
			if caster:HasTalent("special_bonus_pocket_portal_evasion") then
				local Talent_Evasion = caster:AddNewModifier(caster, self:GetAbility(), "modifier_pocket_portal_evasion", {duration = caster:FindTalentCustomValue("special_bonus_pocket_portal_evasion", "duration")})
				Talent_Evasion:SetStackCount(self:GetCaster():FindTalentCustomValue("special_bonus_pocket_portal_evasion", "chance"))
			end
		end
	end

	if IsServer() then self:GetAbility():UseResources(false, false, true) end
	if portal then
		ParticleManager:DestroyParticle(portal, false)
		ParticleManager:ReleaseParticleIndex(portal)
	end
	pressed = nil
end

modifier_pocket_portal_evasion = class({})
function modifier_pocket_portal_evasion:IsHidden() return true end
function modifier_pocket_portal_evasion:IsPurgable() return true end
function modifier_pocket_portal_evasion:DeclareFunctions() return {MODIFIER_PROPERTY_EVASION_CONSTANT} end
function modifier_pocket_portal_evasion:GetModifierEvasion_Constant() return self:GetStackCount() end


---------------------
-- Kardel's Skills --
---------------------
kardels_skills = class({})
function kardels_skills:GetManaCost(lvl)
	return self:GetCaster():GetAgility() * self:GetSpecialValueFor("dmg_per_agility")
end
function kardels_skills:GetIntrinsicModifierName() return "modifier_kardels_skills" end
modifier_kardels_skills = class({})
function modifier_kardels_skills:IsHidden() return true end
function modifier_kardels_skills:IsPurgable() return true end
function modifier_kardels_skills:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA + 11111 end
function modifier_kardels_skills:DeclareFunctions() return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_kardels_skills:GetModifierBaseAttack_BonusDamage() return self:GetCaster():GetAgility() * (self:GetAbility():GetSpecialValueFor("dmg_per_agility") + talent_value(self:GetCaster(), "special_bonus_kardels_skills_dmg")) end
function modifier_kardels_skills:GetModifierAttackRangeBonus() return 550 end
function modifier_kardels_skills:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true}
end


------------------
-- Hunting Mark --
------------------
hunting_mark = class({})
function hunting_mark:GetCastRange(location, target)
	return self:GetCaster():Script_GetAttackRange() + self:GetSpecialValueFor("cast_range_buffer") - self:GetCaster():GetCastRangeBonus()
end
function hunting_mark:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(caster, self, "modifier_hunting_mark", {duration = self:GetSpecialValueFor("duration")})
	if RollPercentage(5) then
		EmitSoundOn("sniper_snip_spawn_03", caster)
	end
end

modifier_hunting_mark = class({})
function modifier_hunting_mark:IsHidden() return false end
function modifier_hunting_mark:IsPurgable() return true end
function modifier_hunting_mark:OnCreated()
	local effect_cast = ParticleManager:CreateParticleForTeam("particles/custom/abilities/heroes/kardel_hunting_mark/hunting_mark.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(effect_cast, false, false, -1, false, true)
end
function modifier_hunting_mark:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end
function modifier_hunting_mark:GetModifierProvidesFOWVision() return 1 end