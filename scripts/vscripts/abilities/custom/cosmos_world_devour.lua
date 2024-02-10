if cosmos_world_devour == nil then cosmos_world_devour = class({}) end



function cosmos_world_devour:GetBehavior()
  return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function cosmos_world_devour:GetCooldown( nLevel )
  return self.BaseClass.GetCooldown( self, nLevel )
end

function cosmos_world_devour:OnSpellStart()
  if IsServer() then
    self:CreateExplosion(self:GetCaster())
    local distance1 = self:GetSpecialValueFor( "knockback_distance" )
    local caster = self:GetCaster()
    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    if #units > 0 then
      for _,target in pairs(units) do
        target:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self:GetSpecialValueFor("duration") } )
        local caster_missing_hp = caster:GetHealthDeficit()
        local extra_dmg = self:GetSpecialValueFor("missing_hp") * caster_missing_hp * 0.01       
        local dmg = self:GetAbilityDamage() + (target:GetMaxHealth() * (self:GetSpecialValueFor("damage") / 100)) + extra_dmg
        local dmg2 = self:GetAbilityDamage() + target:GetMaxMana() + (extra_dmg * 5)
       
        

        caster:Heal(dmg2, target)
        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true );
        ParticleManager:DestroyParticle(nFXIndex, false)
        ParticleManager:ReleaseParticleIndex( nFXIndex );


        FindClearRandomPositionAroundUnit(target, caster, math.random(200))

        Timers:CreateTimer(0.1, function()
          if target:IsNull() or not target:IsAlive() then return end
          local distance = RandomInt(150, distance1*2)
          local knockbackProperties = {
               center_x = caster:GetAbsOrigin().x,
               center_y = caster:GetAbsOrigin().y,
               center_z = caster:GetAbsOrigin().z,
               duration = self:GetSpecialValueFor("knockback_duration"),
               knockback_duration = self:GetSpecialValueFor("knockback_duration"),
               knockback_distance = distance,
               knockback_height = 150,
               should_stun = true,
           } 
           target:AddNewModifier(caster, self, "modifier_knockback", knockbackProperties)

          ApplyDamage({
               victim = target,
               attacker = caster,
               damage = dmg,
               damage_type = DAMAGE_TYPE_PURE,
               ability = self
          })
        end)       
      end
    end

    --FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetAbsOrigin(), true)
  end
end

function cosmos_world_devour:CreateExplosion(caster)

  local nFXIndex = ParticleManager:CreateParticle( "particles/galactus/galactus_seed_of_ambition_eternal_item.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
  ParticleManager:SetParticleControl(nFXIndex, 0, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(nFXIndex, 2, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(nFXIndex, 3, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(nFXIndex, 6, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl (nFXIndex, 1, Vector (1500, 1500, 0))
  ParticleManager:DestroyParticle(nFXIndex, false)
  ParticleManager:ReleaseParticleIndex( nFXIndex )
  caster:EmitSound("PudgeWarsClassic.echo_slam")
  caster:EmitSound("PudgeWarsClassic.echo_slam")
  caster:EmitSound("PudgeWarsClassic.echo_slam")
  EmitSoundOn( "Hero_ObsidianDestroyer.SanityEclipse.TI8", self:GetCaster() )
  ScreenShake( caster:GetOrigin(), 600, 600, 2, 9999, 0, true)
  self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_3 );


--[[   local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start.vpcf", PATTACH_WORLDORIGIN, nil )
  ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )

  local explosion5 = ParticleManager:CreateParticle("particles/effects/echo_slam.vpcf", PATTACH_WORLDORIGIN, caster)
  ParticleManager:SetParticleControl(explosion5, 0, caster:GetAbsOrigin() + Vector(0, 0, 1))
  ParticleManager:SetParticleControl(explosion5, 1, caster:GetAbsOrigin() + Vector(0, 0, 1))
  ParticleManager:SetParticleControl (explosion5, 2, Vector (1500, 1500, 0))
  ParticleManager:SetParticleControl(explosion5, 3, caster:GetAbsOrigin() + Vector(0, 0, 1))
  ParticleManager:SetParticleControl(explosion5, 4, caster:GetAbsOrigin() + Vector(0, 0, 1))
  ParticleManager:SetParticleControl (explosion5, 5, Vector (1500, 1500, 0))

  caster:EmitSound("PudgeWarsClassic.echo_slam")
  caster:EmitSound("PudgeWarsClassic.echo_slam")
  caster:EmitSound("PudgeWarsClassic.echo_slam")

  

  EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_EarthShaker.EchoSlamSmall", self:GetCaster() )
  ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 1, 1 ) ) ]]
end

