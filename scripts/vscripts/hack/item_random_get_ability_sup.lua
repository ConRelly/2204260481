
function OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.unit
	local hero = caster
	if caster:IsNull() then return end
	if hero:HasModifier("modifier_arc_warden_tempest_double") then
		ability:SetActivated(false)
		return
	end
	if hero:IsRealHero() then

		local GenericSlots = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local abil = caster:GetAbilityByIndex(i)
			if abil then
				if abil:GetAbilityName() == "generic_hidden" then
					GenericSlots = GenericSlots + 1
				end
			end
		end
		if GenericSlots > 0 then
			for i = 0, caster:GetAbilityCount() - 1 do
				local abil = caster:GetAbilityByIndex(i)
				if abil then
					if abil:GetAbilityName() == "generic_hidden" then
						caster:RemoveAbility("generic_hidden")
					end
				end
			end
			if GenericSlots > 1 then
				for i = 1, GenericSlots - 1 do
					caster:AddAbility("generic_hidden")
				end
			end
		end

		if caster:GetName() ~= "npc_dota_hero_monkey_king" then
			for i=0, caster:GetAbilityCount() - 1 do
				local hAbility = caster:GetAbilityByIndex( i )
				if hAbility and not hAbility:IsNull() and not hAbility:IsCosmetic( nil ) then
					local hAbility_name = hAbility:GetAbilityName()
					if hAbility_name == "ability_capture" then
--						print("Remove: " .. hAbility_name)
						if caster and caster:HasAbility(hAbility_name) then
							caster:RemoveAbility(hAbility_name)
						end
					end
				end	
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
				if newAbilityName == "dzzl_good_juju" then
					if hero:HasAbility("dazzle_good_juju") then
						ability:OnSpellStart() 
						return
					end
				end
				local newAbility = hero:AddAbility(newAbilityName)
--				print("newAbility:" .. newAbilityName)
				hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
				found_valid_ability = true
				--hero:RemoveItem(ability)
				hero:TakeItem(ability)
				hero:ModifyGold(321, true, 0)
				return true
			end
		end
	end
end

function GetRandomAbilityName( hero )
	local abilityList = {
		"beastmaster_inner_beast",
		--"skeleton_king_vampiric_aura",
		--"skeleton_king_mortal_strike",
		--"spirit_breaker_greater_bash",
		--"drow_ranger_marksmanship",
		--"sven_great_cleave",
		--"mjz_kunkka_tidebringer",
		"mjz_pudge_flesh_heap",
		--"mjz_obsidian_destroyer_essence_aura",
		--"shredder_reactive_armor",
		"mjz_night_stalker_hunter_in_the_night",
		--"phantom_assassin_blur",
		"tidehunter_anchor_smash",
		"mjz_tiny_craggy_exterior",
		--"mjz_omniknight_degen_aura",
		"mjz_troll_warlord_fervor",
		"chaos_knight_chaos_strike",
		--"mars_bulwark",
		--"magnataur_empower",
		"legion_commander_custom_duel",
		"alchemist_chemical_rage",
		"mjz_dragon_knight_dragon_blood",
		--"mars_bulwark",
		--"juggernaut_healing_ward",
		"mjz_juggernaut_blade_fury",
		--"templar_assassin_psi_blades",
		"juggernaut_duelist", --innate1
		"leshrac_defilement", --innate2			
		"mjz_vengefulspirit_vengeance",
		"monkey_king_custom_jingu_mastery",
		"alchemist_goblins_greed",
		"alchemist_goblins_greed",
		"alchemist_goblins_greed",
		"mjz_omniknight_repel",
		"lycan_feral_impulse",
		"antimage_counterspell",
		--"antimage_spell_shield",
		"ursa_fury_swipes",
		"lich_custom_cold_soul",
		"mjz_invoker_magic_master",
		--"medusa_split_shot",
		"medusa_mana_shield",
		"mjz_broodmother_insatiable_hunger",
		--"abyssal_underlord_atrophy_aura",
		--"meepo_ransack",
		--"bloodseeker_thirst",
		"void_custom_bash",
		"mjz_lina_laguna_blade",
		"mjz_clinkz_soul_pact",
		--"luna_lunar_blessing",
		"elder_titan_natural_order",
		"elder_titan_natural_order",
		"nyx_assassin_custom_vendetta",
		--"skywrath_mage_ancient_seal",
		--"mjz_axe_counter_helix",
		--"dark_willow_bedlam_lua",
		"alchemist_power_of_gold2",
		"alchemist_power_of_gold",
		"rubick_arcane_supremacy",
		--"jakiro_liquid_fire",
		"obsidian_destroyer_arcane_orb",
		"mjz_crystal_maiden_brilliance_aura",
		"mystic_dragon_endless_wisdom",
		"lion_to_hell_and_back", --innate3
		"obsidian_destroyer_ominous_discernment", --innate4			
		"imba_phantom_assassin_coup_de_grace",
		"dzzl_good_juju",
		"ancient_apparition_chilling_touch",
		"grow_strong",
		"ogre_magi_multicast_n",
		--"enchantress_impetus",
		--"dark_seer_custom_ion_shell",
		--"mjz_centaur_return",
		"huskar_berserkers_blood",
		--"pangolier_heartpiercer_oaa",	 
		"faceless_void_backtrack",
		--"bane_enfeeble",
		"phantom_lancer_phantom_edge",
		"ryze_arcane_mastery",
		"juggernaut_blade_dance_lua",
		"vengefulspirit_command_aura_lua",
		"omniknight_repel_lua",
		"doom_devour_lua",
		"lion_custom_finger_of_death",
		"mjz_general_granite_golem_hp_aura",
		"spectre_einherjar_lua",
		-- "roshan_bash",
		"mjz_general_megamorph",
		"ogre_magi_multicast_lua",
		"tinker_eureka", --innate5
		"rattletrap_armor_power", --innate6			
		"juggernaut_omni_slash",
		"viper_corrosive_skin",
		"drow_ranger_frost_arrows_lua",
		"drow_ranger_frost_arrows_lua",
		"drow_ranger_multishot_lua",
		"drow_ranger_multishot_lua",
		"aghanim_blink2",
		--"mjz_templar_assassin_proficiency",
		"mjz_chaos_knight_chaos_strike",
		"mjz_treant_natures_guise",
		"mjz_treant_natures_guise",
		--"terrorblade_metamorphosis",
		"lycan_shapeshift",
		"chen_custom_avatar",
		"mjz_doom_bringer_doom",
		"ursa_maul", --innate7
		"razor_dynamo", --innate8			
		"antimage_custom_mana_break",
		"faceless_void_time_walk",
		"dark_willow_shadow_realm_lua",
		"mjz_leshrac_pulse_nova",
		"witch_doctor_custom_death_skull",
		"mjz_phoenix_icarus_dive",
		"mjz_zuus_thundergods_wrath",
		"mjz_queenofpain_sonic_wave",
		"earthshaker_aftershock_lua",
		"spirit_breaker_herd_mentality", --innate12
		"earthshaker_echo_slam_lua",
		"phantom_reflex",
		--"mjz_slark_dark_pact",
		"mjz_slark_essence_shift",
		"nevermore_custom_necromastery",
		"mjz_arc_warden_spark_wraith",
		"venomancer_sepsis", --innate13
		"custom_aphotic_shield",
		--"phantom_assassin_fan_of_knives",
		"mjz_necrolyte_heartstopper_aura",
		"mjz_lifestealer_poison_sting",
		"legion_commander_duel_lua", 
		--"lich_chain_frost",
		"weaver_the_swarm",
		--"hoodwink_scurry",
		--"hoodwink_acorn_shot",
		"custom_mana_regen",
		"custom_mana_regen2",
		"mjz_crystal_maiden_frostbite",
		--"enchantress_untouchable",
		"nevermore_dark_lord", 
		"bristleback_warpath_lua",
		--"obs_replay",
		"beastmaster_wild_axes",
		"jotaro_absolute_defense3",
		"treant_innate_attack_damage", --innate9
		"rubick_might_and_magus", --innate10		
		"zanto_gari",
		"blood_madness",
		"clinkz_infernal_breath",
		"mjz_bloodseeker_thirst",
		"custom_side_gunner",
		"centaur_rawhide", --innate11
		"mjz_magnataur_reverse_polarity",
		"medusa_custom_stone_arrows",
		"brewmaster_drunken_brawler",
		"tiny_grow",
		"naga_siren_rip_tide",
		--"viper_poison_attack",  does not work on other heroes , last a single frame on enemy
		"vengefulspirit_wave_of_terror_lua",
		"purifying_flames",

	}
    local randomIndex
    if _G._second_random_op then
        -- Use the custom random function
        randomIndex = CustomRandomInt(1, #abilityList)
    else
        -- Use the default RandomInt function
        randomIndex = RandomInt(1, #abilityList)
    end

    return abilityList[randomIndex]
end

-- Custom RandomInt function using a different algorithm
function CustomRandomInt(min, max)
    -- Get the system time in milliseconds as a seed
    local seed = math.ceil(Plat_FloatTime() % 100000) 
	seed = seed * RandomInt(1, 300) -- Combine with a random integer
    -- Parameters for a simple linear congruential generator (LCG)
    local a = 1664525
    local c = 1013904223
    local m = 2^32
    
    -- Generate the pseudo-random number
    seed = (a * seed + c) % m
    
    -- Map the result to the desired range
	local random_result = min + (seed % (max - min + 1))
    return random_result
end
