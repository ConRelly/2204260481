LinkLuaModifier("modifier_mjz_lina_fiery_soul", "abilities/hero_lina/mjz_lina_fiery_soul", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lina_fiery_soul_buff", "abilities/hero_lina/mjz_lina_fiery_soul", LUA_MODIFIER_MOTION_NONE)


----------------
-- Fiery Soul --
----------------
mjz_lina_fiery_soul = class({})
function mjz_lina_fiery_soul:GetIntrinsicModifierName() return "modifier_mjz_lina_fiery_soul" end
function mjz_lina_fiery_soul:GetAbilityTextureName()
	if self:GetCaster():HasScepter() then return "mjz_lina_fiery_soul_arcana" end
	return "mjz_lina_fiery_soul"
end

--------------------------------------------------------------------------------
modifier_mjz_lina_fiery_soul = class({})
function modifier_mjz_lina_fiery_soul:IsHidden() return true end
function modifier_mjz_lina_fiery_soul:IsPurgable() return false end
function modifier_mjz_lina_fiery_soul:RemoveOnDeath() return false end
function modifier_mjz_lina_fiery_soul:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end
function modifier_mjz_lina_fiery_soul:OnAbilityExecuted(params)
	if not IsServer() then return end
	local caster = self:GetCaster()
	if params.unit ~= caster then return end
	if caster:PassivesDisabled() then return end
	if not params.ability then return end
	if params.ability:IsItem() or params.ability:IsToggle() then return end

	local ability = self:GetAbility()
	local max_stacks = ability:GetSpecialValueFor("max_stacks")
	local stack_duration = ability:GetSpecialValueFor("stack_duration")
	local buff_name = "modifier_mjz_lina_fiery_soul_buff"

	if not caster:HasModifier(buff_name) then
		caster:AddNewModifier(caster, ability, buff_name, {})			
	end

	local modifier_buff = caster:FindModifierByName(buff_name)
	local buff_stacks = modifier_buff:GetStackCount()
	if buff_stacks < max_stacks then
		modifier_buff:SetStackCount(buff_stacks + 1)
	end

	modifier_buff:SetDuration(stack_duration, true)
	modifier_buff:ForceRefresh()
end
function modifier_mjz_lina_fiery_soul:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_mjz_lina_fiery_soul_buff")
	end
end

---------------------
-- Fiery Soul Buff --
---------------------
modifier_mjz_lina_fiery_soul_buff = class({})
function modifier_mjz_lina_fiery_soul_buff:IsHidden() return false end
function modifier_mjz_lina_fiery_soul_buff:IsBuff() return true end
function modifier_mjz_lina_fiery_soul_buff:IsPurgable() return false end
function modifier_mjz_lina_fiery_soul_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_mjz_lina_fiery_soul_buff:OnCreated(params)
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local talent_name = "special_bonus_unique_mjz_lina_fiery_soul"
	self.attack_speed_bonus = ability:GetSpecialValueFor("attack_speed_bonus") + talent_value(caster, talent_name)
	self.move_speed_bonus = ability:GetSpecialValueFor("move_speed_bonus") + talent_value(caster, talent_name)
	self.spell_amp_bonus = ability:GetSpecialValueFor("spell_amp_bonus") + talent_value(caster, talent_name)

	self.particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(self.particle_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.particle_fx, 1, Vector(1,0,0))
end
function modifier_mjz_lina_fiery_soul_buff:OnRefresh(params)
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local talent_name = "special_bonus_unique_mjz_lina_fiery_soul"
	self.attack_speed_bonus = ability:GetSpecialValueFor("attack_speed_bonus") + talent_value(caster, talent_name)
	self.move_speed_bonus = ability:GetSpecialValueFor("move_speed_bonus") + talent_value(caster, talent_name)
	self.spell_amp_bonus = ability:GetSpecialValueFor("spell_amp_bonus") + talent_value(caster, talent_name)
end
function modifier_mjz_lina_fiery_soul_buff:OnDestroy()
	if IsServer() then
		if self.particle_fx then
			ParticleManager:DestroyParticle(self.particle_fx, false)
			ParticleManager:ReleaseParticleIndex(self.particle_fx)
		end
	end
end
function modifier_mjz_lina_fiery_soul_buff:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetStackCount() * self.attack_speed_bonus end
end
function modifier_mjz_lina_fiery_soul_buff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetStackCount() * self.move_speed_bonus end
end
function modifier_mjz_lina_fiery_soul_buff:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetStackCount() * self.spell_amp_bonus end
end
