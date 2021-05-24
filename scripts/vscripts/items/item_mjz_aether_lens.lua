
LinkLuaModifier( "modifier_item_mjz_aether_lens",  "modifiers/items/modifier_item_mjz_aether_lens.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_aether_lens_stats",  "modifiers/items/modifier_item_mjz_aether_lens_stats.lua",LUA_MODIFIER_MOTION_NONE )

function OnEquip( keys )
    if not IsServer() then return nil end

    local caster = keys.caster
	local ability = keys.ability
    local modifier = 'modifier_item_mjz_aether_lens'
    local modifier_stats = 'modifier_item_mjz_aether_lens_stats'

    -- 不叠加
    if caster:HasModifier(modifier_stats) then
		return nil
    end

    if caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
    end
    caster:AddNewModifier(caster, ability, modifier, {})
end

function OnUnequip( keys )
    if not IsServer() then return nil end

    local caster = keys.caster
	local ability = keys.ability
    local modifier = 'modifier_item_mjz_aether_lens'

    if caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
    end
end

function OnSpellStart( keys )
    if not IsServer() then return nil end

    local caster = keys.caster
	local ability = keys.ability
	local modifier = 'modifier_item_mjz_aether_lens'
    local modifier_stats = 'modifier_item_mjz_aether_lens_stats'

    local sound_cast = keys.sound_cast
    local item_name = ability:GetAbilityName()
    
    -- 不叠加
    if caster:HasModifier(modifier_stats) then
		return nil
    end
    
    caster:AddNewModifier(caster, ability, modifier_stats, {})
    
    caster:EmitSound(sound_cast)

    ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
    caster:RemoveItem(ability)
	caster:RemoveModifierByName(modifier)

    
    -- Create a Item for one game frame to prevent regular dota interactions from going bad
    if Timers then
        local item_dummy = CreateItem(item_name, caster, caster)
        caster:AddItem(item_dummy)
        Timers:CreateTimer(0.01, function()
            caster:RemoveItem(item_dummy)
        end)
    end

end
