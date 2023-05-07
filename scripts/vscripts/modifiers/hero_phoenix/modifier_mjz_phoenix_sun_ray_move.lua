

modifier_mjz_phoenix_sun_ray_rooted = class({})
local modifier_rooted = modifier_mjz_phoenix_sun_ray_rooted

function modifier_rooted:IsHidden() return true end
function modifier_rooted:IsPurgable() return false end

function modifier_rooted:CheckState() 
	if self:GetParent().bAbsoluteNoCC then return end
	local state = {
		[MODIFIER_STATE_ROOTED]     = true,
	}
	return state
end



modifier_mjz_phoenix_sun_ray_move = class({})
local modifier_move = modifier_mjz_phoenix_sun_ray_move

function modifier_move:IsHidden() return true end
function modifier_move:IsPurgable() return false end

function modifier_move:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	}
end

function modifier_move:GetModifierMoveSpeed_AbsoluteMin()
	-- return 1
	return self:GetAbility():GetSpecialValueFor('forward_move_speed')
end
function modifier_move:GetModifierMoveSpeedOverride()
	return 1
end