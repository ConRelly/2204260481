

modifier_gm_single_fort = class({})
local modifier = modifier_gm_single_fort

function modifier:IsHidden() return false end
function modifier:IsPurgable() return false end

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
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,    -- GetModifierConstantHealthRegen
            -- MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,  --GetModifierConstantHealthRegen
          }
end
  
function modifier:GetModifierPhysicalArmorBonus()
    return 20
end
function modifier:GetModifierConstantHealthRegen()
    return 50
end
function modifier:GetModifierHealthRegenPercentage()
    return 10
end