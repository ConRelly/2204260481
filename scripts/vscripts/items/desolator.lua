---------------
-- Desolator --
---------------
LinkLuaModifier("modifier_apl_desolator", "items/desolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_apl_desolator_armor", "items/desolator", LUA_MODIFIER_MOTION_NONE)

item_desolator_custom = class({})
function item_desolator_custom:GetIntrinsicModifierName() return "modifier_apl_desolator" end
item_desolator_2_custom = class({})
function item_desolator_2_custom:GetIntrinsicModifierName() return "modifier_apl_desolator" end
item_desolator_3_custom = class({})
function item_desolator_3_custom:GetIntrinsicModifierName() return "modifier_apl_desolator" end
item_mjz_desolator_2 = class({})
function item_mjz_desolator_2:GetIntrinsicModifierName() return "modifier_apl_desolator" end
item_mjz_desolator_3 = class({})
function item_mjz_desolator_3:GetIntrinsicModifierName() return "modifier_apl_desolator" end
item_mjz_desolator_4 = class({})
function item_mjz_desolator_4:GetIntrinsicModifierName() return "modifier_apl_desolator" end
item_mjz_desolator_5 = class({})
function item_mjz_desolator_5:GetIntrinsicModifierName() return "modifier_apl_desolator" end

modifier_apl_desolator = class({})
function modifier_apl_desolator:IsHidden() return true end
function modifier_apl_desolator:IsPurgable() return false end
function modifier_apl_desolator:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_apl_desolator:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_apl_desolator:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_apl_desolator:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_apl_desolator:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		local ability = self:GetAbility()
		if owner ~= keys.attacker then return end
		target:EmitSound("Item_Desolator.Target")
		target:AddNewModifier(owner, ability, "modifier_apl_desolator_armor", {duration = ability:GetSpecialValueFor("corruption_duration") * (1 - target:GetStatusResistance())})
	end
end

-------------------------------
-- Desolator Armor Reduction --
-------------------------------
modifier_apl_desolator_armor = class({})
function modifier_apl_desolator_armor:IsHidden() return false end
function modifier_apl_desolator_armor:IsDebuff() return true end
function modifier_apl_desolator_armor:IsPurgable() return true end
function modifier_apl_desolator_armor:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_apl_desolator_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_apl_desolator_armor:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("corruption_armor") end
end

