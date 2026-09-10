local precached_paths = {}
local unique_count = 0
local duplicate_count = 0

local function NormalizePath(path)
    if not path or type(path) ~= "string" then return nil end
    local clean = string.gsub(path, "^%s*(.-)%s*$", "%1") -- trim whitespace
    clean = string.gsub(clean, "\\", "/")
    return string.lower(clean), clean
end

function PrecacheSafeResource(res_type, path, context)
    local key, clean_path = NormalizePath(path)
    if not key or key == "" then return end

    if not precached_paths[key] then
        precached_paths[key] = true
        unique_count = unique_count + 1
        PrecacheResource(res_type, clean_path, context)
    else
        duplicate_count = duplicate_count + 1
    end
end

function Precache_Resource( context )
    print("!!! BEGIN PRECACHE RESOURCE")
    precached_paths = {}
    unique_count = 0
    duplicate_count = 0

    PrecacheEveryThingFromKV(context)

    -- Enable unit and item resource precaching
    Precache_Unit_Resource(context)
    Precach_Item_Resource(context)
    Precache_Extra_Game_Resources(context)

    print("!!! FINISH PRECACHE RESOURCE. Unique resources precached: " .. unique_count .. " (Skipped " .. duplicate_count .. " duplicates)")
end

-- 自动预载入
function PrecacheEveryThingFromKV( context )
    local kv_files = {
        "scripts/npc/npc_units_custom.txt",
        "scripts/npc/npc_abilities_custom.txt",
        "scripts/npc/npc_heroes_custom.txt",
        "scripts/npc/npc_items_custom.txt",
        "scripts/npc/npc_abilities_override.txt",
    }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            print("!!! BEGIN TO PRECACHE RESOURCE FROM: ", kv)
            PrecacheEverythingFromTable( context, kvs)
        end
    end
end

function PrecacheEverythingFromTable(context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            PrecacheEverythingFromTable(context, value)
        elseif type(value) == "string" then
            local val_lower = string.lower(value)
            if string.find(val_lower, "%.vpcf") then
                PrecacheSafeResource("particle", value, context)
            elseif string.find(val_lower, "%.vmdl") then
                PrecacheSafeResource("model", value, context)
            elseif string.find(val_lower, "%.vsndevts") or string.find(val_lower, "%.vsnd") then
                PrecacheSafeResource("soundfile", value, context)
            end
            -- NOTE: Do NOT precache "particle_folder". In Source 2, particle_folder causes the engine
            -- to scan the filesystem and enqueue every .vpcf file in that directory into CLoadingResource.
            -- With hero directories containing 21,000+ particles, this quickly exceeds the 32,767 capacity limit.
        end
    end
end

function Precache_Unit_Resource( context )
    print("!!! BEGIN PRECACHE UNIT RESOURCE")
    
    -- npc_mjz_sheer_heart_attack_tank
    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_techies/techies_suicide_base.vpcf", context)
    
    -- Goddess units / boss resources
    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_crystalmaiden/maiden_loadout.vpcf", context)
    PrecacheSafeResource("particle", "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_base_attack.vpcf", context)

    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lina.vsndevts", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_lina/lina_loadout.vpcf", context)

    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_drowranger.vsndevts", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_drow/drow_loadout.vpcf", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_drow/drow_base_attack.vpcf", context)

    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_windrunner.vsndevts", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_windrunner/windrunner_loadout.vpcf", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf", context)
end
    
function Precach_Item_Resource( context)
    -- item_mjz_luck_sheepstick
    PrecacheSafeResource("model", "models/props_gameplay/frog.vmdl", context)
    PrecacheSafeResource("model", "models/props_gameplay/chicken.vmdl", context)
    PrecacheSafeResource("model", "models/props_gameplay/pig.vmdl", context)
    PrecacheSafeResource("model", "models/items/hex/sheep_hex/sheep_hex.vmdl", context)
    PrecacheSafeResource("model", "models/items/hex/sheep_hex/sheep_hex_gold.vmdl", context)
    PrecacheSafeResource("model", "models/courier/navi_courier/navi_courier.vmdl", context)
    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts", context)
    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context)
    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context)
    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context)
    PrecacheSafeResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ember_spirit.vsndevts", context)
    PrecacheSafeResource("soundfile", "sounds/weapons/hero/lion/lion_voodoo.vsnd", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", context)
    PrecacheSafeResource("particle", "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf", context)
    PrecacheSafeResource("particle", "particles/custom/items/broken_wings/broken_wings_feather.vpcf", context)
    PrecacheSafeResource("particle", "particles/custom/items/staff_of_light/staff_of_light_wisp_attack.vpcf", context)
    PrecacheSafeResource("particle", "particles/custom/items/staff_of_light/staff_of_light_wisp_preattack.vpcf", context)
end

function Precache_Extra_Game_Resources( context )
    local extra_particles = {
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
    for _, p in ipairs(extra_particles) do
        PrecacheSafeResource("particle", p, context)
    end

    local extra_sounds = {
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
    for _, s in ipairs(extra_sounds) do
        PrecacheSafeResource("soundfile", s, context)
    end
end