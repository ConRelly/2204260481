LinkLuaModifier("modifier_mystic_dragon_endless_wisdom_buff", "heroes/mystic_dragon/endless_wisdom", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------
------------------------------------------------------------
modifier_mystic_dragon_endless_wisdom_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end,
})

function modifier_mystic_dragon_endless_wisdom_buff:GetModifierBonusStats_Intellect()
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("grow_int")
end

--Increases the stack count of Flesh Heap.
function StackCountIncrease( keys )
    local caster = keys.caster
    local ability = keys.ability
    local fleshHeapStackModifier = "modifier_mystic_dragon_endless_wisdom_buff"
    local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

	caster:AddNewModifier(caster, ability, fleshHeapStackModifier, nil)
    caster:SetModifierStackCount(fleshHeapStackModifier, ability, (currentStacks + 1))
end


