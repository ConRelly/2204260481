modifier_bristleback_warpath_stack_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_bristleback_warpath_stack_lua:IsHidden()
	return true
end

function modifier_bristleback_warpath_stack_lua:IsDebuff()
	return false
end

function modifier_bristleback_warpath_stack_lua:IsPurgable()
	return false
end

function modifier_bristleback_warpath_stack_lua:RemoveOnDeath()
	return false
end

function modifier_bristleback_warpath_stack_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_bristleback_warpath_stack_lua:OnCreated( kv )
end

function modifier_bristleback_warpath_stack_lua:OnRefresh( kv )
end

function modifier_bristleback_warpath_stack_lua:OnDestroy()
	if not IsServer() then return end
	self.parent_modifier:RemoveStack()
end