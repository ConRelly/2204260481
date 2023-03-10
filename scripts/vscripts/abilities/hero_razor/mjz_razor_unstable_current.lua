LinkLuaModifier("modifier_mjz_razor_unstable_current", "modifiers/hero_razor/modifier_mjz_razor_unstable_current.lua", LUA_MODIFIER_MOTION_NONE)


mjz_razor_unstable_current = class({})
local ability_class = mjz_razor_unstable_current


function ability_class:GetAbilityTextureName()
    if self:GetCaster():HasScepter() then
        return "mjz_razor_unstable_current"
    end
    return "razor_unstable_current"	 -- return self.BaseClass.GetAbilityTextureName(self)
end

function ability_class:GetAOERadius()
    if self:GetCaster() and self:GetCaster():HasScepter() then
        return self:GetCaster():Script_GetAttackRange() + 100 --self:GetSpecialValueFor("radius_scepter")
    end
	return self:GetSpecialValueFor("radius")	 -- return self.BaseClass.GetAOERadius(self)
end


function ability_class:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("passive_area_interval_scepter")
    end
    return self:GetSpecialValueFor("passive_area_interval")	-- return self.BaseClass.GetCooldown(self, iLevel)
end


function ability_class:GetDamageType()
    return DAMAGE_TYPE_PHYSICAL
end
function ability_class:GetAbilityDamageType()
    return self:GetDamageType()
end
function ability_class:GetUnitDamageType()
    return self:GetDamageType()
end

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_razor_unstable_current"
end

function ability_class:OnToggle(keys)
end

if IsServer() then
    function ability_class:_IsReady( )
        return self:GetToggleState() and self:_IsCooldownReady()
    end
    function ability_class:_IsCooldownReady()    
        local caster = self:GetCaster()
        local ability = self
        local cooldown_time = ability:GetSpecialValueFor("passive_area_interval")
        if caster:HasScepter() then
            cooldown_time = ability:GetSpecialValueFor("passive_area_interval_scepter")
        end
        self._prev_spell_time = self._prev_spell_time or GameRules:GetGameTime()
        local isCooldownReady = GameRules:GetGameTime() > (self._prev_spell_time + cooldown_time)
        return isCooldownReady
    end
    function ability_class:_StartCooldown()    
        local ability = self
        ability:StartCooldown( ability:GetCooldown(ability:GetLevel() - 1) )
        self._prev_spell_time = GameRules:GetGameTime()
    end

end