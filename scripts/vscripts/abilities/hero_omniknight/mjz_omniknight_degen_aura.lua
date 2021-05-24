
function OnCreatedAura( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local modifier_name = 'modifier_mjz_omniknight_degen_aura_attackspeed_bonus'
	ability:ApplyDataDrivenModifier(caster, target, modifier_name, {})
	-- target:AddNewModifier(caster, ability, modifier_name, {duration = -1})
end

function OnDestroyAura( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local modifier_name = 'modifier_mjz_omniknight_degen_aura_attackspeed_bonus'
	target:RemoveModifierByName(modifier_name)
end


--------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_mjz_omniknight_degen_aura_attackspeed_bonus", "abilities/hero_omniknight/mjz_omniknight_degen_aura.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_omniknight_degen_aura_attackspeed_bonus = class({})
local modifier_class = modifier_mjz_omniknight_degen_aura_attackspeed_bonus

function modifier_class:IsHidden()
    return true
end

function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end

function modifier_class:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_class:GetModifierAttackSpeedBonus_Constant( params )
	return self.attack_bonus_per
	-- return -10
end

function modifier_class:OnCreated( kv )
	self.ability = self:GetAbility()
	self.attack_bonus = self.ability:GetSpecialValueFor( "attack_bonus")
	self.tick_rate = self.ability:GetSpecialValueFor( "think_interval" )

	self:OnIntervalThink()
	self:StartIntervalThink( self.tick_rate )
end

function modifier_class:OnIntervalThink()
	local unit = self:GetParent()
	self.attack_bonus_per = unit:GetAttackSpeed() * self.attack_bonus

	-- print(unit:GetAttackSpeed(), self.attack_bonus, self.attack_bonus_per)
end

