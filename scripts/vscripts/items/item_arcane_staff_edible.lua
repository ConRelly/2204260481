
LinkLuaModifier("modifier_item_arcane_staff", "items/arcane_staff.lua", LUA_MODIFIER_MOTION_NONE)



function OnSpellStart( keys )
    if not IsServer() then return nil end

    local caster = keys.caster
	local ability = keys.ability
    local modifier_stats2 = 'modifier_item_arcane_staff'
 
 

    local sound_cast = keys.sound_cast
    local item_name = ability:GetAbilityName()
    
    -- 不叠加
    if caster:HasModifier(modifier_stats2) then
		return nil
    end
    
    caster:AddNewModifier(caster, ability, modifier_stats2, {})
    --caster:AddNewModifier(caster, ability, modifier_stats3, {})


    
    caster:EmitSound(sound_cast)

    ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
    caster:TakeItem(ability)
    --caster:RemoveItem(ability)

    
    -- Create a Item for one game frame to prevent regular dota interactions from going bad
    if Timers then
        local item_dummy = CreateItem(item_name, caster, caster)
        caster:AddItem(item_dummy)
        Timers:CreateTimer(0.01, function()
            caster:TakeItem(item_dummy)
            --caster:RemoveItem(item_dummy)
        end)
    end

end
