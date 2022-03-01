require("lib/my")



item_vladmir_temp = class({})


function item_vladmir_temp:GetIntrinsicModifierName()
    return "modifier_item_vladmir_temp"
end



LinkLuaModifier("modifier_item_vladmir_temp", "items/item_vladmir_temp.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_vladmir_temp = class({})


function modifier_item_vladmir_temp:IsHidden()
    return true
end
function modifier_item_vladmir_temp:IsPurgable()
	return false
end

if IsServer() then
	function modifier_item_vladmir_temp:OnCreated()
		local parent = self:GetParent()
		local PlayerID = parent:GetPlayerID()
		Timers:CreateTimer(
            0.9,
            function()
				if not self:IsNull() and not self:GetAbility():IsNull() then
					self:GetAbility():Destroy()
				end	
				
				if parent:GetNumItemsInInventory() < 9 then
					local item = parent:AddItemByName("item_vladmir's_soul")
				else
					local item = CreateItem("item_vladmir's_soul", parent, parent)
					CreateItemOnPositionSync(parent:GetAbsOrigin(), item)
				end
				if self:IsNull() then return end
				self:Destroy()
			end
		)
	end
end 