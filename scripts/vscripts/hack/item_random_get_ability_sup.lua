
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
		for i = 0, DOTA_MAX_ABILITIES - 1 do
			local abil = caster:GetAbilityByIndex(i)
			if abil then
				if abil:GetAbilityName() == "generic_hidden" then
					GenericSlots = GenericSlots + 1
				end
			end
		end
		if GenericSlots > 0 then
			for i = 0, DOTA_MAX_ABILITIES - 1 do
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
			for i=0, 31 do
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
				hero:RemoveItem(ability)
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
		"mars_bulwark",
		--"magnataur_empower",
		"legion_commander_custom_duel",
		"alchemist_chemical_rage",
		"mjz_dragon_knight_dragon_blood",
		"mars_bulwark",
		--"juggernaut_healing_ward",
		"mjz_juggernaut_blade_fury",
		--"templar_assassin_psi_blades",
		"mjz_vengefulspirit_vengeance",
		"monkey_king_custom_jingu_mastery",
		"alchemist_goblins_greed",
		"mjz_omniknight_repel",
		"lycan_feral_impulse",
		"antimage_custom_counterspell",
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
		--"faceless_void_time_lock",
		"mjz_lina_laguna_blade",
		"mjz_clinkz_soul_pact",
		--"luna_lunar_blessing",
		"elder_titan_natural_order",
		"nyx_assassin_custom_vendetta",
		--"skywrath_mage_ancient_seal",
		--"mjz_axe_counter_helix",
		"dark_willow_bedlam_lua",
		"alchemist_power_of_gold2",
		"alchemist_power_of_gold",
		"rubick_arcane_supremacy",
		--"jakiro_liquid_fire",
		"obsidian_destroyer_arcane_orb",
		"mjz_crystal_maiden_brilliance_aura",
		"mystic_dragon_endless_wisdom",
		"imba_phantom_assassin_coup_de_grace",
		"dzzl_good_juju",
		"ancient_apparition_chilling_touch",
		"grow_strong",
		"ogre_magi_multicast_n",
		--"enchantress_impetus",
		"dark_seer_custom_ion_shell",
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
		"phantom_reflex",
		"mjz_slark_dark_pact",
		"mjz_slark_essence_shift",
		"nevermore_custom_necromastery",
		"mjz_arc_warden_spark_wraith",
		"custom_aphotic_shield",
		--"phantom_assassin_fan_of_knives",
		"mjz_necrolyte_heartstopper_aura",
		"mjz_lifestealer_poison_sting",
		"legion_commander_duel_lua", 
		--"lich_chain_frost",
		"weaver_the_swarm",
		"hoodwink_scurry",
		"hoodwink_acorn_shot",
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
		"custom_side_gunner",
		"mjz_magnataur_reverse_polarity",
		"medusa_custom_stone_arrows",
		"brewmaster_drunken_brawler",

	}
	local randomIndex = RandomInt(1, #abilityList)
	return abilityList[randomIndex]
end
