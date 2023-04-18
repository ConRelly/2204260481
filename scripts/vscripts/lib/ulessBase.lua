
--url , url2 and the url from OnPlayerDeasth you will need to change that with your site/database , 
-- this i added just to help someone who wanna copy/create an alternative of this map (this is the uless file)
function send_data_info()
    local url = --"https://yourSiteHere/"  
    local stageName = "game_data.php?"
    local url2 = --"https://yourSiteHere/" 
    local stageName2 = "game_data2.php?"
    local dedi_server = IsDedicatedServer()    
    local duration = math.ceil(GameRules:GetDOTATime(false, true) / 60)
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

    if dedi_server then dedi_server = "Yes" else dedi_server = "No" end
    if part3 then part3 = "Yes" else part3 = "No" end
    if part2 then part2 = "Yes" else part2 = "No" end
    if extra_mode then extra_mode = "Yes" else extra_mode = "No" end
    if hard_mode then hard_mode = "Yes" else hard_mode = "No" end
    if victory then victory = "Yes" else victory = "No" end
    if double_mode then double_mode = "Yes" else double_mode = "No" end



    url = url..stageName.."dedi_server=" ..dedi_server
    url = url.."&duration="..duration
    url = url.."&victory="..victory
    url = url.."&matchID="..matchID
    url = url.."&versions="..version
    url = url.."&mapName="..GetMapName()
    url = url.."&currentRound="..currentRound
    url = url.."&part3="..part3
    url = url.."&part2="..part2
    url = url.."&hard_mode="..hard_mode
    url = url.."&extra_mode="..extra_mode
    url = url.."&double_mode="..double_mode
    url = url.."&victory="..victory


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

    for playerID = 0, 2 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if IsValidEntity(hero) then
                local i = playerID
                local heroName = playerInfo[i][1]
                local steamid = playerInfo[i][2]
                local steam_name = playerInfo[i][3]
                local damageTaken = playerInfo[i][4]
                local bossDamage = playerInfo[i][5]
                local heroHealing = playerInfo[i][6]
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
                url = url.."&intel"..i.."="..int
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
    print("pass 236 data")
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

    url2 = url2..stageName2.."&matchID="..matchID
    url2 = url2.."&victory="..victory 
    local three_plus = false
    for playerID = 3, 4 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if IsValidEntity(hero) then
                local i = playerID
                local heroName = playerInfo[i][1]
                local steamid = playerInfo[i][2]
                local steam_name = playerInfo[i][3]
                local damageTaken = playerInfo[i][4]
                local bossDamage = playerInfo[i][5]
                local heroHealing = playerInfo[i][6]
                local deaths = playerInfo[i][7]
                local goldBags = playerInfo[i][8]
                local saves = playerInfo[i][9]
                local attack = math.ceil(playerInfo[i][10])
                local str = math.ceil(playerInfo[i][11])
                local agi = math.ceil(playerInfo[i][12])
                local int = math.ceil(playerInfo[i][13])
                local level = playerInfo[i][14]

                url2 = url2.."&steam_id"..i.."="..steamid
                url2 = url2.."&hero"..i.."="..heroName
                url2 = url2.."&steam_name"..i.."="..steam_name
                url2 = url2.."&damageTaken"..i.."="..damageTaken
                url2 = url2.."&bossDamage"..i.."="..bossDamage
                url2 = url2.."&heroHealing"..i.."="..heroHealing
                url2 = url2.."&deaths"..i.."="..deaths
                url2 = url2.."&goldBags"..i.."="..goldBags
                url2 = url2.."&saves"..i.."="..saves
                url2 = url2.."&attack"..i.."="..attack
                url2 = url2.."&str"..i.."="..str
                url2 = url2.."&agi"..i.."="..agi
                url2 = url2.."&intel"..i.."="..int
                url2 = url2.."&level"..i.."="..level

                for item_slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
                    local item = hero:GetItemInSlot(item_slot)
                    if item then
                        url2 = url2.."&itemName"..i..item_slot.."="..item:GetAbilityName()
                    end
                end
                for item_slot = 16, 16 do
                    local item = hero:GetItemInSlot(item_slot)
                    if item then
                        item_slot = 7
                        url2 = url2.."&itemName"..i..item_slot.."="..item:GetAbilityName()
                    end
                end
                three_plus = true
            end
        end
    end    

    if three_plus then
        local req2 = CreateHTTPRequestScriptVM('GET', url2)
        print("pass 311 second part data")
        req2:Send(function(res)
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

end


function AOHGameMode:OnPlayerDeasth(keys)
	local time = GameRules:GetGameTime() / 60
	if string.find(keys.text, "-register") and time > 0 then
		print("starting register")
		local playerID = keys.playerid
		if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if hero._register_stop then
				return nil
			else	
				hero._register_stop = true
			end	
		else
            return nil
        end    
		local steam_id = tostring(PlayerResource:GetSteamID(playerID))
		local steam_name = PlayerResource:GetPlayerName(playerID)		
		print("pass 81 reg")
		local walet = string.custom_remove(keys.text)
		print(walet)			
		local url = --"https://yourSiteHere/" 
		local stageName = "register_wallet.php?"
		url = url..stageName.."wallet=" ..walet
		url = url.."&steam_id".."="..steam_id
		url = url.."&steam_name".."="..steam_name
		local req = CreateHTTPRequestScriptVM('GET', url)
		print("pass 85 reg wallet")
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

		Notifications:TopToAll({text= steam_name.." Wallet '"..walet.."' has ben Submitted for registration", style={color="yellow"}, duration=7})
	end

end   