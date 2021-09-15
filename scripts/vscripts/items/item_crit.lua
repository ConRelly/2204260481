-- Copyright (C) 2018  The Dota IMBA Development Team
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Editors:
--

--	Author: Firetoad
--	Date: 			21.07.2016
--	Last Update:	07.08.2017


-----------------------------------------------------------------------------------------------------------
--	Crystalys definition
-----------------------------------------------------------------------------------------------------------

if item_imba_lesser_crit == nil then item_imba_lesser_crit = class({}) end
LinkLuaModifier( "modifier_item_imba_lesser_crit", "items/item_crit.lua", LUA_MODIFIER_MOTION_NONE )		-- Owner's bonus attributes, stackable
LinkLuaModifier( "modifier_item_imba_lesser_crit_buff", "items/item_crit.lua", LUA_MODIFIER_MOTION_NONE )	-- Critical damage increase counter

function item_imba_lesser_crit:GetAbilityTextureName()
	return "item_lesser_crit"
end

function item_imba_lesser_crit:GetIntrinsicModifierName()
	return "modifier_item_imba_lesser_crit" end

-----------------------------------------------------------------------------------------------------------
--	Crystalys owner bonus attributes (stackable)
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_lesser_crit == nil then modifier_item_imba_lesser_crit = class({}) end
function modifier_item_imba_lesser_crit:IsHidden() return true end
function modifier_item_imba_lesser_crit:IsDebuff() return false end
function modifier_item_imba_lesser_crit:IsPurgable() return false end
function modifier_item_imba_lesser_crit:IsPermanent() return true end
function modifier_item_imba_lesser_crit:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- Adds the damage increase counter when created
function modifier_item_imba_lesser_crit:OnCreated(keys)
	
		self.ability = self:GetAbility()
		self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_imba_lesser_crit_buff") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_imba_lesser_crit_buff", {})
		end
	end
end


function modifier_item_imba_lesser_crit:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,}

	return decFuncs
end

function modifier_item_imba_lesser_crit:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

-- Removes the crit if Crystalys is not in the inventory
function modifier_item_imba_lesser_crit:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_imba_lesser_crit") then
			parent:RemoveModifierByName("modifier_item_imba_lesser_crit_buff")
		end
	end
end

-----------------------------------------------------------------------------------------------------------
--	Crystalys crit triggers
-----------------------------------------------------------------------------------------------------------
modifier_item_imba_lesser_crit_buff = modifier_item_imba_lesser_crit_buff or class({})
function modifier_item_imba_lesser_crit_buff:IsHidden() return true end
function modifier_item_imba_lesser_crit_buff:IsDebuff() return false end
function modifier_item_imba_lesser_crit_buff:IsPurgable() return false end

-- Track parameters to prevent errors if the item is unequipped
function modifier_item_imba_lesser_crit_buff:OnCreated()
	if IsServer() then
		self.base_crit = self:GetAbility():GetSpecialValueFor("base_crit")
		self.crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
	end
end

-- Declare modifier events/properties
function modifier_item_imba_lesser_crit_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
	return funcs
end

-- Grant the crit damage multiplier
function modifier_item_imba_lesser_crit_buff:GetModifierPreAttack_CriticalStrike(params)
	if IsServer() then
		if RollPercentage(self.crit_chance) then
			return self.base_crit
		else
			return nil
		end
	end
end



-----------------------------------------------------------------------------------------------------------
--	Daedalus definition
-----------------------------------------------------------------------------------------------------------

if item_imba_greater_crit == nil then item_imba_greater_crit = class({}) end
LinkLuaModifier( "modifier_item_imba_greater_crit", "items/item_crit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_imba_greater_crit_buff", "items/item_crit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_mana_blade_up", "items/item_crit.lua", LUA_MODIFIER_MOTION_NONE)

function item_imba_greater_crit:GetAbilityTextureName() return "custom/imba_greater_crit" end
function item_imba_greater_crit:GetIntrinsicModifierName() return "modifier_item_imba_greater_crit" end

-----------------------------------------------------------------------------------------------------------
--	Daedalus owner bonus attributes (stackable)
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_greater_crit == nil then modifier_item_imba_greater_crit = class({}) end
function modifier_item_imba_greater_crit:IsHidden() return true end
function modifier_item_imba_greater_crit:IsDebuff() return false end
function modifier_item_imba_greater_crit:IsPurgable() return false end
function modifier_item_imba_greater_crit:IsPermanent() return true end
--function modifier_item_imba_greater_crit:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_imba_greater_crit:OnCreated(keys)
	local parent = self:GetParent()
	if IsServer() then
		if not parent:HasModifier("modifier_item_imba_greater_crit_buff") and not parent:HasModifier("modifier_item_imba_greater_crit_edible") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_imba_greater_crit_buff", {})
		end
	
		if not parent:IsRealHero() or parent:HasModifier("modifier_item_imba_greater_crit_edible") then return end

		local level = parent:GetLevel()
		self.base_damage = self:GetAbility():GetSpecialValueFor("bonus_damage") * level
		self.bonus_damage_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")

		self:StartIntervalThink(FrameTime())
	end
end
function modifier_item_imba_greater_crit:OnIntervalThink() self:OnCreated(keys) end
function modifier_item_imba_greater_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_item_imba_greater_crit:GetModifierBaseAttack_BonusDamage() return self.base_damage end
function modifier_item_imba_greater_crit:GetModifierBaseDamageOutgoing_Percentage() return self.bonus_damage_pct end
function modifier_item_imba_greater_crit:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_imba_greater_crit") then
			parent:RemoveModifierByName("modifier_item_imba_greater_crit_buff")
		end
	end
end

-----------------------------------------------------------------------------------------------------------
--	Daedalus crit damage buff
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_greater_crit_buff == nil then modifier_item_imba_greater_crit_buff = class({}) end
function modifier_item_imba_greater_crit_buff:IsHidden() return true end
function modifier_item_imba_greater_crit_buff:IsDebuff() return false end
function modifier_item_imba_greater_crit_buff:IsPurgable() return false end
function modifier_item_imba_greater_crit_buff:IsPermanent() return true end
function modifier_item_imba_greater_crit_buff:GetTexture() return "imba_greater_crit" end
function modifier_item_imba_greater_crit_buff:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		local level = parent:GetLevel()
		self.base_crit = self:GetAbility():GetSpecialValueFor("base_crit")
		local crit_increase = self:GetAbility():GetSpecialValueFor("crit_increase") * level
		local crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
		local bonus_crit_chance = self:GetAbility():GetSpecialValueFor("bonus_crit_chance")
		
			if parent:HasScepter() then
				crit_chance = crit_chance + bonus_crit_chance
			end
			if parent:HasModifier("modifier_mana_blade_aura_emitter") and parent:HasModifier("modifier_mana_blade_up") then
				crit_chance = crit_chance + parent:FindModifierByName("modifier_mana_blade_up"):GetStackCount()
			end
			if HasSuperScepter(parent) then
				--[[ if level >= 66 then
					crit_increase = 12 * level
				end ]]
				crit_increase = crit_increase * 2
			end
		
		self.crit_chance = crit_chance
		self.crit_increase = crit_increase
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_item_imba_greater_crit_buff:OnIntervalThink() self:OnCreated() end
function modifier_item_imba_greater_crit_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end
function modifier_item_imba_greater_crit_buff:GetModifierPreAttack_CriticalStrike(params)
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if RollPseudoRandomPercentage(self.crit_chance, 0, parent) then
		if parent:HasModifier("modifier_mana_blade_aura_emitter") then
			if parent:HasModifier("modifier_mana_blade_up") then
				local up_pct_per_stack = ability:GetSpecialValueFor("up_pct_per_stack")
				local up_max_effect = ability:GetSpecialValueFor("up_max_effect")
				local devils_up = parent:FindModifierByName("modifier_mana_blade_up")
				devils_up:SetStackCount(devils_up:GetStackCount() + up_pct_per_stack)
				if devils_up:GetStackCount() > up_max_effect then
					devils_up:SetStackCount(up_max_effect)
				end
			else
				parent:AddNewModifier(parent, ability, "modifier_mana_blade_up", {duration = ability:GetSpecialValueFor("up_duration")})
			end
		end
		return self.base_crit + self.crit_increase
	end
end

-------------------
-- Mana Blade UP --
-------------------
if modifier_mana_blade_up == nil then modifier_mana_blade_up = class({}) end
function modifier_mana_blade_up:IsHidden() return false end
function modifier_mana_blade_up:IsDebuff() return false end
function modifier_mana_blade_up:IsPurgable() return false end
function modifier_mana_blade_up:OnCreated()
	if not IsServer() then return end
	local up_pct_per_stack = self:GetAbility():GetSpecialValueFor("up_pct_per_stack")
	self:SetStackCount(up_pct_per_stack)
end
function modifier_mana_blade_up:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_mana_blade_up:OnTooltip() return self:GetStackCount() end
