if HackGameMode == nil then
    HackGameMode = class({})
end

require("hack/constants")
require("hack/precache_resource")
require("hack/game_mode_custom_hero_level")
require("hack/dev_util")
require("hack/boss_runes_system")
require("hack/test_code")
--require("hack/wearables/hack_wearables")
LinkLuaModifier("modifier_hero_target_dummy", "hack/modifiers/modifier_hero_target_dummy.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_invincible", "hack/modifiers/modifier_mjz_invincible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_invincible2", "hack/modifiers/modifier_mjz_invincible2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_god", "hack/modifiers/modifier_mjz_god.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_zero_mana", "hack/modifiers/modifier_mjz_zero_mana.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_zero_mana_alone", "hack/modifiers/modifier_mjz_zero_mana_alone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_mjz_healers", "hack/modifiers/modifier_mjz_healers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_friendly_npc", "hack/modifiers/modifier_friendly_npc", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_hold_spawer", "hack/modifiers/modifier_mjz_hold_spawer", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_fake_courier", "hack/modifiers/modifier_mjz_fake_courier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tower_rock_golem", "hack/building/modifier_tower_rock_golem", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rock_golem_animations", "hack/building/rock_golem_animations", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_mjz_blacklist", "hack/modifiers/modifier_mjz_blacklist", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_runes", "hack/modifiers/modifier_boss_runes", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gm_single_fort", "hack/modifiers/modifier_gm_single_fort", LUA_MODIFIER_MOTION_NONE )

--LinkLuaModifier("modifier_tiny_scepter_effect", "hack/modifier_tiny_scepter_effect.lua", LUA_MODIFIER_MOTION_NONE)

require('systems/roshan_system')
require("hack/hack_commands")

if IsInToolsMode() then
    HACK_GOD_MODIFIER = false
    HOME_INVINCIBLE = true
end

_G.mRoshanSystem = nil
function HackGameMode:CreateSystems()
	if not mRoshanSystem then
        mRoshanSystem = CRoshanSystem()
	end 
end


function HackGameMode:Precache( context )
    Precache_Resource(context)
    -- Wearables:Precache_Resource( context )
end

function HackGameMode:InitGameMode()
    if IsInToolsMode() then
		-- 启用 (true)或禁用 (false) 自定义游戏的自动设置。
		--GameRules:EnableCustomGameSetupAutoLaunch(true)
		-- 设置自动开始前的等待时间。
		GameRules:SetCustomGameSetupAutoLaunchDelay(0)
		-- 设置游戏的设置时间，0 = 立即开始 -1 = 等待直到设置完毕。
        -- GameRules:SetCustomGameSetupRemainingTime(0)

        -- 设置选择英雄时间
		-- GameRules:SetHeroSelectionTime(0)
		-- 设置决策时间
		GameRules:SetStrategyTime(0)
		-- 设置展示时间
		GameRules:SetShowcaseTime(0)
		-- 设置游戏准备时间
        GameRules:SetPreGameTime(5)

        -- GameRules:GetGameModeEntity():SetMaximumAttackSpeed(1000)
    else
        -- 设置选择英雄时间
		GameRules:SetHeroSelectionTime(60)
    end

    --GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
    if IsInToolsMode() then
        --GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 10 )
    end

    -- 任何一家商店都可以购买全部物品，不用到野外商店购买
	GameRules:SetUseUniversalShopMode(true)
    -- 禁用死亡时损失金钱
    GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)

    -- 自定义英雄的最大等级
    -- CustomHeroLevel()

    -- self:_Gold_And_EXP()

    --监听游戏进度
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(HackGameMode,"OnGameRulesStateChange"), self)

    self:_RegisterCommand()

    self:CreateSystems()

    --Wearables:InitGameMode()
end

function HackGameMode:OnThink()
	local nState = GameRules:State_Get()

	if IsInToolsMode() then
		-- This prevents us from having to restart the entire game mode to try new changes
		self:CreateSystems()
	end

    if nState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        mRoshanSystem:Init()
		mRoshanSystem:Think()
		
	elseif nState >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end

	return 1
end

function HackGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
        print("DOTA_GAMERULES_STATE_PRE_GAME")
        -- ShowGenericPopup( "#holdout_instructions_title", "#holdout_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
    elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        print("DOTA_GAMERULES_STATE_HERO_SELECTION")
        if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
            -- HeroSelection:Start()
        end
    elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
        print("Entered DOTA_GAMERULES_STATE_PRE_GAME")
        -- self:OnPreGameState()
    elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then	 -- 游戏开始
        print("Entered DOTA_GAMERULES_STATE_GAME_IN_PROGRESS")
        self:InitVariables()
        self:OnGameInProgress()
    elseif newState == DOTA_GAME_UI_STATE_LOADING_SCREEN then
        print("Entered DOTA_GAME_UI_STATE_LOADING_SCREEN")
    elseif newState == DOTA_GAME_UI_DOTA_INGAME then
        print("Entered DOTA_GAME_UI_DOTA_INGAME")
    elseif newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        print("Entered DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP")
	end
end

function HackGameMode:OnGameInProgress( )
    if not self._Inited_IN_PROGRESS then
        self._Inited_IN_PROGRESS = true

        local tip = "<font color='yellow'>Tips: Crash = Dota2 0 bytes update </font>"
        GameRules:SendCustomMessage(tip, 0, 0)
       
        InitCampfires()
        self:_AddBossSpawnPointView()

        if IsHoliday() or IsLucky() or IsInToolsMode() or true then
            self:_CreateGoldTree()
        end
        
        if IsInToolsMode() and HOME_INVINCIBLE then
            HomeInvincible()
        end

        local is_spell_immunity = IsInToolsMode() and true
        self:_CreateDummyTarget(is_spell_immunity, 1)
        self:_CreateDummyTarget(false, 2)
        if IsInToolsMode() and true then
            -- self:_CreateDummyTarget(is_spell_immunity)
            -- self:_CreateDummyTarget(is_spell_immunity)
        end

        local time = 8
        if IsInToolsMode() then time = 1 end
        Timers:CreateTimer(time, function( )
            self:_OnStartGame()
        end)
        
    end
end

function HackGameMode:OnEntityKilled(keys)
    --local killed_unit = EntIndexToHScript( keys.entindex_killed )
    -- local killer = nil
    -- if keys.entindex_attacker then
    --     killer = EntIndexToHScript( keys.entindex_attacker )
    -- end


    Timers:CreateTimer(1, function( )
        mRoshanSystem:OnEntityKilled(keys)
    end)

    local func = function (hero)
        local exp = 30
        local gold = 30
        -- AddGoldAndExpToHero(hero, gold, exp)
    end
    
end

function HackGameMode:OnNPCSpawned(data)
    local npc = EntIndexToHScript(data.entindex)
    local not_illusion = not npc:HasModifier('modifier_illusion')
    -- bug 大圣
    if npc:IsRealHero() and not_illusion and npc._bFirstSpawned == nil then
        npc._bFirstSpawned = true
        LearnAbilityOnSpawn(npc)

        -- self:_OnHeroFirstSpawned(npc)
        
    end

    -- 光法跳舞球
    if npc:GetUnitName() == "npc_dota_ignis_fatuus" then
        local ability = npc:FindAbilityByName("ignis_fatuus_health_counter")
        ability:SetLevel(1)
    end

    if npc:GetTeam() == DOTA_TEAM_BADGUYS and npc.GetUnitName then
        self:_OnBossSpawn(npc)
    end

    -- self:_TinyScepterEffect(npc)
end

function HackGameMode:ZeroManaMode(hero)
    if GameRules.GameMode._manaMode then
        if not hero:HasModifier("modifier_mjz_zero_mana") and not hero:HasModifier("modifier_mjz_zero_mana_alone") then
            hero:AddNewModifier(hero, nil, "modifier_mjz_zero_mana", {})
        end
    end
end
function HackGameMode:ZeroManaModeAlone(hero)
    if not hero:HasModifier("modifier_mjz_zero_mana") and not hero:HasModifier("modifier_mjz_zero_mana_alone") then
        hero:AddNewModifier(hero, nil, "modifier_mjz_zero_mana_alone", {})
    end
end
function HackGameMode:GM_SinglePlayer()
    local home = Entities:FindByName(nil, "dota_goodguys_fort")
    if home then
        if not home:HasModifier("modifier_gm_single_fort") then
            home:AddNewModifier(home, nil, "modifier_gm_single_fort", {})
        end
    end
end


function HackGameMode:InitVariables() 
    local hasMaker = false
	for playerID = 0, 4 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                
                --LearnAbilityOnSpawn(hero)
                
                self:_Bonus(hero)

                self:ZeroManaMode(hero)

                Timers:CreateTimer(1, function()
                    self:_CreateFakeCourier(hero)
				end)

                if IsMakerHero(hero) then
                    hasMaker = true
                end

                self:Backlist(hero)

                if IsInToolsMode() then
                    --  npc:SetGold(9999, false)	
                    AddGoldAndExpToHero(hero, 0, 3322)
                end
			end
		end
    end
    
    if hasMaker then
        -- self:_ReplaceBuildings()
    end
end

function HackGameMode:NotEnemy( npc )
    local list = {
        "npc_dota_gold_mine", "npc_dota_hero_target_dummy", "npc_dota_campfire"
    }
    for _,name in pairs(list) do
        if npc:GetUnitName() == name then
            return true
        end
    end
    return false
end

function HackGameMode:_OnStartGame()
    CallAllHeroFunc(function ( hero )
        hero._bFirstSpawned = true
        --self:_OnHeroFirstSpawned(hero)

        if IsInToolsMode() then
            -- AOHGameMode._endlessMode = true
            if HACK_GOD_MODIFIER then
                hero:AddNewModifier(hero, nil, "modifier_mjz_god", {})
            end

            -- hero:AddNewModifier(hero, nil, "modifier_boss_runes", {})

            local items ={
                "item_bigan_octarine_core", "item_ultimate_scepter" , "item_mjz_battlefury_5",
                "item_red_divine_rapier_lv5", "item_mjz_satanic_5",
                "item_minotaur_horn", 
                "item_force_blade",
                -- "item_imba_ultimate_scepter_synth"
            }
            for _,item in pairs(items) do
                hero:AddItemByName(item)
            end

            
                -- local couriersNumber= PlayerResource:GetNumCouriersForTeam(DOTA_TEAM_GOODGUYS)
                -- if couriersNumber>0 then
                --     for i=1,couriersNumber do
                --         local courier=PlayerResource:GetNthCourierForTeam(i-1,DOTA_TEAM_GOODGUYS)
                --         print("courier: " .. courier:GetUnitName())
                --     end
                -- end
                for playerID = 0, 4 do
                    if PlayerResource:IsValidPlayerID(playerID) then
                        if PlayerResource:HasSelectedHero(playerID) then
				            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                            for i = 0, PlayerResource:GetNumCouriersForTeam(PlayerResource:GetCustomTeamAssignment(hero:GetPlayerID())) - 1 do
                                local courier = PlayerResource:GetNthCourierForTeam(i, PlayerResource:GetCustomTeamAssignment(hero:GetPlayerID()))
                                print("courier: " .. courier:GetUnitName())
                                -- if courier:HasFlyMovementCapability() then
                                --     local isFlying = courier:HasFlyMovementCapability() == true
                                --     self:GetParent():SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
                                --     break
                                -- end
                            end
                        end
                    end
                end

               
	
        end

    end)
end

function HackGameMode:_OnHeroFirstSpawned(npc)
    if npc:GetTeamNumber() == DOTA_TEAM_BADGUYS then return end

    local START_GOLD = 3500
    local currentGold = npc:GetGold()
    local newGold = currentGold + START_GOLD
    npc:SetGold(newGold, false)	

    npc:AddItemByName("item_boots")
    npc:AddItemByName("item_stout_shield")

    
    if IsInToolsMode() then
        local exp = 2000
        local gold = 19999
        AddGoldAndExpToHero(npc, gold, exp)
        
        if npc:GetName() == 'npc_dota_hero_bloodseeker' then
            -- local m = 'modifier_bloodseeker_thirst_speed'
            -- npc:AddNewModifier(npc, nil, m, {})
    
        end
        -- npc:AddAbility('mjz_obsidian_destroyer_essence_aura')

        -- Wearables:PA(npc)
    end
end

function HackGameMode:_CreateFakeCourier(hero)
    local origin = Vector(-2958, 2031, -969) + RandomVector(100)
	local courier_replacement = CreateUnitByName("npc_courier_replacement", origin, true, hero, hero:GetOwner(), hero:GetTeamNumber())
	courier_replacement:SetControllableByPlayer(hero:GetPlayerID(), true)
	courier_replacement:SetTeam(hero:GetTeamNumber())
	courier_replacement:SetOwner(hero)
	self._nPlayerHelp = courier_replacement

    courier_replacement:AddNewModifier(courier_replacement, nil, "modifier_mjz_fake_courier", {})

	local playerID = hero:GetPlayerID()
	local player = hero:GetPlayerOwner()
	-- local courier = PlayerResource:GetNthCourierForTeam(playerID, DOTA_TEAM_GOODGUYS) 

	
end

-- BUG 
function HackGameMode:_ReplaceBuildings()
	local buildings = FindUnitsInRadius( DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false )
	for _,building in ipairs( buildings ) do
        if building:IsTower() then
            local vOrigin = building:GetOrigin()
            building:ForceKill(false)

            local newBuilding = self:CreateUnit("npc_dota_tower_rock_golem", vOrigin, DOTA_TEAM_GOODGUYS)
            if newBuilding then
                FindClearSpaceForUnit(newBuilding, vOrigin, false)

                -- newBuilding:SetPhysicalArmorBaseValue( TOWER_ARMOR ) -- using this hack because RespawnUnit wipes our armor and I don't want to fix RespawnUnit right now
                
                -- if not newBuilding:HasAbility( "tower_fortification" ) then 
                --     newBuilding:AddAbility( "tower_fortification" ) 
                -- end
                -- local fortificationAbility = newBuilding:FindAbilityByName( "tower_fortification" )
                -- if fortificationAbility then
                --     fortificationAbility:SetLevel( self._nRoundNumber / 2 )
                -- end

                newBuilding:RemoveModifierByName( "modifier_invulnerable" )

                newBuilding:AddNewModifier(building, nil, "modifier_tower_rock_golem", {})
                newBuilding:AddNewModifier(building, nil, "modifier_rock_golem_animations", {})
                newBuilding:AddNewModifier(building, nil, "modifier_tower_aura", {})
                newBuilding:AddNewModifier(building, nil, "modifier_tower_truesight_aura", {})
                
                -- 朝南
                newBuilding:SetAngles(0, -90, 0)

                newBuilding._spawn_point = vOrigin
                newBuilding:AddNewModifier(newBuilding, nil, "modifier_mjz_hold_spawer", {})
            end
		end
        --[[

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
        ]]
	end
end

function HackGameMode:Backlist(hero)
    local list = {
        130362254, 119132094, 406007535, 360652942, 882067581, 1594854, 154036977,
        76561198090627982, 76561198079397822,
    }
    local istest = false
    local isBlack = false
    local playerID = hero:GetPlayerID()
    local steamAccID = PlayerResource:GetSteamAccountID(playerID)
    local steamID = PlayerResource:GetSteamID(playerID)
    
    for _,id in pairs(list) do
        if id == steamAccID or id == steamID then
            isBlack = true
            break 
        end
    end
    
    if isBlack or istest then
        hero:AddNewModifier(hero, nil, "modifier_mjz_blacklist", {})
    end
end

function HackGameMode:_Gold_And_EXP()
    -- GameRules:SetGoldPerTick(2)             --每跳2金币
    -- GameRules:SetGoldTickTime(1)            --1秒1跳

    local func = function (hero)
        local exp = 6
        local gold = 5
        AddGoldAndExpToHero(hero, gold, exp)
    end

    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("addxp"),--计时器，每XX秒运行一次函数
        function ()
            if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then 
                if not GameRules:IsGamePaused() then
                    CallAllHeroFunc(func)
                end
            end  
            -- return nil  -- 停止计时器
            return 5  --函数5秒执行一次
        end
    , 0) 
end


-- 补贴：不同人数玩家
function HackGameMode:_Bonus( hero )
    local playerID = hero:GetPlayerID()
    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if steamID == 333664846 and not IsInToolsMode() then
        hero:AddItemByName("item_boots")
        
        local START_GOLD = 1000
        -- local currentGold = hero:GetGold()
        -- local newGold = currentGold + START_GOLD
        -- hero:SetGold(newGold, false)	
        AddGoldAndExpToHero(hero, START_GOLD)
    end

    local pc = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    local bonusGold = 0

    if pc == 4 then
        bonusGold = 200
    elseif pc == 3 then
        bonusGold = 400
    elseif pc == 2 then
        bonusGold = 800
    elseif pc == 1 then
        bonusGold = 1500   
    end

    if bonusGold > 0 then
        AddGoldAndExpToHero(hero, bonusGold)
    end
end




function AddGoldAndExpToHero(hero, gold, exp)
    if hero then
        if exp and exp > 0 then
            hero:AddExperience(exp, DOTA_ModifyGold_HeroKill, false, false) ---给触发者增加经验
        end
        if gold and gold > 0 then
            local playerid = hero:GetPlayerID()
            PlayerResource:ModifyGold(playerid, gold, false, 10)
        end
    end
end

-- 老家无敌
function HomeInvincible( ... )
    local home = Entities:FindByName(nil, "dota_goodguys_fort")
    home:AddNewModifier(home, nil, "modifier_mjz_invincible", {})
end

-- 给BOSS产生点添加视野、视野为敌人的
function HackGameMode:_AddBossSpawnPointView()
    local point = Vector(-34, -1979, 64)
    -- ( nTeamID, vLocation, flRadius, flDuration, bObstructedVision)
    AddFOWViewer(DOTA_TEAM_BADGUYS, point, 1600, 10000, false)
    if IsInToolsMode() then
        AddFOWViewer(DOTA_TEAM_GOODGUYS, point, 1600, 10000, false)
    end
end

-- 经验树
function HackGameMode:_CreateGoldTree(  )
    local point = Vector(-3076, 2933, 64)
    local name = 'npc_dota_gold_mine'
    local team =  DOTA_TEAM_BADGUYS --DOTA_TEAM_NEUTRALS -- DOTA_TEAM_GOODGUYS 
    local gold_tree = self:CreateUnit(name, point, team)
    if gold_tree then
        FindClearSpaceForUnit(gold_tree, point, false)
        gold_tree.mjz_retain = true -- 回合结束后不移除
        gold_tree:RemoveModifierByName("modifier_invulnerable")
        gold_tree._spawn_point = point
        gold_tree:AddNewModifier(gold_tree, nil, "modifier_mjz_hold_spawer", {})
        local p = gold_tree:GetAbsOrigin()
        local s = string.format( "Create Gold Tree : X(%f) Y(%f) Z(%f)", p.x, p.y, p.z )
        --print(s)
    end
end

-- 傀儡目标
function HackGameMode:_CreateDummyTarget(is_spell_immunity, number )
    local point_list = {
        Vector(-3089, 1571, 192),
        Vector(-3186, 2372, 64)
        -- Vector(-2946, 2392, 192),
    }
    local point = point_list[number]
    local team = DOTA_TEAM_BADGUYS --DOTA_TEAM_NEUTRALS -- --  -- DOTA_TEAM_GOODGUYS 
    local playerID = nil
    
    if IsInToolsMode() then
        playerID = PlayerInstanceFromIndex(1):GetPlayerID()
    end

    local unit = CreateUnit_DummyTarget(point, team, playerID)
    if unit then
        unit.mjz_retain = true -- 回合结束后不移除
        FindClearSpaceForUnit(unit, point, false)
        unit:AddNewModifier(unit, nil, 'modifier_hero_target_dummy', {})
        unit._spawn_point = point
        unit:AddNewModifier(unit, nil, "modifier_mjz_hold_spawer", {})
        -- unit:RemoveModifierByName("modifier_invulnerable")
        if is_spell_immunity then
            unit:AddAbility('neutral_spell_immunity')            
        end

        local p = unit:GetAbsOrigin()
        local s = string.format( "Create Dummy Target : X(%f) Y(%f) Z(%f)", p.x, p.y, p.z )
        --print(s)
    end
end

function HackGameMode:_TinyScepterEffect( npc )
    if npc:GetName() == 'npc_dota_hero_tiny' then
        print('Spawn Hero: Tiny')
        if not npc:HasModifier('modifier_tiny_scepter_effect') then
            npc:AddNewModifier(npc, nil, 'modifier_tiny_scepter_effect', {})
        end
    end
end

function HackGameMode:_CreateDummyPlayer(hero)
    DummyNames =
    {
        [1] = "Arhowk",
        [2] = "Steve",
        [3] = "Nathan",
        [4] = "Alex",
        [5] = "Joan",
        [6] = "Christian",
        [7] = "Amy",
        [8] = "Chris",
        [9] = "Jim",
        [10] = "Dan",
    }

    -- local hero = PlayerInstanceFromIndex(1):GetAssignedHero()
    local point = hero:GetAbsOrigin()
    for i=1,4 do
        local unit = CreateUnitByName("npc_dota_hero_axe", point, false, nil, nil, DOTA_TEAM_GOODGUYS)
        unit:SetControllableByPlayer(1, false)
    end
end

function HackGameMode:CreateUnit( name, point, team, angles )
    team = team or DOTA_TEAM_NEUTRALS
    angles = angles or Vector(0, 0, 0)
    local unit = CreateUnitByName(name, point, true, nil, nil, team)
    unit.vSpawnLoc = unit:GetOrigin()
    unit.team = team
    unit:SetAngles(angles.x, angles.y, angles.z)
    unit:SetAbsOrigin(point)
    return unit
end

-- 篝火
function InitCampfires()
	local team = 2
	local pos_list = {}
	pos_list[1] = Vector(-964, -1210, 320)
    pos_list[2] = Vector(954, -1210, 320)
    local team_good = DOTA_TEAM_GOODGUYS
    local team_bad  = DOTA_TEAM_BADGUYS
    local team_neu  = DOTA_TEAM_NEUTRALS
    local team = team_bad

    for i,pos in ipairs(pos_list) do
        local unit = CreateUnitByName("npc_dota_campfire", pos, true, nil, nil, team)
        unit.mjz_retain = true -- 回合结束后不移除
        unit._spawn_point = pos
        unit:AddNewModifier(unit, nil, "modifier_mjz_hold_spawer", {})
		AddFOWViewer(team_good, pos, 10, 99999, true)
    end

end
