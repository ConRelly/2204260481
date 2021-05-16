function autoapply( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_item_aghanims_shard") or caster:HasModifier("modifier_arc_warden_tempest_double") then
		return nil
	else
		caster:AddNewModifier(caster, ability, "modifier_item_aghanims_shard", {})
	end
	ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
	caster:RemoveItem(ability)
end