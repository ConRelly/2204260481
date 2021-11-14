LinkLuaModifier("modifier_damage_meter", "abilities/damage_meter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damage_meter2", "abilities/damage_meter", LUA_MODIFIER_MOTION_NONE)

---------------
-- DPS Meter --
---------------
damage_meter = class({})
function damage_meter:GetIntrinsicModifierName() return "modifier_damage_meter" end

modifier_damage_meter = class({})
function modifier_damage_meter:IsHidden() return true end
function modifier_damage_meter:IsPurgable() return false end
function modifier_damage_meter:RemoveOnDeath() return false end
--function modifier_damage_meter:CanParentBeAutoAttacked() return false end
function modifier_damage_meter:DeclareFunctions() return
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end
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
function modifier_damage_meter2:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():SetMaxHealth(1)
	self:GetCaster():SetBaseMaxHealth(1)
	self:GetCaster():SetHealth(1)
end
