-------------------
-- Void Talisman --
-------------------
item_void_talisman = item_void_talisman or class({})
LinkLuaModifier("modifier_void_talisman", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_talisman_debuff", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
function item_void_talisman:GetIntrinsicModifierName() return "modifier_void_talisman" end
-- Void Talisman Modifier
modifier_void_talisman = modifier_void_talisman or class({})
function modifier_void_talisman:IsHidden() return true end
function modifier_void_talisman:IsPurgable() return false end
function modifier_void_talisman:RemoveOnDeath() return false end
function modifier_void_talisman:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_void_talisman:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_void_talisman:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_void_talisman:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_void_talisman:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_void_talisman:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end
function modifier_void_talisman:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		target:AddNewModifier(owner, ability, "modifier_void_talisman_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
-- Void Talisman Debuff
modifier_void_talisman_debuff = modifier_void_talisman_debuff or class({})
function modifier_void_talisman_debuff:IsHidden() return false end
function modifier_void_talisman_debuff:IsDebuff() return true end
function modifier_void_talisman_debuff:IsPurgable() return true end
function modifier_void_talisman_debuff:GetEffectName() return "particles/items_fx/diffusal_slow.vpcf" end
function modifier_void_talisman_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_void_talisman_debuff:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

---------------------
-- Void Talisman 2 --
---------------------
item_void_talisman_2 = item_void_talisman_2 or class({})
LinkLuaModifier("modifier_void_talisman_2", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_talisman_2_debuff", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
function item_void_talisman_2:GetIntrinsicModifierName() return "modifier_void_talisman_2" end
-- Void Talisman 2 Modifier
modifier_void_talisman_2 = modifier_void_talisman_2 or class({})
function modifier_void_talisman_2:IsHidden() return true end
function modifier_void_talisman_2:IsPurgable() return false end
function modifier_void_talisman_2:RemoveOnDeath() return false end
function modifier_void_talisman_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_void_talisman_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_void_talisman_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_void_talisman_2:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_void_talisman_2:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_void_talisman_2:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end
function modifier_void_talisman_2:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		target:AddNewModifier(owner, ability, "modifier_void_talisman_2_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
-- Void Talisman 2 Debuff
modifier_void_talisman_2_debuff = modifier_void_talisman_2_debuff or class({})
function modifier_void_talisman_2_debuff:IsHidden() return false end
function modifier_void_talisman_2_debuff:IsDebuff() return true end
function modifier_void_talisman_2_debuff:IsPurgable() return true end
function modifier_void_talisman_2_debuff:GetEffectName() return "particles/items_fx/diffusal_slow.vpcf" end
function modifier_void_talisman_2_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_void_talisman_2_debuff:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

---------------------
-- Void Talisman 3 --
---------------------
item_void_talisman_3 = item_void_talisman_3 or class({})
LinkLuaModifier("modifier_void_talisman_3", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_talisman_3_debuff", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
function item_void_talisman_3:GetIntrinsicModifierName() return "modifier_void_talisman_3" end
-- Void Talisman 3 Modifier
modifier_void_talisman_3 = modifier_void_talisman_3 or class({})
function modifier_void_talisman_3:IsHidden() return true end
function modifier_void_talisman_3:IsPurgable() return false end
function modifier_void_talisman_3:RemoveOnDeath() return false end
function modifier_void_talisman_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_void_talisman_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_void_talisman_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_void_talisman_3:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_void_talisman_3:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_void_talisman_3:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end
function modifier_void_talisman_3:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		target:AddNewModifier(owner, ability, "modifier_void_talisman_3_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
-- Void Talisman 3 Debuff
modifier_void_talisman_3_debuff = modifier_void_talisman_3_debuff or class({})
function modifier_void_talisman_3_debuff:IsHidden() return false end
function modifier_void_talisman_3_debuff:IsDebuff() return true end
function modifier_void_talisman_3_debuff:IsPurgable() return true end
function modifier_void_talisman_3_debuff:GetEffectName() return "particles/items_fx/diffusal_slow.vpcf" end
function modifier_void_talisman_3_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_void_talisman_3_debuff:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end


----------------------
-- Talisman Of Atos --
----------------------
item_talisman_of_atos = item_talisman_of_atos or class({})
LinkLuaModifier("modifier_talisman_of_atos", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talisman_of_atos_debuff", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talisman_of_atos_dmg_reduction", "items/void_talisman.lua", LUA_MODIFIER_MOTION_NONE)
function item_talisman_of_atos:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("dmg_red_duration")
    caster:Purge(false,true,false,false,false)
	caster:AddNewModifier(caster, self, "modifier_talisman_of_atos_dmg_reduction", {duration = duration})
end
function item_talisman_of_atos:GetIntrinsicModifierName() return "modifier_talisman_of_atos" end
-- Talisman Of Atos Modifier
modifier_talisman_of_atos = modifier_talisman_of_atos or class({})
function modifier_talisman_of_atos:IsHidden() return true end
function modifier_talisman_of_atos:IsPurgable() return false end
function modifier_talisman_of_atos:RemoveOnDeath() return false end
function modifier_talisman_of_atos:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_talisman_of_atos:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_talisman_of_atos:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_talisman_of_atos:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("str") end
function modifier_talisman_of_atos:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("agi") end
function modifier_talisman_of_atos:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_talisman_of_atos:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_talisman_of_atos:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end
function modifier_talisman_of_atos:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		target:AddNewModifier(owner, ability, "modifier_talisman_of_atos_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
-- Talisman Of Atos Debuff
modifier_talisman_of_atos_debuff = modifier_talisman_of_atos_debuff or class({})
function modifier_talisman_of_atos_debuff:IsHidden() return false end
function modifier_talisman_of_atos_debuff:IsDebuff() return true end
function modifier_talisman_of_atos_debuff:IsPurgable() return true end
function modifier_talisman_of_atos_debuff:GetEffectName() return "particles/items_fx/diffusal_slow.vpcf" end
function modifier_talisman_of_atos_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_talisman_of_atos_debuff:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end
-- Talisman Of Atos Damage Reduction
modifier_talisman_of_atos_dmg_reduction = modifier_talisman_of_atos_dmg_reduction or class({})
function modifier_talisman_of_atos_dmg_reduction:IsHidden() return false end
function modifier_talisman_of_atos_dmg_reduction:IsPurgable() return false end
function modifier_talisman_of_atos_dmg_reduction:GetEffectName() return "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_cylinder_active.vpcf" end
function modifier_talisman_of_atos_dmg_reduction:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_talisman_of_atos_dmg_reduction:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_talisman_of_atos_dmg_reduction:GetModifierIncomingDamage_Percentage() return self:GetAbility():GetSpecialValueFor("dmg_red") * (-1) end
