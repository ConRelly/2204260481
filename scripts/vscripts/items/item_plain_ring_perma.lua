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
	if not caster:IsAlive() then return end
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
			caster:AddNewModifier(caster, ability, "modifier_item_plain_ring_perma", {})
			caster:AddNewModifier(caster, ability, "modifier_item_plain_ring_perma_armor", {})
			if caster:HasModifier("modifier_item_plain_ring_perma_armor") then
				caster:FindModifierByName("modifier_item_plain_ring_perma_armor"):SetStackCount(bonus_armor)
			end	
		end
		if ability:GetCurrentCharges() > 1 then
			ability:SpendCharge()
		else
			caster:RemoveItem(ability)
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
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_item_plain_ring_perma:GetPriority()
	return MODIFIER_PRIORITY_LOW 
end
function modifier_item_plain_ring_perma:OnCreated()
	if IsServer() then
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.parent:AddNewModifier(self.parent, self.ability, "modifier_ring_invincibility_cd", {})
	end
end
function modifier_item_plain_ring_perma:OnTakeDamage(keys)
	if IsServer() then
		if keys.unit ~= self.parent then return end
		local aegis_charges = self.parent:FindModifierByName("modifier_aegis")
		if aegis_charges and aegis_charges:GetStackCount() > 0 then return end
		if self.parent:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") then return end
		--if self.parent:HasModifier("modifier_item_helm_of_the_undying_active") then return nil end
		if self.parent:IsReincarnating() then return end
		local unit = keys.unit
		local attacker = keys.attacker
		if unit == self.parent then
			--local damage = keys.damage
			if self.parent:FindModifierByName("modifier_ring_invincibility_cd"):GetStackCount() == 0 then
				if self.parent:GetHealth() <= 0 then
					if self.parent:HasModifier("modifier_brewmaster_primal_split") then return end
					if IsUndyingRdy(unit) then return end
					unit:SetHealth(1000)
					Timers:CreateTimer({
						endTime = 0.001, 
						callback = function()
							if not unit:IsAlive() then
								local rezPosition = unit:GetAbsOrigin()						
								unit:RespawnHero(false, false)
								unit:SetAbsOrigin(rezPosition)
								unit:AddNewModifier(unit, self.ability, "modifier_item_plain_ring_perma_invincibility", {duration = inv_duration})
							end	
						end
					})
					unit:AddNewModifier(unit, self.ability, "modifier_item_plain_ring_perma_invincibility", {duration = inv_duration})
					local cooldown = cooldown
					if unit:HasModifier("modifier_plain_ring_perma_up") then
						cooldown = cooldown - cooldown_reduction
					end
					unit:FindModifierByName("modifier_ring_invincibility_cd"):SetStackCount(cooldown + 1)
					unit:FindModifierByName("modifier_ring_invincibility_cd"):StartIntervalThink(1)
					unit:FindModifierByName("modifier_ring_invincibility_cd"):OnIntervalThink()
				end
			end
		end
	end
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
	return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end
function modifier_item_plain_ring_perma_invincibility:GetMinHealth() return 1 end
function modifier_item_plain_ring_perma_invincibility:GetModifierIncomingDamage_Percentage() return -400 end
function modifier_item_plain_ring_perma_invincibility:GetModifierTotal_ConstantBlock(params) return params.damage end
function modifier_item_plain_ring_perma_invincibility:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		if parent:HasModifier("modifier_item_plain_ring_perma") then --Lifeguard skill (jotaro3) triggers this(invincibility) modifier
			parent:FindModifierByName("modifier_item_plain_ring_perma"):SetStackCount(1)
		end	
		self.min_health = min_health
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
			local GoldRingMod = self:GetParent():FindModifierByName("modifier_item_plain_ring_perma")
			if GoldRingMod then
				GoldRingMod:SetStackCount(0)
				self:StartIntervalThink(-1)
			end
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


