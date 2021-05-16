--------------
--FIRE STONE--
--------------
LinkLuaModifier("modifier_fire_stone_1", "items/fire_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_stone_1_aura", "items/fire_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_stone == nil then item_fire_stone = class({}) end
function item_fire_stone:GetIntrinsicModifierName() return "modifier_fire_stone_1" end

if modifier_fire_stone_1 == nil then modifier_fire_stone_1 = class({}) end
function modifier_fire_stone_1:IsHidden() return true end
function modifier_fire_stone_1:IsPurgable() return false end
function modifier_fire_stone_1:RemoveOnDeath() return false end
function modifier_fire_stone_1:IsAura() return true end
function modifier_fire_stone_1:IsAuraActiveOnDeath() return false end
function modifier_fire_stone_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_fire_stone_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_fire_stone_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_fire_stone_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_fire_stone_1:GetAuraDuration() return FrameTime() end
function modifier_fire_stone_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_fire_stone_1:GetModifierAura() return "modifier_fire_stone_1_aura" end
-------------------
--FIRE STONE AURA--
-------------------
if modifier_fire_stone_1_aura == nil then modifier_fire_stone_1_aura = class({}) end
function modifier_fire_stone_1_aura:IsHidden() return false end
function modifier_fire_stone_1_aura:IsDebuff() return false end
function modifier_fire_stone_1_aura:IsPurgable() return false end
function modifier_fire_stone_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_stone_1_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_fire_stone_1_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
function modifier_fire_stone_1_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end

---------------
--FIRE STONE2--
---------------
LinkLuaModifier("modifier_fire_stone_2", "items/fire_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_stone_2_aura", "items/fire_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_stone_2 == nil then item_fire_stone_2 = class({}) end
function item_fire_stone_2:GetIntrinsicModifierName() return "modifier_fire_stone_2" end

if modifier_fire_stone_2 == nil then modifier_fire_stone_2 = class({}) end
function modifier_fire_stone_2:IsHidden() return true end
function modifier_fire_stone_2:IsPurgable() return false end
function modifier_fire_stone_2:RemoveOnDeath() return false end
function modifier_fire_stone_2:IsAura() return true end
function modifier_fire_stone_2:IsAuraActiveOnDeath() return false end
function modifier_fire_stone_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_fire_stone_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_fire_stone_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_fire_stone_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_fire_stone_2:GetAuraDuration() return FrameTime() end
function modifier_fire_stone_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_fire_stone_2:GetModifierAura() return "modifier_fire_stone_2_aura" end
--------------------
--FIRE STONE2 AURA--
--------------------
if modifier_fire_stone_2_aura == nil then modifier_fire_stone_2_aura = class({}) end
function modifier_fire_stone_2_aura:IsHidden() return false end
function modifier_fire_stone_2_aura:IsDebuff() return false end
function modifier_fire_stone_2_aura:IsPurgable() return false end
function modifier_fire_stone_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_stone_2_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_fire_stone_2_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
function modifier_fire_stone_2_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end

---------------
--FIRE STONE3--
---------------
LinkLuaModifier("modifier_fire_stone_3", "items/fire_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_stone_3_aura", "items/fire_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_stone_3 == nil then item_fire_stone_3 = class({}) end
function item_fire_stone_3:GetIntrinsicModifierName() return "modifier_fire_stone_3" end

if modifier_fire_stone_3 == nil then modifier_fire_stone_3 = class({}) end
function modifier_fire_stone_3:IsHidden() return true end
function modifier_fire_stone_3:IsPurgable() return false end
function modifier_fire_stone_3:RemoveOnDeath() return false end
function modifier_fire_stone_3:IsAura() return true end
function modifier_fire_stone_3:IsAuraActiveOnDeath() return false end
function modifier_fire_stone_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_fire_stone_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_fire_stone_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_fire_stone_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_fire_stone_3:GetAuraDuration() return FrameTime() end
function modifier_fire_stone_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_fire_stone_3:GetModifierAura() return "modifier_fire_stone_3_aura" end
--------------------
--FIRE STONE3 AURA--
--------------------
if modifier_fire_stone_3_aura == nil then modifier_fire_stone_3_aura = class({}) end
function modifier_fire_stone_3_aura:IsHidden() return false end
function modifier_fire_stone_3_aura:IsDebuff() return false end
function modifier_fire_stone_3_aura:IsPurgable() return false end
function modifier_fire_stone_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_stone_3_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_fire_stone_3_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
function modifier_fire_stone_3_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end


----------------
--VAMPIRE ROBE--
----------------
LinkLuaModifier("modifier_vampire_robe", "items/fire_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vampire_robe_aura", "items/fire_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_vampire_robe == nil then item_vampire_robe = class({}) end
function item_vampire_robe:GetIntrinsicModifierName() return "modifier_vampire_robe" end

if modifier_vampire_robe == nil then modifier_vampire_robe = class({}) end
function modifier_vampire_robe:IsHidden() return true end
function modifier_vampire_robe:IsPurgable() return false end
function modifier_vampire_robe:RemoveOnDeath() return false end
function modifier_vampire_robe:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_vampire_robe:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end
function modifier_vampire_robe:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_vampire_robe:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_vampire_robe:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_vampire_robe:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_vampire_robe:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_vampire_robe:IsAura() return true end
function modifier_vampire_robe:IsAuraActiveOnDeath() return false end
function modifier_vampire_robe:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_vampire_robe:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_vampire_robe:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_vampire_robe:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_vampire_robe:GetAuraDuration() return FrameTime() end
function modifier_vampire_robe:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_vampire_robe:GetModifierAura() return "modifier_vampire_robe_aura" end
---------------------
--VAMPIRE ROBE AURA--
---------------------
if modifier_vampire_robe_aura == nil then modifier_vampire_robe_aura = class({}) end
function modifier_vampire_robe_aura:IsHidden() return false end
function modifier_vampire_robe_aura:IsDebuff() return false end
function modifier_vampire_robe_aura:IsPurgable() return false end
function modifier_vampire_robe_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_TOOLTIP }
end
function modifier_vampire_robe_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_vampire_robe_aura:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end
function modifier_vampire_robe_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
function modifier_vampire_robe_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end
function modifier_vampire_robe_aura:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_aura") end
end
function modifier_vampire_robe_aura:GetModifierLifesteal()
	if self:GetAbility() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then return self:GetAbility():GetSpecialValueFor("ls_pct_aura") end
end
function modifier_vampire_robe_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("ls_pct_aura") end
