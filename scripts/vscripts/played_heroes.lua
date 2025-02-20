LinkLuaModifier("modifier_bottom_50", "modifiers/modifier_bottom_50.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bottom_20", "modifiers/modifier_bottom_20.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bottom_10", "modifiers/modifier_bottom_10.lua", LUA_MODIFIER_MOTION_NONE)

-- The URL of the server that provides the hero play counts.
local HERO_PLAY_COUNTS_URL = "https://conrelly.com/played_heroes.txt"

-- A table that maps hero names to modifier names based on their play counts.
local hero_modifiers = {}

-- Sends a request to the server to get the hero play counts.
--[[ function GetLeastPlayedHeroes()
    local retries = 4
    local delay = 50 / (retries + 1)
    local function sendRequest()
        local request = CreateHTTPRequestScriptVM("GET", HERO_PLAY_COUNTS_URL)
        request:SetHTTPRequestAbsoluteTimeoutMS(30000)
        request:Send(function(response)
            if response.StatusCode == 200 then
                local hero_play_counts = {}
                local hero_play_count_strs = string.gmatch(response.Body, "(.-):(%d+)\n?")
                for hero_name, play_count in hero_play_count_strs do
                    hero_play_counts[hero_name] = tonumber(play_count)
                end
                                      
                -- Calculate the ranks of the hero play counts.
                local hero_play_count_ranks = {}
                local hero_plays = {}
                for hero_name, play_count in pairs(hero_play_counts) do
                    hero_plays[#hero_plays+1] = play_count
                end
                table.sort(hero_plays)
                local rank = 1
                local last_play_count = -1
                for i, play_count in ipairs(hero_plays) do
                    if play_count ~= last_play_count then
                        rank = i
                        last_play_count = play_count
                    end
                    for hero_name, count in pairs(hero_play_counts) do
                        if count == play_count then
                            hero_play_count_ranks[hero_name] = rank
                        end
                    end
                end

                -- Map hero names to modifier names based on their ranks.
                local hero_names = {}
                for hero_name, play_count in pairs(hero_play_counts) do
                    hero_names[#hero_names+1] = hero_name
                end
                table.sort(hero_names, function(a, b) return hero_play_counts[a] < hero_play_counts[b] end)
                for i, hero_name in ipairs(hero_names) do
                    if hero_play_count_ranks[hero_name] ~= nil then
                        print(i .. ": " .. hero_name .. " (" .. hero_play_counts[hero_name] .. " plays)" .. "Rank: " ..hero_play_count_ranks[hero_name])
                        local rank = hero_play_count_ranks[hero_name]
                        if rank <= 50 then
                            if rank <= 10 then
                                hero_modifiers[hero_name] = "modifier_bottom_10"
                            elseif rank <= 20 then
                                hero_modifiers[hero_name] = "modifier_bottom_20"
                            else
                                hero_modifiers[hero_name] = "modifier_bottom_50"
                            end
                        end
                    end
                end
                print("Sucess to get hero play counts, Status: " .. response.StatusCode)
            else
                print("Failed to get hero play counts: " .. response.StatusCode)
                retries = retries - 1
                if retries > 0 then
                    print("Retrying in " .. delay .. " seconds...")
                    Timers:CreateTimer(delay, function()
                        sendRequest()
                    end)
                end
                delay = 80 / (retries + 1)
            end
        end)
    end
    sendRequest()
end ]]

--new test
-- Sends a request to the server to get the hero play counts.
function GetLeastPlayedHeroes()
    local retries = 4
    local delay = 50 / (retries + 1)
    local function sendRequest()
        local request = CreateHTTPRequestScriptVM("GET", HERO_PLAY_COUNTS_URL)
        request:SetHTTPRequestAbsoluteTimeoutMS(30000)
        request:Send(function(response)
            if response.StatusCode == 200 then
                local hero_play_counts = {}
                local hero_play_count_strs = string.gmatch(response.Body, "(.-):(%d+)\n?")
                for hero_name, play_count in hero_play_count_strs do
                    hero_play_counts[hero_name] = tonumber(play_count)
                end
                                      
                -- Calculate the ranks of the hero play counts.
                local hero_play_count_ranks = {}
                local hero_plays = {}
                for hero_name, play_count in pairs(hero_play_counts) do
                    hero_plays[#hero_plays+1] = play_count
                end
                table.sort(hero_plays)
                local rank = 1
                local last_play_count = -1
                for i, play_count in ipairs(hero_plays) do
                    if play_count ~= last_play_count then
                        rank = i
                        last_play_count = play_count
                    end
                    for hero_name, count in pairs(hero_play_counts) do
                        if count == play_count then
                            hero_play_count_ranks[hero_name] = rank
                        end
                    end
                end

                -- Map hero names to modifier names based on their ranks.
                -- We'll introduce counters for each tier to track the number of heroes assigned.
                local counters = {top10 = 0, top20 = 0, top50 = 0}                
                local hero_names = {}
                for hero_name, play_count in pairs(hero_play_counts) do
                    hero_names[#hero_names+1] = hero_name
                end
                table.sort(hero_names, function(a, b) return hero_play_counts[a] < hero_play_counts[b] end)                
                for i, hero_name in ipairs(hero_names) do
                    if hero_play_count_ranks[hero_name] ~= nil then
                        --print(i .. ": " .. hero_name .. " (" .. hero_play_counts[hero_name] .. " plays)" .. "Rank: " .. hero_play_count_ranks[hero_name])
                        local rank = hero_play_count_ranks[hero_name]
                        local modifier = ""
                        -- Check if the hero qualifies for top 50.
                        if rank <= 50 and counters.top50 < 60 then
                            -- Within top 10.
                            if rank <= 10 and counters.top10 < 12 then
                                hero_modifiers[hero_name] = "modifier_bottom_10"
                                counters.top10 = counters.top10 + 1
                                modifier = " (modifier_bottom_10)"
                            -- If exceeds top 10 but within top 20.
                            elseif rank <= 20 and counters.top20 < 25 then
                                hero_modifiers[hero_name] = "modifier_bottom_20"
                                counters.top20 = counters.top20 + 1
                                modifier = " (modifier_bottom_20)"
                            -- If exceeds top 20 but qualifies for top 50.
                            elseif rank > 20 then
                                hero_modifiers[hero_name] = "modifier_bottom_50"
                                modifier = " (modifier_bottom_50)"
                            end
                            counters.top50 = counters.top50 + 1 -- Increment top 50 counter regardless of specific tier.
                            --print(i .. ": " .. hero_name .. " (" .. hero_play_counts[hero_name] .. " plays)" .. " Rank: " .. rank .. modifier)
                        end
                    end
                end
                print("Sucess to get hero play counts, Status: " .. response.StatusCode)
            else
                print("Failed to get hero play counts: " .. response.StatusCode)
                retries = retries - 1
                if retries > 0 then
                    print("Retrying in " .. delay .. " seconds...")
                    Timers:CreateTimer(delay, function()
                        sendRequest()
                    end)
                end
                delay = 80 / (retries + 1)
            end
        end)
    end
    sendRequest()
end

--



-- Checks the hero's ranking and adds the appropriate modifier if necessary.
local delays = 0
function check_hero_ranking(unit)
    local hero_name = unit:GetUnitName()
    if next(hero_modifiers) == nil then
        -- If the hero_modifiers table is empty, try fetching the hero play counts again.
        Timers:CreateTimer(delays, function()
            if next(hero_modifiers) == nil then
                GetLeastPlayedHeroes()
            end 
        end)
        delays = delays + 2
    else
        local modifier_name = hero_modifiers[hero_name]
        if modifier_name and not unit:HasModifier(modifier_name) then
            unit:AddNewModifier(unit, nil, modifier_name, {})
            
        elseif IsSunday() then
            print("Sunday")
            if CheckModifiers(unit) then
                unit:AddNewModifier(unit, nil, "modifier_bottom_50", {}) 
            end
        end
    end
end


local modifiers = {
    "modifier_bottom_10",
    "modifier_bottom_20",
    "modifier_bottom_50"
}

function CheckModifiers(unit)
    for _, modifierName in pairs(modifiers) do
        if unit:HasModifier(modifierName) then
            return false -- The hero has one of the modifiers, so return false
        end
    end

    return true -- The hero doesn't have any of the modifiers, so return true
end


--adjust for leap year
--holiday included
function IsSunday()
    if _G.IsSunday_1 and _G.IsSunday_1_messagge then
        print("IsSunday_1 is true")
        return true
    end   

    local date = StrSplit(GetSystemDate(), '/')
    print("Date: " .. date[1] .. "/" .. date[2] .. "/" .. date[3]) -- Print the date
    local y = tonumber(date[3])
    local m = tonumber(date[1])
    local d = tonumber(date[2])

    -- Check if the date is between December 10 and January 2
    if (m == 12 and d >= 10) or (m == 1 and d <= 2) then
        print("Holiday bonus active: Treating as Sunday")
        Notifications:TopToAll({text= "Holiday bonus active: Treating as Sunday(all heroes get top 50 bonus and 1 enchanter)",style={color="green"}, duration=10})
        _G.IsSunday_1 = true
        _G.IsSunday_1_messagge = true
        return true
    end
    if (m == 2 and d >= 14) then
        print("Second half of Feb bonus active: Treating as Sunday")
        Notifications:TopToAll({text= "Second Half of February: Treating as Sunday(all heroes get top 50 bonus and 1 enchanter)",style={color="green"}, duration=10})
        _G.IsSunday_1 = true
        _G.IsSunday_1_messagge = true
        return true
    end

    -- Adjust for leap year
    if m == 1 or m == 2 then
        m = m + 12
        y = y - 1
    end

    local c = math.floor(y / 100)
    y = y % 100

    local w = y + math.floor(y / 4) + math.floor(c / 4) - 2 * c + math.floor(26 * (m + 1) / 10) + d - 1
    local wday = w % 7
    print("wday is: " .. wday)
    if wday == 0 then
        wday = 7
        _G.IsSunday_1 = true
        print("Sunday detected")
    end
    return wday == 7
end



-- Call GetLeastPlayedHeroes to start fetching the hero play counts.
GetLeastPlayedHeroes()

