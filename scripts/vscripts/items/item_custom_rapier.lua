LinkLuaModifier("modifier_item_custom_rapier", "items/item_custom_rapier.lua", LUA_MODIFIER_MOTION_NONE)

item_custom_rapier = class({})
function item_custom_rapier:GetIntrinsicModifierName() return "modifier_item_custom_rapier" end

item_custom_rapier = class(item_custom_rapier)
item_ultimate_rapier = class(item_custom_rapier)
item_infinite_rapier = class(item_custom_rapier)

modifier_item_custom_rapier = class({})
--[[
function modifier_item_custom_rapier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
]]
function modifier_item_custom_rapier:IsPurgable() return false end
function modifier_item_custom_rapier:IsHidden() return true end
function modifier_item_custom_rapier:GetTexture() return "rapier" end
function modifier_item_custom_rapier:GetEffectName()
	if self:GetAbility():GetAbilityName() == "item_infinite_rapier" then
		return "particles/custom/infinite_rapier_shell.vpcf"
	end
	return nil
end
function modifier_item_custom_rapier:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_custom_rapier:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end
function modifier_item_custom_rapier:OnCreated()
	self.parent = self:GetParent()
	if IsServer() then
		if self.parent:IsHero() then
			self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
		else
			self.damage = 0
		end
--[[
		if self:GetAbility():GetAbilityName() == "item_infinite_rapier" then
			self.particle = ParticleManager:CreateParticle("particles/custom/infinite_rapier_shell.vpcf", PATTACH_POINT, self:GetParent())
			ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		end
]]
	end
end
function modifier_item_custom_rapier:OnDestroy()
	if IsServer() then
--[[
		if self:GetAbility():GetAbilityName() == "item_infinite_rapier" then
			ParticleManager:DestroyParticle(self.particle, true)
		end
]]
	end
end
function modifier_item_custom_rapier:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage") / 2
end
function modifier_item_custom_rapier:GetModifierBaseAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage") / 2
end
