LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night_mspeed","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night_aspeed","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)

mjz_night_stalker_hunter_in_the_night = class({})
function mjz_night_stalker_hunter_in_the_night:GetIntrinsicModifierName()
	return "modifier_mjz_night_stalker_hunter_in_the_night"
end

---------------------------------------------------------------------------------------
modifier_mjz_night_stalker_hunter_in_the_night = class({})
function modifier_mjz_night_stalker_hunter_in_the_night:IsPassive() return true end
function modifier_mjz_night_stalker_hunter_in_the_night:IsHidden() return true end
function modifier_mjz_night_stalker_hunter_in_the_night:IsPurgable() return false end
if IsServer() then
	function modifier_mjz_night_stalker_hunter_in_the_night:OnCreated()
		self.multiplier = self:GetAbility():GetSpecialValueFor("bonus_in_night") or 0
		self:StartIntervalThink(FrameTime())
	end
	function modifier_mjz_night_stalker_hunter_in_the_night:OnIntervalThink()
		self:BonusModifier("bonus_movement_speed_pct", "modifier_mjz_night_stalker_hunter_in_the_night_mspeed")
		self:BonusModifier("bonus_attack_speed", "modifier_mjz_night_stalker_hunter_in_the_night_aspeed")
	end
	function modifier_mjz_night_stalker_hunter_in_the_night:BonusModifier(specialName, modifierName)
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local hParent = self:GetParent()
		local bonus = hAbility:GetTalentSpecialValueFor(specialName)
		if not GameRules:IsDaytime() then
			bonus = bonus * self.multiplier
		end
		if hParent:PassivesDisabled() then bonus = 0 end
		local modifier = nil
		if not hParent:HasModifier(modifierName) then
			modifier = hParent:AddNewModifier(hCaster, hAbility, modifierName, {})
		end
		if modifier == nil then
			modifier = hParent:FindModifierByName(modifierName)
		end
		if modifier ~= nil then
			if modifier:GetStackCount() ~= bonus then
				modifier:SetStackCount(bonus)
			end
		end
	end
end

-----------------------------------------------------------------------------------------
modifier_mjz_night_stalker_hunter_in_the_night_mspeed = class({})
function modifier_mjz_night_stalker_hunter_in_the_night_mspeed:IsPassive() return true end
function modifier_mjz_night_stalker_hunter_in_the_night_mspeed:IsHidden() return false end
function modifier_mjz_night_stalker_hunter_in_the_night_mspeed:IsPurgable() return false end
function modifier_mjz_night_stalker_hunter_in_the_night_mspeed:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_mjz_night_stalker_hunter_in_the_night_mspeed:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end

-----------------------------------------------------------------------------------------
modifier_mjz_night_stalker_hunter_in_the_night_aspeed = class({})
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:IsPassive() return true end
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:IsHidden() return false end
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:IsPurgable() return false end
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end
