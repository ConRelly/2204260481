LinkLuaModifier("modifier_sourcery", "heroes/hero_piety/sourcery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sourcery_aura", "heroes/hero_piety/sourcery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sourcery_active", "heroes/hero_piety/sourcery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_divinity_activated", "heroes/hero_piety/divine_cancel", LUA_MODIFIER_MOTION_NONE)

--------------
-- Sourcery --
--------------
sourcery = class({})
function sourcery:GetIntrinsicModifierName() return "modifier_sourcery" end
function sourcery:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_divinity_activated") then
		if self:GetCaster():HasModifier("modifier_sourcery_active") then
			return "custom/abilities/sourcery_positive"
		else
			return "custom/abilities/sourcery_negative"
		end
	end
	return "custom/abilities/sourcery"
end
function sourcery:ProcsMagicStick() return false end
function sourcery:GetBehavior()
	if self:GetCaster():HasModifier("modifier_divinity_activated") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end
function sourcery:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_divinity_activated") then
		return 30 / self:GetCaster():GetCooldownReduction()
	end
	return 0
end
function sourcery:Spawn()
	if IsServer() then self:SetLevel(1) end
end
function sourcery:OnHeroLevelUp()
	if IsServer() then
		local caster = self:GetCaster()
		caster:ModifyStrength(caster:GetStrengthGain())
		caster:ModifyAgility(caster:GetAgilityGain())
		caster:ModifyIntellect(caster:GetIntellectGain())
	end
end
function sourcery:OnSpellStart()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_sourcery_active") then
		caster:RemoveModifierByName("modifier_sourcery_active")
	else
		caster:AddNewModifier(caster, self, "modifier_sourcery_active", {})
	end
end

-----------------------
-- Sourcery Modifier --
-----------------------
modifier_sourcery = class({})
function modifier_sourcery:IsHidden() return (self:GetStackCount() == 0) end
function modifier_sourcery:IsPurgable() return false end
function modifier_sourcery:IsDebuff() return false end
function modifier_sourcery:RemoveOnDeath() return false end
function modifier_sourcery:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA + 11111 end
function modifier_sourcery:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local parent = self:GetParent()
		if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then Timers:CreateTimer(0.05, function() parent:RemoveSelf() end) parent:ForceKill(false) end
		parent:SetUnitName("npc_dota_hero_piety")
		parent:SetEntityName("npc_dota_hero_piety")
		parent:SetDayTimeVisionRange(1600)
		parent:SetNightTimeVisionRange(1600)
		parent:SetPhysicalArmorBaseValue(10)
		parent:SetBaseMagicalResistanceValue(30)
		parent:SetBaseHealthRegen(5)
		parent:SetBaseManaRegen(5)

		self.MaxShields = self:GetAbility():GetSpecialValueFor("max_shields")
		self.interval = self:GetAbility():GetSpecialValueFor("shield_interval")
		self.Divine = false
		self:SetStackCount(1)
		layer1 = ParticleManager:CreateParticle("particles/custom/abilities/sourcery/sourcery_layer1.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(layer1, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AddParticle(layer1, false, false, -1, true, false)

		self:StartIntervalThink(self.interval)
		if self:GetCaster():HasAbility("divine_cancel") and not self.Divine then
			self.Divine = true
			self.interval = self:GetAbility():GetSpecialValueFor("shield_interval") / 2
			self:StartIntervalThink(self.interval)
		end
	end
end
function modifier_sourcery:OnStackCountChanged()
	if IsServer() then
		self:GetCaster():SetRangedProjectileName("particles/custom/abilities/sourcery/sourcery_attack_effect.vpcf")
		if self:GetCaster():HasAbility("divine_cancel") and not self.Divine then
			self.Divine = true
			self.interval = self:GetAbility():GetSpecialValueFor("shield_interval") / 2
			self:StartIntervalThink(self.interval)
		end
		if self:GetStackCount() == self.MaxShields then
			self:StartIntervalThink(-1)
		end
	end
end
function modifier_sourcery:OnIntervalThink()
	local caster = self:GetCaster()
	if self:GetStackCount() < self.MaxShields then
		self:SetStackCount(self:GetStackCount() + 1)
	end
	if self:GetStackCount() == 1 then
		layer1 = ParticleManager:CreateParticle("particles/custom/abilities/sourcery/sourcery_layer1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(layer1, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(layer1, false, false, -1, true, false)
	end
	if self:GetStackCount() == 2 then
		layer2 = ParticleManager:CreateParticle("particles/custom/abilities/sourcery/sourcery_layer2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(layer2, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(layer2, false, false, -1, true, false)
	end
	if self:GetStackCount() == 3 then
		layer3 = ParticleManager:CreateParticle("particles/custom/abilities/sourcery/sourcery_layer3.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(layer3, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(layer3, false, false, -1, true, false)
	end

	if self:GetStackCount() == self.MaxShields then
		self:StartIntervalThink(-1)
	end
end
function modifier_sourcery:IsAura() if IsServer() then return self:GetCaster():HasAbility("divine_cancel") end end
function modifier_sourcery:IsAuraActiveOnDeath() return false end
function modifier_sourcery:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_sourcery:GetAuraDuration() return FrameTime() end
function modifier_sourcery:GetModifierAura() return "modifier_sourcery_aura" end
function modifier_sourcery:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_sourcery:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_sourcery:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_sourcery:GetAuraEntityReject(Entity)
	if not self:GetCaster():HasModifier("modifier_divinity_activated") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_divinity_activated", {})
	end
	if Entity == self:GetCaster() then return true end
	return false
end
function modifier_sourcery:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS,
	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_AVOID_DAMAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end
function modifier_sourcery:GetModifierHealthBonus()
	if self:GetAbility() then return 194 end
end
function modifier_sourcery:GetModifierManaBonus()
	if self:GetAbility() then return 555 end
end
function modifier_sourcery:GetModifierTotalDamageOutgoing_Percentage(keys)
	if self:GetAbility() then return -400 end
end
function modifier_sourcery:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("dmg_reduction") * (-1) end
end
function modifier_sourcery:GetModifierAvoidDamage(keys)
	if self:GetAbility() then
		if IsServer() then
			if self:GetCaster():HasAbility("divine_cancel") and not self.Divine then
				self.Divine = true
				self.interval = self:GetAbility():GetSpecialValueFor("shield_interval") / 2
				self:StartIntervalThink(self.interval)
			end
		end
		if keys.damage > 100 and self:GetStackCount() > 0 then
			if self:GetStackCount() == self.MaxShields then
				self:StartIntervalThink(self.interval)
			end
			if self:GetStackCount() == 3 then
				ParticleManager:DestroyParticle(layer3, false)
				ParticleManager:ReleaseParticleIndex(layer3)
			elseif self:GetStackCount() == 2 then
				ParticleManager:DestroyParticle(layer2, false)
				ParticleManager:ReleaseParticleIndex(layer2)
			elseif self:GetStackCount() == 1 then
				ParticleManager:DestroyParticle(layer1, false)
				ParticleManager:ReleaseParticleIndex(layer1)
			end
			self:SetStackCount(self:GetStackCount() - 1)
			if self:GetCaster():HasTalent("special_bonus_unique_sourcery_health_recovery") then
				local heal = self:GetCaster():GetMaxHealth() * talent_value(self:GetCaster(), "special_bonus_unique_sourcery_health_recovery") / 100
				self:GetCaster():Heal(heal, self:GetCaster())
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetCaster(), heal, nil)
			end
			return 1
		end
		return 0
	end
end
function modifier_sourcery:GetModifierStatusResistanceStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("status_resist") end
end
function modifier_sourcery:GetModifierHealthRegenPercentage()
	if self:GetAbility() then return talent_value(self:GetCaster(), "special_bonus_unique_sourcery_health_regen_pct") end
end
function modifier_sourcery:CheckState()
	return {[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true}
end

--------------------------
-- Sourcery Divine Aura --
--------------------------
modifier_sourcery_aura = class({})
function modifier_sourcery_aura:IsHidden() return false end
function modifier_sourcery_aura:IsDebuff()
	if self:GetCaster():HasModifier("modifier_sourcery_active") then Debuff = nil else Debuff = true end
	return Debuff
end
function modifier_sourcery_aura:IsBuff()
	if self:GetCaster():HasModifier("modifier_sourcery_active") then Buff = true else Buff = nil end
	return Buff
end
function modifier_sourcery_aura:IsPurgable() return false end
function modifier_sourcery_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_sourcery_aura:OnIntervalThink()
	if _G._Sun then self:SetStackCount(-1) else self:SetStackCount(0) end
end
function modifier_sourcery_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_sourcery_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		local armor = self:GetCaster():GetPhysicalArmorValue(false) * self:GetAbility():GetSpecialValueFor("aura_armor") / 100
		if self:GetStackCount() == -1 then
			if self:GetCaster():HasModifier("modifier_sourcery_active") then
				return armor
			else
				return -armor
			end
		end
		return 0
	end
end
function modifier_sourcery_aura:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then
		local armor = self:GetCaster():GetMagicalArmorValue() * self:GetAbility():GetSpecialValueFor("aura_armor")
		if self:GetStackCount() == 0 then
			if self:GetCaster():HasModifier("modifier_sourcery_active") then
				return armor
			else
				return -armor
			end
		end
		return 0
	end
end

modifier_sourcery_active = class({})
function modifier_sourcery_active:IsHidden() return true end
function modifier_sourcery_active:IsPurgable() return false end
function modifier_sourcery_active:RemoveOnDeath() return false end
