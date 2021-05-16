modifier_generic_disarm_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_disarm_lua:IsDebuff()
	return true
end

function modifier_generic_disarm_lua:IsStunDebuff()
	return false
end

function modifier_generic_disarm_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Modifier State
function modifier_generic_disarm_lua:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics and animations
function modifier_generic_disarm_lua:GetEffectName()
	return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_generic_disarm_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
