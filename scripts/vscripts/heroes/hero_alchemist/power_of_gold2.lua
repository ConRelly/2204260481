
alchemist_power_of_gold2 = class({})

LinkLuaModifier("modifier_hero_alchemist_power_of_gold2", "heroes/hero_alchemist/power_of_gold2.lua", LUA_MODIFIER_MOTION_NONE)

function alchemist_power_of_gold2:GetIntrinsicModifierName()
  return "modifier_hero_alchemist_power_of_gold2"
end


modifier_hero_alchemist_power_of_gold2 = class({})


function modifier_hero_alchemist_power_of_gold2:OnCreated()
    if IsServer() and not self:IsNull() then
        -- Insert new stack values
  		local gpm = PlayerResource:GetGoldPerMin(self:GetParent():GetPlayerID())
		self:SetStackCount(gpm*GameRules:GetGameTime()/60*self:GetAbility():GetSpecialValueFor("gold_percent")/100)
    Timers:CreateTimer(3,function() self:OnCreated() end)
	end
end
function modifier_hero_alchemist_power_of_gold2:OnDestroy()

end  
function modifier_hero_alchemist_power_of_gold2:IsHidden() return false end
function modifier_hero_alchemist_power_of_gold2:IsPurgable() return false end
function modifier_hero_alchemist_power_of_gold2:IsDebuff() return false end
function modifier_hero_alchemist_power_of_gold2:AllowIllusionDuplicate() return true end

function modifier_hero_alchemist_power_of_gold2:DeclareFunctions()
    local decFunc = {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}

    return decFunc
end

function modifier_hero_alchemist_power_of_gold2:GetModifierSpellAmplify_Percentage()	
 	return self:GetStackCount()--*GameRules:GetGameTime()/60*self:GetAbility():GetSpecialValueFor("gold_percent")/100
end
