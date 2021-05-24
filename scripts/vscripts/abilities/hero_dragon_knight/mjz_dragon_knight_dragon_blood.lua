
local THIS_LUA = "abilities/hero_dragon_knight/mjz_dragon_knight_dragon_blood.lua"
local MODIFIER_INIT_NAME = 'modifier_mjz_dragon_knight_dragon_blood'



LinkLuaModifier(MODIFIER_INIT_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------------------------

mjz_dragon_knight_dragon_blood = class({})
local ability_class = mjz_dragon_knight_dragon_blood

function ability_class:GetIntrinsicModifierName()
    return MODIFIER_INIT_NAME
end

------------------------------------------------------------------------------------------


modifier_mjz_dragon_knight_dragon_blood = class({})
local modifier_class = modifier_mjz_dragon_knight_dragon_blood

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:IsPassive() return true end

function modifier_class:DeclareFunctions()
    return {
		-- MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,	--GetModifierHPRegenAmplify_Percentage
    }
end

-- function modifier_class:GetModifierHealthRegenPercentage( params )
-- 	return self:GetAbility():GetSpecialValueFor('health_drain_per_second_scepter')
-- end
function modifier_class:GetModifierConstantHealthRegen( params )
	local ability = self:GetAbility()
	if IsValidEntity(ability) then
		local value = ability:GetSpecialValueFor("bonus_health_regen")
		local stack = self:GetStackCount()
		if stack > 0 then
			return value * stack / 10
		else
			return value
		end
	end
	return 0
end
function modifier_class:GetModifierPhysicalArmorBonus( params )
	if IsValidEntity(self:GetParent()) and self:GetParent():PassivesDisabled() then return 0 end
	local ability = self:GetAbility()
	if IsValidEntity(ability) then
		local value = ability:GetSpecialValueFor("bonus_armor")
		local stack = self:GetStackCount()
		if stack > 0 then
			return value * stack / 10
		else
			return value
		end
	end
	return 0
end
function modifier_class:GetModifierHPRegenAmplify_Percentage()
	if IsValidEntity(self:GetParent()) and self:GetParent():PassivesDisabled() then return 0 end
    local ability = self:GetAbility()
    if IsValidEntity(ability) then
	    return ability:GetSpecialValueFor("hp_regen_amp")
	end
	return 0
end


if IsServer() then
	function modifier_class:OnCreated(table)
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		local think_interval = 5
		self:StartIntervalThink(think_interval)
	end

	function modifier_class:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local special = "special_bonus_unique_dragon_knight"
		local stack = 18

		local ab = parent:FindAbilityByName(special)
		if ab and ab:GetLevel() > 0 then
			if self:GetStackCount() ~= stack then
				self:SetStackCount(stack)
			end
		end

		
	end
	

end

------------------------------------------------------------------------------------------

function HasModifierList( unit, modifier_name_list )
	for _,modifier_name in pairs(modifier_name_list) do
		if not unit:HasModifier(modifier_name) then
			return false
		end
	end
	return true
end

function SetModifierListDuration( unit, modifier_name_list, duration )
	for _,modifier_name in pairs(modifier_name_list) do
		local modifier = unit:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
		end
	end
end

function SetModifierDuration( unit, modifier_name, duration )
	local modifier = unit:FindModifierByName(modifier_name)
	if modifier then
		modifier:SetDuration(duration, true)
	end
end

