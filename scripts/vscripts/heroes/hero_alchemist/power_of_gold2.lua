LinkLuaModifier("modifier_hero_alchemist_power_of_gold2", "heroes/hero_alchemist/power_of_gold2", LUA_MODIFIER_MOTION_NONE)


alchemist_power_of_gold2 = class({})
function alchemist_power_of_gold2:GetIntrinsicModifierName() return "modifier_hero_alchemist_power_of_gold2" end


modifier_hero_alchemist_power_of_gold2 = class({})
function modifier_hero_alchemist_power_of_gold2:IsHidden() return false end
function modifier_hero_alchemist_power_of_gold2:IsPurgable() return false end
function modifier_hero_alchemist_power_of_gold2:IsDebuff() return false end
function modifier_hero_alchemist_power_of_gold2:AllowIllusionDuplicate() return true end
function modifier_hero_alchemist_power_of_gold2:OnCreated()
	if IsServer() then
		local startergold = 600
		local earnedgold_dmg = self:GetAbility():GetSpecialValueFor("gold_percent")
		local earnedgold = PlayerResource:GetTotalEarnedGold(self:GetCaster():GetPlayerID())
		local networth = (startergold + earnedgold) * earnedgold_dmg / 100
		self:SetStackCount(networth)

		self:StartIntervalThink(1)
	end
end
function modifier_hero_alchemist_power_of_gold2:OnIntervalThink()
	if IsServer() then
		local startergold = 600
		local earnedgold_dmg = self:GetAbility():GetSpecialValueFor("gold_percent")
		local earnedgold = PlayerResource:GetTotalEarnedGold(self:GetCaster():GetPlayerID())
		local networth = (startergold + earnedgold) * earnedgold_dmg / 100
		self:SetStackCount(networth)
	end
end
function modifier_hero_alchemist_power_of_gold2:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_hero_alchemist_power_of_gold2:GetModifierSpellAmplify_Percentage() return self:GetStackCount() end
