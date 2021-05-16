LinkLuaModifier("modifier_mjz_doom_bringer_infernal_blade","modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_infernal_blade.lua", LUA_MODIFIER_MOTION_NONE)

mjz_doom_bringer_infernal_blade = class({})
local ability_class = mjz_doom_bringer_infernal_blade

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('cast_range')
end
function ability_class:GetCastRange(vLocation, hTarget)
	-- return self.BaseClass.GetCastRange(self, vLocation, hTarget) end 
	return self:GetSpecialValueFor('cast_range')
end

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_doom_bringer_infernal_blade"
end


function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		if target then
			self.overrideAutocast = true
			self:GetCaster():MoveToTargetToAttack(target)
		end
	end
end

