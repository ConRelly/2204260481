require("lib/my")



item_philo_stone_temp = class({})


function item_philo_stone_temp:GetIntrinsicModifierName()
    return "modifier_item_philo_stone_temp"
end



LinkLuaModifier("modifier_item_philo_stone_temp", "items/item_philo_stone_temp.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_philo_stone_temp = class({})


function modifier_item_philo_stone_temp:IsHidden()
    return true
end
function modifier_item_philo_stone_temp:IsPurgable()
	return false
end

if IsServer() then
	function modifier_item_philo_stone_temp:OnCreated()
		local parent = self:GetParent()
		local PlayerID = parent:GetPlayerID()
		if _G.AOHGameMode.AllowedPhilo(PlayerID) then
			Timers:CreateTimer(
				0.8,
				function()
					self:GetAbility():Destroy()
					
					if parent:GetNumItemsInInventory() < 9 then
						local item = parent:AddItemByName("item_philosophers_stone")
					else
						local item = CreateItem("item_philosophers_stone", parent, parent)
						CreateItemOnPositionSync(parent:GetAbsOrigin(), item)
					end
					self:Destroy()
				end
			)
			_G.AOHGameMode.IncrementPhilo(PlayerID)
		else
			Timers:CreateTimer(
				0.8,
				function()
					self:GetAbility():Destroy()
					
					if parent:GetNumItemsInInventory() < 9 then
						local item = parent:AddItemByName("item_philo_stone_failed")
						item:SetPurchaseTime(GameRules:GetGameTime() - 10)
					else
						local item = CreateItem("item_philo_stone_failed", parent, parent)
						item:SetPurchaseTime(GameRules:GetGameTime() - 10)
						CreateItemOnPositionSync(parent:GetAbsOrigin(), item)
					end
					self:Destroy()
				end
			)
		end
		
	end
end 