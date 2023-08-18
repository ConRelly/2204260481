
function OnSpellStart( keys )
    local caster = keys.caster
    local ability = keys.ability
    local unit = keys.unit
    local hero = caster
    if hero:HasModifier("modifier_arc_warden_tempest_double") then
        ability:SetActivated(false)
		return
    end
    if hero:IsRealHero() then
--[[
		local ability4 = hero:GetAbilityByIndex(3)
		local ability5 = hero:GetAbilityByIndex(4)
		local ability7 = hero:GetAbilityByIndex(6)
		local ability8 = hero:GetAbilityByIndex(7)
]]
		local slotId = -1
--[[
		if ability4 then slotId = 4 end
		if ability5 then slotId = 6 end
		if ability7 then slotId = 8 end
		if ability8 then slotId = nil end
		if ability8 == nil or ability8:GetName() == "generic_hidden" then slotId = 7 end
		if ability7 == nil or ability7:GetName() == "generic_hidden" then slotId = 6 end
		if ability5 == nil or ability5:GetName() == "generic_hidden" then slotId = 4 end
		if ability4 == nil or ability4:GetName() == "generic_hidden" then slotId = 3 end
		if ability8 == nil then slotId = 7 end
		if ability7 == nil then slotId = 6 end
]]
		if hero:GetAbilityByIndex(3) == nil then
			slotId = -1
		elseif hero:GetAbilityByIndex(3):GetName() == "generic_hidden" then
			slotId = 3
		elseif hero:GetAbilityByIndex(4):GetName() == "generic_hidden" then
			slotId = 4
		end

--[[
		if IsInToolsMode() then
			print("ability8 :" .. ability8:GetName())
			print("ability7 :" .. ability7:GetName())
			print("ability5 :" .. ability5:GetName())
			print("ability4 :" .. ability4:GetName())
			print("newAbility slotID:" .. slotId)
		end
]]
		if slotId > -1 then
			local oldAbility = hero:GetAbilityByIndex(slotId)
			if oldAbility then
				print("oldAbility:" .. oldAbility:GetName())
				hero:RemoveAbilityByHandle(oldAbility)
			end
		end
        local found_valid_ability = false
        while not found_valid_ability do
            local newAbilityName = GetRandomAbilityName(hero)                                            
            if not hero:HasAbility(newAbilityName) then
                local newAbility = hero:AddAbility(newAbilityName)      
                print("newAbility:" .. newAbilityName)  
--				if slotId > -1 then                          
--					newAbility:SetAbilityIndex(slotId)
--				end
                hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
                found_valid_ability = true
                hero:RemoveItem(ability)
                hero:ModifyGold(321, true, 0)
                return true                                                    
            end                                                    
        end
    end
end

function GetRandomAbilityName( hero )                 
    local abilityList = {
        "beastmaster_inner_beast",      -- 兽王    野性之心
        "skeleton_king_vampiric_aura",      --骷髅王2
        "skeleton_king_mortal_strike",      --骷髅王3
        "spirit_breaker_greater_bash",            --发条2
        "drow_ranger_marksmanship",     --大地之灵2
        "sven_great_cleave",                -- sven 2
        "mjz_kunkka_tidebringer",               -- 船长 2
        "mjz_pudge_flesh_heap",                 -- 屠夫 3
        "mjz_obsidian_destroyer_essence_aura",                      -- 全能 3
        "shredder_reactive_armor",          -- 伐木机 3
        "mjz_night_stalker_hunter_in_the_night",                  -- 潮汐 1
        "phantom_assassin_blur",          -- 潮汐 2
        "tidehunter_anchor_smash",          -- 潮汐 3
        "mjz_tiny_craggy_exterior",   -- 军团 3
        "mjz_omniknight_degen_aura",        -- 夜魔 3
		"mjz_vengefulspirit_vengeance",			-- 老奶奶 2
        "mjz_troll_warlord_fervor",            -- 老奶奶 3
        "chaos_knight_chaos_strike",        -- 混沌3
        "mars_bulwark",              -- 猛犸 1
        "magnataur_empower",                -- 猛犸 2
        "legion_commander_custom_duel",                 -- 猛犸 3
        "alchemist_chemical_rage",                 -- 马尔斯 2
        "mjz_dragon_knight_dragon_blood",       -- 龙骑3
		"mars_bulwark",					-- 小骷髅 扫射
        "juggernaut_healing_ward",          -- 剑圣2
        "mjz_juggernaut_blade_fury",           -- 剑圣3
        "templar_assassin_psi_blades",      -- TA 3
        "mjz_vengefulspirit_vengeance",      -- VS 3
        "monkey_king_custom_jingu_mastery",          -- 小娜迦 1
        "alchemist_goblins_greed",              -- 小娜迦 3
        "mjz_omniknight_repel",           -- 影魔 4
        "mjz_huskar_berserkers_blood",              -- 影魔 5
        "mjz_antimage_counterspell",              -- 敌法 1
        "mjz_ursa_overpower",                   -- 拍拍熊 2
        "ursa_fury_swipes",                 -- 拍拍熊 3
        "sniper_headshot_lua",                  -- 火枪 2
        "lich_custom_cold_soul",                  -- 火枪 3
        "mjz_invoker_magic_master",           -- 飞机 3
        "medusa_split_shot",                -- 美杜莎 1
        "medusa_mana_shield",               -- 美杜莎 3
        "mjz_broodmother_insatiable_hunger",                      -- 白虎 3
        "abyssal_underlord_atrophy_aura",             -- 滚滚 3
        "meepo_ransack",                    -- 米波 3
        "bloodseeker_thirst",           -- 蚂蚁 3    bug
        "faceless_void_time_lock",          -- 虚空 3
        "mjz_lina_laguna_blade",            -- 血魔 1
        "mjz_clinkz_soul_pact",                -- 赏金 2
        "luna_lunar_blessing",              -- 露娜 3
        "elder_titan_natural_order",                 -- 蝙蝠 3
        "nyx_assassin_custom_vendetta",             -- 先知 2
        "skywrath_mage_ancient_seal",       -- 天怒 3
        "mjz_axe_counter_helix",        -- 冰龙 1
        --"dark_willow_bedlam",                      -- 巫医 2
        "alchemist_power_of_gold2",                 -- 巫妖 2
        "alchemist_power_of_gold",          -- 干扰者 3
        "rubick_arcane_supremacy",          -- 拉比克 3
        "jakiro_liquid_fire",               -- 双头龙 3
        "obsidian_destroyer_arcane_orb",    -- 黑鸟 1
        "mjz_crystal_maiden_brilliance_aura",   -- 冰女 3
        "mystic_dragon_endless_wisdom",     -- 沉默 1
        "imba_phantom_assassin_coup_de_grace",                -- 女王 2
        "dazzle_bad_juju",                  -- 丽娜 3
        "ancient_apparition_chilling_touch",    -- 冰魂 3
        "grow_strong",            -- 蓝猫 3
        "ogre_magi_multicast_n",              -- 蓝胖 3
        "enchantress_impetus",              -- 小鹿 1
        "dark_seer_custom_ion_shell",                  -- 黑贤 3
        "mjz_centaur_return",                   -- 人马 3
        "huskar_berserkers_blood",          -- 哈斯卡 3

        --"pangolier_heartpiercer_oaa",     
        "faceless_void_backtrack",         --3
        "bane_enfeeble",           -- 2
        "phantom_lancer_phantom_edge",       -- 1
        "ryze_arcane_mastery",     --4
        "juggernaut_blade_dance_lua",              --  魔抗光环 
        "vengefulspirit_command_aura_lua",      -- 熊怪 迅捷光环
        "omniknight_repel_lua",             -- 坚韧光环
        "doom_devour_lua",     -- 龙肤光环 没有光环
        "lion_custom_finger_of_death",       -- 溅射攻击
        "mjz_general_granite_golem_hp_aura",             -- 磐石光环
        "big_thunder_lizard_wardrums_aura",   --战鼓光环
        "phantom_reflex",
        "custom_aphotic_shield",                      -- ROSHAN 重击
        "mjz_general_megamorph",            --巨大化
    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]   
end
