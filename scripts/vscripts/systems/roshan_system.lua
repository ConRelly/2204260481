--[[
    源文件：https://github.com/balancedenergy/game/scripts/vscripts/systems/roshan_system.lua
]]

LinkLuaModifier('modifier_roshan_bonus', 'modifiers/modifier_roshan_bonus', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_roshan_bonus_burn', 'modifiers/modifier_roshan_bonus_burn', LUA_MODIFIER_MOTION_NONE)

-- Manage Game Mode Roshan
if CRoshanSystem == nil then
	CRoshanSystem = class({})
end

-- Configuration
local MAX_PRISION_RANGE = 1000                      -- 可以被攻击的范围
local BONUS_DURATION = 120
local MIN_RESPAWN_TIME = 5                        -- 最短刷新时间
local MAX_RESPAWN_TIME = 6                        -- 最长刷新时间
local ROSHAN_CLASS_NAME = "npc_dota_roshan_mega"    -- Roshan 类名
local ROSHAN_SPAWNER = "roshan_spawner"             -- 出生定位点

if IsInToolsMode() then
    MIN_RESPAWN_TIME = 1.0
    MAX_RESPAWN_TIME = 1.0
end

-- Indicates the time Respawn should be done
CRoshanSystem._flRespawnTime = -1.0

-- Indicates that Roshan is currently
CRoshanSystem._iNum = 1

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

    print("RoshanSystem: Init...")

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
        if ( hKiller:IsRealHero()  ) then
            hKiller:AddNewModifier(hKiller, nil, 'modifier_roshan_bonus', {duration = BONUS_DURATION})
            print('Roshan #' .. self._iNum .. ' killed, transfering bonus buff!')
        end
    end

    self._iNum = self._iNum + 1
    print('Roshan die! The next roshan will be: #' .. self._iNum)

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
    self._flRespawnTime = flTime + (flMinutes * 60)

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

    -- No more wait...
    self._flRespawnTime = -1.0

    -- Roshan creation
    local hRoshan = CreateUnitByName(ROSHAN_CLASS_NAME, self._SpawnPosition, true, nil, nil, DOTA_TEAM_NEUTRALS)
    hRoshan:SetAngles(self._SpawnAngles.x, self._SpawnAngles.y, self._SpawnAngles.z)

    -- Items
    hRoshan:AddItemByName('item_aegis')         -- 复活盾

    -- Second kill
    if ( self._iNum >= 2 ) then
        hRoshan:AddItemByName('item_cheese')
        hRoshan:AddNewModifier(hRoshan, nil, 'modifier_roshan_bonus', nil)
    end

    if ( self._iNum >= 3 ) then
        hRoshan:AddItemByName('item_refresher_shard')        -- 刷新碎片 
    end

    if ( self._iNum >= 4 ) then
        hRoshan:AddItemByName('item_ultimate_scepter_2')        -- 神杖
    end

    if ( self._iNum >= 5 ) then
        hRoshan:AddItemByName('item_moon_shard')        -- 银月
    end

    self._roshan_instance = hRoshan

    -- Ready!
    return hRoshan
end