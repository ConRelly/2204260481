

function OnSpellStart( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1

	local duration = ability:GetLevelSpecialValueFor('duration', ability_level)
	local modifier_name = 'modifier_mjz_omniknight_repel_status_resistance_bonus'

	target:AddNewModifier(caster, ability, modifier_name, {duration = duration})
end


--------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_mjz_omniknight_repel_status_resistance_bonus", "abilities/hero_omniknight/mjz_omniknight_repel.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_omniknight_repel_status_resistance_bonus = class({})
local modifier_class = modifier_mjz_omniknight_repel_status_resistance_bonus

function modifier_class:IsHidden()
    return true
end

function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end

function modifier_class:DeclareFunctions()
    local funcs = {
		-- MODIFIER_PROPERTY_STATUS_RESISTANCE,				-- 状态抗性（不可叠加）	GetModifierStatusResistance
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING		-- 状态抗性（可以叠加）	GetModifierStatusResistanceStacking
    }
    return funcs
end

function modifier_class:GetModifierStatusResistanceStacking( params )
	return self.status_resistance_bonus
end

function modifier_class:OnCreated( kv )
	self.ability = self:GetAbility()
	self.status_resistance_bonus = self.ability:GetSpecialValueFor( "status_resistance_bonus")
end



