require("lib/data")
require("lib/my")
require('statcollection/lib/md5')

--[[
    DISCLAIMER:
    This file is heavily inspired and based on the open sourced code from Angel Arena Black Star, respecting their Apache-2.0 License.
    Thanks to Angel Arena Black Star.
]]


function formated_number(number)
    local as_string = tostring(math.floor(number))
    if number < 1000 then
        return as_string
    end

    local len = as_string:len()
    local split_point = len - 3

    return as_string:sub(1, split_point) .. "." .. as_string:sub(split_point + 1, len - 2) .. "K"
end


function end_screen_get_data(isWinner)
    local time = GameRules:GetDOTATime(false, true)
    local matchID = tostring(GameRules:Script_GetMatchID()) or 0

    local data = {
        version = "2.1.2",
        matchID = matchID,
        mapName = GetMapName(),
        players = {},
        isWinner = isWinner,
        duration = math.floor(time),
        flags = {}
    }

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if IsValidEntity(hero) then
                local playerInfo = {
                    steamid = tostring(PlayerResource:GetSteamID(playerID)),

                    damageTaken = formated_number(player_data_get_value(playerID, "damageTaken")),
                    bossDamage = formated_number(player_data_get_value(playerID, "bossDamage")),
                    heroHealing = formated_number(PlayerResource:GetHealing(playerID)),

                    deaths = PlayerResource:GetDeaths(playerID),
                    goldBags = player_data_get_value(playerID, "goldBagsCollected"),
                    saves = player_data_get_value(playerID, "saves"),
                    heroName = hero:GetName(),

                    attack = hero:GetAverageTrueAttackDamage(hero),
                    -- attack_bonus = hero:GetAverageTrueAttackDamage(hero) - hero:GetAttackDamage(),
                    str = hero:GetStrength(),
                    agi = hero:GetAgility(),
                    int = hero:GetIntellect(),

                    level = hero:GetLevel(),
                    items = {},
                    stacksr = {}
                }

                for item_slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
                    local item = hero:GetItemInSlot(item_slot)
                    if item then
                        playerInfo.items[item_slot] = item:GetAbilityName()
                    end
                end

                -- 15, 16 分别为TP槽位和自然物品槽位
                for item_slot = 16, 16 do
                    local item = hero:GetItemInSlot(item_slot)
                    if item then
                        playerInfo.items[item_slot] = item:GetAbilityName()
                    end
                end
                if hero:HasModifier("modifier_antimage_custom_mana_break_buff") then
                    local stacks = hero:FindModifierByName("modifier_antimage_custom_mana_break_buff")
                    local nr_stacks = stacks:GetStackCount()
                    playerInfo.stacksr["mana_break_Stacks"] = nr_stacks
                end
                data.players[playerID] = playerInfo
            end
        end
    end

    return data
end



local has_send_data = false
if info_data == nil then
    info_data = class({})
end

function end_screen_setup(isWinner)
    local data = end_screen_get_data(isWinner)

    CustomNetTables:SetTableValue("end_game_scoreboard", "game_info", data)
    info_data:send_data()
end



function info_data:send_data()
    local url = "http://localhost/"
    local stageName = "game_data.php?"
    local time = math.ceil(GameRules:GetDOTATime(false, true) / 60)
    local matchID = tostring(GameRules:Script_GetMatchID()) or 0
    local version = "1.6.9"
    local mapName = GetMapName()
    local currentRound = GameRules.GLOBAL_roundNumber
    local part3 = GameRules.GLOBAL_endlessHard_started
    local part2 = GameRules.GLOBAL_endlessMode_started
    local extra_mode = GameRules.GLOBAL_extra_mode
    local victory = GameRules.GLOBAL_vic_1
    local double_mode = GameRules.GLOBAL_doubleMode
    local hard_mode = GameRules.GLOBAL_hardMode
    local nr_players = 0

    if part3 then part3 = "Yes" else part3 = "No" end
    if part2 then part2 = "Yes" else part2 = "No" end
    if extra_mode then extra_mode = "Yes" else extra_mode = "No" end
    if hard_mode then hard_mode = "Yes" else hard_mode = "No" end
    if victory then victory = "Yes" else victory = "No" end
    if double_mode then double_mode = "Yes" else double_mode = "No" end



    url = url..stageName.."time=" ..time
    url = url.."&matchID="..matchID
    url = url.."&version="..version
    url = url.."&mapName="..GetMapName()
    url = url.."&currentRound="..currentRound
    url = url.."&part3="..part3
    url = url.."&part2="..part2
    url = url.."&hard_mode="..hard_mode
    url = url.."&extra_mode="..extra_mode
    url = url.."&double_mode="..double_mode
    url = url.."&victory="..victory


    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if IsValidEntity(hero) then
                nr_players = nr_players + 1
            end
        end
    end
    local playerInfo = {}

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if IsValidEntity(hero) then
                playerInfo[playerID] = {}
                playerInfo[playerID][1] = hero:GetName()
                playerInfo[playerID][2] = tostring(PlayerResource:GetSteamID(playerID))
                playerInfo[playerID][3] = PlayerResource:GetPlayerName(playerID)
                playerInfo[playerID][4] = formated_number(player_data_get_value(playerID, "damageTaken"))
                playerInfo[playerID][5] = formated_number(player_data_get_value(playerID, "bossDamage"))
                playerInfo[playerID][6] = formated_number(PlayerResource:GetHealing(playerID))
                playerInfo[playerID][7] = PlayerResource:GetDeaths(playerID)
                playerInfo[playerID][8] = player_data_get_value(playerID, "goldBagsCollected")
                playerInfo[playerID][9] = player_data_get_value(playerID, "saves")
                playerInfo[playerID][10] = hero:GetAverageTrueAttackDamage(hero)
                playerInfo[playerID][11] = hero:GetStrength()
                playerInfo[playerID][12] = hero:GetAgility()
                playerInfo[playerID][13] = hero:GetIntellect()
                playerInfo[playerID][14] = hero:GetLevel()

            end
        end
    end

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if IsValidEntity(hero) then
                local i = playerID
                local heroName = playerInfo[i][1]
                local steamid = playerInfo[i][2]
                local steam_name = playerInfo[i][3]
                local damageTaken = math.ceil(playerInfo[i][4])
                local bossDamage = math.ceil(playerInfo[i][5])
                local heroHealing = math.ceil(playerInfo[i][6])
                local deaths = playerInfo[i][7]
                local goldBags = playerInfo[i][8]
                local saves = playerInfo[i][9]
                local attack = math.ceil(playerInfo[i][10])
                local str = math.ceil(playerInfo[i][11])
                local agi = math.ceil(playerInfo[i][12])
                local int = math.ceil(playerInfo[i][13])
                local level = playerInfo[i][14]

                url = url.."&steam_id"..i.."="..steamid
                url = url.."&hero"..i.."="..heroName
                url = url.."&steam_name"..i.."="..steam_name
                url = url.."&damageTaken"..i.."="..damageTaken
                url = url.."&bossDamage"..i.."="..bossDamage
                url = url.."&heroHealing"..i.."="..heroHealing
                url = url.."&deaths"..i.."="..deaths
                url = url.."&goldBags"..i.."="..goldBags
                url = url.."&saves"..i.."="..saves
                url = url.."&attack"..i.."="..attack
                url = url.."&str"..i.."="..str
                url = url.."&agi"..i.."="..agi
                url = url.."&int"..i.."="..int
                url = url.."&level"..i.."="..level

                for item_slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
                    local item = hero:GetItemInSlot(item_slot)
                    if item then
                        url = url.."&itemName"..i..item_slot.."="..item:GetAbilityName()
                    end
                end
                for item_slot = 16, 16 do
                    local item = hero:GetItemInSlot(item_slot)
                    if item then
                        item_slot = 7
                        url = url.."&itemName"..i..item_slot.."="..item:GetAbilityName()
                    end
                end
            end
        end
    end


    local req = CreateHTTPRequestScriptVM('GET', url)
    print("pass 163 data")
    req:Send(function(res)
        if res.StatusCode ~= 200 then

            print("errorFailedToContactServer")
            print("Status Code", res.StatusCode or "nil")
            print("Body", res.Body or "nil")
            return
        end

        if not res.Body then
            print("errorEmptyServerResponse")
            print("Status Code", res.StatusCode or "nil")
            return
        end

    end)
end


