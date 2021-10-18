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
function modifier_mjz_night_stalker_hunter_in_the_night:OnCreated()
--[[
	if IsServer() then
		if _G._Sun == nil then
			if GameRules:IsDaytime() then
				_G._Sun = true
			else
				_G._Sun = false
			end
		end
	end
]]
	if not self:GetCaster():HasModifier("modifier_night_stalker_hunter_in_the_night") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_night_stalker_hunter_in_the_night", {})
	end
	self:StartIntervalThink(FrameTime())
end
--[[
function modifier_mjz_night_stalker_hunter_in_the_night:OnIntervalThink()
	local modifiers = self:GetCaster():FindAllModifiers()
	for _,modifier in pairs(modifiers) do
		print("modifier: ",modifier,modifier:GetName())
	end
end
]]

function modifier_mjz_night_stalker_hunter_in_the_night:OnDestroy()
	if self:GetCaster():HasModifier("modifier_night_stalker_hunter_in_the_night") then
		self:GetCaster():RemoveModifierByName("modifier_night_stalker_hunter_in_the_night")
	end
	if self:GetCaster():HasModifier("modifier_mjz_night_stalker_hunter_in_the_night_mspeed") then
		self:GetCaster():RemoveModifierByName("modifier_mjz_night_stalker_hunter_in_the_night_mspeed")
	end
	if self:GetCaster():HasModifier("modifier_mjz_night_stalker_hunter_in_the_night_aspeed") then
		self:GetCaster():RemoveModifierByName("modifier_mjz_night_stalker_hunter_in_the_night_aspeed")
	end
end
function modifier_mjz_night_stalker_hunter_in_the_night:OnIntervalThink()
	if IsServer() then
		if _G._Sun == nil then Sun = GameRules:IsDaytime() else Sun = _G._Sun end

		local modifier_ms = "modifier_mjz_night_stalker_hunter_in_the_night_mspeed"
		local modifier_as = "modifier_mjz_night_stalker_hunter_in_the_night_aspeed"
		local multiplier = self:GetAbility():GetTalentSpecialValueFor("bonus_in_night")
		local bonus_ms_pct = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed_pct")
		local bonus_as = self:GetAbility():GetTalentSpecialValueFor("bonus_attack_speed")

		if not Sun then
			bonus_ms_pct = bonus_ms_pct * multiplier
			bonus_as = bonus_as * multiplier
		end

		if self:GetCaster():PassivesDisabled() then bonus_ms_pct = 0 bonus_as = 0 end

		if not Sun and self:GetCaster():IsAlive() then
--			if not self:GetCaster():HasModifier(modifier_ms) then
				local ms_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), modifier_ms, {})
				ms_modifier:SetStackCount(bonus_ms_pct)
--			end
--			if not self:GetCaster():HasModifier(modifier_as) then
				local as_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), modifier_as, {})
				as_modifier:SetStackCount(bonus_as)
--			end
		end
		if Sun and self:GetCaster():IsAlive() then
			if self:GetCaster():HasModifier(modifier_ms) then
				self:GetCaster():RemoveModifierByName(modifier_ms)
			end
			if self:GetCaster():HasModifier(modifier_as) then
				self:GetCaster():RemoveModifierByName(modifier_as)
			end
		end
	end
end

-----------------------------------------------------------------------------------------
modifier_mjz_night_stalker_hunter_in_the_night_mspeed = class({})
function modifier_mjz_night_stalker_hunter_in_the_night_mspeed:IsPassive() return true end
function modifier_mjz_night_stalker_hunter_in_the_night_mspeed:IsHidden() return true end
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
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:IsHidden() return true end
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:IsPurgable() return false end
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_mjz_night_stalker_hunter_in_the_night_aspeed:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end
