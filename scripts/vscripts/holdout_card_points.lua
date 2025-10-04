holdout_card_points = class({})

local cardPointsTableName = "card_points"

function holdout_card_points:Init()
    local playerIds = {}
    local playerPoints = {}

    local startingCardPoints = 0
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        playerIds[nPlayerID] = true
        playerPoints[nPlayerID] = startingCardPoints
    end

    PlayerTables:CreateTable(cardPointsTableName, playerPoints, playerIds)

    CustomGameEventManager:RegisterListener("spells_menu_buy_spell", function(...)
        return self:_SpellsMenuBuySpell(...)
    end)

    CustomGameEventManager:RegisterListener("spells_menu_get_player_spells", function(...)
        return self:_SpellsMenuGetSpells(...)
    end)

    CustomGameEventManager:RegisterListener("spells_menu_swap_player_spells", function(...)
        return self:_SpellsMenuSwapAbilitiesPosition(...)
    end)

    CustomGameEventManager:RegisterListener("spells_menu_hide_player_spells", function(...)
        return self:_SpellsMenuHideAbility(...)
    end)

    CustomGameEventManager:RegisterListener("spells_menu_get_player_spells_hidden", function(...)
        return self:_SpellsMenuGetHiddenSpells(...)
    end)

    CustomGameEventManager:RegisterListener("spells_menu_get_stalker_abilities", function(...)
        return self:_SpellsMenuGetStalkerAbilities(...)
    end)

    CustomGameEventManager:RegisterListener("spells_menu_buy_stalker_spell", function(...)
        return self:_SpellsMenuBuyStalkerSpell(...)
    end)

    CustomGameEventManager:RegisterListener("spells_menu_update_stalker_eligibility", function(...)
        return self:_SpellsMenuUpdateStalkerEligibility(...)
    end)

end

function holdout_card_points:_RetrieveCardPoints(nPlayerID)
    if PlayerTables:TableExists(cardPointsTableName) then
        return PlayerTables:GetTableValue(cardPointsTableName, nPlayerID)
    end

    return 0
end

function holdout_card_points:_SetCardPoints(nPlayerID, cardPoints)
    if PlayerTables:TableExists(cardPointsTableName) then
        PlayerTables:SetTableValue(cardPointsTableName, nPlayerID, cardPoints)
    end
end

function holdout_card_points:_BuyCardPoints(nPlayerID, cardPoints)
    if PlayerTables:TableExists(cardPointsTableName) then
        local player = PlayerResource:GetPlayer(nPlayerID)
        local newCardPoints = self:_RetrieveCardPoints(nPlayerID) + cardPoints
        self:_SetCardPoints(nPlayerID, newCardPoints)
        CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_buy_spell_feedback", { new_card_points = newCardPoints })
        Notifications:Top(nPlayerID, { text = "#DOTA_HUD_Spells_Menu_Card_Point_Book_Used", duration = 4, style = { color = "green" } })
    end
end

function holdout_card_points:_SpellsMenuBuySpell(eventSourceIndex, event_data)
    local nPlayerID = event_data.player_id
    local abilityName = event_data.spell_id
    local abilityCost = event_data.cost
    local associatedAbilities = event_data.associated_spells
    local associatedLearnables = event_data.associated_learnables

    if PlayerResource:HasSelectedHero(nPlayerID) then
        local player = PlayerResource:GetPlayer(nPlayerID)
        local playerHero = player:GetAssignedHero()
        local cardPoints = 0

        -- check for card points and retrieve
        cardPoints = self:_RetrieveCardPoints(nPlayerID)

        -- Does the player already have the ability requested?
        if playerHero:HasAbility(abilityName) then
            -- Trying to refund
            local existingAbility = playerHero:FindAbilityByName(abilityName)
            local spellLevel = existingAbility:GetLevel()
            local abilityPointsToSet = playerHero:GetAbilityPoints()
            if spellLevel ~= 0 then
                -- IF it is a learnable ability, refund ability points spent
                if not (bit.band(existingAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) ~= 0) then
                    abilityPointsToSet = abilityPointsToSet + spellLevel
                end
            end
            playerHero:RemoveAbilityByHandle(existingAbility)
            if associatedAbilities then
                -- Remove associated abilities
                for _, associatedAbilityName in pairs(associatedAbilities) do
                    playerHero:RemoveAbility(associatedAbilityName)
                end
            end
            if associatedLearnables then
                -- Remove associated learnables
                for _, associatedLearnableName in pairs(associatedLearnables) do
                    -- refund points
                    local learnableAbility = playerHero:FindAbilityByName(associatedLearnableName)
                    -- IF it is a learnable ability, refund ability points spent
                    if not (bit.band(learnableAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) ~= 0) then
                        abilityPointsToSet = abilityPointsToSet + learnableAbility:GetLevel()
                    end
                    playerHero:RemoveAbilityByHandle(learnableAbility)
                end
            end
            playerHero:SetAbilityPoints(abilityPointsToSet)

            -- Refund the card points
            local newCardPoints = cardPoints + abilityCost
            self:_SetCardPoints(nPlayerID, newCardPoints)
            Notifications:Top(nPlayerID, { text = "Ability successfully refunded!", duration = 4, style = { color = "green" } })
            CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_buy_spell_feedback", { new_card_points = newCardPoints }) -- Close the menu
        else
            -- Trying to buy
            if cardPoints >= abilityCost then
                local newAbility = playerHero:AddAbility(abilityName)
                CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_learned_ability", { player = player, abilityname = abilityName })
                if bit.band(newAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) ~= 0 then
                    newAbility:SetLevel(1)
                else
                    newAbility:SetLevel(0)
                end
                newAbility:MarkAbilityButtonDirty()
                if associatedAbilities then
                    -- Add associated abilities
                    for _, associatedAbilityName in pairs(associatedAbilities) do
                        local associatedAbility = playerHero:AddAbility(associatedAbilityName)
                        associatedAbility:MarkAbilityButtonDirty()
                    end
                end
                if associatedLearnables then
                    -- Add associated learnable
                    for _, associatedLearnableName in pairs(associatedLearnables) do
                        local associatedLearnable = playerHero:AddAbility(associatedLearnableName)
                        associatedLearnable:MarkAbilityButtonDirty()
                    end
                end
                -- Deduct card points
                local newCardPoints = cardPoints - abilityCost
                self:_SetCardPoints(nPlayerID, newCardPoints)
                Notifications:Top(nPlayerID, { text = "Ability successfully purchased!", duration = 4, style = { color = "green" } })
                CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_buy_spell_feedback", { new_card_points = newCardPoints }) -- Close the menu
            else
                Notifications:Top(nPlayerID, { text = "Insufficient Card Points!", duration = 4, style = { color = "red" } })
            end
        end

        playerHero:CalculateStatBonus(false)
        CustomGameEventManager:Send_ServerToPlayer(player, "dota_ability_changed", { entityIndex = playerHero })
    end
end

function holdout_card_points:_SpellsMenuGetSpells(eventSourceIndex, event_data)
    local nPlayerID = event_data.player_id
    local player = PlayerResource:GetPlayer(nPlayerID)
    local playerAbilities = self:_GetPlayerSpells(nPlayerID)

    CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_get_player_spells_feedback", { player_abilities = playerAbilities })
end

function holdout_card_points:_GetPlayerSpells(nPlayerID)
    local player = PlayerResource:GetPlayer(nPlayerID)
    if player and PlayerResource:HasSelectedHero(nPlayerID) then
        local playerHero = player:GetAssignedHero()
        local maxAbilities = playerHero:GetAbilityCount() - 1

        local playerAbilities = {}

        for i = 0, maxAbilities do
            local ability = playerHero:GetAbilityByIndex(i)
            if playerHero:GetUnitName() == "npc_dota_hero_doom_bringer"  then
                if ability and not ability:IsAttributeBonus() and not ability:IsHidden() then --and ability ~= playerHero:GetAbilityByIndex(3)
                    local abilityName = ability:GetAbilityName()
                    if not string.find(abilityName, "empty") and not string.find(abilityName, "autocast") and not string.find(abilityName, "fireblast") then
                        table.insert(playerAbilities, abilityName)
                    end    
                end
            elseif playerHero:GetUnitName() == "npc_dota_hero_lone_druid" or playerHero:GetUnitName() == "npc_dota_hero_rubick" then
                if ability and not ability:IsAttributeBonus() and not ability:IsHidden() and ability ~= playerHero:GetAbilityByIndex(3) and ability ~= playerHero:GetAbilityByIndex(4) then --
                    local abilityName = ability:GetAbilityName()
                    if not string.find(abilityName, "empty") then
                        table.insert(playerAbilities, abilityName)
                    end    
                end    
            else
                if ability and not ability:IsAttributeBonus() and not ability:IsHidden() then --
                    local abilityName = ability:GetAbilityName()
                    if not string.find(abilityName, "empty") then
                        table.insert(playerAbilities, abilityName)
                    end    
                end
            end            
        end

        return playerAbilities
    end

    return {}
end

function holdout_card_points:_SpellsMenuSwapAbilitiesPosition(eventSourceIndex, event_data)
	local nPlayerID = event_data.player_id
	local firstAbilityName = event_data.first_ability_name
	local secondAbilityName = event_data.second_ability_name
	local player = PlayerResource:GetPlayer(nPlayerID)

	self:_SwapAbilitiesPosition(nPlayerID, firstAbilityName, secondAbilityName)

    CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_swap_player_spells_feedback", { })
end




function holdout_card_points:_SpellsMenuGetHiddenSpells(eventSourceIndex, event_data)
    local nPlayerID = event_data.player_id
    local player = PlayerResource:GetPlayer(nPlayerID)
	if player:GetAssignedHero().playerAbilities == nil then
		player:GetAssignedHero().playerAbilities = {}
	end
    local playerAbilities = player:GetAssignedHero().playerAbilities--self:_GetPlayerHiddenSpells(nPlayerID)

    CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_get_player_spells_hidden_feedback", { player_abilities = playerAbilities })
end
--[[
function holdout_card_points:_GetPlayerHiddenSpells(nPlayerID)
    local player = PlayerResource:GetPlayer(nPlayerID)
    if player and PlayerResource:HasSelectedHero(nPlayerID) then
        local playerHero = player:GetAssignedHero()
        local maxAbilities = playerHero:GetAbilityCount() - 1
		
		local non_trigger_inflictors = {
			["special_bonus_attributes"] = true,
			["ability_capture"] = true,
		}
		
        local playerAbilities = {}

        for i = 0, maxAbilities do
            local ability = playerHero:GetAbilityByIndex(i)
            if playerHero:GetUnitName() == "npc_dota_hero_doom_bringer"  then
                if ability and not ability:IsAttributeBonus() and ability:IsHidden() then
                    local abilityName = ability:GetAbilityName()
                    if not string.find(abilityName, "empty") and not string.find(abilityName, "autocast") and not string.find(abilityName, "fireblast") then
                        table.insert(playerAbilities, abilityName)
                    end    
                end
            elseif playerHero:GetUnitName() == "npc_dota_hero_lone_druid" or playerHero:GetUnitName() == "npc_dota_hero_rubick" then
                if ability and not ability:IsAttributeBonus() and ability:IsHidden() and ability ~= playerHero:GetAbilityByIndex(3) and ability ~= playerHero:GetAbilityByIndex(4) then
                    local abilityName = ability:GetAbilityName()
                    if not string.find(abilityName, "empty") then
                        table.insert(playerAbilities, abilityName)
                    end    
                end    
            else
                if ability and not ability:IsAttributeBonus() and ability:IsHidden() then
                    local abilityName = ability:GetAbilityName()
                    if not string.find(abilityName, "empty") then
                        table.insert(playerAbilities, abilityName)
                    end    
                end
            end            
        end

        return playerAbilities
    end

    return {}
end
]]
function holdout_card_points:_SpellsMenuHideAbility(eventSourceIndex, event_data)
	local nPlayerID = event_data.player_id
	local firstAbilityName = event_data.first_ability_name
	local player = PlayerResource:GetPlayer(nPlayerID)
    if player and PlayerResource:HasSelectedHero(nPlayerID) then

		if player:GetAssignedHero().playerAbilities == nil then
			player:GetAssignedHero().playerAbilities = {}
		end

		local firstAbility = player:GetAssignedHero():FindAbilityByName(firstAbilityName)
		if firstAbility and not firstAbility:IsHidden() then
			firstAbility:SetHidden(true)
			table.insert(player:GetAssignedHero().playerAbilities, firstAbilityName)
			CustomGameEventManager:Send_ServerToPlayer(player, "dota_ability_changed", {entityIndex = playerHero})
			CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_hide_player_spells2_feedback", {})
		elseif firstAbility and firstAbility:IsHidden() then
			firstAbility:SetHidden(false)
			for id,ab in pairs(player:GetAssignedHero().playerAbilities) do
				if ab == firstAbilityName then
					table.remove(player:GetAssignedHero().playerAbilities, id)
				end
			end
			
			CustomGameEventManager:Send_ServerToPlayer(player, "dota_ability_changed", {entityIndex = playerHero})
			CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_hide_player_spells_feedback", {})
		end
	end
end


function holdout_card_points:_SwapAbilitiesPosition(nPlayerID, firstAbilityName, secondAbilityName)
    local player = PlayerResource:GetPlayer(nPlayerID)
    local playerHero = player:GetAssignedHero()
    local firstAbility = playerHero:FindAbilityByName(firstAbilityName)
    local secondAbility = playerHero:FindAbilityByName(secondAbilityName)
    --local firstAbilityName = firstAbility:GetAbilityName()
    --local secondAbilityName = secondAbility:GetAbilityName()
   -- local slot_id = playerHero:GetAbilityByIndex(3):GetAbilityName()
    --local slot_id_name = slot_id:GetAbilityName()
    --if not firstAbilityName == slot_id and not secondAbilityName == slot_id then
    if firstAbility and secondAbility then
        playerHero:SwapAbilities(firstAbilityName, secondAbilityName, not firstAbility:IsHidden(), not secondAbility:IsHidden())

        CustomGameEventManager:Send_ServerToPlayer(player, "dota_ability_changed", { entityIndex = playerHero })
    end
end

function holdout_card_points:_SpellsMenuGetStalkerAbilities(eventSourceIndex, event_data)
    local nPlayerID = event_data.player_id
    local player = PlayerResource:GetPlayer(nPlayerID)

    if player and PlayerResource:HasSelectedHero(nPlayerID) then
        local playerHero = player:GetAssignedHero()

        -- Check if player is in stalker list and hasn't used their choice yet
        if IsStalkerList(playerHero) or (_G._stalker_skill and _G._stalker_skill[nPlayerID] == true) then
            -- Check if player has already used their stalker ability choice this game
            if not self:_HasUsedStalkerChoice(nPlayerID) then
                -- Get the stalker ability list and send to client
                local eventData = {
                    can_use = true
                }
                CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_get_stalker_abilities_feedback", eventData)
            else
                -- Player has already used their choice
                CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_get_stalker_abilities_feedback", {
                    stalker_abilities = {},
                    can_use = false,
                    message = "You have already used your 1 time ability choice this game."
                })
            end
        else
            -- Player is not in stalker list
            CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_get_stalker_abilities_feedback", {
                stalker_abilities = {},
                can_use = false,
                message = "You are not eligible for 1 time ability choice. Kill Aghanim, the Apex Mage foar a 20% chance"
            })
        end
    else
        -- Player or hero not found
    end
end

function holdout_card_points:_SpellsMenuBuyStalkerSpell(eventSourceIndex, event_data)
    local nPlayerID = event_data.player_id
    local abilityName = event_data.spell_id
    local player = PlayerResource:GetPlayer(nPlayerID)

    if player and PlayerResource:HasSelectedHero(nPlayerID) then
        local playerHero = player:GetAssignedHero()

        -- Check if player is in stalker list
        if IsStalkerList(playerHero) or (_G._stalker_skill and _G._stalker_skill[nPlayerID] == true) then
            -- Check if player has already used their stalker ability choice this game
            if not self:_HasUsedStalkerChoice(nPlayerID) then
                -- Check if player already has this ability
                if not playerHero:HasAbility(abilityName) then
                    -- Add the ability
                    local newAbility = playerHero:AddAbility(abilityName)
                    if newAbility then
                        -- Set appropriate level based on ability type
                        if bit.band(newAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) ~= 0 then
                            newAbility:SetLevel(1)
                        else
                            newAbility:SetLevel(0)
                        end
                        newAbility:MarkAbilityButtonDirty()

                        -- Mark that this player has used their stalker choice
                        self:_MarkStalkerChoiceUsed(nPlayerID)

                        -- Send success feedback
                        Notifications:Top(nPlayerID, {
                            text = "1 Time Choice ability successfully chosen!",
                            duration = 7,
                            style = { color = "green" }
                        })
                        CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_buy_spell_feedback", {
                            new_card_points = self:_RetrieveCardPoints(nPlayerID)
                        })

                        -- Close the menu
                        CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_buy_stalker_spell_feedback", {})
                    end
                else
                    Notifications:Top(nPlayerID, {
                        text = "You already have this ability!",
                        duration = 8,
                        style = { color = "red" }
                    })
                end
            else
                Notifications:Top(nPlayerID, {
                    text = "You have already used your 1 Time Choice ability choice!",
                    duration = 9,
                    style = { color = "red" }
                })
            end
        else
            Notifications:Top(nPlayerID, {
                text = "You are not eligible for 1 time Choice ability choice! Kill Aghanim, the Apex Mage foar a 25% chance",
                duration = 9,
                style = { color = "red" }
            })
        end

        playerHero:CalculateStatBonus(false)
        CustomGameEventManager:Send_ServerToPlayer(player, "dota_ability_changed", { entityIndex = playerHero })
    end
end


function holdout_card_points:_HasUsedStalkerChoice(nPlayerID)
    -- Check if player has used their stalker choice this game
    -- We'll use PlayerTables to track this persistently across the game
    local stalkerUsedTableName = "stalker_ability_used"

    if not PlayerTables:TableExists(stalkerUsedTableName) then
        PlayerTables:CreateTable(stalkerUsedTableName, {}, {nPlayerID})
        return false
    end

    local usedStatus = PlayerTables:GetTableValue(stalkerUsedTableName, nPlayerID)
    return usedStatus == true
end

function holdout_card_points:_MarkStalkerChoiceUsed(nPlayerID)
    -- Mark that this player has used their stalker choice
    local stalkerUsedTableName = "stalker_ability_used"

    if PlayerTables:TableExists(stalkerUsedTableName) then
        PlayerTables:SetTableValue(stalkerUsedTableName, nPlayerID, true)
    else
        PlayerTables:CreateTable(stalkerUsedTableName, {[nPlayerID] = true}, {nPlayerID})
    end
end

function holdout_card_points:_SpellsMenuUpdateStalkerEligibility(eventSourceIndex, event_data)
    local nPlayerID = event_data.player_id
    local player = PlayerResource:GetPlayer(nPlayerID)

    if player and PlayerResource:HasSelectedHero(nPlayerID) then
        local playerHero = player:GetAssignedHero()

        -- Check if player is in stalker list OR has gained eligibility from NPC kill
        local isEligible = IsStalkerList(playerHero) or (_G._stalker_skill and _G._stalker_skill[nPlayerID] == true)
        local canUse = isEligible and not self:_HasUsedStalkerChoice(nPlayerID)
        --update table for _G._stalker_skill[nPlayerID] to true if the player is true for IsStalkerList(playerHero)
        if isEligible and _G._stalker_skill and _G._stalker_skill[nPlayerID] ~= true then
            _G._stalker_skill[nPlayerID] = true
        end
        -- Send current eligibility status to client
        local eventData = {
            can_use = canUse,
            is_eligible = isEligible
        }
        CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_update_stalker_eligibility_feedback", eventData)
    end
end