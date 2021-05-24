

modifier_mjz_doom_bringer_devour = class({})
local modifier_class = modifier_mjz_doom_bringer_devour

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_class:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end


-----------------------------------------------------------------------------------------

modifier_mjz_doom_bringer_devour_regen = class({})
local modifier_regen = modifier_mjz_doom_bringer_devour_regen

function modifier_regen:IsHidden() return false end
function modifier_regen:IsPurgable() return false end
function modifier_regen:IsBuff() return true end

function modifier_regen:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE		-- 效果能够存在多个
end

function modifier_regen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_regen:GetModifierConstantHealthRegen( params )
	return self.regen
end

function modifier_regen:OnCreated( kv )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen" )
end

function modifier_regen:OnRefresh( kv )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen" )
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