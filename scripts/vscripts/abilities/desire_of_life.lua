LinkLuaModifier("modifier_generic_handler", "modifiers/modifier_generic_handler", LUA_MODIFIER_MOTION_NONE)
function buff(event)
	event.caster:AddNewModifier(event.caster, nil, "modifier_generic_handler", {})
end
function grave(event)
	caster = event.caster
	if caster:GetHealth() < 5 then
		caster:RemoveModifierByName("modifier_desire_of_life")
	end
end
function promise(event)
	caster = event.caster
	if caster:GetHealth() < 4 then
		caster:RemoveModifierByName("modifier_fp_delay")
	end
end
function give(event)
	caster = event.caster
	if _G._hardMode then
		caster:AddItem(CreateItem("item_daedalus", nil, nil))
	else
		caster:AddItem(CreateItem("item_crystalys", nil, nil))
	end
end
