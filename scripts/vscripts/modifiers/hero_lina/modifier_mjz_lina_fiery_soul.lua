LinkLuaModifier("modifier_mjz_lina_fiery_soul_attackspeed", "modifiers/hero_lina/modifier_mjz_lina_fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lina_fiery_soul_movespeed", "modifiers/hero_lina/modifier_mjz_lina_fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lina_fiery_soul_spellamp", "modifiers/hero_lina/modifier_mjz_lina_fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_lina_fiery_soul_buff = class({})
function modifier_mjz_lina_fiery_soul_buff:IsHidden() return false end
function modifier_mjz_lina_fiery_soul_buff:IsBuff() return true end
function modifier_mjz_lina_fiery_soul_buff:IsPurgable() return false end

if IsServer() then
    function modifier_mjz_lina_fiery_soul_buff:OnCreated(table)
    end

    function modifier_mjz_lina_fiery_soul_buff:OnRefresh(table)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attack_speed_bonus = GetTalentSpecialValueFor(ability, 'attack_speed_bonus')
        local move_speed_bonus = GetTalentSpecialValueFor(ability, 'move_speed_bonus')
        local spell_amp_bonus = GetTalentSpecialValueFor(ability, 'spell_amp_bonus')

        local buff_stacks = self:GetStackCount()
        local attack_speed_stacks = attack_speed_bonus * buff_stacks
        local move_speed_stacks = move_speed_bonus * buff_stacks
        local spell_amp_stacks = spell_amp_bonus * buff_stacks

        SetModifierStackCount(parent, ability, 'modifier_mjz_lina_fiery_soul_attackspeed', attack_speed_stacks)
        SetModifierStackCount(parent, ability, 'modifier_mjz_lina_fiery_soul_movespeed', move_speed_stacks)
        SetModifierStackCount(parent, ability, 'modifier_mjz_lina_fiery_soul_spellamp', spell_amp_stacks)
    end

    function modifier_mjz_lina_fiery_soul_buff:OnDestroy()
        local parent = self:GetParent()
        parent:RemoveModifierByName('modifier_mjz_lina_fiery_soul_attackspeed')
        parent:RemoveModifierByName('modifier_mjz_lina_fiery_soul_movespeed')
        parent:RemoveModifierByName('modifier_mjz_lina_fiery_soul_spellamp')
    end

end

--------------------------------------------------------------------------------

modifier_mjz_lina_fiery_soul_attackspeed = class({})

function modifier_mjz_lina_fiery_soul_attackspeed:IsHidden() return true end
function modifier_mjz_lina_fiery_soul_attackspeed:IsPurgable() return false end

function modifier_mjz_lina_fiery_soul_attackspeed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end
function modifier_mjz_lina_fiery_soul_attackspeed:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end 

--------------------------------------------------------------------------------

modifier_mjz_lina_fiery_soul_movespeed = class({})

function modifier_mjz_lina_fiery_soul_movespeed:IsHidden() return true end
function modifier_mjz_lina_fiery_soul_movespeed:IsPurgable() return false end

function modifier_mjz_lina_fiery_soul_movespeed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end
function modifier_mjz_lina_fiery_soul_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount()
end 

--------------------------------------------------------------------------------

modifier_mjz_lina_fiery_soul_spellamp = class({})

function modifier_mjz_lina_fiery_soul_spellamp:IsHidden() return true end
function modifier_mjz_lina_fiery_soul_spellamp:IsPurgable() return false end

function modifier_mjz_lina_fiery_soul_spellamp:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end
function modifier_mjz_lina_fiery_soul_spellamp:GetModifierSpellAmplify_Percentage()
    return self:GetStackCount()
end 

--------------------------------------------------------------------------------


function SetModifierStackCount(owner, ability, modifier_name, count)
    if not owner:HasModifier(modifier_name) then
        owner:AddNewModifier(owner, ability, modifier_name, {})            
    end
    owner:SetModifierStackCount(modifier_name, owner, count)    
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
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or 'value'
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end

