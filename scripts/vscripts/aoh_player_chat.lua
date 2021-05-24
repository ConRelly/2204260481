
function AOHGameMode:OnPlayerChat(keys)
	
	if keys.text == "-hard" and not self._hardMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._hardMode = true
		Notifications:TopToAll({text="Hard mode has been activated.", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 2
	end
	if keys.text == "-endless" and not self._endlessMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._endlessMode = true
		Notifications:TopToAll({text="#game_mode_endless_enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 5
	end

	if keys.text == "-zeromanall" and not self._manaMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._manaMode = true
		Notifications:TopToAll({text="#game_mode_mana_enabled", style={color="blue"}, duration=5})
		-- mHackGameMode:ZeroManaMode()
	end

	if keys.text == "-zeromana" then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
		local playerID = keys.playerid
		if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if player_count < 4 then
				self._manaMode = true
				mHackGameMode:ZeroManaMode(hero)
			else
				mHackGameMode:ZeroManaModeAlone(hero)
			end
		end
	end

	if keys.text == "-double" and not self._doubleMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._doubleMode = true
		Notifications:TopToAll({text="#game_mode_double_monsters_enabled", style={color="yellow"}, duration=5})
	end

	if keys.text == "-single" and not self._singleMode and keys.playerid == 0 then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		if player_count == 1 then
			self._singleMode = true
			mHackGameMode:GM_SinglePlayer()
			Notifications:TopToAll({text="#game_mode_single_player", style={color="yellow"}, duration=5})
		end
	end


    
    if keys.text == "-refresh" then
		self._physdamage[keys.playerid] = 1
		self._magdamage[keys.playerid] = 1
		self._puredamage[keys.playerid] = 1
    end
    
	if keys.text == "-renew" then
		-- CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerid), "delete", {})
		-- for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		-- 	if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
		-- 		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerid), "game_begin", {name = PlayerResource:GetSelectedHeroName(playerID), id = playerID})
		-- 	end
        -- end
        self:RenewDamageUI(keys.playerid)
	end

	if keys.text == "-kill" then
		local playerID = keys.playerid
		self:CC_Kill(playerID)
    end
end

function AOHGameMode:OnPlayerConnect(keys)
	--print('PlayerConnect')
	-- PrintTable(keys)
	local plyID = keys.PlayerID
	if plyID then
		local ply = PlayerResource:GetPlayer(plyID)
		
		self:RenewDamageUI(plyID)
	end
end

function AOHGameMode:OnPlayerReconnect(keys)
	print ( 'OnPlayerReconnect' )
	-- PrintTable(keys)
	local plyID = keys.PlayerID
	local ply = PlayerResource:GetPlayer(plyID)
	print("P" .. plyID .. " reconnected.")
	local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
    ply.disconnected = false
    
    self:RenewDamageUI(plyID)
end


-- 伤害统计UI
function AOHGameMode:RenewDamageUI(playerid)
	local nNewState = GameRules:State_Get()

    if nNewState ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then	 -- 游戏开始
        return false
    end

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerid), "delete", {})
    for pid = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(pid) and PlayerResource:HasSelectedHero(pid) then
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerid), "game_begin", {
                name = PlayerResource:GetSelectedHeroName(pid), 
                id = pid
            })
        end
    end
end

-- 刷新所以玩家的伤害统计UI
function AOHGameMode:RenewAllPlayerDamageUI()
	local now = GameRules:GetGameTime()
	if self._prev_renew_all == nil then
		self._prev_renew_all = now
		return 
	end

	if (now - self._prev_renew_all) < 30 then
		return
	else
		self._prev_renew_all = now
	end

	-- CustomGameEventManager:Send_ServerToAllClients("delete", {})
	-- for playerID = 0, 4 do
	-- 	if PlayerResource:IsValidPlayerID(playerID) then
	-- 		if PlayerResource:HasSelectedHero(playerID) then
	-- 			CustomGameEventManager:Send_ServerToAllClients("game_begin", {name = PlayerResource:GetSelectedHeroName(playerID), id = playerID})
	-- 			-- self:RenewDamageUI(playerID)
	-- 		end
	-- 	end
	-- end
end

function AOHGameMode:CC_Kill( playerID )
	if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		local isAlive = hero:IsAlive()

		if not IsInToolsMode() then
			local now = GameRules:GetGameTime()
			local interval = 60 * 1
			hero._command_kill = hero._command_kill or 0
			if (now - hero._command_kill) < interval then
				return false
			else
				hero._command_kill = now
			end
		end	

		-- if isAlive then
			hero:RespawnUnit()
			hero:ForceKill(false)
		-- else
		-- 	local nSearchRange = 1000
		-- 	local hEnemies = FindUnitsInRadius( hero:GetTeamNumber(), hero:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		-- 	if #hEnemies > 0 then
		-- 		-- return false
		-- 	end
		-- 	local vLocation = hero:GetOrigin()
		-- 	hero:RespawnHero( false, false )
		-- 	hero:RespawnUnit()
		-- 	FindClearSpaceForUnit( hero, vLocation, true )
		-- end
	end
end

