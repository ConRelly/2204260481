-------------------
-- STONE OF VOID --
-------------------
LinkLuaModifier("modifier_stone_of_void_1", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stone_of_void_1_aura", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
if item_stone_of_void == nil then item_stone_of_void = class({}) end
function item_stone_of_void:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_stone_of_void:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_stone_of_void:GetIntrinsicModifierName() return "modifier_stone_of_void_1" end

if modifier_stone_of_void_1 == nil then modifier_stone_of_void_1 = class({}) end
function modifier_stone_of_void_1:IsHidden() return true end
function modifier_stone_of_void_1:IsPurgable() return false end
function modifier_stone_of_void_1:RemoveOnDeath() return false end
function modifier_stone_of_void_1:IsAura() return true end
function modifier_stone_of_void_1:IsAuraActiveOnDeath() return false end
function modifier_stone_of_void_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_stone_of_void_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_stone_of_void_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_stone_of_void_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_stone_of_void_1:GetAuraDuration() return FrameTime() end
function modifier_stone_of_void_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_stone_of_void_1:GetModifierAura() return "modifier_stone_of_void_1_aura" end

------------------------
-- STONE OF VOID AURA --
------------------------
if modifier_stone_of_void_1_aura == nil then modifier_stone_of_void_1_aura = class({}) end
function modifier_stone_of_void_1_aura:IsHidden() return false end
function modifier_stone_of_void_1_aura:IsDebuff() return false end
function modifier_stone_of_void_1_aura:IsPurgable() return false end
function modifier_stone_of_void_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_stone_of_void_1_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT}
end
function modifier_stone_of_void_1_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
function modifier_stone_of_void_1_aura:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_aura") end
end
function modifier_stone_of_void_1_aura:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion_aura") end
end


---------------------
-- STONE OF VOID 2 --
---------------------
LinkLuaModifier("modifier_stone_of_void_2", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stone_of_void_2_aura", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
if item_stone_of_void_2 == nil then item_stone_of_void_2 = class({}) end
function item_stone_of_void_2:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_stone_of_void_2:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_stone_of_void_2:GetIntrinsicModifierName() return "modifier_stone_of_void_2" end

if modifier_stone_of_void_2 == nil then modifier_stone_of_void_2 = class({}) end
function modifier_stone_of_void_2:IsHidden() return true end
function modifier_stone_of_void_2:IsPurgable() return false end
function modifier_stone_of_void_2:RemoveOnDeath() return false end
function modifier_stone_of_void_2:IsAura() return true end
function modifier_stone_of_void_2:IsAuraActiveOnDeath() return false end
function modifier_stone_of_void_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_stone_of_void_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_stone_of_void_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_stone_of_void_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_stone_of_void_2:GetAuraDuration() return FrameTime() end
function modifier_stone_of_void_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_stone_of_void_2:GetModifierAura() return "modifier_stone_of_void_2_aura" end

--------------------------
-- STONE OF VOID 2 AURA --
--------------------------
if modifier_stone_of_void_2_aura == nil then modifier_stone_of_void_2_aura = class({}) end
function modifier_stone_of_void_2_aura:IsHidden() return false end
function modifier_stone_of_void_2_aura:IsDebuff() return false end
function modifier_stone_of_void_2_aura:IsPurgable() return false end
function modifier_stone_of_void_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_stone_of_void_2_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT}
end
function modifier_stone_of_void_2_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
function modifier_stone_of_void_2_aura:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_aura") end
end
function modifier_stone_of_void_2_aura:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion_aura") end
end


---------------------
-- STONE OF VOID 3 --
---------------------
LinkLuaModifier("modifier_stone_of_void_3", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stone_of_void_3_aura", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
if item_stone_of_void_3 == nil then item_stone_of_void_3 = class({}) end
function item_stone_of_void_3:GetBehavior() return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA end
function item_stone_of_void_3:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_stone_of_void_3:GetIntrinsicModifierName() return "modifier_stone_of_void_3" end

if modifier_stone_of_void_3 == nil then modifier_stone_of_void_3 = class({}) end
function modifier_stone_of_void_3:IsHidden() return true end
function modifier_stone_of_void_3:IsPurgable() return false end
function modifier_stone_of_void_3:RemoveOnDeath() return false end
function modifier_stone_of_void_3:IsAura() return true end
function modifier_stone_of_void_3:IsAuraActiveOnDeath() return false end
function modifier_stone_of_void_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_stone_of_void_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_stone_of_void_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_stone_of_void_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_stone_of_void_3:GetAuraDuration() return FrameTime() end
function modifier_stone_of_void_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_stone_of_void_3:GetModifierAura() return "modifier_stone_of_void_3_aura" end

--------------------------
-- STONE OF VOID 3 AURA --
--------------------------
if modifier_stone_of_void_3_aura == nil then modifier_stone_of_void_3_aura = class({}) end
function modifier_stone_of_void_3_aura:IsHidden() return false end
function modifier_stone_of_void_3_aura:IsDebuff() return false end
function modifier_stone_of_void_3_aura:IsPurgable() return false end
function modifier_stone_of_void_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_stone_of_void_3_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT}
end
function modifier_stone_of_void_3_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
function modifier_stone_of_void_3_aura:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_aura") end
end
function modifier_stone_of_void_3_aura:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion_aura") end
end


--------------
-- Moonfall --
--------------
LinkLuaModifier("modifier_moonfall", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moonfall_aura", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moonfall_buff", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moonfall_debuff", "items/stone_of_void.lua", LUA_MODIFIER_MOTION_NONE)
if item_moonfall == nil then item_moonfall = class({}) end
function item_moonfall:GetCastRange() return self:GetSpecialValueFor("aura_radius") end
function item_moonfall:GetIntrinsicModifierName() return "modifier_moonfall" end
function item_moonfall:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	target:EmitSound("Blink_Layer.Arcane")
	target:EmitSound("Blink_Layer.Swift")
    if target:GetTeam() == caster:GetTeam() then
		target:AddNewModifier(self:GetCaster(), self, "modifier_moonfall_buff", {duration = self:GetSpecialValueFor("duration")})
		target:EmitSound("Item.StarEmblem.Friendly")
    else
		target:AddNewModifier(self:GetCaster(), self, "modifier_moonfall_debuff", {duration = self:GetSpecialValueFor("duration")})
		target:EmitSound("Item.StarEmblem.Enemy")
    end
end

if modifier_moonfall == nil then modifier_moonfall = class({}) end
function modifier_moonfall:IsHidden() return true end
function modifier_moonfall:IsPurgable() return false end
function modifier_moonfall:RemoveOnDeath() return false end
function modifier_moonfall:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_moonfall:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT}
end
function modifier_moonfall:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_moonfall:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_moonfall:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_moonfall:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_moonfall:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("speed") end
end
function modifier_moonfall:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion_self") end
end
function modifier_moonfall:IsAura() return true end
function modifier_moonfall:IsAuraActiveOnDeath() return false end
function modifier_moonfall:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_moonfall:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_moonfall:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_moonfall:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_moonfall:GetAuraDuration() return FrameTime() end
function modifier_moonfall:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_moonfall:GetModifierAura() return "modifier_moonfall_aura" end

-------------------
-- Moonfall AURA --
-------------------
if modifier_moonfall_aura == nil then modifier_moonfall_aura = class({}) end
function modifier_moonfall_aura:IsHidden() return false end
function modifier_moonfall_aura:IsDebuff() return false end
function modifier_moonfall_aura:IsPurgable() return false end
function modifier_moonfall_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_moonfall_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT}
end
function modifier_moonfall_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
function modifier_moonfall_aura:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_aura") end
end
function modifier_moonfall_aura:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion_aura") end
end

-------------------
-- Moonfall BUFF --
-------------------
if modifier_moonfall_buff == nil then modifier_moonfall_buff = class({}) end
function modifier_moonfall_buff:IsHidden() return false end
function modifier_moonfall_buff:IsDebuff() return false end
function modifier_moonfall_buff:IsPurgable() return true end
function modifier_moonfall_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_moonfall_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_moonfall_buff:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_buff") end
end
function modifier_moonfall_buff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_buff") end
end
function modifier_moonfall_buff:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end

---------------------
-- Moonfall DEBUFF --
---------------------
if modifier_moonfall_debuff == nil then modifier_moonfall_debuff = class({}) end
function modifier_moonfall_debuff:IsHidden() return false end
function modifier_moonfall_debuff:IsDebuff() return true end
function modifier_moonfall_debuff:IsPurgable() return false end
function modifier_moonfall_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_moonfall_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_moonfall_debuff:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_debuff") * (-1) end
end
function modifier_moonfall_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_debuff") * (-1) end
end
function modifier_moonfall_debuff:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") * (-1) end
end