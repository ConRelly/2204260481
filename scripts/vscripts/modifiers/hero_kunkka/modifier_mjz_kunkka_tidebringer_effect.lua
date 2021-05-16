
modifier_mjz_kunkka_tidebringer_effect = class({})
local modifier_class = modifier_mjz_kunkka_tidebringer_effect


function modifier_class:IsHidden()
    return true
end
function modifier_class:IsPurgable()
    return false
end
function modifier_class:IsDebuff()
	return false
end

function modifier_class:RemoveOnDeath()
	return false
end

if IsServer() then
	function modifier_class:OnCreated(keys)
		local parent = self:GetParent()
		local ability = self:GetAbility()

		if self.weapon_pfx == nil then
			local weapon_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", PATTACH_POINT_FOLLOW, parent)
			ParticleManager:SetParticleControlEnt(weapon_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_tidebringer", parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(weapon_pfx, 2, parent, PATTACH_POINT_FOLLOW, "attach_sword", parent:GetAbsOrigin(), true)
			self.weapon_pfx = weapon_pfx
		end
	end

	modifier_class.OnRefresh = modifier_class.OnCreated

	function modifier_class:OnDestroy()
		local parent = self:GetParent()
		local ability = self:GetAbility()
			ParticleManager:DestroyParticle(self.weapon_pfx, true)
			ParticleManager:ReleaseParticleIndex(self.weapon_pfx)
			self.weapon_pfx = nil
	end
end