LinkLuaModifier("modifier_boss_truesight_aura", "bosses/boss_true_sight.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_truesight", "bosses/boss_true_sight.lua", LUA_MODIFIER_MOTION_NONE)

modifier_boss_truesight_aura = class({})
boss_truesight_aura = modifier_boss_truesight_aura

function boss_truesight_aura:IsHidden() return true end
function boss_truesight_aura:IsPurgable() return false end


function boss_truesight_aura:OnCreated()
  self.pulse_duration = 7 -- seconds
  self.aura_radius = 7200

  self.pulse_timer = 0

  if IsServer() then
    self:StartIntervalThink(30)
  end
end

function boss_truesight_aura:OnIntervalThink()
  local caster = self:GetCaster()
  local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, self.aura_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  for _,enemy in pairs(enemies) do
    enemy:AddNewModifier(caster, self, "modifier_boss_truesight", {duration = self.pulse_duration}) 
  end
end

modifier_boss_truesight = class({})


function modifier_boss_truesight:IsHidden() return false end
function modifier_boss_truesight:IsPurgable() return false end
function modifier_boss_truesight:IsDebuff() return true end
function modifier_boss_truesight:GetTexture() return "eye_true" end

function modifier_boss_truesight:CheckState()
  if IsServer() then
    local parent = self:GetParent()
    if parent:HasModifier("modifier_phantom_assassin_blur_active") then
      parent:RemoveModifierByName("modifier_phantom_assassin_blur_active")
    end
  end

  return {
    [MODIFIER_STATE_INVISIBLE] = false,
    [MODIFIER_STATE_TRUESIGHT_IMMUNE] = false,
  }
end

function modifier_boss_truesight:GetPriority()
  return MODIFIER_PRIORITY_SUPER_ULTRA + 10000 -- very high priority
end