
function BloodBathImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local hp_dmg = caster:GetMaxHealth()/100 * ability:GetSpecialValueFor("hp_dmg")
	local damage = hp_dmg + base_dmg
	
	if target:GetTeam() == caster:GetTeam() then
		target:Heal(damage, ability)
	else
		DealDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, nil, ability)
		local effect = "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf"
		local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin()) -- Origin
	
	end
--	EmitSoundOn("Hero_Shredder.WhirlingDeath.Cast".caster)


end