

modifier_mjz_invincible = class({})
local modifier = modifier_mjz_invincible

function modifier:IsHidden() return true end
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
            -- MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,    -- GetModifierConstantHealthRegen
            MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,  --GetModifierConstantHealthRegen
          }
end
  
function modifier:GetModifierPhysicalArmorBonus()
    return 340
end
function modifier:GetModifierHealthRegenPercentage()
    return 100
end
