
item_tome_bargain = class({})


function item_tome_bargain:OnSpellStart()	
    local caster = self:GetCaster()
    if caster:GetUnitLabel() ~= "spirit_bear" then
		if caster:HasModifier("modifier_item_tome_bargain") then
			local tome = caster:FindModifierByName("modifier_item_tome_bargain")
			local tome_count = tome:GetStackCount()
			local tome = caster:AddNewModifier(caster, self, "modifier_item_tome_bargain", {})
			tome:SetStackCount(tome_count + 1)
		else
			local tome = caster:AddNewModifier(caster, self, "modifier_item_tome_bargain", {})
			tome:SetStackCount(1)
		end
		self:SpendCharge()
	end	
end



LinkLuaModifier("modifier_item_tome_bargain", "items/item_tome_bargain.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_tome_bargain = class({})
function modifier_item_tome_bargain:GetTexture() return "tome_bargain" end
function modifier_item_tome_bargain:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_TOOLTIP2}
end
function modifier_item_tome_bargain:IsPurgable() return false end
function modifier_item_tome_bargain:RemoveOnDeath() return false end
function modifier_item_tome_bargain:AllowIllusionDuplicate() return true end
function modifier_item_tome_bargain:OnCreated()

end
function modifier_item_tome_bargain:GetModifierBaseAttack_BonusDamage()
	return self:GetStackCount() * 250 
end
function modifier_item_tome_bargain:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount() * (-10) 
end
function modifier_item_tome_bargain:OnTooltip()
	return self:GetStackCount() * 250 
end
function modifier_item_tome_bargain:OnTooltip2()
	return self:GetStackCount() * (-10) 
end