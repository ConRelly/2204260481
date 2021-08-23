require("lib/my")


modifier_atr_fix = class({})


function modifier_atr_fix:IsHidden()
    return true
end


function modifier_atr_fix:IsPurgable()
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
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
	}
	return funcs
end


function modifier_atr_fix:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_atr_fix:OnCreated()
	self.parent = self:GetParent()
end

--[[function modifier_atr_fix:GetModifierConstantManaRegen()
    local parent_int = self.parent:GetIntellect()
    local m_regen = parent_int * 0.0375
    return m_regen
end]]

function modifier_atr_fix:GetModifierSpellAmplify_Percentage()
    local parent_int = self.parent:GetIntellect()  
    local amp = parent_int * 0.03
    return amp
end

function modifier_atr_fix:GetCustomStackingCDR()
	local parent_int = self.parent:GetIntellect()
    local cdr = parent_int * 0.0025
    if cdr > 50 then
        cdr = 50
    end    
    return cdr
end

function modifier_atr_fix:GetModifierBaseAttack_BonusDamage()
    return self.parent:GetAgility()
end

--[[function modifier_atr_fix:GetModifierBaseDamageOutgoing_Percentage()
	local parent_agi = self.parent:GetAgility()
    local bonus_attack = parent_agi * 0.005
    return bonus_attack
end]]


function modifier_atr_fix:GetModifierStatusResistance()
	local parent_str = self.parent:GetStrength()
    local s_resit = parent_str * 0.0037
    if s_resit > 40 then
        s_resit = 40
    end   
    return s_resit
end
