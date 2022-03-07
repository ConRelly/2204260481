---------------
--RING OF ICE--
---------------
LinkLuaModifier("modifier_ring_of_ice_1", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ring_of_ice_1_aura", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
if item_ring_of_ice == nil then item_ring_of_ice = class({}) end
function item_ring_of_ice:GetIntrinsicModifierName() return "modifier_ring_of_ice_1" end

if modifier_ring_of_ice_1 == nil then modifier_ring_of_ice_1 = class({}) end
function modifier_ring_of_ice_1:IsHidden() return true end
function modifier_ring_of_ice_1:IsPurgable() return false end
function modifier_ring_of_ice_1:RemoveOnDeath() return false end
function modifier_ring_of_ice_1:IsAura() return true end
function modifier_ring_of_ice_1:IsAuraActiveOnDeath() return false end
function modifier_ring_of_ice_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_ring_of_ice_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_ring_of_ice_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_ring_of_ice_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ring_of_ice_1:GetAuraDuration() return FrameTime() end
function modifier_ring_of_ice_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_ring_of_ice_1:GetModifierAura() return "modifier_ring_of_ice_1_aura" end
--------------------
--RING OF ICE AURA--
--------------------
if modifier_ring_of_ice_1_aura == nil then modifier_ring_of_ice_1_aura = class({}) end
function modifier_ring_of_ice_1_aura:IsHidden() return false end
function modifier_ring_of_ice_1_aura:IsDebuff() return false end
function modifier_ring_of_ice_1_aura:IsPurgable() return false end
function modifier_ring_of_ice_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ring_of_ice_1_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_ring_of_ice_1_aura:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_aura") end
end
function modifier_ring_of_ice_1_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_aura") end
end
function modifier_ring_of_ice_1_aura:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_resist_aura") end
end

----------------
--RING OF ICE2--
----------------
LinkLuaModifier("modifier_ring_of_ice_2", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ring_of_ice_2_aura", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
if item_ring_of_ice_2 == nil then item_ring_of_ice_2 = class({}) end
function item_ring_of_ice_2:GetIntrinsicModifierName() return "modifier_ring_of_ice_2" end

if modifier_ring_of_ice_2 == nil then modifier_ring_of_ice_2 = class({}) end
function modifier_ring_of_ice_2:IsHidden() return true end
function modifier_ring_of_ice_2:IsPurgable() return false end
function modifier_ring_of_ice_2:RemoveOnDeath() return false end
function modifier_ring_of_ice_2:IsAura() return true end
function modifier_ring_of_ice_2:IsAuraActiveOnDeath() return false end
function modifier_ring_of_ice_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_ring_of_ice_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_ring_of_ice_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_ring_of_ice_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ring_of_ice_2:GetAuraDuration() return FrameTime() end
function modifier_ring_of_ice_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_ring_of_ice_2:GetModifierAura() return "modifier_ring_of_ice_2_aura" end
---------------------
--RING OF ICE2 AURA--
---------------------
if modifier_ring_of_ice_2_aura == nil then modifier_ring_of_ice_2_aura = class({}) end
function modifier_ring_of_ice_2_aura:IsHidden() return false end
function modifier_ring_of_ice_2_aura:IsDebuff() return false end
function modifier_ring_of_ice_2_aura:IsPurgable() return false end
function modifier_ring_of_ice_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ring_of_ice_2_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_ring_of_ice_2_aura:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_aura") end
end
function modifier_ring_of_ice_2_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_aura") end
end
function modifier_ring_of_ice_2_aura:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_resist_aura") end
end

----------------
--RING OF ICE3--
----------------
LinkLuaModifier("modifier_ring_of_ice_3", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ring_of_ice_3_aura", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
if item_ring_of_ice_3 == nil then item_ring_of_ice_3 = class({}) end
function item_ring_of_ice_3:GetIntrinsicModifierName() return "modifier_ring_of_ice_3" end

if modifier_ring_of_ice_3 == nil then modifier_ring_of_ice_3 = class({}) end
function modifier_ring_of_ice_3:IsHidden() return true end
function modifier_ring_of_ice_3:IsPurgable() return false end
function modifier_ring_of_ice_3:RemoveOnDeath() return false end
function modifier_ring_of_ice_3:IsAura() return true end
function modifier_ring_of_ice_3:IsAuraActiveOnDeath() return false end
function modifier_ring_of_ice_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_ring_of_ice_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_ring_of_ice_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_ring_of_ice_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ring_of_ice_3:GetAuraDuration() return FrameTime() end
function modifier_ring_of_ice_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_ring_of_ice_3:GetModifierAura() return "modifier_ring_of_ice_3_aura" end
---------------------
--RING OF ICE3 AURA--
---------------------
if modifier_ring_of_ice_3_aura == nil then modifier_ring_of_ice_3_aura = class({}) end
function modifier_ring_of_ice_3_aura:IsHidden() return false end
function modifier_ring_of_ice_3_aura:IsDebuff() return false end
function modifier_ring_of_ice_3_aura:IsPurgable() return false end
function modifier_ring_of_ice_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ring_of_ice_3_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_ring_of_ice_3_aura:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_aura") end
end
function modifier_ring_of_ice_3_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_aura") end
end
function modifier_ring_of_ice_3_aura:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_resist_aura") end
end


-----------------
--PIPE OF DEZUN--
-----------------
LinkLuaModifier("modifier_pipe_of_dezun", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pipe_of_dezun_magic_immune_aura", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pipe_of_dezun_magic_immune_buff", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pipe_of_dezun_aura", "items/ring_of_ice.lua", LUA_MODIFIER_MOTION_NONE)
if item_pipe_of_dezun == nil then item_pipe_of_dezun = class({}) end
function item_pipe_of_dezun:GetIntrinsicModifierName() return "modifier_pipe_of_dezun" end
function item_pipe_of_dezun:IsMuted()
	if not IsServer() then return end
	if IsValidEntity(self:GetParent()) and self:GetParent():IsRealHero() then
		return false
	end
	return true
end
function item_pipe_of_dezun:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_item_mjz_attribute_mail") then
		return self.BaseClass.GetCooldown(self, level)
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end
function item_pipe_of_dezun:GetCastRange(location, target) return self:GetSpecialValueFor("active_aura_radius") end
function item_pipe_of_dezun:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("active_aura_radius")
	caster:EmitSound("DOTA_Item.Pipe.Activate")
	local particle = ParticleManager:CreateParticle("particles/items2_fx/pipe_of_insight_launch.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(particle)

	caster:AddNewModifier(caster, self, "modifier_pipe_of_dezun_magic_immune_aura", {duration = duration})
end

-- Pipe of Dezun Modifier --
if modifier_pipe_of_dezun == nil then modifier_pipe_of_dezun = class({}) end
function modifier_pipe_of_dezun:IsHidden() return true end
function modifier_pipe_of_dezun:IsPurgable() return false end
function modifier_pipe_of_dezun:RemoveOnDeath() return false end
function modifier_pipe_of_dezun:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_pipe_of_dezun:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_resist") end
end
function modifier_pipe_of_dezun:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("health_regen") end
end
function modifier_pipe_of_dezun:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") + self:GetAbility():GetSpecialValueFor("bonus_strength") end
end
function modifier_pipe_of_dezun:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
end
function modifier_pipe_of_dezun:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
end
function modifier_pipe_of_dezun:IsAura() return true end
function modifier_pipe_of_dezun:IsAuraActiveOnDeath() return false end
function modifier_pipe_of_dezun:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_pipe_of_dezun:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_pipe_of_dezun:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_pipe_of_dezun:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_pipe_of_dezun:GetAuraDuration() return FrameTime() end
function modifier_pipe_of_dezun:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_pipe_of_dezun:GetModifierAura() return "modifier_pipe_of_dezun_aura" end

-- Pipe of Dezun Magic Immune Aura --
if modifier_pipe_of_dezun_magic_immune_aura == nil then modifier_pipe_of_dezun_magic_immune_aura = class({}) end
function modifier_pipe_of_dezun_magic_immune_aura:IsHidden() return true end
function modifier_pipe_of_dezun_magic_immune_aura:IsPurgable() return false end
function modifier_pipe_of_dezun_magic_immune_aura:RemoveOnDeath() return false end
function modifier_pipe_of_dezun_magic_immune_aura:GetEffectName() return "particles/custom/items/pipe_of_dezun/pipe_of_dezun_magic_immune.vpcf" end
function modifier_pipe_of_dezun_magic_immune_aura:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_pipe_of_dezun_magic_immune_aura:IsAura() return true end
function modifier_pipe_of_dezun_magic_immune_aura:IsAuraActiveOnDeath() return false end
function modifier_pipe_of_dezun_magic_immune_aura:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_pipe_of_dezun_magic_immune_aura:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_pipe_of_dezun_magic_immune_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_pipe_of_dezun_magic_immune_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_pipe_of_dezun_magic_immune_aura:GetAuraDuration() return FrameTime() end
function modifier_pipe_of_dezun_magic_immune_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_pipe_of_dezun_magic_immune_aura:GetModifierAura() return "modifier_pipe_of_dezun_magic_immune_buff" end

-- Pipe of Dezun Magic Immune BUFF --
if modifier_pipe_of_dezun_magic_immune_buff == nil then modifier_pipe_of_dezun_magic_immune_buff = class({}) end
function modifier_pipe_of_dezun_magic_immune_buff:IsHidden() return false end
function modifier_pipe_of_dezun_magic_immune_buff:IsPurgable() return false end
function modifier_pipe_of_dezun_magic_immune_buff:IsDebuff() return false end
function modifier_pipe_of_dezun_magic_immune_buff:RemoveOnDeath() return false end
function modifier_pipe_of_dezun_magic_immune_buff:GetEffectName() return "particles/custom/items/pipe_of_dezun/pipe_of_dezun_magic_immune_avatar.vpcf" end
function modifier_pipe_of_dezun_magic_immune_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_pipe_of_dezun_magic_immune_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_pipe_of_dezun_magic_immune_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_pipe_of_dezun_magic_immune_buff:GetModifierMagicalResistanceBonus() return 100 end
function modifier_pipe_of_dezun_magic_immune_buff:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

-- Pipe of Dezun Aura --
if modifier_pipe_of_dezun_aura == nil then modifier_pipe_of_dezun_aura = class({}) end
function modifier_pipe_of_dezun_aura:IsHidden() return false end
function modifier_pipe_of_dezun_aura:IsDebuff() return false end
function modifier_pipe_of_dezun_aura:IsPurgable() return false end
function modifier_pipe_of_dezun_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_pipe_of_dezun_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_pipe_of_dezun_aura:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_aura") end
end
function modifier_pipe_of_dezun_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("as_aura") end
end
function modifier_pipe_of_dezun_aura:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_resist_aura") end
end
function modifier_pipe_of_dezun_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_aura") end
end
