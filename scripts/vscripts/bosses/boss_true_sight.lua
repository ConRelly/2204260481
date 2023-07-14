
LinkLuaModifier("modifier_boss_truesight_aura", "bosses/boss_true_sight.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("boss_truesight_modifier", "bosses/boss_true_sight.lua", LUA_MODIFIER_MOTION_NONE)

modifier_boss_truesight_aura = class({})

function boss_truesight_aura:OnCreated()
  self.pulse_interval = 30 -- seconds
  self.pulse_duration = 7 -- seconds
  self.aura_radius = 7200

  self.pulse_timer = 0

  if IsServer() then
    self:StartIntervalThink(1)
  end
end

function boss_truesight_aura:OnIntervalThink()
  self.pulse_timer = self.pulse_timer + 1
  
  if self.pulse_timer >= self.pulse_interval then
    self.pulse_timer = 0
    
    local caster = self:GetCaster()
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, self.aura_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    for _,enemy in pairs(enemies) do
      enemy:AddNewModifier(caster, self, "boss_truesight_modifier", {duration = self.pulse_duration}) 
    end
  end
end

boss_truesight_modifier = class({})

function boss_truesight_modifier:IsHidden()
  return true 
end

function boss_truesight_modifier:CheckState()
  return {[MODIFIER_STATE_INVISIBLE] = false}
end 

function boss_truesight_modifier:GetPriority()
  return 10 -- very high priority
end