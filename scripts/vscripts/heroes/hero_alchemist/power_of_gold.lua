
alchemist_power_of_gold = class({})

LinkLuaModifier("modifier_hero_alchemist_power_of_gold", "heroes/hero_alchemist/power_of_gold", LUA_MODIFIER_MOTION_NONE)

function alchemist_power_of_gold:GetIntrinsicModifierName()
  return "modifier_hero_alchemist_power_of_gold"
end


modifier_hero_alchemist_power_of_gold = class({})


function modifier_hero_alchemist_power_of_gold:OnCreated()
  if IsServer() and not self:IsNull() then
        -- Insert new stack values
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local gold_ptc = ability:GetSpecialValueFor("gold_percent")/100
    if parent and not parent:IsNull() and IsValidEntity(parent) then 
      local gpm = PlayerResource:GetGoldPerMin(self:GetParent():GetPlayerID())
      local bonus_dmg = math.ceil(gpm * (GameRules:GetGameTime() / 60) * gold_ptc)
      self:SetStackCount(bonus_dmg)
      Timers:CreateTimer(3,
      function()
        if not parent:IsNull() and IsValidEntity(parent) then
          self:OnCreated()
        end 
      end)
    end  
	end
end
function modifier_hero_alchemist_power_of_gold:OnDestroy()

end  
function modifier_hero_alchemist_power_of_gold:IsHidden() return true end
function modifier_hero_alchemist_power_of_gold:IsPurgable() return false end
function modifier_hero_alchemist_power_of_gold:IsDebuff() return false end
function modifier_hero_alchemist_power_of_gold:AllowIllusionDuplicate() return true end

function modifier_hero_alchemist_power_of_gold:DeclareFunctions()
    local decFunc = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}

    return decFunc
end

function modifier_hero_alchemist_power_of_gold:GetModifierPreAttack_BonusDamage()	
 	return self:GetStackCount()
end
