LinkLuaModifier("willpower_heal", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_divinity_activated", "heroes/hero_piety/divine_cancel", LUA_MODIFIER_MOTION_NONE)
-- Buffs
LinkLuaModifier("willpower_health_regen", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_health_regen_pct", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_mana_regen", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_mana_regen_pct", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_base_attack_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_attack_speed_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_attack_speed_pct_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_movement_speed_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_movement_speed_pct_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_cdr", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_armor_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_magic_armor_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_status_resist_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_evasion_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_incoming_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_outgoing_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_spell_amp_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_lifesteal_pure", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_lifesteal", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_spell_lifesteal_pure", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_spell_lifesteal", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
-- Debuffs
LinkLuaModifier("willpower_health_regen_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_health_amp_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_mana_regen_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_mana_regen_pct_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_base_attack_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_attack_speed_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_attack_speed_pct_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_movement_speed_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_movement_speed_pct_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_cdi", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_armor_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_magic_armor_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_status_resist_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_evasion_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_incoming_inc", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_outgoing_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_spell_amp_red", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_miss_chance", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("willpower_hp_drain", "heroes/hero_piety/willpower", LUA_MODIFIER_MOTION_NONE)


willpower = class({})
--function willpower:ProcsMagicStick() return false end
function willpower:GetManaCost(level)
	local ManaCost = self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("health_sacrifice") / 100
	return ManaCost
end
function willpower:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		if target:TriggerSpellAbsorb(self) then return end

		local health_sacrifice = self:GetSpecialValueFor("health_sacrifice")
		local duration = self:GetSpecialValueFor("duration")
		local damage = caster:GetMaxHealth() * health_sacrifice / 100

		if caster:HasTalent("special_bonus_unique_willpower_separate") then
			if target:GetTeamNumber() == caster:GetTeamNumber() then
				damage = damage * talent_value(caster, "special_bonus_unique_willpower_separate") / 100
				if caster:GetHealth() > damage then
					caster:SetHealth(caster:GetHealth() - damage)
				else
					caster:SetHealth(1)
				end
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, caster, damage, nil)
				damage = damage * (1 - (talent_value(caster, "special_bonus_unique_willpower_separate") / 100))
			end
		end

		if target:GetHealth() > damage then
			target:SetHealth(target:GetHealth() - damage)
		else
			if target ~= caster then
				target:Kill(self, caster)
			else
				caster:SetHealth(1)
			end
		end
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage, nil)

		local void_pfx = ParticleManager:CreateParticle("particles/custom/abilities/willpower/willpower.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(void_pfx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(void_pfx, 1, Vector(100, 0, 0))
		ParticleManager:SetParticleControlEnt(void_pfx, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(void_pfx)
		EmitSoundOn("Willpower_Damage", target)

		target:AddNewModifier(caster, self, "willpower_heal", {duration = duration})

		if caster:HasModifier("modifier_divinity_activated") then
			local Roll = RollPercentage(70)
			if target:GetTeamNumber() == caster:GetTeamNumber() then
				if Roll then
					RandomModifier = TakeBuff()
				else
					RandomModifier = TakeDebuff()
				end
			else
				if Roll then
					RandomModifier = TakeDebuff()
				else
					RandomModifier = TakeBuff()
				end
			end
			target:AddNewModifier(caster, self, RandomModifier, {duration = duration})
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
willpower_heal = class({})
function willpower_heal:IsHidden() return false end
function willpower_heal:IsPurgable() return true end
function willpower_heal:RemoveOnDeath() return true end
function willpower_heal:IsDebuff() return false end
function willpower_heal:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.interval = FrameTime()
		self:StartIntervalThink(self.interval)
	end
end
function willpower_heal:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local heal_pct = self:GetAbility():GetSpecialValueFor("health_sacrifice")
		local heal_duration = self:GetAbility():GetSpecialValueFor("duration")
		local heal_per_interval = parent:GetMaxHealth() * heal_pct / heal_duration / 100 * self.interval
		if parent:GetTeamNumber() ~= caster:GetTeamNumber() then
			heal_per_interval = parent:GetMaxHealth() * heal_pct / heal_duration / 150 * self.interval
		end

		parent:Heal(heal_per_interval, caster)
	end
end
function willpower_heal:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function willpower_heal:OnTooltip() return self:GetAbility():GetSpecialValueFor("health_sacrifice") end

------------------------------------------------------------------------------------------------------------------------
function TakeBuff()
	local ModifierList = {
		"willpower_health_regen",				-- HP Regen Increase
		"willpower_health_regen_pct",			-- HP Regen Percent Increase
		"willpower_mana_regen",					-- Mana Regen Increase
		"willpower_mana_regen_pct",				-- Mana Regen Percent Increase
		"willpower_base_attack_inc",			-- Attack Damage Increase
		"willpower_attack_speed_inc",			-- Attack Speed Increase
		"willpower_attack_speed_pct_inc",		-- Attack Speed Percent Increase
		"willpower_movement_speed_inc",			-- Movement Speed Increase
		"willpower_movement_speed_pct_inc",		-- Movement Speed Percent Increase
		"willpower_cdr",						-- Cooldown Reduction
		"willpower_armor_inc",					-- Armor Increase
		"willpower_magic_armor_inc",			-- Magic Resist Increase
		"willpower_status_resist_inc",			-- Status Resist Increase
		"willpower_evasion_inc",				-- Evasion Increase
		"willpower_incoming_red",				-- Incoming Damage Reduction
		"willpower_outgoing_inc",				-- Outgoing Damage Increase
		"willpower_spell_amp_inc",				-- Spell Damage Increase
		"willpower_lifesteal_pure",				-- Pure Lifesteal Increase
		"willpower_lifesteal",					-- Lifesteal Increase
		"willpower_spell_lifesteal_pure",		-- Spell Lifesteal Increase
		"willpower_spell_lifesteal",			-- Pure Spell Lifesteal Increase
	}
	local Roll = RandomInt(1, #ModifierList)
	return ModifierList[Roll]
end

function TakeDebuff()
	local ModifierList = {
		"willpower_health_regen_red",			-- HP Regen Reduction
		"willpower_health_amp_red",				-- HP Regen Amp Reduction
		"willpower_mana_regen_red",				-- Mana Regen Reduction
		"willpower_mana_regen_pct_red",			-- Mana Regen Percent Reduction
		"willpower_base_attack_red",			-- Attack Damage Reduction
		"willpower_attack_speed_red",			-- Attack Speed Reduction
		"willpower_attack_speed_pct_red",		-- Attack Speed Percent Reduction
		"willpower_movement_speed_red",			-- Movement Speed Reduction
		"willpower_movement_speed_pct_red",		-- Movement Speed Percent Reduction
		"willpower_cdi",						-- Cooldown Increase
		"willpower_armor_red",					-- Armor Reduction
		"willpower_magic_armor_red",			-- Magic Resist Reduction
		"willpower_status_resist_red",			-- Status Resist Reduction
		"willpower_evasion_red",				-- Evasion Reduction
		"willpower_incoming_inc",				-- Incoming Damage Increase
		"willpower_outgoing_red",				-- Outgoing Damage Reduction
		"willpower_spell_amp_red",				-- Spell Damage Reduction
		"willpower_miss_chance",				-- Miss Chance
		"willpower_hp_drain",					-- HP Drain
	}
	local Roll = RandomInt(1, #ModifierList)
	return ModifierList[Roll]
end







---------------------------------------------------------------------------------------------------------------------------
------------------------------------POSITIVE-------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

if willpower_health_regen == nil then willpower_health_regen = class({}) end
function willpower_health_regen:IsHidden() return false end
function willpower_health_regen:IsDebuff() return false end
function willpower_health_regen:IsPurgable() return false end
function willpower_health_regen:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetHealthRegen() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100))
	end
end
function willpower_health_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function willpower_health_regen:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_health_regen_pct == nil then willpower_health_regen_pct = class({}) end
function willpower_health_regen_pct:IsHidden() return false end
function willpower_health_regen_pct:IsDebuff() return false end
function willpower_health_regen_pct:IsPurgable() return false end
function willpower_health_regen_pct:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end
function willpower_health_regen_pct:GetModifierHealthRegenPercentage()
	if self:GetAbility() then return 2.5 end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_mana_regen == nil then willpower_mana_regen = class({}) end
function willpower_mana_regen:IsHidden() return false end
function willpower_mana_regen:IsDebuff() return false end
function willpower_mana_regen:IsPurgable() return false end
function willpower_mana_regen:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetManaRegen() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100))
	end
end
function willpower_mana_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function willpower_mana_regen:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_mana_regen_pct == nil then willpower_mana_regen_pct = class({}) end
function willpower_mana_regen_pct:IsHidden() return false end
function willpower_mana_regen_pct:IsDebuff() return false end
function willpower_mana_regen_pct:IsPurgable() return false end
function willpower_mana_regen_pct:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE}
end
function willpower_mana_regen_pct:GetModifierTotalPercentageManaRegen()
	if self:GetAbility() then return 2.5 end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_base_attack_inc == nil then willpower_base_attack_inc = class({}) end
function willpower_base_attack_inc:IsHidden() return false end
function willpower_base_attack_inc:IsDebuff() return false end
function willpower_base_attack_inc:IsPurgable() return false end
function willpower_base_attack_inc:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetAttackDamage() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100))
	end
end
function willpower_base_attack_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function willpower_base_attack_inc:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_attack_speed_inc == nil then willpower_attack_speed_inc = class({}) end
function willpower_attack_speed_inc:IsHidden() return false end
function willpower_attack_speed_inc:IsDebuff() return false end
function willpower_attack_speed_inc:IsPurgable() return false end
function willpower_attack_speed_inc:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetDisplayAttackSpeed() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100))
	end
end
function willpower_attack_speed_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function willpower_attack_speed_inc:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_attack_speed_pct_inc == nil then willpower_attack_speed_pct_inc = class({}) end
function willpower_attack_speed_pct_inc:IsHidden() return false end
function willpower_attack_speed_pct_inc:IsDebuff() return false end
function willpower_attack_speed_pct_inc:IsPurgable() return false end
function willpower_attack_speed_pct_inc:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_attack_speed_pct_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
end
function willpower_attack_speed_pct_inc:GetModifierAttackSpeedPercentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_movement_speed_inc == nil then willpower_movement_speed_inc = class({}) end
function willpower_movement_speed_inc:IsHidden() return false end
function willpower_movement_speed_inc:IsDebuff() return false end
function willpower_movement_speed_inc:IsPurgable() return false end
function willpower_movement_speed_inc:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetBaseMoveSpeed() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100))
	end
end
function willpower_movement_speed_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function willpower_movement_speed_inc:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_movement_speed_pct_inc == nil then willpower_movement_speed_pct_inc = class({}) end
function willpower_movement_speed_pct_inc:IsHidden() return false end
function willpower_movement_speed_pct_inc:IsDebuff() return false end
function willpower_movement_speed_pct_inc:IsPurgable() return false end
function willpower_movement_speed_pct_inc:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_movement_speed_pct_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function willpower_movement_speed_pct_inc:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_cdr == nil then willpower_cdr = class({}) end
function willpower_cdr:IsHidden() return false end
function willpower_cdr:IsDebuff() return false end
function willpower_cdr:IsPurgable() return false end
function willpower_cdr:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_cdr:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end
function willpower_cdr:GetModifierPercentageCooldown()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_armor_inc == nil then willpower_armor_inc = class({}) end
function willpower_armor_inc:IsHidden() return false end
function willpower_armor_inc:IsDebuff() return false end
function willpower_armor_inc:IsPurgable() return false end
function willpower_armor_inc:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetPhysicalArmorValue(false) * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100))
	end
end
function willpower_armor_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function willpower_armor_inc:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_magic_armor_inc == nil then willpower_magic_armor_inc = class({}) end
function willpower_magic_armor_inc:IsHidden() return false end
function willpower_magic_armor_inc:IsDebuff() return false end
function willpower_magic_armor_inc:IsPurgable() return false end
function willpower_magic_armor_inc:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetMagicalArmorValue() * self:GetAbility():GetSpecialValueFor("modifier_affect")))
	end
end
function willpower_magic_armor_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function willpower_magic_armor_inc:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_status_resist_inc == nil then willpower_status_resist_inc = class({}) end
function willpower_status_resist_inc:IsHidden() return false end
function willpower_status_resist_inc:IsDebuff() return false end
function willpower_status_resist_inc:IsPurgable() return false end
function willpower_status_resist_inc:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetStatusResistance() * self:GetAbility():GetSpecialValueFor("modifier_affect")))
	end
end
function willpower_status_resist_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end
function willpower_status_resist_inc:GetModifierStatusResistanceStacking()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_evasion_inc == nil then willpower_evasion_inc = class({}) end
function willpower_evasion_inc:IsHidden() return false end
function willpower_evasion_inc:IsDebuff() return false end
function willpower_evasion_inc:IsPurgable() return false end
function willpower_evasion_inc:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_evasion_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end
function willpower_evasion_inc:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_incoming_red == nil then willpower_incoming_red = class({}) end
function willpower_incoming_red:IsHidden() return false end
function willpower_incoming_red:IsDebuff() return false end
function willpower_incoming_red:IsPurgable() return false end
function willpower_incoming_red:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect") / 2 * (-1))
	end
end
function willpower_incoming_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function willpower_incoming_red:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_outgoing_inc == nil then willpower_outgoing_inc = class({}) end
function willpower_outgoing_inc:IsHidden() return false end
function willpower_outgoing_inc:IsDebuff() return false end
function willpower_outgoing_inc:IsPurgable() return false end
function willpower_outgoing_inc:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect") / 2)
	end
end
function willpower_outgoing_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function willpower_outgoing_inc:GetModifierTotalDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_spell_amp_inc == nil then willpower_spell_amp_inc = class({}) end
function willpower_spell_amp_inc:IsHidden() return false end
function willpower_spell_amp_inc:IsDebuff() return false end
function willpower_spell_amp_inc:IsPurgable() return false end
function willpower_spell_amp_inc:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetSpellAmplification(false) * self:GetAbility():GetSpecialValueFor("modifier_affect")))
	end
end
function willpower_spell_amp_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function willpower_spell_amp_inc:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_lifesteal_pure == nil then willpower_lifesteal_pure = class({}) end
function willpower_lifesteal_pure:IsHidden() return false end
function willpower_lifesteal_pure:IsDebuff() return false end
function willpower_lifesteal_pure:IsPurgable() return false end
function willpower_lifesteal_pure:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_lifesteal_pure:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function willpower_lifesteal_pure:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() end
end
function willpower_lifesteal_pure:GetModifierPureLifesteal()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_lifesteal == nil then willpower_lifesteal = class({}) end
function willpower_lifesteal:IsHidden() return false end
function willpower_lifesteal:IsDebuff() return false end
function willpower_lifesteal:IsPurgable() return false end
function willpower_lifesteal:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_lifesteal:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function willpower_lifesteal:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() end
end
function willpower_lifesteal:GetModifierLifesteal()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_spell_lifesteal_pure == nil then willpower_spell_lifesteal_pure = class({}) end
function willpower_spell_lifesteal_pure:IsHidden() return false end
function willpower_spell_lifesteal_pure:IsDebuff() return false end
function willpower_spell_lifesteal_pure:IsPurgable() return false end
function willpower_spell_lifesteal_pure:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_spell_lifesteal_pure:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function willpower_spell_lifesteal_pure:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() end
end
function willpower_spell_lifesteal_pure:GetModifierPureSpellLifesteal()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_spell_lifesteal == nil then willpower_spell_lifesteal = class({}) end
function willpower_spell_lifesteal:IsHidden() return false end
function willpower_spell_lifesteal:IsDebuff() return false end
function willpower_spell_lifesteal:IsPurgable() return false end
function willpower_spell_lifesteal:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_spell_lifesteal:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function willpower_spell_lifesteal:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() end
end
function willpower_spell_lifesteal:GetModifierSpellLifesteal()
	if self:GetAbility() then return self:GetStackCount() end
end







----------------------------------------------------------------------------------------------------------------------------
--------------------------------------NEGATIVE------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

if willpower_health_regen_red == nil then willpower_health_regen_red = class({}) end
function willpower_health_regen_red:IsHidden() return false end
function willpower_health_regen_red:IsDebuff() return true end
function willpower_health_regen_red:IsPurgable() return false end
function willpower_health_regen_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetHealthRegen() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100) * (-1))
	end
end
function willpower_health_regen_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function willpower_health_regen_red:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_health_amp_red == nil then willpower_health_amp_red = class({}) end
function willpower_health_amp_red:IsHidden() return false end
function willpower_health_amp_red:IsDebuff() return true end
function willpower_health_amp_red:IsPurgable() return false end
function willpower_health_amp_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE}
end
function willpower_health_amp_red:GetModifierHPRegenAmplify_Percentage()
	if self:GetAbility() then return -self:GetAbility():GetSpecialValueFor("modifier_affect") end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_mana_regen_red == nil then willpower_mana_regen_red = class({}) end
function willpower_mana_regen_red:IsHidden() return false end
function willpower_mana_regen_red:IsDebuff() return true end
function willpower_mana_regen_red:IsPurgable() return false end
function willpower_mana_regen_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetManaRegen() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100) * (-1))
	end
end
function willpower_mana_regen_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function willpower_mana_regen_red:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_mana_regen_pct_red == nil then willpower_mana_regen_pct_red = class({}) end
function willpower_mana_regen_pct_red:IsHidden() return false end
function willpower_mana_regen_pct_red:IsDebuff() return true end
function willpower_mana_regen_pct_red:IsPurgable() return false end
function willpower_mana_regen_pct_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE}
end
function willpower_mana_regen_pct_red:GetModifierTotalPercentageManaRegen()
	if self:GetAbility() then return -2.5 end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_base_attack_red == nil then willpower_base_attack_red = class({}) end
function willpower_base_attack_red:IsHidden() return false end
function willpower_base_attack_red:IsDebuff() return true end
function willpower_base_attack_red:IsPurgable() return false end
function willpower_base_attack_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetAttackDamage() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100) * (-1))
	end
end
function willpower_base_attack_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function willpower_base_attack_red:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_attack_speed_red == nil then willpower_attack_speed_red = class({}) end
function willpower_attack_speed_red:IsHidden() return false end
function willpower_attack_speed_red:IsDebuff() return true end
function willpower_attack_speed_red:IsPurgable() return false end
function willpower_attack_speed_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetDisplayAttackSpeed() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100) * (-1))
	end
end
function willpower_attack_speed_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function willpower_attack_speed_red:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_attack_speed_pct_red == nil then willpower_attack_speed_pct_red = class({}) end
function willpower_attack_speed_pct_red:IsHidden() return false end
function willpower_attack_speed_pct_red:IsDebuff() return true end
function willpower_attack_speed_pct_red:IsPurgable() return false end
function willpower_attack_speed_pct_red:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect") * (-1))
	end
end
function willpower_attack_speed_pct_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
end
function willpower_attack_speed_pct_red:GetModifierAttackSpeedPercentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_movement_speed_red == nil then willpower_movement_speed_red = class({}) end
function willpower_movement_speed_red:IsHidden() return false end
function willpower_movement_speed_red:IsDebuff() return true end
function willpower_movement_speed_red:IsPurgable() return false end
function willpower_movement_speed_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetBaseMoveSpeed() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100) * (-1))
	end
end
function willpower_movement_speed_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function willpower_movement_speed_red:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_movement_speed_pct_red == nil then willpower_movement_speed_pct_red = class({}) end
function willpower_movement_speed_pct_red:IsHidden() return false end
function willpower_movement_speed_pct_red:IsDebuff() return true end
function willpower_movement_speed_pct_red:IsPurgable() return false end
function willpower_movement_speed_pct_red:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect") * (-1))
	end
end
function willpower_movement_speed_pct_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function willpower_movement_speed_pct_red:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_cdi == nil then willpower_cdi = class({}) end
function willpower_cdi:IsHidden() return false end
function willpower_cdi:IsDebuff() return true end
function willpower_cdi:IsPurgable() return false end
function willpower_cdi:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect") * (-1))
	end
end
function willpower_cdi:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end
function willpower_cdi:GetModifierPercentageCooldown()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_armor_red == nil then willpower_armor_red = class({}) end
function willpower_armor_red:IsHidden() return false end
function willpower_armor_red:IsDebuff() return true end
function willpower_armor_red:IsPurgable() return false end
function willpower_armor_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetPhysicalArmorValue(false) * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100) * (-1))
	end
end
function willpower_armor_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function willpower_armor_red:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_magic_armor_red == nil then willpower_magic_armor_red = class({}) end
function willpower_magic_armor_red:IsHidden() return false end
function willpower_magic_armor_red:IsDebuff() return true end
function willpower_magic_armor_red:IsPurgable() return false end
function willpower_magic_armor_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetMagicalArmorValue() * self:GetAbility():GetSpecialValueFor("modifier_affect")) * (-1))
	end
end
function willpower_magic_armor_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function willpower_magic_armor_red:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_status_resist_red == nil then willpower_status_resist_red = class({}) end
function willpower_status_resist_red:IsHidden() return false end
function willpower_status_resist_red:IsDebuff() return false end
function willpower_status_resist_red:IsPurgable() return false end
function willpower_status_resist_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetStatusResistance() * self:GetAbility():GetSpecialValueFor("modifier_affect")) * (-1))
	end
end
function willpower_status_resist_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end
function willpower_status_resist_red:GetModifierStatusResistanceStacking()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_evasion_red == nil then willpower_evasion_red = class({}) end
function willpower_evasion_red:IsHidden() return false end
function willpower_evasion_red:IsDebuff() return true end
function willpower_evasion_red:IsPurgable() return false end
function willpower_evasion_red:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect") * (-1))
	end
end
function willpower_evasion_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end
function willpower_evasion_red:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_incoming_inc == nil then willpower_incoming_inc = class({}) end
function willpower_incoming_inc:IsHidden() return false end
function willpower_incoming_inc:IsDebuff() return true end
function willpower_incoming_inc:IsPurgable() return false end
function willpower_incoming_inc:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect") / 2)
	end
end
function willpower_incoming_inc:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function willpower_incoming_inc:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_outgoing_red == nil then willpower_outgoing_red = class({}) end
function willpower_outgoing_red:IsHidden() return false end
function willpower_outgoing_red:IsDebuff() return true end
function willpower_outgoing_red:IsPurgable() return false end
function willpower_outgoing_red:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect") / 2 * (-1))
	end
end
function willpower_outgoing_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function willpower_outgoing_red:GetModifierTotalDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_spell_amp_red == nil then willpower_spell_amp_red = class({}) end
function willpower_spell_amp_red:IsHidden() return false end
function willpower_spell_amp_red:IsDebuff() return true end
function willpower_spell_amp_red:IsPurgable() return false end
function willpower_spell_amp_red:OnCreated()
	if IsServer() then
		self:SetStackCount((self:GetCaster():GetSpellAmplification(false) * self:GetAbility():GetSpecialValueFor("modifier_affect")) * (-1))
	end
end
function willpower_spell_amp_red:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function willpower_spell_amp_red:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_miss_chance == nil then willpower_miss_chance = class({}) end
function willpower_miss_chance:IsHidden() return false end
function willpower_miss_chance:IsDebuff() return true end
function willpower_miss_chance:IsPurgable() return false end
function willpower_miss_chance:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("modifier_affect"))
	end
end
function willpower_miss_chance:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end
function willpower_miss_chance:GetModifierMiss_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

------------------------------------------------------------------------------------------------------------------------

if willpower_hp_drain == nil then willpower_hp_drain = class({}) end
function willpower_hp_drain:IsHidden() return false end
function willpower_hp_drain:IsDebuff() return true end
function willpower_hp_drain:IsPurgable() return false end
function willpower_hp_drain:OnCreated()
	if IsServer() then
		self.interval = FrameTime()
		self:StartIntervalThink(self.interval)
	end
end
function willpower_hp_drain:OnIntervalThink()
	local drain = self:GetAbility():GetSpecialValueFor("modifier_affect")
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local current_hp = self:GetParent():GetHealth()
	local hp_drain = self:GetParent():GetMaxHealth() * drain / 100 * self.interval / duration
	if current_hp > hp_drain then
		self:GetParent():SetHealth(math.max(current_hp - hp_drain, 1))
	else
		if self:GetParent() ~= self:GetCaster() then
			self:GetParent():Kill(self:GetAbility(), self:GetCaster())
		else
			self:GetCaster():SetHealth(1)
		end
	end
end
function willpower_hp_drain:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function willpower_hp_drain:OnTooltip()
	if self:GetAbility() then return self:GetParent():GetMaxHealth() * self:GetAbility():GetSpecialValueFor("modifier_affect") / 100 / self:GetAbility():GetSpecialValueFor("duration") end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
