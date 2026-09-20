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

local FALLBACK_HERO_PLAY_COUNTS = [[
npc_dota_hero_dawnbreaker:36
npc_dota_hero_bloodseeker:47
npc_dota_hero_muerta:119
npc_dota_hero_pugna:30
npc_dota_hero_ancient_apparition:17
npc_dota_hero_dazzle:145
npc_dota_hero_spectre:113
npc_dota_hero_nyx_assassin:32
npc_dota_hero_lycan:25
npc_dota_hero_mirana:76
npc_dota_hero_kunkka:25
npc_dota_hero_visage:7
npc_dota_hero_silencer:82
npc_dota_hero_primal_beast:29
npc_dota_hero_undying:54
npc_dota_hero_meepo:93
npc_dota_hero_death_prophet:45
npc_dota_hero_lich:28
npc_dota_hero_rattletrap:50
npc_dota_hero_troll_warlord:110
npc_dota_hero_medusa:424
npc_dota_hero_techies:66
npc_dota_hero_phantom_lancer:85
npc_dota_hero_omniknight:38
npc_dota_hero_sand_king:26
npc_dota_hero_invoker:161
npc_dota_hero_obsidian_destroyer:66
npc_dota_hero_disruptor:14
npc_dota_hero_venomancer:41
npc_dota_hero_axe:174
npc_dota_hero_bristleback:172
npc_dota_hero_legion_commander:104
npc_dota_hero_warlock:13
npc_dota_hero_night_stalker:17
npc_dota_hero_antimage:146
npc_dota_hero_clinkz:56
npc_dota_hero_necrolyte:164
npc_dota_hero_earth_spirit:18
npc_dota_hero_juggernaut:298
npc_dota_hero_skeleton_king:97
npc_dota_hero_marci:197
npc_dota_hero_treant:27
npc_dota_hero_beastmaster:46
npc_dota_hero_hoodwink:22
npc_dota_hero_nevermore:180
npc_dota_hero_tiny:98
npc_dota_hero_razor:68
npc_dota_hero_faceless_void:162
npc_dota_hero_storm_spirit:45
npc_dota_hero_rubick:22
npc_dota_hero_magnataur:33
npc_dota_hero_abyssal_underlord:24
npc_dota_hero_oracle:48
npc_dota_hero_grimstroke:6
npc_dota_hero_morphling:133
npc_dota_hero_winter_wyvern:48
npc_dota_hero_enchantress:33
npc_dota_hero_puck:25
npc_dota_hero_spirit_breaker:33
npc_dota_hero_arc_warden:38
npc_dota_hero_lone_druid:30
npc_dota_hero_brewmaster:16
npc_dota_hero_gyrocopter:74
npc_dota_hero_lina:40
npc_dota_hero_tinker:66
npc_dota_hero_earthshaker:74
npc_dota_hero_doom_bringer:99
npc_dota_hero_riki:44
npc_dota_hero_centaur:101
npc_dota_hero_mars:35
npc_dota_hero_tidehunter:73
npc_dota_hero_bane:10
npc_dota_hero_viper:74
npc_dota_hero_luna:126
npc_dota_hero_slark:129
npc_dota_hero_huskar:208
npc_dota_hero_pudge:403
npc_dota_hero_phantom_assassin:392
npc_dota_hero_bounty_hunter:31
npc_dota_hero_queenofpain:120
npc_dota_hero_alchemist:224
npc_dota_hero_enigma:29
npc_dota_hero_jakiro:54
npc_dota_hero_shadow_demon:8
npc_dota_hero_ursa:314
npc_dota_hero_tusk:17
npc_dota_hero_weaver:57
npc_dota_hero_void_spirit:163
npc_dota_hero_batrider:27
npc_dota_hero_naga_siren:23
npc_dota_hero_crystal_maiden:48
npc_dota_hero_phoenix:14
npc_dota_hero_witch_doctor:21
npc_dota_hero_ember_spirit:58
npc_dota_hero_snapfire:40
npc_dota_hero_leshrac:125
npc_dota_hero_abaddon:68
npc_dota_hero_ogre_magi:84
npc_dota_hero_windrunner:192
npc_dota_hero_pangolier:55
npc_dota_hero_vengefulspirit:58
npc_dota_hero_skywrath_mage:41
npc_dota_hero_dark_willow:27
npc_dota_hero_lion:106
npc_dota_hero_furion:18
npc_dota_hero_broodmother:22
npc_dota_hero_shadow_shaman:11
npc_dota_hero_terrorblade:25
npc_dota_hero_wisp:49
npc_dota_hero_slardar:60
npc_dota_hero_templar_assassin:72
npc_dota_hero_elder_titan:15
npc_dota_hero_dark_seer:25
npc_dota_hero_dragon_knight:80
npc_dota_hero_keeper_of_the_light:43
npc_dota_hero_zuus:121
npc_dota_hero_shredder:35
npc_dota_hero_chen:21
npc_dota_hero_chaos_knight:116
npc_dota_hero_sven:105
npc_dota_hero_life_stealer:264
npc_dota_hero_sniper:792
npc_dota_hero_drow_ranger:376
npc_dota_hero_monkey_king:65
npc_dota_hero_kez:127
]]

function ParseAndApplyHeroPlayCounts(raw_body)
    if not raw_body or type(raw_body) ~= "string" then return false end
    local hero_play_counts = {}
    local hero_play_count_strs = string.gmatch(raw_body, "(.-):(%d+)\n?")
    for hero_name, play_count in hero_play_count_strs do
        hero_play_counts[hero_name] = tonumber(play_count)
    end
    
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

    local counters = {top10 = 0, top20 = 0, top50 = 0}                
    local hero_names = {}
    for hero_name, play_count in pairs(hero_play_counts) do
        hero_names[#hero_names+1] = hero_name
    end
    table.sort(hero_names, function(a, b) return hero_play_counts[a] < hero_play_counts[b] end)                
    for i, hero_name in ipairs(hero_names) do
        if hero_play_count_ranks[hero_name] ~= nil then
            local rank = hero_play_count_ranks[hero_name]
            if rank <= 50 and counters.top50 < 60 then
                if rank <= 10 and counters.top10 < 12 then
                    hero_modifiers[hero_name] = "modifier_bottom_10"
                    counters.top10 = counters.top10 + 1
                elseif rank <= 20 and counters.top20 < 25 then
                    hero_modifiers[hero_name] = "modifier_bottom_20"
                    counters.top20 = counters.top20 + 1
                elseif rank > 20 then
                    hero_modifiers[hero_name] = "modifier_bottom_50"
                end
                counters.top50 = counters.top50 + 1
            end
        end
    end
    return true
end

-- Immediately populate rankings with the fallback list so heroes always have bonuses
ParseAndApplyHeroPlayCounts(FALLBACK_HERO_PLAY_COUNTS)

local function RunSingleHttpTest(testName, url, headers)
    print("==================================================")
    print("[HTTP TEST] Starting: " .. testName)
    print("[HTTP TEST] URL: " .. url)
    
    if not CreateHTTPRequestScriptVM then
        print("[HTTP TEST] FAILED: CreateHTTPRequestScriptVM does not exist in _G!")
        print("==================================================")
        return
    end

    local request = CreateHTTPRequestScriptVM("GET", url)
    if not request then
        print("[HTTP TEST] FAILED: CreateHTTPRequestScriptVM returned nil for URL: " .. url)
        print("==================================================")
        return
    end

    if headers then
        for k, v in pairs(headers) do
            local ok, err = pcall(function()
                request:SetHTTPRequestHeaderValue(k, v)
            end)
            if not ok then
                print("[HTTP TEST] Warning: SetHTTPRequestHeaderValue(" .. k .. ") failed: " .. tostring(err))
            end
        end
    end

    request:SetHTTPRequestAbsoluteTimeoutMS(15000)

    local sendOk, sendErr = pcall(function()
        request:Send(function(response)
            print("--------------------------------------------------")
            print("[HTTP TEST RESULT] " .. testName)
            if not response then
                print("[HTTP TEST RESULT] Callback fired, but 'response' is nil!")
            else
                local status = response.StatusCode
                local body = response.Body
                local bodyLen = body and string.len(body) or 0
                print("[HTTP TEST RESULT] StatusCode: " .. tostring(status))
                print("[HTTP TEST RESULT] Body length: " .. tostring(bodyLen) .. " bytes")
                
                if status == 200 and bodyLen > 0 then
                    print("[HTTP TEST RESULT] >>> SUCCESS! Connected and received data! <<<")
                    if string.find(url, "played_heroes") then
                        ParseAndApplyHeroPlayCounts(body)
                        print("[HTTP TEST RESULT] Successfully applied live played_heroes data!")
                    else
                        local preview = string.sub(body, 1, 80)
                        print("[HTTP TEST RESULT] Response preview: " .. preview)
                    end
                else
                    print("[HTTP TEST RESULT] >>> FAILED (Status: " .. tostring(status) .. ") <<<")
                    if body and string.len(body) > 0 then
                        local preview = string.sub(body, 1, 150)
                        print("[HTTP TEST RESULT] Response snippet: " .. preview)
                    end
                end
            end
            print("--------------------------------------------------")
        end)
    end)

    if not sendOk then
        print("[HTTP TEST] FAILED during request:Send(): " .. tostring(sendErr))
    else
        print("[HTTP TEST] Request sent, waiting for response callback...")
    end
    print("==================================================")
end

function RunAllHttpTests()
    print("==================================================")
    print("[HTTP DIAGNOSTICS] Checking HTTP API availability in Dota engine:")
    print("[HTTP DIAGNOSTICS] CreateHTTPRequestScriptVM exists: " .. tostring(CreateHTTPRequestScriptVM ~= nil))
    print("[HTTP DIAGNOSTICS] CreateHTTPRequest exists: " .. tostring(_G.CreateHTTPRequest ~= nil))
    print("==================================================")

    -- Test 1: Standard HTTPS with User-Agent and Accept headers
    Timers:CreateTimer(1.0, function()
        RunSingleHttpTest("Test 1 (HTTPS + Browser Headers)", HERO_PLAY_COUNTS_URL, {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
            ["Accept"] = "text/plain, */*"
        })
    end)

    -- Test 2: Raw HTTPS without any custom headers
    Timers:CreateTimer(4.0, function()
        RunSingleHttpTest("Test 2 (HTTPS Raw / Default Headers)", HERO_PLAY_COUNTS_URL, nil)
    end)

    -- Test 3: Plain HTTP (No SSL/TLS) with User-Agent
    Timers:CreateTimer(7.0, function()
        RunSingleHttpTest("Test 3 (Plain HTTP / No SSL)", "http://conrelly.com/played_heroes.txt", {
            ["User-Agent"] = "Mozilla/5.0"
        })
    end)

    -- Test 4: HTTPS with Cache-Buster query param
    Timers:CreateTimer(10.0, function()
        local bustUrl = HERO_PLAY_COUNTS_URL .. "?nocache=" .. tostring(RandomInt(10000, 99999))
        RunSingleHttpTest("Test 4 (HTTPS Cache-Buster)", bustUrl, {
            ["User-Agent"] = "Mozilla/5.0"
        })
    end)

    -- Test 5: Neutral external API (GitHub Zen API) to test if ANY outbound HTTP works
    Timers:CreateTimer(13.0, function()
        RunSingleHttpTest("Test 5 (Neutral Public API - GitHub Zen)", "https://api.github.com/zen", {
            ["User-Agent"] = "Mozilla/5.0"
        })
    end)
end

function GetLeastPlayedHeroes()
    RunAllHttpTests()
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



-- Delay fetching hero play counts until the game starts and Timers is ready
if Timers and Timers.CreateTimer then
    Timers:CreateTimer(5, function()
        GetLeastPlayedHeroes()
    end)
else
    -- Fallback in case Timers isn't available yet
    ListenToGameEvent("game_rules_state_change", function()
        if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME then
            GetLeastPlayedHeroes()
        end
    end, nil)
end

