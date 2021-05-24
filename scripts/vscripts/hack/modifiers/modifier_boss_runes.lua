
modifier_boss_runes = class({})

function modifier_boss_runes:IsPurgable()
    return false
end
function modifier_boss_runes:IsHidden()
    return true
end

if IsServer() then
    function modifier_boss_runes:OnCreated(table)
        self:StartIntervalThink(1.25)
    end
    function modifier_boss_runes:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        -- local radius = 1000

        -- local runes = Entities:FindAllByClassnameWithin("dota_item_rune", parent:GetAbsOrigin(), radius)
        -- for _,rune in pairs(runes) do
        --     print("rune name: " .. rune:GetName())
        -- end

        self:find_rune(parent)
    end

    
    function modifier_boss_runes:find_rune( parent )
        local radius = 1000

        local RUNES_MODEL = {
            -- 奥术
            arcane      = "models/props_gameplay/rune_arcane.vmdl",  
            -- 双倍
            double      = "models/props_gameplay/rune_doubledamage01.vmdl", 
            -- 赏金
            goldxp      = "models/props_gameplay/rune_goldxp.vmdl",
            -- 极速 
            haste       = "models/props_gameplay/rune_haste01.vmdl",
            -- 幻象 
            illusion    = "models/props_gameplay/rune_illusion01.vmdl",
            -- 隐身
            stealth     = "models/props_gameplay/rune_invisibility01.vmdl",
            -- 恢复
            regen       = "models/props_gameplay/rune_regeneration01.vmdl",
        }

        local runes = Entities:FindAllByClassnameWithin("dota_item_rune", parent:GetAbsOrigin(), radius)
        for _,rune in pairs(runes) do
            -- print("rune model: " .. rune:GetModelName())
            local runeModelName = rune:GetModelName()
            for rn,rm in pairs(RUNES_MODEL) do
                if runeModelName == rm then
                    -- print("Find rune: " .. rn)
                    self:pickup_rune(parent, rune, rn)
                end
            end
            -- PrintTable(rune)
        end
    end

    function modifier_boss_runes:pickup_rune( unit, rune, runeName )
        local RUNES_MODIFIER = {
            -- 奥术
            arcane      = "modifier_rune_arcane"    ,  
            -- 双倍
            double      = "modifier_rune_doubledamage"  , 
            -- 赏金
            goldxp      = nil  ,
            -- 极速 
            haste       = "modifier_rune_haste" ,
            -- 幻象 
            illusion    = nil  ,
            -- 隐身
            stealth     = "modifier_mirana_moonlight_shadow", --"modifier_rune_invis"  ,
            -- 恢复
            regen       = "modifier_rune_regen"  ,

            -- 四倍伤害     
            extradamage  = "modifier_rune_extradamage",
            -- 翱翔极速     移动速度达到极限，可以穿越树木和地形。
            flying_haste  = "modifier_rune_flying_haste",
            -- 持久隐身
            super_invis  = "modifier_rune_super_invis",
            -- 超级恢复
            super_regen  = "modifier_rune_super_regen",
            -- 超级奥术     冷却时间减少60%，魔法消耗减少60%
            super_arcane = "modifier_rune_super_arcane",
            -- 超级幻象     召唤4个自身的幻象，继承35%的攻击力。近战幻象承受200%伤害，远程幻象承受300%伤害。持续75秒。
            -- super_illusion = "",
            
        }
        local RUNES_SOUND = {
            -- 奥术
            arcane      = "Rune.Arcane"    ,  
            -- 双倍
            double      = "Rune.DD"  , 
            -- 赏金
            goldxp      = "Rune.Bounty"  ,
            -- 极速 
            haste       = "Rune.Haste" ,
            -- 幻象 
            illusion    = "Rune.Illusion"  ,
            -- 隐身
            stealth     = "Rune.Invis"  ,
            -- 恢复
            regen       = "Rune.Regen"  ,
        }

        if not IsValidEntity(unit) then return end
        if not unit:IsAlive() then return end
        if rune._used then return end

        local isPick = false
        local duration = 60
        local modifierName = RUNES_MODIFIER[runeName]
        local soundName = RUNES_SOUND[runeName]
        if modifierName then
            isPick = true
            -- rune:ForceKill(false)
            -- if IsInToolsMode() then
            --     modifierName = "modifier_mirana_moonlight_shadow"
            -- end
            unit:AddNewModifier(unit, nil, modifierName, {duration = duration})

        end

        if runeName == "illusion" then
            isPick = true
            self:illusion_rune(unit, rune, runeName)
        end

        if isPick then
            rune._used = true
            -- print("Use Rune: " .. runeName)
            EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), soundName, unit)
        end
    end

    function modifier_boss_runes:illusion_rune( unit, rune, runeName )

        local heros = {}
        for playerID = 0, 4 do
            if PlayerResource:IsValidPlayerID(playerID) then
                if PlayerResource:HasSelectedHero(playerID) then
                    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                    table.insert( heros, hero)
                end
            end
        end
        local luck_hero = heros[RandomInt(1, #heros)]

        local duration = 60
        local images_count = 1
        local vRandomSpawnPos = {
            Vector( 72, 0, 0 ),		-- North
            Vector( 0, 72, 0 ),		-- East
            Vector( -72, 0, 0 ),	-- South
            Vector( 0, -72, 0 ),	-- West
        }

        for i = #vRandomSpawnPos, 2, -1 do	-- Simply shuffle them
            local j = RandomInt( 1, i )
            vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
        end

        table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )
        -- FindClearSpaceForUnit(unit, unit:GetAbsOrigin() + table.remove( vRandomSpawnPos, 1 ), true)

        for i = 1, images_count do
            local origin = luck_hero:GetAbsOrigin() + table.remove( vRandomSpawnPos, 1 )

            local illusion_kv = { duration = duration, outgoing_damage = 100, incoming_damage = 100 }
            -- ( hOwner, hHeroToCopy, hModiiferKeys, nNumIllusions, nPadding, bScramblePosition, bFindClearSpace )
            local illusions = CreateIllusions(unit, luck_hero, illusion_kv, 1, 50, true, true )
            local illusion = illusions[1]
            if IsInToolsMode() then 
                illusion:SetPlayerID(unit:GetPlayerID())
                illusion:SetOwner(unit)
            end
            illusion:SetTeam(DOTA_TEAM_BADGUYS)

            FindClearSpaceForUnit( illusion, origin, false )

        end
    end

end

