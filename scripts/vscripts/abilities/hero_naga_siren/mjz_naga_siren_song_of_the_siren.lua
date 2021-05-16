LinkLuaModifier("modifier_mjz_naga_siren_song_of_the_siren_caster","modifiers/hero_naga_siren/modifier_mjz_naga_siren_song_of_the_siren_caster.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_naga_siren_song_of_the_siren_aura","modifiers/hero_naga_siren/modifier_mjz_naga_siren_song_of_the_siren_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_naga_siren_song_of_the_siren_aura_friendly","modifiers/hero_naga_siren/modifier_mjz_naga_siren_song_of_the_siren_aura_friendly.lua", LUA_MODIFIER_MOTION_NONE)


local sub_ability_name = 'mjz_naga_siren_song_of_the_siren_cancel'
local modifier_caster_name = "modifier_mjz_naga_siren_song_of_the_siren_caster"
local modifier_aura_name = "modifier_mjz_naga_siren_song_of_the_siren_aura"
local modifier_aura_friendly_name = "modifier_mjz_naga_siren_song_of_the_siren_aura_friendly"

mjz_naga_siren_song_of_the_siren = class({})
local ability_class = mjz_naga_siren_song_of_the_siren


function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local duration = ability:GetSpecialValueFor('duration')

		-- Swap sub_ability
		local main_ability_name = ability:GetAbilityName()
		caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )

		-- Make cooldown
		sub_ability = caster:FindAbilityByName( sub_ability_name )
		local cooldown = sub_ability:GetCooldownTimeRemaining()
		sub_ability:EndCooldown()
		sub_ability:StartCooldown( cooldown )


		self:_AddNewModifier(modifier_caster_name, duration)
		self:_AddNewModifier(modifier_aura_name, duration)
		self:_AddNewModifier(modifier_aura_friendly_name, duration)

		-- Play the song, which will be stopped when the sub ability fires
		caster:EmitSound( "Hero_NagaSiren.SongOfTheSiren" )

	end

	function ability_class:OnUpgrade( )
		local ability = self
		local caster = self:GetCaster()
		local this_abilityName = ability:GetAbilityName()
		if not caster:HasAbility(sub_ability_name) then
			caster:AddAbility(sub_ability_name)
		end
		LevelUpAbility(caster, ability, sub_ability_name)
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