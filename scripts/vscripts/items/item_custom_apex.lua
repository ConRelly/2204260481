LinkLuaModifier("modifier_bonus_primary_controller", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_primary_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)

item_custom_apex = class({})
item_custom_apex_2 = item_custom_apex
function item_custom_apex:GetIntrinsicModifierName()
    return "modifier_item_custom_apex"
end
function item_custom_apex:Spawn()
	if IsServer() then
		local caster = self:GetParent()
		if self:GetName() == "item_custom_apex_2" then
			Timers:CreateTimer(0.1, function()
				if IsValidEntity(caster) and caster:IsAlive() and IsValidEntity(self) then
					caster:DropItemAtPositionImmediate(self, caster:GetAbsOrigin())
					Timers:CreateTimer(0.1, function()
						if IsValidEntity(self) and IsValidEntity(caster) and caster:IsAlive() then
							caster:PickupDroppedItem(self:GetContainer())
						end
					end)
				end
			end)
		end
	end
end
LinkLuaModifier("modifier_item_custom_apex", "items/item_custom_apex.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_apex = class({})
function modifier_item_custom_apex:IsHidden()
    return true
end

function modifier_item_custom_apex:IsPurgable()
	return false
end

function modifier_item_custom_apex:RemoveOnDeath()
	return false
end


if IsServer() then
	function modifier_item_custom_apex:OnCreated()
		local ability = self:GetAbility()
		local marci_bonus = 0
		local caster = self:GetCaster()
		if not ability then
			self:Destroy()
			return
		end
		self.parent = self:GetParent()
		if self.parent:HasModifier("modifier_super_scepter") then
			if self.parent:HasModifier("modifier_marci_unleash_flurry") then
				marci_bonus = 10
			end                                 
		end 		
		self.parent:AddNewModifier(self.parent, self, "modifier_bonus_primary_controller", {})
		self.modifier = self.parent:AddNewModifier(self.parent, self, "modifier_bonus_primary_token", {
			bonus = (ability:GetSpecialValueFor("primary_stat_percent") + marci_bonus)})

	end
	
	function modifier_item_custom_apex:OnDestroy()
		if self.modifier:IsNull() then return end
		self.modifier:Destroy()
	end
end