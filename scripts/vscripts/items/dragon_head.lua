item_dragon_head = class({})
item_dragon_head_2 = item_dragon_head
function item_dragon_head:GetIntrinsicModifierName() return "modifier_item_dragon_head" end

LinkLuaModifier("modifier_item_dragon_head", "items/dragon_head.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_dragon_head_aura_buff", "items/dragon_head.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_dragon_head_2_aura_buff", "items/dragon_head.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_dragon_head = class({})
function modifier_item_dragon_head:IsHidden() return true end
function modifier_item_dragon_head:IsPurgable() return false end
function modifier_item_dragon_head:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_dragon_head:IsAura() return true end
function modifier_item_dragon_head:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_dragon_head:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_dragon_head:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_dragon_head:GetModifierAura()
	if self:GetAbility():GetName() == "item_dragon_head_2" then
		return "modifier_item_dragon_head_2_aura_buff"
	end
	return "modifier_item_dragon_head_aura_buff"
end
function modifier_item_dragon_head:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_item_dragon_head:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end
function modifier_item_dragon_head:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end



modifier_item_dragon_head_aura_buff = class({})
function modifier_item_dragon_head_aura_buff:IsHidden()
	if self:GetParent():HasModifier("modifier_item_dragon_head_2_aura_buff") then
		return true
	end
	return false
end
function modifier_item_dragon_head_aura_buff:GetTexture() return "item_ForaMon/dragon_head" end
function modifier_item_dragon_head_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_item_dragon_head_aura_buff:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_bonus_health") end
end
function modifier_item_dragon_head_aura_buff:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_bonus_strength") end
end



modifier_item_dragon_head_2_aura_buff = class({})
function modifier_item_dragon_head_2_aura_buff:GetTexture() return "item_ForaMon/dragon_head" end
function modifier_item_dragon_head_2_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_item_dragon_head_2_aura_buff:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_bonus_health") end
end
function modifier_item_dragon_head_2_aura_buff:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_bonus_strength") end
end
function modifier_item_dragon_head_2_aura_buff:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_bonus_extra_health") end
end
