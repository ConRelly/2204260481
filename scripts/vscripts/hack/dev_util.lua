
function print_all_hero_point( )
    CallAllHeroFunc(function(hero)
        local p_id = hero:GetPlayerID()
        local p = hero:GetAbsOrigin()
        local s = string.format( "Player - %d : X(%f) Y(%f) Z(%f)", p_id, p.x, p.y, p.z )
        print(s)
    end)
end

function print_hero_all_modifiers( )
    CallAllHeroFunc(function(hero)
        local p_id = hero:GetPlayerID()
        local ms = hero:FindAllModifiers()
        print("Player - " .. p_id)
        for _, modifier in pairs(ms) do
            print("    " .. modifier:GetName())
            local statck_count = hero:GetModifierStackCount(modifier:GetName(), nil)
            local duration = modifier:GetDuration()
            local s = string.format( "Statck(%d) Duration(%d)", statck_count, duration)
            print("    " .. s)
        end
    end)
end

function print_hero_base_attack_time( )
  CallAllHeroFunc(function(hero)
    local p_id = hero:GetPlayerID()
    print("Player - " .. p_id)
    print('    base_attack_time: ', hero:GetBaseAttackTime())
  end)
end

function CallAllHeroFunc( func )
    local player_list = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    for i = 1, player_list do
        local player = PlayerInstanceFromIndex(i)
        if player ~= nil then 
            local hero = PlayerInstanceFromIndex(i):GetAssignedHero()
            if hero ~= nil then 
                if type(func) == 'function' then
                    func(hero)
                end
            end
        end
    end
end


function PrintTable(t, indent, done)
    --print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end
  
    done = done or {}
    done[t] = true
    indent = indent or 0
  
    local l = {}
    for k, v in pairs(t) do
      table.insert(l, k)
    end
  
    table.sort(l)
    for k, v in ipairs(l) do
      -- Ignore FDesc
      if v ~= 'FDesc' then
        local value = t[v]
  
        if type(value) == "table" and not done[value] then
          done [value] = true
          print(string.rep ("\t", indent)..tostring(v)..":")
          PrintTable (value, indent + 2, done)
        elseif type(value) == "userdata" and not done[value] then
          done [value] = true
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
          PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
        else
          if t.FDesc and t.FDesc[v] then
            print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
          else
            print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
          end
        end
      end
    end
end


-- 创建傀儡目标
function CreateUnit_DummyTarget(point, team, playerID)

  local hDummy = CreateUnitByName( "npc_dota_hero_target_dummy", point, true, nil, nil, team )
  hDummy:SetAbilityPoints( 0 )
  if playerID then
    hDummy:SetControllableByPlayer( playerID, false )
  end
  hDummy:Hold()
  hDummy:SetIdleAcquire( false )
  hDummy:SetAcquisitionRange( 0 )

  return hDummy
end

function StrSplit (inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end


-- 是否假日
function IsHoliday()
  -- print(GetSystemDate())  --05/15/20
  -- print(GetSystemTime())  --13:23:07
  local date = StrSplit(GetSystemDate(), '/')
  local c = 20
  local y = tonumber(date[3])
  local m = tonumber(date[1])
  local d = tonumber(date[2])

  local w=y+ (y/4)+ (c/4)-2*c+(26*(m+1)/10)+d-1
  local wday = w / 7
  if wday == 0 then
    wday = 7 
  end
  --print('wday: ' .. tostring(wday))
  --local time = os.date("*t")
  -- return wday == 6 or wday == 7
  return false
end


function IsLucky()
  local time = StrSplit(GetSystemTime(), ':')
  return tonumber(time[3]) % 2 == 1
end


--[[
    A quick function to create popups.
    Example:
    create_popup({
        target = target,
        value = value,
        color = Vector(255, 20, 147),
        type = "spell_custom"
	}) 
	伤害类型的颜色：
		物理：Vector(174, 47, 40)
		魔法：Vector(91, 147, 209)
		纯粹：Vector(216, 174, 83)
	spell_custom: 
		block | crit | damage | evade | gold | heal | mana_add | mana_loss | miss | poison | spell | xp
	Color:	
		red 	={255,0,0},
		orange	={255,127,0},
		yellow	={255,255,0},
		green 	={0,255,0},
		blue 	={0,0,255},
		indigo 	={0,255,255},
		purple 	={255,0,255},
]]
function create_popup(data)
    local target = data.target
    local value = math.floor(data.value)

    local type = data.type or "miss"
    local color = data.color or Vector(255, 255, 255)
    local duration = data.duration or 1.0

    local size = string.len(value)

    local pre = data.pre or nil
    if pre ~= nil then
        size = size + 1
    end

    local pos = data.pos or nil
    if pos ~= nil then
        size = size + 1
    end

    local particle_path = "particles/msg_fx/msg_" .. type .. ".vpcf"
    local particle = ParticleManager:CreateParticle(particle_path, PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 1, Vector(pre, value, pos))
    ParticleManager:SetParticleControl(particle, 2, Vector(duration, size, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
	ParticleManager:ReleaseParticleIndex(particle)
end

function create_popup_by_damage_type(data, ability)
    local damage_type = ability:GetAbilityDamageType()
    if damage_type == DAMAGE_TYPE_PHYSICAL then
        data.color = Vector(174, 47, 40)
    elseif damage_type == DAMAGE_TYPE_MAGICAL then
        data.color = Vector(91, 147, 209)
    elseif damage_type == DAMAGE_TYPE_PURE then
        data.color = Vector(216, 174, 83)
    else
        data.color = Vector(255, 255, 255)
    end
    create_popup(data)
end

-- 是否制作者的英雄
function IsMakerHero(hero)
  if hero and IsValidEntity(hero) and hero:IsHero() then
    local playerID = hero:GetPlayerID()
    local steamID = PlayerResource:GetSteamAccountID(playerID)
    if steamID == 30361752 then --333664846 then -- or 76561198293930574 --76561197990627480
      return true
    end
  end
  return false
end

function IsStalkerList(hero)
  if IsServer() then
    if hero and IsValidEntity(hero) and hero:IsHero() then
      local playerID = hero:GetPlayerID()
      local steamID = tostring(PlayerResource:GetSteamID(playerID))   --76561197990627480
      local list = {
        "76561198125830286", --kuma
        "76561197990627480", --nepot
        "76561197998245437", --nepot  
        "76561198202813685", --nepot
      }    
      for k, v in pairs(list) do
        if tostring(v) == steamID then
          return true
        end
      end
    end
    return false
  end 
end


-- 创建幻象时，不能复制的物品
function IsIllusionExcludeItem(item)
  local items = {
    "item_aegis", -- 不朽之守护
  }
  if item then
    for _,v in ipairs(items) do
      if item:GetName() == v then
        return true
      end
    end
  end
  return false
end

-- 计算两个实体之间的距离
function CalcDistanceBetween( target, caster)
  local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
  local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
  return (target_loc - caster_loc):Length2D()
end


--  出生时学习技能
function LearnAbilityOnSpawn( npc)
  if IsValidEntity(npc) then
    for i=0,30 do
      local ability = npc:GetAbilityByIndex(i)
      if ability then
        local kv = ability:GetAbilityKeyValues()
        for k,v in pairs(kv) do -- trawl through keyvalues
            if k == "LearnOnSpawn" then
              local level = tonumber(v)
              if ability:GetLevel() < level then
                --print("learn ability: " .. ability:GetName())
                ability:SetLevel(level)
                ability:SetHidden(false)
              end
            end
        end
      end
    end
  end
end

