
--LinkLuaModifier("modifier_playerhelp_revive", "modifiers/modifier_playerhelp_revive.lua", LUA_MODIFIER_MOTION_NONE)
modifier_playerhelp_revive = class({})


function modifier_playerhelp_revive:IsHidden()
    return false
end
function modifier_playerhelp_revive:GetTexture()
    return "dragon_knight_dragon_tail"
end

function modifier_playerhelp_revive:IsPurgable()
    return false
end


