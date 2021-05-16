

modifier_mjz_god_kill = class({})
local modifier = modifier_mjz_god_kill

function modifier:IsHidden() return false end
function modifier:IsPurgable() return false end


function modifier:OnCreated(table)
    if IsServer() then
    end
end
function modifier:OnIntervalThink()

end
