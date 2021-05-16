-----------------
-- EARTH SPEAR --
-----------------
LinkLuaModifier("modifier_earth_spear_1", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_spear_1_aura", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_spear_2", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_spear_2_aura", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_spear_3", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_spear_3_aura", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)

if item_earth_spear == nil then item_earth_spear = class({}) end
if item_earth_spear_2 == nil then item_earth_spear_2 = class({}) end
if item_earth_spear_3 == nil then item_earth_spear_3 = class({}) end

if modifier_earth_spear_1 == nil then modifier_earth_spear_1 = class({}) end
if modifier_earth_spear_2 == nil then modifier_earth_spear_2 = class({}) end
if modifier_earth_spear_3 == nil then modifier_earth_spear_3 = class({}) end

if modifier_earth_spear_1_aura == nil then modifier_earth_spear_1_aura = class({}) end
if modifier_earth_spear_2_aura == nil then modifier_earth_spear_2_aura = class({}) end
if modifier_earth_spear_3_aura == nil then modifier_earth_spear_3_aura = class({}) end

function item_earth_spear:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_earth_spear:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_earth_spear:GetIntrinsicModifierName() return "modifier_earth_spear_1" end

function modifier_earth_spear_1:IsHidden() return true end
function modifier_earth_spear_1:IsPurgable() return false end
function modifier_earth_spear_1:RemoveOnDeath() return false end
function modifier_earth_spear_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_earth_spear_1:IsAura() return true end
function modifier_earth_spear_1:IsAuraActiveOnDeath() return false end
function modifier_earth_spear_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_earth_spear_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_earth_spear_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_earth_spear_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_earth_spear_1:GetAuraDuration() return FrameTime() end
function modifier_earth_spear_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_earth_spear_1:GetModifierAura() return "modifier_earth_spear_1_aura" end
----------------------
-- EARTH SPEAR AURA --
----------------------
function modifier_earth_spear_1_aura:IsHidden() return false end
function modifier_earth_spear_1_aura:IsDebuff() return false end
function modifier_earth_spear_1_aura:IsPurgable() return false end
function modifier_earth_spear_1_aura:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_earth_spear_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_earth_spear_1_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_earth_spear_1_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed_aura") end
end
function modifier_earth_spear_1_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end


-------------------
-- EARTH SPEAR 2 --
-------------------
function item_earth_spear_2:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_earth_spear_2:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_earth_spear_2:GetIntrinsicModifierName() return "modifier_earth_spear_2" end

function modifier_earth_spear_2:IsHidden() return true end
function modifier_earth_spear_2:IsPurgable() return false end
function modifier_earth_spear_2:RemoveOnDeath() return false end
function modifier_earth_spear_2:IsAura() return true end
function modifier_earth_spear_2:IsAuraActiveOnDeath() return false end
function modifier_earth_spear_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_earth_spear_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_earth_spear_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_earth_spear_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_earth_spear_2:GetAuraDuration() return FrameTime() end
function modifier_earth_spear_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_earth_spear_2:GetModifierAura() return "modifier_earth_spear_2_aura" end
------------------------
-- EARTH SPEAR 2 AURA --
------------------------
function modifier_earth_spear_2_aura:IsHidden() return false end
function modifier_earth_spear_2_aura:IsDebuff() return false end
function modifier_earth_spear_2_aura:IsPurgable() return false end
function modifier_earth_spear_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_earth_spear_2_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_earth_spear_2_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed_aura") end
end
function modifier_earth_spear_2_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end


-------------------
-- EARTH SPEAR 3 --
-------------------
function item_earth_spear_3:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_earth_spear_3:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_earth_spear_3:GetIntrinsicModifierName() return "modifier_earth_spear_3" end

function modifier_earth_spear_3:IsHidden() return true end
function modifier_earth_spear_3:IsPurgable() return false end
function modifier_earth_spear_3:RemoveOnDeath() return false end
function modifier_earth_spear_3:IsAura() return true end
function modifier_earth_spear_3:IsAuraActiveOnDeath() return false end
function modifier_earth_spear_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_earth_spear_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_earth_spear_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_earth_spear_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_earth_spear_3:GetAuraDuration() return FrameTime() end
function modifier_earth_spear_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_earth_spear_3:GetModifierAura() return "modifier_earth_spear_3_aura" end
---------------------
--EARTH SPEAR3 AURA--
---------------------
function modifier_earth_spear_3_aura:IsHidden() return false end
function modifier_earth_spear_3_aura:IsDebuff() return false end
function modifier_earth_spear_3_aura:IsPurgable() return false end
function modifier_earth_spear_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_earth_spear_3_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_earth_spear_3_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed_aura") end
end
function modifier_earth_spear_3_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end


-------------------
-- EARTH CUIRASS --
-------------------
LinkLuaModifier("modifier_earth_cuirass", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_cuirass_aura", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_cuirass_debuff", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_cuirass_debuff_aura", "items/earth_spear.lua", LUA_MODIFIER_MOTION_NONE)
if item_earth_cuirass == nil then item_earth_cuirass = class({}) end
function item_earth_cuirass:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_earth_cuirass:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_earth_cuirass:GetIntrinsicModifierName() return "modifier_earth_cuirass" end

if modifier_earth_cuirass == nil then modifier_earth_cuirass = class({}) end
function modifier_earth_cuirass:IsHidden() return true end
function modifier_earth_cuirass:IsPurgable() return false end
function modifier_earth_cuirass:RemoveOnDeath() return false end
function modifier_earth_cuirass:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_earth_cuirass_debuff", {})
	end
end
function modifier_earth_cuirass:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_earth_cuirass:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_earth_cuirass:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_earth_cuirass:IsAura() return true end
function modifier_earth_cuirass:IsAuraActiveOnDeath() return false end
function modifier_earth_cuirass:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_earth_cuirass:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_earth_cuirass:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_earth_cuirass:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_earth_cuirass:GetAuraDuration() return FrameTime() end
function modifier_earth_cuirass:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_earth_cuirass:GetModifierAura() return "modifier_earth_cuirass_aura" end
------------------------
-- EARTH CUIRASS AURA --
------------------------
if modifier_earth_cuirass_aura == nil then modifier_earth_cuirass_aura = class({}) end
function modifier_earth_cuirass_aura:IsHidden() return false end
function modifier_earth_cuirass_aura:IsDebuff() return false end
function modifier_earth_cuirass_aura:IsPurgable() return false end
function modifier_earth_cuirass_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_earth_cuirass_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_earth_cuirass_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed_aura") end
end
function modifier_earth_cuirass_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end
-------------------------------
-- EARTH CUIRASS DEBUFF AURA --
-------------------------------
if modifier_earth_cuirass_debuff == nil then modifier_earth_cuirass_debuff = class({}) end
function modifier_earth_cuirass_debuff:IsHidden() return true end
function modifier_earth_cuirass_debuff:IsPurgable() return false end
function modifier_earth_cuirass_debuff:RemoveOnDeath() return false end
function modifier_earth_cuirass_debuff:IsAura() return true end
function modifier_earth_cuirass_debuff:IsAuraActiveOnDeath() return false end
function modifier_earth_cuirass_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_earth_cuirass_debuff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_earth_cuirass_debuff:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_earth_cuirass_debuff:GetAuraDuration() return FrameTime() end
function modifier_earth_cuirass_debuff:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_earth_cuirass_debuff:GetModifierAura() return "modifier_earth_cuirass_debuff_aura" end
function modifier_earth_cuirass_debuff:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end

if modifier_earth_cuirass_debuff_aura == nil then modifier_earth_cuirass_debuff_aura = class({}) end
function modifier_earth_cuirass_debuff_aura:IsDebuff() return true end
function modifier_earth_cuirass_debuff_aura:IsHidden() return false end
function modifier_earth_cuirass_debuff_aura:IsPurgable() return false end
function modifier_earth_cuirass_debuff_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_earth_cuirass_debuff_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_earth_cuirass_debuff_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_red") * (-1) end
end