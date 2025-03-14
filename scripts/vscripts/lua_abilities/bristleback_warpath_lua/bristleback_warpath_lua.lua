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
function modifier_bristleback_warpath_lua:DestroyOnExpire() return false end
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
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("move_speed_per_stack") * self:GetStackCount()
	end	
end
function modifier_bristleback_warpath_lua:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("damage_per_stack") + (self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multiplier")) * self:GetStackCount()
	end	
end
function modifier_bristleback_warpath_lua:OnAbilityFullyCast(params)
	if IsServer() then
		if params.unit==self:GetParent() and not self:GetParent():PassivesDisabled() then
			-- check item ability
			local hAbility = params.ability
			if hAbility:GetCooldown(hAbility:GetLevel()) <= 0 then return end
			if hAbility ~= nil and (not hAbility:IsItem()) and (not hAbility:IsToggle()) and self:GetParent():IsAlive() then
				self:AddStack()
			end
		end
	end
end
function modifier_bristleback_warpath_lua:GetModifierModelScale(params)
	return 4 * self:GetStackCount()
end
function modifier_bristleback_warpath_lua:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("spell_amp_per_stack") * self:GetStackCount()
	end	
end
function modifier_bristleback_warpath_lua:AddStack()
	if IsServer() and self:GetParent():IsAlive() and self:GetAbility() then
		local stack_duration = self:GetAbility():GetSpecialValueFor("stack_duration")
		local modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_bristleback_warpath_stack_lua", {duration = stack_duration})
		if modifier then
			modifier.parent_modifier = self
			self:GetAbility():IncrementStackCount()
			self:SetStackCount(math.min(self:GetAbility():GetStackCount(), self:GetAbility():GetSpecialValueFor("max_stacks")))
			self:SetDuration(stack_duration, true)
		end
		if self.effect_cast == nil then
			self.effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(self.effect_cast, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.effect_cast, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
		end
		Timers:CreateTimer(stack_duration + FrameTime(), function()
			if self ~= nil and not self:IsNull() and not self:GetAbility():IsNull() and not self:GetParent():IsNull() and not self:GetCaster():IsNull() and self:GetStackCount() < 1 then
				if self.effect_cast then
					ParticleManager:DestroyParticle(self.effect_cast, false)
					ParticleManager:ReleaseParticleIndex(self.effect_cast)
					self.effect_cast = nil
				end
			end
		end)
	end
end
function modifier_bristleback_warpath_lua:RemoveStack()
	if IsServer() then
		if self and not self:IsNull() then
			if self:GetAbility() and not self:GetAbility():IsNull() and IsValidEntity(self:GetAbility()) then
				self:GetAbility():DecrementStackCount()
				self:SetStackCount(math.min(self:GetAbility():GetStackCount(), self:GetAbility():GetSpecialValueFor("max_stacks")))
			end
		end		
	end
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
	if self.parent_modifier then
		self.parent_modifier:RemoveStack()
	end
end