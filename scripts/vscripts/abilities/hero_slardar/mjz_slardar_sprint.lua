LinkLuaModifier( "modifier_mjz_slardar_sprint", "abilities/hero_slardar/mjz_slardar_sprint.lua",LUA_MODIFIER_MOTION_NONE )

mjz_slardar_sprint = class({})
local ability_class = mjz_slardar_sprint

function ability_class:OnToggle()
	if IsServer() then
		local caster = self:GetCaster()
		if self:GetToggleState() then
			EmitSoundOn("Hero_Slardar.Sprint", caster)
			caster:AddNewModifier(caster, self, 'modifier_mjz_slardar_sprint', {})
		else
			caster:RemoveModifierByName('modifier_mjz_slardar_sprint')
		end
	end
end

----------------------------------------------------------------------------

modifier_mjz_slardar_sprint = class({})
local modifier_class = modifier_mjz_slardar_sprint

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
end
function modifier_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
	function modifier_class:OnCreated(table)
		if self:GetAbility() then
			self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
			self.bonus_move_speed = self:GetAbility():GetSpecialValueFor("bonus_move_speed")
			self.health_cost_per_second = self:GetAbility():GetSpecialValueFor("health_cost_per_second") * (1 - talent_value(self:GetCaster(), "special_bonus_unique_mjz_slardar_sprint_hp_cost") / 100)
			self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
		end
		self:StartIntervalThink(self.tick_interval)
	end

	function modifier_class:OnIntervalThink()
		local health_cost = self.health_cost_per_second * self.tick_interval

		local iDesiredHealthValue = self:GetParent():GetHealth() - health_cost
		self:GetParent():ModifyHealth(iDesiredHealthValue, self:GetAbility(), false, 0)
	end
end
function modifier_class:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_class:GetActivityTranslationModifiers() return "sprint" end
function modifier_class:GetModifierAttackSpeedBonus_Constant() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end end
function modifier_class:GetModifierMoveSpeedBonus_Percentage() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_move_speed") end end
function modifier_class:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end
