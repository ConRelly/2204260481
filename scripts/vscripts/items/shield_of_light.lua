---------------------
-- SHIELD OF LIGHT --
---------------------
LinkLuaModifier("modifier_shield_of_light_1", "items/shield_of_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shield_of_light_1_aura", "items/shield_of_light.lua", LUA_MODIFIER_MOTION_NONE)
if item_shield_of_light == nil then item_shield_of_light = class({}) end
function item_shield_of_light:GetIntrinsicModifierName() return "modifier_shield_of_light_1" end

if modifier_shield_of_light_1 == nil then modifier_shield_of_light_1 = class({}) end
function modifier_shield_of_light_1:IsHidden() return true end
function modifier_shield_of_light_1:IsPurgable() return false end
function modifier_shield_of_light_1:RemoveOnDeath() return false end
function modifier_shield_of_light_1:IsAura() return true end
function modifier_shield_of_light_1:IsAuraActiveOnDeath() return false end
function modifier_shield_of_light_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_shield_of_light_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_shield_of_light_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_shield_of_light_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_shield_of_light_1:GetAuraDuration() return FrameTime() end
function modifier_shield_of_light_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_shield_of_light_1:GetModifierAura() return "modifier_shield_of_light_1_aura" end
--------------------------
-- SHIELD OF LIGHT AURA --
--------------------------
if modifier_shield_of_light_1_aura == nil then modifier_shield_of_light_1_aura = class({}) end
function modifier_shield_of_light_1_aura:IsHidden() return false end
function modifier_shield_of_light_1_aura:IsDebuff() return false end
function modifier_shield_of_light_1_aura:IsPurgable() return false end
function modifier_shield_of_light_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_shield_of_light_1_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_shield_of_light_1_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_shield_of_light_1_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int_aura") end
end

-----------------------
-- SHIELD OF LIGHT 2 --
-----------------------
LinkLuaModifier("modifier_shield_of_light_2", "items/shield_of_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shield_of_light_2_aura", "items/shield_of_light.lua", LUA_MODIFIER_MOTION_NONE)
if item_shield_of_light_2 == nil then item_shield_of_light_2 = class({}) end
function item_shield_of_light_2:GetIntrinsicModifierName() return "modifier_shield_of_light_2" end

if modifier_shield_of_light_2 == nil then modifier_shield_of_light_2 = class({}) end
function modifier_shield_of_light_2:IsHidden() return true end
function modifier_shield_of_light_2:IsPurgable() return false end
function modifier_shield_of_light_2:RemoveOnDeath() return false end
function modifier_shield_of_light_2:IsAura() return true end
function modifier_shield_of_light_2:IsAuraActiveOnDeath() return false end
function modifier_shield_of_light_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_shield_of_light_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_shield_of_light_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_shield_of_light_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_shield_of_light_2:GetAuraDuration() return FrameTime() end
function modifier_shield_of_light_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_shield_of_light_2:GetModifierAura() return "modifier_shield_of_light_2_aura" end
----------------------------
-- SHIELD OF LIGHT 2 AURA --
----------------------------
if modifier_shield_of_light_2_aura == nil then modifier_shield_of_light_2_aura = class({}) end
function modifier_shield_of_light_2_aura:IsHidden() return false end
function modifier_shield_of_light_2_aura:IsDebuff() return false end
function modifier_shield_of_light_2_aura:IsPurgable() return false end
function modifier_shield_of_light_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_shield_of_light_2_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_shield_of_light_2_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_shield_of_light_2_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int_aura") end
end

-----------------------
-- SHIELD OF LIGHT 3 --
-----------------------
LinkLuaModifier("modifier_shield_of_light_3", "items/shield_of_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shield_of_light_3_aura", "items/shield_of_light.lua", LUA_MODIFIER_MOTION_NONE)
if item_shield_of_light_3 == nil then item_shield_of_light_3 = class({}) end
function item_shield_of_light_3:GetIntrinsicModifierName() return "modifier_shield_of_light_3" end

if modifier_shield_of_light_3 == nil then modifier_shield_of_light_3 = class({}) end
function modifier_shield_of_light_3:IsHidden() return true end
function modifier_shield_of_light_3:IsPurgable() return false end
function modifier_shield_of_light_3:RemoveOnDeath() return false end
function modifier_shield_of_light_3:IsAura() return true end
function modifier_shield_of_light_3:IsAuraActiveOnDeath() return false end
function modifier_shield_of_light_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_shield_of_light_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_shield_of_light_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_shield_of_light_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_shield_of_light_3:GetAuraDuration() return FrameTime() end
function modifier_shield_of_light_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_shield_of_light_3:GetModifierAura() return "modifier_shield_of_light_3_aura" end
----------------------------
-- SHIELD OF LIGHT 3 AURA --
----------------------------
if modifier_shield_of_light_3_aura == nil then modifier_shield_of_light_3_aura = class({}) end
function modifier_shield_of_light_3_aura:IsHidden() return false end
function modifier_shield_of_light_3_aura:IsDebuff() return false end
function modifier_shield_of_light_3_aura:IsPurgable() return false end
function modifier_shield_of_light_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_shield_of_light_3_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_shield_of_light_3_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_shield_of_light_3_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int_aura") end
end


--------------------
-- HEART OF LIGHT --
--------------------
LinkLuaModifier("modifier_heart_of_light", "items/shield_of_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_heart_of_light_aura", "items/shield_of_light.lua", LUA_MODIFIER_MOTION_NONE)
if item_heart_of_light == nil then item_heart_of_light = class({}) end
function item_heart_of_light:GetIntrinsicModifierName() return "modifier_heart_of_light" end

if modifier_heart_of_light == nil then modifier_heart_of_light = class({}) end
function modifier_heart_of_light:IsHidden() return true end
function modifier_heart_of_light:IsPurgable() return false end
function modifier_heart_of_light:RemoveOnDeath() return false end
function modifier_heart_of_light:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end
function modifier_heart_of_light:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_heart_of_light:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_heart_of_light:GetModifierHealthRegenPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_pct") end
end
function modifier_heart_of_light:IsAura() return true end
function modifier_heart_of_light:IsAuraActiveOnDeath() return false end
function modifier_heart_of_light:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_heart_of_light:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_heart_of_light:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_heart_of_light:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_heart_of_light:GetAuraDuration() return FrameTime() end
function modifier_heart_of_light:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_heart_of_light:GetModifierAura() return "modifier_heart_of_light_aura" end
-------------------------
-- HEART OF LIGHT AURA --
-------------------------
if modifier_heart_of_light_aura == nil then modifier_heart_of_light_aura = class({}) end
function modifier_heart_of_light_aura:IsHidden() return false end
function modifier_heart_of_light_aura:IsDebuff() return false end
function modifier_heart_of_light_aura:IsPurgable() return false end
function modifier_heart_of_light_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_heart_of_light_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_heart_of_light_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_heart_of_light_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int_aura") end
end