---------------
-- Crystalys --
---------------
item_crystalys = class({})
LinkLuaModifier("modifier_crystalys", "items/crit.lua", LUA_MODIFIER_MOTION_NONE)
function item_crystalys:GetIntrinsicModifierName() return "modifier_crystalys" end

modifier_crystalys = class({})
function modifier_crystalys:IsHidden() return true end
function modifier_crystalys:IsPurgable() return false end
function modifier_crystalys:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_crystalys:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_crystalys:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_crystalys:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end
function modifier_crystalys:GetModifierCritDMG()
	if IsServer() then
		if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) then
			self.IsCrit = true
			return self:GetAbility():GetSpecialValueFor("crit_multiplier")
		end
	end
	return 0
end

--------------
-- Daedalus --
--------------
item_daedalus = class({})
LinkLuaModifier("modifier_daedalus", "items/crit.lua", LUA_MODIFIER_MOTION_NONE)
function item_daedalus:GetIntrinsicModifierName() return "modifier_daedalus" end

modifier_daedalus = class({})
function modifier_daedalus:IsHidden() return true end
function modifier_daedalus:IsPurgable() return false end
function modifier_daedalus:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_daedalus:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.IsCrit = false
	end
end
function modifier_daedalus:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_daedalus:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end
function modifier_daedalus:GetModifierCritDMG()
	if IsServer() then
		if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) then
			self.IsCrit = true
			return self:GetAbility():GetSpecialValueFor("crit_multiplier")
		end
	end
	return 0
end
function modifier_daedalus:OnAttackLanded(params)
	if IsServer() then
		if self:GetParent() == params.attacker then
			local target = params.target
			if target ~= nil and self.bIsCrit then
				EmitSoundOn("DOTA_Item.Daedelus.Crit", target)
				self.IsCrit = false
			end
		end
	end
	return 0
end

-----------------------
-- Upgraded Daedalus --
-----------------------
item_upgraded_daedalus = class({})
LinkLuaModifier("modifier_upgraded_daedalus", "items/crit.lua", LUA_MODIFIER_MOTION_NONE)
function item_upgraded_daedalus:GetIntrinsicModifierName() return "modifier_upgraded_daedalus" end

modifier_upgraded_daedalus = class({})
function modifier_upgraded_daedalus:IsHidden() return true end
function modifier_upgraded_daedalus:IsPurgable() return false end
function modifier_upgraded_daedalus:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_upgraded_daedalus:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.IsCrit = false
	end
end
function modifier_upgraded_daedalus:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_upgraded_daedalus:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end
function modifier_upgraded_daedalus:GetModifierCritDMG()
	if IsServer() then
		if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) then
			self.IsCrit = true
			return self:GetAbility():GetSpecialValueFor("crit_multiplier")
		end
	end
	return 0
end
function modifier_upgraded_daedalus:OnAttackLanded(params)
	if IsServer() then
		if self:GetParent() == params.attacker then
			local target = params.target
			if target ~= nil and self.bIsCrit then
				EmitSoundOn("DOTA_Item.Daedelus.Crit", target)
				self.IsCrit = false
			end
		end
	end
	return 0
end

---------------
-- Wildthorn --			WIP
---------------
LinkLuaModifier("modifier_wildthorn", "items/crit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wildthorn_unique_crit", "items/crit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wildthorn_debuff", "items/crit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wildthorn_buff", "items/crit", LUA_MODIFIER_MOTION_NONE)
item_wildthorn = class({})
function item_wildthorn:GetIntrinsicModifierName() return "modifier_wildthorn" end
function item_wildthorn:CastFilterResultTarget(Target)
	if not self:GetCaster():HasModifier("modifier_life_greaves") and Target:GetTeam() == self:GetCaster():GetTeam() then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
function item_wildthorn:GetCustomCastErrorTarget(Target)
	if not self:GetCaster():HasModifier("modifier_life_greaves") and Target:GetTeam() == self:GetCaster():GetTeam() then
		return "#dota_hud_error_cant_cast_on_ally"
	end
	return ""
end

function item_wildthorn:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local silence_duration = self:GetSpecialValueFor("silence_duration")

		if not caster:HasModifier("modifier_super_scepter") then
			if target:GetTeam() ~= caster:GetTeam() then if target:TriggerSpellAbsorb(self) then return end end
		end

		target:EmitSound("DOTA_Item.Bloodthorn.Activate")

		if Wildthorn ~= nil then
			Wildthorn:Destroy()
		end

		if target:GetTeam() ~= caster:GetTeam() then
			Wildthorn = target:AddNewModifier(caster, self, "modifier_wildthorn_debuff", {duration = silence_duration * (1 + target:GetStatusResistance())})
		else
			caster:Purge(false,true,false,false,false)
			Wildthorn = target:AddNewModifier(caster, self, "modifier_wildthorn_buff", {duration = silence_duration * (1 + target:GetStatusResistance())})
		end
	end
end

modifier_wildthorn = class({})
function modifier_wildthorn:IsHidden() return true end
function modifier_wildthorn:IsPurgable() return false end
function modifier_wildthorn:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_wildthorn:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_wildthorn:OnIntervalThink()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_wildthorn_unique_crit") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wildthorn_unique_crit", {})
		end
	end
end
function modifier_wildthorn:OnDestroy()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_wildthorn_unique_crit") then
			self:GetCaster():RemoveModifierByName("modifier_wildthorn_unique_crit")
		end
	end
end
function modifier_wildthorn:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end
function modifier_wildthorn:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_wildthorn:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_wildthorn:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_wildthorn:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

modifier_wildthorn_unique_crit = class({})
function modifier_wildthorn_unique_crit:IsHidden() return true end
function modifier_wildthorn_unique_crit:IsPurgable() return false end
function modifier_wildthorn_unique_crit:RemoveOnDeath() return false end
function modifier_wildthorn_unique_crit:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_wildthorn_unique_crit:OnAttackStart(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		if target:HasModifier("modifier_wildthorn_debuff") then
			self.DebuffCritProc = true
		else
			self.DebuffCritProc = false
			if not owner:HasModifier("modifier_wildthorn") then
				owner:RemoveModifierByName("modifier_wildthorn_unique_crit")
			end
		end
	end
end
function modifier_wildthorn_unique_crit:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		if target:HasModifier("modifier_wildthorn_debuff") then
			self.DebuffCritProc = true
		else
			self.DebuffCritProc = false
			if not owner:HasModifier("modifier_wildthorn") then
				owner:RemoveModifierByName("modifier_wildthorn_unique_crit")
			end
		end
	end
end
function modifier_wildthorn_unique_crit:GetModifierCritDMG()
	if IsServer() then
		Proc = false
		local BaseCrit = 0
		local DebuffCrit = 0
		if self.DebuffCritProc then
			DebuffCrit = self:GetAbility():GetSpecialValueFor("target_crit_multiplier") - 100
		end
		if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) and self:GetParent():HasModifier("modifier_wildthorn") then
			Proc = true
			BaseCrit = self:GetAbility():GetSpecialValueFor("crit_multiplier")
		end
		return BaseCrit + DebuffCrit
	end
end

-----------------------
--	Wildthorn debuff --
-----------------------
modifier_wildthorn_debuff = class({})
function modifier_wildthorn_debuff:IsHidden() return false end
function modifier_wildthorn_debuff:IsDebuff() return true end
--function modifier_wildthorn_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_wildthorn_debuff:IsPurgable()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then return false else return true end
end
function modifier_wildthorn_debuff:GetEffectName() return "particles/custom/items/wildthorn/wildthorn.vpcf" end
function modifier_wildthorn_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_wildthorn_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local parent = self:GetParent()
		if not parent.wildthorn_damage_taken then
			parent.wildthorn_damage_taken = 0
		end
		self.damage_factor = self:GetAbility():GetSpecialValueFor("silence_damage_percent")
	end
end
function modifier_wildthorn_debuff:CheckState()
	local passives = nil
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		passives = true
	end
	return {
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = passives,
	}
end
function modifier_wildthorn_debuff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ATTACK_START}
end
function modifier_wildthorn_debuff:OnAttackStart(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		local attacker = keys.attacker
		if owner == attacker then return end
		if owner == target then
			if not attacker:HasModifier("modifier_wildthorn_unique_crit") then
				attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wildthorn_unique_crit", {})
			end
		end
	end
end
function modifier_wildthorn_debuff:OnTakeDamage(keys)
	if IsServer() then
		local parent = self:GetParent()
		if parent == keys.unit then
			parent.wildthorn_damage_taken = parent.wildthorn_damage_taken + keys.damage
		end
	end
end
function modifier_wildthorn_debuff:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage_factor = ability:GetSpecialValueFor("silence_damage_percent")
		if parent.wildthorn_damage_taken > 0 then
			local damage = parent.wildthorn_damage_taken * damage_factor * 0.01
			ApplyDamage({attacker = ability:GetCaster(), victim = parent, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

			local orchid_end_pfx = ParticleManager:CreateParticle("particles/custom/items/wildthorn/wildthorn_pop.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
			ParticleManager:SetParticleControl(orchid_end_pfx, 0, parent:GetAbsOrigin())
			ParticleManager:SetParticleControl(orchid_end_pfx, 1, Vector(100, 0, 0))
			ParticleManager:ReleaseParticleIndex(orchid_end_pfx)
		end

		self:GetParent().wildthorn_damage_taken = nil
	end
end

---------------------
--	Wildthorn buff --
---------------------
modifier_wildthorn_buff = class({})
function modifier_wildthorn_buff:IsHidden() return false end
function modifier_wildthorn_buff:IsDebuff() return true end
--function modifier_wildthorn_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_wildthorn_buff:IsPurgable()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then return true else return false end
end
function modifier_wildthorn_buff:GetEffectName() return "particles/custom/items/wildthorn/wildthorn.vpcf" end
function modifier_wildthorn_buff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_wildthorn_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_wildthorn_buff:CheckState()
	local passives = nil
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		passives = false
	end
	return {
		[MODIFIER_STATE_MUTED] = false,
		[MODIFIER_STATE_SILENCED] = false,
		[MODIFIER_STATE_PASSIVES_DISABLED] = passives,
	}
end
function modifier_wildthorn_buff:GetModifierCritDMG()
	local BaseCrit = 0
	local BuffCrit = 0
	if Proc then
		BaseCrit = 100
	end
	if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) then
		BuffCrit = 75
	end
	return BaseCrit + BuffCrit
end
