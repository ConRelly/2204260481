require("lib/my")

function add_perma(keys)
	if keys.caster:IsHero() and not keys.caster:HasModifier("modifier_arc_warden_tempest_double") then
		if keys.caster:HasModifier("modifier_item_plain_ring_perma") then
			local inv_cd = keys.caster:FindModifierByName("modifier_ring_invincibility_cd")
			local cd_reduct = keys.ability:GetSpecialValueFor("cd_reduct")
			if inv_cd:GetStackCount() >= cd_reduct then
				inv_cd:SetStackCount(inv_cd:GetStackCount() - cd_reduct)
			else
				inv_cd:SetStackCount(0)
			end
			keys.caster:ModifyGold(keys.ability:GetCost() * (keys.ability:GetSpecialValueFor("refund") / 100), true, 0)
			SendOverheadEventMessage(PlayerResource:GetPlayer(keys.caster:GetPlayerOwnerID()), OVERHEAD_ALERT_GOLD, keys.caster, keys.ability:GetCost() * (keys.ability:GetSpecialValueFor("refund") / 100), nil)
		else
			keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_plain_ring_perma", {duration = -1, invincibility_duration = keys.ability:GetSpecialValueFor("duration"), cooldown = keys.ability:GetSpecialValueFor("cooldown"), min_health = keys.ability:GetSpecialValueFor("min_health")})
			keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_plain_ring_perma_armor", {})
		end
		if keys.ability:GetCurrentCharges() >= 1 then
			keys.ability:SpendCharge()
		else
			keys.caster:RemoveItem(keys.ability)
		end
	end
end


LinkLuaModifier("modifier_item_plain_ring_perma", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring_perma_armor", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring_perma_invincibility", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ring_invincibility_cd", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)

------------------
-- Perma Effect --
------------------
modifier_item_plain_ring_perma = class({})
function modifier_item_plain_ring_perma:GetTexture() return "plain_ring" end
function modifier_item_plain_ring_perma:IsHidden()
	return (self:GetStackCount() == 1)
end
function modifier_item_plain_ring_perma:IsPurgable() return false end
function modifier_item_plain_ring_perma:RemoveOnDeath() return false end
function modifier_item_plain_ring_perma:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_plain_ring_perma:OnCreated(keys)
	if IsServer() then
		self.parent = self:GetCaster()
		self.ability = self:GetAbility()
		self.invincibility_duration = keys.invincibility_duration
		self.min_health = keys.min_health
		self.cooldown = keys.cooldown
		self.parent:AddNewModifier(self.parent, self.ability, "modifier_ring_invincibility_cd", {})
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_item_plain_ring_perma:OnIntervalThink()
	if IsServer() then
		self.stacks = self:GetCaster():FindModifierByName("modifier_ring_invincibility_cd"):GetStackCount()
	end
end

function modifier_item_plain_ring_perma:OnTakeDamage(keys)
	if IsServer() then
		local aegis_charges = self:GetCaster():FindModifierByName("modifier_aegis")
		if aegis_charges and aegis_charges:GetStackCount() > 0 then return end
		if self:GetCaster():IsReincarnating() then return end
		local unit = keys.unit
		local damage = keys.damage
		local health = self.parent:GetHealth()
		if self:GetCaster() == unit then
			if self.parent:FindModifierByName("modifier_ring_invincibility_cd"):GetStackCount() == 0 then
				if health < 1 then
					self.parent:SetHealth(1)
					self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_plain_ring_perma_invincibility", {duration = self.invincibility_duration, min_health = self.min_health})
					self.parent:FindModifierByName("modifier_ring_invincibility_cd"):SetStackCount(self.cooldown)
				end
			end
		end
	end
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
function modifier_item_plain_ring_perma_armor:GetModifierPhysicalArmorBonus() return 20 end

------------------------
-- Invincibility Buff --
------------------------
modifier_item_plain_ring_perma_invincibility = class({})
function modifier_item_plain_ring_perma_invincibility:IsPurgable() return false end
function modifier_item_plain_ring_perma_invincibility:GetTexture() return "plain_ring_invincibility" end
function modifier_item_plain_ring_perma_invincibility:GetEffectName() return "particles/world_shrine/dire_shrine_regen.vpcf" end
function modifier_item_plain_ring_perma_invincibility:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_plain_ring_perma_invincibility:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_item_plain_ring_perma_invincibility:GetMinHealth() return 1 end
function modifier_item_plain_ring_perma_invincibility:GetModifierIncomingDamage_Percentage() return -400 end

function modifier_item_plain_ring_perma_invincibility:OnCreated(keys)
	if IsServer() then
		self:GetCaster():FindModifierByName("modifier_item_plain_ring_perma"):SetStackCount(1)
		local parent = self:GetParent()
		self.min_health = keys.min_health
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
			self:GetCaster():FindModifierByName("modifier_item_plain_ring_perma"):SetStackCount(0)
		end
	end
end
