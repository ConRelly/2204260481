
local THIS_LUA = "abilities/hero_pudge/mjz_pudge_flesh_heap.lua"

LinkLuaModifier( "modifier_mjz_pudge_flesh_heap", THIS_LUA, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_pudge_flesh_heap_mrb", THIS_LUA, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_pudge_flesh_heap_str", THIS_LUA, LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------

mjz_pudge_flesh_heap = class({})
local ability_class = mjz_pudge_flesh_heap

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_pudge_flesh_heap"
end

---------------------------------------------------------------------------------------

modifier_mjz_pudge_flesh_heap = class({})
local modifier_class = modifier_mjz_pudge_flesh_heap

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:OnCreated( kv )
        local parent = self:GetParent()
        local caster = self:GetCaster()
        local ability = self:GetAbility()

        parent:AddNewModifier(caster, ability, "modifier_mjz_pudge_flesh_heap_mrb", {})
        parent:AddNewModifier(caster, ability, "modifier_mjz_pudge_flesh_heap_str", {})

        self:StartIntervalThink( 1.0 )
    end

    function modifier_class:OnDestroy( kv )
        local parent = self:GetParent()
        if parent and IsValidEntity(parent) and parent:IsAlive() then
            parent:RemoveModifierByName( "modifier_mjz_pudge_flesh_heap_mrb" )
            parent:RemoveModifierByName( "modifier_mjz_pudge_flesh_heap_str" )
        end
    end

    function modifier_class:OnIntervalThink()
		local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local ability_level = self:GetAbility():GetLevel()

        local magic_damage_reduction_pct = ability:GetTalentSpecialValueFor("magic_damage_reduction_pct")			
        local primary_attribute_per = ability:GetTalentSpecialValueFor("primary_attribute_per")			

        local m_mrb = parent:FindModifierByName("modifier_mjz_pudge_flesh_heap_mrb")
        if m_mrb and ability_level > 0 then
            if m_mrb:GetStackCount() ~= magic_damage_reduction_pct then
                m_mrb:SetStackCount(magic_damage_reduction_pct) 
            end
		else
			parent:AddNewModifier(caster, ability, "modifier_mjz_pudge_flesh_heap_mrb", {})
        end

        local m_str = parent:FindModifierByName("modifier_mjz_pudge_flesh_heap_str")
        if m_str and ability_level > 0  then
            local bonus_str = self:CalcBonusPrimaryStat(parent, primary_attribute_per)
            if m_str:GetStackCount() ~= bonus_str then
                m_str:SetStackCount(bonus_str)
            end
		else
			parent:AddNewModifier(caster, ability, "modifier_mjz_pudge_flesh_heap_str", {})
        end

    end

    function modifier_class:CalcBonusPrimaryStat(unit, primary_attribute_per )
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local STRENGTH = 0
        local AGILITY = 1
        local INTELLIGENCE = 2
        local str_bonus = 0 
        local agi_bonus = 0 
        local int_bonus = 0 
        local bonus = 0

        unit:CalculateStatBonus(false)	-- 	重新计算全部属性

        local pa = unit:GetPrimaryAttribute()
        if pa == STRENGTH  then
            bonus = unit:GetBaseStrength() * (primary_attribute_per / 100)
            str_bonus = bonus
        elseif pa == AGILITY  then
            bonus = unit:GetBaseAgility() * (primary_attribute_per / 100)
            agi_bonus = bonus
        elseif pa == INTELLIGENCE  then
            bonus = unit:GetBaseIntellect() * (primary_attribute_per / 100)
            int_bonus = bonus
        end
        
        if math.abs( bonus ) < 1 then bonus = 0 end
        return bonus
    end

    function modifier_class:CalcBonusStrength(unit, primary_attribute_per )
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        
        local str_bonus = 0 
        local agi_bonus = 0 
        local int_bonus = 0 
    
        unit:CalculateStatBonus(false)	-- 	重新计算全部属性
        local bonus = unit:GetPrimaryStatValue() * (primary_attribute_per / 100)
        if math.abs( bonus ) < 1 then bonus = 0 end
    
        local STRENGTH = 0
        local AGILITY = 1
        local INTELLIGENCE = 2
    
        local pa = unit:GetPrimaryAttribute()
        if pa == STRENGTH  then
            str_bonus = bonus
        elseif pa == AGILITY  then
            agi_bonus = bonus
        elseif pa == INTELLIGENCE  then
            int_bonus = bonus
        end
        return bonus
    end
end


---------------------------------------------------------------------------------------
modifier_mjz_pudge_flesh_heap_mrb = class({})
local modifier_class_mrb = modifier_mjz_pudge_flesh_heap_mrb

function modifier_class_mrb:IsHidden() return true end
function modifier_class_mrb:IsPurgable() return false end

function modifier_class_mrb:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_class_mrb:GetModifierMagicalResistanceBonus( params )
	return self:GetStackCount()
end

---------------------------------------------------------------------------------------

modifier_mjz_pudge_flesh_heap_str = class({})
local modifier_class_str = modifier_mjz_pudge_flesh_heap_str

function modifier_class_str:IsHidden() return true end
function modifier_class_str:IsPurgable() return false end

function modifier_class_str:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
	return funcs
end

function modifier_class_str:GetModifierBonusStats_Strength(kv)
	return self:GetStackCount()
end

------------------------------------------------------------------------------------------

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

