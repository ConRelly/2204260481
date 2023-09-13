--------------
--FIRE SWORD--
--------------
LinkLuaModifier("modifier_fire_sword_1", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_sword_1_burn", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_sword == nil then item_fire_sword = class({}) end
function item_fire_sword:GetIntrinsicModifierName() return "modifier_fire_sword_1" end

if modifier_fire_sword_1 == nil then modifier_fire_sword_1 = class({}) end
function modifier_fire_sword_1:IsHidden() return true end
function modifier_fire_sword_1:IsPurgable() return false end
function modifier_fire_sword_1:RemoveOnDeath() return false end
function modifier_fire_sword_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_sword_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_sword_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_fire_sword_1:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_fire_sword_1:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_fire_sword_1:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_fire_sword_1:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		target:AddNewModifier(owner, ability, "modifier_fire_sword_1_burn", {duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
	end
end
-------------------
--FIRE SWORD BURN--
-------------------
modifier_fire_sword_1_burn = modifier_fire_sword_1_burn or class({})
function modifier_fire_sword_1_burn:IsDebuff() return true end
function modifier_fire_sword_1_burn:IsHidden() return false end
function modifier_fire_sword_1_burn:IsPurgable() return true end
function modifier_fire_sword_1_burn:RemoveOnDeath() return true end
function modifier_fire_sword_1_burn:OnCreated(kv)
	self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	self.dpt = self:GetAbility():GetSpecialValueFor("dpt")
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		self.burn = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.burn, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.burn, 1, self:GetCaster():GetAbsOrigin())
		self:StartIntervalThink(self.tick_interval)
	end
end
function modifier_fire_sword_1_burn:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self.dpt,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end
function modifier_fire_sword_1_burn:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.burn, false)
		ParticleManager:ReleaseParticleIndex(self.burn)
	end
end

---------------
--FIRE SWORD2--
---------------
LinkLuaModifier("modifier_fire_sword_2", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_sword_2_burn", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_sword_2 == nil then item_fire_sword_2 = class({}) end
function item_fire_sword_2:GetIntrinsicModifierName() return "modifier_fire_sword_2" end

if modifier_fire_sword_2 == nil then modifier_fire_sword_2 = class({}) end
function modifier_fire_sword_2:IsHidden() return true end
function modifier_fire_sword_2:IsPurgable() return false end
function modifier_fire_sword_2:RemoveOnDeath() return false end
function modifier_fire_sword_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_sword_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_sword_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_fire_sword_2:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_fire_sword_2:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_fire_sword_2:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_fire_sword_2:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		target:AddNewModifier(owner, ability, "modifier_fire_sword_2_burn", {duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
	end
end
--------------------
--FIRE SWORD2 BURN--
--------------------
modifier_fire_sword_2_burn = modifier_fire_sword_2_burn or class({})
function modifier_fire_sword_2_burn:IsDebuff() return true end
function modifier_fire_sword_2_burn:IsHidden() return false end
function modifier_fire_sword_2_burn:IsPurgable() return true end
function modifier_fire_sword_2_burn:RemoveOnDeath() return true end
function modifier_fire_sword_2_burn:OnCreated(kv)
	self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	self.dpt = self:GetAbility():GetSpecialValueFor("dpt")
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		self.burn = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.burn, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.burn, 1, self:GetCaster():GetAbsOrigin())
		self:StartIntervalThink(self.tick_interval)
	end
end
function modifier_fire_sword_2_burn:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self.dpt,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end
function modifier_fire_sword_2_burn:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.burn, false)
		ParticleManager:ReleaseParticleIndex(self.burn)
	end
end

---------------
--FIRE SWORD3--
---------------
LinkLuaModifier("modifier_fire_sword_3", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fire_sword_3_burn", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_fire_sword_3 == nil then item_fire_sword_3 = class({}) end
function item_fire_sword_3:GetIntrinsicModifierName() return "modifier_fire_sword_3" end

if modifier_fire_sword_3 == nil then modifier_fire_sword_3 = class({}) end
function modifier_fire_sword_3:IsHidden() return true end
function modifier_fire_sword_3:IsPurgable() return false end
function modifier_fire_sword_3:RemoveOnDeath() return false end
function modifier_fire_sword_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fire_sword_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_fire_sword_3:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_fire_sword_3:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_fire_sword_3:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_fire_sword_3:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_fire_sword_3:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		target:AddNewModifier(owner, ability, "modifier_fire_sword_3_burn", {duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
	end
end
--------------------
--FIRE SWORD3 BURN--
--------------------
modifier_fire_sword_3_burn = modifier_fire_sword_3_burn or class({})
function modifier_fire_sword_3_burn:IsDebuff() return true end
function modifier_fire_sword_3_burn:IsHidden() return false end
function modifier_fire_sword_3_burn:IsPurgable() return true end
function modifier_fire_sword_3_burn:RemoveOnDeath() return true end
function modifier_fire_sword_3_burn:OnCreated(kv)
	self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	self.dpt = self:GetAbility():GetSpecialValueFor("dpt")
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		self.burn = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.burn, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.burn, 1, self:GetCaster():GetAbsOrigin())
		self:StartIntervalThink(self.tick_interval)
	end
end
function modifier_fire_sword_3_burn:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self.dpt,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end
function modifier_fire_sword_3_burn:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.burn, false)
		ParticleManager:ReleaseParticleIndex(self.burn)
	end
end

-----------------
--DEMONIC SWORD--
-----------------
LinkLuaModifier("modifier_demonic_sword", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demonic_sword_burn", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demonic_sword_burn_aura", "items/fire_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_demonic_sword == nil then item_demonic_sword = class({}) end
function item_demonic_sword:GetIntrinsicModifierName() return "modifier_demonic_sword" end

if modifier_demonic_sword == nil then modifier_demonic_sword = class({}) end
function modifier_demonic_sword:IsHidden() return true end
function modifier_demonic_sword:IsPurgable() return false end
function modifier_demonic_sword:RemoveOnDeath() return false end
function modifier_demonic_sword:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_demonic_sword:GetEffectName() return "particles/items2_fx/radiance_owner.vpcf" end
function modifier_demonic_sword:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_demonic_sword:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_demonic_sword:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_demonic_sword:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_demonic_sword:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_demonic_sword:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end
		keys.target:AddNewModifier(owner, self:GetAbility(), "modifier_demonic_sword_burn", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
end
function modifier_demonic_sword:IsAura() return true end
function modifier_demonic_sword:IsAuraActiveOnDeath() return false end
function modifier_demonic_sword:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_demonic_sword:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_demonic_sword:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_demonic_sword:GetAuraDuration() return 0.2 end
function modifier_demonic_sword:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_demonic_sword:GetModifierAura() return "modifier_demonic_sword_burn_aura" end
----------------------
--DEMONIC SWORD BURN--
----------------------
modifier_demonic_sword_burn = modifier_demonic_sword_burn or class({})
function modifier_demonic_sword_burn:IsDebuff() return true end
function modifier_demonic_sword_burn:IsHidden() return false end
function modifier_demonic_sword_burn:IsPurgable() return true end
function modifier_demonic_sword_burn:RemoveOnDeath() return true end
function modifier_demonic_sword_burn:OnCreated(kv)
	self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	self.dps = self:GetAbility():GetSpecialValueFor("dps")
	self.hp_dmg = self:GetAbility():GetSpecialValueFor("current_hp_damage")
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		self.burn = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.burn, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.burn, 1, self:GetCaster():GetAbsOrigin())
		self:StartIntervalThink(self.tick_interval)
	end
end
function modifier_demonic_sword_burn:OnIntervalThink()
	local parent = self:GetParent()
	local current_hp = parent:GetHealth()
	local bonus_dmg = math.floor(current_hp * (self.hp_dmg /100))
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = (self.dps + bonus_dmg) * self.tick_interval,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end
function modifier_demonic_sword_burn:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.burn, false)
		ParticleManager:ReleaseParticleIndex(self.burn)
	end
end
---------------------------
--DEMONIC SWORD BURN AURA--
---------------------------
if modifier_demonic_sword_burn_aura == nil then modifier_demonic_sword_burn_aura = class({}) end
function modifier_demonic_sword_burn_aura:IsHidden() return false end
function modifier_demonic_sword_burn_aura:IsDebuff() return true end
function modifier_demonic_sword_burn_aura:IsPurgable() return false end
function modifier_demonic_sword_burn_aura:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_demonic_sword_burn_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end
function modifier_demonic_sword_burn_aura:GetModifierMiss_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("blind_pct") end
end
function modifier_demonic_sword_burn_aura:OnCreated(kv)
	self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	self.dps_aura = self:GetAbility():GetSpecialValueFor("dps_aura")
	if self:GetCaster():IsIllusion() then
		self.dps_aura = self:GetAbility():GetSpecialValueFor("dps_illusion_aura")
	end
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		self.burn = ParticleManager:CreateParticle("particles/items2_fx/radiance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.burn, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.burn, 1, self:GetCaster():GetAbsOrigin())
		self:StartIntervalThink(self.tick_interval)
	end
end
function modifier_demonic_sword_burn_aura:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self.dps_aura,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end
function modifier_demonic_sword_burn_aura:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.burn, false)
		ParticleManager:ReleaseParticleIndex(self.burn)
	end
end
