modifier_generic_muted_lua = class({})

--------------------------------------------------------------------------------

function modifier_generic_muted_lua:IsDebuff()
	return true
end

function modifier_generic_muted_lua:IsStunDebuff()
	return false
end

function modifier_generic_muted_lua:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_generic_muted_lua:CheckState()
	local state = {
	[MODIFIER_STATE_MUTED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_generic_muted_lua:GetEffectName()
	return "particles/generic_gameplay/generic_muted_model.vpcf"
end

function modifier_generic_muted_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------
