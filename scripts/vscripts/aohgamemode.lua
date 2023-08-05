--[[
From
Holdout Example

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability

	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]
require("AOHGameRound")
require("AOHSpawner")
require("hack/precache_resource")
require("lib/atr_fix")
require("lib/underdog")
require("lib/my")
require("lib/timers")
require("lib/ai")
require("lib/chat_handler")
require("items/arcane_staff")
require("items/item_demon_talon")
require("lib/parsers")
require("lib/end_screen")
require("lib/data")
require("lib/notifications")
require("lib/hero_damage")
require("teststuf")
--require('statcollection/init')

require("monster_style")

require("lib/funcs")
require("lib/sounds")
require("holdout_card_points")
require("libraries/playertables")
require("hack/dev_util")


require("cdota/cdota")


require("hack/hack_game_mode")


LinkLuaModifier("modifier_playerhelp_revive", "modifiers/modifier_playerhelp_revive.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss", "modifiers/modifier_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hard_mode_boss", "modifiers/modifier_hard_mode_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_power_boss", "hack/modifiers/modifier_power_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phys", "modifiers/modifier_phys.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_bristleback_quill_spray_autocast6", "abilities/hero_bristleback/modifier_mjz_bristleback_quill_spray_autocast6.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_hpbar2", "abilities/boss_hpbar2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_double_trouble", "modifiers/modifier_double_trouble.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_infinite_health", "modifiers/modifier_infinite_health.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_truesight_aura", "bosses/boss_true_sight.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_truesight", "bosses/boss_true_sight.lua", LUA_MODIFIER_MOTION_NONE)


if AOHGameMode == nil then
	_G.AOHGameMode = class({})
	-- Make card points system a global for access by items
	_G.holdout_card_points = holdout_card_points
end
require('lib/cfinder')
require("hack/holdout_commands")
require("aoh_player_chat")
require("lib/mys")
require("lib/uless")



_G.mHackGameMode = HackGameMode()

local MONSTER_CONFIG_ORIGIN = "aoh2_config.txt"
local MONSTER_CONFIG_NEW_KING = "aoh2_config_siltbreaker_200809_hard.txt"
local MONSTER_CONFIG_SILTBREAKER = "aoh2_config_siltbreaker_200809.txt"
local MONSTER_CONFIG_GODS =  "aoh2_config_gods.txt" --   "test_short_rounds.txt" -- 
local MONSTER_CONFIG = MONSTER_CONFIG_GODS
print("MONSTER_CONFIG: " .. MONSTER_CONFIG)
--if IsInToolsMode() and false then
--	MONSTER_CONFIG = "aoh2_config_test.txt"
--	print("Load Test MONSTER_CONFIG: " .. MONSTER_CONFIG)
--end
if Cheats:IsEnabled() then 
	MONSTER_CONFIG = "aoh2_config_siltbreaker_200809.txt" --"test_short_rounds.txt" --  
	print("CHeat mode")
end	

Precache = require "Precache"



function AOHGameMode:InitGameMode()
	self._nRoundNumber = 1
	if 	_G.RoundNumber == nil then
		_G.RoundNumber = 1
	end
	self._currentRound = nil
	self._entAncient = Entities:FindByName(nil, "dota_goodguys_fort")
	if not self._entAncient then
		print( "Ancient entity not found!" )
	end
	self._hasVoted = {}
	AOHGameMode.numPhilo = {}
	AOHGameMode.numPhilo[0] = 0
	AOHGameMode.numPhilo[1] = 0
	AOHGameMode.numPhilo[2] = 0
	AOHGameMode.numPhilo[3] = 0
	AOHGameMode.numPhilo[4] = 0
	_G._hardMode = false
	_G._extra_mode = false
	_G.super_courier = {false, false, false, false, false}
	_G._challenge_bosss = 0
	_G._effect_rate = 100
	_G.reload_buff = true
	_G._stalker_chance = 1
	_G.symbiosisOn = true	
	_G._endlessMode_started = false
	_G._normal_mode = false
	_G._defeat_extra_lives = 3
	_G._no_gold_bags = true
	_G._itemauto1 = {}
	_G._itemauto2 = {}
	_G._playerNumber = 0
	_G._sell_slayer_fragmets = true
	_G._dev_enemy = false
	_G._dev_enemy_ano = false
	self._hardMode = false
	self._endlessMode = false
	self._endlessMode_started = false
	self._manaMode = false
	self._doubleMode = false
	self._extra_mode = false
	self._vic_1 = false
	self.starting_intems = false
	self.renew = false
	self.gon = true
	self.spawned_gon = false
	self.challenge = false
	self.frist_init = false
	GameRules.GLOBAL_roundNumber = 1
	AOHGameMode.isArcane = {}
	AOHGameMode.isArcane[0] = false
	AOHGameMode.isArcane[1] = false
	AOHGameMode.isArcane[2] = false
	AOHGameMode.isArcane[3] = false
	AOHGameMode.isArcane[4] = false
	AOHGameMode.isTalon = {}
	AOHGameMode.isTalon[0] = nil
	AOHGameMode.isTalon[1] = nil
	AOHGameMode.isTalon[2] = nil
	AOHGameMode.isTalon[3] = nil
	AOHGameMode.isTalon[4] = nil
	AOHGameMode.talonCount = {}
	AOHGameMode.talonCount[0] = {}
	AOHGameMode.talonCount[1] = {}
	AOHGameMode.talonCount[2] = {}
	AOHGameMode.talonCount[3] = {}
	AOHGameMode.talonCount[4] = {}
	self._damagecount = {}
	self._damagecount[0] = {}
	self._damagecount[1] = {}
	self._damagecount[2] = {}
	self._damagecount[3] = {}
	self._damagecount[4] = {}
	self._physdamage = {}
	self._physdamage[0] = 1
	self._physdamage[1] = 1
	self._physdamage[2] = 1
	self._physdamage[3] = 1
	self._physdamage[4] = 1
	self._physdanage = false
	self._magdamage = {}
	self._magdamage[0] = 1
	self._magdamage[1] = 1
	self._magdamage[2] = 1
	self._magdamage[3] = 1
	self._magdamage[4] = 1
	self._puredamage = {}
	self._puredamage[0] = 1
	self._puredamage[1] = 1
	self._puredamage[2] = 1
	self._puredamage[3] = 1
	self._puredamage[4] = 1
	self._dpstick = 0
	self._playerNumber = 0
	self._goldRatio = 1.2
	self._expRatio = 1.0
	self._ischeckingdefeat = false
	self._defeatcounter = 10
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	Convars:SetInt("dota_max_physical_items_purchase_limit", 99)
	Convars:SetInt("cl_init_scaleform", 1)		--Unfortunately, we have to keep doing this until Valve decides to implement Read/WriteKV in Panorama
    Convars:SetInt("dota_hud_healthbars", 1)
	MonsterStyle:InitGameMode()
	self:_ReadGameConfiguration()

	local xpTable = {}

	xpTable[0] = 0
	xpTable[1] = 230
	xpTable[2] = 600
	xpTable[3] = 1080
	xpTable[4] = 1660
	xpTable[5] = 2260
	xpTable[6] = 2980
	xpTable[7] = 3730
	xpTable[8] = 4510
	xpTable[9] = 5320
	xpTable[10] = 6160
	xpTable[11] = 7030
	xpTable[12] = 7930
	xpTable[13] = 9155
	xpTable[14] = 10405
	xpTable[15] = 11680
	xpTable[16] = 12980
	xpTable[17] = 14305
	xpTable[18] = 15805
	xpTable[19] = 17395
	xpTable[20] = 18995
	xpTable[21] = 20845
	xpTable[22] = 22945
	xpTable[23] = 25295
	xpTable[24] = 27895
	for i = 25, 1000 do
		xpTable[i] = xpTable[i-1]+(i-24)*1000+2500
	end

	GameRules.xpTable = xpTable

	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(xpTable)
	GameRules:SetCustomGameSetupAutoLaunchDelay(3.0)
	GameRules:SetTimeOfDay(0.75)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroSelectionTime(90.0)
	GameRules:SetPreGameTime(25.0)
	GameRules:SetStrategyTime(10.0)
	GameRules:SetPostGameTime(30.0)
	GameRules:SetTreeRegrowTime(10.0)
	GameRules:SetHeroMinimapIconScale(1.2)
	GameRules:SetCreepMinimapIconScale(1.2)
	GameRules:SetRuneMinimapIconScale(1.2)
	--GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(false)
	--GameRules:GetGameModeEntity():SetXPRuneSpawnInterval(99999)
	--GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_XP, false )
	--GameRules:GetGameModeEntity():SetAllowNeutralItemDrops( true )
	GameRules:GetGameModeEntity():SetCustomDireScore(0)
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible(false)
	GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled(true)
	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled(true)
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(999)
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(1100)
	GameRules:GetGameModeEntity():SetNeutralStashEnabled(true)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED,0.05)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP,2.5)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN,0.4)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0.01)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN,0.07)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 3)
	--GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESIST, 0)  -- not implemented by dota yet
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1400)
	GameRules:GetGameModeEntity():SetHUDVisible(26,false)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(AOHGameMode, 'OnEntitySpawned'), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(AOHGameMode, 'OnEntityKilled'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(AOHGameMode, "OnPlayerDeasth"), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(AOHGameMode, "OnGameRulesStateChange"), self)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(AOHGameMode, 'OnItemPickedUp'), self)
	ListenToGameEvent("dota_holdout_revive_complete", Dynamic_Wrap(AOHGameMode, 'OnHoldoutReviveComplete'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(AOHGameMode, "OnPlayerChat"), self)
	ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(AOHGameMode, "OnHeroLevelUp"), self)
    ListenToGameEvent("tree_cut", Dynamic_Wrap(AOHGameMode, "OnTreeCut"), self)
	-- 玩家连接
	ListenToGameEvent('player_connect', Dynamic_Wrap(AOHGameMode, 'OnPlayerConnect'), self)
	-- 玩家重新连接
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(AOHGameMode, 'OnPlayerReconnect'), self)
	ListenToGameEvent("player_disconnected", Dynamic_Wrap(AOHGameMode, 'OnPlayerDisconnect'), self)

	GameRules:GetGameModeEntity():SetThink("OnThink", self, 1.0)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(AOHGameMode, 'OnDamageDealt'), self)
	gHeroDamage:InitGameMode()

	self:InitCommand()
	mHackGameMode:InitGameMode()
	-- Init card points system
	holdout_card_points:Init()






	if Cheats:IsEnabled() then
		ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(AOHGameMode, "OnItemPurchased"), self)

		SendToServerConsole("sv_cheats 1")
		SendToServerConsole("dota_hero_god_mode 0")

		_G.Demo_UI = false

		self.m_tEnemiesList = {}
		if self.m_bFreeSpellsEnabled == true then
			SendToServerConsole("dota_ability_debug 0")
		end
		self.m_bFreeSpellsEnabled = false
		self.m_bInvulnerabilityEnabled = false
		self.m_bMaxGold = false
		self.m_nHeroRenderMode = 0

		CustomGameEventManager:RegisterListener("RefreshButtonPressed", function(...) return self:OnRefreshButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("LevelUpButtonPressed", function(...) return self:OnLevelUpButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("MaxLevelButtonPressed", function(...) return self:OnMaxLevelButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("SuicideButtonPressed", function(...) return self:OnSuicideButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("FreeSpellsButtonPressed", function(...) return self:OnFreeSpellsButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("InvulnerabilityButtonPressed", function(...) return self:OnInvulnerabilityButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("MaxGoldButtonPressed", function(...) return self:OnMaxGoldButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("SpawnEnemyButtonPressed", function(...) return self:OnSpawnEnemyButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("RemoveSpawnedUnitsButtonPressed", function(...) return self:OnRemoveSpawnedUnitsButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("DayNightTogglePressed", function(...) return self:OnDayNightToggleButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("HeroRenderModePressed", function(...) return self:OnHeroRenderModeButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("PauseButtonPressed", function(...) return self:OnPauseButtonPressed(...) end)
		CustomGameEventManager:RegisterListener("LeaveButtonPressed", function(...) return self:OnLeaveButtonPressed(...) end)
	end
end


function AOHGameMode:AtRoundStart()
	local cost = 300 + 5 * self._nRoundNumber
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if hero then
				PlayerResource:SetCustomBuybackCost(playerID, cost)
			end
		end
	end
	
end

function AOHGameMode.SetArcane(PlayerID, bool)
	AOHGameMode.isArcane[PlayerID] = bool
end

function AOHGameMode.AllowedPhilo(PlayerID)
	if AOHGameMode.numPhilo[PlayerID] < 1 then
		return true
	end
	return false
end

function AOHGameMode.SetTalon(PlayerID, physStack, magStack)
	AOHGameMode.talonCount[PlayerID][0] = AOHGameMode.talonCount[PlayerID][0] + physStack
	AOHGameMode.talonCount[PlayerID][1] = AOHGameMode.talonCount[PlayerID][1] + magStack
	if AOHGameMode.talonCount[PlayerID][1] == 0 and AOHGameMode.talonCount[PlayerID][0] == 0 then
		AOHGameMode.isTalon[PlayerID] = nil
		local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
		hero:RemoveAbility("demon_talon_hidden")
	else 
		local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
		if hero:HasAbility("demon_talon_hidden") then
			AOHGameMode.isTalon[PlayerID] = hero:FindAbilityByName("demon_talon_hidden")
		else 
			AOHGameMode.isTalon[PlayerID] = PlayerResource:GetSelectedHeroEntity(PlayerID):AddAbility("demon_talon_hidden")
			AOHGameMode.isTalon[PlayerID]:SetLevel(1)
		end
	end
end

function AOHGameMode.AllowedPhilo(PlayerID)
	if AOHGameMode.numPhilo[PlayerID] < 1 then
		return true
	end
	return false
end

function AOHGameMode.IncrementPhilo(PlayerID)
	AOHGameMode.numPhilo[PlayerID] = AOHGameMode.numPhilo[PlayerID] + 1
end

--GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(AOHGameMode, 'OnDamageDealt'), self)
function AOHGameMode:OnDamageDealt(damageTable)
	local attacker_index = damageTable.entindex_attacker_const
	local victim_index = damageTable.entindex_victim_const
	if attacker_index and victim_index then
		local attacker = EntIndexToHScript(attacker_index)
		local victim = EntIndexToHScript(victim_index)
		if attacker and victim then
			if attacker.GetPlayerOwnerID then
				local attackerPlayerId = attacker:GetPlayerOwnerID()
				local victim_name = victim:GetUnitName()
				if damageTable.damage > 1 then -- pointless to update tables and lag for 0 or 1
					if damageTable.damagetype_const ~= 1 then
						if AOHGameMode.isArcane[attackerPlayerId] then
							arcane_staff_calculate_crit(attacker, victim, damageTable)
						end
					end
					local dmg_dealt = damageTable.damage -- arcane staff might update this value so i added after isArcane
					if victim:HasModifier("modifier_jotaro_absolute_defense") then
						if victim:GetMaxHealth() * 0.07 <= dmg_dealt then
							local part = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CENTER_FOLLOW, victim)
							ParticleManager:DestroyParticle(part, false)
							ParticleManager:ReleaseParticleIndex(part)
							local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
							ParticleManager:ReleaseParticleIndex(iParticleID)							
							SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCKED, victim, 0, nil)
							return false							
						end	
					end	
					if victim and victim:GetDayTimeVisionRange() ~= 1337 then --npc conduit(1337)
						if attackerPlayerId and attackerPlayerId >= 0 and attacker:IsOpposingTeam(victim:GetTeam()) then
							local victim_hp = victim:GetHealth() --get victim curent healt so we make sure we don't record overkill dps
							if dmg_dealt > victim_hp and victim_name ~= "npc_dota_dummy_misha" then --exception
								dmg_dealt = victim_hp
							end	
							player_data_modify_value(attackerPlayerId, "bossDamage", dmg_dealt)
							gHeroDamage:ModifyValue(attackerPlayerId, "bossDamage", dmg_dealt)
							gHeroDamage:OnDamageDealt(attackerPlayerId, damageTable, dmg_dealt, attacker, victim )
							if damageTable.damagetype_const == 2 then
								self._magdamage[attackerPlayerId] = self._magdamage[attackerPlayerId] + dmg_dealt
							elseif damageTable.damagetype_const == 1 then
								self._physdamage[attackerPlayerId] = self._physdamage[attackerPlayerId] + dmg_dealt
							else
								self._puredamage[attackerPlayerId] = self._puredamage[attackerPlayerId] + dmg_dealt
							end
						end
					end
					if attacker:IsCreature() and victim:IsRealHero() and victim.GetPlayerOwnerID then
						local victimPlayerId = victim:GetPlayerOwnerID()
						if victimPlayerId and victimPlayerId >= 0 then
							player_data_modify_value(victimPlayerId, "damageTaken", dmg_dealt)
							gHeroDamage:ModifyValue(victimPlayerId, "damageTaken", dmg_dealt)
						end
					end
				end	
			end
		end
	end
	return true
end


function AOHGameMode:OnItemPickedUp(keys)
	if keys.itemname == "item_bag_of_gold" then
		player_data_modify_value(keys.PlayerID, "goldBagsCollected", 1)
		gHeroDamage:ModifyValue(keys.PlayerID, "goldBagsCollected", 1)		
	end
end

function AOHGameMode:OnHoldoutReviveComplete(keys)
	local castingHero = EntIndexToHScript(keys.caster)
	if castingHero then
		local playerID = castingHero:GetPlayerOwnerID()
		player_data_modify_value(playerID, "saves", 1)
		gHeroDamage:ModifyValue(playerID, "saves", 1)
	end
end


-- Read and assign configurable keyvalues if applicable
function AOHGameMode:_ReadGameConfiguration()
	--local kv = LoadKeyValues("scripts/config/aoh2_config.txt") or {}
	local kv = LoadKeyValues("scripts/config/" .. MONSTER_CONFIG) or {}


	self._flPrepTimeBetweenRounds = tonumber(kv.PrepTimeBetweenRounds or 0)
	self._flItemExpireTime = tonumber(kv.ItemExpireTime or 10.0)
	self._vRandomSpawnsList = spawns_from_kv(kv["RandomSpawns"])
	if self._hardMode and not self._endlessHard_started and not self._endlessMode_started then 
		self._vLootItemDropsList = items_from_kv(kv["ItemDrops2"])
		self._vRounds = rounds_from_kv(kv["Rounds2"], self)
	elseif self._endlessMode_started and not self._endlessHard_started then
		self._vRounds = rounds_from_kv(kv["Rounds3"], self)		
	elseif self._endlessHard_started then
		self._vRounds = rounds_from_kv(kv["Rounds4"], self) 		 
	else 
		self._vLootItemDropsList = items_from_kv(kv["ItemDrops"])
		self._vRounds = rounds_from_kv(kv["Rounds"], self)
	end	
	
	
end

-- Verify spawners if random is set
function AOHGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error("Attempt to choose a random spawn, but no random spawns are specified in the data.")
		return nil
	end
	return self._vRandomSpawnsList[RandomInt(1, #self._vRandomSpawnsList)]
end

function AOHGameMode:RecountPlayers()
	self._playerNumber = 0
	for playerID = 0, 4 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				if PlayerResource:GetPlayer(playerID) then
					local hero = PlayerResource:GetSelectedHeroEntity(playerID)
					self._playerNumber = self._playerNumber + 1
					_G._playerNumber = self._playerNumber
				end	
			end
		end
	end
	Timers:CreateTimer({
		endTime = 0.5, 
		callback = function()
			if self.frist_init then
				self:InitVariables()
			end	
			if self._playerNumber == 0 then
				send_info_if_game_ends_2()
			end	
			--print(self._playerNumber .. " connected players")
		end
	})		
end

function AOHGameMode:_RenewStats()
	for playerID = 0, 4 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				if PlayerResource:GetPlayer(playerID) then
					local hero = PlayerResource:GetSelectedHeroEntity(playerID)
					DropItemOrInventory(playerID, "item_edible_fragment")
					DropItemOrInventory(playerID, "item_enchanter")
					--hero:AddItemByName("item_edible_fragment")
					--hero:AddItemByName("item_enchanter")
					if RollPercentage(20) or (self._playerNumber < 2) then
						DropItemOrInventory(playerID, "item_imba_ultimate_scepter_synth2")
						--hero:AddItemByName("item_imba_ultimate_scepter_synth2")
					end	
					if self._playerNumber < 2 then
						DropItemOrInventory(playerID, "item_red_divine_rapier_lv4")
						--hero:AddItemByName("item_red_divine_rapier_lv4")
					end	
				end	
			end
		end
	end		
end
-- Initiates variables that need to be set to values

function AOHGameMode:InitVariables()
	if not self.starting_intems then 
		for playerID = 0, 4 do
			for var = 0, 9 do
				self._damagecount[playerID][var] = 0
			end
			if PlayerResource:IsValidPlayerID(playerID) then
				if PlayerResource:HasSelectedHero(playerID) then
					local hero = PlayerResource:GetSelectedHeroEntity(playerID)
					hero:AddItemByName("item_black_king_bar_free")
					hero:AddItemByName("item_random_get_ability")
					hero:AddItemByName("item_aegis_lua")
					hero:AddItemByName("item_aegis_lua")
					hero:AddItemByName("item_aegis_lua")
					hero:AddItemByName("item_philosophers_stone")
--[[ 					DropItemOrInventory(playerID, "item_black_king_bar_free")
					DropItemOrInventory(playerID, "item_random_get_ability")
					DropItemOrInventory(playerID, "item_aegis_lua")
					DropItemOrInventory(playerID, "item_aegis_lua")
					DropItemOrInventory(playerID, "item_aegis_lua")
					DropItemOrInventory(playerID, "item_philosophers_stone") ]]
					
					if self._extra_mode then	
						hero:AddItemByName("item_aegis_lua")
						--DropItemOrInventory(playerID, "item_aegis_lua")
						--hero:AddItemByName("item_philosophers_stone2")
					end
					if not _G._hardMode then 
						hero:ModifyGold(5000, true, 0)
					else
						hero:ModifyGold(4000, true, 0)	
					end	
					if Cheats:IsEnabled() then
						--DropItemOrInventory(playerID, "item_obs_studio")
						hero:AddItemByName("item_obs_studio")
					end	
					--hero:AddItemByName("item_ward_sentry")
					CustomGameEventManager:Send_ServerToAllClients("game_begin", {name = PlayerResource:GetSelectedHeroName(playerID), id = playerID})
					self._playerNumber = self._playerNumber + 1
					PlayerResource:SetCustomBuybackCooldown(playerID, 180)
					--Sounds:CreateSound(playerID, "goh.teme")
				end
			end
		end
		Timers:CreateTimer({
			endTime = 0.1,
			callback = function()
				self.starting_intems = true
				print(self._playerNumber .. " starting players")
			end
		})
		Timers:CreateTimer({
			endTime = 25,
			callback = function()
				if not _G._normal_mode then
					Notifications:TopToAll({text="Easy mode: Ancient Has base 5k Armor(only on part 1). type'-normal' before game starts to disable this(or play -hard)", style={color="green"}, duration=12})
				end	
			end
		})			
	end	
	if not self.starting_intems then 
		for playerID = 0, 4 do
			for var = 0, 2 do
				self.talonCount[playerID][var] = 0
			end
		end
	end	
	self._goldRatio = 3.0 - (0.3 * (5 - self._playerNumber))
	print("updating ratios")
	self._expRatio = 2.0 - (0.3 * (5 - self._playerNumber))
	if self._playerNumber < 2 then
		self._goldRatio = 0.9
		self._expRatio = 0.5
	end	
	if self._playerNumber < 2 and not self.starting_intems then
		self._goldRatio = 0.9
		self._expRatio = 0.5
		local playerHero = PlayerResource:GetPlayer(0):GetAssignedHero()

		Notifications:TopToAll({text="#game_begin_benediction", duration=5})
		if self.gon and not self.spawned_gon then
			self._nPlayerHelp = CreateUnitByName("npc_playerhelp", playerHero:GetAbsOrigin(), true, playerHero, playerHero:GetOwner(), playerHero:GetTeamNumber())
			self._nPlayerHelp:SetControllableByPlayer(playerHero:GetPlayerID(), true)
			self._nPlayerHelp:SetTeam(playerHero:GetTeamNumber())
			self._nPlayerHelp:SetOwner(playerHero)
			self.spawned_gon = true		
		end
	end
	if self._doubleMode then
		self._expRatio = self._expRatio / 1.35
	end
	--GameRules.GLOBAL_player_number = self._playerNumber	
	CustomGameEventManager:Send_ServerToAllClients("frostivus_begins", {})
end



-- When game state changes set state in script
function AOHGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(playerID) then
				if not PlayerResource:HasSelectedHero(playerID) then
					if PlayerResource:GetPlayer(playerID) then
						PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()
					end		
				end
			end
		end
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		self:_RevealShop()
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:GetGameModeEntity():SetThink("OnUpdateThink", self, 9)
		-- GameRules:GetGameModeEntity():SetThink("OnUpdateThink", gHeroDamage, 2)
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
		self.frist_init = true
		self:InitVariables() 
	elseif nNewState == DOTA_GAMERULES_STATE_POST_GAME then
		send_info_if_game_ends()
		GameRules:SetSafeToLeave(true)
		end_screen_setup(self._entAncient and self._entAncient:IsAlive())
	elseif nNewState == DOTA_GAMERULES_STATE_DISCONNECT then
		GameRules:SetSafeToLeave(true)
	end

end
-- Updates the damage meter UI for players
function AOHGameMode:OnUpdateThink()
	--if self.dpsinfo then
	gHeroDamage:OnUpdateThink()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(playerID) then
			local heroName = PlayerResource:GetSelectedHeroName(playerID)
			-- local bossDamage = player_data_get_value(playerID, "bossDamage")
			local bossDamage = gHeroDamage:GetValue(playerID, "bossDamage")
			local damageTaken = gHeroDamage:GetValue(playerID, "damageTaken")
			CustomGameEventManager:Send_ServerToAllClients("dps_update", {damage = formated_number((bossDamage - self._damagecount[playerID][self._dpstick]) / 16), id = playerID, name = heroName})
			CustomGameEventManager:Send_ServerToAllClients("heal_update", {damage = formated_number(PlayerResource:GetHealing(playerID)), id = playerID, name = heroName})
			CustomGameEventManager:Send_ServerToAllClients("damage_type_update", {physical = self._physdamage[playerID],magical = self._magdamage[playerID],pure = self._puredamage[playerID], id = playerID, name = heroName})
			CustomGameEventManager:Send_ServerToAllClients("damage_update", {damage = formated_number(bossDamage), id = playerID})
			CustomGameEventManager:Send_ServerToAllClients("damage_taken_update", {damage = formated_number(damageTaken), id = playerID, name = heroName})
			self._damagecount[playerID][self._dpstick] = bossDamage
		end
	end
	self._dpstick = self._dpstick + 1
	if self._dpstick > 3 then
		self._dpstick = 0
	end
	return 4.00
	--end	
end

local chests = {[0] = "item_resurection_pendant", "item_aegis_lua", "item_plain_perma", "item_mjz_aether_lens", "item_random_get_ability_onlvl", }

-- Distributes chests based on round number
function AOHGameMode:DistributeChests()
	local temp = self._nRoundNumber / 6
	if temp > 0 and temp < 6 then
		local chestName = chests[temp - 1]
		-- Notifications:TopToAll({text="Trade your chest in for a tier " .. temp .. " neutral item", duration=5})
		Notifications:TopToAll({text="#notifications_trade_chest_" .. temp, duration=5})
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:IsValidPlayer(playerID) then
				if PlayerResource:HasSelectedHero(playerID) then
					local hero = PlayerResource:GetSelectedHeroEntity(playerID)
					if hero then
						--DropItemOrInventory(playerID, chestName)
						hero:AddItemByName(chestName)
					end
				end
			end	
		end
	end
end

-- Evaluate the state of the game
function AOHGameMode:OnThink()
	if mHackGameMode then mHackGameMode:OnThink() end
	
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:_CheckForDefeat()
		removed_expired_items(self._flItemExpireTime)
		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()
		elseif self._currentRound ~= nil then
			self._currentRound:Think()
			if self._currentRound:IsFinished() then
				self._currentRound:End(self._nRoundNumber)
				self._currentRound = nil
				if not self._hardMode and not self._endlessMode then
					refresh_players()
				end
				if not self._endlessMode_started then 
					if self._nRoundNumber % 6 == 0 then
						self:DistributeChests()
					end
				end
				self._nRoundNumber = self._nRoundNumber + 1
				_G.RoundNumber = _G.RoundNumber + 1
				if self._nRoundNumber <= #self._vRounds then
					self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
				end
			end
		end
		self:_CheckWin()
		self:TrackDisconnectedPlayers()
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 1
end




local ABANDONED_THRESHOLD = 420 -- 7 minutes in seconds
local disconnected_players = {}
local dropped_heroes = {}
-- List of items that should not be dropped
local item_exceptions = {
	["item_branch_component"] = true,
	["item_broken_wings"] = true,
	["item_psychic_headband"] = true,
	["item_psychic_headband2"] = true,
	["item_tpscroll"] = true,

}

function AOHGameMode:TrackDisconnectedPlayers()
	if not IsServer() then return end

	for i = 0, PlayerResource:GetPlayerCount() - 1 do
		local player = PlayerResource:GetPlayer(i)
		if not player then
			if not disconnected_players[i] then
				disconnected_players[i] = 0
			else
				disconnected_players[i] = disconnected_players[i] + 1
			end

			if disconnected_players[i] >= ABANDONED_THRESHOLD then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				if hero and not dropped_heroes[hero] then
					-- drop hero's items on the ground with no owner
					for j = 0, 8 do
						local item = hero:GetItemInSlot(j)
						if item and not item_exceptions[item:GetName()] then
							--local pos = hero:GetAbsOrigin()
							--local drop = CreateItemOnPositionSync(pos, item)
							--drop:SetContainedItem(item)
							OnLootDropItem(item:GetName())
							item:RemoveSelf()
						end
					end

					-- drop hero's stash items on the ground with no owner
					for j = 9, 14 do
						local item = hero:GetItemInSlot(j)
						if item and not item_exceptions[item:GetName()] then
							--local pos = hero:GetAbsOrigin()
							--local drop = CreateItemOnPositionSync(pos, item)
							--drop:SetContainedItem(item)
							OnLootDropItem(item:GetName())
							item:RemoveSelf()
						end
					end

					-- mark hero as dropped
					Notifications:TopToAll({text="Player disconnected for more then 7 min , most of his items have ben distributed to other players", style={color="red"}, duration=7})
					dropped_heroes[hero] = true
				end
			end
		else	
			disconnected_players[i] = 0
		end
	end
end





function AOHGameMode:_RevealShop()
	local shopPos = Entities:FindByName(nil, "the_shop"):GetAbsOrigin()
	AddFOWViewer(2, shopPos, 1000, 10000, true)
end

function AOHGameMode:_CheckWin()
	if self._nRoundNumber > #self._vRounds then
		if self._nRoundNumber > #self._vRounds then
			if self._endlessHard_started then
				if self:IsEndlessWin() and not self._vic_1 then
					if self._extra_mode then
						if self._doubleMode then
							Notifications:TopToAll({text="You Have Defeated All Mortals and Gods(Higher Difficulty + Double)", style={color="red"}, duration=20})
							hiddenCommand_(15)
						else
							Notifications:TopToAll({text="You Have Defeated All Mortals and Gods(Higher Difficulty)", style={color="red"}, duration=20})
							hiddenCommand_(10)
						end
					elseif self._doubleMode then
						Notifications:TopToAll({text="You Have Defeated All Mortals and Gods(Lower Difficulty + Double)", style={color="red"}, duration=20})
						hiddenCommand_(7)			
					else
						Notifications:TopToAll({text="You Have Defeated All Mortals and Gods (Lower Difficulty)", style={color="red"}, duration=20})
						hiddenCommand_(5)
					end		
					Timers:CreateTimer({
						endTime = 15, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
						callback = function()
							GameRules:SetSafeToLeave(true)
							end_screen_setup(self._entAncient and self._entAncient:IsAlive())			
							PauseGame(true)
							Timers:CreateTimer({
								useGameTime = false, 
								endTime = 0.4, 
								callback = function()
									PauseGame(false)
								end
							})							
							GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
						end
					})		
					self._vic_1 = true
					GameRules.GLOBAL_vic_1 = self._vic_1
					send_info_if_game_ends()
				end	
			elseif self._endlessMode_started and self._hardMode then
				self._endlessHard_started = true
				self:_ReadGameConfiguration()
				self._nRoundNumber = 1
				self._currentRound = nil
				self._flPrepTimeBetweenRounds = 5
				self._flPrepTimeEnd = GameRules:GetGameTime() + 6
				if self._extra_mode then
					if self._doubleMode then
						Notifications:TopToAll({text="Part 3 ,You have Done Well Geting This Far(Higher Difficulty +Double)", style={color="red"}, duration=8})
						hiddenCommand_(4)
					else
						Notifications:TopToAll({text="Part 3 ,You have Done Well Geting This Far", style={color="red"}, duration=8})
						hiddenCommand_(3)
					end
				elseif self._doubleMode then
					Notifications:TopToAll({text="Part 3 Lower dificulty, You have Done Well Geting This Far (Lower Difficulty +Double)", style={color="red"}, duration=8})	
					hiddenCommand_(3)		
				else
					Notifications:TopToAll({text="Part 3 Lower dificulty, You have Done Well Geting This Far", style={color="red"}, duration=8})
					hiddenCommand_(2)
				end	
			
			elseif self._endlessMode and not self._hardMode then
				self._endlessMode_started = true
				_G._endlessMode_started = true
				self:_ReadGameConfiguration()
				self._nRoundNumber = 1
				self._currentRound = nil
				self._flPrepTimeBetweenRounds = 5
				self._flPrepTimeEnd = GameRules:GetGameTime() + 6
				if self._endlessMode_started then
					if self:IsEndlessWin() and not self._vic_1 then
						Notifications:TopToAll({text="You Have Defeated All Mortals, Try -fullgame to Encounter Final God Bosses", style={color="red"}, duration=10})
						hiddenCommand_(1)
						Timers:CreateTimer({
							endTime = 15, 
							callback = function()
								GameRules:SetSafeToLeave(true)
								end_screen_setup(self._entAncient and self._entAncient:IsAlive())			
								PauseGame(true)
								Timers:CreateTimer({
									useGameTime = false, 
									endTime = 0.4, 
									callback = function()
										PauseGame(false)
									end
								})								
								GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
							end
						})
						self._vic_1 = true
						GameRules.GLOBAL_vic_1 = self._vic_1
						send_info_if_game_ends()						
					end
				end		
			elseif self._endlessMode then
				self._endlessMode_started = true
				_G._endlessMode_started = true
				self:_ReadGameConfiguration()
				self._nRoundNumber = 1
				self._currentRound = nil
				self._flPrepTimeBetweenRounds = 5
				self._flPrepTimeEnd = GameRules:GetGameTime() + 6
				if self._extra_mode then
					if self._doubleMode then
						Notifications:TopToAll({text="Second part has Begin(Higher Difficulty + Double)", style={color="red"}, duration=7})
						hiddenCommand_(2)
					else
						Notifications:TopToAll({text="Second part has Begin(Higher Difficulty)", style={color="red"}, duration=7})
						hiddenCommand_(1)
					end	
				else
					Notifications:TopToAll({text="Second part has Begin(Lower Difficulty)", style={color="red"}, duration=7})	
					hiddenCommand_(1)
				end	
			elseif not self._vic_1 then
				if not _G._normal_mode then
					Notifications:TopToAll({text="You Have Defeated Demo Difficulty on Easy, Try '-normal', or -fullgame to meet new bosses and final GOD Bosses", style={color="red"}, duration=20})
					hiddenCommand_(1)
				else
					Notifications:TopToAll({text="You Have Defeated Demo Difficulty , Try -fullgame to meet new bosses and final GOD Bosses", style={color="red"}, duration=20})
					hiddenCommand_(1)
				end	
				Timers:CreateTimer({
					endTime = 15,
					callback = function()
						GameRules:SetSafeToLeave(true)
						end_screen_setup(self._entAncient and self._entAncient:IsAlive())			
						PauseGame(true)
						Timers:CreateTimer({
							useGameTime = false, 
							endTime = 0.4, 
							callback = function()
								PauseGame(false)
							end
						})						
						GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
					end
				})
				self._vic_1 = true
				GameRules.GLOBAL_vic_1 = self._vic_1
				send_info_if_game_ends()	
			end
		end
	end
end
local slayer_fragmet = 4
local edible_bonus_fragment = 3
local encahnter_bonus = 2
function AOHGameMode:OnHeroLevelUp(event)
	local hero = EntIndexToHScript(event.hero_entindex)
	-- Save current unspend AP
	local unspendAP = hero:GetAbilityPoints()
	local heroLevel = hero:GetLevel()
	local nPlayerID = hero:GetPlayerID()
	if not PlayerResource:IsValidPlayer(nPlayerID) then return end
	local dice_1 = RandomInt(1, 100)
	local dice_2 = RandomInt(1, 100)
	local abilityPointsToGive = 1
	local apEveryXLevel = 7
	local fragmentEveryXLevel = 7
	local cardPointsToGive = 0
	local cpEveryXLevel = 12
	local itEveryXLevel = 75
	local ediblefragment = 20
	--hiddenCommand_(50)
	if hero:HasModifier("modifier_item_imba_skadi_unique") then
		if hero:IsRealHero() then
			local bonus = 8 * _G._challenge_bosss
			local base = 20 + bonus
			hero:ModifyIntellect(base)
		end	
	end

	if (heroLevel % apEveryXLevel == 0) then
		hero:SetAbilityPoints(unspendAP + abilityPointsToGive)
	end
	if (heroLevel % cpEveryXLevel == 0) and not hero:IsIllusion() then
		-- Check if main/real hero
		local mainHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
		if mainHero == hero then
			--cardPointsToGive = 1
			DropItemOrInventory2(nPlayerID, "item_random_get_ability_onlvl")
			--mainHero:AddItemByName("item_random_get_ability_onlvl")
			--holdout_card_points:_BuyCardPoints(nPlayerID, cardPointsToGive)
		end
	end	
	if (heroLevel % itEveryXLevel == 0) and not hero:IsIllusion() then
		-- Check if main/real hero
		local mainHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
		if mainHero == hero then
			DropItemOrInventory(nPlayerID, "item_weapon_fragment")
			--mainHero:AddItemByName("item_weapon_fragment")
		end
	end
	if (heroLevel % fragmentEveryXLevel == 0) and not hero:IsIllusion() then
		-- Check if main/real hero
		local mainHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
		if mainHero == hero then
			if self._playerNumber < 2 and slayer_fragmet > 0 then
				--mainHero:AddItemByName("item_weapon_fragment")
				if _G._sell_slayer_fragmets then
					GameRules:IncreaseItemStock(DOTA_TEAM_GOODGUYS, "item_weapon_fragment", 1, -1)
					Notifications:Top(nPlayerID,{text="Personal: A Slayer weapon fragment has ben added to shop from your drop", style={color="yellow"}, duration=8})
				else	
					DropItemOrInventory(nPlayerID, "item_weapon_fragment")
				end
				slayer_fragmet = slayer_fragmet - 1
			else
				if RandomInt( 0,100 ) < 28 then
					if _G._sell_slayer_fragmets then
						GameRules:IncreaseItemStock(DOTA_TEAM_GOODGUYS, "item_weapon_fragment", 1, -1)
						Notifications:Top(nPlayerID,{text="Personal: A Slayer weapon fragment has ben added to shop from your drop", style={color="yellow"}, duration=8})
					else	
						DropItemOrInventory(nPlayerID, "item_weapon_fragment")
					end
					--mainHero:AddItemByName("item_weapon_fragment")
				end
				if self._playerNumber < 4 then
					if RandomInt( 0,100 ) < 20 then
						if _G._sell_slayer_fragmets then
							GameRules:IncreaseItemStock(DOTA_TEAM_GOODGUYS, "item_weapon_fragment", 1, -1)
							Notifications:Top(nPlayerID,{text="Personal: A Slayer weapon fragment has ben added to shop from your drop", style={color="yellow"}, duration=8})
						else	
							DropItemOrInventory(nPlayerID, "item_weapon_fragment")
						end	
						--mainHero:AddItemByName("item_weapon_fragment")
					end	
				end
				if self._playerNumber < 2 then
					if RandomInt( 0,100 ) < 10 then
						if _G._sell_slayer_fragmets then
							GameRules:IncreaseItemStock(DOTA_TEAM_GOODGUYS, "item_weapon_fragment", 1, -1)
							Notifications:Top(nPlayerID,{text="Personal: A Slayer weapon fragment has ben added to shop from your drop", style={color="yellow"}, duration=8})
						else	
							DropItemOrInventory(nPlayerID, "item_weapon_fragment")
						end
						--mainHero:AddItemByName("item_weapon_fragment")
					end	
				end
			end					
		end
	end
	if (heroLevel % ediblefragment == 0) and not hero:IsIllusion() then
		-- Check if main/real hero
		local mainHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
		if mainHero == hero then
			if self._playerNumber < 2 and edible_bonus_fragment > 0 then
				--mainHero:AddItemByName("item_edible_fragment")
				DropItemOrInventory(nPlayerID, "item_edible_fragment")
				edible_bonus_fragment = edible_bonus_fragment - 1		
			elseif RandomInt( 0,100 ) < 25 then
				DropItemOrInventory(nPlayerID, "item_edible_fragment")
				--mainHero:AddItemByName("item_edible_fragment")
			end
		end
	end
	if (heroLevel == 20) and not hero:IsIllusion() then
		-- Check if main/real hero
		local mainHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
		if mainHero == hero then
			DropItemOrInventory2(nPlayerID, "item_branch_component")
			--mainHero:AddItemByName("item_branch_component")
		end
	end	
	if (heroLevel == 10) and not hero:IsIllusion() then
		-- Check if main/real hero
		local mainHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
		if mainHero == hero then
			DropItemOrInventory(nPlayerID, "item_all_essence")
		end
	end	
	if self._playerNumber < 2 and encahnter_bonus > 0 and not hero:IsIllusion() and (heroLevel > 9) then	
		local mainHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
		if mainHero == hero then
			DropItemOrInventory(nPlayerID, "item_enchanter")
			--mainHero:AddItemByName("item_enchanter")
			encahnter_bonus = encahnter_bonus - 1
		end
	elseif dice_1 == dice_2 and not hero:IsIllusion() and (heroLevel > 9) then
		-- Check if main/real hero
		local mainHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
		if mainHero == hero then
			DropItemOrInventory(nPlayerID, "item_enchanter")
			--mainHero:AddItemByName("item_enchanter")
		end
	end							
end

_G.lopata = true
function AOHGameMode:OnTreeCut(keys)
	if RollPseudoRandom(1, self) and lopata then
		local item = CreateItem("item_trusty_shovel", nil, nil)
		CreateItemOnPositionSync(Vector(keys.tree_x,keys.tree_y,0), item)
		AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(keys.tree_x,keys.tree_y,0), 300, 10, false)
		_G.lopata = false
	end
end


function AOHGameMode:_CheckForDefeat()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if self._entAncient and self._entAncient:IsAlive() then
			if are_all_heroes_dead() and not self._ischeckingdefeat then
				GameRules:GetGameModeEntity():SetThink("CheckForDefeatDelay", self, 0.5)
				self._ischeckingdefeat = true
			end
		else
			print("end game post")
			send_info_if_game_ends()
			GameRules:SetSafeToLeave(true)
			PauseGame(true)
			Timers:CreateTimer({
				useGameTime = false, 
				endTime = 0.4, 
				callback = function()
					PauseGame(false)
				end
			})			
			--end_screen_setup(self._entAncient and self._entAncient:IsAlive())			
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)	
		end
	end
end

local one_time_reward = true

function AOHGameMode:CheckForDefeatDelay()
	if self._defeatcounter > 0 then
		Notifications:TopToAll({text=self._defeatcounter, duration=1})
		self._defeatcounter = self._defeatcounter - 1
		return 1
	else 
		if self._entAncient and self._entAncient:IsAlive() then
			local time = math.floor(GameRules:GetGameTime() / 60)
			local bonus_gold = (5 + time) * 500
			if are_all_heroes_dead() then
				if _G._defeat_extra_lives > 0 and not _G._hardMode then
					if one_time_reward then
						refresh_players_bonus()
						_G._defeat_extra_lives = _G._defeat_extra_lives - 1
						Notifications:TopToAll({text="Lives left = " .._G._defeat_extra_lives.. ", Everyone gets 5 lvls, " ..bonus_gold.. " gold and an Edible Fragment.", style={color="green"}, duration=10})
						self._defeatcounter = 10
						self._ischeckingdefeat = false
						one_time_reward = false
						return nil
					else
						refresh_players_bonus()
						_G._defeat_extra_lives = _G._defeat_extra_lives - 1
						Notifications:TopToAll({text="Lives left = " .._G._defeat_extra_lives.. ", Everyone gets 5 lvls and  " ..bonus_gold.. "  gold.", style={color="green"}, duration=10})
						self._defeatcounter = 10
						self._ischeckingdefeat = false
						return nil						
					end	
				elseif _G._defeat_extra_lives > 0 and _G._hardMode then
					refresh_players_bonus()
					_G._defeat_extra_lives = _G._defeat_extra_lives - 3
					Notifications:TopToAll({text="Lives left = " .._G._defeat_extra_lives.. ", Everyone gets 5 lvls and " ..bonus_gold.. " gold.", style={color="green"}, duration=10})
					self._defeatcounter = 10
					self._ischeckingdefeat = false
					return nil
				else	
					print("anciend 1")
					self._entAncient:Kill(nil,nil)
					print("anciend killed")
					Notifications:TopToAll({text="You LOST, All Heroes dead When CountDown ended with 0 lives left", style={color="red"}, duration=5})
					Timers:CreateTimer({
						endTime = 4,
						callback = function()
							self._entAncient:Kill(nil,nil)
						end
					})
				end		
			else
				Notifications:TopToAll({text="CLEAR", duration=1})
				self._defeatcounter = 10
				self._ischeckingdefeat = false
				return nil
			end
		end
	end
end

function AOHGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
		self._flPrepTimeEnd = nil
		if self._entPrepTimeQuest then
			UTIL_Remove(self._entPrepTimeQuest)
			self._entPrepTimeQuest = nil
		end
		GameRules.GLOBAL_roundNumber = self._nRoundNumber  -- Set a global.
		GameRules.GLOBAL_endlessHard_started = self._endlessHard_started --another global
		GameRules.GLOBAL_endlessMode_started = self._endlessMode_started
		_G._endlessMode_started = self._endlessMode_started
		GameRules.GLOBAL_extra_mode = self._extra_mode
		GameRules.GLOBAL_vic_1 = self._vic_1
		GameRules.GLOBAL_doubleMode	= self._doubleMode
		GameRules.GLOBAL_hardMode = self._hardMode

		self._currentRound = self._vRounds[self._nRoundNumber]
		--if self._endlessMode_started then
		--	self._currentRound:BeginEndless(#self._vRounds)
		--end
		if self._doubleMode then
			self._currentRound:BeginDouble()
		end

		self._currentRound:Begin(self._goldRatio, self._expRatio, self._nRoundNumber)
		self:AtRoundStart()
		self:RecountPlayers()
		RefillBottle()
		return
	end

	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous("quest", { name = "PrepTime", title = "#DOTA_Quest_Holdout_PrepTime" })
		self._entPrepTimeQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber)
		local round = self._vRounds[self._nRoundNumber]
		round:Precache()
	end
	self._entPrepTimeQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime())
end

local IllusionNotLearn = {
		--["dark_willow_bedlam_lua"] = true,
		["chen_custom_holy_persuasion"] = true,
		["dark_seer_custom_dark_clone_2"] = true,
		["rubick_spell_steal"] = true,
		["arc_warden_tempest_double"] = true,
		["dawnbreaker_luminosity"] = true,
		["dawnbreaker_custom_luminosity"] = true,
		["obs_replay"] = true,
		["lone_druid_spirit_bear"] = true,
		--["legion_commander_duel_lua"] = true,
		--["custom_drow_ranger_trueshot"] = true,
		--["ability_random_custom_gold"] = true,
	};

LinkLuaModifier("modifier_generic_handler", "modifiers/modifier_generic_handler", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_charges", "modifiers/modifier_charges", LUA_MODIFIER_MOTION_NONE)
local reminder = true
function AOHGameMode:OnEntitySpawned(event)
	if not IsServer() then return end
	--mHackGameMode:OnNPCSpawned(event)
	-- Fix for str magic res and more.
	local unit = EntIndexToHScript(event.entindex)
	if unit:IsNull() then return end
	if (unit:GetPlayerOwnerID() == 0 and unit:IsRealHero() and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME) and reminder then
		local steam_name = PlayerResource:GetPlayerName(0)
		if GetMapName() == "heroattack_on_easy" then
			Notifications:TopToAll({text="Host( "..steam_name.." ) can type '-full' to enable Second part, '-normal' to have normal Ancient armor, check Map description for more", style={color="red"}, duration=10})
			reminder = false
		else	
			Notifications:TopToAll({text="Host( "..steam_name.." ) can type '-fullgame' to enable Full Game(hard only)(part 2 and 3), check Map description for more ", style={color="red"}, duration=15})
			reminder = false
		end	
	end	

	if unit and unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		local not_illusion = not unit:HasModifier('modifier_illusion')
		if IsValidEntity(unit) and not unit:IsHero()  then
			LearnAbilityOnSpawn(unit)
			-- self:_OnHeroFirstSpawned(npc)   
		end
	end		
	if unit and not unit:IsNull() and unit:IsHero()then
		if not unit:IsIllusion() then
			fix_atr_for_hero2(unit)
			check_hero_ranking(unit)
		end
		fix_atr_for_hero(unit)
		unit:AddNewModifier(unit, nil, "modifier_generic_handler", {})
		unit:AddNewModifier(unit, nil, "modifier_aegis_buff", {duration = 7})
		unit:AddNewModifier(unit, nil, "modifier_aegis_buff", {duration = 2})
	end	
	if unit and (unit:GetUnitName()== "npc_courier_replacement" or unit:GetUnitName()== "npc_dota_lone_druid_bear4") then
		unit:AddNewModifier(unit, nil, "modifier_generic_handler", {})
		unit:AddNewModifier(unit, nil, "modifier_aegis_buff", {duration = 7})
	end	

	Timers:CreateTimer({
		endTime = 0.1, 
		callback = function()
			if unit:IsNull() then return end
			if unit and IsValidEntity(unit) and unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and (unit:IsIllusion() or unit:HasModifier("modifier_arc_warden_tempest_double")) then
				if unit:HasModifier("modifier_death") then return end
				local playerownerID = unit:GetPlayerOwnerID()
				if not PlayerResource:GetPlayer(playerownerID) then return end
				local player = PlayerResource:GetPlayer(playerownerID)
				local playerHero = player:GetAssignedHero()
				local maxAbilities = playerHero:GetAbilityCount() - 1
				local skip = 0.01
				--print("illusion created")
				for abilitySlot=0, maxAbilities do
					skip = skip + 0.02
					Timers:CreateTimer({
						endTime = skip, 
						callback = function()
							if unit:IsNull() then return end
							if not unit:IsAlive() then return end
							local ability = playerHero:GetAbilityByIndex(abilitySlot)
							if ability ~= nil and not ability:IsNull() then 
								local abilityLevel = ability:GetLevel()
								local abilityName = ability:GetAbilityName()
								if unit and IllusionNotLearn[abilityName] ~= true and not unit:HasAbility(abilityName) and not ability:IsAttributeBonus() then
									if unit and abilityLevel > 0 then
										local illusionAbility = unit:AddAbility(abilityName)
										illusionAbility:SetLevel(abilityLevel)
									end
								end
							end
						end
					})		
				end
			end
		end
		})		
	--[[Timers:CreateTimer({
		endTime = 0.1, 
		callback = function()
			if unit and unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and unit:HasModifier("modifier_replay") then
				local playerownerID = unit:GetPlayerOwnerID()
				local player = PlayerResource:GetPlayer(playerownerID)
				local playerHero = player:GetAssignedHero()
				local maxAbilities = playerHero:GetAbilityCount() - 1
				local skip = 0.05
				print("illusion created")
				for abilitySlot=0, maxAbilities do
					skip = skip + 0.05
					Timers:CreateTimer({
						endTime = skip, 
						callback = function()
							local ability = playerHero:GetAbilityByIndex(abilitySlot)
							if ability ~= nil then 
								local abilityLevel = ability:GetLevel()
								local abilityName = ability:GetAbilityName()
								if unit and IllusionNotLearn[abilityName] ~= true and not unit:HasAbility(abilityName) and not ability:IsAttributeBonus() then
									if unit and abilityLevel > 0 then
										local illusionAbility = unit:AddAbility(abilityName)
										illusionAbility:SetLevel(abilityLevel)
									end
								end
							end
						end
					})		
				end
			end
		end
	})]]
	local custom_hp_bar = {
		["npc_dota_boss_void_spirit"] = true,
		["npc_boss_skeleton_king_angry_new"] = true,
		["npc_boss_skeleton_king_angry"] = true,
		["npc_boss_skeleton_king_ultimate"] = true,
		["npc_boss_juggernaut_2"] = true,
		["npc_dota_creature_siltbreaker_2"] = true,
		["npc_dota_boss_aghanim"] = true,
		["npc_boss_randomstuff_aiolos_demo"] = true,
		["npc_boss_juggernaut_3"] = true,
		["npc_dota_boss_void_spirit_2"] = true, 
		["npc_dota_creature_siltbreaker"] = true,
		["npc_boss_guesstuff_Moran"] = true,
		["npc_boss_randomstuff_aiolos"] = true,
		["npc_boss_juggernaut_4"] = true,
		--["npc_boss_skeletal_archer_new"] = true,

	};	
	local boss_challenger = {
		["npc_boss_juggernaut_4"] = true,
		--["npc_boss_skeleton_king_angry_new"] = true,


	};
--[[ 	if unit and unit:GetUnitName() == "npc_dota_dummy_misha" then 
		unit:AddNewModifier(unit, nil, "modifier_phys", {})
		print("misha phy buff")
	end	 ]]
	if unit and unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and unit:GetUnitName() ~= "npc_dota_thinker" then
		if self._endlessMode_started then
			unit:AddNewModifier(unit, nil, "modifier_power_boss", {})
		end
		unit:AddNewModifier(unit, nil, "modifier_boss", {})
        if self._extra_mode then
            if unit and unit:GetUnitLabel() == "randomskill" then
                Timers:CreateTimer(0.5, function( )
                    xpcall(
                                function()
                                  return getrandomskill(unit)
                                end,
                                function(msg)
                                  print(debug.traceback(msg, 3))
                                  return false
                                end
                            )
                end)                
                if RollPercentage(85) or unit:GetUnitName() == "npc_boss_randomstuff_aiolos" then
                    Timers:CreateTimer(1, function( )
                        xpcall(
                                function()
                                  return getrandomskill(unit)
                                end,
                                function(msg)
                                  print(debug.traceback(msg, 3))
                                  return false
                                end
                            )
                    end)                    
                end
            end    
        end
		if self._hardMode then
			unit:AddNewModifier(unit, nil, "modifier_hard_mode_boss", {})
		end
		if (unit:GetLevel() > 79) then
			--if unit:GetUnitName() == "npc_boss_randomstuff_aiolos" then
				--print("boss moster")
				unit:AddNewModifier(unit, nil, "modifier_phys", {})
				unit:AddNewModifier(unit, nil, "modifier_boss_truesight_aura", {})
			--end
		end			
		if boss_challenger[unit:GetUnitName()] == true then
			unit:AddNewModifier(unit, nil, "modifier_infinite_health", {duration = 420})
			--unit:AddNewModifier(unit, nil, "modifier_kill", {duration = 421})
		end	
		if unit:GetUnitName() == "npc_boss_guesstuff_Moran" or  unit:GetUnitName() == "npc_boss_randomstuff_aiolos" then
			unit:AddNewModifier(unit, nil, "modifier_double_trouble", {})
		end			
	end
	if custom_hp_bar[unit:GetUnitName()] == true then
		unit:AddNewModifier(unit, nil, "modifier_boss_hpbar2", {})
	end	
	
	if unit:GetUnitName() == "npc_dota_boss_aghanim" then
		for i=0,9 do
			Sounds:CreateSound(i, "goh.teme")
		end
	end
--[[ 	if unit:GetUnitName() == "npc_dota_boss_void_spirit" then
		for i=0,9 do
			Sounds:CreateSound(i, "bleach_fate")
		end
	end	 ]]	
	--for playerID = 0, 4 do
	--	if unit:GetUnitName() == "npc_boss_skeletal_archer_new" then
	--		Sounds:CreateSound(playerID, "bleach_fate")
	--	end 
	--end
	if unit:GetUnitName() == "npc_boss_guesstuff_Moran" and Cheats:IsEnabled() then		
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	end
	--[[if unit:GetUnitName() == "npc_boss_randomstuff_aiolos" and Cheats:IsEnabled() then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	end]]
				
end




function AOHGameMode:OnEntityKilled(event)
	if not IsServer() then return end
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	if killedUnit:IsNull() then return end
	if killedUnit:IsFort() then
		print("game end fort dead")
		GameRules:SetSafeToLeave(true)
		end_screen_setup(self._entAncient and self._entAncient:IsAlive())			
		PauseGame(true)
		Timers:CreateTimer({
			useGameTime = false, 
			endTime = 0.4, 
			callback = function()
				PauseGame(false)
			end
		})
	end	
	if killedUnit and killedUnit:IsRealHero()  then
		-- create_ressurection_tombstone(killedUnit)
		Timers:CreateTimer(1, function( )
			create_ressurection_tombstone(killedUnit)
		end)
		if killedUnit:IsRealHero() and not killedUnit:IsTempestDouble() and not killedUnit:IsReincarnating() then
			GameRules:GetGameModeEntity():SetCustomRadiantScore(GetTeamHeroKills(DOTA_TEAM_GOODGUYS))
			GameRules:GetGameModeEntity():SetCustomDireScore(GetTeamHeroKills(DOTA_TEAM_BADGUYS))
		end	
	end
	if killedUnit:GetUnitName() == "npc_playerhelp" then
		if not killedUnit:IsIllusion() and killedUnit:IsControllableByAnyPlayer() then
			local playerHero = PlayerResource:GetPlayer(0):GetAssignedHero()
			playerHero:AddNewModifier(playerHero, nil, "modifier_playerhelp_revive", {duration = 15})
			GameRules:GetGameModeEntity():SetThink("RevivePlayerHelp", self, 15)
		end
	end

	if self._endlessMode_started then
		if killedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			self:RemoveEndlessEnemy(killedUnit)
		end
	end
	--[[if killedUnit:GetUnitName() == "npc_dota_boss_aghanim" then
		for i=0,9 do
			Sounds:RemoveSound(i, "goh.teme")
		end
	end
	if killedUnit:GetUnitName() == "npc_dota_boss_void_spirit" then
		for i=0,9 do
			Sounds:RemoveSound(i, "bleach_fate")
		end
	end]]	
	if killedUnit:GetUnitName() == "npc_boss_guesstuff_Moran" and not Cheats:IsEnabled() then
		if self._extra_mode then
			if self._doubleMode then
				Notifications:TopToAll({text="You Have Defeated One God MORAN(Higher Difficulty + Double)", style={color="red"}, duration=15})
			else	
				Notifications:TopToAll({text="You Have Defeated The God MORAN(Higher Difficulty)", style={color="red"}, duration=15})
			end	
		else	
			Notifications:TopToAll({text="You Have Defeated The God MORAN(Lower Dificulty)", style={color="red"}, duration=15})
		end	
	end			
	mHackGameMode:OnEntityKilled(event)
end

-- Revives player help in single player mode
function AOHGameMode:RevivePlayerHelp()
	local playerHero = PlayerResource:GetPlayer(0):GetAssignedHero()
	self._nPlayerHelp = CreateUnitByName("npc_playerhelp", playerHero:GetAbsOrigin(), true, playerHero, playerHero:GetOwner(), playerHero:GetTeamNumber())
	self._nPlayerHelp:SetControllableByPlayer(playerHero:GetPlayerID(), true)
	self._nPlayerHelp:SetTeam(playerHero:GetTeamNumber())
	self._nPlayerHelp:SetOwner(playerHero)
end

function AOHGameMode:CheckForLootItemDrop(killedUnit)
	for _, itemDropInfo in pairs(self._vLootItemDropsList) do
		if RollPercentage(itemDropInfo.nChance) then
			OnLootDropItem(itemDropInfo.szItemName)
			--create_item_drop(itemDropInfo.szItemName, killedUnit:GetAbsOrigin())
		end
	end
end


function AOHGameMode:AddEndlessEnemy(enemy)
	self._endlessEnemyList = self._endlessEnemyList or {}

	table.insert(self._endlessEnemyList, enemy)
end
function AOHGameMode:RemoveEndlessEnemy(enemy)
	self._endlessEnemyList = self._endlessEnemyList or {}

	for i, unit in pairs(self._endlessEnemyList) do
		if enemy == unit then
			table.remove(self._endlessEnemyList, i)
			break
		end
	end	
end
function AOHGameMode:IsEndlessWin()
	if self._endlessMode_started and self._endlessEnemyList then
		return #self._endlessEnemyList == 0
	end
	return false
end

-----
--[[ function CScriptParticleManager:SetParticleControlEnt(particle, controlPoint, unit, particleAttach, attachment, offset, lockOrientation)
    success = pcall(function() CScriptParticleManager:SetParticleControlEnt(particle, controlPoint, unit, particleAttach, attachment, offset, lockOrientation) end)
    if success then
    else
    end
end ]]
-----





-------------------
-- ItemPurchased --
-------------------
function AOHGameMode:OnItemPurchased(event)
	if self.m_bMaxGold == true then
		local Buyer = PlayerResource:GetPlayer(event.PlayerID)
		local BuyerHero = Buyer:GetAssignedHero()
		BuyerHero:ModifyGold(event.itemcost, true, 0)
	elseif self.m_bMaxGold == false then
	end
end

-------------------
-- RefreshButton --
-------------------
function AOHGameMode:OnRefreshButtonPressed(eventSourceIndex)
	SendToServerConsole("dota_hero_refresh")
end

-------------------
-- LevelUpButton --
-------------------
function AOHGameMode:OnLevelUpButtonPressed(eventSourceIndex)
	SendToServerConsole("dota_dev hero_level 1")
end

-------------------
-- SuicideButton --
-------------------
function AOHGameMode:OnSuicideButtonPressed(eventSourceIndex)
	SendToServerConsole("dota_hero_suicide")
end

--------------------
-- MaxLevelButton --
--------------------
function AOHGameMode:OnMaxLevelButtonPressed(eventSourceIndex, data)
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	hPlayerHero:AddExperience(56045, false, false)
	SendToServerConsole("dota_dev hero_level 971")

	local Abilities = hPlayerHero:GetAbilityCount()
	for i = 0, Abilities do
		local Ability = hPlayerHero:GetAbilityByIndex(i)
		if Ability and Ability:CanAbilityBeUpgraded() == ABILITY_CAN_BE_UPGRADED and not Ability:IsHidden() then
			while Ability:GetLevel() < Ability:GetMaxLevel() do
				hPlayerHero:UpgradeAbility(Ability)
			end
		end
	end
--	hPlayerHero:SetAbilityPoints(0)
end

----------------------
-- FreeSpellsButton --
----------------------
function AOHGameMode:OnFreeSpellsButtonPressed(eventSourceIndex)
--	SendToServerConsole("toggle dota_ability_debug")
	if self.m_bFreeSpellsEnabled == false then
		self.m_bFreeSpellsEnabled = true
		SendToServerConsole("dota_hero_refresh")
		SendToServerConsole("dota_ability_debug 1")
	elseif self.m_bFreeSpellsEnabled == true then
		self.m_bFreeSpellsEnabled = false
		SendToServerConsole("dota_ability_debug 0")
	end
end

---------------------------
-- InvulnerabilityButton --
---------------------------
LinkLuaModifier("lm_take_no_damage", LUA_MODIFIER_MOTION_NONE)
function AOHGameMode:OnInvulnerabilityButtonPressed(eventSourceIndex, data)
	local PlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local AllPlayerUnits = {}
	AllPlayerUnits = PlayerHero:GetAdditionalOwnedUnits()
	AllPlayerUnits[#AllPlayerUnits + 1] = PlayerHero

	if self.m_bInvulnerabilityEnabled == false then
		for _, Unit in pairs(AllPlayerUnits) do
			Unit:AddNewModifier(PlayerHero, nil, "lm_take_no_damage", nil)
		end
		self.m_bInvulnerabilityEnabled = true
	elseif self.m_bInvulnerabilityEnabled == true then
		for _, Unit in pairs(AllPlayerUnits) do
			Unit:RemoveModifierByName("lm_take_no_damage")
		end
		self.m_bInvulnerabilityEnabled = false
	end
end


-------------------
-- MaxGoldButton --
-------------------
function AOHGameMode:OnMaxGoldButtonPressed(eventSourceIndex)
	if self.m_bMaxGold == false then
		self.m_bMaxGold = true
		SendToServerConsole("dota_dev player_givegold 99999")
		SendToServerConsole("dota_easybuy 1")
	elseif self.m_bMaxGold == true then
		self.m_bMaxGold = false
		SendToServerConsole("dota_easybuy 0")
	end
end

----------------------
-- SpawnEnemyButton --
----------------------
function AOHGameMode:OnSpawnEnemyButtonPressed(eventSourceIndex, data)
	local PlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)

	self._Misha = CreateUnitByName("npc_dota_dummy_misha", PlayerHero:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
	self._Misha:SetControllableByPlayer(PlayerHero:GetPlayerID(), true)

	table.insert(self.m_tEnemiesList,self._Misha)
end

------------------------------
-- RemoveSpawnedUnitsButton --
------------------------------
function AOHGameMode:OnRemoveSpawnedUnitsButtonPressed(eventSourceIndex)
--	for k, v in pairs(self.m_tEnemiesList) do
	local enemy = self.m_tEnemiesList[1]
	if enemy then
		enemy:Kill(nil,nil)
		table.remove(self.m_tEnemiesList, 1)
		enemy:RemoveSelf()
	end
	self.m_nEnemiesCount = 0
end

--------------------------
-- DayNightToggleButton --
--------------------------
function AOHGameMode:OnDayNightToggleButtonPressed(eventSourceIndex)
	if not _G._Sun then
		GameRules:SetTimeOfDay(0.75)
		_G._Sun = true
	else
		GameRules:SetTimeOfDay(0.25)
		_G._Sun = false
	end
end

--------------------------
-- HeroRenderModeButton --
--------------------------
function AOHGameMode:OnHeroRenderModeButtonPressed(eventSourceIndex)
	self.m_nHeroRenderMode = self.m_nHeroRenderMode + 1
	if self.m_nHeroRenderMode > 8 then
		self.m_nHeroRenderMode = 0
	end
	if self.m_nHeroRenderMode == 1 then
		self.m_nHeroRenderMode = 2 
	end

	SendToServerConsole(tostring(string.format("r_hero_debug_render_mode %i", self.m_nHeroRenderMode)))
end

-----------------
-- PauseButton --
-----------------
function AOHGameMode:OnPauseButtonPressed(eventSourceIndex)
	SendToServerConsole("dota_pause")
end

-----------------
-- LeaveButton --
-----------------
function AOHGameMode:OnLeaveButtonPressed(eventSourceIndex)
	SendToServerConsole("disconnect")
end
