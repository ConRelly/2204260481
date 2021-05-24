
LinkLuaModifier( "modifier_item_mjz_rage_moon_shard",  "modifiers/items/modifier_item_mjz_rage_moon_shard.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_rage_moon_shard_stats",  "modifiers/items/modifier_item_mjz_rage_moon_shard_stats.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_rage_moon_shard_bat",  "modifiers/items/modifier_item_mjz_rage_moon_shard_bat.lua",LUA_MODIFIER_MOTION_NONE )


local modifier = 'modifier_item_mjz_rage_moon_shard'
local modifier_stats = 'modifier_item_mjz_rage_moon_shard_stats'
local MODIFIER_BASE_ATTACK_TIME = 'modifier_item_mjz_rage_moon_shard_bat'

function OnEquip( keys )
    if not IsServer() then return nil end

    local caster = keys.caster
	local ability = keys.ability

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

    if caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
    end
end

function OnSpellStart( keys )
    if not IsServer() then return nil end

    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local sound_cast = keys.sound_cast
    local item_name = ability:GetAbilityName()
    
    -- 不叠加
    if target:HasModifier(modifier_stats) then
		return nil
    end

    target:AddNewModifier(caster, ability, modifier_stats, {})
    AddModifier_BaseAttackTime(caster, ability, target)
    target:EmitSound(sound_cast)

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

function AddModifier_BaseAttackTime( caster, ability, target )
    local modifer_attack_time_name = MODIFIER_BASE_ATTACK_TIME
    if target:HasModifier(modifer_attack_time_name) then
		return nil
    end

    local consumed_bonus_attack_time = ability:GetSpecialValueFor('consumed_bonus_attack_time')
    local target_base_attack_time = target:GetBaseAttackTime()

    local base_attack_time = target_base_attack_time + consumed_bonus_attack_time

    target:AddNewModifier(caster, ability, modifer_attack_time_name, {})

    local modifer_attack_time = target:FindModifierByName(modifer_attack_time_name)
    local iCount = math.abs( base_attack_time * 10 )
    modifer_attack_time:SetStackCount(iCount)
end