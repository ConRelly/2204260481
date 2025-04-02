require("lib/my")
LinkLuaModifier("modifier_underdog", "modifiers/modifier_underdog.lua", LUA_MODIFIER_MOTION_NONE)

modifier_underdog = class({})



function modifier_underdog:IsHidden()
    return false
end
function modifier_underdog:AllowIllusionDuplicate()
    return true
end
function modifier_underdog:IsPurgable()
    return false
end
function modifier_underdog:IsDebuff()
    return true
end    
function modifier_underdog:GetTexture()
    return "underdog"
end


function modifier_underdog:DeclareFunctions()
    --if IsServer() then
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, 
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,         
    }
    return funcs
    --end    
end


function modifier_underdog:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

--[[function modifier_underdog:OnCreated()
    if IsServer( ) then
        if self.amp == nil then
            self.amp = RandomInt(100, 400)
            self.dmg = RandomInt(35, 85)
            self.str = RandomInt(100, 1000)
            self.agi = RandomInt(100, 1000)
            self.int = RandomInt(100, 1000)
        end
    end       
end]]
   
function modifier_underdog:GetModifierSpellAmplify_Percentage()
    return 300 --self.amp
end

function modifier_underdog:GetModifierDamageOutgoing_Percentage()
    return 50 --self.dmg       
end

function modifier_underdog:GetModifierBonusStats_Strength()  
    return 1000 --self.str
end

function modifier_underdog:GetModifierBonusStats_Agility() 
    return 1000 --self.agi
end
function modifier_underdog:GetModifierBonusStats_Intellect() 
    return 1000 --self.int     
end
 