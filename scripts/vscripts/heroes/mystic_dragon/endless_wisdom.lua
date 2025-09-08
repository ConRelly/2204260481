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
		{MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_TOOLTIP} end,
})

function modifier_mystic_dragon_endless_wisdom_buff:OnCreated()
	--if IsServer() then
		local parent = self:GetParent()
		local time = GameRules:GetGameTime() / 60
		if time > 1 and not self.one_time_only then
			local mbuff = self
			local stack = math.floor(time * 3)
			mbuff:SetStackCount(stack)
			self:IncrementStackCount()
			self.one_time_only = true
		end	
	--end
end	
function modifier_mystic_dragon_endless_wisdom_buff:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("grow_int") end
end

function modifier_mystic_dragon_endless_wisdom_buff:GetModifierManaBonus()
	local mana_bonus = talent_value(self:GetParent(), "special_bonus_unique_winter_wyvern_endless_01") or 0
	if mana_bonus then return self:GetStackCount() * mana_bonus end
end

function modifier_mystic_dragon_endless_wisdom_buff:OnTooltip()
	--calc bonus int
	if self:GetAbility() then
		local bonus_int = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("grow_int")
		return bonus_int
	end
end
--Increases the stack count of Flesh Heap.
function StackCountIncrease( keys )
    local caster = keys.caster
    local ability = keys.ability
	local bonus = 1
	if caster:HasModifier("modifier_super_scepter") then
		if caster:HasModifier("modifier_marci_unleash_flurry") then
			bonus = 2
		end                                 
	end
    local fleshHeapStackModifier = "modifier_mystic_dragon_endless_wisdom_buff"
	if not caster:HasModifier(fleshHeapStackModifier) then
		caster:AddNewModifier(caster, ability, fleshHeapStackModifier, nil)
	end		
    local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

	local pfx = ParticleManager:CreateParticle("particles/custom/abilities/endless_wisdom/endless_wisdom_count.vpcf", PATTACH_OVERHEAD_FOLLOW, keys.caster)
	ParticleManager:ReleaseParticleIndex(pfx)

	caster:AddNewModifier(caster, ability, fleshHeapStackModifier, nil)
    caster:SetModifierStackCount(fleshHeapStackModifier, ability, (currentStacks + bonus))
end


