--------------
--ENERGY BOW--
--------------
LinkLuaModifier("modifier_energy_bow_1", "items/energy_bow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_bow_1_aura", "items/energy_bow.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_bow == nil then item_energy_bow = class({}) end
function item_energy_bow:GetIntrinsicModifierName() return "modifier_energy_bow_1" end

if modifier_energy_bow_1 == nil then modifier_energy_bow_1 = class({}) end
function modifier_energy_bow_1:IsHidden() return true end
function modifier_energy_bow_1:IsPurgable() return false end
function modifier_energy_bow_1:RemoveOnDeath() return false end
function modifier_energy_bow_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_bow_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_bow_1:IsAura() return true end
function modifier_energy_bow_1:IsAuraActiveOnDeath() return false end
function modifier_energy_bow_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_energy_bow_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_energy_bow_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_energy_bow_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_energy_bow_1:GetAuraDuration() return FrameTime() end
function modifier_energy_bow_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_energy_bow_1:GetModifierAura() return "modifier_energy_bow_1_aura" end
-------------------
--ENERGY BOW AURA--
-------------------
if modifier_energy_bow_1_aura == nil then modifier_energy_bow_1_aura = class({}) end
function modifier_energy_bow_1_aura:IsHidden() return false end
function modifier_energy_bow_1_aura:IsDebuff() return false end
function modifier_energy_bow_1_aura:IsPurgable() return false end
function modifier_energy_bow_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.pierce_proc = false
	self.pierce_records = {}
end
function modifier_energy_bow_1_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL, MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_PROPERTY_TOOLTIP }
end
function modifier_energy_bow_1_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_energy_bow_1_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end
function modifier_energy_bow_1_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("proc_chance") end
function modifier_energy_bow_1_aura:GetModifierProcAttack_BonusDamage_Magical(keys)
	if not IsServer() then return end
	local proc_damage = 0
	for _, record in pairs(self.pierce_records) do	
		if record == keys.record then
			table.remove(self.pierce_records, _)
			if not self:GetParent():IsIllusion() and not keys.target:IsBuilding() then
				return proc_damage
			end
		end
	end
end
function modifier_energy_bow_1_aura:OnAttackRecord(keys)
	if keys.attacker == self:GetParent() then
		local chance = self:GetAbility():GetSpecialValueFor("proc_chance")
		if self.pierce_proc then
			table.insert(self.pierce_records, keys.record)
			self.pierce_proc = false
		end
		if RollPseudoRandom(chance, self) then
			self.pierce_proc = true
		end
	end
end
function modifier_energy_bow_1_aura:CheckState()
	local state = {}
	if self.pierce_proc then
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
	return state
end

---------------
--ENERGY BOW2--
---------------
LinkLuaModifier("modifier_energy_bow_2", "items/energy_bow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_bow_2_aura", "items/energy_bow.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_bow_2 == nil then item_energy_bow_2 = class({}) end
function item_energy_bow_2:GetIntrinsicModifierName() return "modifier_energy_bow_2" end

if modifier_energy_bow_2 == nil then modifier_energy_bow_2 = class({}) end
function modifier_energy_bow_2:IsHidden() return true end
function modifier_energy_bow_2:IsPurgable() return false end
function modifier_energy_bow_2:RemoveOnDeath() return false end
function modifier_energy_bow_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_bow_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_bow_2:IsAura() return true end
function modifier_energy_bow_2:IsAuraActiveOnDeath() return false end
function modifier_energy_bow_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_energy_bow_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_energy_bow_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_energy_bow_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_energy_bow_2:GetAuraDuration() return FrameTime() end
function modifier_energy_bow_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_energy_bow_2:GetModifierAura() return "modifier_energy_bow_2_aura" end
--------------------
--ENERGY BOW2 AURA--
--------------------
if modifier_energy_bow_2_aura == nil then modifier_energy_bow_2_aura = class({}) end
function modifier_energy_bow_2_aura:IsHidden() return false end
function modifier_energy_bow_2_aura:IsDebuff() return false end
function modifier_energy_bow_2_aura:IsPurgable() return false end
function modifier_energy_bow_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.pierce_proc = false
	self.pierce_records = {}
end
function modifier_energy_bow_2_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL, MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_PROPERTY_TOOLTIP }
end
function modifier_energy_bow_2_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_energy_bow_2_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end
function modifier_energy_bow_2_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("proc_chance") end
function modifier_energy_bow_2_aura:GetModifierProcAttack_BonusDamage_Magical(keys)
	if not IsServer() then return end
	local proc_damage = 0
	for _, record in pairs(self.pierce_records) do	
		if record == keys.record then
			table.remove(self.pierce_records, _)
			if not self:GetParent():IsIllusion() and not keys.target:IsBuilding() then
				return proc_damage
			end
		end
	end
end
function modifier_energy_bow_2_aura:OnAttackRecord(keys)
	if keys.attacker == self:GetParent() then
		local chance = self:GetAbility():GetSpecialValueFor("proc_chance")
		if self.pierce_proc then
			table.insert(self.pierce_records, keys.record)
			self.pierce_proc = false
		end
		if RollPseudoRandom(chance, self) then
			self.pierce_proc = true
		end
	end
end
function modifier_energy_bow_2_aura:CheckState()
	local state = {}
	if self.pierce_proc then
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
	return state
end

---------------
--ENERGY BOW3--
---------------
LinkLuaModifier("modifier_energy_bow_3", "items/energy_bow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_bow_3_aura", "items/energy_bow.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_bow_3 == nil then item_energy_bow_3 = class({}) end
function item_energy_bow_3:GetIntrinsicModifierName() return "modifier_energy_bow_3" end

if modifier_energy_bow_3 == nil then modifier_energy_bow_3 = class({}) end
function modifier_energy_bow_3:IsHidden() return true end
function modifier_energy_bow_3:IsPurgable() return false end
function modifier_energy_bow_3:RemoveOnDeath() return false end
function modifier_energy_bow_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_bow_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_energy_bow_3:IsAura() return true end
function modifier_energy_bow_3:IsAuraActiveOnDeath() return false end
function modifier_energy_bow_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_energy_bow_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_energy_bow_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_energy_bow_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_energy_bow_3:GetAuraDuration() return FrameTime() end
function modifier_energy_bow_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_energy_bow_3:GetModifierAura() return "modifier_energy_bow_3_aura" end
--------------------
--ENERGY BOW3 AURA--
--------------------
if modifier_energy_bow_3_aura == nil then modifier_energy_bow_3_aura = class({}) end
function modifier_energy_bow_3_aura:IsHidden() return false end
function modifier_energy_bow_3_aura:IsDebuff() return false end
function modifier_energy_bow_3_aura:IsPurgable() return false end
function modifier_energy_bow_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.pierce_proc = false
	self.pierce_records = {}
end
function modifier_energy_bow_3_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL, MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_PROPERTY_TOOLTIP }
end
function modifier_energy_bow_3_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_energy_bow_3_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end
function modifier_energy_bow_3_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("proc_chance") end
function modifier_energy_bow_3_aura:GetModifierProcAttack_BonusDamage_Magical(keys)
	if not IsServer() then return end
	local proc_damage = 0
	for _, record in pairs(self.pierce_records) do	
		if record == keys.record then
			table.remove(self.pierce_records, _)
			if not self:GetParent():IsIllusion() and not keys.target:IsBuilding() then
				return proc_damage
			end
		end
	end
end
function modifier_energy_bow_3_aura:OnAttackRecord(keys)
	if keys.attacker == self:GetParent() then
		local chance = self:GetAbility():GetSpecialValueFor("proc_chance")
		if self.pierce_proc then
			table.insert(self.pierce_records, keys.record)
			self.pierce_proc = false
		end
		if RollPseudoRandom(chance, self) then
			self.pierce_proc = true
		end
	end
end
function modifier_energy_bow_3_aura:CheckState()
	local state = {}
	if self.pierce_proc then
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
	return state
end


----------------
--APOLLO'S BOW--
----------------
LinkLuaModifier("modifier_apollo_bow", "items/energy_bow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_apollo_bow_aura", "items/energy_bow.lua", LUA_MODIFIER_MOTION_NONE)
if item_apollo_bow == nil then item_apollo_bow = class({}) end
function item_apollo_bow:GetIntrinsicModifierName() return "modifier_apollo_bow" end

if modifier_apollo_bow == nil then modifier_apollo_bow = class({}) end
function modifier_apollo_bow:IsHidden() return true end
function modifier_apollo_bow:IsPurgable() return false end
function modifier_apollo_bow:RemoveOnDeath() return false end
function modifier_apollo_bow:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_apollo_bow:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_apollo_bow:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_apollo_bow:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_apollo_bow:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_apollo_bow:GetModifierProcAttack_BonusDamage_Magical(keys)
	if not IsServer() then return end
	local target = keys.target
	local chance = self:GetAbility():GetSpecialValueFor("proc_chance")
	local proc_damage = self:GetAbility():GetSpecialValueFor("proc_damage")
	if RollPseudoRandom(chance, self) then
		if not self:GetParent():IsIllusion() and not target:IsBuilding() then
			target:EmitSound("DOTA_Item.MKB.proc")
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, proc_damage, nil)
			local proc_fx = ParticleManager:CreateParticle("particles/custom/items/apollo_bow/apollo_bow_proc.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControl(proc_fx, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(proc_fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(proc_fx)
			return proc_damage
		end
	end
end
function modifier_apollo_bow:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end
function modifier_apollo_bow:IsAura() return true end
function modifier_apollo_bow:IsAuraActiveOnDeath() return false end
function modifier_apollo_bow:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_apollo_bow:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_apollo_bow:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_apollo_bow:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_apollo_bow:GetAuraDuration() return FrameTime() end
function modifier_apollo_bow:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_apollo_bow:GetModifierAura() return "modifier_apollo_bow_aura" end
---------------------
--APOLLO'S BOW AURA--
---------------------
if modifier_apollo_bow_aura == nil then modifier_apollo_bow_aura = class({}) end
function modifier_apollo_bow_aura:IsHidden() return false end
function modifier_apollo_bow_aura:IsDebuff() return false end
function modifier_apollo_bow_aura:IsPurgable() return false end
function modifier_apollo_bow_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.pierce_proc = false
	self.pierce_records = {}
end
function modifier_apollo_bow_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL, MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_TOOLTIP2}
end
function modifier_apollo_bow_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_apollo_bow_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end
function modifier_apollo_bow_aura:OnTooltip() return self:GetAbility():GetSpecialValueFor("proc_chance_aura") end
function modifier_apollo_bow_aura:OnTooltip2() return self:GetAbility():GetSpecialValueFor("proc_damage_aura") end
function modifier_apollo_bow_aura:GetModifierProcAttack_BonusDamage_Magical(keys)
	if not IsServer() then return end
	local proc_damage = self:GetAbility():GetSpecialValueFor("proc_damage_aura")
	for _, record in pairs(self.pierce_records) do	
		if record == keys.record then
			table.remove(self.pierce_records, _)
			if not self:GetParent():IsIllusion() and not keys.target:IsBuilding() then
--				keys.target:EmitSound("DOTA_Item.MKB.proc")
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, proc_damage, nil)
				return proc_damage
			end
		end
	end
end
function modifier_apollo_bow_aura:OnAttackRecord(keys)
	if keys.attacker == self:GetParent() then
		local chance = self:GetAbility():GetSpecialValueFor("proc_chance_aura")
		if self.pierce_proc then
			table.insert(self.pierce_records, keys.record)
			self.pierce_proc = false
		end
		if RollPseudoRandom(chance, self) then
			self.pierce_proc = true
		end
	end
end
function modifier_apollo_bow_aura:CheckState()
	local state = {}
	if self.pierce_proc then
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
	return state
end