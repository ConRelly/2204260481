---------------
--FIRE HAMMER--
---------------
LinkLuaModifier("modifier_fire_hammer_1", "items/fire_hammer.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_hammer == nil then item_fire_hammer = class({}) end
function item_fire_hammer:GetIntrinsicModifierName() return "modifier_fire_hammer_1" end

if modifier_fire_hammer_1 == nil then modifier_fire_hammer_1 = class({}) end
function modifier_fire_hammer_1:IsHidden() return true end
function modifier_fire_hammer_1:IsPurgable() return false end
function modifier_fire_hammer_1:RemoveOnDeath() return false end
function modifier_fire_hammer_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_hammer_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_hammer_1:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_fire_hammer_1:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_fire_hammer_1:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_fire_hammer_1:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi") end
end
function modifier_fire_hammer_1:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetCaster()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local chance = ability:GetSpecialValueFor("bonus_chance")
		local bonus_chance_damage = ability:GetSpecialValueFor("bonus_chance_damage")
		if RollPseudoRandom(chance, self) then
			ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self:GetAbility(), damage = bonus_chance_damage, damage_type = DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, bonus_chance_damage, nil)
		end
	end
end

----------------
--FIRE HAMMER2--
----------------
LinkLuaModifier("modifier_fire_hammer_2", "items/fire_hammer.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_hammer_2 == nil then item_fire_hammer_2 = class({}) end
function item_fire_hammer_2:GetIntrinsicModifierName() return "modifier_fire_hammer_2" end

if modifier_fire_hammer_2 == nil then modifier_fire_hammer_2 = class({}) end
function modifier_fire_hammer_2:IsHidden() return true end
function modifier_fire_hammer_2:IsPurgable() return false end
function modifier_fire_hammer_2:RemoveOnDeath() return false end
function modifier_fire_hammer_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_hammer_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_hammer_2:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_fire_hammer_2:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_fire_hammer_2:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_fire_hammer_2:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi") end
end
function modifier_fire_hammer_2:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetCaster()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local chance = ability:GetSpecialValueFor("bonus_chance")
		local bonus_chance_damage = ability:GetSpecialValueFor("bonus_chance_damage")
		if RollPseudoRandom(chance, self) then
			ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self:GetAbility(), damage = bonus_chance_damage, damage_type = DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, bonus_chance_damage, nil)
		end
	end
end

----------------
--FIRE HAMMER3--
----------------
LinkLuaModifier("modifier_fire_hammer_3", "items/fire_hammer.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_hammer_3 == nil then item_fire_hammer_3 = class({}) end
function item_fire_hammer_3:GetIntrinsicModifierName() return "modifier_fire_hammer_3" end

if modifier_fire_hammer_3 == nil then modifier_fire_hammer_3 = class({}) end
function modifier_fire_hammer_3:IsHidden() return true end
function modifier_fire_hammer_3:IsPurgable() return false end
function modifier_fire_hammer_3:RemoveOnDeath() return false end
function modifier_fire_hammer_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_hammer_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_hammer_3:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_fire_hammer_3:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_fire_hammer_3:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_fire_hammer_3:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi") end
end
function modifier_fire_hammer_3:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetCaster()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local chance = ability:GetSpecialValueFor("bonus_chance")
		local bonus_chance_damage = ability:GetSpecialValueFor("bonus_chance_damage")
		if RollPseudoRandom(chance, self) then
			ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self:GetAbility(), damage = bonus_chance_damage, damage_type = DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, bonus_chance_damage, nil)
		end
	end
end

-------------------
--CURSED DEVOURER--
-------------------
LinkLuaModifier("modifier_cursed_devourer", "items/fire_hammer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cursed_devourer_greater_maim", "items/fire_hammer.lua", LUA_MODIFIER_MOTION_NONE)
if item_cursed_devourer == nil then item_cursed_devourer = class({}) end
function item_cursed_devourer:GetIntrinsicModifierName() return "modifier_cursed_devourer" end

if modifier_cursed_devourer == nil then modifier_cursed_devourer = class({}) end
function modifier_cursed_devourer:IsHidden() return true end
function modifier_cursed_devourer:IsPurgable() return false end
function modifier_cursed_devourer:RemoveOnDeath() return false end
function modifier_cursed_devourer:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_cursed_devourer:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_cursed_devourer:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_cursed_devourer:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_cursed_devourer:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_cursed_devourer:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi") end
end
function modifier_cursed_devourer:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
end
function modifier_cursed_devourer:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("movement_speed_bonus") end
end
function modifier_cursed_devourer:GetModifierStatusResistanceStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("status_res") end
end
function modifier_cursed_devourer:GetModifierHPRegenAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end
end
function modifier_cursed_devourer:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetCaster()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local chance = ability:GetSpecialValueFor("bonus_chance")
		local bonus_chance_damage = ability:GetSpecialValueFor("bonus_chance_damage")
		local maim_duration = ability:GetSpecialValueFor("maim_duration")
		if RollPseudoRandom(chance, self) then
			ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self:GetAbility(), damage = bonus_chance_damage, damage_type = DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, bonus_chance_damage, nil)
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_cursed_devourer_greater_maim", {duration = maim_duration})
			target:EmitSound("DOTA_Item.Maim")
		end
	end
end

if modifier_cursed_devourer_greater_maim == nil then modifier_cursed_devourer_greater_maim = class({}) end
function modifier_cursed_devourer_greater_maim:IsHidden() return false end
function modifier_cursed_devourer_greater_maim:IsDebuff() return true end
function modifier_cursed_devourer_greater_maim:IsPurgable() return true end
function modifier_cursed_devourer_greater_maim:RemoveOnDeath() return true end
function modifier_cursed_devourer_greater_maim:GetEffectName() return "particles/items2_fx/sange_maim.vpcf" end
function modifier_cursed_devourer_greater_maim:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_cursed_devourer_greater_maim:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_cursed_devourer_greater_maim:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("maim_slow_as") * (-1) end
end
function modifier_cursed_devourer_greater_maim:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("maim_slow_ms") * (-1) end
end
