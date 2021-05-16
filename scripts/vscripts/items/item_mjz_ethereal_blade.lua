

function OnEquip( keys )
    PrecacheResource("soundfile", "sounds/items/item_ghost_etherealblade.vsnd")
    PrecacheResource("particle", "particles/items_fx/ethereal_blade.vpcf")
    PrecacheResource("particle", "particles/status_fx/status_effect_ghost.vpcf")
    PrecacheResource("particle", "particles/items_fx/ghost.vpcf")
end

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

end

--[[
    	"OnSpellStart"				
		{
			"FireSound"
			{
				"EffectName"  		"DOTA_Item.EtherealBlade.Activate"
				"Target"    		"CASTER"
			}
			"TrackingProjectile"
			{
				"Target"               	"TARGET"
				// "EffectName"        	"particles/units/heroes/hero_tinker/tinker_laser.vpcf"
				"EffectName"			"particles/items_fx/ethereal_blade.vpcf"
				"Dodgeable"            	"1"		//是否可闪避
				"ProvidesVision"    	"0"		//是否提供视野
				"VisionRadius"    		"800"
				"MoveSpeed"            	"%projectile_speed"
				"SourceAttachment"    	"DOTA_PROJECTILE_ATTACHMENT_ATTACK_1"
			}
		}
]]