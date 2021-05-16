
local main_ability_name = "mjz_naga_siren_song_of_the_siren"
local modifier_caster_name = "modifier_mjz_naga_siren_song_of_the_siren_caster"
local modifier_aura_name = "modifier_mjz_naga_siren_song_of_the_siren_aura"
local modifier_aura_friendly_name = "modifier_mjz_naga_siren_song_of_the_siren_aura_friendly"


mjz_naga_siren_song_of_the_siren_cancel = class({})
local ability_class = mjz_naga_siren_song_of_the_siren_cancel


if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()

		caster:RemoveModifierByName(modifier_caster_name)
		caster:RemoveModifierByName(modifier_aura_name)
		caster:RemoveModifierByName(modifier_aura_friendly_name)

		-- Plays the cancel sound
		caster:EmitSound( "Hero_NagaSiren.SongOfTheSiren.Cancel" )
	end

	function ability_class:OnUpgrade( )
		local ability = self
		local caster = self:GetCaster()
		LevelUpAbility(caster, ability, main_ability_name)
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