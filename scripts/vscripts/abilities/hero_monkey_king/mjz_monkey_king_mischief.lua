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