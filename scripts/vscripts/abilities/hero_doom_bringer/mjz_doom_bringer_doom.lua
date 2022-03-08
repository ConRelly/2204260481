
local MODIFIER_CASTER_NAME = 'modifier_mjz_doom_bringer_doom_caster'

LinkLuaModifier(MODIFIER_CASTER_NAME,"modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_doom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_doom_bringer_doom_debuff","modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_doom.lua", LUA_MODIFIER_MOTION_NONE)



mjz_doom_bringer_doom = class({})
local ability_class = mjz_doom_bringer_doom

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
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