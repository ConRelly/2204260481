
_G.NEUTRAL_TEAM = 4 -- global const for neutral team int
_G.HERO_MAX_LEVEL = 30

XP_PER_LEVEL_TABLE = {
	0,-- 1
	200,-- 2
	500,-- 3
	900,-- 4
	1400,-- 5
	2000,-- 6
	2600,-- 7
	3200,-- 8
	4400,-- 9
	5400,-- 10
	6000,-- 11
	8200,-- 12
	9000,-- 13
	10400,-- 14
	11900,-- 15
	13500,-- 16
	15200,-- 17
	17000,-- 18
	18900,-- 19
	20900,-- 20
	23000,-- 21
	25200,-- 22
	27500,-- 23
	29900,-- 24
	32400,-- 25
	36600,-- 26
	42100,-- 27
	48600,-- 28
	56100,-- 29
	60000,-- 30
}

STARTING_GOLD = 625
ROUND_EXPECTED_VALUES_TABLE = {
	{ gold = STARTING_GOLD, xp = 0 }, -- 1
	{ gold = 1054+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[4] }, -- 2
	{ gold = 2212+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[5] }, -- 3
	{ gold = 3456+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[6] }, -- 4
	{ gold = 4804+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[8] }, -- 5
	{ gold = 6256+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[9] }, -- 6
	{ gold = 7812+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[9] }, -- 7
	{ gold = 9471+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[10] }, -- 8
	{ gold = 11234+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[11] }, -- 9
	{ gold = 13100+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[13] }, -- 10
	{ gold = 15071+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[13] }, -- 11
	{ gold = 17145+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[14] }, -- 12
	{ gold = 19322+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[16] }, -- 13
	{ gold = 21604+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[18] }, -- 14
	{ gold = 23368+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[18] }, -- 15
	{ gold = 23368+STARTING_GOLD, xp = XP_PER_LEVEL_TABLE[18] }, -- 15
}


function AOHGameMode:InitCommand( )
    -- Custom console commands
	Convars:RegisterCommand( "holdout_test_round", function(...) return self:_TestRoundConsoleCommand( ... ) end, "Test a round of holdout.", FCVAR_CHEAT )
	Convars:RegisterCommand( "holdout_spawn_gold", function(...) return self._GoldDropConsoleCommand( ... ) end, "Spawn a gold bag.", FCVAR_CHEAT )
	Convars:RegisterCommand( "holdout_status_report", function(...) return self:_StatusReportConsoleCommand( ... ) end, "Report the status of the current holdout game.", FCVAR_CHEAT )
	Convars:RegisterCommand( "holdout_kill_all_enemies", function(...) return self:_KillAllEnemiesConsoleCommand( ... ) end, "Kill all currently spawned enemies on the map.", FCVAR_CHEAT )
	
	CustomGameEventManager:RegisterListener( "cheat_to_round", function(...) return self:_ProcessCheatToRound( ... ) end )
end


-- Custom game specific console command "holdout_test_round"
function AOHGameMode:_TestRoundConsoleCommand( cmdName, roundNumber, delay )
	local nRoundToTest = tonumber( roundNumber )
	if nRoundToTest == nil then
		print( "_TestRoundConsoleCommand - No valid round number provided!" )
		return
	end

	print( string.format( "Testing round %d", nRoundToTest ) )
	if nRoundToTest <= 0 or nRoundToTest > #self._vRounds then
		Msg( string.format( "Cannot test invalid round %d", nRoundToTest ) )
		return
	end

	
	if self._currentRound ~= nil then
		self:_RoundFinished()
		--self._currentRound:End()
		self._currentRound = nil
	end

	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if PlayerResource:IsValidPlayer( nPlayerID ) then
			local nGold = self:GetTestRoundGoldToAward( nPlayerID, nRoundToTest )
			local nXP = self:GetTestRoundXPToAward( nPlayerID, nRoundToTest )
			local hHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
			-- PlayerResource:ReplaceHeroWith( nPlayerID, PlayerResource:GetSelectedHeroName( nPlayerID ), nGold, nXP )
			-- if Hero ~= nil and Hero:IsNull() == false then
			-- 	UTIL_Remove( Hero )
			-- end
			PlayerResource:SetBuybackCooldownTime( nPlayerID, 0 )
			PlayerResource:SetBuybackGoldLimitTime( nPlayerID, 0 )
			PlayerResource:ResetBuybackCostTime( nPlayerID )
			self:SetCorrectAbilityPointsCount( nPlayerID )
		end
	end

	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem then
			UTIL_RemoveImmediate( containedItem )
		end
		UTIL_RemoveImmediate( item )
	end

	self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	self._nRoundNumber = nRoundToTest
	if delay ~= nil then
		delay = min(1, tonumber(delay) )
		self._flPrepTimeEnd = GameRules:GetGameTime() + delay
	end
end

function AOHGameMode:_GoldDropConsoleCommand( cmdName, goldToDrop )
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	newItem:SetPurchaseTime( 0 )
	if goldToDrop == nil then goldToDrop = 100 end
	newItem:SetCurrentCharges( goldToDrop )
	local spawnPoint = Vector( 0, 0, 0 )
	local heroEnt = PlayerResource:GetSelectedHeroEntity( 0 )
	if heroEnt ~= nil then
		spawnPoint = heroEnt:GetAbsOrigin()
	end
	local drop = CreateItemOnPositionSync( spawnPoint, newItem )
	--newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
end


function AOHGameMode:_ProcessCheatToRound( eventSourceIndex, args )
	if not SteamInfo:IsPublicUniverse() then
		local nRoundNumber = args[ "round_number" ]
		self:_TestRoundConsoleCommand( nil, nRoundNumber, nil )
	end
end

function AOHGameMode:_StatusReportConsoleCommand( cmdName )
	print( "*** Holdout Status Report ***" )
	print( string.format( "Current Round: %d", self._nRoundNumber ) )
	if self._currentRound then
		self._currentRound:StatusReport()
	end
	print( "*** Holdout Status Report End *** ")
end

function AOHGameMode:_RestartGame()
	-- Clean up the last round
	self._currentRound:End( false )
	self:_RespawnBuildings()
	GameRules:ResetDefeated()
	
	-- Clean up everything on the ground; gold, tombstones, items, everything.
	while GameRules:NumDroppedItems() > 0 do
		local item = GameRules:GetDroppedItem(0)
		UTIL_RemoveImmediate( item )
	end

	
	for playerID=0,4 do
		PlayerResource:SetGold( playerID, STARTING_GOLD, false )
		PlayerResource:SetGold( playerID, 0, true )
		PlayerResource:SetBuybackCooldownTime( playerID, 0 )
		PlayerResource:SetBuybackGoldLimitTime( playerID, 0 )
		PlayerResource:ResetBuybackCostTime( playerID )
	end

	-- Reset values
	self:InitGameMode()

	GameRules:ResetToHeroSelection()
	FireGameEvent( "dota_reset_suggested_items", {} )

	-- Reset voting
	self._votes = {}
	self._flEndTime = nil
end

function AOHGameMode:_RoundFinished()
	-- self:_AwardPoints()
	self._currentRound:End( true )

	self._currentRound = nil

	-- Heal all players
	self:_RefreshPlayers()

	-- Heal ancient
	self._entAncient:SetHealth( self._entAncient:GetMaxHealth() )
	--self._entAncient:SetInvulnCount( self.nAncientInvulnerabilityCount )

	-- Respawn all buildings
	self:_RespawnBuildings()


	self._nRoundNumber = self._nRoundNumber + 1
	if self._nRoundNumber > #self._vRounds then
		-- if self._nGameEndState == NOT_ENDED then
		-- 	self:_Victory()
		-- end
	else
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	end
end

function AOHGameMode:_RefreshPlayers()
	for nPlayerID = 0, 5 -1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if not hero:IsAlive() then
					local vLocation = hero:GetOrigin()
					hero:RespawnHero( false, false )
					FindClearSpaceForUnit( hero, vLocation, true )
				end
				hero:SetHealth( hero:GetMaxHealth() )
				hero:SetMana( hero:GetMaxMana() )
			end
		end
	end
end

function AOHGameMode:_RespawnBuildings()
	-- Respawn all the towers.
	print("Respawn all the towers.")
	self:_PhaseAllUnits( true )
	local buildings = FindUnitsInRadius( DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false )
	for _,building in ipairs( buildings ) do
		if building:IsTower() then
			local sModelName = "models/props_structures/tower_good.vmdl"
			sModelName = building.sModelName or sModelName
			building:SetOriginalModel( sModelName )
			building:SetModel( sModelName )
			local vOrigin = building:GetOrigin()
			if building:IsAlive() then
				building:Heal( building:GetMaxHealth(), building )
			else
				building:RespawnUnit()
				building:SetPhysicalArmorBaseValue( TOWER_ARMOR ) -- using this hack because RespawnUnit wipes our armor and I don't want to fix RespawnUnit right now
			end
			building:SetOrigin( vOrigin )

			if not building:HasAbility( "tower_fortification" ) then building:AddAbility( "tower_fortification" ) end
			local fortificationAbility = building:FindAbilityByName( "tower_fortification" )
			if fortificationAbility then
				fortificationAbility:SetLevel( self._nRoundNumber / 2 )
			end

			building:RemoveModifierByName( "modifier_invulnerable" )
		end

		if building:IsShrine() then
			local sModelName = "models/props_structures/radiant_statue001.vmdl"
			building:SetOriginalModel( sModelName )
			building:SetModel( sModelName )

			local hHealAbility = building:FindAbilityByName( "filler_ability" )
		
			local vOrigin = building:GetOrigin()
			if building:IsAlive() then
				building:Heal( building:GetMaxHealth(), building )
			else
				building:RespawnUnit()
				building:SetPhysicalArmorBaseValue( SHRINE_ARMOR ) -- using this hack because RespawnUnit wipes our armor and I don't want to fix RespawnUnit right now
				if hHealAbility ~= nil then
					hHealAbility:StartCooldown( hHealAbility:GetCooldown( hHealAbility:GetLevel() ) )
				end
			end
			building:SetOrigin( vOrigin )

			building:RemoveModifierByName( "modifier_invulnerable" )
		end
	end
	self:_PhaseAllUnits( false )
end

function AOHGameMode:_PhaseAllUnits( bPhase )
	local units = FindUnitsInRadius( DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY + DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER, 0, FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		if bPhase then
			unit:AddNewModifier( units[i], nil, "modifier_phased", {} )
		else
			unit:RemoveModifierByName( "modifier_phased" )
		end
	end
end

function AOHGameMode:_ProcessCheatToRound( eventSourceIndex, args )
	if not SteamInfo:IsPublicUniverse() then
		local nRoundNumber = args[ "round_number" ]
		self:_TestRoundConsoleCommand( nil, nRoundNumber, nil )
	end
end

-- Custom game specific console command "holdout_kill_all_enemies"
function AOHGameMode:_KillAllEnemiesConsoleCommand( cmdName )
	if IsServer() then
		for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
			if not unit:IsTower() then
				--UTIL_RemoveImmediate( unit )
				unit:Kill(nil,nil)
				--unit:Destroy()
			end
		end
	end
end

function AOHGameMode:_AwardPoints()
	if self._playerPointsData == nil then
		self._playerPointsData = {}
	end
	
	local nCount = PlayerResource:GetPlayerCountForTeam( DOTA_TEAM_GOODGUYS )

	for i=0,nCount do
		local nPlayerID = PlayerResource:GetNthPlayerIDOnTeam( DOTA_TEAM_GOODGUYS, i )
		if nPlayerID ~= -1 then

			local szSteamID = tostring( PlayerResource:GetSteamAccountID( nPlayerID ) )
			local bDailyBonusActive = self._hEventGameDetails and self._hEventGameDetails[szSteamID] ~= nil and self._hEventGameDetails[szSteamID] < 1 

			if not self._playerPointsData["Player"..nPlayerID] then 
				self._playerPointsData["Player"..nPlayerID] = {} 
				self._playerPointsData["Player"..nPlayerID]["total_event_points"] = 0
			end

			local nCurrentPoints = self._playerPointsData["Player"..nPlayerID]["total_event_points"]

			if bDailyBonusActive and self._nRoundNumber == 5 then
				self._playerPointsData["Player"..nPlayerID]["total_event_points"] = nCurrentPoints*self._periodic_points_scale_normal_event_points
			end

			self._playerPointsData["Player"..nPlayerID]["daily_bonus_active"] = bDailyBonusActive
			self._playerPointsData["Player"..nPlayerID]["total_event_points"] = self._playerPointsData["Player"..nPlayerID]["total_event_points"] + self._currentRound:GetPointReward( nPlayerID )
			printf( "Awarded Player%d %d points", nPlayerID,  self._playerPointsData["Player"..nPlayerID]["total_event_points"] )
		end
	end
	--self._nAccumulatedPoints = self._nAccumulatedPoints + nPointAmount
	
end

function AOHGameMode:GetTestRoundGoldToAward( nPlayerID, nRoundToTest )
	if IsServer() then
		--local nExpectedGold = ROUND_EXPECTED_VALUES_TABLE[ math.min(nRoundToTest,#ROUND_EXPECTED_VALUES_TABLE) ].gold or STARTING_GOLD
		local nExpectedGold = 30000
		local hHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
		local nGold = nExpectedGold - self:GetHeroNetWorth( hHero )

		--print( string.format( "  nExpectedGold == %d", nExpectedGold ) )
		--print( string.format( "  player's hero's net worth: %d", self:GetHeroNetWorth( hHero ) ) )
		--print( string.format( "  nGold == %d", nGold ) )

		if nGold < 0 then
			nGold = 0
		end

		--print( string.format( "Awarding %d gold to player id %d", nGold, nPlayerID ) )

		return nGold
	end
end

function AOHGameMode:GetTestRoundXPToAward( nPlayerID, nRoundToTest )
	if IsServer() then
		--local nExpectedXP = ROUND_EXPECTED_VALUES_TABLE[ math.min(nRoundToTest,#ROUND_EXPECTED_VALUES_TABLE) ].xp or 0
		local nExpectedXP = 2000 * tonumber(nRoundToTest)
		local nXP = nExpectedXP

		--print( string.format( "  nExpectedXP == %d", nExpectedXP ) )
		--print( string.format( "  nXP == %d", nXP ) )

		if nXP < 0 then
			nXP = 0
		end

		--print( string.format( "Awarding %d xp to player id %d", nXP, nPlayerID ) )

		return nXP
	end
end

function AOHGameMode:SetCorrectAbilityPointsCount( nPlayerID )
	if IsServer() then
		local hPlayerHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
		if hPlayerHero == nil or hPlayerHero:IsNull() then
			print( "WARNING - GetHeroNetWorth: hPlayerHero doesn't exist" )
			return
		end

		if hPlayerHero:IsRealHero() == false then
			print( string.format( "WARNING - GetHeroNetWorth: hPlayerHero (\"%s\") is not a real hero", hPlayerHero:GetUnitName() ) )
			return
		end

		local nSpentPoints = 0

		for i = 0, DOTA_MAX_ABILITIES - 1 do
			local hAbility = hPlayerHero:GetAbilityByIndex( i )
			if hAbility and not hAbility:IsHidden() and hAbility:CanAbilityBeUpgraded() ~= ABILITY_NOT_LEARNABLE and self:IsValidAbility( hAbility ) then
				--print( string.format( "%s - increasing nSpentPoints by %d points", hAbility:GetAbilityName(), hAbility:GetLevel() ) )
				nSpentPoints = nSpentPoints + hAbility:GetLevel()
			end
		end

		local nPointsDelta = hPlayerHero:GetLevel() - nSpentPoints 
		if nPointsDelta == 0 then
			--print( "  already have correct points" )
			hPlayerHero:SetAbilityPoints( 0 )
			return
		elseif nPointsDelta < 0 then
			--print( "  we have too many points, reset all abilities to level 0 and re-award points" )
			for i = 0, DOTA_MAX_ABILITIES - 1 do
				local hAbility = hPlayerHero:GetAbilityByIndex( i )
				if hAbility and hAbility:CanAbilityBeUpgraded() ~= ABILITY_NOT_LEARNABLE and self:IsValidAbility( hAbility ) then
					hAbility:SetLevel( 0 )
				end
			end
			--print( "    set ability points to: " .. hPlayerHero:GetLevel() )
			hPlayerHero:SetAbilityPoints( hPlayerHero:GetLevel() )
		elseif nPointsDelta > 0 then
			--print( "  we are missing points, award nPointsDelta" )
			hPlayerHero:SetAbilityPoints( nPointsDelta )
		end
	end
end

function AOHGameMode:IsValidAbility( hAbility )
	if IsServer() then
		local szName = hAbility:GetAbilityName()
		if szName then
			if szName == "throw_snowball" or szName == "throw_coal" or szName == "shoot_firework" or szName == "healing_campfire" or szName == "invoker_invoke" then
				return false
			end
		end

		return true
	end
end

function AOHGameMode:GetHeroNetWorth( hHero )
	if IsServer() then
		if hHero == nil or hHero:IsNull() then
			print( "WARNING - GetHeroNetWorth: hHero doesn't exist" )
			return 0
		end

		local nNetWorthTotal = 0

		for slot = 0, DOTA_ITEM_SLOT_9 do
			local hItem = hHero:GetItemInSlot( slot )
			if hItem ~= nil and hItem:GetAbilityName() ~= "item_tpscroll" then
				nNetWorthTotal = nNetWorthTotal + hItem:GetCost()
			end
		end

		return nNetWorthTotal
	end
end