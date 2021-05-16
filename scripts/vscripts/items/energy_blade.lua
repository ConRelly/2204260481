------------------
-- Energy Blade --
------------------
item_energy_blade = item_energy_blade or class({})
LinkLuaModifier("modifier_energy_blade", "items/energy_blade.lua", LUA_MODIFIER_MOTION_NONE)
function item_energy_blade:GetIntrinsicModifierName() return "modifier_energy_blade" end
-- Energy Blade Modifier
modifier_energy_blade = modifier_energy_blade or class({})
function modifier_energy_blade:IsHidden() return true end
function modifier_energy_blade:IsPurgable() return false end
function modifier_energy_blade:RemoveOnDeath() return false end
function modifier_energy_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_blade:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_energy_blade:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_energy_blade:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
function modifier_energy_blade:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp") end

--------------------
-- Energy Blade 2 --
--------------------
item_energy_blade_2 = item_energy_blade_2 or class({})
LinkLuaModifier("modifier_energy_blade_2", "items/energy_blade.lua", LUA_MODIFIER_MOTION_NONE)
function item_energy_blade_2:GetIntrinsicModifierName() return "modifier_energy_blade_2" end
-- Energy Blade 2 Modifier
modifier_energy_blade_2 = modifier_energy_blade_2 or class({})
function modifier_energy_blade_2:IsHidden() return true end
function modifier_energy_blade_2:IsPurgable() return false end
function modifier_energy_blade_2:RemoveOnDeath() return false end
function modifier_energy_blade_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_blade_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_blade_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_energy_blade_2:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_energy_blade_2:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
function modifier_energy_blade_2:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp") end

--------------------
-- Energy Blade 3 --
--------------------
item_energy_blade_3 = item_energy_blade_3 or class({})
LinkLuaModifier("modifier_energy_blade_3", "items/energy_blade.lua", LUA_MODIFIER_MOTION_NONE)
function item_energy_blade_3:GetIntrinsicModifierName() return "modifier_energy_blade_3" end
-- Energy Blade 3 Modifier
modifier_energy_blade_3 = modifier_energy_blade_3 or class({})
function modifier_energy_blade_3:IsHidden() return true end
function modifier_energy_blade_3:IsPurgable() return false end
function modifier_energy_blade_3:RemoveOnDeath() return false end
function modifier_energy_blade_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_blade_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_blade_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_energy_blade_3:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_energy_blade_3:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
function modifier_energy_blade_3:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp") end


-----------------
-- Energy Veil --
-----------------
item_battlemage_cloth = item_battlemage_cloth or class({})
LinkLuaModifier("modifier_battlemage_cloth", "items/energy_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_battlemage_cloth_buff", "items/energy_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_battlemage_cloth_debuff", "items/energy_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_battlemage_cloth_aura", "items/energy_blade.lua", LUA_MODIFIER_MOTION_NONE)
function item_battlemage_cloth:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration_buff")
	caster:AddNewModifier(caster, self, "modifier_battlemage_cloth_buff", {duration = duration})
end
function item_battlemage_cloth:GetIntrinsicModifierName() return "modifier_battlemage_cloth" end
-- Energy Veil Modifier
modifier_battlemage_cloth = modifier_battlemage_cloth or class({})
function modifier_battlemage_cloth:IsHidden() return true end
function modifier_battlemage_cloth:IsPurgable() return false end
function modifier_battlemage_cloth:RemoveOnDeath() return false end
function modifier_battlemage_cloth:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_battlemage_cloth:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_battlemage_cloth:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_battlemage_cloth:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("str") end
function modifier_battlemage_cloth:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("agi") end
function modifier_battlemage_cloth:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_battlemage_cloth:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
function modifier_battlemage_cloth:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp") end
function modifier_battlemage_cloth:IsAura() return true end
function modifier_battlemage_cloth:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_battlemage_cloth:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_battlemage_cloth:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_battlemage_cloth:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_battlemage_cloth:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_battlemage_cloth:GetAuraDuration() return FrameTime() end
function modifier_battlemage_cloth:GetModifierAura() return "modifier_battlemage_cloth_aura" end
-- Energy Veil Aura
modifier_battlemage_cloth_aura = modifier_battlemage_cloth_aura or class({})
function modifier_battlemage_cloth_aura:IsHidden() return false end
function modifier_battlemage_cloth_aura:IsPurgable() return false end
function modifier_battlemage_cloth_aura:RemoveOnDeath() return false end
function modifier_battlemage_cloth_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_battlemage_cloth_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_battlemage_cloth_aura:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_aura") end
end
-- Energy Veil Buff
modifier_battlemage_cloth_buff = modifier_battlemage_cloth_buff or class({})
function modifier_battlemage_cloth_buff:IsDebuff() return false end
function modifier_battlemage_cloth_buff:IsHidden() return false end
function modifier_battlemage_cloth_buff:IsPurgable() return true end
function modifier_battlemage_cloth_buff:GetEffectName() return "particles/custom/items/battlemage_cloth/battlemage_cloth_ambient.vpcf" end
function modifier_battlemage_cloth_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_battlemage_cloth_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_battlemage_cloth_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_battlemage_cloth_buff:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration_debuff")
		target:AddNewModifier(owner, ability, "modifier_battlemage_cloth_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
function modifier_battlemage_cloth_buff:OnTooltip() return self:GetAbility():GetSpecialValueFor("magic_resist_red") end
-- Energy Veil Debuff
modifier_battlemage_cloth_debuff = modifier_battlemage_cloth_debuff or class({})
function modifier_battlemage_cloth_debuff:IsDebuff() return true end
function modifier_battlemage_cloth_debuff:IsHidden() return false end
function modifier_battlemage_cloth_debuff:IsPurgable() return false end
function modifier_battlemage_cloth_debuff:RemoveOnDeath() return true end
function modifier_battlemage_cloth_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		debuff_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(debuff_pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
		self:AddParticle(debuff_pfx, false, false, -1, false, false)
	end
end
function modifier_battlemage_cloth_debuff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(debuff_pfx, false)
	end
end
function modifier_battlemage_cloth_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_battlemage_cloth_debuff:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_resist_red") * (-1) end
end
