LinkLuaModifier("modifier_mjz_bloodseeker_rupture", "abilities/hero_bloodseeker/mjz_bloodseeker_rupture.lua", LUA_MODIFIER_MOTION_NONE)

mjz_bloodseeker_rupture = class({})
function mjz_bloodseeker_rupture:GetIntrinsicModifierName() return "modifier_mjz_bloodseeker_rupture" end

------------------------------------------------------------------------------------

modifier_mjz_bloodseeker_rupture = class({})
function modifier_mjz_bloodseeker_rupture:IsHidden() return true end
function modifier_mjz_bloodseeker_rupture:IsPassive() return true end
function modifier_mjz_bloodseeker_rupture:IsPurgable() return false end
function modifier_mjz_bloodseeker_rupture:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_mjz_bloodseeker_rupture:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_increase_outgoing_pct") + talent_value(self:GetCaster(), "special_bonus_unique_mjz_bloodseeker_rupture_01")
end

------------------------------------------------------------------------------------

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