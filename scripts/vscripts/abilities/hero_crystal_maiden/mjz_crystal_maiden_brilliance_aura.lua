
local THIS_LUA = "abilities/hero_crystal_maiden/mjz_crystal_maiden_brilliance_aura.lua"
LinkLuaModifier("modifier_mjz_crystal_maiden_brilliance_aura", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_crystal_maiden_brilliance_aura_effect", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_crystal_maiden_brilliance_aura_manacost", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

mjz_crystal_maiden_brilliance_aura = class({})
local ability_class = mjz_crystal_maiden_brilliance_aura

function ability_class:GetIntrinsicModifierName() return "modifier_mjz_crystal_maiden_brilliance_aura" end

---------------------------------------------------------------------------------------

modifier_mjz_crystal_maiden_brilliance_aura = class({})
local modifier_class = modifier_mjz_crystal_maiden_brilliance_aura

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:IsAura() return true end
function modifier_class:GetAuraRadius() return FIND_UNITS_EVERYWHERE end
function modifier_class:GetModifierAura() return "modifier_mjz_crystal_maiden_brilliance_aura_effect" end
function modifier_class:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function modifier_class:GetAuraEntityReject(target) return self:GetParent():IsIllusion() end
function modifier_class:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function modifier_class:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function modifier_class:GetAuraDuration() return 0.5 end

---------------------------------------------------------------------------------------

modifier_mjz_crystal_maiden_brilliance_aura_effect = class({})
local modifier_effect = modifier_mjz_crystal_maiden_brilliance_aura_effect

function modifier_effect:IsHidden() return false end
function modifier_effect:IsPurgable() return false end
function modifier_effect:IsBuff() return true end
function modifier_effect:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE} end
function modifier_effect:GetModifierTotalPercentageManaRegen()
	if self:GetParent() == self:GetCaster() then
		if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_self_total_pct") end
	else
		if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_total_pct") end
	end
end

if IsServer() then
	function modifier_effect:OnCreated(table)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		parent:AddNewModifier(caster, ability, "modifier_mjz_crystal_maiden_brilliance_aura_manacost", {})
	end

	function modifier_effect:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveModifierByName("modifier_mjz_crystal_maiden_brilliance_aura_manacost")
	end
end


---------------------------------------------------------------------------------------

modifier_mjz_crystal_maiden_brilliance_aura_manacost = class({})
local modifier_manacost = modifier_mjz_crystal_maiden_brilliance_aura_manacost

function modifier_manacost:IsHidden() return true end
function modifier_manacost:IsPurgable() return false end
function modifier_manacost:IsBuff() return true end
function modifier_manacost:DeclareFunctions() return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE} end

function modifier_manacost:GetModifierPercentageManacost()
	if IsServer() then
		local manacost_reduction = GetTalentSpecialValueFor(self:GetAbility(), "manacost_reduction")
		if self:GetStackCount() ~= manacost_reduction then
			self:SetStackCount(manacost_reduction)
		end
	end
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