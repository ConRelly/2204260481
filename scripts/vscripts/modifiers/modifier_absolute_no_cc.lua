
modifier_absolute_no_cc = class({})

-----------------------------------------------------------------------------------------

function modifier_absolute_no_cc:IsHidden()
	return true
end

-----------------------------------------------------------------------------------------

function modifier_absolute_no_cc:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_absolute_no_cc:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 900000
end

--------------------------------------------------------------------------------

function modifier_absolute_no_cc:OnCreated( kv )
	if IsServer() then
		self:GetParent().bAbsoluteNoCC = true
	end
end

-----------------------------------------------------------------------------------------

function modifier_absolute_no_cc:CheckState()
	if IsServer() then
		local state =
		{
			[MODIFIER_STATE_HEXED] = false,
			[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_FROZEN] = false,
			[MODIFIER_STATE_FEARED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = false,
			[MODIFIER_STATE_TETHERED] = false,
			[MODIFIER_STATE_NO_UNIT_COLLISION ] = true,
			--[MODIFIER_STATE_FLYING ] = true,
			--[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
			[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		}	
		return state
	end
end
