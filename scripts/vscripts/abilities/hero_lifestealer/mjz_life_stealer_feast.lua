LinkLuaModifier("modifier_mjz_life_stealer_feast", "abilities/hero_lifestealer/mjz_life_stealer_feast.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_life_stealer_feast_damage", "abilities/hero_lifestealer/mjz_life_stealer_feast.lua", LUA_MODIFIER_MOTION_NONE)

mjz_life_stealer_feast = class({})
local ability_class = mjz_life_stealer_feast

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_life_stealer_feast"
end

function ability_class:_CheckLegal( attacker, target )
    local parent = self:GetCaster()
    local ability = self

    if target.IsBuilding == nil or target:IsBuilding() then return false end
    if target:GetTeam() == attacker:GetTeam() then return false end
    if attacker:PassivesDisabled() or attacker:IsIllusion() then return false end

    return true
end

function ability_class:_CreateParticle( target, heal )
    local ability = self
    local interval = 0.25
    local now = GameRules:GetGameTime()
    ability.prev_create_particle = ability.prev_create_particle or now
    if (now - ability.prev_create_particle) > interval then
        ability.prev_create_particle = now

        if create_popup and heal then
            create_popup({
                target = target,
                value = heal,
                color = Vector(0, 230, 0),
                type = "heal"
            })
        end

        --local p_name = "particles/generic_gameplay/generic_lifesteal.vpcf"
       -- local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, target)
        --ParticleManager:ReleaseParticleIndex(p_index)
    end
end




---------------------------------------------------------------------------------------

modifier_mjz_life_stealer_feast = class({})
local modifier_class = modifier_mjz_life_stealer_feast

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:DeclareFunctions() 
        return {
            MODIFIER_EVENT_ON_ATTACK_START,
            MODIFIER_EVENT_ON_ATTACK,
            -- MODIFIER_EVENT_ON_ATTACK_LANDED,
        } 
    end

    function modifier_class:OnAttackStart(keys)
        -- PrintTable(keys)
        if keys.attacker ~= self:GetParent() then return end
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
        local m_name = 'modifier_mjz_life_stealer_feast_damage'
        
        if parent:HasModifier(m_name) then
            parent:RemoveModifierByName(m_name)           
        end

        if not ability:_CheckLegal(attacker, target) then return nil end

        parent:AddNewModifier(caster, ability, m_name, {})
    end

    function modifier_class:OnAttack(keys)
        if keys.attacker ~= self:GetParent() then return end
        local attacker = keys.attacker
        local target = keys.target
        -- local damage = keys.damage
        local parent = self:GetParent()
        local ability = self:GetAbility()

        if not ability:_CheckLegal(attacker, target) then return nil end

        local str_damage_pct = GetTalentSpecialValueFor(ability, "str_damage_pct")
        local damage = parent:GetStrength() * (str_damage_pct / 100.0)
        attacker:Heal(damage, ability)

        ability:_CreateParticle(attacker, damage)
    end
    
    function modifier_class:OnAttackLanded(keys)
        if keys.attacker ~= self:GetParent() then return end
        
    end


end

---------------------------------------------------------------------------------------

modifier_mjz_life_stealer_feast_damage = class({})
local modifier_damage = modifier_mjz_life_stealer_feast_damage

function modifier_damage:IsHidden() return true end
function modifier_damage:IsPurgable() return false end
function modifier_damage:IsBuff() return true end

function modifier_damage:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    } 
end
function modifier_damage:GetModifierPreAttack_BonusDamage()    
    return self:GetStackCount() * 1000
end

function modifier_damage:OnAttackLanded(keys)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if self:IsNull() then return end
    self:Destroy()
end

if IsServer() then
    function modifier_damage:OnCreated(table)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local str_damage_pct = (GetTalentSpecialValueFor(ability, "str_damage_pct") / 100)
        local has_ss = parent:HasModifier("modifier_super_scepter")
        if has_ss then
            local lvl = (parent:GetLevel() / 20 ) + 1
            str_damage_pct = str_damage_pct * lvl
        end
        local damage = math.ceil((parent:GetStrength() * str_damage_pct) / 1000)
        self:SetStackCount(damage)
    end
end

---------------------------------------------------------------------------------------

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