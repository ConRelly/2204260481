require("lib/timers")
LinkLuaModifier("modifier_mjz_bristleback_quill_spray_autocast6", "abilities/hero_bristleback/modifier_mjz_bristleback_quill_spray_autocast6.lua", LUA_MODIFIER_MOTION_NONE)
function getrandomskill(npc)
    if IsServer() then 

        local M_NAME = "modifier_mjz_bristleback_quill_spray_autocast6"
        local aghbuf = "modifier_item_ultimate_scepter_consumed"
        local shard = "modifier_item_aghanims_shard"
        local aghanim_chance = 65
        local skill_lvl = RandomInt(1, 5)
        local skop = RandomInt(1,5) / 10
        local skop2 = RandomInt(6 ,10) / 10
        if npc:GetLevel() > 25 then
            skill_lvl = RandomInt(1, 6)
        end        
        if npc:GetLevel() > 50 then
            skill_lvl = RandomInt(4, 7)
            if npc:GetLevel() > 84 then
                skill_lvl = 7
            end    
        end
        --[[local ability_trist = "mjz_night_stalker_hunter_in_the_night"
        local searing = npc:AddAbility(ability_trist)
        searing:UpgradeAbility(true)
        searing:SetLevel(skill_lvl)]]
        Timers:CreateTimer({
            endTime = skop, 
            callback = function()
                local found_valid_ability1 = false
                while not found_valid_ability1 do               
                    local newAbilityName = GetRandomAbilityName(hero)
                    if not npc:HasAbility(newAbilityName) then
                        local link_a = npc:AddAbility(newAbilityName)
                        link_a:UpgradeAbility(true)
                        link_a:SetLevel(skill_lvl)
                        found_valid_ability1 = true
                    end   
                end
            end
        })        
        Timers:CreateTimer({
            endTime = skop2, 
            callback = function()
                local found_valid_ability2 = false
                while not found_valid_ability2 do
                    local newAbilityNameb = GetRandomAbilityName(hero)
                    if not npc:HasAbility(newAbilityNameb) then                
                        local link_b = npc:AddAbility(newAbilityNameb)
                        link_b:UpgradeAbility(true) 
                        link_b:SetLevel(skill_lvl)
                        found_valid_ability2 = true
                    end    
                end
            end
        })         
        Timers:CreateTimer({
            endTime = skop + 0.1, 
            callback = function()
                if RollPercentage(60) then
                    local found_valid_ability3 = false
                    while not found_valid_ability3 do
                        local newAbilityNamec = GetRandomAbilityName(hero)
                        if not npc:HasAbility(newAbilityNamec) then                              
                            local link_c = npc:AddAbility(newAbilityNamec)
                            link_c:UpgradeAbility(true) 
                            link_c:SetLevel(skill_lvl)
                            found_valid_ability3 = true
                        end    
                    end         
                end 
            end
        })     
            
        if not npc:HasModifier(M_NAME) then
            npc:AddNewModifier( npc, nil, M_NAME, {})
        end 
        --[[Timers:CreateTimer({
            endTime = skop2 + 0.1, 
            callback = function()
                if RollPercentage(aghanim_chance) then
                    if not npc:HasModifier(aghbuf) then
                        npc:AddNewModifier( npc, nil, aghbuf, {})
                    end
                    if not npc:HasModifier(shard) and npc:GetUnitName() ~= "npc_boss_zeus" and npc:GetUnitName() ~= "npc_boss_enigma" and npc:GetUnitName() ~= "npc_boss_wisp_new" then
                        npc:AddNewModifier( npc, nil, shard, {})
                    end                
                end
            end
        })]]                  
    end
end


--if IsServer() then
function GetRandomAbilityName( hero )                 
    local abilityList = {
        --"skeleton_king_vampiric_aura",      --骷髅王2
        --"skeleton_king_mortal_strike",      --骷髅王3
        --"mjz_obsidian_destroyer_essence_aura",                      -- 全能 3
        --"antimage_custom_mana_break",          -- 伐木机 3
        --"phantom_assassin_blur",          -- 潮汐 2
        --"mjz_vengefulspirit_vengeance",			-- 老奶奶 2
        --"chaos_knight_chaos_strike",        -- 混沌3
        --"mars_bulwark", 
        --"lone_druid_spirit_bear_demolish",   
        --"monkey_king_custom_jingu_mastery", 
        --"mjz_broodmother_insatiable_hunger",    
        --"abyssal_underlord_atrophy_aura",             -- 滚滚 3
        --"mjz_clinkz_soul_pact",                -- 赏金 2
        --"nyx_assassin_custom_vendetta",             -- 先知 2
        --"dark_willow_bedlam",                 
        --"rubick_arcane_supremacy",          -- 拉比克 3
        --"jakiro_liquid_fire",               -- 双头龙 3
        --"obsidian_destroyer_arcane_orb",    -- 黑鸟 1
        --"mjz_crystal_maiden_brilliance_aura",   -- 冰女 3
        --"naga_siren_rip_tide",     -- 沉默 1
        --"imba_phantom_assassin_coup_de_grace", 
        --"ancient_apparition_chilling_touch",    -- 冰魂 3
        --"visage_soul_assumption",            -- 蓝猫 3
        --"enchantress_impetus",              -- 小鹿 1
        --"wisp_overcharge",                  -- 黑贤 3
        --"mjz_faceless_void_backtrack",         --3
        --"ryze_arcane_mastery",     --4
        --"mars_gods_rebuke",     -- 龙肤光环 没有光环
        --"void_spirit_astral_step",       -- 溅射攻击
        --"phantom_reflex",
        --"ogre_magi_multicast_lua",
        --"mjz_clinkz_death_pact",
        --"mjz_phantom_assassin_coup_de_grace",
        --"mjz_templar_assassin_refraction",
        --"mjz_void_spirit_astral_atlas",
        --"mjz_windrunner_powershot",
        --"huskar_burning_spear",
        --"bloodseeker_custom_thirst",
        --"bloodseeker_custom_rampage",
        --"dark_seer_custom_dark_clone",
        --"monkey_king_custom_jingu_mastery",
        --"tiny_custom_toss",
        --"treant_custom_ultimate_sacrifice",
        --"mjz_bloodseeker_rupture",
        --"dragon_knight_elder_dragon_form",
        --"mjz_monkey_king_jingu_mastery",
        --"mjz_mirana_arrow",
        --"mjz_drow_ranger_marksmanship",
        --"mjz_ember_spirit_flame_guard",
        --"mjz_io_overcharge",
        --"wisp_tether",
        --"viper_poison_attack",
        --"mjz_troll_warlord_battle_trance",
        --"mjz_chaos_knight_chaos_strike",
        --"chen_custom_avatar",
        --"hoodwink_acorn_shot",
        --"brewmaster_drunken_brawler",                   
        --"luna_lunar_blessing",
        --"mjz_doom_bringer_doom",
        --"vengefulspirit_command_aura",
        --"bounty_hunter_jinada", --crash
        --"winter_wyvern_arctic_burn",
        --"tidehunter_anchor_smash",          -- 潮汐 3
        --"tidehunter_gush",
        --"life_stealer_custom_deny",
        --"earth_spirit_magnetize",
        --"enigma_black_hole",
        --"mjz_night_stalker_darkness",
        --"arc_warden_magnetic_field",
        --"mjz_windrunner_powershot",
        --"mjz_faceless_the_world",  ?
        --"special_bonus_spell_block_18",
        --"juggernaut_healing_ward", 
        --"mjz_windrunner_focusfire",
        --"bounty_hunter_shuriken_toss", --crash in combo with trak probably
        --"batrider_sticky_napalm", --sometimes crash in combination with hero attack or others skills.(uncommon)  
        --"mjz_omniknight_degen_aura",    --probably lagy or maybe unstable   
        --"faceless_void_time_lock",      --to many hits might lock acting.
        --"night_stalker_darkness", 
        --"dazzle_bad_juju",                  -- 丽娜 3 
        --"mjz_furion_power_of_nature", 
        --"mjz_invoker_magic_master",
        "phantom_assassin_blur",
        "custom_leap",       
        "ember_spirit_searing_chains",
        "mjz_troll_warlord_fervor",            -- 老奶奶 3              
        "beastmaster_inner_beast",      -- 兽王    野性之心
        "spirit_breaker_greater_bash",            --发条2
        "sven_great_cleave",                -- sven 2
        "mjz_night_stalker_hunter_in_the_night", -- test  
        "magnataur_empower",                -- 猛犸 2
        "legion_commander_custom_duel",                 -- 猛犸 3
        "alchemist_chemical_rage",                 -- 马尔斯 2
        "lone_druid_rabid",       -- 龙骑3
        "templar_assassin_psi_blades",      -- TA 3
        "mjz_vengefulspirit_vengeance",      -- VS 3         -- 小娜迦 1
        "mjz_omniknight_repel",           -- 影魔 4
        "lycan_feral_impulse",              -- 影魔 5
        "mjz_ursa_overpower",                   -- 拍拍熊 2
        "ursa_fury_swipes",                 -- 拍拍熊 3
        "lich_custom_cold_soul2",                  -- 火枪 3
        "meepo_ransack",                    -- 米波 3
        "brewmaster_fire_permanent_immolation",           -- 蚂蚁 3    bug
        "ogre_magi_bloodlust",            -- 血魔 1
        "elder_titan_natural_order",                 -- 蝙蝠 3
        "skywrath_mage_ancient_seal",       -- 天怒 3
        "disruptor_custom_ion_hammer",        -- 冰龙 1 crash on snowball               -- 女王 2
        "medusa_stone_gaze",              -- 蓝胖 3
        "tusk_walrus_punch",          -- 哈斯卡 3           
        "bane_enfeeble",           -- 2
        "elder_titan_natural_order_spirit",      -- 熊怪 迅捷光环
        "oracle_false_promise",             -- 坚韧光环
        "big_thunder_lizard_wardrums_aura",   --战鼓光环
        "mjz_general_megamorph",            --巨大化
        "juggernaut_omni_slash",
        "mjz_phantom_assassin_phantom_strike",
        "mjz_spectre_desolate",
        "mjz_templar_assassin_proficiency",
        "omniknight_guardian_angel",
        "legion_commander_custom_duel",
        "rattletrap_custom_battery_assault",
        "sven_gods_strength",
        "witch_doctor_maledict",
        "mjz_axe_berserkers_call",
        "mjz_silencer_global_silence",
        "weaver_the_swarm",
        "tinker_march_of_the_machines",
        "tusk_tag_team",
        "tidehunter_ravage",
        "viper_nethertoxin",
        "viper_viper_strike",
        "enigma_midnight_pulse",
        "sniper_headshot", 
        "lich_chain_frost",
        "slark_pounce",
        "puck_dream_coil",
        "morphling_waveform",
        "nyx_assassin_mana_burn",
        "dazzle_poison_touch",
        "dazzle_bad_juju",
        "mirana_leap",
        "hoodwink_scurry",
        "hoodwink_bushwhack",
        "doom_bringer_doom",
        "mars_spear",
        "grimstroke_soul_chain",
        "slardar_amplify_damage",
        "slardar_sprint",
        "pudge_meat_hook",
        "vengefulspirit_magic_missile",
        "vengefulspirit_wave_of_terror",
        "silencer_curse_of_the_silent",
        "bloodseeker_rupture",
        "earth_spirit_boulder_smash",
        "earth_spirit_rolling_boulder",
        "earthshaker_echo_slam",
        "legion_commander_duel",
        "legion_commander_press_the_attack",
        "sniper_assassinate",
        "warlock_fatal_bonds",
        "lion_finger_of_death",
        "dragon_knight_breathe_fire",
        "night_stalker_void",
        "centaur_hoof_stomp",
        "chaos_knight_chaos_bolt",
        "chaos_knight_reality_rift",
        "doom_bringer_infernal_blade",
        "earthshaker_aftershock",
        "dragon_knight_dragon_blood",
        "wisp_overcharge",
        "legion_commander_overwhelming_odds",
        "lycan_howl",
        "magnataur_reverse_polarity",
        "magnataur_shockwave",
        "greevil_miniboss_orange_light_strike_array",
        "omniknight_purification",
        "sandking_sand_storm",
        "sven_warcry",
        "sven_storm_bolt",
        "shredder_whirling_death",
        "silencer_global_silence",
        "slardar_slithereen_crush",
        "spectre_spectral_dagger",
        "storm_spirit_electric_vortex",
        "visage_grave_chill",
        "void_spirit_dissimilate",
        "shadow_demon_demonic_purge",
        "bloodseeker_blood_bath",
        "bounty_hunter_track",
        "brewmaster_storm_cyclone",
        "broodmother_incapacitating_bite",
        "death_prophet_spirit_siphon",
        "ancient_apparition_cold_feet",
        "abyssal_underlord_firestorm",
        "faceless_void_time_dilation",
        "enigma_malefice",
        "keeper_of_the_light_radiant_bind",
        "skywrath_mage_concussive_shot",
        "skywrath_mage_mystic_flare",
        "ogre_magi_ignite",
        "axe_battle_hunger",
        "axe_berserkers_call",
        "mjz_juggernaut_blade_fury",
        "razor_static_link",
        "riki_smoke_screen",
        "nevermore_dark_lord",
        "chen_penitence",
        "enchantress_untouchable",
        "enchantress_natures_attendants",
        "warlock_shadow_word",
        "huskar_berserkers_blood",

    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]   
end
--end   