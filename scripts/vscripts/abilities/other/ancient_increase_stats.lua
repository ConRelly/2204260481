require("lib/my")
require("AOHGameMode")


ancient_increase_stats = class({})


function ancient_increase_stats:GetIntrinsicModifierName()
    return "modifier_ancient_increase_stats"
end



LinkLuaModifier("modifier_ancient_increase_stats", "abilities/other/ancient_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)

modifier_ancient_increase_stats = class({})


if IsServer() then
    function modifier_ancient_increase_stats:OnCreated()
        self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.health_base = ability:GetSpecialValueFor("health_base")
		self.health_per_round = ability:GetSpecialValueFor("health_per_round")
		self.armor_base = ability:GetSpecialValueFor("armor_base")
		self.armor_per_round = ability:GetSpecialValueFor("armor_per_round")
		self.round = 0
		self:StartIntervalThink(2)
    end
	function modifier_ancient_increase_stats:OnIntervalThink()
		if self.parent and not self.parent:IsNull() and self.parent:IsAlive() then
			local round = GameRules.GLOBAL_roundNumber
			if round and round > self.round then
				
				-- Health
				local maxHealth = self.health_base + (self.health_per_round * round)
				local health = maxHealth
			
				if round == previous_round then   -- heal only when round changes.
					health = maxHealth * self.parent:GetHealthPercent() * 0.01
				end
			
				self.parent:SetMaxHealth(maxHealth)
				self.parent:SetBaseMaxHealth(maxHealth)
				self.parent:SetHealth(health)
				--


				-- Armor
				local armor = self.armor_base + (self.armor_per_round * round)
				self.parent:SetPhysicalArmorBaseValue(armor)
				--

				previous_round = round
			end
		end
	end
	

end


function modifier_ancient_increase_stats:IsHidden()
    return true
end
function modifier_ancient_increase_stats:IsPurgable()
	return false
end

