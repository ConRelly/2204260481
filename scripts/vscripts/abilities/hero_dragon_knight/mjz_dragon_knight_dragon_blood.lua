LinkLuaModifier("modifier_mjz_dragon_knight_dragon_blood", "abilities/hero_dragon_knight/mjz_dragon_knight_dragon_blood.lua", LUA_MODIFIER_MOTION_NONE)


mjz_dragon_knight_dragon_blood = class({})
function mjz_dragon_knight_dragon_blood:GetIntrinsicModifierName() return "modifier_mjz_dragon_knight_dragon_blood" end

------------------------------------------------------------------------------------------
modifier_mjz_dragon_knight_dragon_blood = class({})
function modifier_mjz_dragon_knight_dragon_blood:IsHidden() return true end
function modifier_mjz_dragon_knight_dragon_blood:IsPurgable() return false end
function modifier_mjz_dragon_knight_dragon_blood:IsPassive() return true end

function modifier_mjz_dragon_knight_dragon_blood:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_mjz_dragon_knight_dragon_blood:GetModifierConstantHealthRegen(params)
	if IsValidEntity(self:GetParent()) and self:GetParent():PassivesDisabled() then return 0 end
	local ability = self:GetAbility()
	if IsValidEntity(ability) then
		local value = ability:GetSpecialValueFor("bonus_health_regen")
		local stack = self:GetStackCount()
		if stack > 0 then
			return value * stack
		else
			return value
		end
	end
	return 0
end
function modifier_mjz_dragon_knight_dragon_blood:GetModifierPhysicalArmorBonus(params)
	if IsValidEntity(self:GetParent()) and self:GetParent():PassivesDisabled() then return 0 end
	local ability = self:GetAbility()
	if IsValidEntity(ability) then
		local value = ability:GetSpecialValueFor("bonus_armor")
		local stack = self:GetStackCount()
		if stack > 0 then
			return value * stack
		else
			return value
		end
	end
	return 0
end
function modifier_mjz_dragon_knight_dragon_blood:GetModifierHPRegenAmplify_Percentage()
	if IsValidEntity(self:GetParent()) and self:GetParent():PassivesDisabled() then return 0 end
	local ability = self:GetAbility()
	if IsValidEntity(ability) then
		return ability:GetSpecialValueFor("hp_regen_amp")
	end
	return 0
end
if IsServer() then
	function modifier_mjz_dragon_knight_dragon_blood:OnCreated(table)
		self:StartIntervalThink(FrameTime())
	end

	function modifier_mjz_dragon_knight_dragon_blood:OnIntervalThink()
		if self:GetCaster():HasTalent("special_bonus_unique_dragon_knight") then
			stack = self:GetCaster():FindTalentValue("special_bonus_unique_dragon_knight")
			if self:GetStackCount() ~= stack then
				self:SetStackCount(stack)
			end
		end
	end
end
