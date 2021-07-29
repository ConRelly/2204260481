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
            Notifications:Top(nPlayerID, { text = "#DOTA_HUD_Spells_Menu_Successful_Refund", duration = 4, style = { color = "green" } })
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
                Notifications:Top(nPlayerID, { text = "#DOTA_HUD_Spells_Menu_Successful_Purchase", duration = 4, style = { color = "green" } })
                CustomGameEventManager:Send_ServerToPlayer(player, "spells_menu_buy_spell_feedback", { new_card_points = newCardPoints }) -- Close the menu
            else
                Notifications:Top(nPlayerID, { text = "#DOTA_HUD_Spells_Menu_Insufficient_CP", duration = 4, style = { color = "red" } })
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
			if ability and not ability:IsAttributeBonus() and not ability:IsHidden() then
				local abilityName = ability:GetAbilityName()
				if not string.find(abilityName, "empty") then
					table.insert(playerAbilities, abilityName)
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