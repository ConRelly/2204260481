LinkLuaModifier("modifier_item_mjz_guardian_greaves_holy_light", "items/item_mjz_guardian_greaves_holy_light", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_guardian_greaves_holy_light_aura", "items/item_mjz_guardian_greaves_holy_light", LUA_MODIFIER_MOTION_NONE)

item_mjz_guardian_greaves_holy_light = class({})
function item_mjz_guardian_greaves_holy_light:GetIntrinsicModifierName() return "modifier_item_mjz_guardian_greaves_holy_light" end
function item_mjz_guardian_greaves_holy_light:OnSpellStart()
    local caster = self:GetCaster()
    local replenish_radius = self:GetSpecialValueFor("aura_radius")
    local replenish_health_pct = self:GetSpecialValueFor("replenish_health_pct")
    local replenish_health = self:GetSpecialValueFor("replenish_health")
    local replenish_mana_pct = self:GetSpecialValueFor("replenish_mana_pct")
    local replenish_mana = self:GetSpecialValueFor("replenish_mana")

    caster:EmitSound("Item.GuardianGreaves.Activate")

	caster:Purge(false, true, false, true, false)

	local friends = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, replenish_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

    for _, unit in pairs(friends) do
        local flAmount_health = (unit:GetMaxHealth() * replenish_health_pct / 100) + replenish_health
        local flAmount_mana = (unit:GetMaxMana() * replenish_mana_pct / 100) + replenish_mana

		unit:Heal(flAmount_health, caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, unit, flAmount_health, nil)

		unit:GiveMana(flAmount_mana)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, unit, flAmount_mana, nil)

        unit:EmitSound("Item.GuardianGreaves.Target")
    end
end

----------------------------------------------------------------------------------------

modifier_item_mjz_guardian_greaves_holy_light = class({})
function modifier_item_mjz_guardian_greaves_holy_light:IsHidden() return true end
function modifier_item_mjz_guardian_greaves_holy_light:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_mjz_guardian_greaves_holy_light:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_MANA_BONUS,
    }
end
function modifier_item_mjz_guardian_greaves_holy_light:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_mjz_guardian_greaves_holy_light:GetModifierMoveSpeedBonus_Special_Boots()
	return self:GetAbility():GetSpecialValueFor("bonus_movement")
end
function modifier_item_mjz_guardian_greaves_holy_light:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_mjz_guardian_greaves_holy_light:IsAura() return true end
function modifier_item_mjz_guardian_greaves_holy_light:GetModifierAura()
	return "modifier_item_mjz_guardian_greaves_holy_light_aura"
end
function modifier_item_mjz_guardian_greaves_holy_light:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_mjz_guardian_greaves_holy_light:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_mjz_guardian_greaves_holy_light:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_mjz_guardian_greaves_holy_light:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end


-------------------------------------------------------------------

modifier_item_mjz_guardian_greaves_holy_light_aura = class({})
function modifier_item_mjz_guardian_greaves_holy_light_aura:IsHidden() return false end
function modifier_item_mjz_guardian_greaves_holy_light_aura:IsPurgable() return false end
function modifier_item_mjz_guardian_greaves_holy_light_aura:GetTexture() return "item_mjz_guardian_greaves_holy_light" end
function modifier_item_mjz_guardian_greaves_holy_light_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end
function modifier_item_mjz_guardian_greaves_holy_light_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_armor") end 
end
function modifier_item_mjz_guardian_greaves_holy_light_aura:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_health_regen") end
end
