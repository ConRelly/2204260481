function AghanimsSynthCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_synth = keys.modifier_synth
	local modifier_stats = keys.modifier_stats
	
	if caster:HasModifier("modifier_arc_warden_tempest_double") then return nil end
	
	if not caster:HasModifier(modifier_synth) then
		caster:AddNewModifier(caster, nil, modifier_synth, {})
	end
	if caster:HasModifier(modifier_stats) then
		local modifier = caster:FindModifierByName(modifier_stats)
		modifier:SetStackCount(modifier:GetStackCount() + 1)
	else
		ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {})
		local modifier = caster:FindModifierByName(modifier_stats)
		modifier:SetStackCount(1)
	end
	caster:EmitSound("Hero_Alchemist.Scepter.Cast")
	caster:RemoveItem(ability)
end