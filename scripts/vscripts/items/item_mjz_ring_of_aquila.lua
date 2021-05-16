



function SwapToItem( keys, ItemName, DummyItemName)
    local BaseNPC = EntIndexToHScript(keys.caster_entindex)   --物品携带者
    
    for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item == nil then
			keys.caster:AddItem(CreateItem(DummyItemName, keys.caster, keys.caster))
		end
	end
	
	keys.caster:RemoveItem(keys.ability)
	keys.caster:AddItem(CreateItem(ItemName, keys.caster, keys.caster))  --This should be put into the same slot that the removed item was in.
	
	for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == DummyItemName then
				keys.caster:RemoveItem(current_item)
			end
		end
	end
end


-- 切换至激活状态
function SwapToActiveStatus( keys )
    SwapToItem(keys, keys.ActiveItem, keys.DummyItem)
end

-- 切换至关闭状态
function SwapToInactiveStatus( keys )
    SwapToItem(keys, keys.InactiveItem, keys.DummyItem)
end
