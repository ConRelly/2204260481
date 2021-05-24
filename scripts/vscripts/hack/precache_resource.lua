


function Precache_Resource( context )
    PrecacheItemByNameSync("item_tombstone", context)
	PrecacheItemByNameSync("item_bag_of_gold", context)

    PrecacheEveryThingFromKV(context)

    -- Precache_Unit_Resource(context)
    -- Precach_Item_Resource(context)

end

--自动预载入
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
function PrecacheEverythingFromTable(context,kvtable)
    for key,value in pairs(kvtable) do
            if type(value) == "table" then
                    PrecacheEverythingFromTable(context,value)
            else
                if string.find(value,"vpcf") then
                        PrecacheResource("particle",value,context)
                        -- print("!!! PRECACHE PARTICLE RESOURCE",value)
                end
                if string.find(value,"vmdl") then
                        PrecacheResource("model",value,context)
                        -- print("!!! PRECACHE MODEL RESOURCE",value)
                end
                if string.find(value,"vsndevts") then
                        PrecacheResource("soundfile",value,context)
                        -- print("!!! PRECACHE SOUND RESOURCE",value)
                end
				if string.find(value, ".vsnd") then
                    PrecacheResource("soundfile",value,context)
                    -- print("!!! PRECACHE SOUND RESOURCE",value)
				end
				if string.find(key,"particle_folder") then
						PrecacheResource("particle_folder",value,context)
						-- print("!!! PRECACHE PARTICLE FOLDER RESOURCE",value)
				end
            end
    end
end

function Precache_Unit_Resource( context )
    
    -- npc_mjz_sheer_heart_attack_tank
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_techies/techies_suicide_base.vpcf", context)
    
    -- npc_dota_goddess_crystal_queen
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_crystalmaiden", context)
    PrecacheResource("particle", "particles/units/heroes/hero_crystalmaiden/maiden_loadout.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_base_attack.vpcf", context)

     -- npc_dota_goddess_lina
     PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lina.vsndevts", context)
     PrecacheResource("particle_folder", "particles/units/heroes/hero_lina", context)
     PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_loadout.vpcf", context)
 

    -- npc_dota_goddess_sylvanas
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_drowranger.vsndevts", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_drow", context)
    PrecacheResource("particle", "particles/units/heroes/hero_drow/drow_loadout.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_drow/drow_base_attack.vpcf", context)

    -- npc_dota_goddess_windranger
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_windrunner.vsndevts", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_windrunner", context)
    PrecacheResource("particle", "particles/units/heroes/hero_windrunner/windrunner_loadout.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf", context)
        
end
    
function Precach_Item_Resource( context)
    -- item_mjz_luck_sheepstick
    PrecacheResource("model","models/props_gameplay/frog.vmdl", context)
    PrecacheResource("model","models/props_gameplay/chicken.vmdl", context)
    PrecacheResource("model","models/props_gameplay/pig.vmdl", context)
    PrecacheResource("model","models/items/hex/sheep_hex/sheep_hex.vmdl", context)
    PrecacheResource("model","models/items/hex/sheep_hex/sheep_hex_gold.vmdl", context)
    PrecacheResource("model","models/courier/navi_courier/navi_courier.vmdl", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context)
    PrecacheResource("soundfile","sounds/weapons/hero/lion/lion_voodoo.vsnd", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", context)

end