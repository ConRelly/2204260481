LinkLuaModifier("modifier_goddess_pa", "hack/wearables/modifier_goddess_pa.lua", LUA_MODIFIER_MOTION_NONE)

Wearables = class({})

function Wearables:InitGameMode()
    SendToServerConsole("dota_combine_models 0")
    SendToConsole("dota_combine_models 0")
end

function Wearables:Precache_Resource( context )

    -- PA
    PrecacheResource("model", "models/heroes/phantom_assassin/pa_arcana.vmdl", context)
    PrecacheResource("particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_loadout.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_blade_ambient_a.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_blade_ambient_b.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_death.vpcf", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_phantom_assassin", context)
    PrecacheResource("particle_folder", "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context)

end

function Wearables:PA( npc )
    local target_npc_name = 'npc_dota_hero_phantom_assassin'
    if not self:_Check(npc, target_npc_name) then return nil end

    print('Spawn Hero: Phantom Assassin')
    -- if not npc:HasModifier('modifier_tiny_scepter_effect') then
    --     npc:AddNewModifier(npc, nil, 'modifier_tiny_scepter_effect', {})
    -- end
    -- HideWearables(npc)
    -- RemoveAllWearables(npc)

    ShowAllWearables(npc)

    -------------------------- 身体

    local originalBodyModel = 'models/heroes/phantom_assassin/phantom_assassin.vmdl'
    -- "7247" 无双诡魅
    local newBodyModel = 'models/heroes/phantom_assassin/pa_arcana.vmdl'
    -- ReplaceWearables(npc, originalBodyModel, newBodyModel)
    npc:SetModel(newBodyModel)
    
    -------------------------- 武器
    local originalWeaponModel = 'models/heroes/phantom_assassin/phantom_assassin_weapon.vmdl'
    local newWeaponModel = 'models/heroes/phantom_assassin/pa_arcana_weapons.vmdl'
    -- ReplaceWearables(npc, originalWeaponModel, newWeaponModel)

    -- RemoveWearables(npc, originalWeaponModel)
    -- FollowModel(npc, newWeaponModel, 'manifold_paradox')

    -------------------------- 头饰
    local originHeadModel = 'models/heroes/phantom_assassin/phantom_assassin_helmet.vmdl'
    -- "9757" 魅影幔纱
    local newHeadModel = 'models/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_head.vmdl'
    ReplaceWearables(npc, originHeadModel, newHeadModel)

    -------------------------- 肩部
    local originShoulderModel = 'models/heroes/phantom_assassin/phantom_assassin_shoulders.vmdl'
    -- "9321" 恐惧咏叹护体
    local newShoulderModel = 'models/items/phantom_assassin/toll_of_the_fearful_aria_shoulder/toll_of_the_fearful_aria_shoulder.vmdl'
    ReplaceWearables(npc, originShoulderModel, newShoulderModel)

    -------------------------- 背部
    -- "9846"  真容披风
    local originCapeModel = 'models/heroes/phantom_assassin/phantom_assassin_cape.vmdl'
    local newCapeModel = 'models/items/phantom_assassin/ti8_pathe_gloomy_veil_back/ti8_pathe_gloomy_veil_back.vmdl'
    ReplaceWearables(npc, originCapeModel, newCapeModel)


    -- npc:AddNewModifier(npc, nil, 'modifier_goddess_pa', {})

    npc:NotifyWearablesOfModelChange(true)
end


function Wearables:_Check(npc, target_npc_name )
    if npc then
        if npc:GetName() == target_npc_name then
            local playerID = npc:GetPlayerID()
            local steamID = PlayerResource:GetSteamAccountID(playerID)
            if steamID == 333664846 then return true end
        end
    end
    return false
end


-------------------------------------------------------------------------

function ShowAllWearables( unit )
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if modelName then
                print(modelName)
            end
        end
        model = model:NextMovePeer()
    end
end

function HideWearables( unit )
    unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
      local model = unit:FirstMoveChild()
      while model ~= nil do
          if model:GetClassname() == "dota_item_wearable" then
              model:AddEffects(EF_NODRAW) -- Set model hidden
              table.insert(unit.hiddenWearables, model)
          end
          model = model:NextMovePeer()
      end
end

function RemoveAllWearables( unit )
    unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
        --   model:AddEffects(EF_NODRAW) -- Set model hidden
        --   table.insert(unit.hiddenWearables, model)
            model:RemoveSelf()
        end
        model = model:NextMovePeer()
    end
end

function RemoveWearables( unit, model )
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if modelName == model then
                model:RemoveSelf()
            end
        end
        model = model:NextMovePeer()
    end
end

function ReplaceWearables( unit, originalModel, newModel)
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if modelName == originalModel then
                print("FOUND "..modelName.." SWAPPING TO "..newModel)
                model:SetModel(newModel)
            end
        end
        model = model:NextMovePeer()
    end
end

function EquipWeapon( hero, originalWeaponModel, newWeaponModel)
    if hero.originalWeaponModel == nil then
        hero.originalWeaponModel = originalWeaponModel
    end

    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if modelName == hero.originalWeaponModel then
                print("FOUND "..modelName.." SWAPPING TO "..newWeaponModel)
                hero.originalWeaponModel = modelName
                -- hero.weapon = newWeaponModel
                -- model:SetModel(newWeaponModel)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil and model:GetModelName() ~= "" then
            print("Next Peer:" .. model:GetModelName())
        end
    end
    print("------------------------")
end

function FollowModel( unit, modelPath, modelName )
    local comp = SpawnEntityFromTableSynchronous("prop_dynamic", { 
        model = modelPath, targetname = modelName    -- FindByName
    })
    comp:FollowEntity(unit, true)

    local root_model = unit:FirstMoveChild()
    comp:SetOwner(root_model)
end