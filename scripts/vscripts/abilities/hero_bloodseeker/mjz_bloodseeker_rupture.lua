
local THIS_LUA = "abilities/hero_bloodseeker/mjz_bloodseeker_rupture.lua"
LinkLuaModifier("modifier_mjz_bloodseeker_rupture", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_bloodseeker_rupture_buff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

mjz_bloodseeker_rupture = class({})
local ability_class = mjz_bloodseeker_rupture


function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_bloodseeker_rupture"
end

------------------------------------------------------------------------------------

modifier_mjz_bloodseeker_rupture = class({})
local modifier_class = modifier_mjz_bloodseeker_rupture

function modifier_class:IsHidden() return true end
function modifier_class:IsPassive() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:OnCreated(table)
        self:UpdateStackCount()
        self:StartIntervalThink(1.0)
    end

    function modifier_class:OnIntervalThink()
        self:UpdateStackCount()
    end

    function modifier_class:UpdateStackCount( )
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local modifier_buff_name = 'modifier_mjz_bloodseeker_rupture_buff'   
        local stacks = GetTalentSpecialValueFor(ability, 'damage_increase_outgoing_pct')

        if not parent:HasModifier(modifier_buff_name) then
            parent:AddNewModifier(caster, ability, modifier_buff_name, {})
        end

        local modifier = parent:FindModifierByName(modifier_buff_name)
        if modifier:GetStackCount() ~= stacks then
            modifier:SetStackCount(stacks)
        end
    end
end



------------------------------------------------------------------------------------

modifier_mjz_bloodseeker_rupture_buff = class({})
local modifier_buff = modifier_mjz_bloodseeker_rupture_buff

function modifier_buff:IsHidden() return true end
function modifier_buff:IsPurgable() return false end


function modifier_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_buff:GetModifierTotalDamageOutgoing_Percentage( )
    return self:GetStackCount()
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