
local MAIN_ABILITY_NAME = 'mjz_monkey_king_mischief'
local SUB_ABILITY_NAME = 'mjz_monkey_king_untransform'
local MODIFIER_MISCHIEF_NAME = 'modifier_mjz_monkey_king_mischief'


mjz_monkey_king_untransform = class({})
local ability_class = mjz_monkey_king_untransform


if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()

		caster:RemoveModifierByName(MODIFIER_MISCHIEF_NAME)

		-- Plays the cancel sound
        caster:EmitSound( "Hero_MonkeyKing.Transform.Off" )
	end

    function ability_class:OnUpgrade( )
		local ability = self
        local caster = self:GetCaster()
        if not caster:HasAbility(MAIN_ABILITY_NAME) then
			caster:AddAbility(MAIN_ABILITY_NAME)
		end
		LevelUpAbility(caster, ability, MAIN_ABILITY_NAME)
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