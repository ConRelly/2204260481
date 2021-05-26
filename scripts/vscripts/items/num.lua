---------
-- NUM --
---------
item_num = item_num or class({})
LinkLuaModifier("modifier_num", "items/num.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_num_buff", "items/num.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_num_debuff", "items/num.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_num_debuff_aura", "items/num.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_num_aura", "items/num.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_num_sp", "items/num.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seal_act", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)

function item_num:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration_buff")
	caster:AddNewModifier(caster, self, "modifier_num_debuff", {duration = duration * (1 + caster:GetStatusResistance())})
	caster:EmitSoundParams("DOTA_Item.VeilofDiscord.Activate", 1, 0.5, 0)
end
function item_num:GetIntrinsicModifierName() return "modifier_num" end
----------
-- BUFF --
----------
--[[modifier_num_buff = modifier_num_buff or class({})
function modifier_num_buff:IsDebuff() return false end
function modifier_num_buff:IsHidden() return false end
function modifier_num_buff:IsPurgable() return true end
function modifier_num_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	--self:GetCaster():EmitSoundParams("Hero_Sven.SignetLayer", 1, 1.5, 0)
end
function modifier_num_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_num_buff:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration_debuff")
		target:AddNewModifier(owner, ability, "modifier_num_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	end
end
function modifier_num_buff:GetEffectName() return "particles/custom/items/num/num_active.vpcf" end
function modifier_num_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end]]
------------
-- DEBUFF --
------------
modifier_num_debuff = modifier_num_debuff or class({})
function modifier_num_debuff:IsAura() return true end
function modifier_num_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_NONE end
function modifier_num_debuff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_num_debuff:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_num_debuff:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_num_debuff:GetAuraDuration() return 0.5 end
function modifier_num_debuff:GetModifierAura() return "modifier_num_debuff_aura" end
function modifier_num_debuff:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius_debuf") end
function modifier_num_debuff:GetEffectName() return "particles/custom/items/num/num_active.vpcf" end
function modifier_num_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_num_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	--self:GetParent():EmitSoundParams("DOTA_Item.VeilofDiscord.Activate", 1, 0.5, 0)
end

modifier_num_debuff_aura = modifier_num_debuff_aura or class({})
function modifier_num_debuff_aura:IsDebuff() return true end
function modifier_num_debuff_aura:IsHidden() return false end
function modifier_num_debuff_aura:IsPurgable() return true end
function modifier_num_debuff_aura:RemoveOnDeath() return true end
function modifier_num_debuff_aura:GetEffectName() return "particles/custom/items/num/num_debuff.vpcf" end
function modifier_num_debuff_aura:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_num_debuff_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self:StartIntervalThink(FrameTime())
end
function modifier_num_debuff_aura:OnIntervalThink()
	if not IsServer() then return end
	self.counter_helper = {}
	self.target_counter = 0
	local search_radius = self:GetAbility():GetSpecialValueFor("search_radius")
	local target = self:GetCaster()
	for _, enemy in pairs(FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)) do
		if not self.counter_helper[enemy] then
			self.target_counter = self.target_counter + 1
			self.unit = enemy
			self.counter_helper[self.unit] = true
			self:SetStackCount(self.target_counter)
		end
	end
end
function modifier_num_debuff_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_num_debuff_aura:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then
		if self:GetStackCount() >= 2 then
			magic_resist_red = self:GetAbility():GetSpecialValueFor("magic_resist_red") * 1.5
		else
			magic_resist_red = self:GetAbility():GetSpecialValueFor("magic_resist_red")
		end
		return magic_resist_red * (-1)
	end
end
function modifier_num_debuff_aura:OnTooltip() return self:GetStackCount() end
-- Modifier num
modifier_num = modifier_num or class({})
function modifier_num:IsHidden() return true end
function modifier_num:IsPurgable() return false end
function modifier_num:RemoveOnDeath() return false end
function modifier_num:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_num:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end
function modifier_num:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("str") end
function modifier_num:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("agi") end
function modifier_num:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("int") end
function modifier_num:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("hp") end
function modifier_num:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
function modifier_num:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp") end
function modifier_num:GetModifierHealthRegenPercentage() return self:GetAbility():GetSpecialValueFor("hp_regen_pct") end
function modifier_num:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		local caster = self:GetParent()
		--Timers:CreateTimer(0.1, function()
			--caster:AddNewModifier(caster, self:GetAbility(), "modifier_seal_act", {})
		if self and self:GetAbility() ~= nil then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_num_sp", {})
		end	
		--end)
	end
end
function modifier_num:OnDestroy()
	if IsServer() then
        --self:GetCaster():RemoveModifierByName("modifier_seal_act")
		if self:GetCaster() ~= nil and self:GetCaster():HasModifier("modifier_num_sp") then
        	self:GetCaster():RemoveModifierByName("modifier_num_sp")
		end	
    end
end
function modifier_num:IsAura() return true end
function modifier_num:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_num:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_num:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_num:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_num:GetAuraDuration() return FrameTime() end
function modifier_num:GetModifierAura() return "modifier_num_aura" end
function modifier_num:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
----------
-- AURA --
----------
modifier_num_aura = modifier_num_aura or class({})
function modifier_num_aura:IsHidden() return false end
function modifier_num_aura:IsPurgable() return false end
function modifier_num_aura:RemoveOnDeath() return false end
function modifier_num_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_num_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_num_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_num_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int_aura") end
end
function modifier_num_aura:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen_aura") end
end
-------------
-- SPECIAL --
-------------
modifier_num_sp = modifier_num_sp or class({})
function modifier_num_sp:IsHidden() return false end
function modifier_num_sp:IsPurgable() return false end
function modifier_num_sp:RemoveOnDeath() return false end
function modifier_num_sp:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self:StartIntervalThink(FrameTime())
end
function modifier_num_sp:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local hp_regen = caster:GetHealthRegen()
		local limit = caster:GetLevel() * 2
		self.spell_amp = 0
		if caster:IsRealHero() and caster:GetPrimaryAttribute() == 2 then
			self.spell_amp = math.floor(hp_regen * self:GetAbility():GetSpecialValueFor("hpr_spell_amp") / 100)
		end	
		if self.spell_amp > limit then
			self.spell_amp = limit
		end	
		self:SetStackCount(self.spell_amp)
		
	end
end
function modifier_num_sp:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_num_sp:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end
