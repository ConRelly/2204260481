---------------
-- Ice Blade --
---------------
item_ice_blade = item_ice_blade or class({})
LinkLuaModifier("modifier_ice_blade", "items/ice_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_blade_slow_debuff", "items/ice_blade.lua", LUA_MODIFIER_MOTION_NONE)
function item_ice_blade:GetIntrinsicModifierName() return "modifier_ice_blade" end
-- Ice Blade Modifier
modifier_ice_blade = modifier_ice_blade or class({})
function modifier_ice_blade:IsHidden() return true end
function modifier_ice_blade:IsPurgable() return false end
function modifier_ice_blade:RemoveOnDeath() return false end
function modifier_ice_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_blade:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_ice_blade:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_ice_blade:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_ice_blade:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_ice_blade:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		target:AddNewModifier(owner, ability, "modifier_ice_blade_slow_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
-- Ice Blade Slow Debuff
modifier_ice_blade_slow_debuff = modifier_ice_blade_slow_debuff or class({})
function modifier_ice_blade_slow_debuff:IsDebuff() return true end
function modifier_ice_blade_slow_debuff:IsHidden() return false end
function modifier_ice_blade_slow_debuff:IsPurgable() return true end
function modifier_ice_blade_slow_debuff:RemoveOnDeath() return true end
function modifier_ice_blade_slow_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_ice_blade_slow_debuff:StatusEffectPriority() return 10 end
function modifier_ice_blade_slow_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_blade_slow_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_ice_blade_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_slow") * (-1) end
end
function modifier_ice_blade_slow_debuff:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_slow") * (-1) end
end

-----------------
-- Ice Blade 2 --
-----------------
item_ice_blade_2 = item_ice_blade_2 or class({})
LinkLuaModifier("modifier_ice_blade_2", "items/ice_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_blade_2_slow_debuff", "items/ice_blade.lua", LUA_MODIFIER_MOTION_NONE)
function item_ice_blade_2:GetIntrinsicModifierName() return "modifier_ice_blade_2" end
-- Ice Blade 2 Modifier
modifier_ice_blade_2 = modifier_ice_blade_2 or class({})
function modifier_ice_blade_2:IsHidden() return true end
function modifier_ice_blade_2:IsPurgable() return false end
function modifier_ice_blade_2:RemoveOnDeath() return false end
function modifier_ice_blade_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_blade_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_blade_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_ice_blade_2:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_ice_blade_2:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_ice_blade_2:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_ice_blade_2:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		target:AddNewModifier(owner, ability, "modifier_ice_blade_2_slow_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
-- Ice Blade 2 Slow Debuff
modifier_ice_blade_2_slow_debuff = modifier_ice_blade_2_slow_debuff or class({})
function modifier_ice_blade_2_slow_debuff:IsDebuff() return true end
function modifier_ice_blade_2_slow_debuff:IsHidden() return false end
function modifier_ice_blade_2_slow_debuff:IsPurgable() return true end
function modifier_ice_blade_2_slow_debuff:RemoveOnDeath() return true end
function modifier_ice_blade_2_slow_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_ice_blade_2_slow_debuff:StatusEffectPriority() return 10 end
function modifier_ice_blade_2_slow_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_blade_2_slow_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_ice_blade_2_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_slow") * (-1) end
end
function modifier_ice_blade_2_slow_debuff:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_slow") * (-1) end
end

-----------------
-- Ice Blade 3 --
-----------------
item_ice_blade_3 = item_ice_blade_3 or class({})
LinkLuaModifier("modifier_ice_blade_3", "items/ice_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_blade_3_slow_debuff", "items/ice_blade.lua", LUA_MODIFIER_MOTION_NONE)
function item_ice_blade_3:GetIntrinsicModifierName() return "modifier_ice_blade_3" end
-- Ice Blade 3 Modifier
modifier_ice_blade_3 = modifier_ice_blade_3 or class({})
function modifier_ice_blade_3:IsHidden() return true end
function modifier_ice_blade_3:IsPurgable() return false end
function modifier_ice_blade_3:RemoveOnDeath() return false end
function modifier_ice_blade_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_blade_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_blade_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_ice_blade_3:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_ice_blade_3:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_ice_blade_3:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_ice_blade_3:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		target:AddNewModifier(owner, ability, "modifier_ice_blade_3_slow_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
-- Ice Blade 3 Slow Debuff
modifier_ice_blade_3_slow_debuff = modifier_ice_blade_3_slow_debuff or class({})
function modifier_ice_blade_3_slow_debuff:IsDebuff() return true end
function modifier_ice_blade_3_slow_debuff:IsHidden() return false end
function modifier_ice_blade_3_slow_debuff:IsPurgable() return true end
function modifier_ice_blade_3_slow_debuff:RemoveOnDeath() return true end
function modifier_ice_blade_3_slow_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_ice_blade_3_slow_debuff:StatusEffectPriority() return 10 end
function modifier_ice_blade_3_slow_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_blade_3_slow_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_ice_blade_3_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_slow") * (-1) end
end
function modifier_ice_blade_3_slow_debuff:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_slow") * (-1) end
end


---------------
-- Skadi Bow --
---------------
item_skadi_bow = item_skadi_bow or class({})
LinkLuaModifier("modifier_skadi_bow", "items/ice_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skadi_bow_slow_debuff", "items/ice_blade.lua", LUA_MODIFIER_MOTION_NONE)
function item_skadi_bow:GetIntrinsicModifierName() return "modifier_skadi_bow" end
-- Skadi Bow Modifier
modifier_skadi_bow = modifier_skadi_bow or class({})
function modifier_skadi_bow:IsHidden() return true end
function modifier_skadi_bow:IsPurgable() return false end
function modifier_skadi_bow:RemoveOnDeath() return false end
function modifier_skadi_bow:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_skadi_bow:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PROJECTILE_NAME}
end
function modifier_skadi_bow:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_skadi_bow:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_skadi_bow:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_skadi_bow:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_skadi_bow:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_skadi_bow:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_skadi_bow:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_skadi_bow:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_skadi_bow:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		target:AddNewModifier(owner, ability, "modifier_skadi_bow_slow_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
function modifier_skadi_bow:GetModifierProjectileName()
	return "particles/custom/items/skadi_bow/skadi_projectile.vpcf"
end

-- Skadi Bow Slow Debuff
modifier_skadi_bow_slow_debuff = modifier_skadi_bow_slow_debuff or class({})
function modifier_skadi_bow_slow_debuff:IsDebuff() return true end
function modifier_skadi_bow_slow_debuff:IsHidden() return false end
function modifier_skadi_bow_slow_debuff:IsPurgable() return true end
function modifier_skadi_bow_slow_debuff:RemoveOnDeath() return true end
function modifier_skadi_bow_slow_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_skadi_bow_slow_debuff:StatusEffectPriority() return 10 end
function modifier_skadi_bow_slow_debuff:OnCreated(keys)
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_skadi_bow_slow_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE}
end
function modifier_skadi_bow_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then
		if self:GetParent():IsRangedAttacker() then
			return self:GetAbility():GetSpecialValueFor("ms_slow_ranged") * (-1)
		else
			return self:GetAbility():GetSpecialValueFor("ms_slow_melee") * (-1)
		end
	end
end
function modifier_skadi_bow_slow_debuff:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then
		if self:GetParent():IsRangedAttacker() then
			return self:GetAbility():GetSpecialValueFor("as_slow_ranged") * (-1)
		else
			return self:GetAbility():GetSpecialValueFor("as_slow_melee") * (-1)
		end
	end
end
function modifier_skadi_bow_slow_debuff:GetModifierHPRegenAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_red") * (-1) end
end

