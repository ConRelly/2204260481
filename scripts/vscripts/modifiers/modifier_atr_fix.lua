require("lib/my")


modifier_atr_fix = class({})


function modifier_atr_fix:IsHidden()
    return true
end


function modifier_atr_fix:IsPurgable()
    return false
end
function modifier_atr_fix:RemoveOnDeath()
    return false
end
function modifier_atr_fix:AllowIllusionDuplicate()
    return true
end    

function modifier_atr_fix:GetTexture()
    return "atr_fix"
end


function modifier_atr_fix:DeclareFunctions()
	local funcs = {
		--MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		--MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        --MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        --MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
	}
	return funcs
end


function modifier_atr_fix:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

local function settings()
	SendToConsole("dota_hud_healthbars 1")-- too much health causes lags
    SendToConsole("dota_health_bar_shields 0")-- too much health causes lags
	SendToConsole("dota_hud_disable_damage_numbers true")-- isnt affected by damage filter, and thus useless
end


function modifier_atr_fix:OnCreated()
	self.parent = self:GetParent()
    if IsClient() then
        if self.parent:IsRealHero() then
		    settings()
        end    
	end  
    self:StartIntervalThink(0.5) 
end
function modifier_atr_fix:OnIntervalThink()
    if IsServer() then
        if self.parent then
            -- Get the hero entity
            -- Calculate the base magical resistance value to counteract the int bonus
            local int = self.parent:GetIntellect(false)
            local baseValue = (-0.1 * int) + 30
            -- Set the hero's base magical resistance value
            self.parent:SetBaseMagicalResistanceValue(baseValue)
        end
    end
end    
--[[function modifier_atr_fix:GetModifierConstantManaRegen()
    local parent_int = self.parent:GetIntellect(false)
    local m_regen = parent_int * 0.0375
    return m_regen
end]]

function modifier_atr_fix:GetModifierSpellAmplify_Percentage()
    if self.parent then
        local parent_int = self.parent:GetIntellect(false)
        local str_amp = 0
        local parent_str = self.parent:GetStrength()
        local diff = parent_str - parent_int
        if diff > 0 then
            str_amp = diff * 0.03
            if str_amp > 1000 then
                str_amp = 1000
            end    
        end    
        local amp = (parent_int * 0.03) + str_amp  
        return amp
    end     
end

function modifier_atr_fix:GetCustomStackingCDR()
    if self.parent then
        local parent_int = self.parent:GetIntellect(false)
        local cdr = parent_int * 0.0025
        if cdr > 50 then
            cdr = 50
        end    
        return cdr
    end  
end

function modifier_atr_fix:GetModifierBaseAttack_BonusDamage()
    if self.parent then
        return self.parent:GetAgility()
    end  
end

--[[function modifier_atr_fix:GetModifierBaseDamageOutgoing_Percentage()
	local parent_agi = self.parent:GetAgility()
    local bonus_attack = parent_agi * 0.005
    return bonus_attack
end]]


function modifier_atr_fix:GetModifierStatusResistanceStacking()
    if self.parent then
        local parent_str = self.parent:GetStrength()
        local s_resit = parent_str * 0.002
        if s_resit > 65 then
            s_resit = 65
        end   
        return s_resit
    end    
end
