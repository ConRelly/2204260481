
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
                        return
                    end
                end
                if hero:HasAbility("shadow_demon_custom_hyperactivity") then
                    if newAbilityName == "obs_replay" then
                        print(newAbilityName .. " nope2")
                        --ability:OnSpellStart()
                        return
                    end
                end
                local newAbility = hero:AddAbility(newAbilityName)
                print("newAbility:" .. newAbilityName)
                hero:SetAbilityPoints(hero:GetAbilityPoints() + 5)
                found_valid_ability = true
                hero:RemoveItem(ability)
                hero:ModifyGold(19213, true, 0)
                return true
            end
            break
        end
    end
end

function GetRandomAbilityName( hero )
    local abilityList = {
        --"ogre_magi_multicast_n",
        "ogre_magi_multicast_lua",
        --"aghanim_blink2",
        "ursa_fury_swipes",
        --"brewmaster_drunken_brawler",
        --"mjz_faceless_void_backtrack",
        --"antimage_custom_mana_break",
        "vengefulspirit_wave_of_terror_lua",
        "naga_siren_rip_tide",
        "jotaro_absolute_defense3",
        "nevermore_custom_necromastery",
        "dzzl_good_juju",
        "spectre_custom_dispersion_boss",
        "purifying_flames",
        --"back_in_time",
        --"medusa_custom_stone_arrows",
        --"mjz_slark_essence_shift",
        --"custom_mana_regen",
        --"custom_side_gunner",
       -- "vengefulspirit_command_aura_lua",
        --"nyx_assassin_custom_vendetta",
        --"grow_strong",
        --"hoodwink_acorn_shot",
        --"mjz_faceless_void_backtrack",
        --"hoodwink_acorn_shot",
        --"cold_slashes",
        --"reverse_polarity",
        
    }
    local randomIndex = RandomInt(1, #abilityList)
    return abilityList[randomIndex]
end
