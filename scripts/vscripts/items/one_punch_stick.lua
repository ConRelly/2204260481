function onepunch(keys)
	keys.target:EmitSound("Hero_Dark_Seer.NormalPunch.Lv3")
	if keys.target:GetTeamNumber() == keys.caster:GetTeamNumber() then
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
	else
		damage_flags = DOTA_DAMAGE_FLAG_NONE
		keys.target:Kill(keys.ability, keys.caster)
	end
	ApplyDamage({victim = keys.target, attacker = keys.caster, ability = keys.ability, damage = keys.target:GetMaxHealth(), damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
end