
local MODIFIER_CASTER_NAME = 'modifier_mjz_doom_bringer_doom_caster'

LinkLuaModifier(MODIFIER_CASTER_NAME,"modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_doom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_doom_bringer_doom_debuff","modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_doom.lua", LUA_MODIFIER_MOTION_NONE)



mjz_doom_bringer_doom = class({})
local ability_class = mjz_doom_bringer_doom

function ability_class:GetAOERadius()
	if self:GetCaster() then return  self:GetCaster():Script_GetAttackRange() + 250 end --self:GetSpecialValueFor('radius')
end

function ability_class:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE
	end
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function ability_class:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor('cooldown_scepter')
	end
    -- return self.BaseClass.GetCooldown( self, nLevel )
    return self:GetSpecialValueFor('cooldown')
end

function ability_class:OnToggle()
	if IsServer() then
		local caster = self:GetCaster()


		if not caster:HasScepter() then return nil end

		if self:GetToggleState() then
			caster:AddNewModifier(caster, self, MODIFIER_CASTER_NAME, {})
		else
			caster:RemoveModifierByName(MODIFIER_CASTER_NAME)
			self:StartCooldown(self:GetCooldown(self:GetLevel() - 1))
		end
	end
end

function ability_class:OnSpellStart()
	if IsServer() then
		local duration = self:GetSpecialValueFor("duration")
		if self:GetCaster():HasModifier(MODIFIER_CASTER_NAME) then
			self:GetCaster():RemoveModifierByName(MODIFIER_CASTER_NAME)
		end
		self:GetCaster():AddNewModifier(self:GetCaster(), self, MODIFIER_CASTER_NAME, {duration = duration})
	end
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