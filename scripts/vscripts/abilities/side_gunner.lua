LinkLuaModifier("modifier_custom_side_gunner", "abilities/side_gunner", LUA_MODIFIER_MOTION_NONE)

------------------------
-- Custom Side Gunner --
------------------------
custom_side_gunner = class({})
function custom_side_gunner:GetCastRange(location, target)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return self:GetCaster():Script_GetAttackRange() + self:GetSpecialValueFor("gunner_radius") - self:GetCaster():GetCastRangeBonus()
	else
		return self:GetSpecialValueFor("gunner_radius") - self:GetCaster():GetCastRangeBonus()
	end
end
function custom_side_gunner:GetIntrinsicModifierName() return "modifier_custom_side_gunner" end

modifier_custom_side_gunner = class({})
function modifier_custom_side_gunner:IsHidden() return true end
function modifier_custom_side_gunner:IsPurgable() return false end
function modifier_custom_side_gunner:RemoveOnDeath() return false end
function modifier_custom_side_gunner:OnCreated()
	if not IsServer() then return end
	if self:GetAbility() then
		if self:GetAbility():GetLevel() < 1 then self:GetAbility():SetLevel(1) end 
		self:StartIntervalThink(FrameTime())
	end	
end
function modifier_custom_side_gunner:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if not self:GetCaster():IsAlive() then return end
	if self:GetCaster():IsIllusion() then return end 
	if self:GetCaster():PassivesDisabled() then return end
	if self:GetAbility():GetLevel() < 1 then return end
	local gunner_interval = self:GetAbility():GetSpecialValueFor("gunner_interval")
	local gunner_radius = self:GetAbility():GetSpecialValueFor("gunner_radius")

	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		gunner_radius = gunner_radius + self:GetCaster():Script_GetAttackRange()
	end
	if self:GetCaster():HasScepter() then
		gunner_interval = gunner_interval / 2
	end

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetCaster(), gunner_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_FARTHEST, false)
	self:GetCaster():PerformAttack(enemies[1], true, true, true, false, true, false, false)

	if self:GetCaster():HasModifier("modifier_super_scepter") then
		self:GetCaster():PerformAttack(enemies[2], true, true, true, false, true, false, false)
		gunner_interval = gunner_interval / 2
	end

	self:StartIntervalThink(gunner_interval)
end
