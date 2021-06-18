function Overcharge( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = "modifier_overcharge_stack"

	if caster:HasModifier(modifier) then
		local stack_count = caster:GetModifierStackCount(modifier, ability)
		caster:SetModifierStackCount(modifier, ability, stack_count + 1)
	else
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		caster:SetModifierStackCount(modifier, ability, 1)
	end
	if caster:GetModifierStackCount(modifier, ability) == 25 then
		caster:AddItem(CreateItem("item_basher", nil, nil))
	elseif caster:GetModifierStackCount(modifier, ability) == 45 then
		caster:AddItem(CreateItem("item_basher", nil, nil))
	elseif caster:GetModifierStackCount(modifier, ability) == 65 then
		caster:AddItem(CreateItem("item_basher", nil, nil))
	elseif caster:GetModifierStackCount(modifier, ability) == 85 then
		caster:AddItem(CreateItem("item_basher", nil, nil))
	end
	if caster:GetModifierStackCount(modifier, ability) == 75 then
		caster:AddNewModifier(caster, ability, "modifier_ursa_overpower", {duration = })
		EmitSoundOn("Hero_Ursa.Enrage", caster)
	end
	if _G._hardMode then
		if caster:GetModifierStackCount(modifier, ability) == 100 then
			caster:ForceKill(false)
		end
	else
		if caster:GetModifierStackCount(modifier, ability) == 50 then
			caster:ForceKill(false)
		end
	end
end