--------------------
-- Soul Bind Aura --
--------------------
LinkLuaModifier("modifier_soul_bind_aura", "abilities/soul_bind_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_bind_aura_binded", "abilities/soul_bind_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_bind_aura_dead", "abilities/soul_bind_aura.lua", LUA_MODIFIER_MOTION_NONE)
if soul_bind_aura == nil then soul_bind_aura = class({}) end
function soul_bind_aura:GetIntrinsicModifierName() return "modifier_soul_bind_aura" end

if modifier_soul_bind_aura == nil then modifier_soul_bind_aura = class({}) end
function modifier_soul_bind_aura:IsHidden() return true end
function modifier_soul_bind_aura:IsPurgable() return false end
function modifier_soul_bind_aura:RemoveOnDeath() return false end
function modifier_soul_bind_aura:OnCreated()
	if not self:GetAbility() then self:Destroy() end
	soul_bind_fx = "particles/custom/abilities/soul_bind/soul_bind_ambient.vpcf"
	self.soul_bind_amb = ParticleManager:CreateParticle(soul_bind_fx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.soul_bind_amb, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.soul_bind_amb, false, false, -1, false, false)
end
function modifier_soul_bind_aura:OnDestroy()
	ParticleManager:DestroyParticle(self.soul_bind_amb, false)
	ParticleManager:ReleaseParticleIndex(self.soul_bind_amb)
end
function modifier_soul_bind_aura:IsAura() return true end
function modifier_soul_bind_aura:IsAuraActiveOnDeath() return false end
function modifier_soul_bind_aura:GetAuraRadius() return FIND_UNITS_EVERYWHERE end
function modifier_soul_bind_aura:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_soul_bind_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_soul_bind_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_soul_bind_aura:GetAuraDuration() return FrameTime() end
function modifier_soul_bind_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_soul_bind_aura:GetModifierAura() return "modifier_soul_bind_aura_binded" end
function modifier_soul_bind_aura:GetAuraEntityReject(hEntity)
	if hEntity == self:GetCaster() or not hEntity:HasModifier("modifier_soul_bind_aura") then return true end
	return false
end
------------
-- Binded --
------------
if modifier_soul_bind_aura_binded == nil then modifier_soul_bind_aura_binded = class({}) end
function modifier_soul_bind_aura_binded:IsHidden() return false end
function modifier_soul_bind_aura_binded:IsDebuff() return false end
function modifier_soul_bind_aura_binded:IsPurgable() return false end
function modifier_soul_bind_aura_binded:RemoveOnDeath() return true end
function modifier_soul_bind_aura_binded:OnCreated()
	self.duration = self:GetAbility():GetSpecialValueFor("death_duration")
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
	self:Chain_fx(true)
end
function modifier_soul_bind_aura_binded:OnIntervalThink()
	if IsServer() then
		if self:GetParent():GetHealth() <= 50 and not self:GetParent():HasModifier("modifier_soul_bind_aura_dead") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_soul_bind_aura_dead", {duration = self.duration})
		end
		if self:GetCaster():HasModifier("modifier_soul_bind_aura_dead") and self:GetParent():HasModifier("modifier_soul_bind_aura_dead") then
			self:Chain_fx(false)
			self:GetCaster():RemoveModifierByName("modifier_soul_bind_aura")
			self:GetParent():RemoveModifierByName("modifier_soul_bind_aura")
			self:GetCaster():RemoveModifierByName("modifier_soul_bind_aura_binded")
			self:GetParent():RemoveModifierByName("modifier_soul_bind_aura_binded")
			self:GetCaster():RemoveModifierByName("modifier_soul_bind_aura_dead")
			self:GetParent():RemoveModifierByName("modifier_soul_bind_aura_dead")
			self:GetCaster():ForceKill(false)
			self:GetParent():ForceKill(false)
		end
	end
end
function modifier_soul_bind_aura_binded:DeclareFunctions() return {MODIFIER_PROPERTY_MIN_HEALTH} end
function modifier_soul_bind_aura_binded:GetMinHealth() if self:GetAbility() then return 1 end end
function modifier_soul_bind_aura_binded:Chain_fx(ally)
	if ally then
		local soul_bind = "particles/custom/abilities/soul_bind/soul_bind_chain.vpcf"
		self.soul_bind_chain = ParticleManager:CreateParticle(soul_bind, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.soul_bind_chain, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.soul_bind_chain, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	else
		ParticleManager:DestroyParticle(self.soul_bind_chain, false)
		ParticleManager:ReleaseParticleIndex(self.soul_bind_chain)
	end
end
function modifier_soul_bind_aura_binded:OnDestroy()
	ParticleManager:DestroyParticle(self.soul_bind_chain, false)
	ParticleManager:ReleaseParticleIndex(self.soul_bind_chain)
end
------------------
-- Binded Death --
------------------
if modifier_soul_bind_aura_dead == nil then modifier_soul_bind_aura_dead = class({}) end
function modifier_soul_bind_aura_dead:IsHidden() return false end
function modifier_soul_bind_aura_dead:IsDebuff() return false end
function modifier_soul_bind_aura_dead:IsPurgable() return false end
function modifier_soul_bind_aura_dead:RemoveOnDeath() return true end
function modifier_soul_bind_aura_dead:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_soul_bind_aura_dead:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return -100 end
end
function modifier_soul_bind_aura_dead:OnDestroy()
	local heal_fx = "particles/custom/abilities/soul_bind/soul_bind_heal.vpcf"
	self.soul_bind_heal = ParticleManager:CreateParticle(heal_fx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.soul_bind_heal, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.soul_bind_heal, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(self.soul_bind_heal)
	if IsServer() then
		local endcap_heal = self:GetAbility():GetSpecialValueFor("endcap_heal")
		self:GetParent():SetHealth(self:GetParent():GetMaxHealth() * endcap_heal / 100)
	end
end
function modifier_soul_bind_aura_dead:CheckState()
	return {[MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_STUNNED] = true}
end











------------------------
-- Soul Bind RED Aura --
------------------------
LinkLuaModifier("modifier_soul_bind_red_aura", "abilities/soul_bind_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_bind_red_aura_binded", "abilities/soul_bind_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_bind_red_aura_dead", "abilities/soul_bind_aura.lua", LUA_MODIFIER_MOTION_NONE)
if soul_bind_red_aura == nil then soul_bind_red_aura = class({}) end
function soul_bind_red_aura:GetIntrinsicModifierName() return "modifier_soul_bind_red_aura" end

if modifier_soul_bind_red_aura == nil then modifier_soul_bind_red_aura = class({}) end
function modifier_soul_bind_red_aura:IsHidden() return true end
function modifier_soul_bind_red_aura:IsPurgable() return false end
function modifier_soul_bind_red_aura:RemoveOnDeath() return false end
function modifier_soul_bind_red_aura:OnCreated()
	if not self:GetAbility() then self:Destroy() end
	soul_bind_fx = "particles/custom/abilities/soul_bind/soul_bind_red_ambient.vpcf"
	self.soul_bind_amb = ParticleManager:CreateParticle(soul_bind_fx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.soul_bind_amb, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.soul_bind_amb, false, false, -1, false, false)
end
function modifier_soul_bind_red_aura:OnDestroy()
	ParticleManager:DestroyParticle(self.soul_bind_amb, false)
	ParticleManager:ReleaseParticleIndex(self.soul_bind_amb)
end
function modifier_soul_bind_red_aura:IsAura() return true end
function modifier_soul_bind_red_aura:IsAuraActiveOnDeath() return false end
function modifier_soul_bind_red_aura:GetAuraRadius() return FIND_UNITS_EVERYWHERE end
function modifier_soul_bind_red_aura:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_soul_bind_red_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_soul_bind_red_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_soul_bind_red_aura:GetAuraDuration() return FrameTime() end
function modifier_soul_bind_red_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_soul_bind_red_aura:GetModifierAura() return "modifier_soul_bind_red_aura_binded" end

function modifier_soul_bind_red_aura:GetAuraEntityReject(hEntity)
	if hEntity == self:GetCaster() or not hEntity:HasModifier("modifier_soul_bind_red_aura") then return true end
	return false
end
----------------
-- Binded RED --
----------------
if modifier_soul_bind_red_aura_binded == nil then modifier_soul_bind_red_aura_binded = class({}) end
function modifier_soul_bind_red_aura_binded:IsHidden() return false end
function modifier_soul_bind_red_aura_binded:IsDebuff() return false end
function modifier_soul_bind_red_aura_binded:IsPurgable() return false end
function modifier_soul_bind_red_aura_binded:RemoveOnDeath() return true end
function modifier_soul_bind_red_aura_binded:OnCreated()
	self.duration2 = self:GetAbility():GetSpecialValueFor("death_duration")
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
	self:Chain_fx(true)
end
function modifier_soul_bind_red_aura_binded:OnIntervalThink()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		if self:GetParent():GetHealth() <= 50 and not self:GetParent():HasModifier("modifier_soul_bind_red_aura_dead") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_soul_bind_red_aura_dead", {duration = self.duration2})
		end
		if self:GetCaster():HasModifier("modifier_soul_bind_red_aura_dead") and self:GetParent():HasModifier("modifier_soul_bind_red_aura_dead") then
			self:Chain_fx(false)
			self:GetCaster():RemoveModifierByName("modifier_soul_bind_red_aura")
			self:GetParent():RemoveModifierByName("modifier_soul_bind_red_aura")
			self:GetCaster():RemoveModifierByName("modifier_soul_bind_red_aura_binded")
			self:GetParent():RemoveModifierByName("modifier_soul_bind_red_aura_binded")
			self:GetCaster():RemoveModifierByName("modifier_soul_bind_red_aura_dead")
			self:GetParent():RemoveModifierByName("modifier_soul_bind_red_aura_dead")
			self:GetCaster():ForceKill(false)
			self:GetParent():ForceKill(false)
		end
	end
end
function modifier_soul_bind_red_aura_binded:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MIN_HEALTH} end
function modifier_soul_bind_red_aura_binded:GetModifierIncomingDamage_Percentage(keys)
	if self:GetAbility() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local attacker = keys.attacker
		if caster:IsRangedAttacker() then
			if attacker:IsRangedAttacker() then
				return 10
			else
				return -50
			end
		else
			if attacker:IsRangedAttacker() then
				return -50
			else
				return 10
			end
		end
	end
end
function modifier_soul_bind_red_aura_binded:GetMinHealth() if self:GetAbility() then return 1 end end
function modifier_soul_bind_red_aura_binded:Chain_fx(ally)
	if ally then
		local soul_bind = "particles/custom/abilities/soul_bind/soul_bind_red_chain.vpcf"
		self.soul_bind_chain = ParticleManager:CreateParticle(soul_bind, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.soul_bind_chain, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.soul_bind_chain, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	else
		ParticleManager:DestroyParticle(self.soul_bind_chain, false)
		ParticleManager:ReleaseParticleIndex(self.soul_bind_chain)
	end
end
function modifier_soul_bind_red_aura_binded:OnDestroy()
	ParticleManager:DestroyParticle(self.soul_bind_chain, false)
	ParticleManager:ReleaseParticleIndex(self.soul_bind_chain)
end
----------------------
-- Binded RED Death --
----------------------
if modifier_soul_bind_red_aura_dead == nil then modifier_soul_bind_red_aura_dead = class({}) end
function modifier_soul_bind_red_aura_dead:IsHidden() return false end
function modifier_soul_bind_red_aura_dead:IsDebuff() return false end
function modifier_soul_bind_red_aura_dead:IsPurgable() return false end
function modifier_soul_bind_red_aura_dead:RemoveOnDeath() return true end
function modifier_soul_bind_red_aura_dead:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_soul_bind_red_aura_dead:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_soul_bind_red_aura_dead:GetModifierIncomingDamage_Percentage() if self:GetAbility() then return -100 end end
function modifier_soul_bind_red_aura_dead:OnDestroy()
	local heal_fx = "particles/custom/abilities/soul_bind/soul_bind_red_heal.vpcf"
	self.soul_bind_heal = ParticleManager:CreateParticle(heal_fx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.soul_bind_heal, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.soul_bind_heal, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(self.soul_bind_heal)
	if IsServer() then
		local endcap_heal = self:GetAbility():GetSpecialValueFor("endcap_heal")
		self:GetParent():SetHealth(self:GetParent():GetMaxHealth() * endcap_heal / 100)
	end
end
function modifier_soul_bind_red_aura_dead:CheckState()
	return {[MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_STUNNED] = true}
end
