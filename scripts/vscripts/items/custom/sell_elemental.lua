function OnSpellStart(keys)
    local caster = keys.caster
    local team = caster:GetTeam()

    -- Increase the stock of the water and air essences in the shop by 2
    GameRules:IncreaseItemStock(team, "item_water_essence", 2, -1)
    GameRules:IncreaseItemStock(team, "item_air_essence", 2, -1)

    -- Remove the "item_all_essence" from the player's inventory
    --caster:RemoveItem(keys.ability)
    caster:TakeItem(keys.ability)

    -- Play a sound effect and show a message to the player
    EmitSoundOn("General.Coins", caster)
    SendOverheadEventMessage(caster, OVERHEAD_ALERT_GOLD, caster, 1100, nil)
    caster:ModifyGold(1100, true, 0)
end