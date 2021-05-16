modifier_bkb = class({})
function modifier_bkb:CheckState()
	local state = {}
	state[MODIFIER_STATE_MAGIC_IMMUNE] = true
	return state
end
function modifier_bkb:IsPurgable() return false end
function modifier_bkb:IsHidden() return true end