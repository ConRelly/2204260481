
modifier_mjz_g_frozen = class({})

function modifier_mjz_g_frozen:IsHidden() return false end
function modifier_mjz_g_frozen:IsPurgable() return true end
function modifier_mjz_g_frozen:IsDebuff() return true end

function modifier_mjz_g_frozen:GetTexture()
    if self:GetAbility() == nil then
		return "winter_wyvern_cold_embrace"
	else
		return self:GetAbility():GetAbilityTextureName()
    end
end

function modifier_mjz_g_frozen:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
    local state = { 
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_INVISIBLE] = false,
        }
    return state
end

function modifier_mjz_g_frozen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, 
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}
	return funcs
end

function modifier_mjz_g_frozen:GetModifierPercentageCasttime()
	return -95
end

function modifier_mjz_g_frozen:GetModifierTurnRate_Percentage()
	return -95
end

function modifier_mjz_g_frozen:GetEffectName()
	return "particles/generic_gameplay/generic_frozen.vpcf"	--"particles/generic_frozen.vpcf" 
end

function modifier_mjz_g_frozen:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf"
end

function modifier_mjz_g_frozen:StatusEffectPriority()
	return 11
end