bristleback_warpath_lua = class({})
LinkLuaModifier("modifier_bristleback_warpath_lua", "lua_abilities/bristleback_warpath_lua/bristleback_warpath_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bristleback_warpath_stack_lua", "lua_abilities/bristleback_warpath_lua/bristleback_warpath_lua", LUA_MODIFIER_MOTION_NONE)


function bristleback_warpath_lua:GetIntrinsicModifierName() return "modifier_bristleback_warpath_lua" end
function bristleback_warpath_lua:GetStackCount()
	if self.stack_count == nil then
		self.stack_count = 0
	end
	return self.stack_count
end
function bristleback_warpath_lua:IncrementStackCount()
	if IsServer() then
		self.stack_count = self:GetStackCount() + 1
	end
end
function bristleback_warpath_lua:DecrementStackCount()
	if IsServer() then
		self.stack_count = self:GetStackCount() - 1
	end
end


modifier_bristleback_warpath_lua = class({})
function modifier_bristleback_warpath_lua:IsHidden() return (self:GetStackCount() == 0) end
function modifier_bristleback_warpath_lua:IsDebuff() return false end
function modifier_bristleback_warpath_lua:IsPurgable() return false end
function modifier_bristleback_warpath_lua:OnCreated(kv)
	self.stack_max = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.stack_damage = self:GetAbility():GetSpecialValueFor("damage_per_stack") + (self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multiplier"))
	self.stack_spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp_per_stack")
	self.stack_movespeed = self:GetAbility():GetSpecialValueFor("move_speed_per_stack")
	self.stack_duration = self:GetAbility():GetSpecialValueFor("stack_duration")
	self.stack_size = 4

	if IsServer() then
		self:PlayEffects()
	end
end

function modifier_bristleback_warpath_lua:OnRefresh(kv)
	self.stack_max = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.stack_damage = self:GetAbility():GetSpecialValueFor("damage_per_stack") + (self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multiplier"))
	self.stack_spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp_per_stack")
	self.stack_movespeed = self:GetAbility():GetSpecialValueFor("move_speed_per_stack")
	self.stack_duration = self:GetAbility():GetSpecialValueFor("stack_duration")
end
function modifier_bristleback_warpath_lua:OnDestroy(kv)
	if IsServer() then
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
	end
end
function modifier_bristleback_warpath_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end
function modifier_bristleback_warpath_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.stack_movespeed * self:GetStackCount()
end
function modifier_bristleback_warpath_lua:GetModifierPreAttack_BonusDamage()
	return self.stack_damage * self:GetStackCount()
end
function modifier_bristleback_warpath_lua:OnAbilityFullyCast(params)
	if IsServer() then
		if params.unit==self:GetParent() and not self:GetParent():PassivesDisabled() then
			-- check item ability
			local hAbility = params.ability
			if hAbility ~= nil and (not hAbility:IsItem()) and (not hAbility:IsToggle()) and self:GetParent():IsAlive() then
				self:AddStack()
			end
		end
	end
end
function modifier_bristleback_warpath_lua:GetModifierModelScale(params)
	return self.stack_size * self:GetStackCount()
end
function modifier_bristleback_warpath_lua:GetModifierSpellAmplify_Percentage()
	return self.stack_spell_amp * self:GetStackCount()
end
function modifier_bristleback_warpath_lua:AddStack()
	if IsServer() and self:GetParent():IsAlive() then
		local modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_bristleback_warpath_stack_lua", {duration = self.stack_duration})
		if modifier then
			modifier.parent_modifier = self
			self:GetAbility():IncrementStackCount()
			self:SetStackCount(math.min(self:GetAbility():GetStackCount(),self.stack_max))
		end
	end
end
function modifier_bristleback_warpath_lua:RemoveStack()
	if IsServer() then
		if self:GetAbility() and IsValidEntity(self:GetAbility()) then
			self:GetAbility():DecrementStackCount()
			self:SetStackCount(math.min(self:GetAbility():GetStackCount(),self.stack_max))
		end		
	end
end
function modifier_bristleback_warpath_lua:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf"

	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

	ParticleManager:SetParticleControlEnt(self.effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetOrigin(), true)
	ParticleManager:SetParticleControl(self.effect_cast, 5, Vector(1, 0, 0))
end
function modifier_bristleback_warpath_lua:GetEffectName()
	if self:GetStackCount() > 0 then
		return "particles/units/heroes/hero_bristleback/bristleback_warpath_dust.vpcf"
	end
end
function modifier_bristleback_warpath_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_bristleback_warpath_stack_lua = class({})
function modifier_bristleback_warpath_stack_lua:IsHidden() return true end
function modifier_bristleback_warpath_stack_lua:IsDebuff() return false end
function modifier_bristleback_warpath_stack_lua:IsPurgable() return false end
function modifier_bristleback_warpath_stack_lua:RemoveOnDeath() return false end
function modifier_bristleback_warpath_stack_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_bristleback_warpath_stack_lua:OnCreated(kv) end
function modifier_bristleback_warpath_stack_lua:OnRefresh(kv) end
function modifier_bristleback_warpath_stack_lua:OnDestroy()
	if not IsServer() then return end
	self.parent_modifier:RemoveStack()
end