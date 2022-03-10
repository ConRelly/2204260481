require("lib/my")



function item_consumable_used(keys)
    EmitSoundOn("Item.MoonShard.Consume", keys.caster)
    increase_modifier(keys.caster, keys.caster, keys.ability, keys.modifier)
    keys.ability:SpendCharge()
end



--LinkLuaModifier("modifier_primary_attribute_book_stats", "items/consumables", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tome_str_bonus", "items/tomes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tome_agi_bonus", "items/tomes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tome_int_bonus", "items/tomes", LUA_MODIFIER_MOTION_NONE)

----------------------------
-- Primary Attribute Book --
----------------------------
--item_primary_attribute_book = class ({})
if item_primary_attribute_book == nil then item_primary_attribute_book = class({}) end
function item_primary_attribute_book:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local attributes = self:GetSpecialValueFor("bonus_primary_stat")

	if caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
		modifier_name = "modifier_tome_str_bonus"
		caster:ModifyStrength(attributes)
	elseif caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
		modifier_name = "modifier_tome_agi_bonus"
		caster:ModifyAgility(attributes)
	elseif caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
		modifier_name = "modifier_tome_int_bonus"
		caster:ModifyIntellect(attributes)
	else
		return
	end

	if caster:HasModifier(modifier_name) then
		local modifier = caster:FindModifierByName(modifier_name)
		modifier:SetStackCount(modifier:GetStackCount() + attributes)
	else
		caster:AddNewModifier(caster, self, modifier_name, {})
		caster:FindModifierByName(modifier_name):SetStackCount(attributes)
	end

    EmitSoundOn("Item.TomeOfKnowledge", caster)
    self:SpendCharge()
end


LinkLuaModifier("modifier_item_speed_orb_consumed", "items/consumables", LUA_MODIFIER_MOTION_NONE)
---------------
-- Speed Orb --
---------------
item_speed_orb = class ({})
function item_speed_orb:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ms_bonus = self:GetSpecialValueFor("bonus")

	if caster:HasModifier("modifier_item_speed_orb_consumed") then
		local modifier = caster:FindModifierByName("modifier_item_speed_orb_consumed")
		modifier:SetStackCount(modifier:GetStackCount() + ms_bonus)
	else
		caster:AddNewModifier(caster, self, "modifier_item_speed_orb_consumed", {})
		caster:FindModifierByName("modifier_item_speed_orb_consumed"):SetStackCount(ms_bonus)
	end

    EmitSoundOn("Item.MoonShard.Consume", caster)
    self:SpendCharge()
end

modifier_item_speed_orb_consumed = class({})
function modifier_item_speed_orb_consumed:IsHidden() return false end
function modifier_item_speed_orb_consumed:IsPurgable() return false end
function modifier_item_speed_orb_consumed:RemoveOnDeath() return false end
function modifier_item_speed_orb_consumed:AllowIllusionDuplicate() return true end
function modifier_item_speed_orb_consumed:GetTexture() return "speed_orb" end
function modifier_item_speed_orb_consumed:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function modifier_item_speed_orb_consumed:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount()
end
