require("lib/my")



function copy_level(target, illusion)
    local level = target:GetLevel()
    for i = 1, level - 1 do
        illusion:HeroLevelUp(false)
    end
end


function copy_skill_level(target, illusion, copy_ultimate)
    illusion:SetAbilityPoints(0)
    --local abilityCount = target:GetAbilityCount()
    for slot = 0, 15 do
        local ability = target:GetAbilityByIndex(slot)
        local abilityName = ability:GetAbilityName()
        if ability ~= nil and ability:GetCastPoint() ~= 1337 and abilityName ~= "chen_custom_holy_persuasion" then
            if ability:GetAbilityType() ~= 1 or copy_ultimate then  -- Not ultimate.
                local abilityLevel = ability:GetLevel()
                local illusionAbility = illusion:FindAbilityByName(abilityName)
                if IsValidEntity(illusionAbility) then
                    illusionAbility:SetLevel(abilityLevel)
                end
            end
        end
    end
end

local IllusionNotCopy = {
    ["item_pocket_rax"] = true,
    ["item_remove_ability"] = true,
    ["item_pocket_rax_ranged"] = true,
    ["item_plain_perma"] = true,
    ["item_pharaoh_crown"] = true,
    ["item_mjz_ability_point"] = true,
    ["item_mjz_ability_point_2"] = true,
    ["item_mjz_rage_moon_shard"] = true,
    ["item_pocket_tower"] = true,
    ["item_video_file"] = true, 
    ["item_conduit"] = true,
    ["item_ritual_shovel"] = true,
    ["item_random_get_ability"] = true,
    ["item_random_get_ability2"] = true,
    ["item_random_get_ability_onlvl"] = true,
    ["item_random_get_ability_spell"] = true,
    ["item_random_get_ability3"] = true,
    ["item_remove_ability"] = true,
    ["item_remove_doomskill"] = true,
    ["item_auto_cast"] = true,
    ["item_imba_ultimate_scepter_synth2"] = true,
    ["item_obs_studio"] = true, 
    ["item_god_slayer"] = true,
};



function copy_items(target, illusion)
    for itemSlot = 0, 5 do
        local item = target:GetItemInSlot(itemSlot) 
        local itemname2 = 0
        if item ~= nil then
            itemname2 = item:GetName()
        end    
        if item ~= nil and IllusionNotCopy[itemname2] ~= true and item:GetCastPoint() ~= 1337 then
            local itemName = item:GetName()
            local newItem = CreateItem(itemName, illusion, illusion)
            illusion:AddItem(newItem)
        end
    end
    local item = target:GetItemInSlot(16) 
    local itemname3 = 0
    if item ~= nil then
        itemname3 = item:GetName()
    end    
    if item ~= nil and IllusionNotCopy[itemname2] ~= true and item:GetCastPoint() ~= 1337 then
        local itemName = item:GetName()
        local newItem = CreateItem(itemName, illusion, illusion)
        illusion:AddItem(newItem)
    end

end


function disable_inventory(illusion)
    illusion:SetHasInventory(false)
	illusion:SetCanSellItems(false)
end


function set_vision(illusion)
    illusion:SetDayTimeVisionRange(0)
    illusion:SetNightTimeVisionRange(0)
end


function kill_illusion(illusion)
    if not illusion:IsIllusion() then
        illusion:MakeIllusion()
    end
    illusion:ForceKill(false)
end
