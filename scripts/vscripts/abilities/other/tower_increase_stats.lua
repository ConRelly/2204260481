LinkLuaModifier("modifier_tower_increase_stats", "abilities/other/tower_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)

tower_increase_stats = class({})
function tower_increase_stats:GetIntrinsicModifierName() return "modifier_tower_increase_stats" end


modifier_tower_increase_stats = class({})
function modifier_tower_increase_stats:IsHidden() return true end
function modifier_tower_increase_stats:IsPurgable() return false end
function modifier_tower_increase_stats:OnCreated()
	self.previous_round = 0
	self:StartIntervalThink(0.2)
end
function modifier_tower_increase_stats:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local health_base = ability:GetSpecialValueFor("health_base")
	local health_per_round = ability:GetSpecialValueFor("health_per_round")
	local armor_base = ability:GetSpecialValueFor("armor_base")
	local armor_per_round = ability:GetSpecialValueFor("armor_per_round")
	local damage_base = ability:GetSpecialValueFor("damage_base")
	local damage_per_round = ability:GetSpecialValueFor("damage_per_round")

	if IsServer() then
		if parent and not parent:IsNull() and parent:IsAlive() then
			local round = _G.RoundNumber
			if round and self.previous_round < round then
				self:SetStackCount(round)

				-- Health
				local maxHealth = health_base + (health_per_round * round)
				parent:SetMaxHealth(maxHealth)
				parent:SetBaseMaxHealth(maxHealth)
				parent:SetHealth(maxHealth)
				
				-- Damage
				local damage = damage_base + (damage_per_round * round)
				parent:SetBaseDamageMin(damage)
				parent:SetBaseDamageMax(damage)
				
				-- Armor
				local armor = armor_base + (armor_per_round * round)
				parent:SetPhysicalArmorBaseValue(armor)

				self.previous_round = round
			end
		end
	end
end

