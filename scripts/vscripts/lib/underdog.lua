require("lib/my")


LinkLuaModifier("modifier_underdog", "modifiers/modifier_underdog.lua", LUA_MODIFIER_MOTION_NONE)


-- Fixes the magic res str gives. Check if it is a hero before calling.

function fix_atr_for_hero2(hero)
    local dog_mod = "modifier_underdog"
    --print("dogbuf")
    --if IsServer() then
    if hero:IsRealHero() and hero:GetUnitLabel() ~= "no_underdog" and not hero:HasModifier(dog_mod) then
        if hero:HasModifier("modifier_bottom_10") or hero:HasModifier("modifier_bottom_20") then return end
        local lvl = hero:GetLevel()
        if lvl > 34 then
            hero:AddNewModifier(hero, nil, dog_mod, {})
        end        
    end
    --end   
end
  
