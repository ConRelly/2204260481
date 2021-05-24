
modifier_hard_mode_boss = class({})

function modifier_hard_mode_boss:IsBuff()
    return true
end
function modifier_hard_mode_boss:IsHidden()
    return false
end

function modifier_hard_mode_boss:GetTexture()
    return "custom_avatar_debuff"
end

function modifier_hard_mode_boss:IsPurgable()
    return false
end

function modifier_hard_mode_boss:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

function modifier_hard_mode_boss:GetModifierHealthRegenPercentage()
    return 0.66
end
function modifier_hard_mode_boss:GetModifierPhysicalArmorBonus()
	return 4
end
function modifier_hard_mode_boss:GetModifierMagicalResistanceBonus()
    return 10
end
function modifier_hard_mode_boss:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_hard_mode_boss:OnCreated()
		self:StartIntervalThink(3)
		self:SetStackCount(10)
		self.parent = self:GetParent()
		self.particle = ParticleManager:CreateParticle("particles/custom/infinite_rapier_shell.vpcf", PATTACH_POINT, self.parent)
		ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		self.particle2 = ParticleManager:CreateParticle("particles/custom/infinite_rapier_smoke.vpcf", PATTACH_POINT, self.parent)
		ParticleManager:SetParticleControlEnt(self.particle2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	end
	function modifier_hard_mode_boss:OnDestroy()
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:DestroyParticle(self.particle2,  true)
	end
	function modifier_hard_mode_boss:OnIntervalThink()
		self:IncrementStackCount()
	end

end
