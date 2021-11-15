-- Item Bonus
bonus_damage = 77
bonus_damage_pct = 66

-- Crit Chance
base_crit_chance = 6
bonus_crit_chance = 4

-- Crit Damage
base_crit_dmg = 777
bonus_crit_dmg_per_lvl = 6
bonus_crit_dmg_per_lvl_66 = 12

-- Up Bonus
up_duration = 10
up_pct_per_stack = 1
up_max_effect = 20
----------------------------------------

LinkLuaModifier("modifier_item_imba_greater_crit_edible", "items/item_crit_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_greater_crit_edible_buff", "items/item_crit_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mana_blade_up_edible", "items/item_crit_edible.lua", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------------------------------------
--	Edible item
-----------------------------------------------------------------------------------------------------------
local edible_crit = "modifier_item_imba_greater_crit_edible"
local item_crit = "modifier_item_imba_greater_crit"

if item_crit_edible == nil then item_crit_edible = class({}) end
function item_crit_edible:OnSpellStart()
	local caster = self:GetCaster()
	if not caster:IsRealHero() or caster:HasModifier("modifier_arc_warden_tempest_double") or caster:HasModifier(edible_crit) or caster:HasModifier(item_crit) then return end
	caster:AddNewModifier(caster, self, edible_crit, {})
	caster:EmitSound("Hero_Alchemist.Scepter.Cast")
	caster:RemoveItem(self)
end

-----------------------------------------------------------------------------------------------------------
--	Daedalus owner bonus attributes
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_greater_crit_edible == nil then modifier_item_imba_greater_crit_edible = class({}) end
function modifier_item_imba_greater_crit_edible:IsHidden() return false end
function modifier_item_imba_greater_crit_edible:IsDebuff() return false end
function modifier_item_imba_greater_crit_edible:IsPurgable() return false end
function modifier_item_imba_greater_crit_edible:IsPermanent() return true end
function modifier_item_imba_greater_crit_edible:RemoveOnDeath() return false end
function modifier_item_imba_greater_crit_edible:AllowIllusionDuplicate() return true end
function modifier_item_imba_greater_crit_edible:GetTexture() return "custom/imba_greater_crit_edible" end
function modifier_item_imba_greater_crit_edible:OnCreated()
	local parent = self:GetParent()
	local level = parent:GetLevel()
	if IsServer() then
		if not parent:HasModifier("modifier_item_imba_greater_crit_edible_buff") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_imba_greater_crit_edible_buff", {})
		end
		
		if not parent:IsRealHero() then return nil end


		self:StartIntervalThink(FrameTime())
	end
	self.base_damage = bonus_damage * level
	self.bonus_damage_pct = bonus_damage_pct	
end
function modifier_item_imba_greater_crit_edible:OnIntervalThink() self:OnCreated() end	
function modifier_item_imba_greater_crit_edible:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_item_imba_greater_crit_edible:GetModifierBaseAttack_BonusDamage() return self.base_damage end
function modifier_item_imba_greater_crit_edible:GetModifierBaseDamageOutgoing_Percentage() return self.bonus_damage_pct end
function modifier_item_imba_greater_crit_edible:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_imba_greater_crit_edible") then
			parent:RemoveModifierByName("modifier_item_imba_greater_crit_edible_buff")
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- Edible Daedalus crit damage buff
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_greater_crit_edible_buff == nil then modifier_item_imba_greater_crit_edible_buff = class({}) end
function modifier_item_imba_greater_crit_edible_buff:IsHidden() return true end
function modifier_item_imba_greater_crit_edible_buff:IsDebuff() return false end
function modifier_item_imba_greater_crit_edible_buff:IsPurgable() return false end
function modifier_item_imba_greater_crit_edible_buff:IsPermanent() return true end
--function modifier_item_imba_greater_crit_edible_buff:GetTexture() return "custom/imba_greater_crit_edible" end
function modifier_item_imba_greater_crit_edible_buff:OnCreated()
	local parent = self:GetParent()
	local level = parent:GetLevel()
	local base_crit_dmg = base_crit_dmg
	local crit_increase = bonus_crit_dmg_per_lvl * level
	local crit_chance = base_crit_chance
	if IsServer() then
		if parent:HasScepter() then
			crit_chance = crit_chance + bonus_crit_chance
		end
		if parent:HasModifier("modifier_mana_blade_aura_emitter") and parent:HasModifier("modifier_mana_blade_up_edible") then
			crit_chance = crit_chance + parent:FindModifierByName("modifier_mana_blade_up_edible"):GetStackCount()
		end
		if HasSuperScepter(parent) then
			if level >= 66 then
				crit_increase = bonus_crit_dmg_per_lvl_66 * level
			end
			crit_increase = crit_increase * 2
		end
	end
	self.crit_chance = crit_chance
	self.crit_damage = crit_increase + base_crit_dmg
	self:StartIntervalThink(FrameTime())
end
function modifier_item_imba_greater_crit_edible_buff:OnIntervalThink() self:OnCreated() end
function modifier_item_imba_greater_crit_edible_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end
function modifier_item_imba_greater_crit_edible_buff:GetModifierPreAttack_CriticalStrike()
	local parent = self:GetParent()
	if RollPseudoRandomPercentage(self.crit_chance, 0, parent) then
		if parent:HasModifier("modifier_mana_blade_aura_emitter") then
			if parent:HasModifier("modifier_mana_blade_up_edible") then
				local devils_up = parent:FindModifierByName("modifier_mana_blade_up_edible")
				devils_up:SetStackCount(devils_up:GetStackCount() + up_pct_per_stack)
				if devils_up:GetStackCount() > up_max_effect then
					devils_up:SetStackCount(up_max_effect)
				end
			else
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_mana_blade_up_edible", {duration = up_duration})
			end
		end
		return self.crit_damage
	end
end

-------------------
-- Mana Blade UP --
-------------------
if modifier_mana_blade_up_edible == nil then modifier_mana_blade_up_edible = class({}) end
function modifier_mana_blade_up_edible:IsHidden() return false end
function modifier_mana_blade_up_edible:IsDebuff() return false end
function modifier_mana_blade_up_edible:IsPurgable() return false end
function modifier_mana_blade_up_edible:GetTexture() return "custom/imba_greater_crit_edible" end
function modifier_mana_blade_up_edible:OnCreated()
	self:SetStackCount(up_pct_per_stack)
end
function modifier_mana_blade_up_edible:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_mana_blade_up_edible:OnTooltip() return self:GetStackCount() end
