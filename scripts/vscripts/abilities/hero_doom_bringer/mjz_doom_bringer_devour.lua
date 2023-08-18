LinkLuaModifier("modifier_mjz_doom_bringer_devour","abilities/hero_doom_bringer/mjz_doom_bringer_devour.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_doom_bringer_devour_regen","abilities/hero_doom_bringer/mjz_doom_bringer_devour.lua", LUA_MODIFIER_MOTION_NONE)

mjz_doom_bringer_devour = class({})
function mjz_doom_bringer_devour:GetIntrinsicModifierName() return "modifier_mjz_doom_bringer_devour" end
if IsServer() then
	function mjz_doom_bringer_devour:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local devour_time = ability:GetSpecialValueFor("devour_time")
		local bonus_strength = GetTalentSpecialValueFor(ability, "bonus_strength")
		if target then
			EmitSoundOn("Hero_DoomBringer.DevourCast", caster)

			local p_name = "particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf"
			local pfx = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
    		ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
            ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:ReleaseParticleIndex(pfx)
			
			EmitSoundOn("Hero_DoomBringer.Devour", target)

			local modifier = caster:FindModifierByName('modifier_mjz_doom_bringer_devour')
			modifier:SetStackCount(modifier:GetStackCount() + bonus_strength)

            caster:AddNewModifier(caster, ability, 'modifier_mjz_doom_bringer_devour_regen', {duration = devour_time})
            
            self:_RandomGetAbility()
		end
    end
    
    function mjz_doom_bringer_devour:OnUpgrade()
        if self:GetLevel() == 1 then
            self:ToggleAutoCast()
        end
    end

    function mjz_doom_bringer_devour:_RandomGetAbility()
        local ability = self
        local caster = self:GetCaster()
        local hero = caster
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
        "tidehunter_kraken_shell",          -- 潮汐 2
        "tidehunter_anchor_smash",          -- 潮汐 3
        "legion_commander_moment_of_courage",   -- 军团 3
        "mjz_omniknight_degen_aura",        -- 夜魔 3
		"mjz_vengefulspirit_vengeance",			-- 老奶奶 2
        "mjz_troll_warlord_fervor",            -- 老奶奶 3
        "chaos_knight_chaos_strike",        -- 混沌3
        "mars_bulwark",              -- 猛犸 1
        "magnataur_empower",                -- 猛犸 2
        "legion_commander_custom_duel",                 -- 猛犸 3
        "alchemist_chemical_rage",                 -- 马尔斯 2
        "mjz_dragon_knight_dragon_blood",       -- 龙骑3
		--"mars_bulwark",					-- 小骷髅 扫射
        "juggernaut_healing_ward",          -- 剑圣2
        "juggernaut_blade_dance",
        "mjz_juggernaut_blade_fury",           -- 剑圣3
        "templar_assassin_psi_blades",      -- TA 3
        "mjz_vengefulspirit_vengeance",      -- VS 3
        "monkey_king_custom_jingu_mastery",          -- 小娜迦 1
        "alchemist_goblins_greed",              -- 小娜迦 3
        "mjz_omniknight_repel",           -- 影魔 4
        "lycan_feral_impulse",              -- 影魔 5
        "antimage_counterspell",              -- 敌法 1
        "mjz_ursa_overpower",                   -- 拍拍熊 2
        "ursa_fury_swipes",                 -- 拍拍熊 3
        "sniper_headshot",                  -- 火枪 2
        "lich_custom_cold_soul",                  -- 火枪 3
        --"mjz_invoker_magic_master",           -- 飞机 3
        --"medusa_split_shot",                -- 美杜莎 1
        --"medusa_mana_shield",               -- 美杜莎 3
        "mjz_broodmother_insatiable_hunger",                      -- 白虎 3
        "abyssal_underlord_atrophy_aura",             -- 滚滚 3
        "meepo_ransack",                    -- 米波 3
        "bloodseeker_thirst",           -- 蚂蚁 3    bug
        "void_custom_bash",          -- 虚空 3
        "mjz_lina_laguna_blade",            -- 血魔 1
        "mjz_clinkz_soul_pact",                -- 赏金 2
        "luna_lunar_blessing",              -- 露娜 3
        "elder_titan_natural_order",                 -- 蝙蝠 3
        "nyx_assassin_custom_vendetta",             -- 先知 2
        "skywrath_mage_ancient_seal",       -- 天怒 3
        "mjz_axe_counter_helix",        -- 冰龙 1
        --"dark_willow_bedlam",                      -- crash
        "alchemist_power_of_gold2",                 -- 巫妖 2
        "alchemist_power_of_gold",          -- 干扰者 3
        "rubick_arcane_supremacy",          -- 拉比克 3
        "jakiro_liquid_fire",               -- 双头龙 3
        "obsidian_destroyer_arcane_orb",    -- 黑鸟 1
        "mjz_crystal_maiden_brilliance_aura",   -- 冰女 3
        "mystic_dragon_endless_wisdom",     -- 沉默 1
        "imba_phantom_assassin_coup_de_grace",                -- 女王 2
        "dzzl_good_juju",                  -- 丽娜 3
        "ancient_apparition_chilling_touch",    -- 冰魂 3
        --"roshan_inherit_buff_datadriven",            -- 蓝猫 3
        "ogre_magi_multicast_n",              -- 蓝胖 3
        "enchantress_impetus",              -- 小鹿 1
        "dark_seer_custom_ion_shell",                  -- 黑贤 3
        "mjz_centaur_return",                   -- 人马 3
        --"huskar_berserkers_blood",          -- 哈斯卡 3
        "bane_enfeeble",           -- 半人马 战争践踏
        "phantom_lancer_phantom_edge",       -- 头狼 致命一击
        "kobold_taskmaster_speed_aura",     -- 狗头人 速度光环
        -- "",     -- 泥土傀儡 碎土傀儡
        --mjz_general_granite_golem_hp_aura,              --  魔抗光环 
        --"centaur_khan_endurance_aura",      -- 熊怪 迅捷光环
        --"enraged_wildkin_toughness_aura",             -- 坚韧光环
        --"black_dragon_dragonhide_aura",     -- 龙肤光环 没有光环
        --"black_dragon_splash_attack",       -- 溅射攻击
        "mjz_general_granite_golem_hp_aura",             -- 磐石光环
        "big_thunder_lizard_wardrums_aura",   --战鼓光环
        "custom_aphotic_shield",                      -- ROSHAN 重击
        "mjz_general_megamorph",            --巨大化 
        "beastmaster_inner_beast",      -- 兽王    野性之心
        "skeleton_king_vampiric_aura",      --骷髅王2
        "skeleton_king_mortal_strike",      --骷髅王3
        "spirit_breaker_greater_bash",            --发条2
        --"drow_ranger_marksmanship",     --大地之灵2
        "sven_great_cleave",                -- sven 2
        "mjz_kunkka_tidebringer",               -- 船长 2
        "mjz_pudge_flesh_heap",                 -- 屠夫 3
        "mjz_obsidian_destroyer_essence_aura",                      -- 全能 3
        "shredder_reactive_armor",          -- 伐木机 3
        "mjz_night_stalker_hunter_in_the_night",                  -- 潮汐 1
        "tidehunter_kraken_shell",          -- 潮汐 2
        "tidehunter_anchor_smash",          -- 潮汐 3
        "legion_commander_moment_of_courage",   -- 军团 3
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
        "juggernaut_blade_dance",
        --"mjz_juggernaut_blade_fury",           -- 剑圣3
        "templar_assassin_psi_blades",      -- TA 3
        "mjz_vengefulspirit_vengeance",      -- VS 3
        "monkey_king_custom_jingu_mastery",          -- 小娜迦 1
        "alchemist_goblins_greed",              -- 小娜迦 3
        "mjz_omniknight_repel",           -- 影魔 4
        "lycan_feral_impulse",              -- 影魔 5
        "antimage_counterspell",              -- 敌法 1
        "mjz_ursa_overpower",                   -- 拍拍熊 2
        "ursa_fury_swipes",                 -- 拍拍熊 3
        "sniper_headshot",                  -- 火枪 2
        --"lich_custom_cold_soul",                  -- 火枪 3
        --"mjz_invoker_magic_master",           -- 飞机 3
        --"medusa_split_shot",                -- 美杜莎 1
        "medusa_mana_shield",               -- 美杜莎 3
        "mjz_broodmother_insatiable_hunger",                      -- 白虎 3
        "abyssal_underlord_atrophy_aura",             -- 滚滚 3
        "meepo_ransack",                    -- 米波 3
        "bloodseeker_thirst",           -- 蚂蚁 3    bug
        "void_custom_bash",          -- 虚空 3
        "mjz_lina_laguna_blade",            -- 血魔 1
        "mjz_clinkz_soul_pact",                -- 赏金 2
        "luna_lunar_blessing",              -- 露娜 3
        "elder_titan_natural_order",                 -- 蝙蝠 3
        "nyx_assassin_custom_vendetta",             -- 先知 2
        "skywrath_mage_ancient_seal",       -- 天怒 3
        "mjz_axe_counter_helix",        -- 冰龙 1
        --"dark_willow_bedlam",                      -- 巫医 2
        --"alchemist_power_of_gold2",                 -- 巫妖 2
        "alchemist_power_of_gold",          -- 干扰者 3
        "rubick_arcane_supremacy",          -- 拉比克 3
        "jakiro_liquid_fire",               -- 双头龙 3
        "obsidian_destroyer_arcane_orb",    -- 黑鸟 1
        "mjz_crystal_maiden_brilliance_aura",   -- 冰女 3
        "mystic_dragon_endless_wisdom",     -- 沉默 1
        "imba_phantom_assassin_coup_de_grace",                -- 女王 2
        --"dazzle_bad_juju",                  -- 丽娜 3
        "ancient_apparition_chilling_touch",    -- 冰魂 3
        "roshan_inherit_buff_datadriven",            -- 蓝猫 3
        --"ogre_magi_custom_multicast",              -- 蓝胖 3
        "enchantress_impetus",              -- 小鹿 1
        "dark_seer_custom_ion_shell",                  -- 黑贤 3
        "mjz_centaur_return",                   -- 人马 3
        "huskar_berserkers_blood",          -- 哈斯卡 3
        "faceless_void_backtrack",               -- 鬼魂 寒霜攻击
        "bane_enfeeble",           -- 半人马 战争践踏
        "phantom_lancer_phantom_edge",       -- 头狼 致命一击
        --"kobold_taskmaster_speed_aura",     -- 狗头人 速度光环
        -- "",     -- 泥土傀儡 碎土傀儡
        --mjz_general_granite_golem_hp_aura,              --  魔抗光环 
        --"centaur_khan_endurance_aura",      -- 熊怪 迅捷光环
        --"enraged_wildkin_toughness_aura",             -- 坚韧光环
        --"black_dragon_dragonhide_aura",     -- 龙肤光环 没有光环
        --"black_dragon_splash_attack",       -- 溅射攻击
        "mjz_general_granite_golem_hp_aura",             -- 磐石光环
        "big_thunder_lizard_wardrums_aura",   --战鼓光环
        "custom_aphotic_shield",                      -- ROSHAN 重击
        "mjz_general_megamorph",            --巨大化 
        "viper_corrosive_skin",
        "viper_corrosive_skin",
        "drow_ranger_frost_arrows_lua",
        --"mjz_templar_assassin_proficiency",
        "mjz_chaos_knight_chaos_strike", 
        "mjz_treant_natures_guise",
        "mjz_treant_natures_guise",
        --"terrorblade_metamorphosis",
        "lycan_shapeshift", 
        "ogre_magi_multicast_lua",
        "juggernaut_blade_dance_lua",
        "lion_custom_finger_of_death",
        "vengefulspirit_command_aura_lua",
        "mjz_lina_laguna_blade",
        "drow_ranger_frost_arrows_lua",
        "omniknight_repel_lua",
        "antimage_custom_mana_break",
        "frostivus2018_faceless_void_time_walk",
        "mjz_phoenix_icarus_dive",
        "mjz_zuus_thundergods_wrath",
        "mjz_queenofpain_sonic_wave",
        "earthshaker_aftershock_lua",
        "earthshaker_echo_slam_lua",
        "mjz_phoenix_icarus_dive",
        "mjz_zuus_thundergods_wrath",
        "mjz_queenofpain_sonic_wave",
        "earthshaker_aftershock_lua",
        "earthshaker_echo_slam_lua",
        "nevermore_custom_necromastery",
        "nevermore_custom_necromastery",
        "mjz_arc_warden_spark_wraith",
        "mjz_arc_warden_spark_wraith", 
        --"phantom_assassin_fan_of_knives", --does not work
        --"phantom_assassin_fan_of_knives",
        "mjz_necrolyte_heartstopper_aura",
        "mjz_slark_dark_pact", 
        "mjz_lifestealer_poison_sting",
        "legion_commander_duel_lua",
        "lich_chain_frost",
        "weaver_the_swarm",
        "hoodwink_scurry",
        "hoodwink_acorn_shot",
        "dark_willow_bedlam_lua",
        "grimstroke_custom_soulstore",
        "weaver_the_swarm",
        "hoodwink_scurry",
        "hoodwink_acorn_shot",
        "custom_mana_regen",
        "custom_mana_regen2",
        "mjz_crystal_maiden_frostbite",
        "enchantress_untouchable",
        "nevermore_dark_lord",
        "bristleback_warpath_lua",
        --"obs_replay",
		"jotaro_absolute_defense3",
		"zanto_gari",
		"blood_madness",
		"clinkz_infernal_breath",
		"mjz_bloodseeker_thirst",
		"mjz_clinkz_death_pact",
		"custom_side_gunner",
        "medusa_custom_stone_arrows",
        "brewmaster_drunken_brawler", 
        "grow_strong", 
        "vengefulspirit_wave_of_terror_lua",                           
    
        }
        local newAbilityName = abilityList[ RandomInt(1, #abilityList) ]
        local exclude_table = {
            faceless_void_backtrack = true,
            phantom_reflex = true,

        }       
        if ability:GetAutoCastState() and not hero:HasAbility(newAbilityName) and hero:IsRealHero() then
            if exclude_table[newAbilityName] then
                if hero:HasAbility("phantom_reflex") or hero:HasAbility("faceless_void_backtrack") then
                    --print(newAbilityName .. " nope")
                    ability:EndCooldown()
                    --ability:OnSpellStart()
                    return
                end
            end            
            local abilityPoints = 1
            local slotId = 3
            if slotId > -1 then
                local oldAbility = hero:GetAbilityByIndex(slotId)
                if oldAbility then
                    -- print("oldAbility:" .. oldAbility:GetName())
                    abilityPoints = oldAbility:GetLevel()
                    hero:RemoveAbilityByHandle(oldAbility)
                end
            end

            if IsInToolsMode() then
                -- newAbilityName = "mjz_general_megamorph"
            end
            local newAbility = hero:AddAbility(newAbilityName)
            if newAbility then
                -- print("newAbility:" .. newAbilityName)
                if slotId > -1 then
                    newAbility:SetAbilityIndex(slotId)
                end
                hero:SetAbilityPoints(hero:GetAbilityPoints() + abilityPoints)
                if hero:HasModifier("modifier_medusa_mana_shield") then
                    hero:RemoveModifierByName("modifier_medusa_mana_shield")
                end
            end    
        end
    end
end

-----------------------------------------------------------------------------
modifier_mjz_doom_bringer_devour = class({})
function modifier_mjz_doom_bringer_devour:IsPassive() return false end
function modifier_mjz_doom_bringer_devour:IsHidden() return (self:GetStackCount() < 1) end
function modifier_mjz_doom_bringer_devour:IsPurgable() return false end
function modifier_mjz_doom_bringer_devour:RemoveOnDeath() return false end
function modifier_mjz_doom_bringer_devour:AllowIllusionDuplicate() return true end
function modifier_mjz_doom_bringer_devour:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_mjz_doom_bringer_devour:GetModifierBonusStats_Strength() return self:GetStackCount() end
function modifier_mjz_doom_bringer_devour:OnCreated()
    if not IsServer() then return nil end
    local parent = self:GetParent()
    if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
        local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
        if owner then       
            if parent:HasModifier("modifier_mjz_doom_bringer_devour") then
				local stacks = self:GetStackCount()
                self:SetStackCount(stacks)
            end    
        end    
    end    
end    
function modifier_mjz_doom_bringer_devour:OnDestroy() end

-----------------------------------------------------------------------------
modifier_mjz_doom_bringer_devour_regen = class({})
function modifier_mjz_doom_bringer_devour_regen:IsHidden() return true end
function modifier_mjz_doom_bringer_devour_regen:IsPurgable() return false end
function modifier_mjz_doom_bringer_devour_regen:IsBuff() return true end
function modifier_mjz_doom_bringer_devour_regen:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_mjz_doom_bringer_devour_regen:OnCreated(kv) self.regen = self:GetAbility():GetSpecialValueFor("regen") end
function modifier_mjz_doom_bringer_devour_regen:OnRefresh(kv) self.regen = self:GetAbility():GetSpecialValueFor("regen") end
function modifier_mjz_doom_bringer_devour_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_mjz_doom_bringer_devour_regen:GetModifierConstantHealthRegen(params) return self.regen end














-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end