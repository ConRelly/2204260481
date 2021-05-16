LinkLuaModifier("modifier_mjz_phoenix_sun_ray_caster","modifiers/hero_phoenix/modifier_mjz_phoenix_sun_ray_caster.lua", LUA_MODIFIER_MOTION_NONE)

local SUB_ABILITY_NAME = 'mjz_phoenix_sun_ray_cancel'
local ABILITY_TOGGLE_MOVE_NAME = 'mjz_phoenix_sun_ray_toggle_move'
local MODIFIER_CASTER_NAME = "modifier_mjz_phoenix_sun_ray_caster"

mjz_phoenix_sun_ray = class({})
local ability_class = mjz_phoenix_sun_ray

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('cast_range')
end

function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('cast_range')
end


if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local duration = ability:GetSpecialValueFor('duration')

		-- Swap sub_ability
		local main_ability_name = ability:GetAbilityName()
		caster:SwapAbilities( main_ability_name, SUB_ABILITY_NAME, false, true )

		-- Make cooldown
		sub_ability = caster:FindAbilityByName( SUB_ABILITY_NAME )
		local cooldown = sub_ability:GetCooldownTimeRemaining()
		sub_ability:EndCooldown()
		sub_ability:StartCooldown( cooldown )

		caster:EmitSound( "Hero_Phoenix.SunRay.Cast" )

		self:_AddNewModifier(MODIFIER_CASTER_NAME, duration)
	end

	function ability_class:OnUpgrade( )
		local ability = self
		local caster = self:GetCaster()
		local this_abilityName = ability:GetAbilityName()
		if not caster:HasAbility(SUB_ABILITY_NAME) then
			caster:AddAbility(SUB_ABILITY_NAME)
		end
		LevelUpAbility(caster, ability, SUB_ABILITY_NAME)

		ExtraAbility(caster, ability)
	end

	function ability_class:_AddNewModifier( modifier_name, duration)
		local ability = self
		local caster = self:GetCaster()

		local modifier = caster:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
			modifier:ForceRefresh()
		else
			caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
		end
	end

	function LevelUpAbility( caster, ability, ability_name)
		local this_ability = ability		
		local this_abilityName = this_ability:GetAbilityName()
		local this_abilityLevel = this_ability:GetLevel()
	
		-- The ability to level up
		local ability_handle = caster:FindAbilityByName(ability_name)	
		local ability_level = ability_handle:GetLevel()
	
		-- Check to not enter a level up loop
		if ability_level ~= this_abilityLevel then
			ability_handle:SetLevel(this_abilityLevel)
		end
	end

	function ExtraAbility(caster, ability)
		local ability_tm = caster:FindAbilityByName(ABILITY_TOGGLE_MOVE_NAME)
		if ability_tm and ability_tm:GetLevel() == 0 then
			ability_tm:SetLevel(1)
		end
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