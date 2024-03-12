
function OnSpellStart( keys )
    local caster = keys.caster
    local ability = keys.ability
    local unit = keys.unit
    local hero = caster


    if hero:HasModifier("modifier_arc_warden_tempest_double") then
        ability:SetActivated(false)
		return nil
    end
    
    

 

    if hero:IsRealHero() then
        local ability4 = hero:GetAbilityByIndex(3)
        local ability5 = hero:GetAbilityByIndex(4)
        local ability7 = hero:GetAbilityByIndex(6)
        local ability8 = hero:GetAbilityByIndex(7)


        local slotId = -1
		-- if ability4 then slotId = 4 end
		-- if ability5 then slotId = 6 end
		-- if ability7 then slotId = 8 end
		-- if ability8 then slotId = nil end
        if ability8 == nil or ability8:GetName() == "generic_hidden" then slotId = 7 end
        if ability7 == nil or ability7:GetName() == "generic_hidden" then slotId = 6 end
        if ability5 == nil or ability5:GetName() == "generic_hidden" then slotId = 4 end
        if ability4 == nil or ability4:GetName() == "generic_hidden" then slotId = 3 end
        -- if ability8 == nil then slotId = 7 end
        -- if ability7 == nil then slotId = 6 end

        if IsInToolsMode() then
            print("ability8 :" .. ability8:GetName())
            print("ability7 :" .. ability7:GetName())
            print("ability5 :" .. ability5:GetName())
            print("ability4 :" .. ability4:GetName())
            print("newAbility slotID:" .. slotId)
        end
        
        if slotId > -1 then
            local oldAbility = hero:GetAbilityByIndex(slotId)
            if oldAbility then
                print("oldAbility:" .. oldAbility:GetName())
                hero:RemoveAbilityByHandle(oldAbility)
            end
        end
        local exclude_table = {
            faceless_void_backtrack = true,
            phantom_reflex = true,

        }        
        local found_valid_ability = false
        while not found_valid_ability do
            local newAbilityName = GetRandomAbilityName(hero)                                            
            if not hero:HasAbility(newAbilityName) then
                if exclude_table[newAbilityName] then
                    if hero:HasAbility("phantom_reflex") or hero:HasAbility("faceless_void_backtrack") then
                        return
                    end
                end
                if hero:HasAbility("shadow_demon_custom_hyperactivity") then
                    if newAbilityName == "obs_replay" then
                        print(newAbilityName .. " nope2")
                        --ability:OnSpellStart() 
                        return                            
                    end    
                end                                
                local newAbility = hero:AddAbility(newAbilityName)      
                print("newAbility:" .. newAbilityName)  
                if slotId > -1 then                          
                    newAbility:SetAbilityIndex(slotId)
                end
                hero:SetAbilityPoints(hero:GetAbilityPoints() + 5)
                found_valid_ability = true
                --hero:RemoveItem(ability)
                hero:TakeItem(ability)
                hero:ModifyGold(19213, true, 0)
                return true                                                   
            end
            break                                                    
        end
    end
end

function GetRandomAbilityName( hero )                 
    local abilityList = {
        --"ogre_magi_multicast_n",      -- 兽王    野性之心
        --"ogre_magi_multicast_lua",
        --"aghanim_blink2",
        --"ursa_fury_swipes",
        --"faceless_void_time_lock",
        --"mjz_faceless_void_backtrack",
        "obs_replay",
        --"zanto_gari",
        --"dark_willow_shadow_realm_lua",
        --"monkey_king_custom_jingu_mastery",
        --"mjz_faceless_void_backtrack",
        --"hoodwink_acorn_shot",
        --"cold_slashes",
        --"reverse_polarity",
        
    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]   
end
