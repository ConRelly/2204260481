-----------------
--ENERGY SHIELD--
-----------------
LinkLuaModifier("modifier_energy_shield_1", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_shield_1_shield", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_shield_shield_cd", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_shield_shield_recovery", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_shield == nil then item_energy_shield = class({}) end
function item_energy_shield:GetIntrinsicModifierName() return "modifier_energy_shield_1" end
function item_energy_shield:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	end
	return self.BaseClass.GetBehavior(self)
end
function item_energy_shield:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_energy_shield_1_shield")
	caster:RemoveModifierByName("modifier_energy_shield_shield_cd")
	caster:RemoveModifierByName("modifier_energy_shield_shield_recovery")
	caster:AddNewModifier(caster, self, "modifier_energy_shield_1_shield", {})
end
if modifier_energy_shield_1 == nil then modifier_energy_shield_1 = class({}) end
function modifier_energy_shield_1:IsHidden() return true end
function modifier_energy_shield_1:IsPurgable() return false end
function modifier_energy_shield_1:RemoveOnDeath() return false end
function modifier_energy_shield_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_shield_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local caster = self:GetCaster()
		if not caster:HasModifier("modifier_energy_shield_shield_cd") and not caster:HasModifier("modifier_energy_shield_1_shield") and not caster:HasModifier("modifier_energy_shield_2_shield") and not caster:HasModifier("modifier_energy_shield_3_shield") then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_energy_shield_1_shield", {})
		end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_energy_shield_1:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		if not caster:HasModifier("modifier_energy_shield_shield_cd") and not caster:HasModifier("modifier_energy_shield_1_shield") and not caster:HasModifier("modifier_energy_shield_2_shield") and not caster:HasModifier("modifier_energy_shield_3_shield") then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_energy_shield_1_shield", {})
		end
		if caster:HasModifier("modifier_tranquilboots") and caster:HasScepter() and caster:GetHealth() < (caster:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("threshold") / 100) and self:GetAbility():IsCooldownReady() then
			caster:FindItemInInventory("item_energy_shield"):OnSpellStart()
			self:GetAbility():UseResources(true, true, false, true)
		end
	end
end
function modifier_energy_shield_1:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_energy_shield_1_shield")
	end
end
function modifier_energy_shield_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_energy_shield_1:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_energy_shield_1:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_energy_shield_1:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
------------------------
--ENERGY SHIELD ABSORB--
------------------------
modifier_energy_shield_1_shield = modifier_energy_shield_1_shield or class({})
function modifier_energy_shield_1_shield:IsDebuff() return false end
function modifier_energy_shield_1_shield:IsHidden() return false end
function modifier_energy_shield_1_shield:IsPurgable() return false end
function modifier_energy_shield_1_shield:IsPurgeException() return false end
function modifier_energy_shield_1_shield:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() return end
		if self:GetCaster():HasModifier("modifier_energy_shield_2") and self:GetCaster():HasModifier("modifier_energy_shield_3") then return nil end
		self.shield_remaining = self:GetAbility():GetSpecialValueFor("damage_absorb")
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(self.particle, false, false, -1, false, false)
		self:SetStackCount(self.shield_remaining)
	end
end
function modifier_energy_shield_1_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end
function modifier_energy_shield_1_shield:GetModifierTotal_ConstantBlock(kv)
	if IsServer() then
		local target = self:GetParent()
		self:StartIntervalThink(FrameTime())
		if not target:HasModifier("modifier_abaddon_borrowed_time") and kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
			self.shield_remaining = self.shield_remaining - kv.damage
			if kv.damage < self.shield_remaining then
				return kv.damage
			else
				return self.shield_remaining
			end
		end
	end
end
function modifier_energy_shield_1_shield:OnStackCountChanged(old)
	if IsServer() then
		local based = self:GetAbility():GetSpecialValueFor("damage_absorb")
		local shield_recovery = self:GetAbility():GetSpecialValueFor("shield_recovery")
		if self:GetStackCount() < based then
			if self:GetStackCount() ~= old then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_recovery", {duration = shield_recovery})
			end
		end
	end
end
function modifier_energy_shield_1_shield:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(self.shield_remaining)
		if self:GetStackCount() <= 0 then
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_shield_recovery")
			local shield_cd = self:GetAbility():GetSpecialValueFor("shield_cd")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_cd", {duration = shield_cd})
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_1_shield")
		end
	end
end
function modifier_energy_shield_1_shield:OnDestroy()
	if IsServer() then
		local shield_cd = self:GetAbility():GetSpecialValueFor("shield_cd")
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_cd", {duration = shield_cd})
	end
end


------------------
--ENERGY SHIELD2--
------------------
LinkLuaModifier("modifier_energy_shield_2", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_shield_2_shield", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_shield_2 == nil then item_energy_shield_2 = class({}) end
function item_energy_shield_2:GetIntrinsicModifierName() return "modifier_energy_shield_2" end
function item_energy_shield_2:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	end
	return self.BaseClass.GetBehavior(self)
end
function item_energy_shield_2:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_energy_shield_2_shield")
	caster:RemoveModifierByName("modifier_energy_shield_shield_cd")
	caster:RemoveModifierByName("modifier_energy_shield_shield_recovery")
	caster:AddNewModifier(caster, self, "modifier_energy_shield_2_shield", {})
end
if modifier_energy_shield_2 == nil then modifier_energy_shield_2 = class({}) end
function modifier_energy_shield_2:IsHidden() return true end
function modifier_energy_shield_2:IsPurgable() return false end
function modifier_energy_shield_2:RemoveOnDeath() return false end
function modifier_energy_shield_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_shield_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local caster = self:GetCaster()
		if not caster:HasModifier("modifier_energy_shield_shield_cd") and not caster:HasModifier("modifier_energy_shield_2_shield") and not caster:HasModifier("modifier_energy_shield_3_shield") then
			caster:RemoveModifierByName("modifier_energy_shield_1_shield")
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_energy_shield_2_shield", {})
		end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_energy_shield_2:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		if not caster:HasModifier("modifier_energy_shield_shield_cd") and not caster:HasModifier("modifier_energy_shield_2_shield") and not caster:HasModifier("modifier_energy_shield_3_shield") then
			caster:RemoveModifierByName("modifier_energy_shield_1_shield")
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_energy_shield_2_shield", {})
		end
		if caster:HasModifier("modifier_tranquilboots") and caster:HasScepter() and caster:GetHealth() < (caster:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("threshold") / 100) and self:GetAbility():IsCooldownReady() then
			caster:FindItemInInventory("item_energy_shield_2"):OnSpellStart()
			self:GetAbility():UseResources(true, true, false, true)
		end
	end
end
function modifier_energy_shield_2:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_energy_shield_1_shield")
		self:GetCaster():RemoveModifierByName("modifier_energy_shield_2_shield")
	end
end
function modifier_energy_shield_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_energy_shield_2:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_energy_shield_2:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_energy_shield_2:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
-------------------------
--ENERGY SHIELD2 ABSORB--
-------------------------
modifier_energy_shield_2_shield = modifier_energy_shield_2_shield or class({})
function modifier_energy_shield_2_shield:IsDebuff() return false end
function modifier_energy_shield_2_shield:IsHidden() return false end
function modifier_energy_shield_2_shield:IsPurgable() return false end
function modifier_energy_shield_2_shield:IsPurgeException() return false end
function modifier_energy_shield_2_shield:OnCreated(params)
	if IsServer() then
		if not self:GetAbility() then self:Destroy() return end
		if self:GetCaster():HasModifier("modifier_energy_shield_3") then return nil end
		self.shield_remaining = self:GetAbility():GetSpecialValueFor("damage_absorb")
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(self.particle, false, false, -1, false, false)
		self:SetStackCount(self.shield_remaining)
	end
end
function modifier_energy_shield_2_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end
function modifier_energy_shield_2_shield:GetModifierTotal_ConstantBlock(kv)
	if IsServer() then
		local target = self:GetParent()
		self:StartIntervalThink(FrameTime())
		if not target:HasModifier("modifier_abaddon_borrowed_time") and kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
			self.shield_remaining = self.shield_remaining - kv.damage
			if kv.damage < self.shield_remaining then
				return kv.damage
			else
				return self.shield_remaining
			end
		end
	end
end
function modifier_energy_shield_2_shield:OnStackCountChanged(old)
	if IsServer() then
		local based = self:GetAbility():GetSpecialValueFor("damage_absorb")
		local shield_recovery = self:GetAbility():GetSpecialValueFor("shield_recovery")
		if self:GetStackCount() < based then
			if self:GetStackCount() ~= old then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_recovery", {duration = shield_recovery})
			end
		end
	end
end
function modifier_energy_shield_2_shield:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(self.shield_remaining)
		if self:GetStackCount() <= 0 then
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_shield_recovery")
			local shield_cd = self:GetAbility():GetSpecialValueFor("shield_cd")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_cd", {duration = shield_cd})
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_2_shield")
		end
	end
end
function modifier_energy_shield_2_shield:OnDestroy()
	if IsServer() then
		local shield_cd = self:GetAbility():GetSpecialValueFor("shield_cd")
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_cd", {duration = shield_cd})
	end
end


------------------
--ENERGY SHIELD3--
------------------
LinkLuaModifier("modifier_energy_shield_3", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_shield_3_shield", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
if item_energy_shield_3 == nil then item_energy_shield_3 = class({}) end
function item_energy_shield_3:GetIntrinsicModifierName() return "modifier_energy_shield_3" end
function item_energy_shield_3:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	end
	return self.BaseClass.GetBehavior(self)
end
function item_energy_shield_3:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_energy_shield_3_shield")
	caster:RemoveModifierByName("modifier_energy_shield_shield_cd")
	caster:RemoveModifierByName("modifier_energy_shield_shield_recovery")
	caster:AddNewModifier(caster, self, "modifier_energy_shield_3_shield", {})
end
if modifier_energy_shield_3 == nil then modifier_energy_shield_3 = class({}) end
function modifier_energy_shield_3:IsHidden() return true end
function modifier_energy_shield_3:IsPurgable() return false end
function modifier_energy_shield_3:RemoveOnDeath() return false end
function modifier_energy_shield_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_shield_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local caster = self:GetCaster()
		if not caster:HasModifier("modifier_energy_shield_shield_cd") and not caster:HasModifier("modifier_energy_shield_3_shield") then
			caster:RemoveModifierByName("modifier_energy_shield_1_shield")
			caster:RemoveModifierByName("modifier_energy_shield_2_shield")
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_energy_shield_3_shield", {})
		end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_energy_shield_3:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		if not caster:HasModifier("modifier_energy_shield_shield_cd") and not caster:HasModifier("modifier_energy_shield_3_shield") then
			caster:RemoveModifierByName("modifier_energy_shield_1_shield")
			caster:RemoveModifierByName("modifier_energy_shield_2_shield")
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_energy_shield_3_shield", {})
		end
		if caster:HasModifier("modifier_tranquilboots") and caster:HasScepter() and caster:GetHealth() < (caster:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("threshold") / 100) and self:GetAbility():IsCooldownReady() then
			caster:FindItemInInventory("item_energy_shield_3"):OnSpellStart()
			self:GetAbility():UseResources(true, true, false, true)
		end
	end
end
function modifier_energy_shield_3:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_energy_shield_1_shield")
		self:GetCaster():RemoveModifierByName("modifier_energy_shield_2_shield")
		self:GetCaster():RemoveModifierByName("modifier_energy_shield_3_shield")
	end
end
function modifier_energy_shield_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_energy_shield_3:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_energy_shield_3:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_energy_shield_3:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
-------------------------
--ENERGY SHIELD3 ABSORB--
-------------------------
modifier_energy_shield_3_shield = modifier_energy_shield_3_shield or class({})
function modifier_energy_shield_3_shield:IsDebuff() return false end
function modifier_energy_shield_3_shield:IsHidden() return false end
function modifier_energy_shield_3_shield:IsPurgable() return false end
function modifier_energy_shield_3_shield:IsPurgeException() return false end
function modifier_energy_shield_3_shield:OnCreated(params)
	if IsServer() then
		if not self:GetAbility() then self:Destroy() return end
		self.shield_remaining = self:GetAbility():GetSpecialValueFor("damage_absorb")
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(self.particle, false, false, -1, false, false)
		self:SetStackCount(self.shield_remaining)
	end
end
function modifier_energy_shield_3_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end
function modifier_energy_shield_3_shield:GetModifierTotal_ConstantBlock(kv)
	if IsServer() then
		local target = self:GetParent()
		self:StartIntervalThink(FrameTime())
		if not target:HasModifier("modifier_abaddon_borrowed_time") and kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
			self.shield_remaining = self.shield_remaining - kv.damage
			if kv.damage < self.shield_remaining then
				return kv.damage
			else
				return self.shield_remaining
			end
		end
	end
end
function modifier_energy_shield_3_shield:OnStackCountChanged(old)
	if IsServer() then
		local based = self:GetAbility():GetSpecialValueFor("damage_absorb")
		local shield_recovery = self:GetAbility():GetSpecialValueFor("shield_recovery")
		if self:GetStackCount() < based then
			if self:GetStackCount() ~= old then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_recovery", {duration = shield_recovery})
			end
		end
	end
end
function modifier_energy_shield_3_shield:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(self.shield_remaining)
		if self:GetStackCount() <= 0 then
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_shield_recovery")
			local shield_cd = self:GetAbility():GetSpecialValueFor("shield_cd")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_cd", {duration = shield_cd})
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_3_shield")
		end
	end
end
function modifier_energy_shield_3_shield:OnDestroy()
	if IsServer() then
		local shield_cd = self:GetAbility():GetSpecialValueFor("shield_cd")
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_shield_cd", {duration = shield_cd})
	end
end



--Modifier Shield CD
modifier_energy_shield_shield_cd = modifier_energy_shield_shield_cd or class({})
function modifier_energy_shield_shield_cd:IsDebuff() return true end
function modifier_energy_shield_shield_cd:IsHidden() return false end
function modifier_energy_shield_shield_cd:IsPurgable() return false end
--Modifier Shield Recovery
modifier_energy_shield_shield_recovery = modifier_energy_shield_shield_recovery or class({})
function modifier_energy_shield_shield_recovery:IsDebuff() return false end
function modifier_energy_shield_shield_recovery:IsHidden() return false end
function modifier_energy_shield_shield_recovery:IsPurgable() return false end
function modifier_energy_shield_shield_recovery:OnDestroy()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_energy_shield_1") then
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_1_shield")
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_shield_cd")
			if not self:GetCaster():HasModifier("modifier_energy_shield_shield_cd") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_1_shield", {})
			end
		elseif self:GetCaster():HasModifier("modifier_energy_shield_2") then
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_2_shield")
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_shield_cd")
			if not self:GetCaster():HasModifier("modifier_energy_shield_shield_cd") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_2_shield", {})
			end
		elseif self:GetCaster():HasModifier("modifier_energy_shield_3") then
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_3_shield")
			self:GetCaster():RemoveModifierByName("modifier_energy_shield_shield_cd")
			if not self:GetCaster():HasModifier("modifier_energy_shield_shield_cd") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_energy_shield_3_shield", {})
			end
		end
	end
end


--with linken's sphere
-----------------
--ENERGY SPHERE--
-----------------
LinkLuaModifier("modifier_energy_sphere", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_energy_sphere_mana_shield", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
item_energy_sphere = class({})
modifier_energy_sphere = class({})
modifier_energy_sphere_mana_shield = class({})
function item_energy_sphere:ProcsMagicStick() return false end
function item_energy_sphere:GetIntrinsicModifierName() return "modifier_energy_sphere" end
function item_energy_sphere:OnOwnerSpawned() if self.toggle_state then self:ToggleAbility() end end
function item_energy_sphere:OnOwnerDied() self.toggle_state = self:GetToggleState() end
function item_energy_sphere:OnToggle()
	if not IsServer() then return end
	if self:GetToggleState() then
		self:GetCaster():EmitSound("Hero_Medusa.ManaShield.On")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_energy_sphere_mana_shield", {})
	else
		self:GetCaster():EmitSound("Hero_Medusa.ManaShield.Off")
		self:GetCaster():RemoveModifierByNameAndCaster("modifier_energy_sphere_mana_shield", self:GetCaster())
	end
end

function modifier_energy_sphere:IsHidden() return true end
function modifier_energy_sphere:IsPurgable() return false end
function modifier_energy_sphere:RemoveOnDeath() return false end
function modifier_energy_sphere:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_energy_sphere:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_energy_sphere:GetModifierTotalPercentageManaRegen()
	if self:GetAbility() then
		mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen_percentage")
		if self:GetCaster():HasModifier("modifier_energy_sphere_mana_shield") then
			mana_regen = 0
		else
			mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen_percentage")
		end
		return mana_regen
	end
end
function modifier_energy_sphere:GetModifierBonusStats_Strength() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all") end end
function modifier_energy_sphere:GetModifierBonusStats_Agility() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all") end end
function modifier_energy_sphere:GetModifierBonusStats_Intellect() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all") end end
function modifier_energy_sphere:GetModifierConstantHealthRegen() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("regen") end end

--------------------------
-- MANA SHIELD MODIFIER --
--------------------------
function modifier_energy_sphere_mana_shield:GetEffectName() return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf" end
function modifier_energy_sphere_mana_shield:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_energy_sphere_mana_shield:IsPurgable() return false end
function modifier_energy_sphere_mana_shield:RemoveOnDeath() return false end
function modifier_energy_sphere_mana_shield:OnCreated()
	if not IsServer() then return end
	if not self:GetAbility() then self:Destroy() return end
	self.damage_per_mana = self:GetAbility():GetSpecialValueFor("damage_per_mana")
	self.absorb_pct = self:GetAbility():GetSpecialValueFor("absorb_pct")
	self.mana_raw = self:GetParent():GetMana()
	self.mana_pct = self:GetParent():GetManaPercent()
end
function modifier_energy_sphere_mana_shield:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end
function modifier_energy_sphere_mana_shield:GetModifierIncomingDamage_Percentage(keys)
	if not IsServer() then return end
	if not (keys.damage_type == DAMAGE_TYPE_MAGICAL and self:GetParent():IsMagicImmune()) and self:GetParent().GetMana and not self:GetParent():HasModifier("modifier_abaddon_borrowed_time") then
		local mana_to_block	= keys.original_damage * self.absorb_pct * 0.01 / self.damage_per_mana
		if mana_to_block >= self:GetParent():GetMana() then
			self:GetParent():EmitSound("Hero_Medusa.ManaShield.Proc")
			local shield_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:ReleaseParticleIndex(shield_particle)
		end
		local mana_before = self:GetParent():GetMana()
		self:GetParent():Script_ReduceMana(mana_to_block, nil)
		local mana_after = self:GetParent():GetMana()
		return math.min(self.absorb_pct, self.absorb_pct * self:GetParent():GetMana() / math.max(mana_to_block, 1)) * (-1)
	end
end














----------------
--LUNAR SHIELD--
----------------
LinkLuaModifier("modifier_lunar_shield", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lunar_shield_absorb", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lunar_shield_cd", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lunar_recovery", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lunar_shield_check", "items/energy_shield.lua", LUA_MODIFIER_MOTION_NONE)
if item_lunar_shield == nil then item_lunar_shield = class({}) end
function item_lunar_shield:GetIntrinsicModifierName() return "modifier_lunar_shield" end
function item_lunar_shield:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	end
	return self.BaseClass.GetBehavior(self)
end
function item_lunar_shield:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_lunar_shield_absorb")
	caster:RemoveModifierByName("modifier_lunar_shield_cd")
	caster:RemoveModifierByName("modifier_lunar_recovery")
	caster:AddNewModifier(caster, self, "modifier_lunar_shield_absorb", {})
end
if modifier_lunar_shield == nil then modifier_lunar_shield = class({}) end
function modifier_lunar_shield:IsHidden() return true end
function modifier_lunar_shield:IsPurgable() return false end
function modifier_lunar_shield:RemoveOnDeath() return false end
function modifier_lunar_shield:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lunar_shield:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() self:GetCaster():SetMaxHealth(self:GetCaster():GetBaseMaxHealth()) self:GetCaster():Heal(self:GetCaster():GetBaseMaxHealth(), self:GetCaster()) end
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_lunar_shield_check", {})
		self:StartIntervalThink(0.15)
		if not caster:HasModifier("modifier_lunar_shield_cd") and not caster:HasModifier("modifier_lunar_shield_absorb") then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_lunar_shield_absorb", {})
		end
	end
end
function modifier_lunar_shield:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		if not caster:HasModifier("modifier_lunar_shield_cd") and not caster:HasModifier("modifier_lunar_shield_absorb") then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_lunar_shield_absorb", {})
		end
		if caster:HasModifier("modifier_tranquilboots") and caster:HasScepter() and caster:GetHealth() < (caster:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("threshold") / 100) and self:GetAbility():IsCooldownReady() then
			caster:FindItemInInventory("item_lunar_shield"):OnSpellStart()
			self:GetAbility():UseResources(true, true, false, true)
		end

--[[ 		for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
			local item = self:GetParent():GetItemInSlot(i)
			if item then
				if item:GetAbilityName() == "item_lunar_shield" then
					item:SetSellable(false)
					--item:SetDroppable(false)
				end
			end
		end ]]
	end
end
function modifier_lunar_shield:OnDestroy()
	if IsServer() then
		self:GetCaster():SetMaxHealth(self:GetCaster():GetBaseMaxHealth())
		self:GetCaster():Heal(self:GetCaster():GetBaseMaxHealth(), self:GetCaster())
		self:GetCaster():RemoveModifierByName("modifier_lunar_shield_absorb")
	end
end
function modifier_lunar_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end
function modifier_lunar_shield:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_lunar_shield:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_lunar_shield:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_lunar_shield:GetModifierIncomingDamage_Percentage()
	if not self:GetParent():HasModifier("modifier_lunar_shield_absorb") then
		return self:GetAbility():GetSpecialValueFor("inc_dmg")
	end
	return 0
end
function modifier_lunar_shield:GetModifierExtraHealthPercentage()
	if self:GetAbility() then
		if self:GetCaster():HasModifier("modifier_lier_scarlet_t") or self:GetCaster():HasModifier("modifier_lier_scarlet_m") or self:GetCaster():HasModifier("modifier_lier_scarlet_b") then
			return (self:GetAbility():GetSpecialValueFor("hp_red_pct") / 2) * (-1)
		end
		return self:GetAbility():GetSpecialValueFor("hp_red_pct") * (-1)
	end
end
-----------------------
--LUNAR SHIELD ABSORB--
-----------------------
modifier_lunar_shield_absorb = modifier_lunar_shield_absorb or class({})
function modifier_lunar_shield_absorb:IsDebuff() return false end
function modifier_lunar_shield_absorb:IsHidden() return false end
function modifier_lunar_shield_absorb:IsPurgable() return false end
function modifier_lunar_shield_absorb:IsPurgeException() return false end
function modifier_lunar_shield_absorb:OnCreated(params)
	if IsServer() then
		if not self:GetAbility() then self:Destroy() return end
		local caster = self:GetCaster()
		local shield_durability = self:GetAbility():GetSpecialValueFor("shield_durability")
		local calculation = (self:GetParent():GetMaxHealth()) * (shield_durability / 100)
		self.shields_left = calculation
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(self.particle, false, false, -1, false, false)
		self:SetStackCount(self.shields_left)
	end
end
function modifier_lunar_shield_absorb:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end
function modifier_lunar_shield_absorb:GetModifierTotal_ConstantBlock(kv)
	if IsServer() then
		local target = self:GetParent()
		self:StartIntervalThink(FrameTime())
		if kv.damage >= 0 then
			self.shields_left = self.shields_left - kv.damage
			if kv.damage < self.shields_left then
				return kv.damage
			else
				return self.shields_left
			end
		end
	end
end
function modifier_lunar_shield_absorb:OnStackCountChanged(old)
	if IsServer() then
		local caster = self:GetCaster()
		local shield_durability = self:GetAbility():GetSpecialValueFor("shield_durability")
		local calculation = (self:GetParent():GetMaxHealth()) * (shield_durability / 100)
		local shield_recovery = self:GetAbility():GetSpecialValueFor("shield_recovery")
		if self:GetStackCount() == calculation then return end
		if self:GetStackCount() < calculation then
			if self:GetStackCount() ~= old then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lunar_recovery", {duration = shield_recovery})
			end
		end
	end
end
function modifier_lunar_shield_absorb:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() > self.shields_left then
			local shield_recovery = self:GetAbility():GetSpecialValueFor("shield_recovery")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lunar_recovery", {duration = shield_recovery})
		end
		self:SetStackCount(self.shields_left)
		if self:GetStackCount() <= 0 then
			self:GetCaster():RemoveModifierByName("modifier_lunar_recovery")
			local shield_cd = self:GetAbility():GetSpecialValueFor("shield_cd")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lunar_shield_cd", {duration = shield_cd})
			self:GetCaster():RemoveModifierByName("modifier_lunar_shield_absorb")
		end
	end
end
function modifier_lunar_shield_absorb:OnDestroy()
	if IsServer() then
		local shield_cd = self:GetAbility():GetSpecialValueFor("shield_cd")
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lunar_shield_cd", {duration = shield_cd})
	end
end

--Modifier Shield Check
modifier_lunar_shield_check = modifier_lunar_shield_check or class({})
function modifier_lunar_shield_check:IsHidden() return true end
function modifier_lunar_shield_check:IsPurgable() return false end
function modifier_lunar_shield_check:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() return end
		self.old = nil
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_lunar_shield_check:OnIntervalThink()
	if IsServer() then
		local ability = self:GetParent():FindModifierByName("modifier_lunar_shield_absorb")
		local stacks = ability:GetStackCount()
		local shield_durability = self:GetAbility():GetSpecialValueFor("shield_durability")
		local calculation = (self:GetParent():GetMaxHealth()) * (shield_durability / 100)
			if self.old ~= nil and stacks ~= calculation and not self:GetParent():HasModifier("modifier_lunar_recovery") then
				local shield_recovery = self:GetAbility():GetSpecialValueFor("shield_recovery")
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lunar_recovery", {duration = shield_recovery})
			end
		self.old = stacks
	end
end
--Modifier Shield CD
modifier_lunar_shield_cd = modifier_lunar_shield_cd or class({})
function modifier_lunar_shield_cd:IsDebuff() return true end
function modifier_lunar_shield_cd:IsHidden() return false end
function modifier_lunar_shield_cd:IsPurgable() return false end
--Modifier Shield Recovery
modifier_lunar_recovery = modifier_lunar_recovery or class({})
function modifier_lunar_recovery:IsDebuff() return false end
function modifier_lunar_recovery:IsHidden() return false end
function modifier_lunar_recovery:IsPurgable() return false end
function modifier_lunar_recovery:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_lunar_shield_absorb")
		self:GetCaster():RemoveModifierByName("modifier_lunar_shield_cd")
		if not self:GetCaster():HasModifier("modifier_lunar_shield_cd") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lunar_shield_absorb", {})
		end
	end
end