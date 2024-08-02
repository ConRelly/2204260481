LinkLuaModifier("modifier_mjz_spell_reflect", "modifiers/modifier_mjz_spell_reflect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_spell_reflect_friendly", "modifiers/modifier_mjz_spell_reflect_friendly.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_antimage_counterspell", "abilities/hero_antimage/mjz_antimage_counterspell.lua", LUA_MODIFIER_MOTION_NONE)

mjz_antimage_counterspell = class({})
local ability_class = mjz_antimage_counterspell

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_antimage_counterspell"
end

function ability_class:GetAOERadius(  )
	return self:GetSpecialValueFor("cast_range")	 -- return self.BaseClass.GetAOERadius(self)
end
function ability_class:GetCastRange(  )
	return self:GetSpecialValueFor("cast_range")	 -- return self.BaseClass.GetAOERadius(self)
end
function ability_class:GetCooldown(iLevel)
    return self:GetSpecialValueFor("cooldown")		-- return self.BaseClass.GetCooldown(self, iLevel)
end

function ability_class:OnUpgrade( keys )
	local caster = self:GetCaster()
	local modifer = caster:FindModifierByName('modifier_mjz_antimage_counterspell')
	if modifer then
		modifer:ForceRefresh()
	end
end

function ability_class:OnSpellStart(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local target = self:GetCursorTarget()

		local nLevel = ability:GetLevel() - 1
		local duration = ability:GetLevelSpecialValueFor('duration', nLevel)
		local hModifierTable = {
			duration = duration,
		}

		local modifer = target:FindModifierByName('modifier_mjz_spell_reflect_friendly')
		if modifer then
			modifer:ForceRefresh()
		else
			target:AddNewModifier(caster, ability, 'modifier_mjz_spell_reflect_friendly', hModifierTable)
		end
	end
end

function ability_class:_StartCooldown()    
	local ability = self
	ability:StartCooldown( ability:GetCooldown(ability:GetLevel() - 1) )
	self.last_time = GameRules:GetGameTime()
end

-----------------------------------------------------------------------------------

modifier_mjz_antimage_counterspell = class({})
local modifier_class = modifier_mjz_antimage_counterspell


function modifier_class:IsHidden()
    return true
end
function modifier_class:IsPurgable()
    return false
end

function modifier_class:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs 
end
function modifier_class:GetModifierMagicalResistanceBonus()  
	return self:GetStackCount()
end

if IsServer() then
	function modifier_class:OnRefresh(keys)
		self:_Update()
	end
	function modifier_class:OnCreated(keys)
		local parent = self:GetParent()
		local ability = self:GetAbility()

		if not parent:HasModifier('modifier_mjz_spell_reflect') then
			parent:AddNewModifier(parent, ability, 'modifier_mjz_spell_reflect', {})
		end

		self:_Update()
		self:StartIntervalThink(5)
	end

	function modifier_class:OnIntervalThink()
		self:_Update()
	end

	function modifier_class:_Update( keys )
		local ability = self:GetAbility()
		local magic_resistance = GetTalentSpecialValueFor(ability, "magic_resistance")
		self:SetStackCount(magic_resistance)
	end
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