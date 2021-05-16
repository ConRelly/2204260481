LinkLuaModifier("modifier_mjz_night_stalker_darkness","abilities/hero_night_stalker/mjz_night_stalker_darkness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_darkness_damage","abilities/hero_night_stalker/mjz_night_stalker_darkness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_darkness_lifesteal","abilities/hero_night_stalker/mjz_night_stalker_darkness.lua", LUA_MODIFIER_MOTION_NONE)

mjz_night_stalker_darkness = class({})
local ability_class = mjz_night_stalker_darkness

if IsServer() then
    function ability_class:OnSpellStart()
        local ability = self
        local caster = self:GetCaster()
        local duration = ability:GetSpecialValueFor('duration')
        local modifier_name = 'modifier_mjz_night_stalker_darkness'
        local modifier_damage_name = 'modifier_mjz_night_stalker_darkness_damage'
        local modifier_lifesteal_name = 'modifier_mjz_night_stalker_darkness_lifesteal'
        
        self:_AddModifier(modifier_name, duration)
        self:_AddModifier(modifier_damage_name, duration)
        self:_AddModifier(modifier_lifesteal_name, duration)
        
        local p_name = "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf"
        local nFXIndex = ParticleManager:CreateParticle( p_name, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl(nFXIndex, 0, caster:GetOrigin()) 
		ParticleManager:ReleaseParticleIndex(nFXIndex)

        caster:EmitSound("Hero_Nightstalker.Darkness")
    end

    function ability_class:_AddModifier( modifier_name, duration, is_ability_modifier)
        local ability = self
        local caster = self:GetCaster()
        local modifier = caster:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
			modifier:ForceRefresh()
        else
            if is_ability_modifier then
                ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {duration = duration})
            else
                caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
            end
        end
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_night_stalker_darkness = class({})
local modifier_class = modifier_mjz_night_stalker_darkness

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

--[[
    function modifier_class:GetEffectName()
        return "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf"
    end
    function modifier_class:GetEffectAttachType()
        return PATTACH_ABSORIGIN_FOLLOW
    end
]]

--[[
    function modifier_class:GetHeroEffectName()
        return "particles/units/heroes/hero_night_stalker/nightstalker_darkness_hero_effect.vpcf"
    end
    function modifier_class:HeroEffectPriority()
        return 100
    end
]]

function modifier_class:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end
function modifier_class:GetBonusVisionPercentage( )
	return self:GetAbility():GetSpecialValueFor('bonus_vision_pct')
end
function modifier_class:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor('evasion_chance')
end
function modifier_class:GetModifierModelScale( )
	return self:GetAbility():GetSpecialValueFor('model_scale')
end

-----------------------------------------------------------------------------------------

modifier_mjz_night_stalker_darkness_damage = class({})
local modifier_damage = modifier_mjz_night_stalker_darkness_damage

function modifier_damage:IsHidden() return true end
function modifier_damage:IsPurgable() return false end

function modifier_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end
function modifier_damage:GetModifierPreAttack_BonusDamage()
    if IsServer() then
        local stack_count = GetTalentSpecialValueFor(self:GetAbility(), 'bonus_damage')
        if self:GetStackCount() ~= stack_count then
            self:SetStackCount(stack_count)
        end
    end
    return self:GetStackCount()
end

-----------------------------------------------------------------------------------------

modifier_mjz_night_stalker_darkness_lifesteal = class({})
local modifier_lifesteal = modifier_mjz_night_stalker_darkness_lifesteal

function modifier_lifesteal:IsHidden() return true end
function modifier_lifesteal:IsPurgable() return false end

if IsServer() then
    function modifier_lifesteal:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end

    function modifier_lifesteal:OnAttackLanded(keys)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
        local damage = keys.damage
    
        if parent == attacker and parent:GetTeamNumber() ~= target:GetTeamNumber() then
            if not target:IsHero() and not target:IsCreep() then
                return nil
            end
    
            if parent:IsIllusion() then return nil end
    
            local lifesteal_pct = self:GetAbility():GetSpecialValueFor('lifesteal_pct')
            local lifesteal_amount = damage * (lifesteal_pct / 100.0)
            parent:Heal(lifesteal_amount, parent)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, lifesteal_amount, nil)
    
            -- Choose the particle to draw
            local lifesteal_particle = "particles/generic_gameplay/generic_lifesteal.vpcf"
    
            -- Heal and fire the particle
            local lifesteal_pfx = ParticleManager:CreateParticle(lifesteal_particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
            ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
            
        end
    end    
end


-----------------------------------------------------------------------------------------

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
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end