function SwitchAura(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:GetName() == "item_mjz_ring_of_aquila" then
		ItemName = "item_mjz_ring_of_aquila_inactive"
	elseif ability:GetName() == "item_mjz_ring_of_aquila_inactive" then
		ItemName = "item_mjz_ring_of_aquila"
	end

    for i = 0, 5 do
		local current_item = caster:GetItemInSlot(i)
		if current_item == nil then
			caster:AddItem(CreateItem("item_dummy", caster, caster))
		end
	end
	caster:RemoveItem(ability)
	local Item = CreateItem(ItemName, caster, caster)
	Item:SetPurchaseTime(0)
	caster:AddItem(Item)
	for i = 0, 5 do
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_dummy" then
				caster:RemoveItem(current_item)
			end
		end
	end
end
