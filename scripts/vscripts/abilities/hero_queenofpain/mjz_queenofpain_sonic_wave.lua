
mjz_queenofpain_sonic_wave = class({})

function mjz_queenofpain_sonic_wave:GetManaCost()
    if self:GetLevel() > 0 then
        local max_mana = self:GetCaster():GetMaxMana()
        local mana_cost_pct = self:GetSpecialValueFor("mana_cost_pct") / 100
        return max_mana * mana_cost_pct
    end
end

if IsClient() then
 
end


if IsServer() then

    function mjz_queenofpain_sonic_wave:OnSpellStart( )
        local caster = self:GetCaster()
        local ability = self
        local point = self:GetCursorPosition()
        local distance = self:GetSpecialValueFor("distance")
        local start_radius = self:GetSpecialValueFor("starting_aoe")
        local direction = (point - caster:GetOrigin()):Normalized()

        -- Find shadow strike and check autocast as early as possible to avoid doing extra work
        local shadow_strike = caster:FindAbilityByName("queenofpain_custom_shadow_strike")
        local should_autocast_shadow = false
        if shadow_strike and not shadow_strike:IsNull() and shadow_strike:IsTrained() then
            should_autocast_shadow = shadow_strike:GetAutoCastState()
        end
       -- print("should_autocast_shadow:", should_autocast_shadow)
        if should_autocast_shadow then
            -- Find enemies in the sonic wave path only if we intend to autocast shadow strike
            local enemies = FindUnitsInLine(
                caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                caster:GetAbsOrigin() + direction * distance,
                nil,
                start_radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE
            )

            local valid_enemies = {}
            if enemies and #enemies > 0 then
                for _, e in ipairs(enemies) do
                    if e and not e:IsNull() and e:IsAlive() and (not e:IsIllusion()) and (not e:IsInvulnerable()) then
                        table.insert(valid_enemies, e)
                    end
                end
            end

            if #valid_enemies > 0 then
                -- sort by distance to caster (closest first)
                table.sort(valid_enemies, function(a, b)
                    local da = (a:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
                    local db = (b:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
                    return da < db
                end)

                -- Determine max targets based on intelligence: start at 1, +1 per 2000 int (floor), capped at 5
                local caster_int = caster:GetIntellect(false) or 0
                local additional = math.floor(caster_int / 2000)
                local max_possible = math.min(1 + additional, 5)
                local max_targets = math.min(max_possible, #valid_enemies)

                for i = 1, max_targets do
                    local tgt = valid_enemies[i]
                    if tgt and not tgt:IsNull() and tgt:IsAlive() and (not tgt:IsInvulnerable()) then
                        -- use engine cast to properly spend resources and trigger cooldowns
                        if shadow_strike:IsCooldownReady() and shadow_strike:IsFullyCastable() then
                            caster:CastAbilityOnTarget(tgt, shadow_strike, caster:GetPlayerOwnerID())
                            -- Refresh cooldown only if this is NOT the last cast, so we can cast multiple times up to max_targets
                            if i < max_targets then
                                shadow_strike:EndCooldown()
                            end
                        end
                    end
                end
            end
        end

        -- Always play effect and sound for the sonic wave
        self:PlayEffect()

        local sound_cast = "Hero_QueenOfPain.SonicWave"
        EmitSoundOn( sound_cast, caster )
    end




    function mjz_queenofpain_sonic_wave:PlayEffect()
        local caster = self:GetCaster()
        local ability = self
        local point = self:GetCursorPosition()

        local projectile_name = "particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf"
        local projectile_distance = self:GetSpecialValueFor("distance")
        local projectile_speed = self:GetSpecialValueFor("speed")
        local projectile_start_radius = self:GetSpecialValueFor("starting_aoe")
        local projectile_end_radius = self:GetSpecialValueFor("final_aoe")
        local projectile_direction = (point - caster:GetOrigin()):Normalized()

        local info = {
            Source = caster,
            Ability = ability,
            vSpawnOrigin = caster:GetAbsOrigin(),
            
            EffectName = projectile_name,
            fDistance = projectile_distance,
            fStartRadius = projectile_start_radius,
            fEndRadius = projectile_end_radius,
            bHasFrontalCone = false,
            vVelocity = projectile_direction * projectile_speed,
            
            bDeleteOnHit = false,
            bReplaceExisting = false,
            fExpireTime = GameRules:GetGameTime() + 10.0,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            bProvidesVision = false,
        }
        ProjectileManager:CreateLinearProjectile(info)
        
    end

    function mjz_queenofpain_sonic_wave:OnProjectileHit( target, location )
        local caster = self:GetCaster()
        local ability = self
        local base_damage = self:GetSpecialValueFor("damage")
        local damage_scepter = self:GetSpecialValueFor("damage_scepter")
        local int_damage = self:GetSpecialValueFor("intelligence_damage")

        local screamDamage = value_if_scepter(caster, damage_scepter, base_damage)
        screamDamage = screamDamage + caster:GetIntellect(false) * int_damage / 100

        if target then
        -- Trigger the modifier_queenofpain_custom_shadow_strike:_OnScreamHit() function
            local shadowStrikeModifiers = target:FindAllModifiersByName("modifier_queenofpain_custom_shadow_strike")
            for _, modifier in pairs(shadowStrikeModifiers) do
                modifier:_OnScreamHit()
            end            
            local damageTable = {
                victim = target,
                attacker = caster,
                damage = screamDamage,
                damage_type = ability:GetAbilityDamageType(),
                ability = ability,
            }
            ApplyDamage(damageTable)

            local kbDistance = self:GetSpecialValueFor("knockback_distance")
            local kbDuration = self:GetSpecialValueFor("knockback_duration")
            
            ApplyKnockBack(target, caster:GetAbsOrigin(), kbDuration, kbDuration, kbDistance, 0, caster, ability, false)

        end
    end

end

--------------------------------------------------------------------------------


function ApplyKnockBack(target, position, stunDuration, knockbackDuration, distance, height, caster, ability, bStun)
	local caster = caster or nil
	local ability = ability or nil
	StopMotionControllers(target, false)
	local modifierKnockback = {
		center_x = position.x,
		center_y = position.y,
		center_z = position.z,
		should_stun = 0,
		duration = knockbackDuration,
		knockback_duration = knockbackDuration,
		knockback_distance = distance,
		knockback_height = height or 0,
	}
	if bStun == nil or bStun == true then
		target:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = stunDuration})
	end
	target:AddNewModifier(caster, ability, "modifier_knockback", modifierKnockback )
end

function StopMotionControllers(target, bForceDestroy)
	if target.InterruptMotionControllers then target:InterruptMotionControllers(true) end
	for _, modifier in ipairs( target:FindAllModifiers() ) do
		if modifier.controlledMotionTimer then 
			modifier:StopMotionController(bForceDestroy)
		end
	end
end

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end
