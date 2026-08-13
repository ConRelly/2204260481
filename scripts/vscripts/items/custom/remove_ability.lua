
require("lib/notifications")
-- don't remove ability list
local abilityList = {
    ["ogre_magi_unrefined_fireblast_lua"] = true,
    ["mjz_bristleback_quill_spray_autocast4"] = true,
    ["temporary_slot_used"] = true,
    ["mjz_bristleback_quill_spray_autocast4_5"] = true,
    ["change_bullets_type"] = true,
    ["invoker_quas"] = true,
    ["invoker_wex"] = true,
    ["invoker_exort"] = true,
    ["invoker_invoke"] = true,
    ["true_master"] = true,
    ["custom_aegis_cast"] = true,
}

if IsServer() then
	function OnSpellStart(keys)
        local caster = keys.caster
        local ability = keys.ability
        local hero = caster
        local lvl = hero:GetLevel()

        if lvl < 6 then return nil end

        if hero:HasAbility("doom_bringer_empty2") then
            local doomskill = hero:FindAbilityByName("doom_bringer_empty2")
            if doomskill then
                local number = doomskill:GetAbilityIndex()
                if number < 6 and doomskill:GetName() == "doom_bringer_empty2" then
                    Notifications:BottomToAll({text="Move your empty skill first in to a place higher then your last key bind(default is R)", style={color="yellow"}, duration=5})
                    ability:SetActivated(false)
                    ability:SpendCharge(0.01)
                    return nil 
                end
            end
        end         
        
        if hero:HasModifier("modifier_arc_warden_tempest_double") then
            ability:SetActivated(false)
            return nil
        end
        
        if hero:IsRealHero() then
            local oldAbility = hero:GetAbilityByIndex(0)
            if oldAbility and not abilityList[oldAbility:GetName()] and not string.find(oldAbility:GetAbilityName(), "empty") then
                local abilityPoints = 1
                local abilityName = oldAbility:GetName()
                if oldAbility:GetToggleState() then 
                    print("Toggle OFF the skill first") 
                    return 
                end
                
                abilityPoints = oldAbility:GetLevel()
                print(string.format("[RemoveAbility] Removing ability '%s' (Level: %d, Points refund: %d)", abilityName, abilityPoints, abilityPoints))
                hero:RemoveAbility(abilityName)

                if abilityName == "medusa_mana_shield" then
                    if hero:HasModifier("modifier_medusa_mana_shield") then
                        hero:RemoveModifierByName("modifier_medusa_mana_shield")
                    end
                end
                if abilityName == "naga_siren_rip_tide" then
                    if hero:HasModifier("modifier_naga_siren_rip_tide") then
                        hero:RemoveModifierByName("modifier_naga_siren_rip_tide")
                    end
                    if hero:HasModifier("modifier_naga_siren_rip_tide_passive") then
                        hero:RemoveModifierByName("modifier_naga_siren_rip_tide_passive")
                    end
                    if hero:HasModifier("modifier_naga_riptide_counter") then
                        hero:RemoveModifierByName("modifier_naga_riptide_counter")
                    end                                       
                end 
                if abilityName == "grimstroke_custom_soulstore" then
                    if hero:HasModifier("modifier_grimstroke_custom_soulstore") then
                        hero:RemoveModifierByName("modifier_grimstroke_custom_soulstore")
                    end
                end                               
                if hero:HasAbility("temporary_slot_used") then
                    hero:RemoveAbility("temporary_slot_used")
                end
                hero:SetAbilityPoints(hero:GetAbilityPoints() + abilityPoints)
				
				for i = 0, 14 do
					local item = hero:GetItemInSlot(i)
					if item == nil then
						hero:AddItemByName("item_removed_skill")
						break
					elseif i == 14 and item ~= nil then
						hero:DropItem(nil, "item_removed_skill", false, nil, hero)
					end
				end

                -- Search for a real extra ability in slot 6+ BEFORE adding temporary_slot_used
                local extra_ability_name = nil
                local extra_ability_slot = -1
                for i = 6, hero:GetAbilityCount() - 1 do
                    local hAbility = hero:GetAbilityByIndex(i)
                    if hAbility and not hAbility:IsAttributeBonus() and not hAbility:IsHidden() 
                       and not string.find(hAbility:GetAbilityName(), "empty") 
                       and not string.find(hAbility:GetAbilityName(), "special_bonus")
                       and hAbility:GetAbilityName() ~= "temporary_slot_used"
                       and hAbility:GetAbilityName() ~= "generic_hidden"
                       and not abilityList[hAbility:GetAbilityName()] then
                        extra_ability_name = hAbility:GetAbilityName()
                        extra_ability_slot = i
                        break
                    end
                end

                local newAbility = hero:AddAbility("temporary_slot_used")
                if newAbility then
                    newAbility:SetAbilityIndex(0)
                end
                ability:SpendCharge(0.01)

                local doomskill_not_removed = true
                if extra_ability_name then
                    print(string.format("[RemoveAbility] Moving extra ability '%s' from slot %d to slot 0", extra_ability_name, extra_ability_slot))
                    hero:SwapAbilities("temporary_slot_used", extra_ability_name, true, true)
                    hero:RemoveAbility("temporary_slot_used")
                    doomskill_not_removed = false
                end

				Timers:CreateTimer(0.6, function()
					if doomskill_not_removed then
						for i = 0, 14 do
							local item = hero:GetItemInSlot(i)
							if item == nil then
								hero:AddItemByName("item_remove_doomskill")
								break
							elseif i == 14 and item ~= nil then
								hero:DropItem(nil, "item_remove_doomskill", false, nil, hero)
							end
						end
					end
				end)

            end
        end
    end
end


