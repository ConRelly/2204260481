-------
-- 5 --
-------
LinkLuaModifier("modifier_mjz_satanic_5", "items/mjz_satanic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_satanic_5_active", "items/mjz_satanic.lua", LUA_MODIFIER_MOTION_NONE)
item_mjz_satanic_5 = item_mjz_satanic_5 or class({})
function item_mjz_satanic_5:GetIntrinsicModifierName() return "modifier_mjz_satanic_5" end
function item_mjz_satanic_5:OnSpellStart()
    self:GetCaster():Purge(false,true,false,false,false)
	EmitSoundOn("DOTA_Item.Satanic.Activate", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mjz_satanic_5_active", {duration = self:GetSpecialValueFor("unholy_duration")})
end

modifier_mjz_satanic_5 = class({})
function modifier_mjz_satanic_5:IsHidden() return true end
function modifier_mjz_satanic_5:IsPurgable() return false end
function modifier_mjz_satanic_5:RemoveOnDeath() return false end
function modifier_mjz_satanic_5:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_mjz_satanic_5:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_mjz_satanic_5:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_mjz_satanic_5:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_mjz_satanic_5:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_strength") end
end
function modifier_mjz_satanic_5:GetModifierLifesteal()
	if self:GetAbility() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then
		return self:GetAbility():GetSpecialValueFor("lifesteal_percent")
	end
end

--------------
-- 5 ACTIVE --
--------------
if modifier_mjz_satanic_5_active == nil then modifier_mjz_satanic_5_active = class({}) end
function modifier_mjz_satanic_5_active:IsHidden() return false end
function modifier_mjz_satanic_5_active:IsDebuff() return false end
function modifier_mjz_satanic_5_active:IsPurgable() return false end
function modifier_mjz_satanic_5_active:GetTexture() return "mjz_satanic" end
function modifier_mjz_satanic_5_active:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_mjz_satanic_5_active:GetModifierLifesteal()
	if self:GetAbility() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then
		return self:GetAbility():GetSpecialValueFor("unholy_lifesteal_percent")
	end
end
function modifier_mjz_satanic_5_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_mjz_satanic_5_active:OnTooltip() return self:GetAbility():GetSpecialValueFor("unholy_lifesteal_percent") end