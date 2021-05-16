--[[
A basic and simple sound manipulation library
Created to make manipulating looping sounds easier or to play a sound without a location on a single client

Requirements:
  Add require('libraries/sounds')  before use
  Add sounds.js to your panorama/scripts folders and include it in custom_ui_manifest.xml

Use:
  To start/play a sound for a player, simply call
    Sounds:CreateSound(playerID, soundName)
    eg: Sounds:CreateSound(1, "General.Coins")

  To stop a looping sound or stop a sound early call
    Sounds:RemoveSound(playerID, soundName)
    eg: Sounds:RemoveSound(1, "General.Coins")
]]

if not Sounds then
  Sounds = class({})

  --SOUNDS_TABLE = {}
end

function Sounds:CreateSound(playerID, soundName)
  print("Sounds:CreateSound(", playerID, soundName, ")")
  --[[if not SOUNDS_TABLE[playerID] then
    SOUNDS_TABLE[playerID] = {}
  end

  --Remove the previous sound of the same name from index and game
  if SOUNDS_TABLE[playerID][soundName] then
    Sounds:RemoveSound(playerID, soundName)
  end

  SOUNDS_TABLE[playerID][soundName] = true]]
  local player = PlayerResource:GetPlayer(playerID)
  if player then
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "emit_sound", {pID = playerID, sound = soundName})
  else
    print("Unable to CreateSound, no player found with playerID ", playerID)
  end
end

function Sounds:RemoveSound(playerID, soundName)
  --print("Sounds:RemoveSound(", playerID, soundName, ")")
  --[[if not SOUNDS_TABLE[playerID] then
    SOUNDS_TABLE[playerID] = {}
  end

  if not SOUNDS_TABLE[playerID][soundName] then return end

  print("SOUNDS_TABLE[playerID][soundName] = ", SOUNDS_TABLE[playerID][soundName])]]	  
  local player = PlayerResource:GetPlayer(playerID)
  if player then
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "stop_sound", {pID = playerID, sound = soundName})
  else
    print("Unable to RemoveSound, no player found with playerID ", playerID)
  end

  SOUNDS_TABLE[playerID][soundName] = nil
end

function Sounds:CreateGlobalSound(soundName)
    for i=0,9 do
--        if PlayerResource:GetSelectedHeroEntity(i) then
            Sounds:CreateSound(i, soundName)
--        end
    end
end

function Sounds:RemoveGlobalSound(soundName)
    for i=0,9 do
--        if PlayerResource:GetSelectedHeroEntity(i) then
            Sounds:RemoveSound(i, soundName)
--        end
    end
end
