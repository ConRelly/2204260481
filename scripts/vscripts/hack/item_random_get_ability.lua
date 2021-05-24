
function OnSpellStart( keys )
    local caster = keys.caster
    local ability = keys.ability
    local unit = keys.unit
    local hero = caster

    if hero:HasModifier("modifier_arc_warden_tempest_double") then
        ability:SetActivated(false)
		return nil
	end

    if hero:IsRealHero() then
        local ability4 = hero:GetAbilityByIndex(3)
        local ability5 = hero:GetAbilityByIndex(4)
        local ability7 = hero:GetAbilityByIndex(6)
        local ability8 = hero:GetAbilityByIndex(7)

        local slotId = -1
		-- if ability4 then slotId = 4 end
		-- if ability5 then slotId = 6 end
		-- if ability7 then slotId = 8 end
		-- if ability8 then slotId = nil end
        if ability8 == nil or ability8:GetName() == "generic_hidden" then slotId = 7 end
        if ability7 == nil or ability7:GetName() == "generic_hidden" then slotId = 6 end
        if ability5 == nil or ability5:GetName() == "generic_hidden" then slotId = 4 end
        if ability4 == nil or ability4:GetName() == "generic_hidden" then slotId = 3 end
        -- if ability8 == nil then slotId = 7 end
        -- if ability7 == nil then slotId = 6 end

        if IsInToolsMode() then
            print("ability8 :" .. ability8:GetName())
            print("ability7 :" .. ability7:GetName())
            print("ability5 :" .. ability5:GetName())
            print("ability4 :" .. ability4:GetName())
            print("newAbility slotID:" .. slotId)
        end
        
        if slotId > -1 then
            local oldAbility = hero:GetAbilityByIndex(slotId)
            if oldAbility then
                print("oldAbility:" .. oldAbility:GetName())
                hero:RemoveAbilityByHandle(oldAbility)
            end
        end

        local newAbilityName = GetRandomAbilityName(hero)
        if IsInToolsMode() then
            newAbilityName = "mjz_general_granite_golem_hp_aura"
        end
        local newAbility = hero:AddAbility(newAbilityName)
        if newAbility then
            print("newAbility:" .. newAbilityName)
            
            if slotId > -1 then
                newAbility:SetAbilityIndex(slotId)
            end
            hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
            hero:RemoveItem(ability)

            return true
        end

        

        hero:ModifyGold(321, true, 0)
    end
end

function GetRandomAbilityName( hero )
    local abilityList = {
        "beastmaster_inner_beast",      -- 兽王    野性之心
        -- "skeleton_king_vampiric_aura",      --骷髅王2
        "skeleton_king_mortal_strike",      --骷髅王3
        "rattletrap_power_cogs",            --发条2
        "earth_spirit_rolling_boulder",     --大地之灵2
        "sven_great_cleave",                -- sven 2
        "kunkka_tidebringer",               -- 船长 2
        "pudge_flesh_heap",                 -- 屠夫 3
        "sven_warcry",                      -- 全能 3
        "shredder_reactive_armor",          -- 伐木机 3
        "tidehunter_gush",                  -- 潮汐 1
        "tidehunter_kraken_shell",          -- 潮汐 2
        "tidehunter_anchor_smash",          -- 潮汐 3
        "legion_commander_moment_of_courage",   -- 军团 3
        "night_stalker_hunter_in_the_night",        -- 夜魔 3
		"snapfire_firesnap_cookie",			-- 老奶奶 2
        -- "snapfire_lil_shredder",            -- 老奶奶 3
        "chaos_knight_chaos_strike",        -- 混沌3
        "magnataur_shockwave",              -- 猛犸 1
        "magnataur_empower",                -- 猛犸 2
        "magnataur_skewer",                 -- 猛犸 3
        "mars_gods_rebuke",                 -- 马尔斯 2
        "dragon_knight_dragon_blood",       -- 龙骑3
		"clinkz_strafe",					-- 小骷髅 扫射
        "juggernaut_healing_ward",          -- 剑圣2
        -- "juggernaut_blade_dance",           -- 剑圣3
        "templar_assassin_psi_blades",      -- TA 3
        "vengefulspirit_command_aura",      -- VS 3
        "naga_siren_mirror_image",          -- 小娜迦 1
        "naga_siren_rip_tide",              -- 小娜迦 3
        "nevermore_necromastery",           -- 影魔 4
        "nevermore_dark_lord",              -- 影魔 5
        "antimage_mana_break",              -- 敌法 1
        "ursa_overpower",                   -- 拍拍熊 2
        "ursa_fury_swipes",                 -- 拍拍熊 3
        "sniper_headshot",                  -- 火枪 2
        "sniper_take_aim",                  -- 火枪 3
        "gyrocopter_flak_cannon",           -- 飞机 3
        "medusa_split_shot",                -- 美杜莎 1
        "medusa_mana_shield",               -- 美杜莎 3
        "mirana_leap",                      -- 白虎 3
        "pangolier_lucky_shot",             -- 滚滚 3
        "meepo_ransack",                    -- 米波 3
        -- "weaver_geminate_attack",           -- 蚂蚁 3    bug
        "faceless_void_time_lock",          -- 虚空 3
        "bloodseeker_bloodrage",            -- 血魔 1
        "riki_blink_strike",                -- 赏金 2
        "luna_lunar_blessing",              -- 露娜 3
        "batrider_firefly",                 -- 蝙蝠 3
        "furion_teleportation",             -- 先知 2
        "skywrath_mage_ancient_seal",       -- 天怒 3
        -- "winter_wyvern_arctic_burn",        -- 冰龙 1
        "lion_voodoo",                      -- 巫医 2
        "necrolyte_sadist",                 -- 巫妖 2
        "disruptor_kinetic_field",          -- 干扰者 3
        "rubick_arcane_supremacy",          -- 拉比克 3
        "jakiro_liquid_fire",               -- 双头龙 3
        "obsidian_destroyer_arcane_orb",    -- 黑鸟 1
        "crystal_maiden_brilliance_aura",   -- 冰女 3
        "silencer_curse_of_the_silent",     -- 沉默 1
        "queenofpain_blink",                -- 女王 2
        -- "lina_fiery_soul",                  -- 丽娜 3
        "ancient_apparition_chilling_touch",    -- 冰魂 3
        "storm_spirit_overload",            -- 蓝猫 3
        "ogre_magi_bloodlust",              -- 蓝胖 3
        "enchantress_impetus",              -- 小鹿 1
        "dark_seer_surge",                  -- 黑贤 3
        "centaur_return",                   -- 人马 3
        "huskar_berserkers_blood",          -- 哈斯卡 3


        "kobold_taskmaster_speed_aura",     -- 狗头人 速度光环
        -- "ghost_frost_attack",               -- 鬼魂 寒霜攻击
        "centaur_khan_war_stomp",           -- 半人马 战争践踏
        -- "giant_wolf_critical_strike",       -- 头狼 致命一击
        -- "",     -- 泥土傀儡 碎土傀儡
        "mudgolem_cloak_aura",              --  魔抗光环 
        --"centaur_khan_endurance_aura",      -- 熊怪 迅捷光环
        --"enraged_wildkin_toughness_aura",             -- 坚韧光环
        "black_dragon_dragonhide_aura",     -- 龙肤光环 没有光环
        -- "black_dragon_splash_attack",       -- 溅射攻击
        "mjz_general_granite_golem_hp_aura",             -- 磐石光环
        "big_thunder_lizard_wardrums_aura",   --战鼓光环
        -- "roshan_bash",                      -- ROSHAN 重击
        "mjz_general_megamorph",            --巨大化

    }
    local randomIndex = RandomInt(1, #abilityList)

    return abilityList[randomIndex]
end