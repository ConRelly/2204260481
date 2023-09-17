LinkLuaModifier("modifier_flaming_cape", "items/flaming_cape.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flaming_cape_invis", "items/flaming_cape.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flaming_cape_flames_aura", "items/flaming_cape.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flaming_cape_flames_burn", "items/flaming_cape.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flaming_cape_up_radiance_flames", "items/flaming_cape.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flaming_cape_up_radiance_flames_burn", "items/flaming_cape.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flaming_cape_charges", "items/flaming_cape.lua", LUA_MODIFIER_MOTION_NONE)
------------------
-- Flaming Cape --
------------------
if item_flaming_cape == nil then item_flaming_cape = class({}) end
function item_flaming_cape:GetIntrinsicModifierName() return "modifier_flaming_cape" end
function item_flaming_cape:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end
function item_flaming_cape:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	self:GetCaster():EmitSound("Item.GlimmerCape.Activate")

	local active_fx = ParticleManager:CreateParticle("particles/custom/items/flaming_cape/flaming_cape_active_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(active_fx)

	target:AddNewModifier(self:GetCaster(), self, "modifier_flaming_cape_invis", {duration = self:GetSpecialValueFor("duration")})

	if self:GetCaster():HasModifier("modifier_demonic_sword") then
		target:AddNewModifier(self:GetCaster(), self, "modifier_flaming_cape_up_radiance_flames", {duration = self:GetSpecialValueFor("duration")})
	end
end

---------------------------
-- Flaming Cape Modifier --
---------------------------
if modifier_flaming_cape == nil then modifier_flaming_cape = class({}) end
function modifier_flaming_cape:IsHidden() return true end
function modifier_flaming_cape:IsPurgable() return false end
function modifier_flaming_cape:RemoveOnDeath() return false end
function modifier_flaming_cape:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_flaming_cape:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		if not self:GetParent():HasModifier("modifier_flaming_cape_flames_aura") then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_flaming_cape_flames_aura", {})
		end
		if self.ambient == nil then
			self.ambient = ParticleManager:CreateParticle("particles/custom/items/flaming_cape/flaming_cape_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(self.ambient, 0, Vector(0, 0, 0))
			ParticleManager:SetParticleControl(self.ambient, 1, Vector(self:GetAbility():GetSpecialValueFor("aura_radius"), 1, 1))
		end
	end
end
function modifier_flaming_cape:OnDestroy(keys)
	if IsServer() then
		if not self:GetParent():HasModifier("modifier_flaming_cape") then
			self:GetParent():RemoveModifierByName("modifier_flaming_cape_flames_aura")
		end
	end
	if self.ambient ~= nil then
		ParticleManager:DestroyParticle(self.ambient, false)
		ParticleManager:ReleaseParticleIndex(self.ambient)
		self.ambient = nil
	end
end
function modifier_flaming_cape:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_flaming_cape:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_flaming_cape:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("bonus_magic_resist") end

---------------------------------
-- Flaming Cape Invis Modifier --
---------------------------------
if modifier_flaming_cape_invis == nil then modifier_flaming_cape_invis = class({}) end
function modifier_flaming_cape_invis:IsHidden() return true end
function modifier_flaming_cape_invis:IsPurgable() return true end
function modifier_flaming_cape_invis:RemoveOnDeath() return true end
function modifier_flaming_cape_invis:GetEffectName() return "particles/custom/items/flaming_cape/flaming_cape_active.vpcf" end
function modifier_flaming_cape_invis:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.fade_delay = self:GetAbility():GetSpecialValueFor("fade_delay")
	if not IsServer() then return end
	self.counter = 0
	self:StartIntervalThink(0.1)
end
function modifier_flaming_cape_invis:OnRefresh() self:OnCreated() end
function modifier_flaming_cape_invis:OnIntervalThink()
	if not IsServer() then return end
	local present_mod = false
	for _, modifier in pairs(self:GetParent():FindAllModifiersByName("modifier_invisible")) do
		if modifier:GetAbility() == self:GetAbility() then
			present_mod = true
			break
		end
	end
	if not present_mod then
		self.counter = self.counter + FrameTime()
		if self.counter >= self.fade_delay then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible", {duration = self:GetRemainingTime(), cancelattack = false})
			self.counter = 0
			if self:GetParent():GetAggroTarget() then
				self:GetParent():MoveToTargetToAttack(self:GetParent():GetAggroTarget())
			end
		end
	end
end
function modifier_flaming_cape_invis:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_flaming_cape_invis:GetModifierMagicalResistanceBonus()
	if self:GetParent():HasModifier("modifier_invisible") then
		return self:GetAbility():GetSpecialValueFor("active_magical_armor")
	end
end

-----------------
-- Flames Aura --
-----------------
if modifier_flaming_cape_flames_aura == nil then modifier_flaming_cape_flames_aura = class({}) end
function modifier_flaming_cape_flames_aura:IsHidden() return true end
function modifier_flaming_cape_flames_aura:IsDebuff() return false end
function modifier_flaming_cape_flames_aura:IsPurgable() return false end
function modifier_flaming_cape_flames_aura:IsAura()
	if self:GetParent():IsIllusion() then
		return false
	end
	return true
end
function modifier_flaming_cape_flames_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_flaming_cape_flames_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_flaming_cape_flames_aura:GetModifierAura() return "modifier_flaming_cape_flames_burn" end
function modifier_flaming_cape_flames_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end

--- charge modif---

if modifier_flaming_cape_charges == nil then modifier_flaming_cape_charges = class({}) end
function modifier_flaming_cape_charges:IsHidden() return true end
function modifier_flaming_cape_charges:IsDebuff() return false end
function modifier_flaming_cape_charges:IsPurgable() return false end
function modifier_flaming_cape_charges:RemoveOnDeath() return false end
------

------------------------
-- Flames Aura Effect --
------------------------
if modifier_flaming_cape_flames_burn == nil then modifier_flaming_cape_flames_burn = class({}) end
function modifier_flaming_cape_flames_burn:IsHidden() return false end
function modifier_flaming_cape_flames_burn:IsDebuff() return true end
function modifier_flaming_cape_flames_burn:IsPurgable() return false end
function modifier_flaming_cape_flames_burn:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_flaming_cape_flames_burn:OnCreated()
	local ability = self:GetAbility()
	if not ability then self:Destroy() return end
	local caster = self:GetCaster()
	self.damage_interval = ability:GetSpecialValueFor("damage_interval")
	local lvl = caster:GetLevel()
	local charges = 1
	if lvl > 34 then
		charges = ability:GetCurrentCharges()
		if charges < 1 then
			charges = 1
		end	
	end	
	self.base_damage = ability:GetSpecialValueFor("base_damage") * charges * self.damage_interval
	if IsServer() then
		self.burn = ParticleManager:CreateParticle("particles/custom/items/flaming_cape/flaming_cape_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.burn, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.burn, 1, caster:GetAbsOrigin())
		self:StartIntervalThink(self.damage_interval)
		---charge modif--
		charges = ability:GetCurrentCharges()
		if charges < 1 then
			charges = 1
		end			
		local charges_modifer = caster:FindModifierByName("modifier_flaming_cape_charges")
		if charges_modifer then
			charges_modifer:SetStackCount(charges)
		else
			caster:AddNewModifier(caster, ability, "modifier_flaming_cape_charges", {})
			charges_modifer = caster:FindModifierByName("modifier_flaming_cape_charges")
			if charges_modifer then
				charges_modifer:SetStackCount(charges)
			end	
		end		
	end
end
function modifier_flaming_cape_flames_burn:OnIntervalThink()
	if self:GetAbility() then
		local burn_damage = self.base_damage
		if self:GetCaster():HasModifier("modifier_demonic_sword") then
			burn_damage = burn_damage * (1 + (self:GetAbility():GetSpecialValueFor("up_dmg") / 100))
		end	

		ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			ability = self:GetAbility(),
			damage = burn_damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		})
	end
end
function modifier_flaming_cape_flames_burn:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.burn, false)
		ParticleManager:ReleaseParticleIndex(self.burn)
	end
end

----------------------
-- UP Radiance Aura --
----------------------
if modifier_flaming_cape_up_radiance_flames == nil then modifier_flaming_cape_up_radiance_flames = class({}) end
function modifier_flaming_cape_up_radiance_flames:IsHidden() return true end
function modifier_flaming_cape_up_radiance_flames:IsDebuff() return false end
function modifier_flaming_cape_up_radiance_flames:IsPurgable() return false end
function modifier_flaming_cape_up_radiance_flames:IsAura() return true end
function modifier_flaming_cape_up_radiance_flames:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_flaming_cape_up_radiance_flames:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_flaming_cape_up_radiance_flames:GetModifierAura() return "modifier_flaming_cape_up_radiance_flames_burn" end
function modifier_flaming_cape_up_radiance_flames:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") * 1.5 end
function modifier_flaming_cape_up_radiance_flames:OnCreated(keys)
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		if self.up_ambient == nil then
			self.up_ambient = ParticleManager:CreateParticle("particles/custom/items/flaming_cape/flaming_cape_up_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(self.up_ambient, 0, Vector(0, 0, 0))
			ParticleManager:SetParticleControl(self.up_ambient, 1, Vector(self:GetAbility():GetSpecialValueFor("aura_radius"), 1, 1))
		end
	end
end
function modifier_flaming_cape_up_radiance_flames:OnDestroy(keys)
	if self.up_ambient ~= nil then
		ParticleManager:DestroyParticle(self.up_ambient, false)
		ParticleManager:ReleaseParticleIndex(self.up_ambient)
		self.up_ambient = nil
	end
end

-----------------------------
-- UP Radiance Aura Effect --
-----------------------------
if modifier_flaming_cape_up_radiance_flames_burn == nil then modifier_flaming_cape_up_radiance_flames_burn = class({}) end
function modifier_flaming_cape_up_radiance_flames_burn:IsHidden() return false end
function modifier_flaming_cape_up_radiance_flames_burn:IsDebuff() return true end
function modifier_flaming_cape_up_radiance_flames_burn:IsPurgable() return false end
function modifier_flaming_cape_up_radiance_flames_burn:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_flaming_cape_up_radiance_flames_burn:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	self.damage_interval = self:GetAbility():GetSpecialValueFor("damage_interval")
	local lvl = self:GetCaster():GetLevel()
	local charges = 1
	if lvl > 34 then
		charges = self:GetAbility():GetCurrentCharges()
		if charges < 1 then
			charges = 1
		end	
	end		
	self.base_damage = self:GetAbility():GetSpecialValueFor("base_damage") * (1 + (self:GetAbility():GetSpecialValueFor("up_dmg") / 100)) * charges * self.damage_interval
	if IsServer() then
		self.burn = ParticleManager:CreateParticle("particles/custom/items/flaming_cape/flaming_cape_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.burn, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.burn, 1, self:GetCaster():GetAbsOrigin())
		self:StartIntervalThink(self.damage_interval)
	end
end
function modifier_flaming_cape_up_radiance_flames_burn:OnIntervalThink()
	if self:GetAbility() then
		local burn_damage = self.base_damage
		ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			ability = self:GetAbility(),
			damage = burn_damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		})
	end
end
function modifier_flaming_cape_up_radiance_flames_burn:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.burn, false)
		ParticleManager:ReleaseParticleIndex(self.burn)
	end
end
