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
