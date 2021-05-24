
function OnAttackStart( keys )
    if not IsServer() then return nil end
    
    local caster = keys.caster
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local modifier_name_crit = keys.modifier_crit
    local modifier_name_lifesteal = keys.modifier_lifesteal
    local special_bonus_name = keys.special_bonus

    local crit_chance = ability:GetLevelSpecialValueFor('crit_chance', ability_level)
    if HasTalent(caster, special_bonus_name) then
        local special_bonus_value = FindTalentValue(caster, special_bonus_name)
        crit_chance = crit_chance + special_bonus_value
    end

    local random_value = RandomInt(1, 100)
    if random_value <= crit_chance  then
        ability:ApplyDataDrivenModifier(caster, caster, modifier_name_crit, {})
        ability:ApplyDataDrivenModifier(caster, caster, modifier_name_lifesteal, {})
    end
end

-- 是否学习指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end

-- 获得技能数据中连接的天赋技能的名字
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