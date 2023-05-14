require("AOHSpawner")
require("lib/my")
require("lib/notifications")





if AOHGameRound == nil then
	AOHGameRound = class({})
end



function AOHGameRound:ReadConfiguration(kv, gameMode, roundNumber)
	if not IsServer() then return end
	self._gameMode = gameMode
	self._nRoundNumber = roundNumber
	self._sTitle = kv.Title or ""
	self._nMaxGold = tonumber(kv.MaxGold or 0)
	self._nBagCount = tonumber(kv.BagCount or 0)
	self._nBagVariance = tonumber(kv.BagVariance or 0)
	self._nFixedXP = tonumber(kv.FixedXP or 0)

	self._vSpawners = {}
	for k, v in pairs(kv) do
		if type(v) == "table" and v.NPCName then
			local spawner = AOHSpawner()
			spawner:ReadConfiguration(k, v, self)
			self._vSpawners[ k ] = spawner
		end
	end

	for _, spawner in pairs(self._vSpawners) do
		spawner:PostLoad(self._vSpawners)
	end
end


function AOHGameRound:Precache()
	for _, spawner in pairs(self._vSpawners) do
		spawner:Precache()
	end
end

-- 无尽模式开始
function AOHGameRound:BeginEndless(roundCount)
	self._endlessMode_started = true
	self._roundCount = roundCount
end

-- 双倍模式开始
function AOHGameRound:BeginDouble()
	self._doubleMode = true
end

function AOHGameRound:GetRoundNumber()
	return self._nRoundNumber
end



function AOHGameRound:Begin(goldRatio, expRatio)
	if not IsServer() then return end
	if not self._endlessMode_started then
		local title = "Round " .. self._nRoundNumber .. ": " .. self._sTitle
		Notifications:TopToAll({text=title, duration=6})
	end

	self._vEnemiesRemaining = {}
	self._vEventHandles = {
		ListenToGameEvent("npc_spawned", Dynamic_Wrap(AOHGameRound, "OnNPCSpawned"), self),
		ListenToGameEvent("entity_killed", Dynamic_Wrap(AOHGameRound, "OnEntityKilled"), self),
	}

	self._vPlayerStats = {}
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		self._vPlayerStats[ nPlayerID ] = {
			nCreepsKilled = 0,
			nGoldBagsCollected = 0,
			nPriorRoundDeaths = PlayerResource:GetDeaths(nPlayerID),
			nPlayersResurrected = 0
		}
	end
	self._nGoldRemainingInRound = self._nMaxGold * goldRatio
	self._nFixedXP = self._nFixedXP * expRatio
	self._nGoldBagsRemaining = self._nBagCount
	self._nGoldBagsExpired = 0
	self._nCoreUnitsTotal = 0
	for _, spawner in pairs(self._vSpawners) do
		if self._endlessMode_started then
			spawner:BeginEndless(self._roundCount)
		end
		if self._doubleMode then
			spawner:BeginDouble()
		end
		spawner:Begin()
		self._nCoreUnitsTotal = self._nCoreUnitsTotal + spawner:GetTotalUnitsToSpawn()
	end
	self._nCoreUnitsKilled = 0
	
end


function AOHGameRound:End()
	if not IsServer() then return end
	for _, eID in pairs(self._vEventHandles) do
		StopListeningToGameEvent(eID)
	end
	self._vEventHandles = {}
	local skip = 0.05
	for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false)) do
		if (not unit:IsTower()) and (not unit.mjz_retain) then
			--if not self._endlessMode_started then
 			skip = skip + 0.03
			local name = unit:GetUnitName()
			Timers:CreateTimer({
				endTime = 50 + skip, 
				callback = function()
					if unit and not unit:IsNull() and IsValidEntity(unit) then
						--print("focekill unit: "..name .." or remove if Dead")
						if unit:IsAlive() then
							unit:ForceKill(false)
						elseif not unit:IsNull() and IsValidEntity(unit) then
							--print("remove unit: "..name )
							UTIL_Remove(unit)
						end	
					end	
				end
			})	 			
			--end
		end
	end

	for _,spawner in pairs(self._vSpawners) do
		spawner:End()
	end
	local center = Vector(0, 0, 0)
	local rune_position = Vector(-2307.83, 276, 448)
	local minRadius = 50
	local maxRadius = 2250
	local runePos = GetRandomPointOnMap(rune_position, 50, 350)
	local itemPos = GetRandomPointOnMap(center, minRadius, maxRadius)
	if RollPercentage(90) then
		local rune = CreateRune(runePos, DOTA_RUNE_XP)
		create_item_drop("item_tome_of_knowledge", itemPos)
	end
end

function create_item_drop(item_name, pos)
	local item = CreateItem(item_name, nil, nil)
	item:SetPurchaseTime(0)
	item:SetStacksWithOtherOwners(true)
	local drop = CreateItemOnPositionSync(pos, item)
	item:LaunchLoot(false, 300, 0.75, pos, nil)
end


function GetRandomPointOnMap(center, minRadius, maxRadius)
	local direction = RandomVector(1)
	local distance = RandomFloat(minRadius, maxRadius)
	local offset = direction * distance
	local pos = center + offset
	return GetGroundPosition(pos, nil)
end


function AOHGameRound:Think()
	if not IsServer() then return end
	for _, spawner in pairs(self._vSpawners) do
		spawner:Think()
	end
end


function AOHGameRound:ChooseRandomSpawnInfo()
	return self._gameMode:ChooseRandomSpawnInfo()
end


function AOHGameRound:IsFinished()
	if not IsServer() then return end
	for _, spawner in pairs(self._vSpawners) do
		if not spawner:IsFinishedSpawning() then
			return false
		end
	end

	if self._endlessMode_started then
		if self._nRoundNumber < self._roundCount then
			return true
		end
	end

	local nEnemiesRemaining = #self._vEnemiesRemaining
	if nEnemiesRemaining < 1 then
		return true
	end

	if not self._lastEnemiesRemaining == nEnemiesRemaining then
		self._lastEnemiesRemaining = nEnemiesRemaining
		debug_print(string.format("%d enemies remaining in the round...", #self._vEnemiesRemaining))
	end
	return false
end


function AOHGameRound:GetXPPerCoreUnit()
	if not IsServer() then return end
	if self._nCoreUnitsTotal == 0 then
		return 0
	else
		return math.floor(self._nFixedXP / self._nCoreUnitsTotal)
	end
end


function AOHGameRound:OnNPCSpawned(event)
	if not IsServer() then return end
	local spawnedUnit = EntIndexToHScript(event.entindex)
	if not IsValidEntity(spawnedUnit) then return end
	if not spawnedUnit or spawnedUnit:IsPhantom() or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:GetUnitName() == "" or spawnedUnit:IsIllusion() then
		return
	end
	if spawnedUnit:GetUnitLabel() == "temp_unit" or spawnedUnit:GetUnitLabel() == "pharaoh_ok" or spawnedUnit:GetUnitName() == "npc_dota_invisible_vision_source" then
		return
	end

	if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		if spawnedUnit:GetLevel() < 5 and spawnedUnit:GetUnitName() ~= "npc_boss_juggernaut_4" then return end
		spawnedUnit:SetMustReachEachGoalEntity(true)
		table.insert(self._vEnemiesRemaining, spawnedUnit)
		spawnedUnit:SetDeathXP(0)
		spawnedUnit.unitName = spawnedUnit:GetUnitName()
		Timers:CreateTimer(120, -- 2 minutes in seconds
		function()
		  if not spawnedUnit:IsNull() and IsValidEntity(spawnedUnit) and spawnedUnit:IsAlive() then
			print("enemey unit is alive after 2 min")
			spawnedUnit:SetAbsOrigin(Vector(0, 0, 0)) -- or whatever the center of the map is
			FindClearSpaceForUnit(spawnedUnit, Vector(0, 0, 0), true)
			AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnedUnit:GetAbsOrigin(), 1200, 120, false)
		  end
		end)		

		if self._endlessMode_started then
			GameRules.GameMode:AddEndlessEnemy(spawnedUnit)
		end
	end
end


function AOHGameRound:OnEntityKilled(event)
	if not IsServer() then return end
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	if not IsValidEntity(killedUnit) then return end
	if not killedUnit then
		return
	end

	for i, unit in pairs(self._vEnemiesRemaining) do
		if killedUnit == unit then
			table.remove(self._vEnemiesRemaining, i)
			break
		end
	end	
	if killedUnit.Holdout_IsCore then
		self._nCoreUnitsKilled = self._nCoreUnitsKilled + 1
		self:_CheckForGoldBagDrop(killedUnit)
		self._gameMode:CheckForLootItemDrop(killedUnit)
		self:GiveXPToAllHeroes(self:GetXPPerCoreUnit())
	end

	local attackerUnit = EntIndexToHScript(event.entindex_attacker or -1)
	if attackerUnit then
		local playerID = attackerUnit:GetPlayerOwnerID()
		local playerStats = self._vPlayerStats[ playerID ]
		if playerStats then
			playerStats.nCreepsKilled = playerStats.nCreepsKilled + 1
		end
	end
	if killedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		Timers:CreateTimer(7, 
		function()
			-- check if the unit is still alive (it might have been removed from the _vEnemiesRemaining table)			
			if not killedUnit:IsNull() and IsValidEntity(killedUnit) and killedUnit:IsAlive() then 
				print("killed unit is alive")
				killedUnit:SetAbsOrigin(Vector(0, 0, 0)) 
				FindClearSpaceForUnit(killedUnit, Vector(0, 0, 0), true)
				AddFOWViewer(DOTA_TEAM_GOODGUYS, killedUnit:GetAbsOrigin(), 1200, 180, false)	
			end
		end)
	end	
end

function AOHGameRound:GiveXPToAllHeroes(drop_xp)
	if not IsServer() then return end
	local heroes = GetAllRealHeroesCon()
	local alive_heroes = {}
	local dead_heroes = {}
	local dead_xp = 0
	--divine alive and dead heroes and save total xp for dead heroes.
	for i = 1, #heroes do
		if heroes[i]:IsAlive() then
			table.insert(alive_heroes, heroes[i])
		elseif not heroes[i]:IsAlive() then
			dead_xp = dead_xp + math.floor(drop_xp / (#heroes * 2))
			table.insert(dead_heroes, heroes[i])
		end
	end
	--subtract the dead_xp from toal = alive_xp, give the xp to all heroes
	local alive_xp = drop_xp - dead_xp
	if #alive_heroes > 0 then
		for i = 1, #alive_heroes do
			alive_heroes[i]:AddExperience(math.floor(alive_xp / #alive_heroes), false, false)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_XP, alive_heroes[i], math.floor(alive_xp / #alive_heroes), nil)
		end
	end	

	for i = 1, #dead_heroes do
		if not dead_heroes[i]:IsAlive() then
			dead_heroes[i]:AddExperience(math.floor(dead_xp / #dead_heroes), false, false)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_XP, dead_heroes[i], math.floor(dead_xp / #dead_heroes), nil)
		end
	end
end


function AOHGameRound:OnHoldoutReviveComplete(event)
	if not IsServer() then return end
	local castingHero = EntIndexToHScript(event.caster)
	if castingHero then
		local nPlayerID = castingHero:GetPlayerOwnerID()
		local playerStats = self._vPlayerStats[ nPlayerID ]
		if playerStats then
			playerStats.nPlayersResurrected = playerStats.nPlayersResurrected + 1
		end
	end
end


function AOHGameRound:OnItemPickedUp(event)
	if not IsServer() then return end
	if event.itemname == "item_bag_of_gold" then
		local playerStats = self._vPlayerStats[ event.PlayerID ]
		if playerStats then
			playerStats.nGoldBagsCollected = playerStats.nGoldBagsCollected + 1
		end
	end
end

function AOHGameRound:_CheckForGoldBagDrop(killedUnit)
	if not IsServer() then return end
	if self._nGoldRemainingInRound <= 0 then
		return
	end

	local nGoldToDrop = 0
	local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
	if nCoreUnitsRemaining <= 0 then
		nGoldToDrop = self._nGoldRemainingInRound
	else
		local flCurrentDropChance = self._nGoldBagsRemaining / (1 + nCoreUnitsRemaining)
		if RandomFloat(0, 1) <= flCurrentDropChance then
			if self._nGoldBagsRemaining <= 1 then
				nGoldToDrop = self._nGoldRemainingInRound
			else
				nGoldToDrop = math.floor(self._nGoldRemainingInRound / self._nGoldBagsRemaining)
				nCurrentGoldDrop = math.max(1, RandomInt(nGoldToDrop - self._nBagVariance, nGoldToDrop + self._nBagVariance ))
			end
		end
	end
	
	nGoldToDrop = math.min(nGoldToDrop, self._nGoldRemainingInRound)
	if nGoldToDrop <= 0 then
		return
	end
	self._nGoldRemainingInRound = math.max(0, self._nGoldRemainingInRound - nGoldToDrop)
	self._nGoldBagsRemaining = math.max(0, self._nGoldBagsRemaining - 1)	

	--check if there's only one player connected to the game, give gold directly to him if yes
	if self:RecountPlayers2() < 2 then
		-- Give the gold directly to the player
		if self.solo_player_id and PlayerResource:HasSelectedHero(self.solo_player_id) then
			if PlayerResource:GetPlayer(self.solo_player_id) then
				local player = PlayerResource:GetSelectedHeroEntity(self.solo_player_id)		
				player:ModifyGold(nGoldToDrop, false, 0)
				SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, player, nGoldToDrop, nil)
				EmitSoundOn("General.Coins", player)				
			end	
		end
	 --else check if the comand to disable goldbags is on, if yes give the gold(divided) directly to remaning players 	
	elseif _G._no_gold_bags == true then
		for playerID = 0, 4 do
			if PlayerResource:IsValidPlayerID(playerID) then
				if PlayerResource:HasSelectedHero(playerID) then
					if PlayerResource:GetPlayer(playerID) then
						local player = PlayerResource:GetSelectedHeroEntity(playerID)
						local gold_divided = math.floor(nGoldToDrop / self:RecountPlayers2())
						player:ModifyGold(gold_divided, false, 0)
						SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, player, nGoldToDrop, nil)
						EmitSoundOn("General.Coins", player)						
					end	
				end
			end
		end
	else
		if killedUnit then
			-- Drop the gold bag as usual
			local newItem = CreateItem("item_bag_of_gold", nil, nil)
			newItem:SetPurchaseTime(0)
			newItem:SetCurrentCharges(nGoldToDrop)
			local drop = CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), newItem)
			local dropTarget = killedUnit:GetAbsOrigin() + RandomVector(RandomFloat(50, 350))
			newItem:LaunchLoot(false, 300, 0.75, dropTarget, nil)
		end	
	end	
end

function AOHGameRound:RecountPlayers2()
	self._playerNumber_ = 0
	for playerID = 0, 4 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				if PlayerResource:GetPlayer(playerID) then
					local hero = PlayerResource:GetSelectedHeroEntity(playerID)
					self._playerNumber_ = self._playerNumber_ + 1
					self.solo_player_id = playerID
				end	
			end
		end
	end	
	return self._playerNumber_
end