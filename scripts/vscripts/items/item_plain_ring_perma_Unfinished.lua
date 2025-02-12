require("lib/my")

local inv_duration = 6
local min_health = 25
local cooldown = 50
local cooldown_reduction = 10
local bonus_armor = 20

LinkLuaModifier("modifier_item_plain_ring_perma", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring_perma_armor", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring_perma_invincibility", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ring_invincibility_cd", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_plain_ring_perma_up", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)


function add_perma(keys)
	local caster = keys.caster
	local ability = keys.ability

	local cooldown = ability:GetSpecialValueFor("cooldown")
	local cooldown_reduction = ability:GetSpecialValueFor("cooldown_reduction")
	local inv_duration = ability:GetSpecialValueFor("inv_duration")
	local bonus_armor = ability:GetSpecialValueFor("bonus_armor")
	local min_health = ability:GetSpecialValueFor("min_health")
	if caster:HasModifier("modifier_plain_ring_perma_up") then return end
	if caster:IsHero() and not caster:HasModifier("modifier_arc_warden_tempest_double") then
		if caster:HasModifier("modifier_item_plain_ring_perma") then
			caster:AddNewModifier(caster, ability, "modifier_plain_ring_perma_up", {})
			local inv_cd = caster:FindModifierByName("modifier_ring_invincibility_cd")
			local cooldown_reduction = cooldown_reduction
			if inv_cd:GetStackCount() >= cooldown_reduction then
				inv_cd:SetStackCount(inv_cd:GetStackCount() - cooldown_reduction)
			else
				inv_cd:SetStackCount(0)
			end

			local gold_ring_effect = ParticleManager:CreateParticle("particles/custom/items/gold_ring/gold_ring_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:ReleaseParticleIndex(gold_ring_effect)
--[[
			caster:ModifyGold(ability:GetCost() * (33 / 100), true, 0)
			SendOverheadEventMessage(PlayerResource:GetPlayer(caster:GetPlayerOwnerID()), OVERHEAD_ALERT_GOLD, caster, ability:GetCost() * (33 / 100), nil)
]]
		else
			caster:AddNewModifier(caster, ability, "modifier_item_plain_ring_perma", {cooldown = cooldown, cooldown_reduction = cooldown_reduction, inv_duration = inv_duration, min_health = min_health, duration = -1})
			local armor_modifier = caster:AddNewModifier(caster, ability, "modifier_item_plain_ring_perma_armor", {})
			armor_modifier:SetStackCount(bonus_armor)
		end
		if ability:GetCurrentCharges() > 1 then
			ability:SpendCharge(0.01)
		else
			--caster:RemoveItem(ability)
			caster:TakeItem(ability)
		end
	end
end



------------------
-- Perma Effect --
------------------
modifier_item_plain_ring_perma = class({})
function modifier_item_plain_ring_perma:GetTexture() return "plain_ring" end
function modifier_item_plain_ring_perma:IsHidden() return (self:GetStackCount() == 1) end
function modifier_item_plain_ring_perma:IsPurgable() return false end
function modifier_item_plain_ring_perma:RemoveOnDeath() return false end
function modifier_item_plain_ring_perma:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH_PREVENTED}
end
function modifier_item_plain_ring_perma:OnCreated(keys)
	self.cooldown = keys.cooldown
	self.cooldown_reduction = keys.cooldown_reduction
	self.inv_duration = keys.inv_duration
	self.min_health = keys.min_health

	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ring_invincibility_cd", {})
	end
end
function modifier_item_plain_ring_perma:OnDeathPrevented(params)
	if IsServer() then
		local parent = self:GetParent()
		
		local aegis_charges = self:GetParent():FindModifierByName("modifier_aegis")
		if aegis_charges and aegis_charges:GetStackCount() > 0 then return end
		if self:GetParent():IsReincarnating() then return end
		if self:GetParent():FindModifierByName("modifier_ring_invincibility_cd"):GetStackCount() ~= 0 then return end
		if self:GetParent():HasModifier("modifier_item_plain_ring_perma_invincibility") then return end
		if self:GetParent():HasModifier("modifier_brewmaster_primal_split") then return end
		if IsUndyingRdy(self:GetParent()) == true then return end
		
		if parent == params.unit and parent:IsAlive() then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_plain_ring_perma_invincibility", {min_health = self.min_health, duration = self.inv_duration})
			local cooldown = self.cooldown
			if parent:HasModifier("modifier_plain_ring_perma_up") then
				cooldown = self.cooldown - self.cooldown_reduction
			end
			parent:FindModifierByName("modifier_ring_invincibility_cd"):SetStackCount(cooldown + 1)
			parent:FindModifierByName("modifier_ring_invincibility_cd"):StartIntervalThink(1)
			parent:FindModifierByName("modifier_ring_invincibility_cd"):OnIntervalThink()
		end
	end
end
function modifier_item_plain_ring_perma:GetMinHealth()
	self.DeathPrevented = false
	local aegis_charges = self:GetParent():FindModifierByName("modifier_aegis")
	if aegis_charges and aegis_charges:GetStackCount() > 0 then return end
	if self:GetParent():IsReincarnating() then return end
	if self:GetParent():FindModifierByName("modifier_ring_invincibility_cd"):GetStackCount() ~= 0 then return end
	if self:GetParent():HasModifier("modifier_item_plain_ring_perma_invincibility") then return end
	if self:GetParent():HasModifier("modifier_brewmaster_primal_split") then return end
	if IsUndyingRdy(self:GetParent()) == true then return end
	self.DeathPrevented = true
	return 1
end
function IsUndyingRdy(unit)
	local Item = unit:GetItemInSlot(16)
	if Item ~= nil and IsValidEntity(Item) then
		if Item:GetName() == "item_helm_of_the_undying" then
			if Item:IsCooldownReady() then
				return true
			end	
		end	
	end
	if unit:HasModifier("modifier_item_helm_of_the_undying_active") then
		return true
	end
	return false	
end


--------------------
-- Armor Modifier --
--------------------
modifier_item_plain_ring_perma_armor = class({})
function modifier_item_plain_ring_perma_armor:IsHidden() return true end
function modifier_item_plain_ring_perma_armor:IsPurgable() return false end
function modifier_item_plain_ring_perma_armor:RemoveOnDeath() return false end
function modifier_item_plain_ring_perma_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_item_plain_ring_perma_armor:GetModifierPhysicalArmorBonus() return self:GetStackCount() end

------------------------
-- Invincibility Buff --
------------------------
modifier_item_plain_ring_perma_invincibility = class({})
function modifier_item_plain_ring_perma_invincibility:IsPurgable() return false end
function modifier_item_plain_ring_perma_invincibility:GetTexture() return "plain_ring_invincibility" end
function modifier_item_plain_ring_perma_invincibility:GetEffectName() return "particles/world_shrine/dire_shrine_regen.vpcf" end
function modifier_item_plain_ring_perma_invincibility:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_plain_ring_perma_invincibility:DeclareFunctions()
	return {MODIFIER_PROPERTY_heal, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end
function modifier_item_plain_ring_perma_invincibility:GetMinHealth() return 1 end
function modifier_item_plain_ring_perma_invincibility:GetModifierIncomingDamage_Percentage() return -400 end
function modifier_item_plain_ring_perma_invincibility:GetModifierTotal_ConstantBlock(params) return params.damage end
function modifier_item_plain_ring_perma_invincibility:OnCreated(keys)
	self.min_health = keys.min_health
	if IsServer() then
		local parent = self:GetParent()
		parent:FindModifierByName("modifier_item_plain_ring_perma"):SetStackCount(1)
	end
end
function modifier_item_plain_ring_perma_invincibility:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		parent:Heal((parent:GetMaxHealth() * self.min_health * 0.01), parent)
	end
end

---------------------------
-- Invincibility Buff CD --
---------------------------
modifier_ring_invincibility_cd = class({})
function modifier_ring_invincibility_cd:IsHidden() return (self:GetStackCount() == 0) end
function modifier_ring_invincibility_cd:GetTexture() return "plain_ring" end
function modifier_ring_invincibility_cd:IsDebuff() return true end
function modifier_ring_invincibility_cd:IsPurgable() return false end
function modifier_ring_invincibility_cd:RemoveOnDeath() return false end
function modifier_ring_invincibility_cd:OnCreated()
	if IsServer() then self:StartIntervalThink(1) end
end
function modifier_ring_invincibility_cd:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() > 0 then
			local duration = self:GetStackCount() - 1
			self:SetStackCount(duration)
		end
		if self:GetStackCount() == 0 then
			self:GetParent():FindModifierByName("modifier_item_plain_ring_perma"):SetStackCount(0)
			self:StartIntervalThink(-1)
		end
	end
end

-----------------
-- UP Modifier --
-----------------
modifier_plain_ring_perma_up = class({})
function modifier_plain_ring_perma_up:IsHidden() return true end
function modifier_plain_ring_perma_up:IsPurgable() return false end
function modifier_plain_ring_perma_up:RemoveOnDeath() return false end


