function grave(event)
	caster = event.caster
	desire_of_life = caster:FindAbilityByName( "desire_of_life" )
	if caster:GetHealth() < 5 then
		caster:RemoveModifierByName("modifier_desire_of_life")
	end
end
function promise(event)
	caster = event.caster
	desire_of_life = caster:FindAbilityByName( "desire_of_life" )
	if caster:GetHealth() < 2 then
		caster:RemoveModifierByName("modifier_fp_delay")
	end
end