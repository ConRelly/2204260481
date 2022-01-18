LinkLuaModifier("modifier_hero_alchemist_power_of_gold", "heroes/hero_alchemist/power_of_gold", LUA_MODIFIER_MOTION_NONE)


alchemist_power_of_gold = class({})
function alchemist_power_of_gold:GetIntrinsicModifierName() return "modifier_hero_alchemist_power_of_gold" end


modifier_hero_alchemist_power_of_gold = class({})
function modifier_hero_alchemist_power_of_gold:IsHidden() return false end
function modifier_hero_alchemist_power_of_gold:IsPurgable() return false end
function modifier_hero_alchemist_power_of_gold:IsDebuff() return false end
function modifier_hero_alchemist_power_of_gold:AllowIllusionDuplicate() return true end
function modifier_hero_alchemist_power_of_gold:OnCreated()
	if IsServer() then
		local startergold = 600
		local earnedgold_dmg = self:GetAbility():GetSpecialValueFor("gold_percent")
		local earnedgold = PlayerResource:GetTotalEarnedGold(self:GetCaster():GetPlayerID())
		local networth = (startergold + earnedgold) * earnedgold_dmg / 100
		self:SetStackCount(networth)

		self:StartIntervalThink(1)
	end
end
function modifier_hero_alchemist_power_of_gold:OnIntervalThink()
	if IsServer() then
		local startergold = 600
		local earnedgold_dmg = self:GetAbility():GetSpecialValueFor("gold_percent")
		local earnedgold = PlayerResource:GetTotalEarnedGold(self:GetCaster():GetPlayerID())
		local networth = (startergold + earnedgold) * earnedgold_dmg / 100
		self:SetStackCount(networth)
	end
end
function modifier_hero_alchemist_power_of_gold:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_hero_alchemist_power_of_gold:GetModifierPreAttack_BonusDamage() return self:GetStackCount() end
