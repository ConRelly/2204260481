-----------------------
--AMULET OF VAMPIRISM--
-----------------------
LinkLuaModifier("modifier_item_amulet_of_vampirism_1", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amulet_of_vampirism_1_aura", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
if item_amulet_of_vampirism == nil then item_amulet_of_vampirism = class({}) end
function item_amulet_of_vampirism:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_amulet_of_vampirism:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_amulet_of_vampirism:GetIntrinsicModifierName() return "modifier_item_amulet_of_vampirism_1" end

if modifier_item_amulet_of_vampirism_1 == nil then modifier_item_amulet_of_vampirism_1 = class({}) end
function modifier_item_amulet_of_vampirism_1:IsHidden() return true end
function modifier_item_amulet_of_vampirism_1:IsPurgable() return false end
function modifier_item_amulet_of_vampirism_1:RemoveOnDeath() return false end
function modifier_item_amulet_of_vampirism_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_amulet_of_vampirism_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_item_amulet_of_vampirism_1:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_item_amulet_of_vampirism_1:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_item_amulet_of_vampirism_1:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_item_amulet_of_vampirism_1:IsAura() return true end
function modifier_item_amulet_of_vampirism_1:IsAuraActiveOnDeath() return false end
function modifier_item_amulet_of_vampirism_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_item_amulet_of_vampirism_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_item_amulet_of_vampirism_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_item_amulet_of_vampirism_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_amulet_of_vampirism_1:GetAuraDuration() return FrameTime() end
function modifier_item_amulet_of_vampirism_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_amulet_of_vampirism_1:GetModifierAura() return "modifier_amulet_of_vampirism_1_aura" end

----------------------------
--AMULET OF VAMPIRISM AURA--
----------------------------
if modifier_amulet_of_vampirism_1_aura == nil then modifier_amulet_of_vampirism_1_aura = class({}) end
function modifier_amulet_of_vampirism_1_aura:IsHidden() return false end
function modifier_amulet_of_vampirism_1_aura:IsDebuff() return false end
function modifier_amulet_of_vampirism_1_aura:IsPurgable() return false end
function modifier_amulet_of_vampirism_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_amulet_of_vampirism_1_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_amulet_of_vampirism_1_aura:GetModifierLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ls_pct_aura") end
end
function modifier_amulet_of_vampirism_1_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("ls_pct_aura") end


-------------------------
--AMULET OF VAMPIRISM2--
-------------------------
LinkLuaModifier("modifier_item_amulet_of_vampirism_2", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amulet_of_vampirism_2_aura", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
if item_amulet_of_vampirism_2 == nil then item_amulet_of_vampirism_2 = class({}) end
function item_amulet_of_vampirism_2:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_amulet_of_vampirism_2:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_amulet_of_vampirism_2:GetIntrinsicModifierName() return "modifier_item_amulet_of_vampirism_2" end

if modifier_item_amulet_of_vampirism_2 == nil then modifier_item_amulet_of_vampirism_2 = class({}) end
function modifier_item_amulet_of_vampirism_2:IsHidden() return true end
function modifier_item_amulet_of_vampirism_2:IsPurgable() return false end
function modifier_item_amulet_of_vampirism_2:RemoveOnDeath() return false end
function modifier_item_amulet_of_vampirism_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_amulet_of_vampirism_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_item_amulet_of_vampirism_2:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_item_amulet_of_vampirism_2:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_item_amulet_of_vampirism_2:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_item_amulet_of_vampirism_2:IsAura() return true end
function modifier_item_amulet_of_vampirism_2:IsAuraActiveOnDeath() return false end
function modifier_item_amulet_of_vampirism_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_item_amulet_of_vampirism_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_item_amulet_of_vampirism_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_item_amulet_of_vampirism_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_amulet_of_vampirism_2:GetAuraDuration() return FrameTime() end
function modifier_item_amulet_of_vampirism_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_amulet_of_vampirism_2:GetModifierAura() return "modifier_amulet_of_vampirism_2_aura" end

-----------------------------
--AMULET OF VAMPIRISM2 AURA--
-----------------------------
if modifier_amulet_of_vampirism_2_aura == nil then modifier_amulet_of_vampirism_2_aura = class({}) end
function modifier_amulet_of_vampirism_2_aura:IsHidden() return false end
function modifier_amulet_of_vampirism_2_aura:IsDebuff() return false end
function modifier_amulet_of_vampirism_2_aura:IsPurgable() return false end
function modifier_amulet_of_vampirism_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_amulet_of_vampirism_2_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_amulet_of_vampirism_2_aura:GetModifierLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ls_pct_aura") end
end
function modifier_amulet_of_vampirism_2_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("ls_pct_aura") end


------------------------
--AMULET OF VAMPIRISM3--
------------------------
LinkLuaModifier("modifier_item_amulet_of_vampirism_3", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amulet_of_vampirism_3_aura", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
if item_amulet_of_vampirism_3 == nil then item_amulet_of_vampirism_3 = class({}) end
function item_amulet_of_vampirism_3:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_amulet_of_vampirism_3:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_amulet_of_vampirism_3:GetIntrinsicModifierName() return "modifier_item_amulet_of_vampirism_3" end

if modifier_item_amulet_of_vampirism_3 == nil then modifier_item_amulet_of_vampirism_3 = class({}) end
function modifier_item_amulet_of_vampirism_3:IsHidden() return true end
function modifier_item_amulet_of_vampirism_3:IsPurgable() return false end
function modifier_item_amulet_of_vampirism_3:RemoveOnDeath() return false end
function modifier_item_amulet_of_vampirism_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_amulet_of_vampirism_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_item_amulet_of_vampirism_3:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_item_amulet_of_vampirism_3:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_item_amulet_of_vampirism_3:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_item_amulet_of_vampirism_3:IsAura() return true end
function modifier_item_amulet_of_vampirism_3:IsAuraActiveOnDeath() return false end
function modifier_item_amulet_of_vampirism_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_item_amulet_of_vampirism_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_item_amulet_of_vampirism_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_item_amulet_of_vampirism_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_amulet_of_vampirism_3:GetAuraDuration() return FrameTime() end
function modifier_item_amulet_of_vampirism_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_amulet_of_vampirism_3:GetModifierAura() return "modifier_amulet_of_vampirism_3_aura" end

-----------------------------
--AMULET OF VAMPIRISM3 AURA--
-----------------------------
if modifier_amulet_of_vampirism_3_aura == nil then modifier_amulet_of_vampirism_3_aura = class({}) end
function modifier_amulet_of_vampirism_3_aura:IsHidden() return false end
function modifier_amulet_of_vampirism_3_aura:IsDebuff() return false end
function modifier_amulet_of_vampirism_3_aura:IsPurgable() return false end
function modifier_amulet_of_vampirism_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_amulet_of_vampirism_3_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_amulet_of_vampirism_3_aura:GetModifierLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ls_pct_aura") end
end
function modifier_amulet_of_vampirism_3_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("ls_pct_aura") end


----------------------
--UNHALLOWED SATANIC--
----------------------
LinkLuaModifier("modifier_unhallowed_satanic", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_unhallowed_satanic_aura", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_unhallowed_satanic_active", "items/amulet_of_vampirism.lua", LUA_MODIFIER_MOTION_NONE)
item_unhallowed_satanic = item_unhallowed_satanic or class({})
function item_unhallowed_satanic:GetIntrinsicModifierName() return "modifier_unhallowed_satanic" end
function item_unhallowed_satanic:OnSpellStart()
    self:GetCaster():Purge(false,true,false,false,false)
	EmitSoundOn("DOTA_Item.Satanic.Activate", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_unhallowed_satanic_active", {duration = self:GetSpecialValueFor("unholy_rage_duration")})
end

modifier_unhallowed_satanic = class({})
function modifier_unhallowed_satanic:IsHidden() return true end
function modifier_unhallowed_satanic:IsPurgable() return false end
function modifier_unhallowed_satanic:RemoveOnDeath() return false end
function modifier_unhallowed_satanic:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_unhallowed_satanic:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_unhallowed_satanic:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_unhallowed_satanic:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_bonus") end
end
function modifier_unhallowed_satanic:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("strength_bonus") end
end
function modifier_unhallowed_satanic:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_unhallowed_satanic:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_unhallowed_satanic:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_unhallowed_satanic:IsAura() return true end
function modifier_unhallowed_satanic:IsAuraActiveOnDeath() return false end
function modifier_unhallowed_satanic:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_unhallowed_satanic:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_unhallowed_satanic:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_unhallowed_satanic:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_unhallowed_satanic:GetAuraDuration() return FrameTime() end
function modifier_unhallowed_satanic:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_unhallowed_satanic:GetModifierAura() return "modifier_unhallowed_satanic_aura" end

---------------------------
--UNHALLOWED SATANIC AURA--
---------------------------
if modifier_unhallowed_satanic_aura == nil then modifier_unhallowed_satanic_aura = class({}) end
function modifier_unhallowed_satanic_aura:IsHidden() return false end
function modifier_unhallowed_satanic_aura:IsDebuff() return false end
function modifier_unhallowed_satanic_aura:IsPurgable() return false end
function modifier_unhallowed_satanic_aura:GetTexture() return "custom/item_unhallowed_satanic" end
function modifier_unhallowed_satanic_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_unhallowed_satanic_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_unhallowed_satanic_aura:GetModifierLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("lifesteal_pct") end
end
function modifier_unhallowed_satanic_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("lifesteal_pct") end

-----------------------------
--UNHALLOWED SATANIC ACTIVE--
-----------------------------
if modifier_unhallowed_satanic_active == nil then modifier_unhallowed_satanic_active = class({}) end
function modifier_unhallowed_satanic_active:IsHidden() return false end
function modifier_unhallowed_satanic_active:IsDebuff() return false end
function modifier_unhallowed_satanic_active:IsPurgable() return false end
function modifier_unhallowed_satanic_active:GetTexture() return "custom/item_unhallowed_satanic" end
function modifier_unhallowed_satanic_active:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_unhallowed_satanic_active:GetModifierLifesteal()
	if self:GetAbility() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then
		return self:GetAbility():GetSpecialValueFor("unholy_rage_lifesteal_bonus")
	end
end
function modifier_unhallowed_satanic_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_unhallowed_satanic_active:OnTooltip() return self:GetAbility():GetSpecialValueFor("unholy_rage_lifesteal_bonus") end