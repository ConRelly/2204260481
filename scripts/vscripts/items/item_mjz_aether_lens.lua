LinkLuaModifier("modifier_item_mjz_aether_lens",  "items/item_mjz_aether_lens.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_aether_lens_stats",  "items/item_mjz_aether_lens.lua",LUA_MODIFIER_MOTION_NONE)

function OnEquip(keys)
	if not IsServer() then return nil end
	local caster = keys.caster
	local modifier = "modifier_item_mjz_aether_lens"
	if caster then
		if caster:HasModifier("modifier_item_mjz_aether_lens_stats") then return end
		if caster:HasModifier(modifier) then caster:RemoveModifierByName(modifier) end
		caster:AddNewModifier(caster, keys.ability, modifier, {})
	end
end
function OnUnequip(keys)
	if not IsServer() then return nil end
	local caster = keys.caster
	local ability = keys.ability
	local modifier = "modifier_item_mjz_aether_lens"
	if caster then
		if caster:HasModifier(modifier) then caster:RemoveModifierByName(modifier) end
	end	
end

function OnSpellStart(keys)
	if not IsServer() then return nil end
	local caster = keys.caster
	local ability = keys.ability
	local modifier_stats = "modifier_item_mjz_aether_lens_stats"
	if caster:HasModifier(modifier_stats) then return end
	caster:AddNewModifier(caster, ability, modifier_stats, {})
	caster:EmitSound("Hero_Alchemist.Scepter.Cast")
	caster:RemoveItem(ability)
end


modifier_item_mjz_aether_lens = class({})
function modifier_item_mjz_aether_lens:IsHidden() return true end
function modifier_item_mjz_aether_lens:IsPurgable() return false end
function modifier_item_mjz_aether_lens:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_item_mjz_aether_lens:GetTexture() return "modifiers/mjz_aether_lens" end
function modifier_item_mjz_aether_lens:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS}
end
function modifier_item_mjz_aether_lens:GetModifierCastRangeBonus(htable) return self:GetAbility():GetSpecialValueFor("cast_range_bonus") end



modifier_item_mjz_aether_lens_stats = class({})
function modifier_item_mjz_aether_lens_stats:IsHidden() return false end
function modifier_item_mjz_aether_lens_stats:IsPurgable() return false end
function modifier_item_mjz_aether_lens_stats:AllowIllusionDuplicate() return true end
function modifier_item_mjz_aether_lens_stats:RemoveOnDeath() return false end
function modifier_item_mjz_aether_lens_stats:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_item_mjz_aether_lens_stats:GetTexture() return "modifiers/mjz_aether_lens" end
function modifier_item_mjz_aether_lens_stats:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE}
end
function modifier_item_mjz_aether_lens_stats:GetModifierCastRangeBonus(htable) return 250 end
function modifier_item_mjz_aether_lens_stats:GetModifierSpellAmplify_Percentage() return 25 end
function modifier_item_mjz_aether_lens_stats:GetModifierPercentageCasttime() return 100 end
