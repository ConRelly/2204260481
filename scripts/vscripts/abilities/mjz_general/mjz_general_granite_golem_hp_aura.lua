LinkLuaModifier("modifier_mjz_general_granite_golem_hp_aura", "abilities/mjz_general/mjz_general_granite_golem_hp_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_general_granite_golem_hp_aura_bonus", "abilities/mjz_general/mjz_general_granite_golem_hp_aura.lua", LUA_MODIFIER_MOTION_NONE)


mjz_general_granite_golem_hp_aura = class({})

function mjz_general_granite_golem_hp_aura:GetIntrinsicModifierName()
    return "modifier_mjz_general_granite_golem_hp_aura"
end


-----------------------------------------------------------------------------------------

modifier_mjz_general_granite_golem_hp_aura = class({})
local modifier_aura = modifier_mjz_general_granite_golem_hp_aura
function modifier_mjz_general_granite_golem_hp_aura:IsHidden() return true end
function modifier_mjz_general_granite_golem_hp_aura:IsPurgable() return false end

---------------------------------------------------------------

function modifier_aura:IsAura() return true end
function modifier_aura:GetModifierAura()
	return "modifier_mjz_general_granite_golem_hp_aura_bonus"
end
function modifier_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end
function modifier_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

---------------------------------------------------------------

modifier_mjz_general_granite_golem_hp_aura_bonus = class({})
local modifier_aura_bonus = modifier_mjz_general_granite_golem_hp_aura_bonus
function modifier_aura_bonus:IsHidden() return false end
function modifier_aura_bonus:IsPurgable() return false end

function modifier_aura_bonus:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,       -- GetModifierExtraHealthPercentage
    } 
end

function modifier_aura_bonus:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_hp") end
end

