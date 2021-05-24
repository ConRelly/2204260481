LinkLuaModifier("modifier_mjz_finger_of_death_bonus", "modifiers/hero_lion/modifier_mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_finger_of_death_death", "modifiers/hero_lion/modifier_mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)

mjz_finger_of_death = class({})

function mjz_finger_of_death:GetIntrinsicModifierName()
	return "modifier_mjz_finger_of_death_bonus"
end

function mjz_finger_of_death:GetAbilityTextureName()
    if self:GetCaster():HasScepter() then
        return "mjz_lion_finger_of_death_immortal"
    end
    return "mjz_finger_of_death"
end

function mjz_finger_of_death:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function mjz_finger_of_death:GetAOERadius()
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("splash_radius_scepter")
    end
    return self:GetSpecialValueFor('cast_range')
end

function mjz_finger_of_death:GetCastRange(vLocation, hTarget)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cast_range_scepter")
    end
    return self:GetSpecialValueFor('cast_range')
end

function mjz_finger_of_death:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
    return self.BaseClass.GetCooldown(self, iLevel)
end
function mjz_finger_of_death:GetManaCost(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("mana_cost_scepter")
    end
    return self.BaseClass.GetManaCost(self, iLevel)
end

--[[

function mjz_finger_of_death:GetAbilityTargetFlags()
    if self:GetCaster():HasScepter() then
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function mjz_finger_of_death:GetDamageType()
    if self:GetCaster():HasScepter() then
        return DAMAGE_TYPE_PURE
    end
    return DAMAGE_TYPE_MAGICAL
end
function mjz_finger_of_death:GetAbilityDamageType()
    return self:GetDamageType()
end
function mjz_finger_of_death:GetUnitDamageType()
    return self:GetDamageType()
end

]]


if IsServer() then

    function mjz_finger_of_death:OnSpellStart( )
        local caster = self:GetCaster()
        local ability = self
     
        local damage = self:_CalcDamage()

        local sound ="Hero_Lion.FingerOfDeath" 
        if caster:HasScepter() then
            -- sound = "Hero_Lion.FingerOfDeath.Immortal"
        end
        caster:EmitSound(sound)


        local targets = self:_GetTargets()
        for _, target in ipairs(targets) do
            self:_PlayEffect(target)
            self:_AddDeathMonitor(target)
            self:_ApplyDamage(target, damage)
        end
    end

    function mjz_finger_of_death:_CalcDamage()
        local caster = self:GetCaster()
        local ability = self
     
        self.stack_modifier_name = "modifier_mjz_finger_of_death_bonus"

        local base_damage = self:GetSpecialValueFor(value_if_scepter(caster, "damage_scepter", "damage"))
        local damage_per_kill = self:GetSpecialValueFor("damage_per_kill")

        local kill_count = caster:GetModifierStackCount(self.stack_modifier_name, nil)
        local damage = base_damage + damage_per_kill * kill_count
        return damage
    end

    function mjz_finger_of_death:_GetTargets()
        local ability = self
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if caster:HasScepter() then
            local splash_radius = ability:GetSpecialValueFor("splash_radius_scepter")
            return FindUnitsInRadius(
                caster:GetTeamNumber(),
                target:GetAbsOrigin(),
                nil, splash_radius,
                ability:GetAbilityTargetTeam(),
                ability:GetAbilityTargetType(),
                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                FIND_ANY_ORDER,
                false
            )
        end

        local targets = {}
        table.insert(targets, target)
        return targets
    end

    function mjz_finger_of_death:_PlayEffect(target )
        local caster = self:GetCaster()
        local ability = self

        local particle_name_normal = "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf"
        local particle_name_ti8 = "particles/econ/items/lion/lion_ti8/lion_spell_finger_of_death_charge_ti8.vpcf"
		particle_name_ti8 = particle_name_normal
        local particle_name = value_if_scepter(caster, particle_name_ti8, particle_name_normal)
		
        local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)
    end

    function mjz_finger_of_death:_AddDeathMonitor(target )
        if target:IsIllusion() then return nil end

        local ability = self
        local caster = self:GetCaster()
        local kill_grace_duration = ability:GetSpecialValueFor("kill_grace_duration")
        local creature_enabled = ability:GetSpecialValueFor("creature_enabled")
        -- self.creature_health = ability:GetSpecialValueFor("creature_health")
        local modifier_death = 'modifier_mjz_finger_of_death_death'
        
        local can = false
        if target:IsRealHero() then
            can = true
        else
            if creature_enabled and creature_enabled > 0 then
                can = true
            end
        end

        --添加死亡监听器
        if can then
            target:AddNewModifier(caster, ability, modifier_death, {duration=kill_grace_duration})
        end
    end

    function mjz_finger_of_death:_ApplyDamage(target, damage)
        local caster = self:GetCaster()
        local ability = self

        local sound_default = "Hero_Lion.FingerOfDeathImpact"
        local sound_immortal = "Hero_Lion.FingerOfDeathImpact.Immortal"
        local sound_name = value_if_scepter(caster, sound_immortal, sound_default)
        target:EmitSound(sound_name)

        -- 林肯法球
        if target:TriggerSpellAbsorb(ability) then return nil end

        if not target:IsMagicImmune() or caster:HasScepter() then
            local damage_type = DAMAGE_TYPE_MAGICAL
            if caster:HasScepter() then
                damage_type = DAMAGE_TYPE_PURE
            end

            ApplyDamage({
                attacker = caster,
                victim = target,
                damage = damage,
                damage_type = damage_type,
                ability = ability,
            })
        end
    end
end

--------------------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end
