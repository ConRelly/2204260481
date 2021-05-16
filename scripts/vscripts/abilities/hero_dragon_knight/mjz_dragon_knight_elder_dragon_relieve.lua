
local THIS_LUA = "abilities/hero_dragon_knight/mjz_dragon_knight_elder_dragon_relieve.lua"
local MODIFIER_RELIEVE_NAME = 'modifier_mjz_dragon_knight_elder_dragon_relieve'
local MODIFIER_HEALTH_NAME = 'modifier_mjz_dragon_knight_elder_dragon_relieve_health'

local TARGET_MODIFIER_LIST = {
	'modifier_dragon_knight_dragon_form',
	'modifier_dragon_knight_corrosive_breath',
	'modifier_dragon_knight_splash_attack',
	'modifier_dragon_knight_frost_breath',

}

LinkLuaModifier(MODIFIER_RELIEVE_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_HEALTH_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------------------------

mjz_dragon_knight_elder_dragon_relieve = class({})
local ability_class = mjz_dragon_knight_elder_dragon_relieve

function ability_class:GetIntrinsicModifierName()
    return MODIFIER_RELIEVE_NAME
end

if IsServer() then
	function ability_class:OnSpellStart(  )
		local caster = self:GetCaster()
		local ability = self
		local unit = caster
	
		if HasModifierList(unit, {'modifier_dragon_knight_dragon_form'}) then
			SetModifierListDuration(unit, TARGET_MODIFIER_LIST, 0.1)
	
			if unit:HasModifier(MODIFIER_HEALTH_NAME) then
				unit:RemoveModifierByName(MODIFIER_HEALTH_NAME)	
			end
		end
	end
end


------------------------------------------------------------------------------------------


modifier_mjz_dragon_knight_elder_dragon_relieve = class({})
local modifier_relieve = modifier_mjz_dragon_knight_elder_dragon_relieve

function modifier_relieve:IsHidden() return true end
function modifier_relieve:IsPurgable() return false end

if IsServer() then
	function modifier_relieve:OnCreated(table)
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		local think_interval = ability:GetSpecialValueFor('think_interval')
		self:StartIntervalThink(think_interval)
	end

	function modifier_relieve:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local unit = self:GetParent()

		if unit:HasScepter() and self:InShapeshift() then
			self:UpdateDuration()
			if not unit:HasModifier(MODIFIER_HEALTH_NAME) then
				unit:AddNewModifier(caster, ability, MODIFIER_HEALTH_NAME, {})
			end
		else
			unit:RemoveModifierByName(MODIFIER_HEALTH_NAME)	
		end
	end
	
	function modifier_relieve:InShapeshift( )
		local ability = self:GetAbility()
		local unit = self:GetParent()
		return HasModifierList(unit, {'modifier_dragon_knight_dragon_form'})
	end

	function modifier_relieve:UpdateDuration( )
		local ability = self:GetAbility()
		local unit = self:GetParent()
		local duration = ability:GetSpecialValueFor('duration_scepter')

		SetModifierListDuration(unit, TARGET_MODIFIER_LIST, duration)
	end

end

------------------------------------------------------------------------------------------

modifier_mjz_dragon_knight_elder_dragon_relieve_health = class({})
local modifier_health = modifier_mjz_dragon_knight_elder_dragon_relieve_health

function modifier_health:IsHidden() return true end
function modifier_health:IsPurgable() return false end

function modifier_health:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
end
function modifier_health:GetModifierHealthRegenPercentage( params )
	return self:GetAbility():GetSpecialValueFor('health_drain_per_second_scepter')
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

