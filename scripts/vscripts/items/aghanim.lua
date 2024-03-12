function AghanimsSynthCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_synth = keys.modifier_synth
	local modifier_stats = keys.modifier_stats
	if caster:HasModifier(modifier_synth) or caster:HasModifier("modifier_arc_warden_tempest_double") then
		return nil
	else
		caster:AddNewModifier(caster, nil, modifier_synth, {})
		ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {})
	end
	ability:SetCurrentCharges(ability:GetCurrentCharges() - 1)
	--caster:RemoveItem(ability)
	caster:TakeItem(ability)
end
