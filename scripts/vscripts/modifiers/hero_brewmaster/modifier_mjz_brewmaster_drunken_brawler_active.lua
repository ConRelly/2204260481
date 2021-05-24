
modifier_mjz_brewmaster_drunken_brawler_active = class ({})
local modifier_active = modifier_mjz_brewmaster_drunken_brawler_active

function modifier_active:IsHidden()
    return false
end
function modifier_active:IsPurgable()	-- 能否被驱散
	return false
end

function modifier_active:OnCreated( kv )
    local unit = self:GetParent()
    local caster = unit
    local ability = self:GetAbility()

    ability._active = true
    -- ability:_Refresh()

    local effect_evade_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunkenbrawler_evade.vpcf"
    self.effect_evade = ParticleManager:CreateParticle(effect_evade_name, PATTACH_ABSORIGIN_FOLLOW, caster)
    local effect_crit_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunkenbrawler_crit.vpcf"
    self.effect_crit = ParticleManager:CreateParticle(effect_crit_name, PATTACH_ABSORIGIN_FOLLOW, caster)	
end
function modifier_active:OnDestroy( kv )
    local unit = self:GetParent()
    local caster = unit
    local ability = self:GetAbility()

    ability._active = false
    -- ability:_Refresh()

    ParticleManager:DestroyParticle(self.effect_evade, true)
    ParticleManager:DestroyParticle(self.effect_crit, true)
    ParticleManager:ReleaseParticleIndex(self.effect_evade)
    ParticleManager:ReleaseParticleIndex(self.effect_crit)
end
