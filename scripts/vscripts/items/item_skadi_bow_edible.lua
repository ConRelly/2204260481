LinkLuaModifier("modifier_skadi_bow_edible", "items/item_skadi_bow_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skadi_bow_slow_debuff_edible", "items/item_skadi_bow_edible.lua", LUA_MODIFIER_MOTION_NONE)
---------------
-- Skadi Bow Edible --
---------------
item_skadi_bow_edible = item_skadi_bow_edible or class({})
local edible_skadi = "modifier_skadi_bow_edible"
local item_skadi = "modifier_skadi_bow"


function item_skadi_bow_edible:OnSpellStart()
	local caster = self:GetCaster()
	if not caster:IsRealHero() or caster:HasModifier("modifier_arc_warden_tempest_double") or caster:HasModifier(edible_skadi) or caster:HasModifier(item_skadi) then return end
	caster:AddNewModifier(caster, self, edible_skadi, {})
	caster:EmitSound("Hero_Alchemist.Scepter.Cast")
	caster:RemoveItem(self)
end

-- Skadi Bow Modifier
modifier_skadi_bow_edible = modifier_skadi_bow_edible or class({})
function modifier_skadi_bow_edible:IsHidden() return false end
function modifier_skadi_bow_edible:IsPurgable() return false end
function modifier_skadi_bow_edible:RemoveOnDeath() return false end
function modifier_skadi_bow_edible:AllowIllusionDuplicate() return true end
function modifier_skadi_bow_edible:GetTexture() return "custom/item_skadi_bow_edible" end
function modifier_skadi_bow_edible:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PROJECTILE_NAME}
end
function modifier_skadi_bow_edible:GetModifierPreAttack_BonusDamage()
	return 12000
end
function modifier_skadi_bow_edible:GetModifierPhysicalArmorBonus()
	return 65
end
function modifier_skadi_bow_edible:GetModifierManaBonus()
	return 4500
end
function modifier_skadi_bow_edible:GetModifierBonusStats_Strength()
	return 660
end
function modifier_skadi_bow_edible:GetModifierBonusStats_Agility()
	return 660
end
function modifier_skadi_bow_edible:GetModifierBonusStats_Intellect()
	return 660
end
function modifier_skadi_bow_edible:GetModifierHealthBonus()
	return 6500
end
---Aura slow--
function modifier_skadi_bow_edible:IsAura() return true end
function modifier_skadi_bow_edible:IsAuraActiveOnDeath() return false end
function modifier_skadi_bow_edible:GetAuraDuration() return 3 end
function modifier_skadi_bow_edible:GetModifierAura() return "modifier_skadi_bow_slow_debuff_edible" end
function modifier_skadi_bow_edible:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_skadi_bow_edible:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_skadi_bow_edible:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_skadi_bow_edible:GetAuraRadius() return 2000 end

-- Skadi Bow Slow Debuff
modifier_skadi_bow_slow_debuff_edible = modifier_skadi_bow_slow_debuff_edible or class({})
function modifier_skadi_bow_slow_debuff_edible:IsDebuff() return true end
function modifier_skadi_bow_slow_debuff_edible:IsHidden() return false end
function modifier_skadi_bow_slow_debuff_edible:IsPurgable() return true end
function modifier_skadi_bow_slow_debuff_edible:RemoveOnDeath() return true end
function modifier_skadi_bow_slow_debuff_edible:GetTexture() return "custom/item_skadi_bow_edible" end
function modifier_skadi_bow_slow_debuff_edible:StatusEffectPriority() return 10 end
function modifier_skadi_bow_slow_debuff_edible:OnCreated(keys)
	
end
function modifier_skadi_bow_slow_debuff_edible:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE}
end
function modifier_skadi_bow_slow_debuff_edible:GetModifierMoveSpeedBonus_Percentage()
	return -45
end
function modifier_skadi_bow_slow_debuff_edible:GetModifierAttackSpeedBonus_Constant()
	return -150
end
function modifier_skadi_bow_slow_debuff_edible:GetModifierHPRegenAmplify_Percentage()
	return -50
end