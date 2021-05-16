LinkLuaModifier("modifier_mjz_meepo_meepo_king", "abilities/hero_meepo/mjz_meepo_meepo_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_meepo_meepo_king_experience", "abilities/hero_meepo/mjz_meepo_meepo_king.lua", LUA_MODIFIER_MOTION_NONE)

----------------------------------------------------------------------------

mjz_meepo_meepo_king = class({})
local ability_class = mjz_meepo_meepo_king

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('experience_radius')
end

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_meepo_meepo_king"
end

----------------------------------------------------------------------------


modifier_mjz_meepo_meepo_king = class({})

function modifier_mjz_meepo_meepo_king:IsPassive()  return true end
function modifier_mjz_meepo_meepo_king:IsHidden()  return true end
function modifier_mjz_meepo_meepo_king:IsPurgable()  return false end


function modifier_mjz_meepo_meepo_king:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MODEL_SCALE,		
    }
end

function modifier_mjz_meepo_meepo_king:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor('bonus_damage_pct')
end

function modifier_mjz_meepo_meepo_king:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_mjz_meepo_meepo_king:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

function modifier_mjz_meepo_meepo_king:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_resistance')
end

function modifier_mjz_meepo_meepo_king:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor('bonus_health_regen')
end

function modifier_mjz_meepo_meepo_king:GetModifierModelScale()
    return self:GetAbility():GetSpecialValueFor('model_multiplier')
end

------------------------------------------------

function modifier_mjz_meepo_meepo_king:IsAura()
	return true
end

function modifier_mjz_meepo_meepo_king:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("experience_radius")
end

function modifier_mjz_meepo_meepo_king:GetModifierAura()
    return "modifier_mjz_meepo_meepo_king_experience"
end

function modifier_mjz_meepo_meepo_king:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_mjz_meepo_meepo_king:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_mjz_meepo_meepo_king:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_mjz_meepo_meepo_king:GetAuraEntityReject(entity)
	return self:GetParent():IsIllusion()
end

function modifier_mjz_meepo_meepo_king:GetAuraDuration()
    return 0.5
end

------------------------------------------------

----------------------------------------------------------------------------

modifier_mjz_meepo_meepo_king_experience = class({})

function modifier_mjz_meepo_meepo_king_experience:IsPassive()  return true end
function modifier_mjz_meepo_meepo_king_experience:IsHidden()  return true end
function modifier_mjz_meepo_meepo_king_experience:IsPurgable()  return false end

if IsServer() then
	function modifier_mjz_meepo_meepo_king_experience:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_DEATH,
		}
	end

	function modifier_mjz_meepo_meepo_king_experience:OnDeath(event)
		if self:GetParent() ~= event.unit then return nil end

		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()

		if parent:IsIllusion() then return nil end
		if caster:IsIllusion() then return nil end
		if not caster:IsRealHero() then return nil end
		if caster:PassivesDisabled() then return nil end

		local exp_pct = ability:GetSpecialValueFor('experience_pct')
		local deathXP = parent:GetDeathXP()

		if deathXP > 0 then
			local xp = deathXP * (exp_pct / 100.0)
			caster:AddExperience(xp, DOTA_ModifyXP_Unspecified, true, true)
		end
	end
end





