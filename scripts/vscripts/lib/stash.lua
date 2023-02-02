

----------------------asd
local stored_items = {}

-- Create the stash panel
local stash_panel = CreateFrame("Frame", "StashPanel", UIParent, "BasicFrameTemplateWithInset")
stash_panel:SetSize(300, 300)
stash_panel:SetPoint("CENTER", UIParent, "CENTER")
stash_panel:SetScript("OnShow", function()
    -- Create a list view to display the stored items
    local stash_list = CreateFrame("Frame", nil, stash_panel, "InsetFrameTemplate")
    stash_list:SetPoint("TOPLEFT", stash_panel, "TOPLEFT", 25, -50)
    stash_list:SetSize(250, 200)
    -- Add the stored items to the list view
    for _, item in pairs(stored_items) do
        local item_name = stash_list:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        item_name:SetPoint("TOPLEFT", stash_list, "TOPLEFT", 0, 0)
        item_name:SetText(item:GetName())

        local item_desc = stash_list:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        item_desc:SetPoint("TOPLEFT", item_name, "BOTTOMLEFT", 0, -10)
        item_desc:SetText(item:GetAbilityDescription())
    end
end)

-- Create a button to drop items from the stored items
local drop_item_button = CreateFrame("Button", nil, stash_panel, "GameMenuButtonTemplate")
drop_item_button:SetPoint("BOTTOM", stash_panel, "BOTTOM", -50, 20)
drop_item_button:SetSize(100, 30)
drop_item_button:SetText("Drop Item")
drop_item_button:SetScript("OnClick", function()
    local playerID = LocalPlayer():GetPlayerID()
    local selected_line = stash_list:GetSelectedLine()
    if selected_line then
        local item = stash_list:GetLine(selected_line).item
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local success = hero:AddItem(item)
        if success then
            Notifications:Top(playerID,{text="You have collected your stored item", style={color="green"}, duration=5})
            table.remove(stored_items, selected_line)
            stash_list:RemoveLine(selected_line)
        else
            Notifications:Top(playerID,{text="Your inventory is full, please clear some space", style={color="red"}, duration=5})
        end
    end
end)
local drop_item_button = CreateFrame("Button", nil, stash_panel, "GameMenuButtonTemplate")
drop_item_button:SetPoint("BOTTOM", stash_panel, "BOTTOM", -50, 20)
drop_item_button:SetSize(100, 30)
drop_item_button:SetText("Drop Item")
drop_item_button:SetScript("OnClick", function()
    local playerID = LocalPlayer():GetPlayerID()
    local selected_line = stash_list:GetSelectedLine()
    if selected_line then
        local item = stash_list:GetLine(selected_line).item
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local success = hero:AddItem(item)
        if success then
            Notifications:Top(playerID,{text="You have collected your stored item", style={color="green"}, duration=5})
            table.remove(stored_items, selected_line)
            stash_list:RemoveLine(selected_line)
        else
            Notifications:Top(playerID,{text="Your inventory is full, please clear some space", style={color="red"}, duration=5})
        end
    end
end)


-- Create a button to add items to the stored items
local add_item_button = CreateFrame("Button", nil, stash_panel, "GameMenuButtonTemplate")
add_item_button:SetPoint("BOTTOM", stash_panel, "BOTTOM", 50, 20)
add_item_button:SetSize(100, 30)
add_item_button:SetText("Add Item")
if selected_line then
    local item = stash_list:GetLine(selected_line).item
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local success = hero:AddItem(item)
    if success then
        Notifications:Top(playerID,{text="You have collected your stored item", style={color="green"}, duration=5})
        table.remove(stored_items, selected_line)
        stash_list:RemoveLine(selected_line)
    else
        Notifications:Top(playerID,{text="Your inventory is full, please clear some space", style={color="red"}, duration=5})
    end
 
    
    -- Create a button to add items to the stored items
    local add_item_button = CreateFrame("Button", "AddItemButton", stash_panel, "UIPanelButtonTemplate")
    add_item_button:SetPoint("BOTTOMRIGHT", stash_panel, "BOTTOMRIGHT", -25, 25)
    add_item_button:SetSize(100, 30)
    add_item_button:SetText("Add Item")
    
    -- Create a dropdown menu to display the player's inventory items
    local inventory_dropdown = CreateFrame("Frame", "InventoryDropdown", stash_panel, "UIDropDownMenuTemplate")
    inventory_dropdown:SetPoint("BOTTOM", stash_panel, "BOTTOM", 0, 50)
    
    -- Populate the dropdown menu with the player's inventory items
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    for i=0,5 do
        local item = hero:GetItemInSlot(i)
        if item then
            local info = UIDropDownMenu_CreateInfo()
            info.text = item:GetAbilityName()
            info.value = i
            UIDropDownMenu_AddButton(info)
        end
    end
    
    add_item_button:SetScript("OnClick", function()
        local selected_item = UIDropDownMenu_GetSelectedValue(inventory_dropdown)
        if selected_item then
            local item = hero:GetItemInSlot(selected_item)
            table.insert(stored_items, item)
            local line = stash_list:AddLine(item:GetName(), item:GetAbilityDescription())
            line.item = item
        end
    end)
    
    stash_panel:Show()
    stash_panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    stash_panel:SetSize(250, 300)
    stash_panel:SetMovable(true)
    stash_panel:EnableMouse(true)
    stash_panel:SetResizable(true)
    stash_panel:SetMinResize(150, 150)
    stash_panel:SetMaxResize(450, 450)
    
    stash_panel:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    stash_panel:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
        end
    end)
end
