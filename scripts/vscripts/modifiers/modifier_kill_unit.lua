-- Define the modifier
modifier_kill_unit = class({})

-- Set the modifier as permanent
function modifier_kill_unit:IsPermanent()
    return true
end

-- Set the modifier as hidden
function modifier_kill_unit:IsHidden()
    return true
end

-- Set the modifier as debuff
function modifier_kill_unit:IsDebuff()
    return false
end

-- Set the modifier as purgable
function modifier_kill_unit:IsPurgable()
    return true
end

-- Apply the modifier's effects
function modifier_kill_unit:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        if unit and unit:IsAlive() then
            unit:Kill(nil, nil)
        end    
    end
end
