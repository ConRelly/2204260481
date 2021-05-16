modifier_boss = class({})
function modifier_boss:IsBuff() return true end
function modifier_boss:IsHidden() return false end
function modifier_boss:GetTexture() return "earth_spirit_rolling_boulder" end
function modifier_boss:IsPurgable() return false end
function modifier_boss:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end
function modifier_boss:GetModifierTotalDamageOutgoing_Percentage() return self:GetStackCount() end
function modifier_boss:GetModifierMoveSpeedBonus_Percentage() return self:GetStackCount() * 0.25 end
function modifier_boss:GetModifierExtraHealthPercentage() return self:GetStackCount() * 0.6 end
if IsServer() then
	function modifier_boss:OnCreated()
		self:StartIntervalThink(2.0)
		self.parent = self:GetParent()
	end
	function modifier_boss:OnIntervalThink()
		self:IncrementStackCount()
	end
end


