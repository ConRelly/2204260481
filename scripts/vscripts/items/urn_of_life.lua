-----------------
-- URN OF LIFE --
-----------------
LinkLuaModifier("modifier_urn_of_life_1", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_urn_of_life_1_heal", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
item_urn_of_life = class({})
function item_urn_of_life:GetIntrinsicModifierName() return "modifier_urn_of_life_1" end
function item_urn_of_life:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_urn_of_life_1_heal", {duration = duration})
	target:EmitSound("DOTA_Item.UrnOfShadows.Activate")
end

modifier_urn_of_life_1 = class({})
function modifier_urn_of_life_1:IsHidden() return true end
function modifier_urn_of_life_1:IsPurgable() return false end
function modifier_urn_of_life_1:RemoveOnDeath() return false end
function modifier_urn_of_life_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_urn_of_life_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_urn_of_life_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_urn_of_life_1:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_urn_of_life_1:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_urn_of_life_1:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
----------------------
-- URN OF LIFE HEAL --
----------------------
modifier_urn_of_life_1_heal = class({})
function modifier_urn_of_life_1_heal:IsHidden() return false end
function modifier_urn_of_life_1_heal:IsDebuff() return false end
function modifier_urn_of_life_1_heal:IsPurgable() return true end
function modifier_urn_of_life_1_heal:GetEffectName() return "particles/items2_fx/urn_of_shadows_heal.vpcf" end
function modifier_urn_of_life_1_heal:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_urn_of_life_1_heal:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_urn_of_life_1_heal:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	local tickint = self:GetAbility():GetSpecialValueFor("tickint")
	self:StartIntervalThink(tickint)
end
function modifier_urn_of_life_1_heal:OnIntervalThink()
	local caster = self:GetCaster()
	local hpt = self:GetAbility():GetSpecialValueFor("hpt")
	self:GetParent():Heal(hpt,caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), hpt, nil)
end
function modifier_urn_of_life_1_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_urn_of_life_1_heal:OnTooltip() return self:GetAbility():GetSpecialValueFor("hpt") end


-------------------
-- URN OF LIFE 2 --
-------------------
LinkLuaModifier("modifier_urn_of_life_2", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_urn_of_life_2_heal", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
item_urn_of_life_2 = class({})
function item_urn_of_life_2:GetIntrinsicModifierName() return "modifier_urn_of_life_2" end
function item_urn_of_life_2:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_urn_of_life_2_heal", {duration = duration})
	target:EmitSound("DOTA_Item.UrnOfShadows.Activate")
end

modifier_urn_of_life_2 = class({})
function modifier_urn_of_life_2:IsHidden() return true end
function modifier_urn_of_life_2:IsPurgable() return false end
function modifier_urn_of_life_2:RemoveOnDeath() return false end
function modifier_urn_of_life_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_urn_of_life_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_urn_of_life_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_urn_of_life_2:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_urn_of_life_2:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_urn_of_life_2:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
------------------------
-- URN OF LIFE 2 HEAL --
------------------------
modifier_urn_of_life_2_heal = class({})
function modifier_urn_of_life_2_heal:IsHidden() return false end
function modifier_urn_of_life_2_heal:IsDebuff() return false end
function modifier_urn_of_life_2_heal:IsPurgable() return true end
function modifier_urn_of_life_2_heal:GetEffectName() return "particles/items2_fx/urn_of_shadows_heal.vpcf" end
function modifier_urn_of_life_2_heal:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_urn_of_life_2_heal:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_urn_of_life_2_heal:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	local tickint = self:GetAbility():GetSpecialValueFor("tickint")
	self:StartIntervalThink(tickint)
end
function modifier_urn_of_life_2_heal:OnIntervalThink()
	local caster = self:GetCaster()
	local hpt = self:GetAbility():GetSpecialValueFor("hpt")
	self:GetParent():Heal(hpt,caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), hpt, nil)
end
function modifier_urn_of_life_2_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_urn_of_life_2_heal:OnTooltip() return self:GetAbility():GetSpecialValueFor("hpt") end


-------------------
-- URN OF LIFE 3 --
-------------------
LinkLuaModifier("modifier_urn_of_life_3", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_urn_of_life_3_heal", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
item_urn_of_life_3 = class({})
function item_urn_of_life_3:GetIntrinsicModifierName() return "modifier_urn_of_life_3" end
function item_urn_of_life_3:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_urn_of_life_3_heal", {duration = duration})
	target:EmitSound("DOTA_Item.UrnOfShadows.Activate")
end

modifier_urn_of_life_3 = class({})
function modifier_urn_of_life_3:IsHidden() return true end
function modifier_urn_of_life_3:IsPurgable() return false end
function modifier_urn_of_life_3:RemoveOnDeath() return false end
function modifier_urn_of_life_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_urn_of_life_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_urn_of_life_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_urn_of_life_3:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_urn_of_life_3:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_urn_of_life_3:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
------------------------
-- URN OF LIFE 3 HEAL --
------------------------
modifier_urn_of_life_3_heal = class({})
function modifier_urn_of_life_3_heal:IsHidden() return false end
function modifier_urn_of_life_3_heal:IsDebuff() return false end
function modifier_urn_of_life_3_heal:IsPurgable() return true end
function modifier_urn_of_life_3_heal:GetEffectName() return "particles/items2_fx/urn_of_shadows_heal.vpcf" end
function modifier_urn_of_life_3_heal:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_urn_of_life_3_heal:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_urn_of_life_3_heal:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	local tickint = self:GetAbility():GetSpecialValueFor("tickint")
	self:StartIntervalThink(tickint)
end
function modifier_urn_of_life_3_heal:OnIntervalThink()
	local caster = self:GetCaster()
	local hpt = self:GetAbility():GetSpecialValueFor("hpt")
	self:GetParent():Heal(hpt,caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), hpt, nil)
end
function modifier_urn_of_life_3_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_urn_of_life_3_heal:OnTooltip() return self:GetAbility():GetSpecialValueFor("hpt") end


-------------------------
-- VESSEL OF THE SOULS --
-------------------------
LinkLuaModifier("modifier_vessel_of_the_souls", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vessel_of_the_souls_buff", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vessel_of_the_souls_debuff", "items/urn_of_life.lua", LUA_MODIFIER_MOTION_NONE)
item_vessel_of_the_souls = class({})
function item_vessel_of_the_souls:GetIntrinsicModifierName() return "modifier_vessel_of_the_souls" end
function item_vessel_of_the_souls:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local base_cd = self:GetSpecialValueFor("base_cooldown")
	self:StartCooldown(base_cd)
    if target:GetTeam() == caster:GetTeam() then
		target:AddNewModifier(target, self, "modifier_vessel_of_the_souls_buff", {duration = duration})
		target:EmitSound("DOTA_Item.SpiritVessel.Target.Ally")
		target:Purge(false, true, false, false, false)
    else
        target:AddNewModifier(target, self, "modifier_vessel_of_the_souls_debuff", {duration = duration * (1 - target:GetStatusResistance())})
		target:EmitSound("DOTA_Item.SpiritVessel.Target.Enemy")
    end
end

modifier_vessel_of_the_souls = class({})
function modifier_vessel_of_the_souls:IsHidden() return true end
function modifier_vessel_of_the_souls:IsPurgable() return false end
function modifier_vessel_of_the_souls:RemoveOnDeath() return false end
function modifier_vessel_of_the_souls:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_vessel_of_the_souls:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_vessel_of_the_souls:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end
function modifier_vessel_of_the_souls:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_vessel_of_the_souls:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_vessel_of_the_souls:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_vessel_of_the_souls:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("speed") end
end
function modifier_vessel_of_the_souls:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_vessel_of_the_souls:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_atr") end
end
function modifier_vessel_of_the_souls:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_atr") end
end
function modifier_vessel_of_the_souls:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_atr") end
end

------------------------------
-- VESSEL OF THE SOULS BUFF --
------------------------------
modifier_vessel_of_the_souls_buff = class({})
function modifier_vessel_of_the_souls_buff:IsHidden() return false end
function modifier_vessel_of_the_souls_buff:IsDebuff() return false end
function modifier_vessel_of_the_souls_buff:IsPurgable() return true end
function modifier_vessel_of_the_souls_buff:GetTexture() return "custom/vessel_of_the_souls" end
function modifier_vessel_of_the_souls_buff:GetEffectName() return "particles/items4_fx/spirit_vessel_heal.vpcf" end
function modifier_vessel_of_the_souls_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_vessel_of_the_souls_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_vessel_of_the_souls_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_vessel_of_the_souls_buff:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("buff_hp_regen") end
end
function modifier_vessel_of_the_souls_buff:GetModifierHPRegenAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("buff_hp_regen_amp") end
end
function modifier_vessel_of_the_souls_buff:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("buff_dmg_red") * (-1) end
end

--------------------------------
-- VESSEL OF THE SOULS DEBUFF --
--------------------------------
modifier_vessel_of_the_souls_debuff = class({})
function modifier_vessel_of_the_souls_debuff:IsHidden() return false end
function modifier_vessel_of_the_souls_debuff:IsDebuff() return true end
function modifier_vessel_of_the_souls_debuff:IsPurgable() return true end
function modifier_vessel_of_the_souls_debuff:GetTexture() return "custom/vessel_of_the_souls_debuff" end
function modifier_vessel_of_the_souls_debuff:GetEffectName() return "particles/items4_fx/spirit_vessel_damage.vpcf" end
function modifier_vessel_of_the_souls_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_vessel_of_the_souls_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	local tickint = self:GetAbility():GetSpecialValueFor("tickint")
	self:StartIntervalThink(tickint)
end
function modifier_vessel_of_the_souls_debuff:OnIntervalThink()
	local dpt = self:GetAbility():GetSpecialValueFor("dpt")
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = dpt, damage_type = DAMAGE_TYPE_MAGICAL})
end
function modifier_vessel_of_the_souls_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_vessel_of_the_souls_debuff:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("debuff_magic_resist") * (-1) end
end
function modifier_vessel_of_the_souls_debuff:GetModifierHPRegenAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("debuff_hp_regen_red") * (-1) end
end
function modifier_vessel_of_the_souls_debuff:OnTooltip() return self:GetAbility():GetSpecialValueFor("dpt") end
