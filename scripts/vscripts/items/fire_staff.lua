----------------
-- FIRE STAFF --
----------------
LinkLuaModifier("modifier_fire_staff_1", "items/fire_staff.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_staff == nil then item_fire_staff = class({}) end
function item_fire_staff:GetIntrinsicModifierName() return "modifier_fire_staff_1" end

if modifier_fire_staff_1 == nil then modifier_fire_staff_1 = class({}) end
function modifier_fire_staff_1:IsHidden() return true end
function modifier_fire_staff_1:IsPurgable() return false end
function modifier_fire_staff_1:RemoveOnDeath() return false end
function modifier_fire_staff_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_staff_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_staff_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_fire_staff_1:GetModifierSpellLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_lifesteal") end
end
function modifier_fire_staff_1:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end

------------------
-- FIRE STAFF 2 --
------------------
LinkLuaModifier("modifier_fire_staff_2", "items/fire_staff.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_staff_2 == nil then item_fire_staff_2 = class({}) end
function item_fire_staff_2:GetIntrinsicModifierName() return "modifier_fire_staff_2" end

if modifier_fire_staff_2 == nil then modifier_fire_staff_2 = class({}) end
function modifier_fire_staff_2:IsHidden() return true end
function modifier_fire_staff_2:IsPurgable() return false end
function modifier_fire_staff_2:RemoveOnDeath() return false end
function modifier_fire_staff_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_staff_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_staff_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_fire_staff_2:GetModifierSpellLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_lifesteal") end
end
function modifier_fire_staff_2:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end

------------------
-- FIRE STAFF 3 --
------------------
LinkLuaModifier("modifier_fire_staff_3", "items/fire_staff.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_staff_3 == nil then item_fire_staff_3 = class({}) end
function item_fire_staff_3:GetIntrinsicModifierName() return "modifier_fire_staff_3" end

if modifier_fire_staff_3 == nil then modifier_fire_staff_3 = class({}) end
function modifier_fire_staff_3:IsHidden() return true end
function modifier_fire_staff_3:IsPurgable() return false end
function modifier_fire_staff_3:RemoveOnDeath() return false end
function modifier_fire_staff_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_staff_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_staff_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_fire_staff_3:GetModifierSpellLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_lifesteal") end
end
function modifier_fire_staff_3:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end


---------------
-- FIRE CORE --
---------------
LinkLuaModifier("modifier_fire_core", "items/fire_staff.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_core == nil then item_fire_core = class({}) end
function item_fire_core:GetIntrinsicModifierName() return "modifier_fire_core" end
if modifier_fire_core == nil then modifier_fire_core = class({}) end
function modifier_fire_core:IsHidden() return true end
function modifier_fire_core:IsPurgable() return false end
function modifier_fire_core:RemoveOnDeath() return false end
function modifier_fire_core:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_core:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_fire_core:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_fire_core:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_fire_core:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_fire_core:GetModifierPercentageCooldown()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cooldown") end
end
function modifier_fire_core:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_cast_range") end
end
function modifier_fire_core:GetModifierSpellLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_lifesteal") end
end
