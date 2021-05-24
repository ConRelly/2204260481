

modifier_mjz_blacklist = class({})
local modifier = modifier_mjz_blacklist

function modifier:IsHidden() return true end
function modifier:IsPurgable() return false end
function modifier:RemoveOnDeath() return false end
function modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier:CheckState()
    local state = {
		-- [MODIFIER_STATE_INVULNERABLE] = true,
		-- [MODIFIER_STATE_FLYING] = true,
		-- [MODIFIER_STATE_NO_HEALTH_BAR] = true,
		-- [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		-- [MODIFIER_STATE_UNSELECTABLE] = true,
	}
    return state  
end

function modifier:DeclareFunctions() 
    return { 
            -- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            -- MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,    -- GetModifierConstantHealthRegen
            -- MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,  --GetModifierConstantHealthRegen
       -- MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        --MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        -- MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,		-- 状态抗性（可以叠加）	
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,

          }
end
  
-- function modifier:GetModifierPhysicalArmorBonus()
--     return 340
-- end
-- function modifier:GetModifierHealthRegenPercentage()
--     return 100
-- end
--function modifier:GetModifierTotalDamageOutgoing_Percentage( )
    --return 0       -- 伤害减少100%
--end

-- function modifier:GetModifierStatusResistanceStacking()
-- 	return 80       -- 状态抗性 80%
-- end
--function modifier:GetModifierIncomingDamage_Percentage()
    --return 0     -- 受到伤害增加100%
--end

function modifier:GetModifierMoveSpeedBonus_Percentage()
    return 0
end

