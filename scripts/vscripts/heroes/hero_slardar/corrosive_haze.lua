LinkLuaModifier("modifier_corrosive_haze", "heroes/hero_slardar/corrosive_haze", LUA_MODIFIER_MOTION_NONE)


corrosive_haze = class({})
function corrosive_haze:OnSpellStart()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(self:GetCaster(), self, "modifier_corrosive_haze", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("Hero_Slardar.Amplify_Damage", target)
end


modifier_corrosive_haze = class({})
function modifier_corrosive_haze:IsHidden() return false end
function modifier_corrosive_haze:IsDebuff() return true end
function modifier_corrosive_haze:IsStunDebuff() return false end
function modifier_corrosive_haze:GetTexture() return "slardar_amplify_damage" end
function modifier_corrosive_haze:IsPurgable() return true end
function modifier_corrosive_haze:OnCreated(kv)
	if IsServer() then
		if self:GetAbility() then
			self:ShardEffect(self:GetParent())
			local armor_reduction = self:GetCaster():CustomValue("corrosive_haze", "armor_reduction")
			self:SetStackCount(armor_reduction + talent_value(self:GetCaster(), "special_bonus_unique_slardar_5"))
		end
	end
end
function modifier_corrosive_haze:OnRefresh(kv)
	if IsServer() then
		if self:GetAbility() then
			if not self.effect_cast then
				self:ShardEffect(self:GetParent())
			end
			local armor_reduction = self:GetCaster():CustomValue("corrosive_haze", "armor_reduction")
			self:SetStackCount(armor_reduction + talent_value(self:GetCaster(), "special_bonus_unique_slardar_5"))
		end
	end
end
function modifier_corrosive_haze:ShardEffect(target)
	self.effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, target, PATTACH_OVERHEAD_FOLLOW, nil, target:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, target, PATTACH_OVERHEAD_FOLLOW, nil, target:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 2, target, PATTACH_OVERHEAD_FOLLOW, nil, target:GetOrigin(), true)
	self:AddParticle(self.effect_cast, false, false, -1, false, true)
end
function modifier_corrosive_haze:OnDestroy()
	if IsServer() then
		if self.effect_cast then
			ParticleManager:DestroyParticle(self.effect_cast, false)
			ParticleManager:ReleaseParticleIndex(self.effect_cast)
		end
	end
end
function modifier_corrosive_haze:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end
function modifier_corrosive_haze:GetModifierPhysicalArmorBonus()
	return self:GetStackCount()
end
function modifier_corrosive_haze:GetModifierProvidesFOWVision()
	return 1
end
function modifier_corrosive_haze:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = false}
end
