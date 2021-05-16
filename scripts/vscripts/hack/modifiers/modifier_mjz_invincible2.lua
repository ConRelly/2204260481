

modifier_mjz_invincible2 = class({})
local modifier = modifier_mjz_invincible2

function modifier:IsHidden() return true end
function modifier:IsPurgable() return false end

function modifier:CheckState()
    local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		-- [MODIFIER_STATE_FLYING] = true,
		-- [MODIFIER_STATE_NO_HEALTH_BAR] = true,
		-- [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		-- [MODIFIER_STATE_UNSELECTABLE] = true,
	}
    return state  
end

function modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier:GetModifierIncomingDamage_Percentage()
    return -100
end