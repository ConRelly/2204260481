----------------
-- ENERGY AXE --
----------------
LinkLuaModifier("modifier_energy_axe_1", "items/energy_axe.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_axe == nil then item_energy_axe = class({}) end
function item_energy_axe:GetIntrinsicModifierName() return "modifier_energy_axe_1" end

if modifier_energy_axe_1 == nil then modifier_energy_axe_1 = class({}) end
function modifier_energy_axe_1:IsHidden() return true end
function modifier_energy_axe_1:IsPurgable() return false end
function modifier_energy_axe_1:RemoveOnDeath() return false end
function modifier_energy_axe_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_axe_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_axe_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end
function modifier_energy_axe_1:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_energy_axe_1:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_energy_axe_1:GetModifierPercentageCooldown()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cooldown") end
end

------------------
-- ENERGY AXE 2 --
------------------
LinkLuaModifier("modifier_energy_axe_2", "items/energy_axe.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_axe_2 == nil then item_energy_axe_2 = class({}) end
function item_energy_axe_2:GetIntrinsicModifierName() return "modifier_energy_axe_2" end

if modifier_energy_axe_2 == nil then modifier_energy_axe_2 = class({}) end
function modifier_energy_axe_2:IsHidden() return true end
function modifier_energy_axe_2:IsPurgable() return false end
function modifier_energy_axe_2:RemoveOnDeath() return false end
function modifier_energy_axe_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_axe_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_axe_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end
function modifier_energy_axe_2:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_energy_axe_2:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_energy_axe_2:GetModifierPercentageCooldown()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cooldown") end
end

------------------
-- ENERGY AXE 3 --
------------------
LinkLuaModifier("modifier_energy_axe_3", "items/energy_axe.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_axe_3 == nil then item_energy_axe_3 = class({}) end
function item_energy_axe_3:GetIntrinsicModifierName() return "modifier_energy_axe_3" end

if modifier_energy_axe_3 == nil then modifier_energy_axe_3 = class({}) end
function modifier_energy_axe_3:IsHidden() return true end
function modifier_energy_axe_3:IsPurgable() return false end
function modifier_energy_axe_3:RemoveOnDeath() return false end
function modifier_energy_axe_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_axe_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_axe_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end
function modifier_energy_axe_3:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_energy_axe_3:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_energy_axe_3:GetModifierPercentageCooldown()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cooldown") end
end


-----------------
-- ENERGY CORE --
-----------------
if item_energy_core == nil then item_energy_core = class({}) end
LinkLuaModifier("modifier_energy_core", "items/energy_axe.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_core_aura", "items/energy_axe.lua", LUA_MODIFIER_MOTION_NONE)
function item_energy_core:GetCastRange() return self:GetSpecialValueFor("cdr_aura_radius") end
function item_energy_core:GetIntrinsicModifierName() return "modifier_energy_core" end
if modifier_energy_core == nil then modifier_energy_core = class({}) end
function modifier_energy_core:IsHidden() return true end
function modifier_energy_core:IsPurgable() return false end
function modifier_energy_core:RemoveOnDeath() return false end
function modifier_energy_core:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_core:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_energy_core:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_energy_core:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_energy_core:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_energy_core:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_energy_core:GetModifierPercentageCooldown()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cooldown") end
end
function modifier_energy_core:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_cast_range") end
end
function modifier_energy_core:GetModifierSpellLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_lifesteal") end
end
function modifier_energy_core:IsAura() return true end
function modifier_energy_core:IsAuraActiveOnDeath() return false end
function modifier_energy_core:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cdr_aura_radius") end
end
function modifier_energy_core:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_energy_core:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_energy_core:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_energy_core:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_energy_core:GetModifierAura() return "modifier_energy_core_aura" end
if modifier_energy_core_aura == nil then modifier_energy_core_aura = class({}) end
function modifier_energy_core_aura:IsDebuff() return false end
function modifier_energy_core_aura:IsPurgable() return false end
function modifier_energy_core_aura:OnCreated(keys)
	if not self:GetAbility() then self:Destroy() return end
end
function modifier_energy_core_aura:DeclareFunctions() return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE} end
function modifier_energy_core_aura:GetModifierPercentageCooldown()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cdr_aura") end
end
