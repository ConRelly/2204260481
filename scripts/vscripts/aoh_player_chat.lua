require("lib/string")
function AOHGameMode:OnPlayerChat(keys)
	local time = GameRules:GetGameTime() / 60
	if keys.text == "-hard" and not self._hardMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._hardMode = true
		_G._hardMode = true
		Notifications:TopToAll({text="NotEasy mode has been activated.", style={color="red"}, duration=5})
		self:_ReadGameConfiguration()
	end
	if keys.text == "-endless" and not self._endlessMode and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._endlessMode = true
		Notifications:TopToAll({text="Almost Full Game Enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
	end
	if keys.text == "-full" and not self._endlessMode and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._endlessMode = true
		Notifications:TopToAll({text="Second part Enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
	end
	if keys.text == "-all" and (not self._endlessMode or not self._hardMode or not self._doubleMode) and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._endlessMode = true
		self._hardMode = true
		_G._hardMode = true
		self._doubleMode = true
		Notifications:TopToAll({text="Full Game, Hard Double Enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
		self:_ReadGameConfiguration()
	end
	if keys.text == "-fullhard" and (not self._endlessMode or not self._hardMode) and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._endlessMode = true
		self._hardMode = true
		_G._hardMode = true
		Notifications:TopToAll({text="Full Game Hard Enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
		self:_ReadGameConfiguration()
	end
	if keys.text == "-fullgame" and (not self._endlessMode or not self._hardMode) and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._endlessMode = true
		self._hardMode = true
		_G._hardMode = true
		Notifications:TopToAll({text="Full Game Enabled (hard only) ", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
		self:_ReadGameConfiguration()
	end
	if keys.text == "-extra" and not self._extra_mode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._extra_mode = true
		Notifications:TopToAll({text="Extra Mode Enabled, Bosses over lvl 14 will now get 2-6 random skills(Beta) ", style={color="blue"}, duration=9})		
	end	

	if keys.text == "-zeromanall" and not self._manaMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._manaMode = true
		Notifications:TopToAll({text="#game_mode_mana_enabled", style={color="blue"}, duration=5})
		-- mHackGameMode:ZeroManaMode()
	end
	if keys.text == "-Nonplussed Colonel " and not Cheats:IsEnabled() and time > 30 and not self.renew then
		Notifications:TopToAll({text="#renew_stats1", style={color="red"}, duration=5})
		self.renew = true
	end
	if keys.text == "-Ironic Enormity" and not Cheats:IsEnabled() and time > 30 and not self.renew then
		Notifications:TopToAll({text="#renew_stats2", style={color="red"}, duration=5})
		self.renew = true
	end
	if keys.text == guessing_game_1 and not Cheats:IsEnabled() and time > 1 and not self._physdanage and not GameRules:IsGamePaused() then
		Notifications:TopToAll({text="#dota_npc_does_ab", style={color="red"}, duration=7})
		self._physdanage = true
		self:_RenewStats()
	end
	if keys.text == guessing_game_2 and not Cheats:IsEnabled() and time > 30 and not self._physdanage and not GameRules:IsGamePaused() then
		Notifications:TopToAll({text="#dota_npc_does_bc", style={color="red"}, duration=5})
		self._physdanage = true
	end	



	if keys.text == "-autocast" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end
	if keys.text == "-autocast2" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast2") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast2")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast2")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast2")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end
	if keys.text == "-autocast3" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast3") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast3")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast3")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast3")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end
	if keys.text == "-autocast4" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast4") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast4")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast4")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast4")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end
	if keys.text == "-autocast5" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast5") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast5")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast5")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast5")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end	
	if keys.text == "-removeauto" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast4") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast4")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast4")
				Notifications:TopToAll({text="Removed autocast", style={color="blue"}, duration=1})				 
			end					   
		end	
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
	--[[if keys.text == "-dpsoff" and self.dpsinfo and keys.playerid == 0 then
		self.dpsinfo = false
		Notifications:TopToAll({text="Damage Counter Off", style={color="red"}, duration=5})		
	end	
	if keys.text == "-dpson" and not self.dpsinfo and keys.playerid == 0 then
		self.dpsinfo = true
		Notifications:TopToAll({text="Damage Counter ON", style={color="green"}, duration=5})		
	end]]	

	if keys.text == "-hide" then 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		_HideAbility(hero)
	end
	if keys.text == "-unhide" then 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		_UnHideAbility(hero)
	end

	function _CreateFakeCourier2(hero)
		local origin = Vector(-2958, 2031, -969) + RandomVector(100)
		local courier_replacement = CreateUnitByName("npc_courier_replacement", origin, true, hero, hero:GetOwner(), hero:GetTeamNumber())
		courier_replacement:SetControllableByPlayer(hero:GetPlayerID(), true)
		courier_replacement:SetTeam(hero:GetTeamNumber())
		courier_replacement:SetOwner(hero)
		--self._nPlayerHelp = courier_replacement
	
		courier_replacement:AddNewModifier(courier_replacement, nil, "modifier_mjz_fake_courier", {})
	
		local playerID = hero:GetPlayerID()
		local player = hero:GetPlayerOwner()
		-- local courier = PlayerResource:GetNthCourierForTeam(playerID, DOTA_TEAM_GOODGUYS) 
	
		
	end


	function _HideAbility(hero)
		if IsServer() then
			for i=6,hero:GetAbilityCount() -1 do
				local hAbility = hero:GetAbilityByIndex( i )
				if hAbility and not hAbility:IsAttributeBonus() and not hAbility:IsHidden() and not string.find(hAbility:GetAbilityName(), "empty") and bit.band( hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_PASSIVE ) ~= 0 then
					if hAbility:GetLevel() == hAbility:GetMaxLevel() then
						hAbility:SetHidden(true)
					end	
				end	
			end
		end		
	end
	function _UnHideAbility(hero)
		if IsServer() then
			for i=6,hero:GetAbilityCount() -1 do
				local hAbility = hero:GetAbilityByIndex( i )
				if hAbility and not hAbility:IsAttributeBonus() and hAbility:IsHidden() and not string.find(hAbility:GetAbilityName(), "empty") and bit.band( hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_PASSIVE ) ~= 0 then
					if hAbility:GetLevel() == hAbility:GetMaxLevel() then
						hAbility:SetHidden(false)
					end	
				end	
			end
		end		
	end	


	if keys.text == "-double" and not self._doubleMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._doubleMode = true
		Notifications:TopToAll({text="#game_mode_double_monsters_enabled", style={color="yellow"}, duration=5})
	end

	if keys.text == "-single" and not self._singleMode and keys.playerid == 0 then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if player_count == 1 then
			self._singleMode = true
			mHackGameMode:GM_SinglePlayer()
			_CreateFakeCourier2(hero)
			Notifications:TopToAll({text="#game_mode_single_player", style={color="yellow"}, duration=5})
		end
	end
--[[ 	if keys.text == "-endgame" and keys.playerid == 0 and time < 4 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
       	GameRules:SetSafeToLeave(true)
        end_screen_setup(true)
	end ]]
	
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

	local playerID = keys.playerid
	local player = PlayerResource:GetSelectedHeroEntity(playerID)
	if keys.text == "-killmepls" and player:HasModifier("modifier_inf_aegis") then
		self:Suicider(playerID)
	end

	
	if keys.text == "-SS" then
		if not _G.super_courier[keys.playerid] then
			_G.super_courier[keys.playerid] = true
			Notifications:RemoveTop(keys.playerid, 1)
			Notifications:Top(keys.playerid, {text="Super Scepter for non-heroes enabled", duration=3, style={color="green"}, continue=false})
		else
			_G.super_courier[keys.playerid] = false
			Notifications:RemoveTop(keys.playerid, 1)
			Notifications:Top(keys.playerid, {text="Super Scepter for non-heroes disabled", duration=3, style={color="red"}, continue=false})
		end
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
	self:RecountPlayers()
end
function AOHGameMode:OnPlayerDisconnect(keys)	
	print ( 'OnPlayerDisconnect' )
	-- PrintTable(keys)
	--local plyID = keys.PlayerID
	--local ply = PlayerResource:GetPlayer(plyID)
	--print("P" .. plyID .. " disconnected.")
	--local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
	--ply.disconnected = false
	
	self:RecountPlayers()
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
			local interval = 250 * 1
			hero._command_kill = hero._command_kill or 0
			if (now - hero._command_kill) < interval then
				return false
			else
				hero._command_kill = now
			end
		end	

		-- if isAlive then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			local rezPosition = hero:GetAbsOrigin()
			hero:RespawnHero(false, false)
			hero:SetAbsOrigin(rezPosition)
			Timers:CreateTimer({
				endTime = 0.15, 
				callback = function()
					hero:ForceKill(false)
				end
			})
			--if hero:HasModifier( "modifier_item_plain_ring_perma_invincibility" ) then
			--	hero:RemoveModifierByName( "modifier_item_plain_ring_perma_invincibility" )
			--	hero:SetAbsOrigin(rezPosition)
			--	hero:ForceKill(false)
			--end
			Timers:CreateTimer({
				endTime = 7, 
				callback = function()
					hero:ForceKill(false)
				end
			})
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
function AOHGameMode:Suicider(playerID)
	if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		local isAlive = hero:IsAlive()
		local rezPosition = hero:GetAbsOrigin()
		if isAlive then
			local ring_cd = hero:FindModifierByName("modifier_ring_perma_invincibility_cd")
			if ring_cd and ring_cd:GetStackCount() < 1 then
				ring_cd:SetStackCount(1)
			end
			Timers:CreateTimer(FrameTime(), function() hero:ForceKill(false) end)
		end
	end
end

