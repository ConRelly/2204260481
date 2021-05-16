
modifier_friendly_npc = class({})

--------------------------------------------------------------------------------

function modifier_friendly_npc:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_friendly_npc:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier( nil, nil, "modifier_disable_aggro", { duration = -1 } )
	end
end

--------------------------------------------------------------------------------

function modifier_friendly_npc:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_FIXED_DAY_VISION,
		MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_friendly_npc:GetFixedDayVision( params )
	return 1
end

--------------------------------------------------------------------------------

function modifier_friendly_npc:GetFixedNightVision( params )
	return 1
end

--------------------------------------------------------------------------------

function modifier_friendly_npc:CheckState()
	local state = {}
	if IsServer() then
		state[MODIFIER_STATE_INVULNERABLE] = true
	end
	
	return state
end

--------------------------------------------------------------------------------

