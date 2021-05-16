LinkLuaModifier("modifier_bear_bonus", "abilities/custom/lone_druid_spirit_bear_entangle2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sumon_bonus", "abilities/custom/summon_defense.lua", LUA_MODIFIER_MOTION_NONE)

lone_druid_spirit_bear_entangle2 = class({})
summon_defense = lone_druid_spirit_bear_entangle2

function lone_druid_spirit_bear_entangle2:GetIntrinsicModifierName()
    return "modifier_bear_bonus"
end

modifier_bear_bonus = class({})

function modifier_bear_bonus:IsHidden() return false end
function modifier_bear_bonus:IsPurgable() return false end
function modifier_bear_bonus:GetTexture() return "bear_bonus" end

function modifier_bear_bonus:DeclareFunctions()
  return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, }
end

--[[function modifier_bear_bonus:GetModifierConstantHealthRegen()
  local regen = -30000 --self:GetAbility():GetSpecialValueFor("bonus_health_regen")
  --if self:GetCaster():HasScepter() then
  regen = regen + (GameRules:GetGameTime() / 60) * self:GetAbility():GetSpecialValueFor("scepter_regen_per_minute")
  if GameRules:GetGameTime() > 0 then
  end
  --end
  return regen
end]]

function modifier_bear_bonus:GetModifierIncomingDamage_Percentage()
  local bonus = 45
  bonus = (bonus + (GameRules:GetGameTime() / 60)) * (-1) 
  if GameRules:GetGameTime() > 0 then
  end
  if bonus < -90 then 
    bonus = -90
  end  
  return bonus
end
