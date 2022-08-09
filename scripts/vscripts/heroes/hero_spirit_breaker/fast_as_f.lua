LinkLuaModifier("modifier_fast_as_f", "heroes/hero_spirit_breaker/fast_as_f", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fast_as_f2", "heroes/hero_spirit_breaker/fast_as_f", LUA_MODIFIER_MOTION_NONE)
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
		local parent = self:GetParent()
		if parent and parent:IsAlive() then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_fast_as_f2", {})
		end	
		self:StartIntervalThink(1)
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

modifier_fast_as_f2 = class({})

function modifier_fast_as_f2:IsHidden() return true end
function modifier_fast_as_f2:IsPurgable() return false end
function modifier_fast_as_f2:RemoveOnDeath() return false end
function modifier_fast_as_f2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(1)
	end
end
function modifier_fast_as_f2:OnIntervalThink()
	if IsServer() then
		if _G._challenge_bosss and _G._challenge_bosss > 0 then
			local stacks = ((self:GetAbility():GetSpecialValueFor("bonus_charge_ms") * self:GetCaster():GetLastHits()) / 10) * _G._challenge_bosss
			self:SetStackCount(stacks)
		end
	end	
end

function modifier_fast_as_f2:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function modifier_fast_as_f2:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end