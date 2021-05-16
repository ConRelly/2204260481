LinkLuaModifier( "modifier_item_mjz_devils_veil", "items/item_mjz_devils_veil", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_devils_veil_buff", "items/item_mjz_devils_veil", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------
item_mjz_devils_veil = class({})
function item_mjz_devils_veil:GetIntrinsicModifierName() return "modifier_item_mjz_devils_veil" end
function item_mjz_devils_veil:OnSpellStart()
    if IsServer() then
        local ability = self
        local caster = self:GetCaster()
        local target = caster
        local duration = ability:GetSpecialValueFor("duration")
        if target and IsValidEntity(target) and target:IsRealHero() then
            target:AddNewModifier(caster, ability, "modifier_item_mjz_devils_veil_buff", {duration = duration})
        end
    end
end

---------------------------------------------------------------------------------------
modifier_item_mjz_devils_veil = class({})
function modifier_item_mjz_devils_veil:IsHidden() return true end
function modifier_item_mjz_devils_veil:IsPurgable() return false end
function modifier_item_mjz_devils_veil:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_mjz_devils_veil:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_item_mjz_devils_veil:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mjz_devils_veil:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mjz_devils_veil:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

---------------------------------------------------------------------------------------
modifier_item_mjz_devils_veil_buff = class({})
function modifier_item_mjz_devils_veil_buff:IsHidden() return false end
function modifier_item_mjz_devils_veil_buff:IsPurgable() return false end
function modifier_item_mjz_devils_veil_buff:GetTexture() return "item_mjz_devils_veil" end
function modifier_item_mjz_devils_veil_buff:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end
function modifier_item_mjz_devils_veil_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_item_mjz_devils_veil_buff:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("outgoing_damage")
end
function modifier_item_mjz_devils_veil_buff:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("incoming_damage") + 100
end
