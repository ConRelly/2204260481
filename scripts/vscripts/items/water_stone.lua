-----------------
-- WATER STONE --
-----------------
LinkLuaModifier("modifier_water_stone_1", "items/water_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_water_stone_1_aura", "items/water_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_water_stone == nil then item_water_stone = class({}) end
function item_water_stone:GetIntrinsicModifierName() return "modifier_water_stone_1" end

if modifier_water_stone_1 == nil then modifier_water_stone_1 = class({}) end
function modifier_water_stone_1:IsHidden() return true end
function modifier_water_stone_1:IsPurgable() return false end
function modifier_water_stone_1:RemoveOnDeath() return false end
function modifier_water_stone_1:IsAura() return true end
function modifier_water_stone_1:IsAuraActiveOnDeath() return false end
function modifier_water_stone_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_water_stone_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_water_stone_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_water_stone_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_water_stone_1:GetAuraDuration() return FrameTime() end
function modifier_water_stone_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_water_stone_1:GetModifierAura() return "modifier_water_stone_1_aura" end
----------------------
-- WATER STONE AURA --
----------------------
if modifier_water_stone_1_aura == nil then modifier_water_stone_1_aura = class({}) end
function modifier_water_stone_1_aura:IsHidden() return false end
function modifier_water_stone_1_aura:IsDebuff() return false end
function modifier_water_stone_1_aura:IsPurgable() return false end
function modifier_water_stone_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_stone_1_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_water_stone_1_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int_aura") end
end
function modifier_water_stone_1_aura:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi_aura") end
end
function modifier_water_stone_1_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end

-------------------
-- WATER STONE 2 --
-------------------
LinkLuaModifier("modifier_water_stone_2", "items/water_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_water_stone_2_aura", "items/water_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_water_stone_2 == nil then item_water_stone_2 = class({}) end
function item_water_stone_2:GetIntrinsicModifierName() return "modifier_water_stone_2" end

if modifier_water_stone_2 == nil then modifier_water_stone_2 = class({}) end
function modifier_water_stone_2:IsHidden() return true end
function modifier_water_stone_2:IsPurgable() return false end
function modifier_water_stone_2:RemoveOnDeath() return false end
function modifier_water_stone_2:IsAura() return true end
function modifier_water_stone_2:IsAuraActiveOnDeath() return false end
function modifier_water_stone_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_water_stone_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_water_stone_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_water_stone_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_water_stone_2:GetAuraDuration() return FrameTime() end
function modifier_water_stone_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_water_stone_2:GetModifierAura() return "modifier_water_stone_2_aura" end
------------------------
-- WATER STONE 2 AURA --
------------------------
if modifier_water_stone_2_aura == nil then modifier_water_stone_2_aura = class({}) end
function modifier_water_stone_2_aura:IsHidden() return false end
function modifier_water_stone_2_aura:IsDebuff() return false end
function modifier_water_stone_2_aura:IsPurgable() return false end
function modifier_water_stone_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_stone_2_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_water_stone_2_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int_aura") end
end
function modifier_water_stone_2_aura:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi_aura") end
end
function modifier_water_stone_2_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end

-------------------
-- WATER STONE 3 --
-------------------
LinkLuaModifier("modifier_water_stone_3", "items/water_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_water_stone_3_aura", "items/water_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_water_stone_3 == nil then item_water_stone_3 = class({}) end
function item_water_stone_3:GetIntrinsicModifierName() return "modifier_water_stone_3" end

if modifier_water_stone_3 == nil then modifier_water_stone_3 = class({}) end
function modifier_water_stone_3:IsHidden() return true end
function modifier_water_stone_3:IsPurgable() return false end
function modifier_water_stone_3:RemoveOnDeath() return false end
function modifier_water_stone_3:IsAura() return true end
function modifier_water_stone_3:IsAuraActiveOnDeath() return false end
function modifier_water_stone_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_water_stone_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_water_stone_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_water_stone_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_water_stone_3:GetAuraDuration() return FrameTime() end
function modifier_water_stone_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_water_stone_3:GetModifierAura() return "modifier_water_stone_3_aura" end
------------------------
-- WATER STONE 3 AURA --
------------------------
if modifier_water_stone_3_aura == nil then modifier_water_stone_3_aura = class({}) end
function modifier_water_stone_3_aura:IsHidden() return false end
function modifier_water_stone_3_aura:IsDebuff() return false end
function modifier_water_stone_3_aura:IsPurgable() return false end
function modifier_water_stone_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_stone_3_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_water_stone_3_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int_aura") end
end
function modifier_water_stone_3_aura:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi_aura") end
end
function modifier_water_stone_3_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end

-------------------------
-- ABYSSAL WATER BLADE --
-------------------------
item_abyssal_water_blade = item_abyssal_water_blade or class({})
LinkLuaModifier("modifier_abyssal_water_blade", "items/water_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_water_blade_aura", "items/water_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_water_blade_internal_cd", "items/water_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_water_blade_bash", "items/water_stone", LUA_MODIFIER_MOTION_NONE)
function item_abyssal_water_blade:GetIntrinsicModifierName() return "modifier_abyssal_water_blade" end
function item_abyssal_water_blade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local particle_abyssal = "particles/items_fx/abyssal_blade.vpcf"
	local active_stun_duration = self:GetSpecialValueFor("active_stun_duration")
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if target:TriggerSpellAbsorb(self) then
			return nil
		end
	end
	if self:GetCaster():HasModifier("modifier_slark_pounce") then
		self:GetCaster():FindModifierByName("modifier_slark_pounce"):Destroy()
	end
	target:EmitSound("DOTA_Item.AbyssalBlade.Activate")
	target:EmitSoundParams("Hero_MonkeyKing.Spring.Water", 1, 0.5, 0)
	local blink_start_particle = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_start_ti7_lvl2.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_start_particle)
	FindClearSpaceForUnit(self:GetCaster(), target:GetAbsOrigin() - self:GetCaster():GetForwardVector() * 56, false)
	local blink_end_particle = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_end_ti7_lvl2.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_end_particle)

	local particle_abyssal_fx = ParticleManager:CreateParticle(particle_abyssal, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_abyssal_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_abyssal_fx)

	caster:AddNewModifier(caster, self, "modifier_abyssal_water_blade_internal_cd", {duration = active_stun_duration * (1 - target:GetStatusResistance())})
	target:AddNewModifier(caster, self, "modifier_abyssal_water_blade_bash", {duration = active_stun_duration * (1 - target:GetStatusResistance())})
end

modifier_abyssal_water_blade = modifier_abyssal_water_blade or class({})
function modifier_abyssal_water_blade:IsHidden() return true end
function modifier_abyssal_water_blade:IsPurgable() return false end
function modifier_abyssal_water_blade:RemoveOnDeath() return false end
function modifier_abyssal_water_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_abyssal_water_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
end
function modifier_abyssal_water_blade:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_abyssal_water_blade:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_abyssal_water_blade:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_hp_regen") end
end
function modifier_abyssal_water_blade:GetModifierPhysical_ConstantBlock()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("block_damage")
	end
end
function modifier_abyssal_water_blade:OnAttack(keys)
	if self:GetAbility() and
	keys.attacker == self:GetParent() and
	keys.attacker:FindAllModifiersByName(self:GetName())[1] == self and
	not keys.target:IsBuilding() and
	not keys.target:IsOther() and
	not keys.attacker:IsIllusion() and
	not keys.attacker:HasModifier("modifier_abyssal_water_blade_internal_cd") and
	not keys.attacker:HasModifier("modifier_monkey_king_fur_army_soldier") and
	not keys.attacker:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") and
	not keys.attacker:HasAbility("faceless_void_time_lock") and
	not keys.attacker:HasAbility("spirit_breaker_greater_bash") and
	not keys.attacker:HasAbility("slardar_bash") then
		if self:GetParent():IsRangedAttacker() then
			if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("bash_chance_ranged"), self) then
				self.bash_proc = true
			end
		else
			if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("bash_chance_melee"), self) then
				self.bash_proc = true
			end
		end
	end
end
function modifier_abyssal_water_blade:OnAttackLanded(keys)
	if self:GetAbility() and keys.attacker == self:GetParent() and self.bash_proc then
		local target = keys.target
		local owner = self:GetCaster()
		local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
		local internal_bash_cd = self:GetAbility():GetSpecialValueFor("internal_bash_cd")
		self.bash_proc = false
		bash_fx = ParticleManager:CreateParticle("particles/custom/items/abyssal_water_blade/abyssal_bash.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
		ParticleManager:SetParticleControlEnt(bash_fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(bash_fx, 1, keys.attacker, PATTACH_ABSORIGIN, "attach_hitloc", keys.attacker:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(bash_fx, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		target:EmitSound("DOTA_Item.SkullBasher")
		target:EmitSoundParams("Hero_MonkeyKing.Spring.Water", 1, 0.5, 0)
		local bash_incdmg = 0
		local up = false
		if owner:HasModifier("modifier_skadi_bow") and owner:HasModifier("modifier_abyssal_water_blade") then
			local up_bash_cd = self:GetAbility():GetSpecialValueFor("up_bash_cd")
			local up_stun_duration = self:GetAbility():GetSpecialValueFor("up_stun_duration")
			local up_bash_incdmg = self:GetAbility():GetSpecialValueFor("up_bash_incdmg")
			up = true
			bash_incdmg = up_bash_incdmg
			internal_bash_cd = self:GetAbility():GetSpecialValueFor("internal_bash_cd") * ((100 - up_bash_cd) / 100)
			stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration") * ((100 + up_stun_duration) / 100)
		end
		self:GetParent():AddNewModifier(owner, self:GetAbility(), "modifier_abyssal_water_blade_internal_cd", {duration = internal_bash_cd})
		target:AddNewModifier(owner, self:GetAbility(), "modifier_abyssal_water_blade_bash", {duration = stun_duration * (1 - target:GetStatusResistance())})
	end
end
function modifier_abyssal_water_blade:GetModifierProcAttack_BonusDamage_Physical()
	if self:GetAbility() and self.bash_proc then return self:GetAbility():GetSpecialValueFor("bash_damage") end
end
function modifier_abyssal_water_blade:IsAura() return true end
function modifier_abyssal_water_blade:IsAuraActiveOnDeath() return false end
function modifier_abyssal_water_blade:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_abyssal_water_blade:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_abyssal_water_blade:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_abyssal_water_blade:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_abyssal_water_blade:GetAuraDuration() return FrameTime() end
function modifier_abyssal_water_blade:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_abyssal_water_blade:GetModifierAura() return "modifier_abyssal_water_blade_aura" end
------------------------------
-- ABYSSAL WATER BLADE AURA --
------------------------------
if modifier_abyssal_water_blade_aura == nil then modifier_abyssal_water_blade_aura = class({}) end
function modifier_abyssal_water_blade_aura:IsHidden() return false end
function modifier_abyssal_water_blade_aura:IsDebuff() return false end
function modifier_abyssal_water_blade_aura:IsPurgable() return false end
function modifier_abyssal_water_blade_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_abyssal_water_blade_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_abyssal_water_blade_aura:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_aura") end
end
function modifier_abyssal_water_blade_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_aura") end
end
function modifier_abyssal_water_blade_aura:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_aura") end
end
function modifier_abyssal_water_blade_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end

------------------------------
-- ABYSSAL WATER BLADE BASH --
------------------------------
modifier_abyssal_water_blade_bash = modifier_abyssal_water_blade_bash or class({})
function modifier_abyssal_water_blade_bash:IsHidden() return false end
function modifier_abyssal_water_blade_bash:IsPurgeException() return true end
function modifier_abyssal_water_blade_bash:IsStunDebuff() return true end
function modifier_abyssal_water_blade_bash:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_abyssal_water_blade_bash:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_abyssal_water_blade_bash:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_abyssal_water_blade_bash:OnCreated(keys)
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_abyssal_water_blade_bash:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,  MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_abyssal_water_blade_bash:OnTakeDamage(params)
	if IsServer() then
		local unit = self:GetParent()
		local attacker = params.attacker
		if attacker:HasModifier("modifier_skadi_bow") and attacker:HasModifier("modifier_abyssal_water_blade") then
			if unit:HasModifier("modifier_abyssal_water_blade_bash") and unit:HasModifier("modifier_skadi_bow_slow_debuff") then
			local up_bash_incdmg = self:GetAbility():GetSpecialValueFor("up_bash_incdmg")
				if attacker == self:GetCaster() and
				attacker:IsRealHero() and
--				not attacker:IsIllusion() and
--				not attacker:IsTempestDouble() and
				unit:IsAlive() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
					local damageTable = params.original_damage * (up_bash_incdmg / 100)
					if unit and unit ~= attacker and unit:GetTeamNumber() ~= attacker:GetTeamNumber() then
						if params.damage_type == 1 then
							ApplyDamage({victim = unit, damage = damageTable, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = params.damage_flags + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, attacker = attacker, ability = self:GetAbility()})
						end
					end
				end
			end
		end
	end
end
function modifier_abyssal_water_blade_bash:GetOverrideAnimation() return ACT_DOTA_DISABLED end

-------------------------------
--ABYSSAL WATER BLADE BASH CD--
-------------------------------
modifier_abyssal_water_blade_internal_cd = modifier_abyssal_water_blade_internal_cd or class({})
function modifier_abyssal_water_blade_internal_cd:IsHidden() return true end
function modifier_abyssal_water_blade_internal_cd:IgnoreTenacity() return true end
function modifier_abyssal_water_blade_internal_cd:IsPurgable() return false end
function modifier_abyssal_water_blade_internal_cd:IsDebuff() return true end
function modifier_abyssal_water_blade_internal_cd:RemoveOnDeath() return false end
