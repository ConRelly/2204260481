

function cast_grimstroke_custom_ink_creature(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    ProjectileManager:CreateTrackingProjectile({
        Ability = ability,
        Target = target,
        Source = caster,
        EffectName = "particles/units/heroes/hero_grimstroke/grimstroke_phantom_return.vpcf",
        iMoveSpeed = 3000,
        bReplaceExisting = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
        bDodgeable = false,
        flExpireTime = GameRules:GetGameTime() + 10.0,
    })

    caster:EmitSound("Hero_Grimstroke.InkCreature.Cast")
end



function on_hit(keys)
	local caster = keys.caster
	local target = keys.target
    local ability = keys.ability
    local stats = caster:GetIntellect(true) + caster:GetAgility() + caster:GetStrength()
    local bonus = math.ceil(ability:GetSpecialValueFor("stats_bonus") * stats)
    target:EmitSound("Hero_Grimstroke.InkCreature.Attach")

    if caster:IsOpposingTeam(target:GetTeam()) then
        local damage = ability:GetSpecialValueFor("damage") + bonus
        ApplyDamage({
            ability = ability,
            attacker = caster,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            victim = target
        })
    else
        local heal = ability:GetSpecialValueFor("heal") + bonus
        target:Heal(heal, caster)
    end
end
