LinkLuaModifier("modifier_item_red_divine_rapier", "items/item_red_divine_rapier.lua", LUA_MODIFIER_MOTION_NONE)

item_red_divine_rapier = class({})
function item_red_divine_rapier:GetIntrinsicModifierName() return "modifier_item_red_divine_rapier" end

item_red_divine_rapier_lv1 = class(item_red_divine_rapier)
item_red_divine_rapier_lv2 = class(item_red_divine_rapier)
item_red_divine_rapier_lv3 = class(item_red_divine_rapier)
item_red_divine_rapier_lv4 = class(item_red_divine_rapier)
item_red_divine_rapier_lv5 = class(item_red_divine_rapier)

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
	if self:GetAbility() then
		if self:GetAbility():GetAbilityName() == "item_infinite_rapier" then
			return "particles/custom/infinite_rapier_shell.vpcf"
		end
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
		if self.parent:IsHero() and self:GetAbility() then
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
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage") / 2
	end	
end
function modifier_item_custom_rapier:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage") / 2
	end	
end
