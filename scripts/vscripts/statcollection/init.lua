local statInfo = LoadKeyValues('scripts/vscripts/statcollection/settings.kv')
if not statInfo then
    print("Stat Collection: Critical Error, no settings.kv file found")
    return
end
print("testingstats 5")
require("statcollection/schema")
require('statcollection/lib/statcollection')
require('statcollection/staging')
require('statcollection/lib/utilities')

local COLLECT_STATS = not Convars:GetBool('developer')
local TESTING = tobool(statInfo.TESTING)
local MIN_PLAYERS = tonumber(statInfo.MIN_PLAYERS)

if COLLECT_STATS or TESTING then
    print("testingstats 6")
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()

        if state and state >= 1 and not statCollection.doneInit then

            --if PlayerResource:GetPlayerCount() >= MIN_PLAYERS or TESTING then
                -- Init stat collection
                --statCollection:init()
                --customSchema:init()
                --print("pass 27 init")
            --end
        end
    end, nil)
end