LinkLuaModifier("modifier_charges_checker", "modifiers/modifier_charges", LUA_MODIFIER_MOTION_NONE)
modifier_charges = class({})

if IsServer() then
	function modifier_charges:Update()
		local replenish_time = self.kv.replenish_time * self:GetParent():GetCooldownReduction()
		if self:GetDuration() == -1 then
			self:SetDuration(replenish_time, true)
			self:StartIntervalThink(replenish_time)
		end
		if self:GetStackCount() == 0 then
			self:GetAbility():StartCooldown(self:GetRemainingTime())
		end
	end

	function modifier_charges:OnCreated(kv)
		self:SetStackCount(kv.start_count or kv.max_count)
		self.kv = kv

		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_charges_checker", {self_ability = kv.self_ability})

		if kv.start_count and kv.start_count ~= kv.max_count then
			self:Update()
		end
	end

	function modifier_charges:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
	end

	function modifier_charges:OnAbilityExecuted(params)
		local refresh_ways = {
			["item_refresher"] = true,
			["item_custom_refresher"] = true,
			["item_refresher_shard"] = true,
		}

		if params.unit == self:GetParent() then
			if params.ability == self:GetAbility() then
				self:DecrementStackCount()
				self:Update()
			elseif refresh_ways[params.ability:GetName()] then
				self:StartIntervalThink(-1)
				self:SetDuration(-1, true)
				self:SetStackCount(self.kv.max_count)
			end
		end
		return 0
	end

	function modifier_charges:OnIntervalThink()
		local stacks = self:GetStackCount()
		local replenish_time = self.kv.replenish_time * self:GetParent():GetCooldownReduction()

		if stacks < self.kv.max_count then
			self:SetDuration(replenish_time, true)
			self:IncrementStackCount()
			self:StartIntervalThink(replenish_time)

			if stacks == self.kv.max_count - 1 then
				self:SetDuration(-1, true)
				self:StartIntervalThink(-1)
			end
		end
	end
end
function modifier_charges:IsHidden() return (self:GetStackCount()<=0) end
function modifier_charges:DestroyOnExpire() return false end
function modifier_charges:IsPurgable() return false end
function modifier_charges:RemoveOnDeath() return false end
function modifier_charges:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_charges_checker = class({})
function modifier_charges_checker:IsHidden() return true end
function modifier_charges_checker:DestroyOnExpire() return false end
function modifier_charges_checker:IsPurgable() return false end
function modifier_charges_checker:RemoveOnDeath() return false end
function modifier_charges_checker:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_charges_checker:OnCreated(kv)
	if IsServer() then self:StartIntervalThink(FrameTime()) self.self_ability = kv.self_ability end
end
function modifier_charges_checker:OnIntervalThink()
	if self:GetCaster():FindAbilityByName(self.self_ability) == nil then self:Destroy() end
end


--[[
function название_способности:GetIntrinsicModifierName() return "modifier_способности" end
if modifier_способности == nil then modifier_способности = class({}) end
function modifier_способности:IsHidden() return true end
function modifier_способности:IsPurgable() return false end
function modifier_способности:RemoveOnDeath() return false end
function modifier_способности:OnCreated()
	if IsServer() then if not self:GetAbility() or self:GetAbility():IsNull() then self:Destroy() return end
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("название_способности"), "modifier_charges", {
			self_ability = self:GetAbility():GetAbilityName(),
			max_count = 4,
			start_count = 1,
			replenish_time = 10
		})
	end
end
function modifier_способности:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_charges")
	end
end
]]
