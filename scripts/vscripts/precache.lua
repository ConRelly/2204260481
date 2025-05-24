local particles = {
    "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_necro_souls_hero.vpcf",    
    "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf",
    "particles/items_fx/blink_dagger_start.vpcf",
    "particles/items_fx/blink_dagger_end.vpcf",
    "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_midas_coinshower.vpcf",
    "particles/items_fx/aegis_respawn_timer.vpcf",
    "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf",
    "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf",
    "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_halo_buff.vpcf",
    "particles/econ/items/ogre_magi/ogre_magi_jackpot/ogre_magi_jackpot_spindle_rig.vpcf",
    "particles/econ/events/ti6/teleport_start_ti6.vpcf",
    "particles/econ/events/ti6/teleport_start_ti6_lvl3_rays.vpcf",
    "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter_victories.vpcf",
    "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf",
    "particles/units/heroes/hero_huskar/huskar_berserker_blood_hero_effect.vpcf",
    "particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf",
    "particles/units/heroes/hero_meepo/meepo_geostrike_ambient.vpcf",
    "particles/units/heroes/hero_luna/luna_ambient_lunar_blessing.vpcf",
    "particles/units/heroes/hero_drow/drow_aura_buff.vpcf",
    "particles/units/heroes/hero_abaddon/abaddon_frost_buff.vpcf",
    "particles/units/heroes/hero_omniknight/omniknight_degen_aura.vpcf",
    "particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf",
   
    "particles/econ/events/spring_2021/maelstrom_spring_2021.vpcf",
    "particles/econ/events/ti8/mjollnir_shield_ti8.vpcf",
    "particles/econ/events/ti8/maelstorm_ti8.vpcf",
    "particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf",
    "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf",
    "particles/econ/events/ti9/maelstorm_ti9.vpcf",
    "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_maelstrom_v2_item.vpcf",
    "particles/items2_fx/mjollnir_shield_unused.vpcf",
    "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_mjollnir_shield.vpcf",
    "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_mjollnir_shield_v2.vpcf",
    "particles/econ/events/spring_2021/mjollnir_shield_spring_2021.vpcf",
    "particles/econ/events/ti9/mjollnir_shield_ti9.vpcf",
    "particles/econ/events/ti10/mjollnir_shield_ti10.vpcf",
    "particles/custom/items/spellbook/destruction/spellbook_destruction_cast_aoe.vpcf",
    "particles/custom/items/spellbook/destruction/spellbook_destruction_cast.vpcf",
    "particles/custom/items/spellbook/destruction/spellbook_destruction_impact.vpcf",
    "particles/custom/items/spellbook/destruction/spellbook_destruction_debuff.vpcf",
    "particles/custom/items/pipe_of_dezun/pipe_of_dezun_magic_immune_avatar.vpcf",

      
}

local sounds = {
    "soundevents/game_sounds.vsndevts",
    "soundevents/game_sounds_dungeon.vsndevts",
    "soundevents/game_sounds_dungeon_enemies.vsndevts",
    "soundevents/custom_soundboard_soundevents.vsndevts",
    "soundevents/game_sounds_winter_2018.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts",
    "soundevents/game_sounds_creeps.vsndevts",
    "soundevents/game_sounds_ui.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts",
}


local function PrecacheEverythingFromTable( context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            --忽略那些预载入单位
            if not string.find(key, "npc_precache_") then
               PrecacheEverythingFromTable( context, value )
            end
        else
            if string.find(value, "vpcf") then
                PrecacheResource( "particle", value, context)
            end
            if string.find(value, "vmdl") then
                PrecacheResource( "model", value, context)
            end
            if string.find(value, "vsndevts") then            
                PrecacheResource( "soundfile", value, context)
            end
        end
    end
end

function PrecacheEverythingFromKV( context )
    local kv_files = {
        "scripts/npc/npc_abilities_custom.txt",
        "scripts/npc/npc_units_custom.txt",
        "scripts/npc/npc_items_custom.txt",
    }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            PrecacheEverythingFromTable( context, kvs)
        end
    end
end



return function(context)
    print("[PRECACHE] Starting resource precaching...")
    
    PrecacheEverythingFromKV(context)
    
    
    -- 预载入提前选好的32名英雄
    if not IsInToolsMode() then
       print("[PRECACHE] Precaching selected heroes...")
       for _,sHeroName in ipairs(GameRules.heroesPoolList) do
           print("[PRECACHE] Precaching Hero: " .. sHeroName)
           PrecacheUnitByNameSync(sHeroName, context, -1)
       end
    end

    print("[PRECACHE] Precaching particles...")
    for _, p in pairs(particles) do
        PrecacheResource("particle", p, context)
    end
    
    print("[PRECACHE] Precaching sounds...")
    for _, p in pairs(sounds) do
        PrecacheResource("soundfile", p, context)
    end
    
    print("[PRECACHE] Resource precaching completed!")
end

