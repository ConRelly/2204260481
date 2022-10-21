LinkLuaModifier("modifier_damage_meter", "abilities/damage_meter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damage_meter2", "abilities/damage_meter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phys", "modifiers/modifier_phys.lua", LUA_MODIFIER_MOTION_NONE)

Phys_State = 0
Mag_State = 0
---------------
-- DPS Meter --
---------------
damage_meter = class({})
function damage_meter:GetIntrinsicModifierName() return "modifier_damage_meter" end
function damage_meter:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if not self:GetAutoCastState() then
		if self:GetCaster():GetPhysicalArmorBaseValue() == 420 then
			Phys_State = 0
		else
			Phys_State = Phys_State + 1
		end
		self:GetCaster():SetPhysicalArmorBaseValue(Phys_State * 20)
	else
		if self:GetCaster():GetBaseMagicalResistanceValue() == 100 then
			Mag_State = 0
		else
			Mag_State = Mag_State + 1
		end
		self:GetCaster():SetBaseMagicalResistanceValue(Mag_State * 10)
	end
	if not caster:HasModifier("modifier_phys") then
		caster:AddNewModifier(caster, self, "modifier_phys", {})
	else
		caster:RemoveModifierByName("modifier_phys")	
	end	
end

modifier_damage_meter = class({})
function modifier_damage_meter:IsHidden() return true end
function modifier_damage_meter:IsPurgable() return false end
function modifier_damage_meter:RemoveOnDeath() return false end
--function modifier_damage_meter:CanParentBeAutoAttacked() return false end
function modifier_damage_meter:DeclareFunctions() return
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
	}
end
function modifier_damage_meter:GetModifierPercentageManacost() return 100 end
function modifier_damage_meter:GetModifierPercentageCooldownStacking() return 100 end
function modifier_damage_meter:GetMinHealth() return 1 end
function modifier_damage_meter:OnTakeDamage(data)
	if not IsServer() then return end
	local damage = data.damage
	local attacker = data.attacker
	local unit = data.unit
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	if caster:HasModifier("modifier_boss") then
		caster:RemoveModifierByName("modifier_boss")
	end

	if unit == caster and caster:IsAlive() then
		caster:SetBaseMaxHealth(caster:GetMaxHealth() + damage)
		caster:SetHealth(caster:GetMaxHealth())
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_damage_meter2", {duration = duration})
	end
end

modifier_damage_meter2 = class({})
function modifier_damage_meter2:IsHidden() return true end
function modifier_damage_meter2:IsPurgable() return false end
function modifier_damage_meter2:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_damage_meter2:GetModifierConstantHealthRegen()
	return dps
end
function modifier_damage_meter2:OnCreated()
	CreatedTimer = 1
	TimerInterval = 0.1
	self:StartIntervalThink(TimerInterval)
end
function modifier_damage_meter2:OnIntervalThink()
	CreatedTimer = CreatedTimer + TimerInterval
	dps = math.floor(self:GetCaster():GetMaxHealth() / CreatedTimer)
--	self:GetCaster():SetMaxMana(dps)
--	self:GetCaster():SetMana(dps)
end
function modifier_damage_meter2:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():SetMaxHealth(1)
	self:GetCaster():SetBaseMaxHealth(1)
	self:GetCaster():SetHealth(1)
--	self:GetCaster():SetMaxMana(1)
--	self:GetCaster():SetMana(1)
end
