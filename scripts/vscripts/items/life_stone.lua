----------------
-- LIFE STONE --
----------------
LinkLuaModifier("modifier_life_stone_1", "items/life_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_life_stone == nil then item_life_stone = class({}) end
function item_life_stone:GetIntrinsicModifierName() return "modifier_life_stone_1" end

if modifier_life_stone_1 == nil then modifier_life_stone_1 = class({}) end
function modifier_life_stone_1:IsHidden() return true end
function modifier_life_stone_1:IsPurgable() return false end
function modifier_life_stone_1:RemoveOnDeath() return false end
function modifier_life_stone_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_life_stone_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_life_stone_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function modifier_life_stone_1:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_life_stone_1:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_life_stone_1:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_life_stone_1:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms") end
end

------------------
-- LIFE STONE 2 --
------------------
LinkLuaModifier("modifier_life_stone_2", "items/life_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_life_stone_2 == nil then item_life_stone_2 = class({}) end
function item_life_stone_2:GetIntrinsicModifierName() return "modifier_life_stone_2" end

if modifier_life_stone_2 == nil then modifier_life_stone_2 = class({}) end
function modifier_life_stone_2:IsHidden() return true end
function modifier_life_stone_2:IsPurgable() return false end
function modifier_life_stone_2:RemoveOnDeath() return false end
function modifier_life_stone_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_life_stone_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_life_stone_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function modifier_life_stone_2:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_life_stone_2:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_life_stone_2:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_life_stone_2:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms") end
end

------------------
-- LIFE STONE 3 --
------------------
LinkLuaModifier("modifier_life_stone_3", "items/life_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_life_stone_3 == nil then item_life_stone_3 = class({}) end
function item_life_stone_3:GetIntrinsicModifierName() return "modifier_life_stone_3" end

if modifier_life_stone_3 == nil then modifier_life_stone_3 = class({}) end
function modifier_life_stone_3:IsHidden() return true end
function modifier_life_stone_3:IsPurgable() return false end
function modifier_life_stone_3:RemoveOnDeath() return false end
function modifier_life_stone_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_life_stone_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_life_stone_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function modifier_life_stone_3:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_life_stone_3:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_life_stone_3:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_life_stone_3:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms") end
end


------------------------
-- THE CAUSTIC FINALE --
------------------------
item_caustic_finale = class({})
LinkLuaModifier("modifier_caustic_finale", "items/life_stone.lua", LUA_MODIFIER_MOTION_NONE)
function item_caustic_finale:GetIntrinsicModifierName() return "modifier_caustic_finale" end

modifier_caustic_finale = class({})
function modifier_caustic_finale:IsHidden() return true end
function modifier_caustic_finale:IsPurgable() return false end
function modifier_caustic_finale:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_caustic_finale:OnCreated(kv)
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("damage")
	self.bonus_speed = self:GetAbility():GetSpecialValueFor("ms")
	self.bonus_hp = self:GetAbility():GetSpecialValueFor("hp")
	self.bonus_regen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.IsCrit = false
end
function modifier_caustic_finale:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
--	MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_caustic_finale:GetModifierPreAttack_BonusDamage(params) return self.bonus_damage end
function modifier_caustic_finale:GetModifierMoveSpeedBonus_Constant(params) return self.bonus_speed end
function modifier_caustic_finale:GetModifierHealthBonus(params) return self.bonus_hp end
function modifier_caustic_finale:GetModifierConstantHealthRegen(params) return self.bonus_regen end
function modifier_caustic_finale:GetModifierCritDMG()
	if IsServer() then
--		local target = params.target
--		local attacker = params.attacker
--		if target and (target:IsBuilding() == false) and (target:IsOther() == false) and attacker and (attacker:GetTeamNumber() ~= target:GetTeamNumber()) then
			if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) then
				self.IsCrit = true
				return self:GetAbility():GetSpecialValueFor("crit_multiplier")
			end
--		end
	end
	return 0
end
function modifier_caustic_finale:OnAttackLanded(params)
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
