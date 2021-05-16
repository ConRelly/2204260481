modifier_generic_break_lua = class({})

--------------------------------------------------------------------------------

function modifier_generic_break_lua:IsDebuff()
	return true
end

function modifier_generic_break_lua:IsStunDebuff()
	return false
end

function modifier_generic_break_lua:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_generic_break_lua:CheckState()
	local state = {
	[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_generic_break_lua:GetEffectName()
	return "particles/generic_gameplay/generic_break.vpcf"
end

function modifier_generic_break_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------
