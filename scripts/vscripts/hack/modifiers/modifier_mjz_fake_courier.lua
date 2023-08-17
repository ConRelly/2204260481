

modifier_mjz_fake_courier = class({})
local modifier = modifier_mjz_fake_courier

function modifier:IsHidden() return true end
function modifier:IsPurgable() return false end

if IsServer() then
    
    function modifier:DeclareFunctions() 
        return { 
            MODIFIER_PROPERTY_MODEL_CHANGE,
            MODIFIER_EVENT_ON_ABILITY_EXECUTED
        }
    end
    
    function modifier:GetModifierModelChange()
        return self:GetParent().targetModel
    end
    function modifier:OnAbilityExecuted(params)
        if params.ability:GetName() == "item_tombstone" then
            -- Prevent the courier from continuing the channel
            if params.unit == self:GetParent() then
                params.unit:Interrupt()
            end
        end
    end
    


    function modifier:OnCreated(table)
        self:OnIntervalThink()
        self:StartIntervalThink(60 * 5)
    end

    function modifier:OnIntervalThink()
        local parent = self:GetParent()
        local playerID = parent:GetPlayerOwnerID()
        local courier = PLAYERS_COURIER[playerID + 1]
        if courier then
            -- print(courier:GetModelName())
            local newModel = courier:GetModelName()
            -- newModel = string.gsub( newModel, ".vmdl", "_flying.vmdl")
            parent.targetModel = newModel
            parent:SetModel(newModel)
        else
            print("Cant found courier: " .. playerID)
        end

    end
end