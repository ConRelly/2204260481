LinkLuaModifier("modifier_item_mjz_ipomoea_aquatica", "items/item_mjz_ipomoea_aquatica.lua", LUA_MODIFIER_MOTION_NONE)


item_mjz_ipomoea_aquatica = class({})

function item_mjz_ipomoea_aquatica:GetIntrinsicModifierName()
    return "modifier_item_mjz_ipomoea_aquatica"
end


------------------------------------------------------------------------------

modifier_item_mjz_ipomoea_aquatica = class({})

function modifier_item_mjz_ipomoea_aquatica:IsHidden() return true end
function modifier_item_mjz_ipomoea_aquatica:IsPurgable() return false end

function modifier_item_mjz_ipomoea_aquatica:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mjz_ipomoea_aquatica:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end


function modifier_item_mjz_ipomoea_aquatica:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_mjz_ipomoea_aquatica:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_mjz_ipomoea_aquatica:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intelligence")
end


if IsServer() then
	function modifier_item_mjz_ipomoea_aquatica:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.itemName = self:GetAbility():GetName()
		self.lifesteal = self.ability:GetSpecialValueFor("lifesteal")
		self.mn_lifesteal = "modifier_mjz_spell_lifesteal_unique"
		-- print(self.itemName)
		Timers:CreateTimer(
			0.25, 
			function()
				self.parent:RemoveModifierByName(self.mn_lifesteal)
				local m = self.parent:AddNewModifier(self.parent, self.ability, self.mn_lifesteal, {})
				if m then
					m:SetStackCount(self.lifesteal)
				end
			end
		)
	end
	
	function modifier_item_mjz_ipomoea_aquatica:OnDestroy()
		self.parent:RemoveModifierByName(self.mn_lifesteal)
	end
end

