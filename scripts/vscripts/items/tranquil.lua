------------------
--TRANQUIL BOOTS--
------------------
LinkLuaModifier("modifier_tranquilboots", "items/tranquil.lua", LUA_MODIFIER_MOTION_NONE)
if item_tranquilboots == nil then item_tranquilboots = class({}) end
function item_tranquilboots:GetIntrinsicModifierName() return "modifier_tranquilboots" end

if modifier_tranquilboots == nil then modifier_tranquilboots = class({}) end
function modifier_tranquilboots:IsHidden() return true end
function modifier_tranquilboots:IsPurgable() return false end
function modifier_tranquilboots:RemoveOnDeath() return false end
function modifier_tranquilboots:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_tranquilboots:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_tranquilboots:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end
function modifier_tranquilboots:GetModifierMoveSpeedBonus_Special_Boots()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
end
function modifier_tranquilboots:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_armor") end
end
function modifier_tranquilboots:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
end