------------------------
-- Voodoo Restoration --
------------------------
wd_voodoo_restoration = class({})
LinkLuaModifier("modifier_wd_voodoo_restoration", "heroes/hero_witch_doctor/voodoo_restoration", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wd_voodoo_restoration_heal", "heroes/hero_witch_doctor/voodoo_restoration", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wd_voodoo_restoration_heal_talent", "heroes/hero_witch_doctor/voodoo_restoration", LUA_MODIFIER_MOTION_NONE)

function wd_voodoo_restoration:GetAbilityTextureName() return "witch_doctor_voodoo_restoration" end
function wd_voodoo_restoration:ProcsMagicStick() return false end
function wd_voodoo_restoration:GetCastRange()
	if not IsServer() then return end
	local radius = self:GetSpecialValueFor("radius")
	if self:GetCaster():HasTalent("special_bonus_wd_voodoo_restoration_radius") then
		radius = radius * self:GetCaster():FindTalentValue("special_bonus_wd_voodoo_restoration_radius")
		return radius
	end
	return radius
end
function wd_voodoo_restoration:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
end
function wd_voodoo_restoration:GetManaCost(hTarget)
	return self.BaseClass.GetManaCost(self, hTarget)
end

function wd_voodoo_restoration:OnToggle()
	if self:GetToggleState() then
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration", self:GetCaster())
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration.Loop", self:GetCaster())
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_wd_voodoo_restoration", {})
	else
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration.Off", self:GetCaster())
		StopSoundEvent("Hero_WitchDoctor.Voodoo_Restoration.Loop", self:GetCaster())
		self:GetCaster():RemoveModifierByName("modifier_wd_voodoo_restoration")
	end
end

modifier_wd_voodoo_restoration = class({})
function modifier_wd_voodoo_restoration:IsHidden() return true end
function modifier_wd_voodoo_restoration:OnCreated()
	if IsServer() and self:GetAbility():IsTrained() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		self.interval = ability:GetSpecialValueFor("heal_interval")
		self.manacost = ability:GetSpecialValueFor("mana_per_second") * self.interval
		self.radius = ability:GetSpecialValueFor("radius")
		if caster:HasTalent("special_bonus_wd_voodoo_restoration_radius") then
			self.radius = ability:GetSpecialValueFor("radius") * caster:FindTalentValue("special_bonus_wd_voodoo_restoration_radius")
		end
		self:StartIntervalThink(self.interval)
		self.mainParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(self.mainParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_staff", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.mainParticle, 1, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControlEnt(self.mainParticle, 2, caster, PATTACH_POINT_FOLLOW, "attach_staff", caster:GetAbsOrigin(), true)
	end
end
function modifier_wd_voodoo_restoration:OnDestroy()
	if IsServer() then
		self:StartIntervalThink(-1)
		if self.mainParticle then
			ParticleManager:DestroyParticle(self.mainParticle, false)
			ParticleManager:ReleaseParticleIndex(self.mainParticle)
		end
	end
end
function modifier_wd_voodoo_restoration:OnIntervalThink()
	if not self:GetAbility() or self:GetAbility():IsNull() then self:Destroy() return end
	if not self:GetCaster():IsAlive() then return end

	if self:GetCaster():GetMana() >= self:GetAbility():GetManaCost(-1) then
		self:GetCaster():Script_ReduceMana(self.manacost, self:GetAbility())
	else
		self:GetAbility():ToggleAbility()
	end
end
function modifier_wd_voodoo_restoration:IsAura() return true end
function modifier_wd_voodoo_restoration:IsAuraActiveOnDeath() return false end
function modifier_wd_voodoo_restoration:GetAuraRadius() return self.radius end
function modifier_wd_voodoo_restoration:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_wd_voodoo_restoration:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_wd_voodoo_restoration:GetModifierAura() return "modifier_wd_voodoo_restoration_heal" end

-----------------------------
-- Voodoo Restoration Heal --
-----------------------------
modifier_wd_voodoo_restoration_heal = class({})
function modifier_wd_voodoo_restoration_heal:IsDebuff() return false end
function modifier_wd_voodoo_restoration_heal:IsHidden() return false end
function modifier_wd_voodoo_restoration_heal:IsPurgable() return false end
function modifier_wd_voodoo_restoration_heal:IsPurgeException() return false end
function modifier_wd_voodoo_restoration_heal:RemoveOnDeath() return true end
function modifier_wd_voodoo_restoration_heal:OnCreated()
	if IsServer() then if not self:GetAbility() or self:GetAbility():IsNull() then self:Destroy() return end

		self.heal = self:GetAbility():GetSpecialValueFor("heal")
		self.heal_spell_amp_pct = self:GetAbility():GetSpecialValueFor("heal_spell_amp_pct")
		self.int_to_heal = self:GetAbility():GetSpecialValueFor("int_to_heal")

		self.interval = self:GetAbility():GetSpecialValueFor("heal_interval")
		self:StartIntervalThink(self.interval)
	end
end
function modifier_wd_voodoo_restoration_heal:OnIntervalThink()
	if IsServer() then if not self:GetAbility() or self:GetAbility():IsNull() then self:Destroy() return end

		local caster = self:GetCaster()
		local parent = self:GetParent()
		local talent_heal = self:GetParent():GetMaxHealth() * talent_value(self:GetCaster(), "special_bonus_wd_voodoo_restoration_heal_pct") / 100
		local heal_amp = 1
		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") and self:GetCaster():HasScepter() then
			heal_amp = 1 + (caster:GetSpellAmplification(false) * self.heal_spell_amp_pct / 100)
		end
		local int_to_heal = 0
--[[
		if HasSuperScepter(self:GetCaster()) then
			int_to_heal = caster:GetIntellect() * self.int_to_heal / 100
		end
]]
		local heal = (talent_heal + ((self.heal + int_to_heal) * heal_amp)) * self.interval

		parent:Heal(heal, caster)
		SendOverheadEventMessage(parent, OVERHEAD_ALERT_HEAL, parent, heal, parent)
	end
end
