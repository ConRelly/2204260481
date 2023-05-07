modifier_frozen_generic = class({})
function modifier_frozen_generic:IsPurgable() return true end
function modifier_frozen_generic:IsDebuff() return true end
function modifier_frozen_generic:GetTexture() return "winter_wyvern_cold_embrace" end
function modifier_frozen_generic:GetStatusEffectName() return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf" end
function modifier_frozen_generic:StatusEffectPriority() return 11 end
function modifier_frozen_generic:GetEffectName() return "particles/generic_frozen.vpcf" end

function modifier_frozen_generic:OnCreated()
	if self:GetParent():IsMagicImmune() then
		self:Destroy()
		return
	end
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_frozen_generic:OnIntervalThink()
	if self:GetParent():IsChilled() then
		self:GetParent():RemoveChill()
		if RollPercentage(25) then
			local units = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), 250, {})
			for _, unit in pairs(units) do
				unit:AddChill(self:GetAbility(), self:GetCaster(), 2.5)
				break
			end
		end
	end
end

function modifier_frozen_generic:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	if self:GetParent().bAbsoluteNoStun then return end
	return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_INVISIBLE] = false}
end


function modifier_frozen_generic:DeclareFunctions()
	return {MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function modifier_frozen_generic:GetModifierAttackSpeedBonus(params)
	return -1000
end

function modifier_frozen_generic:GetModifierPercentageCasttime()
	return -95
end

function modifier_frozen_generic:GetModifierTurnRate_Percentage()
	return -95
end
