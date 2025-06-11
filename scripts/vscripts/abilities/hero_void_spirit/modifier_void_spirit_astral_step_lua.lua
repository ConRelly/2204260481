-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_void_spirit_astral_step_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_void_spirit_astral_step_lua:IsHidden()
	return false
end

function modifier_void_spirit_astral_step_lua:IsDebuff()
	return true
end

function modifier_void_spirit_astral_step_lua:IsStunDebuff()
	return false
end

function modifier_void_spirit_astral_step_lua:IsPurgable()
	return false
end

function modifier_void_spirit_astral_step_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_void_spirit_astral_step_lua:OnCreated( kv )
	self.slow = -self:GetAbility():GetSpecialValueFor( "movement_slow_pct" )
	if not IsServer() then return end
	local caster = self:GetCaster()
	local mana_mult = self:GetAbility():GetSpecialValueFor( "mana_mult" )	
	local caster_manreg = caster:GetManaRegen()
	local manareg = caster_manreg * mana_mult
	local caster_lvl_mult = caster:GetLevel() * self:GetAbility():GetSpecialValueFor( "pop_damage" )

	self.damage = caster_lvl_mult + manareg	
end

function modifier_void_spirit_astral_step_lua:OnRefresh( kv )
	
end

function modifier_void_spirit_astral_step_lua:OnRemoved()
end

function modifier_void_spirit_astral_step_lua:OnDestroy()
	if not IsServer() then return end
	-- Apply damage
	local damage_to_apply = self.damage
	local damage_type_to_apply = DAMAGE_TYPE_MAGICAL

	if self:GetAbility():GetAutoCastState() then
		damage_to_apply = self.damage / 10
		damage_type_to_apply = DAMAGE_TYPE_PURE
	end

	local damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage_to_apply,
		damage_type = damage_type_to_apply,
		ability = self:GetAbility(), --Optional.
	}
	ApplyDamage(damageTable)

	-- play effects
	self:PlayEffects()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_void_spirit_astral_step_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_void_spirit_astral_step_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_void_spirit_astral_step_lua:GetEffectName()
	return "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_debuff.vpcf"
end

function modifier_void_spirit_astral_step_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_void_spirit_astral_step_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_void_spirit_astral_step_debuff.vpcf"
end

function modifier_void_spirit_astral_step_lua:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_void_spirit_astral_step_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_dmg.vpcf"
	local sound_target = "Hero_VoidSpirit.AstralStep.MarkExplosion"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_target, self:GetParent() )
end