--TIER_1--
LinkLuaModifier("modifier_tier_1", "items/portal.lua", LUA_MODIFIER_MOTION_NONE)
if item_portal_1 == nil then item_portal_1 = class({}) end
function item_portal_1:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	if caster:HasModifier("modifier_tier_1") or caster:HasModifier("modifier_tier_2") or caster:HasModifier("modifier_tier_3") or caster:HasModifier("modifier_tier_4") or caster:HasModifier("modifier_tier_5") or caster:HasModifier("modifier_tier_6") or caster:HasModifier("modifier_tier_7") then return nil end
	caster:RemoveItem(ability)
	caster:AddNewModifier(caster, ability, "modifier_tier_1", {})
end
modifier_tier_1 = modifier_tier_1 or class({})
function modifier_tier_1:GetTexture() return "custom/portal_1" end
function modifier_tier_1:IsHidden() return false end
function modifier_tier_1:IsPurgable() return false end
function modifier_tier_1:RemoveOnDeath() return false end

--TIER_2--
LinkLuaModifier("modifier_tier_2", "items/portal.lua", LUA_MODIFIER_MOTION_NONE)
if item_portal_2 == nil then item_portal_2 = class({}) end
function item_portal_2:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	if caster:HasModifier("modifier_tier_2") or caster:HasModifier("modifier_tier_3") or caster:HasModifier("modifier_tier_4") or caster:HasModifier("modifier_tier_5") or caster:HasModifier("modifier_tier_6") or caster:HasModifier("modifier_tier_7") then return nil end
	caster:RemoveItem(ability)
	if caster:HasModifier("modifier_tier_1") then caster:RemoveModifierByName("modifier_tier_1") end
	caster:AddNewModifier(caster, ability, "modifier_tier_2", {})
end
modifier_tier_2 = modifier_tier_2 or class({})
function modifier_tier_2:GetTexture() return "custom/portal_2" end
function modifier_tier_2:IsHidden() return false end
function modifier_tier_2:IsPurgable() return false end
function modifier_tier_2:RemoveOnDeath() return false end

--TIER_3--
LinkLuaModifier("modifier_tier_3", "items/portal.lua", LUA_MODIFIER_MOTION_NONE)
if item_portal_3 == nil then item_portal_3 = class({}) end
function item_portal_3:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	if caster:HasModifier("modifier_tier_3") or caster:HasModifier("modifier_tier_4") or caster:HasModifier("modifier_tier_5") or caster:HasModifier("modifier_tier_6") or caster:HasModifier("modifier_tier_7") then return nil end
	caster:RemoveItem(ability)
	if caster:HasModifier("modifier_tier_1") or caster:HasModifier("modifier_tier_2") then caster:RemoveModifierByName("modifier_tier_1") caster:RemoveModifierByName("modifier_tier_2") end
	caster:AddNewModifier(caster, ability, "modifier_tier_3", {})
end
modifier_tier_3 = modifier_tier_3 or class({})
function modifier_tier_3:GetTexture() return "custom/portal_3" end
function modifier_tier_3:IsHidden() return false end
function modifier_tier_3:IsPurgable() return false end
function modifier_tier_3:RemoveOnDeath() return false end

--TIER_4--
LinkLuaModifier("modifier_tier_4", "items/portal.lua", LUA_MODIFIER_MOTION_NONE)
if item_portal_4 == nil then item_portal_4 = class({}) end
function item_portal_4:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	if caster:HasModifier("modifier_tier_4") or caster:HasModifier("modifier_tier_5") or caster:HasModifier("modifier_tier_6") or caster:HasModifier("modifier_tier_7") then return nil end
	caster:RemoveItem(ability)
	if caster:HasModifier("modifier_tier_1") or caster:HasModifier("modifier_tier_2") or caster:HasModifier("modifier_tier_3") then caster:RemoveModifierByName("modifier_tier_1") caster:RemoveModifierByName("modifier_tier_2") caster:RemoveModifierByName("modifier_tier_3") end
	caster:AddNewModifier(caster, ability, "modifier_tier_4", {})
end
modifier_tier_4 = modifier_tier_4 or class({})
function modifier_tier_4:GetTexture() return "custom/portal_4" end
function modifier_tier_4:IsHidden() return false end
function modifier_tier_4:IsPurgable() return false end
function modifier_tier_4:RemoveOnDeath() return false end

--TIER_5--
LinkLuaModifier("modifier_tier_5", "items/portal.lua", LUA_MODIFIER_MOTION_NONE)
if item_portal_5 == nil then item_portal_5 = class({}) end
function item_portal_5:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	if caster:HasModifier("modifier_tier_5") or caster:HasModifier("modifier_tier_6") or caster:HasModifier("modifier_tier_7") then return nil end
	caster:RemoveItem(ability)
	if caster:HasModifier("modifier_tier_1") or caster:HasModifier("modifier_tier_2") or caster:HasModifier("modifier_tier_3") or caster:HasModifier("modifier_tier_4") then caster:RemoveModifierByName("modifier_tier_1") caster:RemoveModifierByName("modifier_tier_2") caster:RemoveModifierByName("modifier_tier_3") caster:RemoveModifierByName("modifier_tier_4") end
	caster:AddNewModifier(caster, ability, "modifier_tier_5", {})
end
modifier_tier_5 = modifier_tier_5 or class({})
function modifier_tier_5:GetTexture() return "custom/portal_5" end
function modifier_tier_5:IsHidden() return false end
function modifier_tier_5:IsPurgable() return false end
function modifier_tier_5:RemoveOnDeath() return false end

--TIER_6--
LinkLuaModifier("modifier_tier_6", "items/portal.lua", LUA_MODIFIER_MOTION_NONE)
if item_portal_6 == nil then item_portal_6 = class({}) end
function item_portal_6:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	if caster:HasModifier("modifier_tier_6") or caster:HasModifier("modifier_tier_7") then return nil end
	caster:RemoveItem(ability)
	if caster:HasModifier("modifier_tier_1") or caster:HasModifier("modifier_tier_2") or caster:HasModifier("modifier_tier_3") or caster:HasModifier("modifier_tier_4") or caster:HasModifier("modifier_tier_5") then caster:RemoveModifierByName("modifier_tier_1") caster:RemoveModifierByName("modifier_tier_2") caster:RemoveModifierByName("modifier_tier_3") caster:RemoveModifierByName("modifier_tier_4") caster:RemoveModifierByName("modifier_tier_5") end
	caster:AddNewModifier(caster, ability, "modifier_tier_6", {})
end
modifier_tier_6 = modifier_tier_6 or class({})
function modifier_tier_6:GetTexture() return "custom/portal_6" end
function modifier_tier_6:IsHidden() return false end
function modifier_tier_6:IsPurgable() return false end
function modifier_tier_6:RemoveOnDeath() return false end

--TIER_7--
LinkLuaModifier("modifier_tier_7", "items/portal.lua", LUA_MODIFIER_MOTION_NONE)
if item_portal_7 == nil then item_portal_7 = class({}) end
function item_portal_7:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	if caster:HasModifier("modifier_tier_7") then return nil end
	caster:RemoveItem(ability)
	if caster:HasModifier("modifier_tier_1") or caster:HasModifier("modifier_tier_2") or caster:HasModifier("modifier_tier_3") or caster:HasModifier("modifier_tier_4") or caster:HasModifier("modifier_tier_5") or caster:HasModifier("modifier_tier_6") then caster:RemoveModifierByName("modifier_tier_1") caster:RemoveModifierByName("modifier_tier_2") caster:RemoveModifierByName("modifier_tier_3") caster:RemoveModifierByName("modifier_tier_4") caster:RemoveModifierByName("modifier_tier_5") caster:RemoveModifierByName("modifier_tier_6") end
	caster:AddNewModifier(caster, ability, "modifier_tier_7", {})
end
modifier_tier_7 = modifier_tier_7 or class({})
function modifier_tier_7:GetTexture() return "custom/portal_7" end
function modifier_tier_7:IsHidden() return false end
function modifier_tier_7:IsPurgable() return false end
function modifier_tier_7:RemoveOnDeath() return false end
