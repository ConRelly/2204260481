

modifier_mjz_hold_spawer = class({})
local modifier = modifier_mjz_hold_spawer

function modifier:IsHidden() return true end
function modifier:IsPurgable() return false end

if IsServer() then
    function modifier:OnCreated(table)
        self:StartIntervalThink(20)
    end

    function modifier:OnIntervalThink()
        local parent = self:GetParent()
        if parent._spawn_point then
            if parent:GetAbsOrigin() ~= parent._spawn_point then
                FindClearSpaceForUnit(parent, parent._spawn_point, false)
            end
        end
    end
end