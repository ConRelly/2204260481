local THIS_MODIFIER = "modifiers/hero_abyssal_underlord/modifier_mjz_abyssal_underlord_dark_rift_aura_friendly.lua"
LinkLuaModifier("modifier_mjz_abyssal_underlord_dark_rift_buff", THIS_MODIFIER, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_abyssal_underlord_dark_rift_buff_regen", THIS_MODIFIER, LUA_MODIFIER_MOTION_NONE)


modifier_mjz_abyssal_underlord_dark_rift_aura_friendly = class({})
local modifier_aura = modifier_mjz_abyssal_underlord_dark_rift_aura_friendly

function modifier_aura:IsHidden() return true end
function modifier_aura:IsPurgable() return false end

---------------------------------------------------------------

function modifier_aura:IsAura() return true end
function modifier_aura:GetModifierAura()
	return "modifier_mjz_abyssal_underlord_dark_rift_buff"
end
function modifier_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end
function modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end
function modifier_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

---------------------------------------------------------------

-----------------------------------------------------------------------------------------

modifier_mjz_abyssal_underlord_dark_rift_buff = class({})
local modifier_buff = modifier_mjz_abyssal_underlord_dark_rift_buff 

function modifier_buff:IsHidden() return false end
function modifier_buff:IsBuff() return true end
function modifier_buff:IsPurgable() return false end

function modifier_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_buff:GetModifierHealthRegenPercentage( )
    return self:GetAbility():GetSpecialValueFor('regen_rate')
end

function modifier_buff:GetModifierMagicalResistanceBonus( )
    return self:GetAbility():GetSpecialValueFor('magic_resistance')
end

function modifier_buff:GetModifierPhysicalArmorBonus( )
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end


if IsServer() then
    function modifier_buff:OnCreated(table)
        local parent = self:GetParent()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
		local regen_rate = ability:GetSpecialValueFor('regen_rate')
        self.modifier_regen = 'modifier_mjz_abyssal_underlord_dark_rift_buff_regen'

        --[[
            local stack_count = regen_rate * 10

            if not parent:HasModifier(self.modifier_regen) then
                parent:AddNewModifier(caster, ability, self.modifier_regen, {})
                parent:SetModifierStackCount(self.modifier_regen, caster, stack_count)
            end
        ]]
        
        self:_AddEffect()
    end
    
    function modifier_buff:OnDestroy()
        local parent = self:GetParent()
        if parent:HasModifier(self.modifier_regen) then
            parent:RemoveModifierByName(self.modifier_regen)
        end
        if self.particle then
            ParticleManager:DestroyParticle( self.particle, false )
            ParticleManager:ReleaseParticleIndex( self.particle )
        end
    end

    function modifier_buff:_AddEffect( )
        local radius = self:GetParent():GetCollisionPadding()     -- 100
        local nFXIndex1 = ParticleManager:CreateParticle( "particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( nFXIndex1, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControl( nFXIndex1, 1, Vector(radius, 0, 0))
		ParticleManager:SetParticleControlEnt( nFXIndex1, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex1, 3, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex1, 5, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex1, 6, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex1, 20, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        self.particle = nFXIndex1
    end
end

-----------------------------------------------------------------------------------------

modifier_mjz_abyssal_underlord_dark_rift_buff_regen = class({})
local modifier_buff_regen = modifier_mjz_abyssal_underlord_dark_rift_buff_regen

function modifier_buff_regen:IsHidden() return true end
function modifier_buff_regen:IsBuff() return true end
function modifier_buff_regen:IsPurgable() return false end

function modifier_buff_regen:DeclareFunctions()
	local funcs = {
        -- MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
	return funcs
end
function modifier_buff_regen:GetModifierConstantHealthRegen( )
    return 0
end
function modifier_buff_regen:GetModifierHealthRegenPercentage( )
    return self:GetStackCount() / 10.0
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