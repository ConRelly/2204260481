
function ApplyModifierToUnit(data)
	--print("ApplyModifierToUnit")
	data.caster:AddNewModifier(data.caster, data.ability, data.ModifName, {})
end
