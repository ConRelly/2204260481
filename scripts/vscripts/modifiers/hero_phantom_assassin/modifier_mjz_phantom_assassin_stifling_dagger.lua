
modifier_mjz_stifling_dagger_slow = class({})
local modifier_slow = modifier_mjz_stifling_dagger_slow

function modifier_slow:IsHidden() return false end
function modifier_slow:IsPurgable() return true end
function modifier_slow:IsDebuff() return true end

function modifier_slow:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf"
end
function modifier_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_slow:GetModifierMoveSpeedBonus_Percentage( )
    return self:GetAbility():GetSpecialValueFor('move_slow')
end

--------------------------------------------------------------------------------------

modifier_mjz_stifling_dagger_attack_factor = class({})
local modifier_attack_factor = modifier_mjz_stifling_dagger_attack_factor

function modifier_attack_factor:IsHidden() return true end
function modifier_attack_factor:IsPurgable() return false end

function modifier_attack_factor:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true   -- When attacking uphill, cannot miss units but can still miss buildings.
	}
end
function modifier_attack_factor:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

function modifier_attack_factor:GetModifierDamageOutgoing_Percentage( )
    return self:GetAbility():GetSpecialValueFor('attack_factor')    
end

--------------------------------------------------------------------------------------

modifier_mjz_stifling_dagger_attack_bonus = class({})
local modifier_attack_bonus = modifier_mjz_stifling_dagger_attack_bonus

function modifier_attack_bonus:IsHidden() return true end
function modifier_attack_bonus:IsPurgable() return false end

function modifier_attack_bonus:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}
	return funcs
end
function modifier_attack_bonus:GetModifierBaseAttack_BonusDamage( )
    return self:GetAbility():GetSpecialValueFor('base_damage')    
end