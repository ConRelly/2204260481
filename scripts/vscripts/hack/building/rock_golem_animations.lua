
-- rock_golem_animations = class({})

-- LinkLuaModifier("modifier_rock_golem_animations", "abilities/building/rock_golem_animations", LUA_MODIFIER_MOTION_NONE)

-- function rock_golem_animations:GetIntrinsicModifierName()
--   return "modifier_rock_golem_animations"
-- end

modifier_rock_golem_animations = class({})

function modifier_rock_golem_animations:IsHidden() return true end

function modifier_rock_golem_animations:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_START,
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_rock_golem_animations:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_rock_golem_animations:GetOverrideAnimation()
  return ACT_DOTA_CUSTOM_TOWER_IDLE
end

function modifier_rock_golem_animations:OnCreated()
  if not IsServer() then return end

  self.rotating = false
  self.target = nil
  self.parent = self:GetParent()

  local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf", PATTACH_ABSORIGIN, self:GetParent())
  ParticleManager:ReleaseParticleIndex(pfx)

  -- self:SetStackCount(self:GetCaster():GetTeamNumber()) --??
end

function sign(value)
  if value < 0 then return -1 end
  if value > 0 then return 1 end
  return 0
end

-- Don't litter global namesapce
function modifier_rock_golem_animations:GetTrackingInterval()
  return 1/30 --Somewhere in building helper, it's told server fps is 30
end

function modifier_rock_golem_animations:ShouldEndTracking()
  if not self.target:IsAlive() then
    self.target = nil
    return
  end
  return self:GetTrackingInterval()
end

function modifier_rock_golem_animations:TrackTarget()
  if not IsServer() then return end
  if not self.target then return end

  -- Keep tracking as long as we should and can, to try to finish movement so it looks natural
  if not IsValidEntity(self.target) then
    self.target = nil
    return
  end

  if not IsValidEntity(self.parent) then
    return
  end
  

  local rotationSpeed = 360 / (1 / self:GetTrackingInterval()) -- Do a full flip per 1 second
  local angleTolerance = 0.25 -- Target location can slightly fluctuate for some reason, causing useless updates

  local parent = self:GetParent()

  local desiredForwardVector = self.target:GetAbsOrigin() - parent:GetAbsOrigin()
  local myForwardVector = parent:GetForwardVector()
  local desiredYaw = VectorToAngles(desiredForwardVector).y
  local myYaw = VectorToAngles(myForwardVector).y

  -- Find shortest path
  local currentPathLength = math.abs(myYaw - desiredYaw)
  if math.abs(myYaw - (desiredYaw - 360)) < currentPathLength then
    desiredYaw = desiredYaw - 360
  elseif math.abs(myYaw - (desiredYaw + 360)) < currentPathLength then
    desiredYaw = desiredYaw + 360
  end

  if math.abs(myYaw - desiredYaw) <= angleTolerance then
    return self:ShouldEndTracking()
  end

  local direction = (desiredYaw > myYaw) and 1 or -1
  local newYaw = myYaw + rotationSpeed * direction
  if sign(newYaw - desiredYaw) == direction then -- if we got to target value and beyond
    parent:SetAngles(0, desiredYaw, 0)
    return self:ShouldEndTracking()
  else
    parent:SetAngles(0, newYaw, 0)
    return self:GetTrackingInterval()
  end
end

function modifier_rock_golem_animations:OnAttackStart(keys)
  if not IsServer() then return end

  if keys.attacker == self:GetParent() then
    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CUSTOM_TOWER_ATTACK, self:GetParent():GetAttacksPerSecond())

    -- If no track target, setup target and start tracking
    -- Do first update now, the rest on demand
    -- Else only update target
    if not self.target then
      self.target = keys.target
      local tilNextUpdate = self:TrackTarget()
      if tilNextUpdate then
        Timers:CreateTimer(tilNextUpdate, function ()
          return self:TrackTarget()
        end)
      end
    else
      self.target = keys.target
    end
  end
end

function modifier_rock_golem_animations:OnDeath(keys)
  if not IsServer() then return end

  if keys.unit == self:GetParent() then
    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CUSTOM_TOWER_DIE, 0.75)
  end
end
