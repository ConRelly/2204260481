-----------------
--SPEAR OF LIFE--
-----------------
LinkLuaModifier("modifier_spear_of_life_1", "items/spear_of_life.lua", LUA_MODIFIER_MOTION_NONE)
if item_spear_of_life == nil then item_spear_of_life = class({}) end
function item_spear_of_life:GetIntrinsicModifierName() return "modifier_spear_of_life_1" end
function item_spear_of_life:OnSpellStart()
	local caster = self:GetCaster()
	local heal = self:GetSpecialValueFor("heal")
	caster:EmitSound("DOTA_Item.FaerieSpark.Activate")
	local target = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for i=1, #target do
		ParticleManager:CreateParticle("particles/custom/items/spear_of_life/spear_of_life_act.vpcf", PATTACH_ABSORIGIN_FOLLOW, target[i])
		target[i]:Heal(heal,caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target[i], heal, nil)
	end
end
if modifier_spear_of_life_1 == nil then modifier_spear_of_life_1 = class({}) end
function modifier_spear_of_life_1:IsHidden() return true end
function modifier_spear_of_life_1:IsPurgable() return false end
function modifier_spear_of_life_1:RemoveOnDeath() return false end
function modifier_spear_of_life_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spear_of_life_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_spear_of_life_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_spear_of_life_1:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_spear_of_life_1:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_spear_of_life_1:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end

------------------
--SPEAR OF LIFE2--
------------------
LinkLuaModifier("modifier_spear_of_life_2", "items/spear_of_life.lua", LUA_MODIFIER_MOTION_NONE)
if item_spear_of_life_2 == nil then item_spear_of_life_2 = class({}) end
function item_spear_of_life_2:GetIntrinsicModifierName() return "modifier_spear_of_life_2" end
function item_spear_of_life_2:OnSpellStart()
	local caster = self:GetCaster()
	local heal = self:GetSpecialValueFor("heal")
	caster:EmitSound("DOTA_Item.FaerieSpark.Activate")
	local target = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for i=1, #target do
		ParticleManager:CreateParticle("particles/custom/items/spear_of_life/spear_of_life_act.vpcf", PATTACH_ABSORIGIN_FOLLOW, target[i])
		target[i]:Heal(heal,caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target[i], heal, nil)
	end
end
if modifier_spear_of_life_2 == nil then modifier_spear_of_life_2 = class({}) end
function modifier_spear_of_life_2:IsHidden() return true end
function modifier_spear_of_life_2:IsPurgable() return false end
function modifier_spear_of_life_2:RemoveOnDeath() return false end
function modifier_spear_of_life_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spear_of_life_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_spear_of_life_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_spear_of_life_2:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_spear_of_life_2:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_spear_of_life_2:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end

------------------
--SPEAR OF LIFE3--
------------------
LinkLuaModifier("modifier_spear_of_life_3", "items/spear_of_life.lua", LUA_MODIFIER_MOTION_NONE)
if item_spear_of_life_3 == nil then item_spear_of_life_3 = class({}) end
function item_spear_of_life_3:GetIntrinsicModifierName() return "modifier_spear_of_life_3" end
function item_spear_of_life_3:OnSpellStart()
	local caster = self:GetCaster()
	local heal = self:GetSpecialValueFor("heal")
	caster:EmitSound("DOTA_Item.FaerieSpark.Activate")
	local target = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for i=1, #target do
		ParticleManager:CreateParticle("particles/custom/items/spear_of_life/spear_of_life_act.vpcf", PATTACH_ABSORIGIN_FOLLOW, target[i])
		target[i]:Heal(heal,caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target[i], heal, nil)
	end
end
if modifier_spear_of_life_3 == nil then modifier_spear_of_life_3 = class({}) end
function modifier_spear_of_life_3:IsHidden() return true end
function modifier_spear_of_life_3:IsPurgable() return false end
function modifier_spear_of_life_3:RemoveOnDeath() return false end
function modifier_spear_of_life_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spear_of_life_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_spear_of_life_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_spear_of_life_3:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_spear_of_life_3:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_spear_of_life_3:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end

------------------
-- Life Greaves --
------------------
LinkLuaModifier("modifier_life_greaves", "items/spear_of_life", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_life_greaves_aura", "items/spear_of_life", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_life_greaves_aura_threshold", "items/spear_of_life", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_life_greaves_mend", "items/spear_of_life", LUA_MODIFIER_MOTION_NONE)
if item_life_greaves == nil then item_life_greaves = class({}) end
function item_life_greaves:GetIntrinsicModifierName() return "modifier_life_greaves" end
function item_life_greaves:OnSpellStart()
	local caster = self:GetCaster()
	local heal_amount_pct = self:GetSpecialValueFor("heal_amount_pct")
	local heal_amount = self:GetSpecialValueFor("heal_amount")
	local mana_amount_pct = self:GetSpecialValueFor("mana_amount_pct")
	local mana_amount = self:GetSpecialValueFor("mana_amount")
	caster:Purge(false,true,false,false,false)

	caster:AddNewModifier(caster, self, "modifier_life_greaves_mend", {duration = self:GetSpecialValueFor("mend_duration")})

	caster:EmitSound("DOTA_Item.FaerieSpark.Activate")
	caster:EmitSound("Item.GuardianGreaves.Activate")
	local target = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _, unit in pairs(target) do
		local heal = (unit:GetMaxHealth() * heal_amount_pct / 100) + heal_amount
		local mana = (unit:GetMaxMana() * mana_amount_pct / 100) + mana_amount
		local mend = ParticleManager:CreateParticle("particles/custom/items/life_greaves/life_greaves_mend.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(mend, 0, unit, PATTACH_CUSTOMORIGIN_FOLLOW, nil, unit:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(mend, 1, unit, PATTACH_CUSTOMORIGIN_FOLLOW, nil, unit:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(mend)
		unit:Heal(heal, caster)
		unit:GiveMana(mana)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, unit, heal, nil)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, unit, mana, nil)
        unit:EmitSound("Item.GuardianGreaves.Target")
		for y=0, 9, 1 do
			local current_item = unit:GetItemInSlot(y)
			if current_item ~= nil then
				if current_item:GetName() == "item_bottle" then
					local charges = current_item:GetCurrentCharges()
					current_item:SetCurrentCharges(charges + 1)
					unit:EmitSoundParams("Bottle.Cork", 1, 0.5, 0)
				end
			end
		end
	end
end

if modifier_life_greaves == nil then modifier_life_greaves = class({}) end
function modifier_life_greaves:IsHidden() return true end
function modifier_life_greaves:IsPurgable() return false end
function modifier_life_greaves:RemoveOnDeath() return false end
function modifier_life_greaves:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_life_greaves:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end self:StartIntervalThink(FrameTime()) end
end
function modifier_life_greaves:OnIntervalThink()
	if IsServer() then
		if self:GetParent():IsIllusion() then return end
		if self:GetAbility():IsCooldownReady() and self:GetCaster():GetHealthPercent() < self:GetAbility():GetSpecialValueFor("aura_bonus_threshold") then
			self:GetCaster():Purge(false, false, false, true, false)
			self:GetAbility():OnSpellStart()
			self:GetAbility():UseResources(true, false, true)
		end
		if self:GetParent():HasModifier("modifier_bottle_regeneration") then
			if not self:GetParent():HasModifier("modifier_life_greaves_mend") then
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_life_greaves_mend", {})
			end
		else
			if self:GetParent():HasModifier("modifier_life_greaves_mend") and self:GetParent():FindModifierByName("modifier_life_greaves_mend"):GetDuration() < 0 then
				self:GetParent():RemoveModifierByName("modifier_life_greaves_mend")
			end
		end
	end
end
function modifier_life_greaves:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_life_greaves:GetModifierMoveSpeedBonus_Special_Boots()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("speed") end
end
function modifier_life_greaves:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_life_greaves:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("health") end
end
function modifier_life_greaves:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_life_greaves:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_life_greaves:IsAura() return true end
function modifier_life_greaves:IsAuraActiveOnDeath() return false end
function modifier_life_greaves:GetAuraRadius() return FIND_UNITS_EVERYWHERE end
function modifier_life_greaves:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_life_greaves:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_life_greaves:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_life_greaves:GetAuraDuration() return FrameTime() end
function modifier_life_greaves:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_life_greaves:GetModifierAura() return "modifier_life_greaves_aura" end

-----------------------
-- Life Greaves Aura --
-----------------------
if modifier_life_greaves_aura == nil then modifier_life_greaves_aura = class({}) end
function modifier_life_greaves_aura:IsHidden() return false end
function modifier_life_greaves_aura:IsDebuff() return false end
function modifier_life_greaves_aura:IsPurgable() return false end
function modifier_life_greaves_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end self:StartIntervalThink(FrameTime()) end
end
function modifier_life_greaves_aura:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():GetHealthPercent() < self:GetAbility():GetSpecialValueFor("aura_bonus_threshold") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_life_greaves_aura_threshold", {})
		else
			self:GetParent():RemoveModifierByName("modifier_life_greaves_aura_threshold")
		end
	end
end
function modifier_life_greaves_aura:OnDestroy()
	if self:GetParent():HasModifier("modifier_life_greaves_aura_threshold") then
		self:GetParent():RemoveModifierByName("modifier_life_greaves_aura_threshold")
	end
end
function modifier_life_greaves_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_life_greaves_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_armor") end
end
function modifier_life_greaves_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_health_regen") end
end

if modifier_life_greaves_aura_threshold == nil then modifier_life_greaves_aura_threshold = class({}) end
function modifier_life_greaves_aura_threshold:IsHidden() return false end
function modifier_life_greaves_aura_threshold:IsDebuff() return false end
function modifier_life_greaves_aura_threshold:IsPurgable() return false end
function modifier_life_greaves_aura_threshold:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_life_greaves_aura_threshold:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_life_greaves_aura_threshold:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_armor_threshold") end
end
function modifier_life_greaves_aura_threshold:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_health_regen_threshold") end
end

-----------------------
-- Life Greaves Mend --
-----------------------
modifier_life_greaves_mend = class({})
function modifier_life_greaves_mend:IsHidden() return false end
function modifier_life_greaves_mend:IsDebuff() return false end
function modifier_life_greaves_mend:IsPurgable() return false end
function modifier_life_greaves_mend:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end
function modifier_life_greaves_mend:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mend_dmg_resist") * (-1) end
end
function modifier_life_greaves_mend:GetModifierStatusResistanceStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mend_status_resist") end
end
