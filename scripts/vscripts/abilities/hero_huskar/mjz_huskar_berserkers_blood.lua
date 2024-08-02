
local THIS_LUA = "abilities/hero_huskar/mjz_huskar_berserkers_blood.lua"
local MODIFIER_LUA = "modifiers/hero_huskar/modifier_mjz_huskar_berserkers_blood.lua"
local MODIFIER_INIT_NAME = 'modifier_mjz_huskar_berserkers_blood'
local MODIFIER_IMMORTAL_SHOULDERS_NAME = 'modifier_mjz_huskar_ti8_immortal_shoulders'
local MODEL_IMMORTAL_SHOULDERS_NAME = 'models/items/huskar/huskar_ti8_immortal_shoulders/huskar_ti8_immortal_shoulders.vmdl'


LinkLuaModifier(MODIFIER_INIT_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_huskar_berserkers_blood = class({})
local ability_class = mjz_huskar_berserkers_blood

function ability_class:GetIntrinsicModifierName()
    if IsServer() then
        self:_CheckImmortal()
    end
    return MODIFIER_INIT_NAME
end

function ability_class:GetAbilityTextureName()
    if self:GetCaster():HasModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME) then
        return 'mjz_huskar_berserkers_blood_immortal'        
    end
    return 'mjz_huskar_berserkers_blood'
end

if IsServer() then
    function ability_class:_CheckImmortal()
        -- print('check immortal...')
        local caster = self:GetCaster()
        local ability = self
        if not caster:HasModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME) then
            local has_immortal = FindWearables(caster, MODEL_IMMORTAL_SHOULDERS_NAME)
            if has_immortal then
                caster:AddNewModifier(caster, ability, MODIFIER_IMMORTAL_SHOULDERS_NAME, {})
            end
        end
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_huskar_ti8_immortal_shoulders = class({})
function modifier_mjz_huskar_ti8_immortal_shoulders:IsHidden() return true end
function modifier_mjz_huskar_ti8_immortal_shoulders:IsPurgable() return false end
function modifier_mjz_huskar_ti8_immortal_shoulders:RemoveOnDeath() return false end

---------------------------------------------------------------------------------------

function FindWearables( unit, wearable_model_name)
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if modelName == wearable_model_name then
                return true
            end
        end
        model = model:NextMovePeer()
    end
    return false
end


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