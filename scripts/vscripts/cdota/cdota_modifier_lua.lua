
---------------------------------------------------------------------------------------------------
-- CDOTA_Modifier_Lua

function CDOTA_Modifier_Lua:GetSpecialValueFor(specVal)
	if self and not self:IsNull() and self:GetAbility() and not self:GetAbility():IsNull() then
		return self:GetAbility():GetSpecialValueFor(specVal)
	end
end
