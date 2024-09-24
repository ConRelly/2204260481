LinkLuaModifier("modifier_mjz_night_stalker_darkness","abilities/hero_night_stalker/mjz_night_stalker_darkness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_darkness_damage","abilities/hero_night_stalker/mjz_night_stalker_darkness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_bonus","abilities/hero_night_stalker/mjz_night_stalker_darkness.lua", LUA_MODIFIER_MOTION_NONE)

mjz_night_stalker_darkness = class({})
local ability_class = mjz_night_stalker_darkness

if IsServer() then
    function ability_class:OnSpellStart()
        local caster = self:GetCaster()
        if caster and caster:IsAlive() then
            local duration = self:GetSpecialValueFor('duration')
            local modifier_name = 'modifier_mjz_night_stalker_darkness'
            local modifier_damage_name = 'modifier_mjz_night_stalker_darkness_damage'
            local modifier_bonus_special = "modifier_mjz_night_stalker_bonus"
    --		self:_AddModifier(modifier_name, duration)
    --		self:_AddModifier(modifier_damage_name, duration)
            caster:AddNewModifier(caster, self, modifier_name, {duration = duration})
            caster:AddNewModifier(caster, self, modifier_damage_name, {duration = duration})
            if IsStalkerList(caster) then
                if not caster:HasModifier(modifier_bonus_special) then
                    caster:AddNewModifier(caster, self, modifier_bonus_special, {})
                end 
            elseif RollPercentage(_G._stalker_chance) then
                if not caster:HasModifier(modifier_bonus_special) then
                    caster:AddNewModifier(caster, self, modifier_bonus_special, {duration = 300})
                end 
            end    

            local p_name = "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf"
            local nFXIndex = ParticleManager:CreateParticle( p_name, PATTACH_ABSORIGIN_FOLLOW, caster )
            ParticleManager:SetParticleControl(nFXIndex, 0, caster:GetAbsOrigin())
            ParticleManager:SetParticleControl(nFXIndex, 1, caster:GetAbsOrigin())
    --		ParticleManager:ReleaseParticleIndex(nFXIndex)

            caster:EmitSound("Hero_Nightstalker.Darkness")
        end   
    end
--[[
    function ability_class:_AddModifier( modifier_name, duration, is_ability_modifier)
        local ability = self
        local caster = self:GetCaster()
        local modifier = caster:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
			modifier:ForceRefresh()
        else
            if is_ability_modifier then
                ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {duration = duration})
            else
                caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
            end
        end
    end
]]
end

---------------------------------------------------------------------------------------

modifier_mjz_night_stalker_darkness = class({})
local modifier_class = modifier_mjz_night_stalker_darkness

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:GetActivityTranslationModifiers() return "hunter_night" end

function modifier_class:OnCreated()
    self:GetActivityTranslationModifiers()
	if IsServer() then
		GameRules:BeginNightstalkerNight(self:GetDuration())
		self:StartIntervalThink(FrameTime() * 3)
	end
end
function modifier_class:OnRefresh()
	self:OnCreated()
end
function modifier_class:OnIntervalThink()
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetCaster():GetCurrentVisionRange(), FrameTime() * 3, false)
end

--[[
    function modifier_class:GetEffectName()
        return "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf"
    end
    function modifier_class:GetEffectAttachType()
        return PATTACH_ABSORIGIN_FOLLOW
    end
]]

--[[
    function modifier_class:GetHeroEffectName()
        return "particles/units/heroes/hero_night_stalker/nightstalker_darkness_hero_effect.vpcf"
    end
    function modifier_class:HeroEffectPriority()
        return 100
    end
]]
function modifier_class:CheckState()
	return {[MODIFIER_STATE_FLYING] = true}
end
function modifier_class:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetAbsOrigin(), false)
	end
end
function modifier_class:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
    }
end
function modifier_class:GetBonusVisionPercentage( )
    if self:GetAbility() then
	    return self:GetAbility():GetSpecialValueFor('bonus_vision_pct')
    end
    return 0    
end
function modifier_class:GetModifierEvasion_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('evasion_chance')
    end
    return 0
end
function modifier_class:GetModifierModelScale( )
    if self:GetAbility() then
        if self:GetParent():HasModifier("modifier_mjz_night_stalker_bonus") then
            return -50
        end    
	    return self:GetAbility():GetSpecialValueFor('model_scale')
    end
    return 0    
end
function modifier_class:GetModifierPureLifesteal()
	if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("lifesteal_pct")
    end
end

-----------------------------------------------------------------------------------------

modifier_mjz_night_stalker_darkness_damage = class({})
local modifier_damage = modifier_mjz_night_stalker_darkness_damage

function modifier_damage:IsHidden() return true end
function modifier_damage:IsPurgable() return false end
function modifier_damage:GetActivityTranslationModifiers() return "hunter_night" end

function modifier_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
end
function modifier_damage:GetModifierBaseAttack_BonusDamage()
    if IsServer() then
        if self:GetAbility() then
            local parent = self:GetParent()
            local stack_count = GetTalentSpecialValueFor(self:GetAbility(), 'bonus_damage')
            if parent and HasSuperScepter(parent) then
                local ms_bonus_attack = self:GetAbility():GetSpecialValueFor('ms_bonus_attack') * 0.01
                local ms = parent:GetIdealSpeed()
                local bonus_attck = ms * ms_bonus_attack
                stack_count = stack_count + bonus_attck
            end    
            if self:GetStackCount() ~= stack_count then
                self:SetStackCount(stack_count)
            end
        end    
    end
    return self:GetStackCount()
end


-----------------------------------------------------------------------------------------

modifier_mjz_night_stalker_bonus = class({})
function modifier_mjz_night_stalker_bonus:IsHidden() return false end
function modifier_mjz_night_stalker_bonus:IsPurgable() return false end
function modifier_mjz_night_stalker_bonus:RemoveOnDeath() return false end
function modifier_mjz_night_stalker_bonus:GetTexture() return "kuma" end

function modifier_mjz_night_stalker_bonus:CheckState()
	local state = {
        [MODIFIER_STATE_CANNOT_MISS] = true,
        --[MODIFIER_STATE_STUNNED] = false
    }
	
	return state
end

function modifier_mjz_night_stalker_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EXP_RATE_BOOST,
        MODIFIER_PROPERTY_GOLD_RATE_BOOST,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_mjz_night_stalker_bonus:GetModifierPercentageExpRateBoost()
    return 33
end
function modifier_mjz_night_stalker_bonus:GetModifierPercentageGoldRateBoost()
    return 33
end
function modifier_mjz_night_stalker_bonus:GetModifierPreAttack_CriticalStrike()
    if RollPercentage(10) then
        local crit_dmg = self:GetParent():GetLevel() * 33 + 100
        return crit_dmg
    end   
end
function modifier_mjz_night_stalker_bonus:GetAbsoluteNoDamagePure()  
    if RollPercentage(60) then
        return 1
    end   
end
function modifier_mjz_night_stalker_bonus:GetModifierIgnoreMovespeedLimit()
    return 1
end
function modifier_mjz_night_stalker_bonus:GetModifierTotalDamageOutgoing_Percentage()
    return 33
end
function modifier_mjz_night_stalker_bonus:GetModifierIncomingDamage_Percentage()
    return -50
end
-------------------------------------------------
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