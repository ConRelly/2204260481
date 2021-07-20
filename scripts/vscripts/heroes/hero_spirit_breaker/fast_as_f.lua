LinkLuaModifier("modifier_fast_as_f", "heroes/hero_spirit_breaker/fast_as_f", LUA_MODIFIER_MOTION_NONE)
fast_as_f = class({})
function fast_as_f:Spawn()
	if IsServer() then self:SetLevel(1) end
end
function fast_as_f:OnHeroLevelUp()
	if IsServer() then
		local level = self:GetLevel()
		if level < self:GetMaxLevel() then
			if (self:GetCaster():GetLevel() % 25 == 0) then
				self:SetLevel(level + 1)
			end
		end
	end
end
function fast_as_f:GetIntrinsicModifierName() return "modifier_fast_as_f" end

modifier_fast_as_f = class({})
function modifier_fast_as_f:IsHidden() return false end
function modifier_fast_as_f:IsPurgable() return false end
function modifier_fast_as_f:RemoveOnDeath() return false end
function modifier_fast_as_f:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_fast_as_f:OnIntervalThink()
	self:SetStackCount(self:GetCaster():GetLastHits())
end
function modifier_fast_as_f:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_fast_as_f:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then
		if self:GetCaster():HasModifier("modifier_spirit_breaker_charge_of_darkness") then
			return self:GetAbility():GetSpecialValueFor("bonus_charge_ms") * self:GetStackCount()
		else
			return 0
		end
	end
end
function modifier_fast_as_f:OnTooltip()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_charge_ms") * self:GetStackCount() end
end