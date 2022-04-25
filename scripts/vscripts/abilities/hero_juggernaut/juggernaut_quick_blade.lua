LinkLuaModifier("modifier_juggernaut_blade_dance_lua", "abilities/hero_juggernaut/juggernaut_quick_blade", LUA_MODIFIER_MOTION_NONE)

juggernaut_blade_dance_lua = class({})
function juggernaut_blade_dance_lua:GetIntrinsicModifierName() return "modifier_juggernaut_blade_dance_lua" end


modifier_juggernaut_blade_dance_lua = class({})
function modifier_juggernaut_blade_dance_lua:IsHidden() return true end
function modifier_juggernaut_blade_dance_lua:IsPurgable() return false end
function modifier_juggernaut_blade_dance_lua:OnCreated()
	if self:GetAbility() then
		self.crit_chance = self:GetAbility():GetSpecialValueFor("blade_dance_crit_chance")
		self.max_crit_chance = self:GetAbility():GetSpecialValueFor("max_crit_chance")
		self.crit_mult = self:GetAbility():GetSpecialValueFor("blade_dance_crit_mult")
		self.crit_chance_agi_multiplier = self:GetAbility():GetSpecialValueFor("crit_chance_agi_multiplier")
	end	
end

function modifier_juggernaut_blade_dance_lua:OnRefresh()
	if self:GetAbility() then
		self.crit_chance = self:GetAbility():GetSpecialValueFor("blade_dance_crit_chance")
		self.max_crit_chance = self:GetAbility():GetSpecialValueFor("max_crit_chance")
		self.crit_mult = self:GetAbility():GetSpecialValueFor("blade_dance_crit_mult")
		self.crit_chance_agi_multiplier = self:GetAbility():GetSpecialValueFor("crit_chance_agi_multiplier")
	end   
end
function modifier_juggernaut_blade_dance_lua:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end
function modifier_juggernaut_blade_dance_lua:GetModifierPreAttack_CriticalStrike(params)
	if IsServer() then
		if self:GetParent():PassivesDisabled() then
			local crit_chance = math.min(self.crit_chance + math.floor(self:GetParent():GetAgility() * self.crit_chance_agi_multiplier / 1000), self.max_crit_chance)
			if RandomInt(0, 100) < crit_chance then
				self.record = params.record
				return self.crit_mult
			end
		end
	end
end
