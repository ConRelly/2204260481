-- Run from the addon root with Lua 5.1. Engine coverage is tested in Dota.
local guard = dofile("scripts/vscripts/lib/healing_guard.lua")
assert(loadfile("scripts/vscripts/aohgamemode.lua"))
assert(loadfile("scripts/vscripts/aoh_player_chat.lua"))

local originalPrint = print
local logs, messages, entities = {}, {}, {}
local lookups, nullChecks, maxReads, healthReads = 0, 0, 0, 0
local toolsMode, cheats = false, false
print = function(message) logs[#logs + 1] = message end
-- No game clock, timers, or source/name lookup APIs are provided: the hot path
-- must work without them, even when every single heal is unsafe.
GameRules = { GetGameModeEntity = function()
    return { SetHealingFilter = function(_, callback, context)
        assert(callback == guard.Filter and context == guard)
    end }
end }
Dynamic_Wrap = function(class, method) return class[method] end
EntIndexToHScript = function(index)
    lookups = lookups + 1
    return entities[index]
end
IsInToolsMode = function() return toolsMode end
Cheats = { IsEnabled = function() return cheats end }
Notifications = {
    Top = function(_, _, data) messages[#messages + 1] = data.text end,
    TopToAll = function(_, data) messages[#messages + 1] = data.text end,
}
PlayerResource = {
    IsValidPlayerID = function(_, id) return id == 0 or id == 1 end,
    GetPlayer = function() return {} end,
}

local function Unit(maxHealth, health)
    return {
        maxHealth = maxHealth, health = health,
        IsNull = function(self) nullChecks = nullChecks + 1; return self.removed or false end,
        GetMaxHealth = function(self) maxReads = maxReads + 1; return self.maxHealth end,
        GetHealth = function(self) healthReads = healthReads + 1; return self.health end,
    }
end

local defaultUnit = Unit(1000, 500)
local function Heal(amount, unit, source)
    entities[1] = unit or defaultUnit
    local event = { heal = amount, entindex_target_const = 1,
        entindex_inflictor_const = source, unchanged = "metadata" }
    local accepted = guard:Filter(event)
    assert(event.unchanged == "metadata")
    return accepted, event.heal
end

local assertions = 0
local function Equal(actual, expected)
    assertions = assertions + 1
    assert(actual == expected, "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

guard:Init()
Equal(guard.enabled, true)
Equal(guard.installed, true)
for _, amount in ipairs({0, 0.001, 10, 1000}) do
    local accepted, result = Heal(amount)
    Equal(accepted, true)
    Equal(result, amount)
end
-- Preserve ordinary overheal instead of clipping to missing HP before anti-heal.
Equal(select(2, Heal(1000, Unit(1000, 999))), 1000)
Equal(select(2, Heal(500, Unit(1000, 1000))), 500)
for _, source in ipairs({0, 10, 11}) do
    local accepted, amount = Heal(999999999999, nil, source)
    Equal(accepted, true)
    Equal(amount, 1000)
end
Equal(select(2, Heal(2147483648, Unit(10000000, 1))), 1000000)
Equal(select(2, Heal(1000001, Unit(10000000, 1))), 1000000)
Equal(select(2, Heal(1000000, Unit(10000000, 1))), 1000000)
Equal(select(2, Heal(1000000, Unit(200000000, 99999900))), 100)
Equal(select(1, Heal(1, Unit(200000000, 100000000))), false)
local aboveBoundary = Unit(200000000, 150000000)
Equal(select(1, Heal(1, aboveBoundary)), false)
Equal(aboveBoundary.maxHealth, 200000000) -- Safety limit does not rewrite max HP.
Equal(aboveBoundary.health, 150000000)

local beforeLookups = lookups
for _, amount in ipairs({-1, -196297, -2147483648, math.huge, -math.huge, 0/0, "100"}) do
    local accepted, healed = Heal(amount)
    Equal(accepted, false)
    Equal(healed, 0)
end
Equal(select(1, Heal(nil)), false)
Equal(lookups, beforeLookups) -- Invalid/overflowed input never touches entities.
Equal(select(1, Heal(10, Unit(0, 1))), false)
Equal(select(1, Heal(10, Unit(math.huge, 1))), false)
Equal(select(1, Heal(10, Unit(100, -1))), false)
Equal(select(1, Heal(10, Unit(100, 0/0))), false)
Equal(select(1, Heal(10, Unit(100, math.huge))), false)
local removed = Unit(100, 1)
removed.removed = true
Equal(select(1, Heal(10, removed)), false)
Equal(guard:Filter({heal = 50, entindex_target_const = -1}), false)
Equal(guard:Filter({heal = 50, entindex_target_const = 999}), false)

-- Stress the filter with reused engine-style input. No per-unit state or logs,
-- and exactly one lookup / null check / max-HP read / current-HP read per heal.
local rapidHero = Unit(1000, 100)
entities[1] = rapidHero
local event = { heal = 1e12, entindex_target_const = 1 }
local beforeLogs, beforeMessages = #logs, #messages
local beforeNull, beforeMax, beforeHealth = nullChecks, maxReads, healthReads
beforeLookups = lookups
for _ = 1, 100000 do
    event.heal = 1e12
    assert(guard:Filter(event) and event.heal == 1000)
end
Equal(lookups - beforeLookups, 100000)
Equal(nullChecks - beforeNull, 100000)
Equal(maxReads - beforeMax, 100000)
Equal(healthReads - beforeHealth, 100000)
Equal(#logs, beforeLogs)
Equal(#messages, beforeMessages)
Equal(rapidHero._aoh_healing_guard, nil)
Equal(guard.stats, nil)

-- The test toggle is independent of the per-heal path. Legacy commands removed.
Equal(guard:HandleChatCommand({text = "-unrelated", playerid = 0}), false)
Equal(guard:HandleChatCommand({text = "-hpdebug", playerid = 0}), false)
Equal(guard:HandleChatCommand({text = "-fixhp", playerid = 0}), false)
guard:HandleChatCommand({text = "-healguard off", playerid = 0})
Equal(guard.enabled, true)
toolsMode = true
guard:HandleChatCommand({text = "-healguard off", playerid = 1})
Equal(guard.enabled, true)
guard:HandleChatCommand({text = "-healguard off", playerid = -1})
Equal(guard.enabled, true)
guard:HandleChatCommand({text = "-healguard off", playerid = 0})
Equal(guard.enabled, false)
beforeLookups = lookups
local accepted, unchanged = Heal(1e12)
Equal(accepted, true)
Equal(unchanged, 1e12)
Equal(lookups, beforeLookups)
guard:HandleChatCommand({text = "-healguard", playerid = 0})
Equal(guard.enabled, false)
guard:HandleChatCommand({text = "-healguard on", playerid = 0})
Equal(guard.enabled, true)
Equal(select(2, Heal(1e12)), 1000)
toolsMode, cheats = false, true
guard:HandleChatCommand({text = "-healguard off", playerid = 0})
Equal(guard.enabled, false)
guard:Init()
Equal(guard.enabled, true) -- Installation always starts protected.

print = originalPrint
print("Healing guard: " .. assertions .. " assertions + 100000 repeated heals passed (" .. _VERSION .. ").")
