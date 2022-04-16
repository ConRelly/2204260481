modifier_chill_generic = class({})
function modifier_chill_generic:IsDebuff() return true end
function modifier_chill_generic:IsPurgable() return true end
function modifier_chill_generic:GetTexture() return "ancient_apparition_cold_feet" end
function modifier_chill_generic:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_chill_generic:GetStatusEffectName() return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_dire.vpcf" end
function modifier_chill_generic:StatusEffectPriority() return 10 end
function modifier_chill_generic:GetPriority() return MODIFIER_PRIORITY_HIGH end

function modifier_chill_generic:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_chill_generic:OnIntervalThink()
	if IsServer() then
		local stacks = self:GetStackCount()
		self:SetStackCount(stacks - math.max(stacks * 0.01))
	end
end

function modifier_chill_generic:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_chill_generic:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self:GetStackCount()
end
