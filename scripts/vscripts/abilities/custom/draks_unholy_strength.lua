LinkLuaModifier("modifier_draks_unholy_strength", "abilities/custom/draks_unholy_strength.lua", LUA_MODIFIER_MOTION_NONE)

draks_unholy_strength = class({})

function draks_unholy_strength:GetIntrinsicModifierName()
    return "modifier_draks_unholy_strength"
end

modifier_draks_unholy_strength = class({})

function modifier_draks_unholy_strength:IsHidden() return true end
function modifier_draks_unholy_strength:IsPurgable() return false end

function modifier_draks_unholy_strength:DeclareFunctions()
  return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
end

function modifier_draks_unholy_strength:GetModifierConstantHealthRegen()
  local regen = -90000 --self:GetAbility():GetSpecialValueFor("bonus_health_regen")
  --if self:GetCaster():HasScepter() then

  regen = regen + (GameRules:GetGameTime() / 60) * self:GetAbility():GetSpecialValueFor("scepter_regen_per_minute")
  if GameRules:GetGameTime() > 0 then
  end
  if regen < 0 then 
    regen = 1
  end  
  --end
  return math.floor(regen)
end

function modifier_draks_unholy_strength:GetModifierTotalDamageOutgoing_Percentage()
  local bonus = -720
  bonus = bonus + (GameRules:GetGameTime() / 60) * 8
  if GameRules:GetGameTime() > 0 then
  end
  if bonus < 0 then 
    bonus = 1
  end  
  return math.floor(bonus)
end

function modifier_draks_unholy_strength:GetModifierHPRegenAmplify_Percentage()
  local bonus_reg = -90
  bonus_reg = bonus_reg + (GameRules:GetGameTime() / 60) * 1
  if GameRules:GetGameTime() > 0 then
  end
  if bonus_reg < 0 then 
    bonus_reg = 1
  end  
  return math.floor(bonus_reg)
end

function modifier_draks_unholy_strength:GetModifierHealAmplify_PercentageTarget()
  local bonus_lifestel = -90
  bonus_lifestel = bonus_lifestel + (GameRules:GetGameTime() / 60) * 1
  if GameRules:GetGameTime() > 0 then
  end
  if bonus_lifestel < 0 then 
    bonus_lifestel = 1
  end  
  return math.floor(bonus_lifestel)
end

function modifier_draks_unholy_strength:GetModifierPercentageCooldown()
  local cdr = -100
  cdr = cdr + (GameRules:GetGameTime() / 60) * 1
  if GameRules:GetGameTime() > 0 then
  end
  if cdr < 0 then 
    cdr = 1
  end 
  if cdr > 90 then
    cdr = 90
  end   
  return math.floor(cdr)
end

function modifier_draks_unholy_strength:GetModifierMoveSpeed_AbsoluteMin() 
  local ms = 100
  ms = ms + (GameRules:GetGameTime() / 60) * 3
  if GameRules:GetGameTime() > 0 then
  end
  if ms > 520 then
    ms = 520
  end   
  return ms
end