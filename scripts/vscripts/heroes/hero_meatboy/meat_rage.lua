
function BloodImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = caster:GetMaxHealth()/100 * ability:GetSpecialValueFor("hp_dmg")
	
	if target:IsBuilding() or target:IsMagicImmune() then
		return
	end
	
	DealDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability)
	
	local effect = "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin()) -- Origin
	ParticleManager:ReleaseParticleIndex(pfx)

end