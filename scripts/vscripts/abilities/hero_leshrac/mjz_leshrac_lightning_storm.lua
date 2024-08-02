
LinkLuaModifier("modifier_mjz_leshrac_lightning_storm", "abilities/hero_leshrac/mjz_leshrac_lightning_storm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_leshrac_lightning_storm_slow", "abilities/hero_leshrac/mjz_leshrac_lightning_storm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_leshrac_lightning_storm_int", "abilities/hero_leshrac/mjz_leshrac_lightning_storm.lua", LUA_MODIFIER_MOTION_NONE)


mjz_leshrac_lightning_storm = class({})
local ability_class = mjz_leshrac_lightning_storm

function ability_class:GetAOERadius()
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("radius_scepter") + self:GetCaster():GetCastRangeBonus()
    end
end

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_leshrac_lightning_storm"
end

function ability_class:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    local ability = self
    local radius = ability:GetAOERadius()


    ability.jump_count = ability:GetSpecialValueFor("jump_count")
    ability.radius = ability:GetSpecialValueFor("radius")
    ability.jump_delay = ability:GetSpecialValueFor("jump_delay")
    ability.slow_duration = GetTalentSpecialValueFor(ability, "slow_duration")
    ability.slow_movement_speed = ability:GetSpecialValueFor("slow_movement_speed")
    ability.damage = self:CalcDamage()

    self:SpellRepeat({ caster=caster,
        initial_target=target, 
        jump_count=ability.jump_count, 
        radius=ability.radius,
        jump_delay=ability.jump_delay,
        slow_duration=ability.slow_duration,
        slow_movement_speed=ability.slow_movement_speed,
        damage=ability.damage,
        ability=ability,
        bounceTable={} })
end

function ability_class:CalcDamage()
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    local ability = self
    local radius = ability:GetAOERadius()

    local base_damage = GetTalentSpecialValueFor(ability, "damage")
    local damage_intelligence_per = GetTalentSpecialValueFor(ability, "damage_intelligence_per")
    local damage = base_damage
    if caster:IsRealHero() then
        damage = base_damage + caster:GetIntellect(false) * (damage_intelligence_per / 100)
    end
    return damage
end

function ability_class:SpellRepeat( params )
    if params.jump_count == 0 or params.initial_target == nil then
        return
    end
    local particle_name = "particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf"
    --local orig_particle = "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf"
    -- hit initial target
    local lightning = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, params.initial_target)
    local loc = params.initial_target:GetAbsOrigin()
    local target = params.initial_target
    local caster = params.caster
    local m_slow = "modifier_mjz_leshrac_lightning_storm_slow"
    ParticleManager:SetParticleControl(lightning, 0, loc + Vector(0, 0, 1000))
    ParticleManager:SetParticleControl(lightning, 1, loc)
    ParticleManager:SetParticleControl(lightning, 2, loc)
    --EmitSoundOn("Hero_Leshrac.Lightning_Storm", params.initial_target)
    target:EmitSoundParams("Hero_Leshrac.Lightning_Storm", 0, 0.3, 0)
    local bonus_dmg = 0
    if target:HasModifier(m_slow) then
        bonus_dmg = math.ceil((target:FindModifierByName(m_slow):GetStackCount() + 1) * (caster:GetIntellect(false) / 10))
    end    
    local damageTable = {
        attacker = caster,
        victim = params.initial_target,
        damage = params.damage + bonus_dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = params.ability}
    ApplyDamage(damageTable)

    -- if unit is still alive, apply slow with glow particle
    if params.initial_target:IsAlive() then
        -- params.ability:ApplyDataDrivenModifier(params.caster, params.initial_target, "lightning_storm_slow", {})
        local slow_duration = params.slow_duration
        if target:HasModifier(m_slow) then
            target:FindModifierByName(m_slow):IncrementStackCount()
            target:FindModifierByName(m_slow):ForceRefresh()
        else
            params.initial_target:AddNewModifier(params.caster, params.ability, m_slow, {duration = slow_duration})
        end
    end

    params.bounceTable[params.initial_target] = 1

    -- find next target (closest one to previous one)
    unitsInRange = FindUnitsInRadius(params.initial_target:GetTeamNumber(),
        params.initial_target:GetAbsOrigin(),
        nil,
        params.radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false)

    params.initial_target = nil
    for k,v in pairs(unitsInRange) do
        if params.bounceTable[v] == nil then
            params.initial_target = v
            break
        end
    end

    params.jump_count = params.jump_count - 1

    -- run the function again in jump_delay seconds
    Timers:CreateTimer(params.jump_delay, 
        function()
            self:SpellRepeat( params )
        end
    )
end

--------------------------------------------------------------------------------

modifier_mjz_leshrac_lightning_storm = class({})
local modifier_class = modifier_mjz_leshrac_lightning_storm

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then


    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        local interval_scepter = ability:GetSpecialValueFor('interval_scepter')
        local caster = self:GetCaster()
        local has_ss = caster:HasModifier("modifier_super_scepter")
        if has_ss then
            interval_scepter = interval_scepter / 2

        end   
        self:StartIntervalThink(interval_scepter)
    end


    function modifier_class:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        
        if not self:CanSpell() then return end

        local radius = ability:GetAOERadius()
        local count  = GetTalentSpecialValueFor(ability, "count_scepter")
        --SS effect
        local chance = ability:GetSpecialValueFor("ss_chance")        
        local has_ss = caster:HasModifier("modifier_super_scepter")
        local modif_tooltip = "modifier_mjz_leshrac_lightning_storm_int"
        local has_modif_tooltip = caster:HasModifier(modif_tooltip)  
        ----
        ability.jump_count = ability:GetSpecialValueFor("jump_count")
        ability.radius = ability:GetSpecialValueFor("radius")
        ability.jump_delay = ability:GetSpecialValueFor("jump_delay")
        ability.slow_duration = GetTalentSpecialValueFor(ability, "slow_duration")
        ability.slow_movement_speed = ability:GetSpecialValueFor("slow_movement_speed")
        ability.damage = ability:CalcDamage()

        -- FIND_ANY_ORDER FIND_CLOSEST
        local enemy_list = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, 
                           ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 
                           FIND_ANY_ORDER, false )

        for _, enemy in ipairs(enemy_list) do
            if count > 0 then
                count = count - 1
                ability:SpellRepeat({ 
                    caster = caster,
                    initial_target = enemy, 
                    jump_count = 1, 
                    radius = ability.radius,
                    jump_delay = ability.jump_delay,
                    slow_duration = ability.slow_duration,
                    slow_movement_speed = ability.slow_movement_speed,
                    damage = ability.damage,
                    ability = ability,
                    bounceTable = {} 
                })
                if has_ss then
                    local randomSeed = math.random(1, 100)
                    if randomSeed <= chance then
                        local bonus = 1
                        caster:ModifyIntellect(bonus)
                        if has_modif_tooltip then
                            local modifier = caster:FindModifierByName(modif_tooltip)
                            modifier:SetStackCount(modifier:GetStackCount() + bonus)
                        elseif not caster:HasModifier("modifier_tome_of_super_scepter") then
                            local modifier = caster:AddNewModifier(caster, ability, modif_tooltip, {})
                            modifier:SetStackCount(bonus)
                            self:OnCreated()  
                        end      
                    end         
                end                
            end
        end

    end

    function modifier_class:CanSpell()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        if not IsValidEntity(caster) then return end
        if not caster:IsAlive() then return end
        if not caster:HasScepter() then return end

        local activeUlt = false
        if caster:FindModifierByName("modifier_leshrac_pulse_nova")     then activeUlt = true end
        if caster:FindModifierByName("modifier_mjz_leshrac_pulse_nova") then activeUlt = true end
        if not activeUlt then return end

        return true
    end
end

--------------------------------------------------------------------------------

modifier_mjz_leshrac_lightning_storm_slow = class({})

function modifier_mjz_leshrac_lightning_storm_slow:IsHidden() return false end
function modifier_mjz_leshrac_lightning_storm_slow:IsPurgable() return false end

function modifier_mjz_leshrac_lightning_storm_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
	}
	return funcs
end
function modifier_mjz_leshrac_lightning_storm_slow:GetModifierHealAmplify_PercentageTarget( )
    return self:GetAbility():GetSpecialValueFor('healing_reduction')
end

function modifier_mjz_leshrac_lightning_storm_slow:GetEffectName()
	return "particles/units/heroes/hero_leshrac/leshrac_lightning_slow.vpcf"
end
function modifier_mjz_leshrac_lightning_storm_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

------------------------------------------------------------------------------
----stack tooltip
if modifier_mjz_leshrac_lightning_storm_int == nil then modifier_mjz_leshrac_lightning_storm_int = class({}) end
local modifier_lightning_storm_int = modifier_mjz_leshrac_lightning_storm_int

function modifier_lightning_storm_int:IsHidden() return false end
function modifier_lightning_storm_int:IsPurgable() return false end
function modifier_lightning_storm_int:IsDebuff() return false end
function modifier_lightning_storm_int:RemoveOnDeath() return false end
function modifier_lightning_storm_int:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_lightning_storm_int:OnTooltip()
	return self:GetStackCount()
end




-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end

