LinkLuaModifier("modifier_forbidden_knowledge_buff", "heroes/hero_master_of_weapons/forbidden_knowledge", LUA_MODIFIER_MOTION_NONE)

forbidden_knowledge = class({})
function forbidden_knowledge:GetCooldown(lvl)
    return self:GetSpecialValueFor("fixed_cooldown") / self:GetCaster():GetCooldownReduction()
end
function forbidden_knowledge:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_forbidden_knowledge_buff")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_forbidden_knowledge_buff", {duration = self:GetSpecialValueFor("buff_duration")})
end

modifier_forbidden_knowledge_buff = class({})
function modifier_forbidden_knowledge_buff:IsHidden() return true end
function modifier_forbidden_knowledge_buff:IsPurgable() return false end
function modifier_forbidden_knowledge_buff:RemoveOnDeath() return false end
function modifier_forbidden_knowledge_buff:OnCreated()
	if self:GetAbility() then
		self:GetCaster():EmitSound("Hero_Sven.WarCry")
		if self:GetCaster():GetLevel() >= 55 then
			self:SetStackCount(self:GetAbility():GetSpecialValueFor("buff_as_55"))
		else
			self:SetStackCount(self:GetAbility():GetSpecialValueFor("buff_as"))
		end
		if self.cast_fx then
			ParticleManager:DestroyParticle(self.cast_fx, false)
			ParticleManager:ReleaseParticleIndex(self.cast_fx)
		end
		self.cast_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.cast_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.cast_fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.cast_fx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.cast_fx, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
		self:AddParticle(self.cast_fx, false, false, -1, false, false)
	end
end
function modifier_forbidden_knowledge_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_forbidden_knowledge_buff:GetModifierAttackSpeed_Limit() return 1 end
function modifier_forbidden_knowledge_buff:GetModifierAttackSpeedBonus_Constant() return self:GetStackCount() end
function modifier_forbidden_knowledge_buff:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end
