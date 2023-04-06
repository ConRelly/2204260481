LinkLuaModifier("modifier_bottom_50", "modifiers/modifier_bottom_50.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bottom_20", "modifiers/modifier_bottom_20.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bottom_10", "modifiers/modifier_bottom_10.lua", LUA_MODIFIER_MOTION_NONE)

local hero_modifiers = {}

function GetLeastPlayedHeroes()
    local request = CreateHTTPRequestScriptVM("GET", "https://conrelly.000webhostapp.com/played_heroes.txt")
    request:SetHTTPRequestAbsoluteTimeoutMS(2000)
    request:Send(function(response)
        if response.StatusCode == 200 then
            local hero_play_counts = {}
            local hero_play_count_strs = string.gmatch(response.Body, "(.-):(%d+)\n")
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
            local hero_names = {}
            for hero_name, play_count in pairs(hero_play_counts) do
                hero_names[#hero_names+1] = hero_name
            end
            table.sort(hero_names, function(a, b) return hero_play_counts[a] < hero_play_counts[b] end)
            --print("Sorted hero names:")
            for i, hero_name in ipairs(hero_names) do
                if hero_play_count_ranks[hero_name] ~= nil then
                    --print(i .. ": " .. hero_name .. " (" .. hero_play_counts[hero_name] .. " plays)" .. "Rank: " ..hero_play_count_ranks[hero_name])
                    if hero_play_count_ranks[hero_name] <= 50 then
                        if hero_play_count_ranks[hero_name] <= 10 then
                            hero_modifiers[hero_name] = "modifier_bottom_10"
                        elseif hero_play_count_ranks[hero_name] <= 20 then
                            hero_modifiers[hero_name] = "modifier_bottom_20"
                        elseif hero_play_count_ranks[hero_name] <= 50 then
                            hero_modifiers[hero_name] = "modifier_bottom_50"
                        end
                    end
                end
            end
            -- Now hero_modifiers is a table that maps hero names to modifier names, e.g. hero_modifiers["npc_dota_hero_visage"] = "modifier_bottom_10"
        else
            print("Failed to get hero play counts: " .. response.StatusCode)
        end
    end)
end


function table.indexof(t, v)
    for i, x in ipairs(t) do
        if x == v then
            return i
        end
    end
    return 0
end

function check_hero_ranking(unit)
    local hero_name = unit:GetUnitName()
    local modifier_name = hero_modifiers[hero_name]
    if modifier_name and not unit:HasModifier(modifier_name) then
        unit:AddNewModifier(unit, nil, modifier_name, {})
        --print("Added modifier : " ..modifier_name .. "to " ..hero_name)
    end
end


GetLeastPlayedHeroes()

