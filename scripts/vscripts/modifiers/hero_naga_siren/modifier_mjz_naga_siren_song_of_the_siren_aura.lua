LinkLuaModifier("modifier_mjz_naga_siren_song_of_the_siren_debuff","modifiers/hero_naga_siren/modifier_mjz_naga_siren_song_of_the_siren_aura.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_naga_siren_song_of_the_siren_aura = class({})
local modifier_aura = modifier_mjz_naga_siren_song_of_the_siren_aura

function modifier_aura:IsHidden() return true end
function modifier_aura:IsPurgable() return false end

---------------------------------------------------------------

function modifier_aura:IsAura() return true end
function modifier_aura:GetModifierAura()
	return "modifier_mjz_naga_siren_song_of_the_siren_debuff"
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

modifier_mjz_naga_siren_song_of_the_siren_debuff = class({})
local modifier_debuff = modifier_mjz_naga_siren_song_of_the_siren_debuff 

function modifier_debuff:IsHidden() return false end
function modifier_debuff:IsDebuff() return true end
function modifier_debuff:IsPurgable() return false end

function modifier_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		-- [MODIFIER_STATE_INVULNERABLE] = true,
	}
end

function modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}
	return funcs
end
function modifier_debuff:GetOverrideAnimation( )
	return ACT_DOTA_DISABLED
end
function modifier_debuff:GetOverrideAnimationRate( )
	return self:GetAbility():GetSpecialValueFor('animation_rate')
end

function modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_song_debuff.vpcf"
end
function modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_siren_song.vpcf"
end

function modifier_debuff:StatusEffectPriority()
	return 10
end

if IsServer() then
	function modifier_debuff:OnCreated(table)
		
	end

	function modifier_debuff:OnDestroy()
		
	end
end

