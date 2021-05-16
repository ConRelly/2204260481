
--remove_ability = class({})
--local ability_class = remove_ability
require("lib/notifications")

if IsServer() then
	function OnSpellStart(keys)
 
        local caster = keys.caster
        local ability = keys.ability
        local unit = keys.unit
        local hero = caster
        --print("spell start")
        if hero:HasModifier("modifier_arc_warden_tempest_double") then
            ability:SetActivated(false)
            return nil
        end
        if hero:IsRealHero() then
            --print("real hero check")
            local doomskill = hero:FindAbilityByName("temporary_slot_used")
            local abilityName = doomskill:GetName()
            local number = doomskill:GetAbilityIndex()
            print(number .. " index")
            -- Retrieve an ability by name from the unit.
            if number > 6 and doomskill and doomskill:GetName() == "temporary_slot_used" then
                --hero:RemoveItem(ability) 
                hero:RemoveAbility(abilityName)
                --local newAbility = hero:AddAbility("doom_bringer_empty2")
                --if newAbility then
                --    print("newAbility")
                --    newAbility:SetAbilityIndex(0)
                --end    
                ability:SpendCharge()
            else
                Notifications:BottomToAll({text="Move your empty skill first in to a place higher then your last key bind(default is R)", style={color="red"}, duration=5}) 
            end        
        end  


    end
end

-----------------------------------------------------------------------------



