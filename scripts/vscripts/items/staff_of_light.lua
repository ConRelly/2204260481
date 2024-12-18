--------------------
-- Staff of Light --
--------------------
if item_staff_of_light == nil then item_staff_of_light = class({}) end
LinkLuaModifier("modifier_staff_of_light", "items/staff_of_light.lua", LUA_MODIFIER_MOTION_NONE)
function item_staff_of_light:GetIntrinsicModifierName() return "modifier_staff_of_light" end
-- Staff of Light Modifier
modifier_staff_of_light = modifier_staff_of_light or class({})
function modifier_staff_of_light:IsHidden() return true end
function modifier_staff_of_light:IsPurgable() return false end
function modifier_staff_of_light:RemoveOnDeath() return false end
--function modifier_staff_of_light:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_staff_of_light:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:StartIntervalThink(1)
end end end
function modifier_staff_of_light:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_staff_of_light:GetModifierBonusStats_Strength()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 0 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light:GetModifierBonusStats_Agility()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 1 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light:GetModifierBonusStats_Intellect()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 2 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light:GetModifierConstantManaRegen() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end end
function modifier_staff_of_light:GetModifierHealthBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end end

function modifier_staff_of_light:OnIntervalThink()
	local caster = self:GetParent()
	if self:GetParent():IsRangedAttacker() then
		search_radius = self:GetAbility():GetSpecialValueFor("radius_ranged")
	else
		search_radius = self:GetAbility():GetSpecialValueFor("radius_melee")
	end
	local projectile_name = "particles/custom/items/staff_of_light/staff_of_light_wisp_attack.vpcf"
	local projectile_speed = self:GetAbility():GetSpecialValueFor("projectile_speed")

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	local target = nil
	for _,enemy in pairs(enemies) do
		if enemy:IsHero() then
			target = enemy
			break
		end
	end
	if not target then
		target = enemies[1]
	end
	if not target then
		return
	end
	local info = {
		Target = target,
		Source = caster,
		Ability = self:GetAbility(),
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,
		bVisibleToEnemies = true,
		bProvidesVision = false,
	}
	ProjectileManager:CreateTrackingProjectile(info)
	CastEffect(caster, target, projectile_speed)
end
function item_staff_of_light:OnProjectileHit(target, location)
	if not target then return end
	if not self:GetParent() then return end
	local radius = 0
	local damage = (self:GetParent():GetBaseDamageMin() + self:GetParent():GetBaseDamageMax()) / 2
	local creep_mult = 100--self:GetSpecialValueFor("creep_damage_pct")
	local damageTable = {
		attacker = self:GetParent(),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER	, false)
	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		damageTable.damage = damage
		if enemy:IsCreep() then
			damageTable.damage = damage * (creep_mult/100)
		end
		ApplyDamage(damageTable)
	end
end

----------------------
-- Staff of Light 2 --
----------------------
if item_staff_of_light_2 == nil then item_staff_of_light_2 = class({}) end
LinkLuaModifier("modifier_staff_of_light_2", "items/staff_of_light.lua", LUA_MODIFIER_MOTION_NONE)
function item_staff_of_light_2:GetIntrinsicModifierName() return "modifier_staff_of_light_2" end
-- Staff of Light 2 Modifier
modifier_staff_of_light_2 = modifier_staff_of_light_2 or class({})
function modifier_staff_of_light_2:IsHidden() return true end
function modifier_staff_of_light_2:IsPurgable() return false end
function modifier_staff_of_light_2:RemoveOnDeath() return false end
--function modifier_staff_of_light_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_staff_of_light_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:StartIntervalThink(1)
end end end
function modifier_staff_of_light_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_staff_of_light_2:GetModifierBonusStats_Strength()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 0 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light_2:GetModifierBonusStats_Agility()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 1 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light_2:GetModifierBonusStats_Intellect()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 2 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light_2:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_staff_of_light_2:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("hp") end

function modifier_staff_of_light_2:OnIntervalThink()
	local caster = self:GetParent()
	if self:GetParent():IsRangedAttacker() then
		search_radius = self:GetAbility():GetSpecialValueFor("radius_ranged")
	else
		search_radius = self:GetAbility():GetSpecialValueFor("radius_melee")
	end
	local projectile_name = "particles/custom/items/staff_of_light/staff_of_light_wisp_attack.vpcf"
	local projectile_speed = self:GetAbility():GetSpecialValueFor("projectile_speed")

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	local target = nil
	for _,enemy in pairs(enemies) do
		if enemy:IsHero() then
			target = enemy
			break
		end
	end
	if not target then
		target = enemies[1]
	end
	if not target then
		return
	end
	local info = {
		Target = target,
		Source = caster,
		Ability = self:GetAbility(),
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,
		bVisibleToEnemies = true,
		bProvidesVision = false,
	}
	ProjectileManager:CreateTrackingProjectile(info)
	CastEffect(caster, target, projectile_speed)
end
function item_staff_of_light_2:OnProjectileHit(target, location)
	if not target then return end
	if not self:GetParent() then return end
	local radius = 0
	local damage = (self:GetParent():GetBaseDamageMin() + self:GetParent():GetBaseDamageMax()) / 2
	local creep_mult = 100--self:GetSpecialValueFor("creep_damage_pct")
	local damageTable = {
		attacker = self:GetParent(),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER	, false)
	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		damageTable.damage = damage
		if enemy:IsCreep() then
			damageTable.damage = damage * (creep_mult/100)
		end
		ApplyDamage(damageTable)
	end
end

----------------------
-- Staff of Light 3 --
----------------------
if item_staff_of_light_3 == nil then item_staff_of_light_3 = class({}) end
LinkLuaModifier("modifier_staff_of_light_3", "items/staff_of_light.lua", LUA_MODIFIER_MOTION_NONE)
function item_staff_of_light_3:GetIntrinsicModifierName() return "modifier_staff_of_light_3" end
-- Staff of Light 3 Modifier
modifier_staff_of_light_3 = modifier_staff_of_light_3 or class({})
function modifier_staff_of_light_3:IsHidden() return true end
function modifier_staff_of_light_3:IsPurgable() return false end
function modifier_staff_of_light_3:RemoveOnDeath() return false end
--function modifier_staff_of_light_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_staff_of_light_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:StartIntervalThink(1)
end end end
function modifier_staff_of_light_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_staff_of_light_3:GetModifierBonusStats_Strength()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 0 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light_3:GetModifierBonusStats_Agility()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 1 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light_3:GetModifierBonusStats_Intellect()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 2 then
	return self:GetAbility():GetSpecialValueFor("primary_attribute") else return 0 end end
end
function modifier_staff_of_light_3:GetModifierConstantManaRegen() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end end
function modifier_staff_of_light_3:GetModifierHealthBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end end

function modifier_staff_of_light_3:OnIntervalThink()
	local caster = self:GetParent()
	if self:GetParent():IsRangedAttacker() then
		search_radius = self:GetAbility():GetSpecialValueFor("radius_ranged")
	else
		search_radius = self:GetAbility():GetSpecialValueFor("radius_melee")
	end
	local projectile_name = "particles/custom/items/staff_of_light/staff_of_light_wisp_attack.vpcf"
	local projectile_speed = self:GetAbility():GetSpecialValueFor("projectile_speed")

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	local target = nil
	for _,enemy in pairs(enemies) do
		if enemy:IsHero() then
			target = enemy
			break
		end
	end
	if not target then
		target = enemies[1]
	end
	if not target then
		return
	end
	local info = {
		Target = target,
		Source = caster,
		Ability = self:GetAbility(),
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,
		bVisibleToEnemies = true,
		bProvidesVision = false,
	}
	ProjectileManager:CreateTrackingProjectile(info)
	CastEffect(caster, target, projectile_speed)
end
function item_staff_of_light_3:OnProjectileHit(target, location)
	if not IsServer() then return end
	if not target then return end
	if not self:GetParent() then return end
	local caster = self:GetParent()
	local int = 0
	local ability = self
	if ability and IsValidEntity(ability) and caster:IsRealHero() then
		local int_to_dmg = ability:GetSpecialValueFor("int_bonus_damage")
		int = caster:GetIntellect(false) * caster:GetLevel() * int_to_dmg / 100
	end
	local radius = 0
	local damage = ((caster:GetBaseDamageMin() + caster:GetBaseDamageMax()) / 2) + int
	local creep_mult = 100--self:GetSpecialValueFor("creep_damage_pct")
	local damageTable = {
		attacker = caster,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER	, false)
	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		damageTable.damage = damage
		if enemy:IsCreep() then
			damageTable.damage = damage * (creep_mult/100)
		end
		ApplyDamage(damageTable)
	end
end



---------------------
-- Spirit Guardian --
---------------------
if item_spirit_guardian == nil then item_spirit_guardian = class({}) end
LinkLuaModifier("modifier_spirit_guardian", "items/staff_of_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spirit_guardian_heal", "items/staff_of_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spirit_guardian_heal_cd", "items/staff_of_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spirit_guardian_bonus_dmg", "items/staff_of_light.lua", LUA_MODIFIER_MOTION_NONE)
function item_spirit_guardian:GetIntrinsicModifierName() return "modifier_spirit_guardian" end
function item_spirit_guardian:OnSpellStart()
	if self:GetParent() ~= nil and not self:GetParent():HasModifier("modifier_spirit_guardian_heal_cd") then
		self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_spirit_guardian_heal", {duration = self:GetSpecialValueFor("guardian_heal_duration")})
	end
end
-- Spirit Guardian Modifier
modifier_spirit_guardian = modifier_spirit_guardian or class({})
function modifier_spirit_guardian:IsHidden() return true end
function modifier_spirit_guardian:IsPurgable() return false end
function modifier_spirit_guardian:RemoveOnDeath() return false end
--function modifier_spirit_guardian:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
local rollchance = 20 --"global" for moneky soliders. as long the player does unleqip the item the "luky" monkey/s will never rerol for start interval.
function modifier_spirit_guardian:OnCreated()
	if IsServer() then
		self.primary_attribute = self:GetAbility():GetSpecialValueFor("primary_attribute")
		self.secondary_stats = self:GetAbility():GetSpecialValueFor("secondary_stats")
		self.agi = self:GetAbility():GetSpecialValueFor("agi")
		self.str = self:GetAbility():GetSpecialValueFor("str")
		self.interval_attack = self:GetAbility():GetSpecialValueFor("interval_attack")
		local parent = self:GetParent()
		if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
			if parent:HasModifier("modifier_monkey_king_fur_army_soldier") then
				if RollPercentage(rollchance) then
					self:StartIntervalThink(self.interval_attack)
					self.pfx3 = ParticleManager:CreateParticle("particles/custom/items/staff_of_light/staff_of_light_ambient_core.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
					rollchance = rollchance / 2 --there's an way to rerol until all moneky have the spirit guardian, but takes time, this make that strat a lot harder
				end
			else
				self:StartIntervalThink(self.interval_attack)
				self.pfx3 = ParticleManager:CreateParticle("particles/custom/items/staff_of_light/staff_of_light_ambient_core.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())				
			end	
		end 
	end
end
function modifier_spirit_guardian:OnDestroy()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() and self.pfx3 ~= nil then
		DFX(self.pfx3, false)
--	ParticleManager:DestroyParticle(self.pfx3, false)
	end end
end
function modifier_spirit_guardian:OnRefresh()
	if IsServer() then
		local parent = self:GetParent()
		local attack_rate = self.interval_attack * parent:GetCooldownReduction()
		if parent:HasModifier("modifier_spirit_guardian_heal_cd") and HasSuperScepter(parent) then
			attack_rate = math.floor(attack_rate * 0.4 * 100 ) / 100 -- just so we don't have 14+ decimals numbers
		end	
		self:StartIntervalThink(attack_rate)
	end	
end
function modifier_spirit_guardian:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_FIXED_ATTACK_RATE}
end
function modifier_spirit_guardian:GetModifierBonusStats_Strength()
	if self:GetAbility() then if (self:GetParent():GetPrimaryAttribute() == 0 or self:GetParent():GetPrimaryAttribute() == 3) then
	return self.primary_attribute + self.str else return self.secondary_stats + self.str end end
end
function modifier_spirit_guardian:GetModifierBonusStats_Agility()
	if self:GetAbility() then if (self:GetParent():GetPrimaryAttribute() == 1 or self:GetParent():GetPrimaryAttribute() == 3) then
	return self.primary_attribute + self.agi else return self.secondary_stats + self.agi end end
end
function modifier_spirit_guardian:GetModifierBonusStats_Intellect()
	if self:GetAbility() then if (self:GetParent():GetPrimaryAttribute() == 2 or self:GetParent():GetPrimaryAttribute() == 3) then
	return self.primary_attribute else return self.secondary_stats end end
end
function modifier_spirit_guardian:GetModifierConstantManaRegen() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end end
function modifier_spirit_guardian:GetModifierHealthBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end end
function modifier_spirit_guardian:GetModifierAttackRangeBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_range") end end
function modifier_spirit_guardian:GetModifierFixedAttackRate() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("fixed_attack_rate") end end

function modifier_spirit_guardian:OnIntervalThink()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	if not self:GetParent():IsAlive() then return end
	local caster = self:GetParent()
	local search_radius = self:GetParent():Script_GetAttackRange() + self:GetAbility():GetSpecialValueFor("range_buffer")
	local projectile_name = "particles/custom/items/staff_of_light/staff_of_light_wisp_attack.vpcf"
	local projectile_speed = self:GetAbility():GetSpecialValueFor("projectile_speed")
	local heal = ((self:GetParent():GetBaseDamageMin() + self:GetParent():GetBaseDamageMax()) / 2)
	if caster:HasModifier("modifier_spirit_guardian_bonus_dmg") then
		local mod = caster:FindModifierByName("modifier_spirit_guardian_bonus_dmg")
		if mod then
			heal = ((self:GetParent():GetBaseDamageMin() + self:GetParent():GetBaseDamageMax()) / 2) + mod:GetStackCount()
		end
	end
	if self:GetParent():HasModifier("modifier_spirit_guardian_heal") then
		local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, search_radius,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		local target = self:GetParent()
		for _,ally in pairs(allies) do
			local mh_pct_ally = math.floor(ally:GetHealth() / (ally:GetMaxHealth() * 0.01))
			local mh_pct_target = math.floor(target:GetHealth() / (target:GetMaxHealth() * 0.01))
			if mh_pct_target > mh_pct_ally then
				target = ally
			end
		end
		if self:GetParent():GetHealth() ~= self:GetParent():GetMaxHealth() then
			target = self:GetParent()
		end
		if target:GetHealth() ~= target:GetMaxHealth() then
			target:Heal(heal, self:GetParent())
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, nil)
		end
	else
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
		local target = nil
		for _,enemy in pairs(enemies) do
			if enemy:IsHero() then
				target = enemy
				break
			end
		end
		if not target then
			target = enemies[1]
		end
		if not target then
			return
		end
		local info = {
			Target = target,
			Source = caster,
			Ability = self:GetAbility(),
			EffectName = projectile_name,
			iMoveSpeed = projectile_speed,
			bDodgeable = true,
			bVisibleToEnemies = true,
			bProvidesVision = false,
		}
		ProjectileManager:CreateTrackingProjectile(info)
		CastEffect(caster, target, projectile_speed)
		self:OnRefresh()
	end
end
function item_spirit_guardian:OnProjectileHit(target, location)
	if not target then return end
	if not self:GetParent() then return end
	local parent = self:GetParent()
	local bonus_int = 0
	local bonus_dmg = 0
	local stacks = 0
	local lvl = parent:GetLevel()
	local chance = math.floor(lvl / 2)
	local base_dmg = ((parent:GetBaseDamageMin() + parent:GetBaseDamageMax()) / 2)
	if IsServer() then
		if parent:HasModifier("modifier_spirit_guardian_bonus_dmg") then
			local modif = parent:FindModifierByName("modifier_spirit_guardian_bonus_dmg")
			if modif then
				modif:IncrementStackCount()
				if RollPercentage(chance) then
					modif:IncrementStackCount()
				end
				stacks = modif:GetStackCount()
				bonus_dmg = lvl * stacks	
			end
			--Monkey soliders they don't update their stacks on summon,probably(unless you unequip the item)
			if parent:HasModifier("modifier_monkey_king_fur_army_soldier") then
				local mod1 = "modifier_spirit_guardian_bonus_dmg"
				local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
				if owner then	  
					local modifier1 = parent:FindModifierByName(mod1)
					if owner:HasModifier(mod1) then
						local modifier2 = owner:FindModifierByName(mod1)
						modifier1:SetStackCount(modifier2:GetStackCount())
					end	
				end		
			end			
		else
			if parent and IsValidEntity(parent) and parent:IsAlive() then
				parent:AddNewModifier(parent, self, "modifier_spirit_guardian_bonus_dmg", {})
				if parent:HasModifier("modifier_spirit_guardian_bonus_dmg") then
					local mod1 = "modifier_spirit_guardian_bonus_dmg"
					local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
					if owner then	  
						local modifier1 = parent:FindModifierByName(mod1)
						if owner:HasModifier(mod1) then
							local modifier2 = owner:FindModifierByName(mod1)
							modifier1:SetStackCount(modifier2:GetStackCount())
						end	
					end		
				end
			end				
		end
		if HasSuperScepter(parent) then
			local int_to_dmg = self:GetSpecialValueFor("bonus_int_dmg")
			bonus_int = math.floor(parent:GetIntellect(false) * lvl * int_to_dmg / 100)
			local stacks_mult = math.floor(base_dmg / 100) / 200 + 1
			if stacks_mult < 1 then
				stacks_mult = 1
			elseif stacks_mult > 12 then
				stacks_mult = 12	
			end	
			if stacks > 1 then
				stacks = math.floor(stacks * stacks_mult)
				bonus_dmg = lvl * stacks
			end	
		end
	end
	local radius = 0
	local damage = base_dmg + bonus_int + bonus_dmg
	--local creep_mult = 100--self:GetSpecialValueFor("creep_damage_pct")
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER	, false)
	for _,enemy in pairs(enemies) do
		--if enemy:IsCreep() then
		--	damageTable.damage = damage * (creep_mult/100)
		--end
		ApplyDamage({
			victim = enemy,
			attacker = self:GetParent(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
		})
		if IsServer() then
			if HasSuperScepter(self:GetParent()) then
				self:GetParent():PerformAttack(enemy, true, true, true, false, true, false, true)
			end
		end
	end
end
-- Defense Mode
if modifier_spirit_guardian_heal == nil then modifier_spirit_guardian_heal = class({}) end
function modifier_spirit_guardian_heal:IsHidden() return false end
function modifier_spirit_guardian_heal:IsDebuff() return false end
function modifier_spirit_guardian_heal:IsPurgable() return false end
function modifier_spirit_guardian_heal:RemoveOnDeath() return false end
function modifier_spirit_guardian_heal:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.avoid_chance = 0
		local parent = self:GetParent()
		if parent:IsRealHero() and (parent:GetPrimaryAttribute() == 2 or parent:GetPrimaryAttribute() == 3) then
			self.avoid_chance = self:GetAbility():GetSpecialValueFor("avoid_chance")
		end
	end
end
function modifier_spirit_guardian_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_AVOID_DAMAGE}
end
function modifier_spirit_guardian_heal:GetModifierAvoidDamage(params)
	if IsServer() then
		if RollPercentage(self.avoid_chance) then
			local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:ReleaseParticleIndex(iParticleID)
			return 1
		end
	end
end
function modifier_spirit_guardian_heal:OnDestroy()
	if IsServer() then	
		if self:GetAbility() then	
			if self:GetParent() ~= nil and self:GetParent():IsAlive() and not self:GetParent():IsIllusion() then
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_spirit_guardian_heal_cd", {duration = self:GetAbility():GetSpecialValueFor("internal_cd")})
			end
		end
	end
end

if modifier_spirit_guardian_heal_cd == nil then modifier_spirit_guardian_heal_cd = class({}) end
function modifier_spirit_guardian_heal_cd:IsHidden() return false end
function modifier_spirit_guardian_heal_cd:IsDebuff() return true end
function modifier_spirit_guardian_heal_cd:IsPurgable() return false end
function modifier_spirit_guardian_heal_cd:RemoveOnDeath() return false end

if modifier_spirit_guardian_bonus_dmg == nil then modifier_spirit_guardian_bonus_dmg = class({}) end
function modifier_spirit_guardian_bonus_dmg:IsHidden() return false end
function modifier_spirit_guardian_bonus_dmg:IsDebuff() return true end
function modifier_spirit_guardian_bonus_dmg:IsPurgable() return false end
function modifier_spirit_guardian_bonus_dmg:RemoveOnDeath() return false end

function CastEffect(caster, target, projectile_speed)
	local particle_cast = "particles/custom/items/staff_of_light/staff_of_light_wisp_preattack.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(projectile_speed, 0, 0))
	ParticleManager:ReleaseParticleIndex(effect_cast)
end
function FailureEffect(caster)
	local particle_cast = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_failure.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end
