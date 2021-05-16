LinkLuaModifier("modifier_sumon_bonus", "abilities/custom/summon_defense.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bear_bonus", "abilities/custom/lone_druid_spirit_bear_entangle2.lua", LUA_MODIFIER_MOTION_NONE)

summon_defense = class({})

function summon_defense:GetIntrinsicModifierName()
  return "modifier_sumon_bonus"
end

modifier_sumon_bonus = class({})

function modifier_sumon_bonus:IsHidden() return false end
function modifier_sumon_bonus:IsPurgable() return false end
function modifier_sumon_bonus:OnCreated()
  if IsServer() then
    local parent = self:GetParent()
    local modif = "modifier_bear_bonus"
    if not parent:HasModifier(modif) then
      parent:AddNewModifier(parent, self, modif, {duration = 8})
    end
  end   
end  
function modifier_sumon_bonus:OnDestroy()

end 

function modifier_sumon_bonus:DeclareFunctions()
  return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, }
end



function modifier_sumon_bonus:GetModifierIncomingDamage_Percentage()
  local bonus = 25
  bonus = (bonus + (GameRules:GetGameTime() / 60)) * (-1) 
  if bonus < -80 then 
    bonus = -80
  end  
  return bonus
end
