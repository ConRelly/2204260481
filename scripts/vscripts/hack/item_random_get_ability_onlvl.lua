
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
		local exclude_table = {
			faceless_void_backtrack = true,
			phantom_reflex = true,

		}		
		local found_valid_ability = false
		while not found_valid_ability do
			local newAbilityName = GetRandomAbilityName(hero)											
			if not hero:HasAbility(newAbilityName) then
				if exclude_table[newAbilityName] then
					if hero:HasAbility("phantom_reflex") or hero:HasAbility("faceless_void_backtrack") then
						--print(newAbilityName .. " nope")
						--ability:EndCooldown()
						ability:OnSpellStart()
						return
					end
				end 
				if hero:HasAbility("shadow_demon_custom_hyperactivity") then
					if newAbilityName == "obs_replay" then
						--print(newAbilityName .. " nope2")
						ability:OnSpellStart() 
						return							
					end	
				end
				if newAbilityName == "clinkz_infernal_breath" then
					if hero:HasAbility("mjz_phantom_assassin_coup_de_grace") then
						ability:OnSpellStart() 
						return							
					end	
				end
				if newAbilityName == "mjz_clinkz_death_pact" then
					if hero:HasAbility("mjz_clinkz_soul_pact") then
						ability:OnSpellStart()
						return
					end
				end
				local newAbility = hero:AddAbility(newAbilityName)	  
				print("newAbility:" .. newAbilityName)  
				if slotId > -1 then						  
					newAbility:SetAbilityIndex(slotId)
				end
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
		"beastmaster_inner_beast",	  -- 兽王	野性之心
		"skeleton_king_vampiric_aura",	  --骷髅王2
		"skeleton_king_mortal_strike",	  --骷髅王3
		"spirit_breaker_greater_bash",			--发条2
		--"drow_ranger_marksmanship",	 --大地之灵2
		"sven_great_cleave",				-- sven 2
		"mjz_kunkka_tidebringer",			   -- 船长 2
		"mjz_pudge_flesh_heap",				 -- 屠夫 3
		"mjz_obsidian_destroyer_essence_aura",					  -- 全能 3
		--"shredder_reactive_armor",		  -- 伐木机 3
		"mjz_night_stalker_hunter_in_the_night",				  -- 潮汐 1
		"phantom_assassin_blur",		  -- 潮汐 2
		"tidehunter_anchor_smash",		  -- 潮汐 3
		"mjz_tiny_craggy_exterior",   -- 军团 3
		"mjz_omniknight_degen_aura",		-- 夜魔 3
		"mjz_vengefulspirit_vengeance",			-- 老奶奶 2
		"mjz_troll_warlord_fervor",			-- 老奶奶 3
		"chaos_knight_chaos_strike",		-- 混沌3
		"mars_bulwark",			  -- 猛犸 1
		"magnataur_empower",				-- 猛犸 2
		"legion_commander_custom_duel",				 -- 猛犸 3
		"alchemist_chemical_rage",				 -- 马尔斯 2
		"mjz_dragon_knight_dragon_blood",	   -- 龙骑3
		"mars_bulwark",					-- 小骷髅 扫射
		"juggernaut_healing_ward",		  -- 剑圣2
		"mjz_juggernaut_blade_fury",		   -- 剑圣3
		"templar_assassin_psi_blades",	  -- TA 3
		"mjz_vengefulspirit_vengeance",	  -- VS 3
		"monkey_king_custom_jingu_mastery",		  -- 小娜迦 1
		"alchemist_goblins_greed",			  -- 小娜迦 3
		"mjz_omniknight_repel",		   -- 影魔 4
		"lycan_feral_impulse",			  -- 影魔 5
		"antimage_counterspell",			  -- 敌法 1 crash with snowball 
		"mjz_ursa_overpower",				   -- 拍拍熊 2
		"ursa_fury_swipes",				 -- 拍拍熊 3
		"lich_custom_cold_soul",				  -- 火枪 3
		"mjz_invoker_magic_master",		   -- 飞机 3
		--"medusa_split_shot",				-- 美杜莎 1
		"medusa_mana_shield",			   -- 美杜莎 3
		"mjz_broodmother_insatiable_hunger",					  -- 白虎 3
		"abyssal_underlord_atrophy_aura",			 -- 滚滚 3
		"meepo_ransack",					-- 米波 3
		"bloodseeker_thirst",		   -- 蚂蚁 3	bug
		"faceless_void_time_lock",		  -- 虚空 3
		"mjz_lina_laguna_blade",			-- 血魔 1
		--"luna_lunar_blessing",			  -- 露娜 3
		"elder_titan_natural_order",				 -- 蝙蝠 3
		"nyx_assassin_custom_vendetta",			 -- 先知 2
		--"skywrath_mage_ancient_seal",	   -- 天怒 3
		"mjz_axe_counter_helix",		-- 冰龙 1 crash on snowball
		--"dark_willow_bedlam",					  -- 巫医 2
		"alchemist_power_of_gold2",				 -- 巫妖 2
		"alchemist_power_of_gold",		  -- 干扰者 3
		"rubick_arcane_supremacy",		  -- 拉比克 3
		"jakiro_liquid_fire",			   -- 双头龙 3
		"obsidian_destroyer_arcane_orb",	-- 黑鸟 1
		"mjz_crystal_maiden_brilliance_aura",   -- 冰女 3
		"mystic_dragon_endless_wisdom",	 -- 沉默 1
		"imba_phantom_assassin_coup_de_grace",				-- 女王 2
		"dazzle_bad_juju_custom",				  -- 丽娜 3
		"ancient_apparition_chilling_touch",	-- 冰魂 3
		"roshan_inherit_buff_datadriven",			-- 蓝猫 3
		"ogre_magi_multicast_n",			  -- 蓝胖 3
		"enchantress_impetus",			  -- 小鹿 1
		"dark_seer_custom_ion_shell",				  -- 黑贤 3
		"mjz_centaur_return",				   -- 人马 3
		"huskar_berserkers_blood",		  -- 哈斯卡 3

		--"antimage_spell_shield",	 
		"faceless_void_backtrack",		 --3
		--"bane_enfeeble",		   -- 2
		"phantom_lancer_phantom_edge",	   -- 1
		"ryze_arcane_mastery",	 --4
		"juggernaut_blade_dance_lua",			  --  魔抗光环 
		"vengefulspirit_command_aura_lua",	  -- 熊怪 迅捷光环
		"omniknight_repel_lua",			 -- 坚韧光环
		"doom_devour_lua",	 -- 龙肤光环 没有光环
		"lion_custom_finger_of_death",	   -- 溅射攻击
		"big_thunder_lizard_wardrums_aura",   --战鼓光环
		"phantom_reflex",
		"custom_aphotic_shield",					  -- ROSHAN 重击
		"mjz_general_megamorph",			--巨大化
		"ogre_magi_multicast_lua",
		"juggernaut_omni_slash",
		"lycan_feral_impulse",
		"viper_corrosive_skin",
		"drow_ranger_frost_arrows_lua",
		"drow_ranger_multishot_lua",
		"aghanim_blink2",
		--"mjz_templar_assassin_proficiency",
		"mjz_chaos_knight_chaos_strike",
		"mjz_treant_natures_guise",
		--"terrorblade_metamorphosis",
		"lycan_shapeshift",
		"chen_custom_avatar",
		"mjz_doom_bringer_doom",
		"antimage_custom_mana_break",
		"frostivus2018_faceless_void_time_walk",
		"dark_willow_shadow_realm_lua",
		"mjz_leshrac_pulse_nova",
		"witch_doctor_custom_death_skull",
		"mjz_phoenix_icarus_dive",
		"mjz_zuus_thundergods_wrath",
		"mjz_queenofpain_sonic_wave",
		"earthshaker_aftershock_lua",
		"earthshaker_echo_slam_lua",
		"mjz_slark_dark_pact",
		"mjz_slark_essence_shift",
		"nevermore_custom_necromastery",
		"mjz_arc_warden_spark_wraith", 
		--"phantom_assassin_fan_of_knives",
		"back_in_time",
		"mjz_necrolyte_heartstopper_aura",
		"mjz_lifestealer_poison_sting",
		"legion_commander_duel_lua",
		"lich_chain_frost",
		"weaver_the_swarm",
		"hoodwink_scurry",
		"hoodwink_custom_acorn_shot",
		"dark_willow_bedlam_lua",
		"grimstroke_custom_soulstore",
		"custom_mana_regen",
		"custom_mana_regen2",
		"mjz_crystal_maiden_frostbite",
		"enchantress_untouchable",
		"nevermore_dark_lord",
		"bristleback_warpath_lua",
		"obs_replay",
		"jotaro_absolute_defense3",
		"zanto_gari",
		"blood_madness",
		"clinkz_infernal_breath",
		"mjz_bloodseeker_thirst",
		"mjz_clinkz_death_pact",
		"custom_side_gunner",
	}
	local randomIndex = RandomInt(1, #abilityList)
	return abilityList[randomIndex]   
end
