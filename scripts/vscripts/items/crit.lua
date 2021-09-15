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
