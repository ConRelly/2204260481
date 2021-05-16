
function RotImpact( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local self_damage = caster:GetMaxHealth()/100 * ability:GetSpecialValueFor("hp_cost")
	local str_dmg = ability:GetSpecialValueFor("str_dmg")/100
	local damage = self_damage + base_dmg
	
	DealDamage(caster, caster, self_damage, DAMAGE_TYPE_PURE, nil, ability)

	local effect = "particles/econ/items/pudge/pudge_ti6_immortal/pudge_meathook_witness_impact_ti6_water.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin()) -- Origin

	local enemies = FindUnitsInRadius(caster:GetTeam(), 
									caster:GetAbsOrigin(), 
									nil, 
									radius, 
									DOTA_UNIT_TARGET_TEAM_ENEMY, 
									DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
									DOTA_UNIT_TARGET_FLAG_NONE, 
									FIND_ANY_ORDER, false)
	
	for i=1,#enemies do
		local enemy = enemies[i]
		DealDamage(caster, enemy, damage, DAMAGE_TYPE_MAGICAL, nil, ability)
--		local effect = "particles/units/heroes/hero_pudge/pudge_meathook_impact_droplets.vpcf"
		local effect = "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf"
		local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:SetParticleControl(pfx, 0, enemy:GetAbsOrigin()) -- Origin
			
	end

end