
modifier_hero_target_dummy = class({})

function modifier_hero_target_dummy:IsHidden() 			return true end
function modifier_hero_target_dummy:IsPurgable() 		return false end
function modifier_hero_target_dummy:CheckState() 
    return {
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_ROOTED]         = true,
        [MODIFIER_STATE_INVISIBLE]      = true,
        [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
    } 
end