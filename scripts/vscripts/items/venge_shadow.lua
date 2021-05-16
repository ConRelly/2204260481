LinkLuaModifier("modifier_venge_shadow", "items/venge_shadow.lua", LUA_MODIFIER_MOTION_NONE)
if item_venge_shadow == nil then item_venge_shadow = class({}) end
function item_venge_shadow:GetAbilityTextureName() return "vengeances_shadow" end
function item_venge_shadow:GetIntrinsicModifierName() return "modifier_venge_shadow" end
function item_venge_shadow:OnOwnerDied()
	if not self:GetCaster():IsIllusion() and self:IsCooldownReady() then
		local num_illusions_on_death	= self:GetSpecialValueFor("num_illusions_on_death")
		if self:GetCaster():GetLevel() >= self:GetSpecialValueFor("illusion_upgrade_level") then
			num_illusions_on_death		= self:GetSpecialValueFor("num_illusions_on_death_upgrade")
		end
		local super_illusions = CreateIllusions(self:GetCaster(), self:GetCaster(), 
		{
			outgoing_damage 			= 100 - self:GetSpecialValueFor("illusion_outgoing_damage"),
			incoming_damage				= self:GetSpecialValueFor("illusion_incoming_damage") - 100,
			bounty_base					= nil,
			bounty_growth				= nil,
			outgoing_damage_structure	= nil,
			outgoing_damage_roshan		= nil,
			duration					= nil
		}
		, num_illusions_on_death, self:GetCaster():GetHullRadius(), true, true)
		for _, illusion in pairs(super_illusions) do
			illusion:SetHealth(illusion:GetMaxHealth())
			illusion:AddNewModifier(self:GetCaster(), self, "modifier_vengefulspirit_hybrid_special", {})
			FindClearSpaceForUnit(illusion, self:GetCaster():GetAbsOrigin() + Vector(RandomInt(0, 1), RandomInt(0, 1), 0) * 108, true)
			PlayerResource:NewSelection(self:GetCaster():GetPlayerID(), super_illusions)
			self:UseResources(false, false, true)
		end
	end
end

if modifier_venge_shadow == nil then modifier_venge_shadow = class({}) end
function modifier_venge_shadow:IsHidden() return true end
function modifier_venge_shadow:IsDebuff() return false end
function modifier_venge_shadow:IsPurgable() return false end
function modifier_venge_shadow:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_venge_shadow:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_venge_shadow:GetModifierHealthBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end end
function modifier_venge_shadow:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local reflect = self:GetAbility():GetSpecialValueFor("reflect")
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local damage_type = params.damage_type
		local reflect_damage = damage * (reflect / 100)
		if attacker ~= nil and target == caster and reflect_damage ~= 0 then
			if not caster:IsIllusion() then
				if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
					ApplyDamage({victim = attacker, attacker = caster, damage = reflect_damage, damage_type = damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()})
				end
			end
		end
	end
end