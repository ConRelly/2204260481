function OnSpellStart(keys)
	local target = keys.target
	local ability = keys.ability
	local caster = keys.caster
	if target:GetTeam() == caster:GetTeam() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_mana_blade_dispel", {duration = keys.duration})
		if caster:HasModifier("modifier_mjz_satanic_5") then
			target:Purge(false,true,false,true,false)
		else
			target:Purge(false,true,false,false,false)
		end
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_mana_blade_debuff", {duration = keys.duration})
		target:Purge(true,false,false,false,false)
	end
end


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


function Dispel(keys)
	keys.target:Purge(false,true,false,false,false)
end
function DispelEnd(keys)
	if keys.caster:HasModifier("modifier_mjz_satanic_5") then
		keys.target:Purge(false,true,false,true,false)
	end
end