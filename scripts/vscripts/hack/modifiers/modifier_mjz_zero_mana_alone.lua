

modifier_mjz_zero_mana_alone = class({})
local modifier_class = modifier_mjz_zero_mana_alone

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:GetTexture()
    return "zero_mana"
end

-- 效果永久，死亡不消失
function modifier_class:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end


function modifier_class:DeclareFunctions() 
    return { 
            -- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            -- MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,    -- GetModifierConstantHealthRegen
            -- MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,  --GetModifierConstantHealthRegen
        -- MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,		-- 状态抗性（可以叠加）
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,          -- 魔法消耗和损失降低
        MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE, 
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		-- MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,    -- GetModifierDamageOutgoing_Percentage
        -- MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE,  -- GetModifierMagicDamageOutgoing_Percentage
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,   --GetModifierTotalDamageOutgoing_Percentage
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,        --GetModifierIncomingDamage_Percentage
    }
end

function modifier_class:GetModifierPercentageManacost()
	return 100
end
function modifier_class:GetModifierPercentageManaRegen()
	return 100
end
function modifier_class:GetModifierConstantManaRegen()
	return 100
end

function modifier_class:GetModifierDamageOutgoing_Percentage()
	return -18
end
function modifier_class:GetModifierMagicDamageOutgoing_Percentage()
	return -18
end
function modifier_class:GetModifierTotalDamageOutgoing_Percentage()
	return -22
end
function modifier_class:GetModifierIncomingDamage_Percentage()
	return 15
end

