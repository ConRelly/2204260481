---------------------------
-- AEGIS OF THE IMMORTAL --
---------------------------
item_inf_aegis = class({})
LinkLuaModifier("modifier_inf_aegis", "items/aegis.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_inf_aegis_stats", "items/aegis.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
function item_inf_aegis:GetIntrinsicModifierName() return "modifier_inf_aegis" end
function item_inf_aegis:IsRefreshable() return false end

local function HasHigherPrioritySave(hero)
	local helm = hero:GetItemInSlot(16)
	if (helm and helm:GetName() == "item_helm_of_the_undying" and helm:IsCooldownReady())
		or hero:HasModifier("modifier_item_helm_of_the_undying_active") then
		return true
	end

	local ringModifier = hero:FindModifierByName("modifier_item_plain_ring")
	local ring = ringModifier and ringModifier:GetAbility()
	if ring and not ring:IsNull() and ring:IsCooldownReady() and has_item(hero, "item_plain_ring") then
		return true
	end

	local ringCooldown = hero:FindModifierByName("modifier_ring_invincibility_cd")
	return ringCooldown and ringCooldown:GetStackCount() == 0 and hero:HasModifier("modifier_item_plain_ring_perma")
		and not hero:HasModifier("modifier_brewmaster_primal_split")
end

modifier_inf_aegis = class({})
function modifier_inf_aegis:IsHidden() return true end
function modifier_inf_aegis:IsPurgable() return false end
function modifier_inf_aegis:IsPurgeException() return false end
function modifier_inf_aegis:IsDebuff() return false end
function modifier_inf_aegis:RemoveOnDeath() return false end

function modifier_inf_aegis:OnCreated()
	if not IsServer() then return end
	local hero = self:GetParent()
	local item = self:GetAbility()
	if not item then return end
	if not hero:HasModifier("modifier_inf_aegis_stats") then
		hero:AddNewModifier(hero, item, "modifier_inf_aegis_stats", {})
	end
	-- Aegis charges and Infinity Aegis share one engine reincarnation provider.
	if hero:IsRealHero() and not hero:HasModifier("modifier_aegis") then
		hero:AddNewModifier(hero, nil, "modifier_aegis", {})
	end
end

function modifier_inf_aegis:TryReincarnate()
	local hero = self:GetParent()
	local now = GameRules:GetGameTime()
	if hero.cosmosExecutionAt == now then return end
	local item = self:GetAbility()
	if not item or item:IsNull() or item:GetCaster() ~= hero or item:IsInBackpack() or not item:IsCooldownReady() then return end
	if hero.infinityAegisSuicideAt ~= now and HasHigherPrioritySave(hero) then return end

	local delay = item:GetSpecialValueFor("reincarnate_delay")
	item:StartCooldown(item:GetSpecialValueFor("cooldown"))
	return delay
end

function modifier_inf_aegis:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_inf_aegis:OnDeath(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then return end
	local hero = keys.unit
	if not hero:IsRealHero() or not hero:HasScepter() or not hero:HasShard() then return end
	if keys.reincarnate ~= true and not hero:IsReincarnating() then return end
	local item = self:GetAbility()
	if not item or item:IsNull() or item:IsInBackpack() then return end
	local aegis = hero:FindModifierByName("modifier_aegis")
	if aegis and aegis.fromInfinity and aegis.reincarnationAt == GameRules:GetGameTime() then return end
	local stats = hero:FindModifierByName("modifier_inf_aegis_stats")
	if stats then stats:IncrementStackCount() end
end

-----------------------
-- AEGIS BONUS STATS --
-----------------------
if modifier_inf_aegis_stats == nil then modifier_inf_aegis_stats = class({}) end
function modifier_inf_aegis_stats:IsHidden() return false end
function modifier_inf_aegis_stats:GetTexture() return "custom/inf_aegis" end
function modifier_inf_aegis_stats:IsDebuff() return false end
function modifier_inf_aegis_stats:IsPurgable() return false end
function modifier_inf_aegis_stats:IsPurgeException() return false end
function modifier_inf_aegis_stats:IsDebuff() return false end
function modifier_inf_aegis_stats:RemoveOnDeath() return false end
function modifier_inf_aegis_stats:OnCreated()
	self:SetStackCount(1)
	self.proc_stats = self:GetAbility():GetSpecialValueFor("proc_stats")
end
function modifier_inf_aegis_stats:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_inf_aegis_stats:OnTooltip() return self:GetStackCount() * self.proc_stats end
function modifier_inf_aegis_stats:GetModifierBonusStats_Strength() return self:GetStackCount() * self.proc_stats end
function modifier_inf_aegis_stats:GetModifierBonusStats_Agility() return self:GetStackCount() * self.proc_stats end
function modifier_inf_aegis_stats:GetModifierBonusStats_Intellect() return self:GetStackCount() * self.proc_stats end
