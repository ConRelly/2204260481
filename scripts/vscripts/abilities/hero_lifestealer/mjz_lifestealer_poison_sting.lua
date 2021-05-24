LinkLuaModifier("modifier_mjz_lifestealer_poison_sting", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lifestealer_poison_sting_slow", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)

mjz_lifestealer_poison_sting = class({})
local ability_class = mjz_lifestealer_poison_sting

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_lifestealer_poison_sting"
end

---------------------------------------------------------------------------------------

modifier_mjz_lifestealer_poison_sting = class({})
local modifier_class = modifier_mjz_lifestealer_poison_sting

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return false end

if IsServer() then
    function modifier_class:DeclareFunctions() 
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED, 
        } 
    end
    
    function modifier_class:OnAttackLanded(keys)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target

        if attacker ~= parent or attacker:PassivesDisabled() or attacker:IsIllusion() then return end

        local iDuration = GetTalentSpecialValueFor(ability, "duration")
        local modifier_slow_name = "modifier_mjz_lifestealer_poison_sting_slow"
        target:AddNewModifier(attacker, ability, modifier_slow_name, {Duration = iDuration})
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_lifestealer_poison_sting_slow = class({})
local modifier_class_slow = modifier_mjz_lifestealer_poison_sting_slow

function modifier_class_slow:IsHidden() return false end
function modifier_class_slow:IsPurgable() return true end
function modifier_class_slow:IsDebuff() return true end

function modifier_class_slow:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    } 
end
function modifier_class_slow:GetModifierMoveSpeedBonus_Percentage() 
	return self:GetAbility():GetSpecialValueFor("move_slow_pct")
end
function modifier_class_slow:GetEffectAttachType() 
    return PATTACH_ABSORIGIN_FOLLOW 
end
function modifier_class_slow:GetEffectName() 
    return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf" 
end
function modifier_class_slow:GetStatusEffectName() 
    return "particles/status_fx/status_effect_poison_venomancer.vpcf" 
end

if IsServer() then
    function modifier_class_slow:OnCreated()
        self:OnIntervalThink()
        self:StartIntervalThink(1.0)
    end
    function modifier_class_slow:OnIntervalThink()
        local caster = self:GetCaster()
        local hAbility = self:GetAbility()
        local hParent = self:GetParent()
        local fDamage = hAbility:GetSpecialValueFor("damage")

        local iParticle = ParticleManager:CreateParticle("particles/msg_fx/msg_spell.vpcf", PATTACH_OVERHEAD_FOLLOW, hParent)
        ParticleManager:SetParticleControlEnt(iParticle, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetOrigin(), true)
        ParticleManager:SetParticleControl(iParticle, 1, Vector(0, fDamage, 6))
        ParticleManager:SetParticleControl(iParticle, 2, Vector(1, math.floor(math.log10(fDamage))+2, 100))
        ParticleManager:SetParticleControl(iParticle, 3, Vector(85+80,26+40,139+40))

        ApplyDamage({
            victim = hParent, 
            attacker = caster, 
            damage = fDamage, 
            damage_type = hAbility:GetAbilityDamageType(), 
            ability = hAbility
        })
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