
--- NEW Versiion ---
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night_mspeed","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night_aspeed","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night_damage","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night_spell_amp","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)

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
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_night_stalker_hunter_in_the_night") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_night_stalker_hunter_in_the_night", {})
		end
		self:StartIntervalThink(1)
	end	
end

function modifier_mjz_night_stalker_hunter_in_the_night:OnDestroy()
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_night_stalker_hunter_in_the_night") then
		self:GetCaster():RemoveModifierByName("modifier_night_stalker_hunter_in_the_night")
	end
	local modifiers = {
		"modifier_mjz_night_stalker_hunter_in_the_night_mspeed",
		"modifier_mjz_night_stalker_hunter_in_the_night_aspeed",
		"modifier_mjz_night_stalker_hunter_in_the_night_damage",
		"modifier_mjz_night_stalker_hunter_in_the_night_spell_amp"
	}
	for _, modifier in pairs(modifiers) do
		if self:GetCaster():HasModifier(modifier) then
			self:GetCaster():RemoveModifierByName(modifier)
		end
	end
end

function modifier_mjz_night_stalker_hunter_in_the_night:OnIntervalThink()
	if IsServer() then
		if _G._Sun == nil then Sun = GameRules:IsDaytime() else Sun = _G._Sun end

		local modifier_ms = "modifier_mjz_night_stalker_hunter_in_the_night_mspeed"
		local modifier_as = "modifier_mjz_night_stalker_hunter_in_the_night_aspeed"
		local modifier_damage = "modifier_mjz_night_stalker_hunter_in_the_night_damage"
		local modifier_spell_amp = "modifier_mjz_night_stalker_hunter_in_the_night_spell_amp"
		
		local multiplier = self:GetAbility():GetTalentSpecialValueFor("bonus_in_night")
		local bonus_ms_pct = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed_pct")
		local bonus_as = self:GetAbility():GetTalentSpecialValueFor("bonus_attack_speed")
		local bonus_damage_pct = self:GetAbility():GetTalentSpecialValueFor("bonus_damage_pct")
		local bonus_spell_amp = self:GetAbility():GetTalentSpecialValueFor("bonus_spell_amp")

		if not Sun then
			bonus_ms_pct = bonus_ms_pct * multiplier
			bonus_as = bonus_as * multiplier
			bonus_damage_pct = bonus_damage_pct * multiplier
			bonus_spell_amp = bonus_spell_amp * multiplier
		end

		if self:GetCaster():PassivesDisabled() then 
			bonus_ms_pct = 0 
			bonus_as = 0 
			bonus_damage_pct = 0 
			bonus_spell_amp = 0 
		end

		if self:GetCaster():IsAlive() then
			local ms_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), modifier_ms, {})
			ms_modifier:SetStackCount(bonus_ms_pct)
			
			local as_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), modifier_as, {})
			as_modifier:SetStackCount(bonus_as)
			
			local damage_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), modifier_damage, {})
			damage_modifier:SetStackCount(bonus_damage_pct)
			
			local spell_amp_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), modifier_spell_amp, {})
			spell_amp_modifier:SetStackCount(bonus_spell_amp)
		end
	end
end

-----------------------------------------------------------------------------------------
-- Movement Speed Modifier
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
-- Attack Speed Modifier
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

-----------------------------------------------------------------------------------------
-- Damage Percentage Modifier
modifier_mjz_night_stalker_hunter_in_the_night_damage = class({})
function modifier_mjz_night_stalker_hunter_in_the_night_damage:IsPassive() return true end
function modifier_mjz_night_stalker_hunter_in_the_night_damage:IsHidden() return true end
function modifier_mjz_night_stalker_hunter_in_the_night_damage:IsPurgable() return false end
function modifier_mjz_night_stalker_hunter_in_the_night_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end
function modifier_mjz_night_stalker_hunter_in_the_night_damage:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount()
end

-----------------------------------------------------------------------------------------
-- Spell Amplification Modifier
modifier_mjz_night_stalker_hunter_in_the_night_spell_amp = class({})
function modifier_mjz_night_stalker_hunter_in_the_night_spell_amp:IsPassive() return true end
function modifier_mjz_night_stalker_hunter_in_the_night_spell_amp:IsHidden() return true end
function modifier_mjz_night_stalker_hunter_in_the_night_spell_amp:IsPurgable() return false end
function modifier_mjz_night_stalker_hunter_in_the_night_spell_amp:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_mjz_night_stalker_hunter_in_the_night_spell_amp:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end
