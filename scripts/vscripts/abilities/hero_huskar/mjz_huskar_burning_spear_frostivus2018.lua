
local THIS_LUA = "abilities/hero_huskar/mjz_huskar_burning_spear_frostivus2018.lua"
local MODIFIER_LUA = "modifiers/hero_huskar/modifier_mjz_huskar_burning_spear_frostivus2018.lua"
local MODIFIER_COUNTER_NAME = 'modifier_mjz_huskar_burning_spear_frostivus2018_debuff'
local MODIFIER_EFFECT_NAME = 'modifier_mjz_huskar_burning_spear_frostivus2018_debuff_effect'
local MODIFIER_TALENT_NAME = 'modifier_special_bonus_unique_huskar_5'
local TALENT_NAME = 'special_bonus_unique_huskar_5'

LinkLuaModifier(MODIFIER_COUNTER_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_EFFECT_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_TALENT_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_orb_effect_v1_0", "modifiers/modifier_generic_orb_effect_v1.0.lua", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_huskar_burning_spear_frostivus2018 = class({})
local ability_class = mjz_huskar_burning_spear_frostivus2018

function ability_class:IsRefreshable() return true end
function ability_class:IsStealable() return false end	-- 是否可以被法术偷取。

function ability_class:GetAbilityDamageType()
    if self:GetCaster():HasModifier(MODIFIER_TALENT_NAME) then
        return DAMAGE_TYPE_PURE
    else
        return DAMAGE_TYPE_MAGICAL
    end
end


function ability_class:GetAbilityTargetFlags( )
    if self:GetCaster():HasModifier(MODIFIER_TALENT_NAME) then
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    else
        return DOTA_UNIT_TARGET_FLAG_NONE
    end
end

function ability_class:OnUpgrade()
    if IsServer() then
        if self:GetLevel() == 1 then
            self:ToggleAutoCast()
        end
    end
end

--------------------------------------------------------------------------------
function ability_class:GetIntrinsicModifierName()
    return "modifier_generic_orb_effect_v1_0"
end

function ability_class:OnAbilityPhaseStart()

end

-- Orb Effects
function ability_class:GetProjectileName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear.vpcf"
end

function ability_class:OnOrbFire( params )
	local ability = self
	local caster = self:GetCaster()
	local target = params.target
    -- play effects
    
    if HasTalent(caster, TALENT_NAME) then
        if not caster:HasModifier(MODIFIER_TALENT_NAME) then
            caster:AddNewModifier(caster, ability, MODIFIER_TALENT_NAME, {})
        end
    end
    
    DoHealthCost({
        caster = caster,
        ability = ability,
    })
end

function ability_class:OnOrbImpact( params )
	local ability = self
	local caster = self:GetCaster()
	local target = params.target

	OnOrbImpact({
        caster = caster,
        ability = ability,
        target = target,
    })
end

--------------------------------------------------------------------------------

function OnOrbImpact( keys )

	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
    
	local spear_aoe = ability:GetLevelSpecialValueFor( "spear_aoe" , ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "burn_duration" , ability:GetLevel() - 1 )
    local flags = ability:GetAbilityTargetFlags()
    -- local enemy_list = FindTargetEnemy(caster, target:GetAbsOrigin(), spear_aoe)
    local enemy_list = FindTargetEnemy_Flags(caster, target:GetAbsOrigin(), spear_aoe, flags)
    for _,enemy in pairs(enemy_list) do

        IncreaseModifierStackCount({
            caster = caster, ability = ability, target = enemy,
            modifier_name = MODIFIER_COUNTER_NAME, duration = duration
        })

        enemy:AddNewModifier(caster, ability, MODIFIER_EFFECT_NAME, {duration = duration})
    end
    
    EmitSoundOn("Hero_Huskar.Burning_Spear", target)
end


--[[
    Removes HP for using Burning Spear
    This is called everytime the ability is used (manual left-click or via auto-cast right-click)
]]
function DoHealthCost( event )
    local caster = event.caster
    local ability = event.ability
    local health_cost = ability:GetLevelSpecialValueFor( "health_cost" , ability:GetLevel() - 1  )
    local health = caster:GetHealth()
    local new_health = (health - health_cost)

    -- "do damage"
    -- aka set the casters HP to the new value
    -- ModifyHealth's third parameter lets us decide if the healthcost should be lethal
    caster:ModifyHealth(new_health, ability, false, 0)

    EmitSoundOn("Hero_Huskar.Burning_Spear.Cast", caster)
end

function IncreaseModifierStackCount( kv )
    local caster = kv.caster
    local ability = kv.ability
    local target = kv.target
    local modifier_name = kv.modifier_name
    local duration = kv.duration

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    if modifier then
        target:SetModifierStackCount(modifier_name, caster, count + 1)
        modifier:SetDuration(duration, true)
    else
        target:AddNewModifier(caster, ability, modifier_name, {duration = duration})
        target:SetModifierStackCount(modifier_name, caster, 1) 
    end
end

---------------------------------------------------------------------------------------

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
    local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE     -- 忽视建筑物
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy_Flags(unit, point, radius, flags)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
    local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
    local iFlagFilter = flags
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
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