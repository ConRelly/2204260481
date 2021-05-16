--------------
--FIRE CLAWS--
--------------
LinkLuaModifier("modifier_fire_claws_1", "items/fire_claws.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_claws_1_armor", "items/fire_claws.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_claws == nil then item_fire_claws = class({}) end
function item_fire_claws:GetIntrinsicModifierName() return "modifier_fire_claws_1" end

if modifier_fire_claws_1 == nil then modifier_fire_claws_1 = class({}) end
function modifier_fire_claws_1:IsHidden() return true end
function modifier_fire_claws_1:IsPurgable() return false end
function modifier_fire_claws_1:RemoveOnDeath() return false end
function modifier_fire_claws_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_claws_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_claws_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_fire_claws_1:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_res") end
end
function modifier_fire_claws_1:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_pct") end
end
function modifier_fire_claws_1:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		local ability = self:GetAbility()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end
		if not target:HasModifier("modifier_fire_claws_1_armor") then
			target:EmitSound("Item_Desolator.Target")
		end
		if target:HasModifier("modifier_fire_claws_2_armor") or target:HasModifier("modifier_fire_claws_3_armor") then
			return end
		target:AddNewModifier(owner, ability, "modifier_fire_claws_1_armor", {duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
	end
end

-------------------------------
--FIRE CLAWS ARMOR REDUCTION--
-------------------------------
if modifier_fire_claws_1_armor == nil then modifier_fire_claws_1_armor = class({}) end
function modifier_fire_claws_1_armor:IsHidden() return false end
function modifier_fire_claws_1_armor:IsDebuff() return true end
function modifier_fire_claws_1_armor:IsPurgable() return true end
function modifier_fire_claws_1_armor:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_claws_1_armor:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_fire_claws_1_armor:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_red") * (-1) end
end

----------------
--FIRE CLAWS2--
----------------
LinkLuaModifier("modifier_fire_claws_2", "items/fire_claws.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_claws_2_armor", "items/fire_claws.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_claws_2 == nil then item_fire_claws_2 = class({}) end
function item_fire_claws_2:GetIntrinsicModifierName() return "modifier_fire_claws_2" end

if modifier_fire_claws_2 == nil then modifier_fire_claws_2 = class({}) end
function modifier_fire_claws_2:IsHidden() return true end
function modifier_fire_claws_2:IsPurgable() return false end
function modifier_fire_claws_2:RemoveOnDeath() return false end
function modifier_fire_claws_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_claws_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_claws_2:DeclareFunctions()
	return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_fire_claws_2:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_res") end
end
function modifier_fire_claws_2:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_pct") end
end
function modifier_fire_claws_2:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		local ability = self:GetAbility()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end
		target:RemoveModifierByName("modifier_fire_claws_1_armor")
		if not target:HasModifier("modifier_fire_claws_2_armor") then
			target:EmitSound("Item_Desolator.Target")
		end
		if target:HasModifier("modifier_fire_claws_3_armor") then
			return end
		target:AddNewModifier(owner, ability, "modifier_fire_claws_2_armor", {duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
	end
end

--------------------------------
--FIRE CLAWS2 ARMOR REDUCTION--
--------------------------------
if modifier_fire_claws_2_armor == nil then modifier_fire_claws_2_armor = class({}) end
function modifier_fire_claws_2_armor:IsHidden() return false end
function modifier_fire_claws_2_armor:IsDebuff() return true end
function modifier_fire_claws_2_armor:IsPurgable() return true end
function modifier_fire_claws_2_armor:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_claws_2_armor:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_fire_claws_2_armor:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_red") * (-1) end
end

----------------
--FIRE CLAWS3--
----------------
LinkLuaModifier("modifier_fire_claws_3", "items/fire_claws.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_claws_3_armor", "items/fire_claws.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_claws_3 == nil then item_fire_claws_3 = class({}) end
function item_fire_claws_3:GetIntrinsicModifierName() return "modifier_fire_claws_3" end

if modifier_fire_claws_3 == nil then modifier_fire_claws_3 = class({}) end
function modifier_fire_claws_3:IsHidden() return true end
function modifier_fire_claws_3:IsPurgable() return false end
function modifier_fire_claws_3:RemoveOnDeath() return false end
function modifier_fire_claws_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_claws_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_claws_3:DeclareFunctions()
	return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_fire_claws_3:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_res") end
end
function modifier_fire_claws_3:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_pct") end
end
function modifier_fire_claws_3:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		local ability = self:GetAbility()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end
		target:RemoveModifierByName("modifier_fire_claws_1_armor")
		target:RemoveModifierByName("modifier_fire_claws_2_armor")
		if not target:HasModifier("modifier_fire_claws_3_armor") then
			target:EmitSound("Item_Desolator.Target")
		end
		target:AddNewModifier(owner, ability, "modifier_fire_claws_3_armor", {duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
	end
end

--------------------------------
--FIRE CLAWS3 ARMOR REDUCTION--
--------------------------------
if modifier_fire_claws_3_armor == nil then modifier_fire_claws_3_armor = class({}) end
function modifier_fire_claws_3_armor:IsHidden() return false end
function modifier_fire_claws_3_armor:IsDebuff() return true end
function modifier_fire_claws_3_armor:IsPurgable() return true end
function modifier_fire_claws_3_armor:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_claws_3_armor:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_fire_claws_3_armor:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_red") * (-1) end
end


------------------
--FIRE DESOLATOR--
------------------
LinkLuaModifier("modifier_fire_desolator", "items/fire_claws.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_desolator_armor", "items/fire_claws.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_desol == nil then item_fire_desol = class({}) end
function item_fire_desol:GetIntrinsicModifierName() return "modifier_fire_desolator" end

if modifier_fire_desolator == nil then modifier_fire_desolator = class({}) end
function modifier_fire_desolator:IsHidden() return true end
function modifier_fire_desolator:IsPurgable() return false end
function modifier_fire_desolator:RemoveOnDeath() return false end
function modifier_fire_desolator:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_desolator:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.Default_Attack = self:GetCaster():GetRangedProjectileName()
		self:GetParent():SetRangedProjectileName("particles/econ/items/shadow_fiend/sf_desolation/sf_base_attack_desolation_desolator.vpcf")
	end
end
function modifier_fire_desolator:OnDestroy()
	if IsServer() then 
		self:GetParent():SetRangedProjectileName(self.Default_Attack)
	end
end
function modifier_fire_desolator:DeclareFunctions()
	return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_fire_desolator:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_res") end
end
function modifier_fire_desolator:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_pct") end
end
function modifier_fire_desolator:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_fire_desolator:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		local ability = self:GetAbility()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end
		target:EmitSound("Item_Desolator.Target")
		target:AddNewModifier(owner, ability, "modifier_fire_desolator_armor", {duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
	end
end

----------------------------------
--FIRE DESOLATOR ARMOR REDUCTION--
----------------------------------
if modifier_fire_desolator_armor == nil then modifier_fire_desolator_armor = class({}) end
function modifier_fire_desolator_armor:IsHidden() return false end
function modifier_fire_desolator_armor:IsDebuff() return true end
function modifier_fire_desolator_armor:IsPurgable() return true end
function modifier_fire_desolator_armor:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_desolator_armor:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_fire_desolator_armor:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_red") * (-1) end
end