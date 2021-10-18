LinkLuaModifier("modifier_gegenstrom", "heroes/hero_piety/gegenstrom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gegenstrom_aura", "heroes/hero_piety/gegenstrom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_divinity_activated", "heroes/hero_piety/divine_cancel", LUA_MODIFIER_MOTION_NONE)

----------------
-- Gegenstrom --
----------------
gegenstrom = class({})
function gegenstrom:GetIntrinsicModifierName() return "modifier_gegenstrom" end
function gegenstrom:ProcsMagicStick() return false end
function gegenstrom:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
end
function gegenstrom:OnSpellStart()
--	if IsServer() then
		if self.pfx then
			ParticleManager:DestroyParticle(self.pfx, false)
			ParticleManager:ReleaseParticleIndex(self.pfx)
		end
		if not _G._Sun then
			GameRules:SetTimeOfDay(0.75)
			_G._Sun = true
			particle = "particles/custom/abilities/gegenstrom/gegenstrom_sun.vpcf"
		else
			GameRules:SetTimeOfDay(0.25)
			_G._Sun = false
			particle = "particles/custom/abilities/gegenstrom/gegenstrom_moon.vpcf"
		end

		self.pfx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(self.pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.pfx, 2, Vector(2, 0, 0))
--	end
end
function gegenstrom:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_divinity_activated") then
		return self:GetCaster():GetMaxMana() / 2
	end
	return self:GetCaster():GetMaxMana()
end
function gegenstrom:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_divinity_activated") then
		return 15 / self:GetCaster():GetCooldownReduction()
	end
	return 60 / self:GetCaster():GetCooldownReduction()
end

-------------------------
-- Gegenstrom Modifier --
-------------------------
modifier_gegenstrom = class({})
function modifier_gegenstrom:IsHidden() return true end
function modifier_gegenstrom:IsPurgable() return false end
function modifier_gegenstrom:IsDebuff() return false end
function modifier_gegenstrom:RemoveOnDeath() return false end
function modifier_gegenstrom:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		if _G._Sun == nil then
			if GameRules:IsDaytime() then
				_G._Sun = true
			else
				_G._Sun = false
			end
		end
	end
end
--[[
function modifier_gegenstrom:GetEffectName()
	return "particles/econ/items/mirana/mirana_2021_immortal/mirana_2021_immortal_moonlight_recipient_golden.vpcf"
end

function modifier_gegenstrom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
]]
function modifier_gegenstrom:IsAura() return true end
function modifier_gegenstrom:IsAuraActiveOnDeath() return false end
function modifier_gegenstrom:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_gegenstrom:GetAuraDuration() return FrameTime() end
function modifier_gegenstrom:GetModifierAura() return "modifier_gegenstrom_aura" end
function modifier_gegenstrom:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_gegenstrom:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_gegenstrom:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end

---------------------
-- Gegenstrom Aura --
---------------------
modifier_gegenstrom_aura = class({})
function modifier_gegenstrom_aura:IsHidden() return true end
function modifier_gegenstrom_aura:IsDebuff() return false end
function modifier_gegenstrom_aura:IsPurgable() return false end
function modifier_gegenstrom_aura:GetTexture()
	if _G._Sun then return "custom/abilities/gegenstrom_day" else return "custom/abilities/gegenstrom_night" end
end
function modifier_gegenstrom_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_gegenstrom_aura:OnIntervalThink()
	if _G._Sun then self:SetStackCount(1) else self:SetStackCount(0) end
end
function modifier_gegenstrom_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE}
end
function modifier_gegenstrom_aura:GetModifierHPRegenAmplify_Percentage()
	if self:GetAbility() then
		if self:GetStackCount() == 1 then
			return self:GetAbility():GetSpecialValueFor("aura_hp_regen_amp")
		else
			return 0
		end
	end
end
function modifier_gegenstrom_aura:GetModifierMPRegenAmplify_Percentage()
	if self:GetAbility() then
		if self:GetStackCount() == 0 then
			return self:GetAbility():GetSpecialValueFor("aura_mana_regen_amp")
		else
			return 0
		end
	end
end
