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
        if npc == nil then
            return
        end
        if npc:GetLevel() > 25 then
            skill_lvl = RandomInt(1, 6)
        end        
        if npc:GetLevel() > 50 then
            skill_lvl = RandomInt(4, 7)
            if npc:GetLevel() > 84 then
                skill_lvl = 7
            end    
        end
        local test_mode = false  -- comment out this or change to 'test_mode = true' to enable /disable test.
        if test_mode then
            local testskill = "primal_beast_uproar_custom"
            local testskill2 = "primal_beast_uproar_custom"
            local testskill3 = "primal_beast_onslaught_custom"
            local testskill4 = "tusk_walrus_punch_2"

            if not npc:HasAbility(testskill) then
                local searing = npc:AddAbility(testskill)
                searing:UpgradeAbility(true)
                searing:SetLevel(skill_lvl)
            end
            if not npc:HasAbility(testskill2) then
                local searing2 = npc:AddAbility(testskill2)   
                searing2:UpgradeAbility(true)
                searing2:SetLevel(skill_lvl)           
            end   
            if not npc:HasAbility(testskill3) then
                local searing3 = npc:AddAbility(testskill3)   
                searing3:UpgradeAbility(true)
                searing3:SetLevel(skill_lvl)           
            end  
            if not npc:HasAbility(testskill4) then
                local searing4 = npc:AddAbility(testskill4)   
                searing4:UpgradeAbility(true)
                searing4:SetLevel(skill_lvl)           
            end
        end    

        
        Timers:CreateTimer({
            endTime = skop, 
            callback = function()
                local found_valid_ability1 = false
                while not found_valid_ability1 do               
                    local newAbilityName = GetRandomAbilityName(hero)
                    if not npc:HasAbility(newAbilityName) then
                        local status, link_a = xpcall(
                                function()
                                  return npc:AddAbility(newAbilityName)
                                end,
                                function(msg)
                                  print(debug.traceback(msg, 3))
                                  return false
                                end
                            )
                        if link_a then
                            link_a:UpgradeAbility(true)
                            link_a:SetLevel(skill_lvl)
                            found_valid_ability1 = true
                        end
                        if link_a == nil then
                           print('Error: No link_a')
                        end
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
                        local status, link_b = xpcall(
                                function()
                                  return npc:AddAbility(newAbilityNameb)
                                end,
                                function(msg)
                                  print(debug.traceback(msg, 3))
                                  return false
                                end
                            )
                        if link_b then
                            link_b:UpgradeAbility(true) 
                            link_b:SetLevel(skill_lvl)
                            found_valid_ability2 = true
                        end
                        if link_b == nil then
                            print('Error: No link_b')
                        end
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
                            local status, link_c = xpcall(
                                function()
                                  return npc:AddAbility(newAbilityNamec)
                                end,
                                function(msg)
                                  print(debug.traceback(msg, 3))
                                  return false
                                end
                            )
                            if link_c then
                                link_c:UpgradeAbility(true) 
                                link_c:SetLevel(skill_lvl)
                                found_valid_ability3 = true
                            end
                            if link_c == nil then
                                print('Error: No link_c')
                            end
                        end    
                    end         
                end 
            end
        })     
            
        if npc and not npc:HasModifier(M_NAME) then
         xpcall(
                function()
                  return npc:AddNewModifier( npc, nil, M_NAME, {})
                end,
                function(msg)
                  print(debug.traceback(msg, 3))
                  return false
                end
            )
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
        --"skeleton_king_vampiric_aura",      
        --"skeleton_king_mortal_strike",      
        --"mjz_obsidian_destroyer_essence_aura",                      
        --"antimage_custom_mana_break",          
        --"phantom_assassin_blur",          
        --"mjz_vengefulspirit_vengeance",			
        --"chaos_knight_chaos_strike",        
        --"mars_bulwark", 
        --"lone_druid_spirit_bear_demolish",   
        --"monkey_king_custom_jingu_mastery", 
        --"mjz_broodmother_insatiable_hunger",    
        --"abyssal_underlord_atrophy_aura",             
        --"mjz_clinkz_soul_pact",                
        --"nyx_assassin_custom_vendetta",             
        --"dark_willow_bedlam",                 
        --"rubick_arcane_supremacy",          
        --"jakiro_liquid_fire",               
        --"obsidian_destroyer_arcane_orb",    
        --"mjz_crystal_maiden_brilliance_aura",   
        --"naga_siren_rip_tide",     -- 沉默 1
        --"imba_phantom_assassin_coup_de_grace", 
        --"ancient_apparition_chilling_touch",   
        --"visage_soul_assumption",            
        --"enchantress_impetus",             
        --"wisp_overcharge",                  
        --"mjz_faceless_void_backtrack",         
        --"ryze_arcane_mastery",     --4
        --"mars_gods_rebuke",     
        --"void_spirit_astral_step",       
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
        --"tidehunter_anchor_smash",          
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
        --"dazzle_bad_juju",                  
        --"mjz_furion_power_of_nature", 
        --"mjz_invoker_magic_master",
        --"enchantress_natures_attendants",
        --"hoodwink_scurry",
        --"hoodwink_bushwhack", 
        --"oracle_false_promise", -- insta kills
        --"brewmaster_storm_cyclone", -- probably crash if hero has some stun immunity and/or moves during
        --"enchantress_natures_attendants", 
        --"mjz_night_stalker_hunter_in_the_night", maybe problematic with crash.   
        --"mjz_juggernaut_blade_fury", crash on mobs  
        --"keeper_of_the_light_radiant_bind",   crash 
        --"mjz_troll_warlord_fervor", stats not good  
        --"viper_viper_strike", 
        --"lone_druid_rabid",    -- bugged / causes crash in certain circumstances 
        --"earth_spirit_rolling_boulder",
        --"bounty_hunter_track", -- crash when caster disapears.             
        "phantom_assassin_blur",
        "custom_leap",       
        "ember_spirit_searing_chains",                   
        "beastmaster_inner_beast",     
        "spirit_breaker_greater_bash",           
        "sven_great_cleave",                
        "magnataur_empower",                
        "legion_commander_custom_duel",                
        "alchemist_chemical_rage",                 
        "templar_assassin_psi_blades",      -- TA 3
        "mjz_vengefulspirit_vengeance",     
        "mjz_omniknight_repel",           
        "lycan_feral_impulse",              
        "mjz_ursa_overpower",                
        "ursa_fury_swipes",                
        "lich_custom_cold_soul2",                  
        "meepo_ransack",                   
        "brewmaster_fire_permanent_immolation",           
        "ogre_magi_bloodlust",            
        "elder_titan_natural_order",                 
        "skywrath_mage_ancient_seal",       
        "disruptor_custom_ion_hammer",       
        "medusa_stone_gaze",              
        "tusk_walrus_punch",                    
        "bane_enfeeble",          
        "elder_titan_natural_order_spirit",                   
        "big_thunder_lizard_wardrums_aura",   
        "mjz_general_megamorph",            
        "juggernaut_omni_slash",
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
        "enigma_midnight_pulse",
        "sniper_headshot", 
        "lich_chain_frost",
        "slark_pounce",
        "puck_dream_coil",
        "morphling_waveform",
        "nyx_assassin_mana_burn",
        "dazzle_poison_touch",
        --"dazzle_bad_juju",
        "mirana_leap",
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
        "earthshaker_echo_slam",
        "legion_commander_duel",
        "legion_commander_press_the_attack",
        "sniper_assassinate", -- bugs when attacking courrier in certain circumstances
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
        "broodmother_incapacitating_bite",
        "death_prophet_spirit_siphon",
        "ancient_apparition_cold_feet",
        "abyssal_underlord_firestorm",
        "faceless_void_time_dilation",
        "enigma_malefice",
        "skywrath_mage_concussive_shot",
        "skywrath_mage_mystic_flare",
        "ogre_magi_ignite",
        "axe_battle_hunger",
        "axe_berserkers_call",
        "razor_static_link",
        "riki_smoke_screen",
        "nevermore_dark_lord",
        "chen_penitence",
        "enchantress_untouchable",
        "warlock_shadow_word",
        "huskar_berserkers_blood",
        "marci_unleash_custom",
        "primal_beast_onslaught", --can move the boss out of map.
        "primal_beast_uproar_custom",


    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]   
end
--end   