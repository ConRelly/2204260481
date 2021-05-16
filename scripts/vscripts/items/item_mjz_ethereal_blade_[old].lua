

function DamageEnemy( keys )
    -- 获取施法者
	local hCaster = EntIndexToHScript(keys.caster_entindex)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

	local blast_damage_base = ability:GetLevelSpecialValueFor("blast_damage_base", ability:GetLevel() - 1 )
    local blast_multiplier = ability:GetLevelSpecialValueFor("blast_multiplier", ability:GetLevel() - 1 )
    
    local stat_value = 0
    stat_value = hCaster:GetPrimaryStatValue() --返回主属性值

    local damage = blast_multiplier * stat_value + blast_damage_base

    local damage_table = {
        attacker = caster,
        victim = target,
        damage_type = ability:GetAbilityDamageType(),
        damage = damage
    }

    ApplyDamage(damage_table)
end


function OnSpellStart( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    EmitSoundOn("DOTA_Item.EtherealBlade.Activate", caster)

	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability:GetLevel() - 1 )
    local EffectName = "particles/items_fx/ethereal_blade.vpcf"

    local info = 
    {
        Target = target,
        Source = caster,
        Ability = ability,	
        EffectName = EffectName,
            iMoveSpeed = projectile_speed,
        vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
        bDrawsOnMinimap = false,                          -- Optional
            bDodgeable = true,                                -- Optional
            bIsAttack = false,                                -- Optional
            bVisibleToEnemies = true,                         -- Optional
            bReplaceExisting = false,                         -- Optional
            flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
        bProvidesVision = true,                           -- Optional
        iVisionRadius = 800,                              -- Optional
        iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
    }
    local projectile = ProjectileManager:CreateTrackingProjectile(info)

end

function OnProjectileHitUnit( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    EmitSoundOn("DOTA_Item.EtherealBlade.Target", target)

	local MAGICAL_RESISTANCE = ability:GetLevelSpecialValueFor("ethereal_damage_bonus", ability:GetLevel() - 1 )
    local MOVESPEED_BONUS = ability:GetLevelSpecialValueFor("blast_movement_slow", ability:GetLevel() - 1 )
    -- DOTA_UNIT_TARGET_TEAM_FRIENDLY or DOTA_UNIT_TARGET_TEAM_ENEMY
    -- if IsFriendly(keys) then
    --     MOVESPEED_BONUS = 0
    -- end
    local modifierData = {
        Duration = 3,
        TextureName = "item_mjz_ethereal_blade_red",
        MAGICAL_RESISTANCE = MAGICAL_RESISTANCE,
        MOVESPEED_BONUS = MOVESPEED_BONUS
    }
    local modifierName = "modifier_effect_ghost"
    ability:ApplyDataDrivenModifier(caster, target, modifierName, modifierData)

    if not IsFriendly(keys) then
        DamageEnemy(keys)
    end
end

-- not work
function IsFriendly( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local TargetType = ability:GetAbilityTargetType() --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
    local TargetFlags = ability:GetAbilityTargetFlags()
    local TeamNumber = caster:GetTeamNumber()
    local ufResult = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, TargetType, TargetFlags, TeamNumber)
    
    return ufResult == UF_SUCCESS  -- UF_FAIL_FRIENDLY
end

-- not work
function IsEnemy( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local TargetType = ability:GetAbilityTargetType()
    local TargetFlags = ability:GetAbilityTargetFlags()
    local TeamNumber = 0
    local ufResult = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, TargetType, TargetFlags, TeamNumber)
    
    return ufResult == UF_SUCCESS  -- UF_FAIL_ENEMY
end