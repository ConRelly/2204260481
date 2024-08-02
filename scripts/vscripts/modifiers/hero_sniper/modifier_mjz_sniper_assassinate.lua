

modifier_mjz_sniper_assassinate_caster = class({})
local modifier_caster = modifier_mjz_sniper_assassinate_caster

function modifier_caster:IsHidden() return true end
function modifier_caster:IsPurgable() return false end

if IsServer() then
    function modifier_caster:DeclareFunctions()
        local func = {
            MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        }
        return func
    end

    function modifier_caster:GetModifierPreAttack_CriticalStrike()
        local crit_chance = 100
        local crit_bonus = self:GetAbility():GetSpecialValueFor("scepter_crit_bonus")
        local bonus_damage_pct = GetTalentSpecialValueFor(self:GetAbility(), 'bonus_damage_pct')
        crit_bonus = crit_bonus + crit_bonus *  (bonus_damage_pct / 100.0)    
        if RollPercentage(crit_chance) then
            return crit_bonus
        end
    end
end

------------------------------------------------------------------------------

modifier_mjz_sniper_assassinate = class({})
local modifier_target = modifier_mjz_sniper_assassinate

function modifier_target:IsHidden() return false end
function modifier_target:IsPurgable() return false end


--[[
    function modifier_target:GetEffectName()
        return "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf"
    end
    function modifier_target:GetEffectAttachType()
        return PATTACH_OVERHEAD_FOLLOW
    end
]]

function modifier_target:OnCreated( kv )
	if IsServer() then
		self:PlayEffects()
	end
end

function modifier_target:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber() )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		true
	)
end

------------------------------------------------------------------------------

modifier_mjz_sniper_assassinate_vision = class({})
local modifier_vision = modifier_mjz_sniper_assassinate_vision

function modifier_vision:IsHidden() return true end
function modifier_vision:IsPurgable() return false end

function modifier_vision:CheckState() 
    local state = {
        [MODIFIER_STATE_PROVIDES_VISION] = true,
        [MODIFIER_STATE_INVISIBLE] = false,
    }
    return state
end

function modifier_vision:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
	return funcs
end
function modifier_vision:GetModifierProvidesFOWVision()
	return true
end

------------------------------------------------------------------------------


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

