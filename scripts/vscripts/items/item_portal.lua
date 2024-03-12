function OnSpellStart(keys)
    if keys.caster:IsRealHero() then
        AddZones:StartRandomZone(keys.caster)
    end
    --keys.caster:RemoveItem(keys.ability)
    keys.caster:TakeItem(keys.ability)
end