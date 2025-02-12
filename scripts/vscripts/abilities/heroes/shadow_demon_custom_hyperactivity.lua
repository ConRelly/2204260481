require("lib/timers")



local exclude_items = {
    item_arcane_boots = true,
    item_custom_refresher = true,
    item_guardian_greaves = true,
    item_sheepstick = true,
	item_conduit = true,
	item_custom_fusion_rune = true,
	item_echo_wand = true,
    shadow_demon_disruption = true,
    item_resurection_pendant = true,
    doom_devour_lua = true,
    dazzle_good_juju = true,
    dzzl_good_juju = true,
	item_master_of_weapons_sword = true,
	item_master_of_weapons_sword2 = true,
	item_master_of_weapons_sword3 = true,
	item_master_of_weapons_sword4 = true,
	item_master_of_weapons_sword5 = true,  
    muerta_pierce_the_veil = true,
    centaur_stampede = true,
    item_spellbook_destruction = true,
    
}


function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local used_ability = keys.event_ability

    if used_ability 
        and used_ability:GetCaster() == caster 
        and used_ability ~= ability 
        and not exclude_items[used_ability:GetAbilityName()] then

        local cooldown = ability:GetSpecialValueFor("cooldown")

        Timers:CreateTimer(
            function()
                if used_ability then
                    if used_ability:GetCooldownTimeRemaining() > 0 then
                        used_ability:EndCooldown()
                        used_ability:StartCooldown(cooldown)
                        return nil
                    end
                    return 0.05
                end
            end
        )
    end
end
