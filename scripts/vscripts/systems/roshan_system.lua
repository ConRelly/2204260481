--[[
    源文件：https://github.com/balancedenergy/game/scripts/vscripts/systems/roshan_system.lua
]]

LinkLuaModifier('modifier_roshan_bonus', 'modifiers/modifier_roshan_bonus', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_roshan_bonus_burn', 'modifiers/modifier_roshan_bonus_burn', LUA_MODIFIER_MOTION_NONE)
--require("lib/utils")
-- Manage Game Mode Roshan
if CRoshanSystem == nil then
	CRoshanSystem = class({})
end

-- Configuration
local MAX_PRISION_RANGE = 1000                      -- 可以被攻击的范围
local BONUS_DURATION = 120
local MIN_RESPAWN_TIME = 1                        -- 最短刷新时间
local MAX_RESPAWN_TIME = 14                        -- 最长刷新时间
local ROSHAN_CLASS_NAME = "npc_dota_roshan_mega"    -- Roshan 类名
local ROSHAN_SPAWNER = "roshan_spawner"             -- 出生定位点

if IsInToolsMode() or GameRules:IsCheatMode() then
    MIN_RESPAWN_TIME = 1
    MAX_RESPAWN_TIME = 1
end
-- Indicates the time Respawn should be done
CRoshanSystem._flRespawnTime = -1.0

-- Indicates that Roshan is currently
CRoshanSystem._iNum = 1

-- Indicates that Roshan is currently
CRoshanSystem._RoshanXP = 700
CRoshanSystem._RoshanXP_killer = 100

-- Indicates the position where Spawn will be made
CRoshanSystem._SpawnPosition = Vector(-2464.244629, 1900.373291, 159.998383)

-- Indicates which direction Roshan should look at
CRoshanSystem._SpawnAngles = Vector(0, 305.999969, 0)

CRoshanSystem._SpawnAngles = Vector(0, 180, 0)      -- 面向西面

-- Indicate if Roshan has rotated                   -- 是否旋转面向角度
CRoshanSystem._bRotated = true

-- Initilization
-- Saves necessary information and removes the roshan spawner
function CRoshanSystem:Init()
    if self._inited then
        return false
    else
        self._inited = true
    end
    self._playernr = 0
    ListenToGameEvent('player_connect', Dynamic_Wrap(self, 'OnPlayerConnect'), self)    
    print("RoshanSystem: Init...")
    for playerID = 0, 4 do  
        if PlayerResource:IsValidPlayerID(playerID) then
            if PlayerResource:HasSelectedHero(playerID) then
                if PlayerResource:GetPlayer(playerID) then
                    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                    self._playernr = self._playernr + 1
                    --Sounds:CreateSound(playerID, "goh.teme")
                end
            end
        end 
    end       
    local hSpawner = Entities:FindByName(nil, ROSHAN_SPAWNER)
    local hRoshan = Entities:FindByClassname(nil, "npc_dota_roshan")

    if (not hSpawner) then
        print("RoshanSystem: cannot find hSpawner")
        return
    end

    -- We need to know where you will be
    -- self._SpawnPosition = hRoshan:GetAbsOrigin()
    -- self._SpawnAngles = hSpawner:GetAnglesAsVector()
    -- 获得定位点的位置，作为 Roshan 的出生点
    self._SpawnPosition = hSpawner:GetAbsOrigin()  
    -- self._SpawnPosition = hRoshan:GetAbsOrigin()


    -- Bye!
    if hSpawner then UTIL_Remove(hSpawner) end
    if hRoshan then UTIL_Remove(hRoshan) end

    -- We create our own Roshan
    self:CreateRoshan()
    print("Nr of Players is "..self._playernr)
end

-- Returns Roshan
function CRoshanSystem:GetRoshan()
    -- return Entities:FindByClassname(nil, ROSHAN_CLASS_NAME)
    if self._roshan_instance and not self._roshan_instance:IsNull() then
        return self._roshan_instance
    else
        return nil
    end
end

-- Called when roshan die
function CRoshanSystem:OnEntityKilled(tData)
    -- This rarely happens...
    if ( not tData.entindex_attacker or not tData.entindex_killed ) then
        return
    end

    local hRoshan = self:GetRoshan()
    local hKiller = EntIndexToHScript(tData.entindex_attacker)

    if ( not hRoshan ) then
        return
    end

    -- We are only interested in Roshan
    if ( hRoshan:GetEntityIndex() ~= tData.entindex_killed ) then
        return
    end

    -- 
    if ( hRoshan:HasModifier('modifier_roshan_bonus') ) then
        if (hKiller:IsRealHero()) then
            hKiller:AddNewModifier(hKiller, nil, 'modifier_roshan_bonus', {duration = BONUS_DURATION})
            print('Roshan #' .. self._iNum .. ' killed, transfering bonus buff!')
        end
    end

	local killedUnit = EntIndexToHScript(tData.entindex_killed)
    if (self._iNum >= 2) then
		if (self._iNum % 2 == 0) then
			self._RoshanXP_killer = self._RoshanXP_killer + 50
		end
		self._RoshanXP = self._RoshanXP + 1000
	end
	if killedUnit:GetUnitName() == "npc_dota_roshan_mega" then
		if not killedUnit:IsIllusion() then
			if hKiller:IsRealHero() then
				hKiller:AddExperience(self._RoshanXP_killer, false, false)
			end
			local getxp = self._RoshanXP
			if getxp > 0 then
				local heroes = GetAllRealHeroes()
				for i = 1, #heroes do
					heroes[i]:AddExperience(getxp / #heroes, false, false)
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_XP, heroes[i], getxp / #heroes, nil)
				end
			end
		end
	end

    self._iNum = self._iNum + 1
    print('Roshan die! The next roshan will be: #' .. self._iNum)
    --give SS to one of the players by turn

    OnRoshDeath(keys)

    -- Random Respawn Time
    self:SetRespawnTime(RandomFloat(MIN_RESPAWN_TIME, MAX_RESPAWN_TIME))
end

-- Thinking!
function CRoshanSystem:Think()
    -- Waiting for respawn...
    if ( self._flRespawnTime > 0 ) then
        self:RespawnThink()
    end

    local hRoshan = self:GetRoshan()

    -- if not hRoshan then
    --     print("CRoshanSystem: is null")
    -- end

    -- We make sure you do not leave your prison boy
    if ( hRoshan and hRoshan:IsAlive() ) then
        self:RoshanThink(hRoshan)
    end
    
end

-- Keeps Roshan inside his prison
function CRoshanSystem:RoshanThink(hRoshan)
    -- local flDistance = CalcDistance(hRoshan:GetAbsOrigin(), self._SpawnPosition)
    local flDistance = (hRoshan:GetAbsOrigin() - self._SpawnPosition):Length2D()

    if ( flDistance > MAX_PRISION_RANGE or flDistance >= 100.0 and not hRoshan:GetAggroTarget() ) then
        -- Go back to your prison!
        hRoshan:MoveToPosition(self._SpawnPosition)
        self._bRotated = false
    elseif ( flDistance <= 80.0 and not hRoshan:GetAggroTarget() and not self._bRotated ) then
        -- Always look straight ahead
        hRoshan:Interrupt()
        hRoshan:SetAngles(self._SpawnAngles.x, self._SpawnAngles.y, self._SpawnAngles.z)
        self._bRotated = true
    end
end

-- Waiting for respawn
function CRoshanSystem:RespawnThink()
    local flTime = GameRules:GetGameTime()

    -- No time yet!
    if ( flTime < self._flRespawnTime ) then
        return
    end

    self:CreateRoshan()
end

-- Set in how many minutes Respawn should be done
function CRoshanSystem:SetRespawnTime(flMinutes)
    local flTime = GameRules:GetGameTime()
    self._flRespawnTime = flTime + (flMinutes * 30)

    print('Roshan respawning in: ' .. self._flRespawnTime .. ' - Current time: ' .. flTime)
end

-- Create Roshan
function CRoshanSystem:CreateRoshan()
    local hRoshan = self:GetRoshan()
    if ( hRoshan ) then
        print('RoshanSystem: It has been requested to create Roshan but it already exists!')
        UTIL_Remove(hRoshan)
    end
    print("RoshanSystem: CreateRoshan")
    print(self._playernr .. " number of player/s")
    -- No more wait...
    self._flRespawnTime = -1.0
    self._ss_drop = false
    -- Roshan creation
    local hRoshan = CreateUnitByName(ROSHAN_CLASS_NAME, self._SpawnPosition, true, nil, nil, DOTA_TEAM_NEUTRALS)
    hRoshan:SetAngles(self._SpawnAngles.x, self._SpawnAngles.y, self._SpawnAngles.z)

    -- Items
    if ( self._iNum >= 0 ) then
        if ( self._iNum <= 13 ) then 
            hRoshan:AddItemByName('item_chest_2') 
        end       
    end    
    -- Second kill
	if ( self._iNum >= 2 ) then
		if ( self._iNum <= 9 ) then
			hRoshan:AddItemByName('item_cheese')     
		end
	end

	if (self._iNum >= 2) then
		if (self._iNum >= 6) then
			hRoshan:AddItemByName("item_aghanims_fragment")
		end
		local count = math.floor(self._iNum / 3)
		
		local heroes = GetAllRealHeroes()
		for i=1, #heroes do
			if heroes[i]:GetUnitName() == "npc_dota_hero_rubick" then
				count = math.floor(self._iNum / 1.5)
				break
			end
		end
		
		for rolls = 0, count - 1 do
			if RandomInt(1, 9 + count) <= 0 + count then
				hRoshan:AddItemByName("item_aghanims_fragment")
			end
		end
	end
    _ss_rosh_drop = false
    if ( self._iNum >= 3 ) then
        local random_nr = math.random(0,100)
        local chance = 18
        if self._playernr == 2 then
            chance = 25
        end
        if self._playernr == 3 then
            chance = 37
        end
        if self._playernr > 3 then
            chance = 45
        end                    
        if random_nr < chance then
            print(random_nr .. " luky nr")
            _ss_rosh_drop = true
            print("SS drop true")
            --hRoshan:AddItemByName('item_imba_ultimate_scepter_synth2')       
        end    
    end
 

    --if ( self._iNum >= 4 ) then
    --    hRoshan:AddItemByName('item_ultimate_scepter_2')        -- 神杖
    --end

    if ( self._iNum >= 5 ) then
        hRoshan:AddItemByName('item_moon_shard')       -- 银月
        if self._playernr > 2 then
            if RollPercentage(10) then
                hRoshan:AddItemByName('item_all_essence')
            end    
        end    
        --hRoshan:AddNewModifier(hRoshan, nil, 'modifier_roshan_bonus', nil)
    end

    if ( self._iNum >= 10 ) then      
        hRoshan:AddItemByName('item_aegis_lua')
    end
    if ( self._iNum >= 9 ) then      
        hRoshan:AddItemByName('item_moon_shard')
    end    
    

    self._roshan_instance = hRoshan

    -- Ready!
    return hRoshan
end

local NotRegister = {
    ["npc_playerhelp"] = true,
    ["npc_dota_target_dummy"] = true,
    ["npc_dummy_unit"] = true,
    ["npc_dota_hero_target_dummy"] = true,
    ["npc_courier_replacement"] = true,
}

-- Create a table to store the players who have received the item
local received_item = {}



--local dropped_items = {}
--local collected_items = {} 
function OnRoshDeath(keys)
    -- Check if the chance to give an item proc
    if _ss_rosh_drop then
      -- Get a list of all players in the game
      local players = {}
      for i = 0, DOTA_MAX_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer(i) then
            if PlayerResource:GetPlayer(i) then
                local hero = PlayerResource:GetSelectedHeroEntity(i)
                if not NotRegister[hero:GetUnitName()] then
                    table.insert(players, i)
                end
            end   
        end
      end

      -- Check if all players have received the item
      local all_received = true
      for _, playerID in pairs(players) do
        if not received_item[playerID] then
          all_received = false
          break
        end
      end

      if all_received then
        -- Reset the table if all players have received the item
        received_item = {}
        print("all players recived")
      end

      -- Shuffle the list of players
      players = shuffle(players)
      -- Give the item to the first player in the list who hasn't received it
      for _, playerID in pairs(players) do
            --if PlayerResource:GetPlayer(playerID) then
                if not received_item[playerID] then
                    -- Give the item to the player
                    DropItemOrInventory(playerID, "item_imba_ultimate_scepter_synth2")
                    local steam_name = PlayerResource:GetPlayerName(playerID)
                    Notifications:TopToAll({text="Player "..steam_name.. ", was his turn for rosh SS(can be shared)", style={color="green"}, duration=5})              
                    received_item[playerID] = true 
                    break
                end
            --end   
        end
    end
end

function shuffle(t)
    local n = #t
    while n > 1 do
        local k = math.random(n)
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
    return t
end


--[[ function CRoshanSystem:OnItemPickedUp(event)
	if not IsServer() then return end
    CollectStoredItem(event.PlayerID)
end


function CollectStoredItem(playerID)
    if dropped_items[playerID] then
        local player = PlayerResource:GetPlayer(playerID)
        local hero = player:GetAssignedHero()
        local success = hero:AddItem(dropped_items[playerID])
        if success then
            Notifications:Top(playerID,{text="You have collected your stored item", style={color="green"}, duration=5})
            collected_items[playerID] = true
            dropped_items[playerID] = nil
        else
            Notifications:Top(playerID,{text="Your inventory is full, please clear some space", style={color="red"}, duration=5})
        end
    end
end
 ]]
