LinkLuaModifier("modifier_mjz_monkey_king_mischief","modifiers/hero_monkey_king/modifier_mjz_monkey_king_mischief.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_monkey_king_mischief_invulnerable","abilities/hero_monkey_king/mjz_monkey_king_mischief.lua", LUA_MODIFIER_MOTION_NONE)

local main_ability_name = 'mjz_monkey_king_mischief'       
local sub_ability_name = 'mjz_monkey_king_untransform'
local modifier_mischief_name = 'modifier_mjz_monkey_king_mischief'

mjz_monkey_king_mischief = class({})
local ability_class = mjz_monkey_king_mischief

if IsServer() then
    function ability_class:OnSpellStart()
        local ability = self
        local caster = self:GetCaster()
        local invul_duration = ability:GetSpecialValueFor('invul_duration')

        -- Swap sub_ability
        caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )

        
        local m_invul_name = 'modifier_mjz_monkey_king_mischief_invulnerable'
        caster:AddNewModifier(caster, ability, m_invul_name, {duration = invul_duration})

        caster:AddNewModifier(caster, ability, modifier_mischief_name, {})
        
        caster:EmitSound( "Hero_MonkeyKing.Transform.On" )
    end

    function ability_class:OnUpgrade( )
		local ability = self
		local caster = self:GetCaster()
		if not caster:HasAbility(sub_ability_name) then
			caster:AddAbility(sub_ability_name)
		end
		LevelUpAbility(caster, ability, sub_ability_name)
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


---------------------------------------------------------------------------------------

modifier_mjz_monkey_king_mischief_invulnerable = class({})
local modifier_invulnerable = modifier_mjz_monkey_king_mischief_invulnerable

function modifier_invulnerable:IsHidden() return true end
function modifier_invulnerable:IsPurgable() return false end

function modifier_invulnerable:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
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