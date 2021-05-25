ocratine1 = "modifier_custom_octarine_core_1"
ocratine2 = "modifier_bigan_octarine_core"
ocratine3 = "modifier_bigan_octarine_core_edible"
ocratine3_eated = "modifier_bigan_octarine_core_edible_eated"
ipomoea_aquatica = "modifier_item_mjz_ipomoea_aquatica"

LinkLuaModifier(ocratine1, "items/octarine_cores.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(ocratine2, "items/octarine_cores.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(ocratine3, "items/octarine_cores.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(ocratine3_eated, "items/octarine_cores.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(ipomoea_aquatica, "items/octarine_cores.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_octarine_core_cdr", "items/octarine_cores.lua", LUA_MODIFIER_MOTION_NONE)

item_custom_octarine_core_1 = class({})
function item_custom_octarine_core_1:GetIntrinsicModifierName() return ocratine1 end

item_bigan_octarine_core = class({})
function item_bigan_octarine_core:GetIntrinsicModifierName() return ocratine2 end

item_custom_octarine_core2 = class({})
function item_custom_octarine_core2:GetIntrinsicModifierName() return ocratine3 end
function item_custom_octarine_core2:OnSpellStart()
	 if IsServer() then
		local caster = self:GetCaster()
		if caster:HasModifier(ocratine3_eated) then return nil end
		caster:AddNewModifier(caster, nil, ocratine3_eated, {})
		caster:EmitSound("Hero_Alchemist.Scepter.Cast")
		caster:RemoveItem(self)
 	end
end

item_mjz_ipomoea_aquatica = class({})
function item_mjz_ipomoea_aquatica:GetIntrinsicModifierName() return ipomoea_aquatica end

-------------------
-- Octarine Core --
-------------------
modifier_custom_octarine_core_1 = class({})
function modifier_custom_octarine_core_1:IsHidden() return true end
function modifier_custom_octarine_core_1:IsPurgable() return false end
function modifier_custom_octarine_core_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_custom_octarine_core_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_custom_octarine_core_1:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasModifier(ocratine1) and not self:GetCaster():HasModifier(ocratine2) and not self:GetCaster():HasModifier(ocratine3) and not self:GetCaster():HasModifier(ocratine3_eated) then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_octarine_core_cdr", {})
		else
			self:GetCaster():RemoveModifierByName("modifier_octarine_core_cdr")
		end
	end
end
function modifier_custom_octarine_core_1:OnDestroy()
	if IsServer() then self:GetCaster():RemoveModifierByName("modifier_octarine_core_cdr") end
end
function modifier_custom_octarine_core_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_custom_octarine_core_1:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_custom_octarine_core_1:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana") end
end
function modifier_custom_octarine_core_1:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_intelligence") end
end

---------------------------
-- BiGan's Octarine Core --
---------------------------
modifier_bigan_octarine_core = class({})
function modifier_bigan_octarine_core:IsHidden() return true end
function modifier_bigan_octarine_core:IsPurgable() return false end
function modifier_bigan_octarine_core:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_bigan_octarine_core:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_bigan_octarine_core:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasModifier(ocratine2) and not self:GetCaster():HasModifier(ocratine3) and not self:GetCaster():HasModifier(ocratine3_eated) then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_octarine_core_cdr", {})
		else
			self:GetCaster():RemoveModifierByName("modifier_octarine_core_cdr")
		end
	end
end
function modifier_bigan_octarine_core:OnDestroy()
	if IsServer() then self:GetCaster():RemoveModifierByName("modifier_octarine_core_cdr") end
end
function modifier_bigan_octarine_core:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_bigan_octarine_core:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_bigan_octarine_core:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana") end
end
function modifier_bigan_octarine_core:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_intelligence") end
end

----------------------------------
-- Edible Bigan's Octarine Core --
----------------------------------
modifier_bigan_octarine_core_edible = class({})
function modifier_bigan_octarine_core_edible:IsHidden() return true end
function modifier_bigan_octarine_core_edible:IsPurgable() return false end
function modifier_bigan_octarine_core_edible:AllowIllusionDuplicate() return true end
function modifier_bigan_octarine_core_edible:RemoveOnDeath() return false end
function modifier_bigan_octarine_core_edible:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_bigan_octarine_core_edible:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_bigan_octarine_core_edible:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasModifier(ocratine3) and not self:GetCaster():HasModifier(ocratine3_eated) then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_octarine_core_cdr", {})
		else
			self:GetCaster():RemoveModifierByName("modifier_octarine_core_cdr")
		end
	end
end
function modifier_bigan_octarine_core_edible:OnDestroy()
	if IsServer() then self:GetCaster():RemoveModifierByName("modifier_octarine_core_cdr") end
end
function modifier_bigan_octarine_core_edible:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_bigan_octarine_core_edible:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_bigan_octarine_core_edible:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana") end
end
function modifier_bigan_octarine_core_edible:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_intelligence") end
end

----------------------------------------
-- Edible Bigan's Octarine Core Eated --
----------------------------------------
modifier_bigan_octarine_core_edible_eated = modifier_bigan_octarine_core_edible_eated or class({})
function modifier_bigan_octarine_core_edible_eated:IsHidden() return false end
function modifier_bigan_octarine_core_edible_eated:IsPurgable() return false end
function modifier_bigan_octarine_core_edible_eated:AllowIllusionDuplicate() return true end
function modifier_bigan_octarine_core_edible_eated:GetTexture() return "bigan_octarine_core_edible" end
function modifier_bigan_octarine_core_edible_eated:OnCreated()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_bigan_octarine_core_edible_eated:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasModifier(ocratine3_eated) then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_octarine_core_cdr", {})
		else
			self:GetCaster():RemoveModifierByName("modifier_octarine_core_cdr")
		end
	end
end
--[[
function modifier_bigan_octarine_core_edible_eated:OnDestroy()
	if IsServer() then self:GetCaster():RemoveModifierByName("modifier_octarine_core_cdr") end
end
]]
function modifier_bigan_octarine_core_edible_eated:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_bigan_octarine_core_edible_eated:GetModifierHealthBonus()
	return 3500
end
function modifier_bigan_octarine_core_edible_eated:GetModifierManaBonus()
	return 3500
end
function modifier_bigan_octarine_core_edible_eated:GetModifierBonusStats_Intellect()
	return 190
end

----------------------
-- Ipomoea Aquatica --
----------------------
modifier_item_mjz_ipomoea_aquatica = class({})
function modifier_item_mjz_ipomoea_aquatica:IsHidden() return true end
function modifier_item_mjz_ipomoea_aquatica:IsPurgable() return false end
function modifier_item_mjz_ipomoea_aquatica:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_mjz_ipomoea_aquatica:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_item_mjz_ipomoea_aquatica:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_item_mjz_ipomoea_aquatica:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana") end
end
function modifier_item_mjz_ipomoea_aquatica:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_intelligence") end
end
function modifier_item_mjz_ipomoea_aquatica:GetModifierPureSpellLifesteal()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("lifesteal") end
end


---------------------------------------------------------------------------
--------------------------- CDR Unique Modifier ---------------------------
---------------------------------------------------------------------------
modifier_octarine_core_cdr = class({})
function modifier_octarine_core_cdr:IsHidden() return true end
function modifier_octarine_core_cdr:IsPurgable() return false end
function modifier_octarine_core_cdr:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_octarine_core_cdr:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end
function modifier_octarine_core_cdr:GetModifierPureSpellLifesteal()
	if self:GetCaster():HasModifier(ocratine3_eated) then
		return 2
	end
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("lifesteal")
	end
end
function modifier_octarine_core_cdr:GetModifierPercentageCooldown()
	if self:GetCaster():HasModifier(ocratine3_eated) then
		return 45
	end
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_cooldown")
	end
end
