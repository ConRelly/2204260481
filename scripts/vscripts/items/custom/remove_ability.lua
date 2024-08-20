
--remove_ability = class({})
--local ability_class = remove_ability
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
        local unit = keys.unit
        local hero = caster
        local lvl = hero:GetLevel()
        if lvl < 6 then return nil end
        --print("spell start")
        if hero:HasAbility("doom_bringer_empty2") then
            local doomskill = hero:FindAbilityByName("doom_bringer_empty2")
            local abilityNamez = doomskill:GetName()
            local number = doomskill:GetAbilityIndex()
            if number < 6 and doomskill and doomskill:GetName() == "doom_bringer_empty2" then
                Notifications:BottomToAll({text="Move your empty skill first in to a place higher then your last key bind(default is R)", style={color="yellow"}, duration=5})
                ability:SetActivated(false)
                ability:SpendCharge(0.01)
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
            if oldAbility and oldAbility:GetName()~= "ogre_magi_unrefined_fireblast_lua" then
                local swap_fireblast = true
                for i=6,hero:GetAbilityCount() -1 do
                    if swap_fireblast then
                        local hAbility = hero:GetAbilityByIndex( i )
                        if hAbility and not hAbility:IsAttributeBonus() and not hAbility:IsHidden() and not string.find(hAbility:GetAbilityName(), "empty") then  -- Talent-- Dunno
                            local bAbility = hAbility:GetName()
                            --print(bAbility .." 7th ability")
                            hero:SwapAbilities( "ogre_magi_unrefined_fireblast_lua", bAbility, true, true )
                            swap_fireblast = false
                        end
                    end
                end
            end
            if oldAbility and not abilityList[oldAbility:GetName()] and not string.find(oldAbility:GetAbilityName(), "empty") then
                local abilityPoints = 1
                local abilityName = oldAbility:GetName()
                if oldAbility:GetToggleState() then print("Toggle OF the skill") return end
                --hero:RemoveItem(ability) 
                abilityPoints = oldAbility:GetLevel()
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

                local newAbility = hero:AddAbility("temporary_slot_used")
                if newAbility then
                   -- print("newAbility")
                    newAbility:SetAbilityIndex(0)
                end
                ability:SpendCharge(0.01)
                local doomskill_not_removed = true
				for i=1,hero:GetAbilityCount() do
					if hero:GetAbilityCount() - i > 5 then
						local hAbility = hero:GetAbilityByIndex(hero:GetAbilityCount() - i)
						if hAbility and not hAbility:IsAttributeBonus() and not hAbility:IsHidden() and not string.find(hAbility:GetAbilityName(), "empty") then
							local bAbility = hAbility:GetName()
							hero:SwapAbilities("temporary_slot_used", bAbility, true, true)
							hero:RemoveAbility("temporary_slot_used")
							doomskill_not_removed = false
							break
						end
                    end
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
