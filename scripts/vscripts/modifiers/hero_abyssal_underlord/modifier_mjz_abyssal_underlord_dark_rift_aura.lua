
local THIS_MODIFIER = "modifiers/hero_abyssal_underlord/modifier_mjz_abyssal_underlord_dark_rift_aura.lua"
LinkLuaModifier("modifier_mjz_abyssal_underlord_dark_rift_aura_debuff",THIS_MODIFIER, LUA_MODIFIER_MOTION_NONE)


modifier_mjz_abyssal_underlord_dark_rift_aura = class({})
local modifier_aura = modifier_mjz_abyssal_underlord_dark_rift_aura

function modifier_aura:IsHidden() return true end
function modifier_aura:IsPurgable() return false end

---------------------------------------------------------------

function modifier_aura:IsAura() return true end
function modifier_aura:GetModifierAura()
	return "modifier_mjz_abyssal_underlord_dark_rift_aura_debuff"
end
function modifier_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end
function modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end
function modifier_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

---------------------------------------------------------------

-----------------------------------------------------------------------------------------

modifier_mjz_abyssal_underlord_dark_rift_aura_debuff = class({})
local modifier_debuff = modifier_mjz_abyssal_underlord_dark_rift_aura_debuff 

function modifier_debuff:IsHidden() return true end
function modifier_debuff:IsDebuff() return true end
function modifier_debuff:IsPurgable() return false end


function modifier_debuff:DeclareFunctions()
	local funcs = {
	}
	return funcs
end

