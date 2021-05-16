function OnAttackLanded(event)
	local target = event.target
	local caster = event.caster
	local ability = event.ability
	local mana_break = ability:GetSpecialValueFor("mana_break")
	local prc = ability:GetSpecialValueFor("prc")
	local tmana = target:GetMana()
	if tmana > 0 then
		if tmana > mana_break then
			target:ReduceMana(mana_break)
			ApplyDamage({victim = target, attacker = caster, damage = mana_break * prc, damage_type = DAMAGE_TYPE_PHYSICAL})
		else
			target:ReduceMana(tmana)
			ApplyDamage({victim = target, attacker = caster, damage = tmana * prc, damage_type = DAMAGE_TYPE_PHYSICAL})
		end
	end
end