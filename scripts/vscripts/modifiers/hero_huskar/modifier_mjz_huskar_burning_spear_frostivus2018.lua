
-- 天赋标记 Modifier
modifier_special_bonus_unique_huskar_5 = class({})
local modifier_counter = modifier_special_bonus_unique_huskar_5

function modifier_counter:IsHidden() return true end
function modifier_counter:IsPurgable() return false end

---------------------------------------------------------------------------------------

modifier_mjz_huskar_burning_spear_frostivus2018_debuff = class({})
local modifier_counter = modifier_mjz_huskar_burning_spear_frostivus2018_debuff

function modifier_counter:IsHidden() return false end
function modifier_counter:IsPurgable() return false end
function modifier_counter:IsDebuff() return true end

---------------------------------------------------------------------------------------


modifier_mjz_huskar_burning_spear_frostivus2018_debuff_effect = class({})
local modifier_effect = modifier_mjz_huskar_burning_spear_frostivus2018_debuff_effect

function modifier_effect:IsHidden() return true end
function modifier_effect:IsPurgable() return false end
function modifier_effect:IsDebuff() return true end
function modifier_effect:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_effect:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end
function modifier_effect:GetEffectAttachType()
     return PATTACH_ABSORIGIN_FOLLOW 
end

if IsServer() then
    function modifier_effect:OnCreated(table)
        self:StartIntervalThink(1.0)
    end

    function modifier_effect:OnDestroy()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        DecreaseStackCount(caster, parent, 'modifier_mjz_huskar_burning_spear_frostivus2018_debuff')
    end

    function modifier_effect:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        
        local burn_damage = GetTalentSpecialValueFor(ability, 'burn_damage')
        local damage_type = ability:GetAbilityDamageType()
        
        -- 天赋：火矛伤害类型变为纯粹
        -- if HasTalent(caster, 'special_bonus_unique_huskar_5') then
        --     damage_type = DAMAGE_TYPE_PURE
        -- end

        local damage_table = {
			victim = parent,
			attacker = caster,
			damage = burn_damage,
			damage_type = damage_type,
			ability = ability
		}
		ApplyDamage(damage_table)
    end

end

--[[
    Decreases stack count on the visual modifier 
    This is called whenever the debuff modifier runs out
]]
function DecreaseStackCount(caster, target, modifier_name)
    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    -- just some saftey checks -just in case
    if modifier then

        -- if there is something to reduce reduce
        -- else just remove the modifier
        if count and count > 1 then
            target:SetModifierStackCount(modifier_name, caster, count-1)
        else
            target:RemoveModifierByName(modifier_name)
        end
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