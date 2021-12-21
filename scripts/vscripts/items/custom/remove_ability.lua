
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
        if hero:HasAbility("doom_bringer_empty2") then
            local doomskill = hero:FindAbilityByName("doom_bringer_empty2")
            local abilityNamez = doomskill:GetName()
            local number = doomskill:GetAbilityIndex()
            if number < 6 and doomskill and doomskill:GetName() == "doom_bringer_empty2" then
                Notifications:BottomToAll({text="Move your empty skill first in to a place higher then your last key bind(default is R)", style={color="yellow"}, duration=5})
                ability:SetActivated(false)
                ability:SpendCharge()
                return nil 
            end
        end            
        
        if hero:HasModifier("modifier_arc_warden_tempest_double") then
            ability:SetActivated(false)
            return nil
        end
        
        if hero:IsRealHero() then
            --print("real hero check")
            local oldAbility = hero:GetAbilityByIndex(0)
            --print(oldAbility:GetName().. " first skill")
            if oldAbility and oldAbility:GetName()~= "ogre_magi_unrefined_fireblast_lua" and oldAbility:GetName()~= "mjz_bristleback_quill_spray_autocast4" and oldAbility:GetName()~= "temporary_slot_used" and oldAbility:GetName()~= "mjz_bristleback_quill_spray_autocast4_5" and oldAbility:GetName()~= "change_bullets_type"  and not string.find(oldAbility:GetAbilityName(), "empty") then
                local abilityPoints = 1
                local abilityName = oldAbility:GetName()
                --hero:RemoveItem(ability) 
                abilityPoints = oldAbility:GetLevel()
                hero:RemoveAbility(abilityName)
                if abilityName == "medusa_mana_shield" then
                    if hero:HasModifier("modifier_medusa_mana_shield") then
                        hero:RemoveModifierByName("modifier_medusa_mana_shield")
                    end    
                end
                if hero:HasAbility("temporary_slot_used") then
                    hero:RemoveAbility("temporary_slot_used")                    
                end    
                hero:SetAbilityPoints(hero:GetAbilityPoints() + abilityPoints)
                hero:AddItemByName("item_removed_skill")
                local newAbility = hero:AddAbility("temporary_slot_used")
                if newAbility then
                   -- print("newAbility")
                    newAbility:SetAbilityIndex(0)
                end
                ability:SpendCharge()
                local doomskill_not_removed = true
                for i=6,hero:GetAbilityCount() -1 do
                    local hAbility = hero:GetAbilityByIndex( i )
                    if hAbility and not hAbility:IsAttributeBonus() and not hAbility:IsHidden() and not string.find(hAbility:GetAbilityName(), "empty") then  -- Talent-- Dunno
                        local bAbility = hAbility:GetName()
                        --print(bAbility .." 7th ability")                     
                        hero:SwapAbilities( "temporary_slot_used", bAbility, true, true )
                        hero:RemoveAbility("temporary_slot_used")
                        doomskill_not_removed = false
                        return    
                    end
                end
				Timers:CreateTimer(
					0.60,
                    function()
                        if doomskill_not_removed then
                            hero:AddItemByName("item_remove_doomskill")
                        end 
					end
				)                
             
            end
        end    
    end
end

-----------------------------------------------------------------------------



