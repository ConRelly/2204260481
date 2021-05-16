
LinkLuaModifier( "modifier_friendly_npc", "hack/modifiers/modifier_friendly_npc", LUA_MODIFIER_MOTION_NONE )

modifier_mjz_healers = class({})

function modifier_mjz_healers:IsHidden()
    return true
end
function modifier_mjz_healers:IsPurgable()
    return false
end

function modifier_mjz_healers:CheckState() 
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
    return state
end

if IsServer() then
    function modifier_mjz_healers:OnCreated(table)
        local parent = self:GetParent()
        parent:AddNewModifier(parent, nil, 'modifier_friendly_npc', {})
    end
end
