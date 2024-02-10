cosmos_first_fundamental = class({})

--------------------------------------------------------------------------------

function cosmos_first_fundamental:OnSpellStart()
     if IsServer() then
          local radius = self:GetSpecialValueFor( "radius" ) 
          local duration = self:GetSpecialValueFor(  "stun_duration" )
          local caster = self:GetCaster()
          local distance1 = self:GetSpecialValueFor( "knockback_distance" )
          local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
          local caster_missing_hp = caster:GetMaxHealth() - caster:GetHealth()
          local extra_dmg = self:GetSpecialValueFor("missing_hp") * caster_missing_hp * 0.01	        
          local damage = self:GetAbilityDamage() + extra_dmg
          if #units > 0 then
               for _,unit in pairs(units) do
                    unit:SetAbsOrigin(caster:GetAbsOrigin())
                    
                    FindClearRandomPositionAroundUnit(unit, caster, math.random(200))

                    Timers:CreateTimer(0, function()
                         if unit:IsNull() or not unit:IsAlive() then return end
                         local distance = RandomInt(distance1, distance1*2)
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
                         unit:AddNewModifier( caster, self, "modifier_stunned", { duration = duration } ) 
                         unit:AddNewModifier(caster, self, "modifier_knockback", knockbackProperties)
    
                         ApplyDamage({
                              victim = unit,
                              attacker = caster,
                              damage = damage,
                              damage_type = DAMAGE_TYPE_PURE,
                              ability = self
                         })
                     end)                    
                    EmitSoundOn( "Hero_Wisp.Return", unit )
                    EmitSoundOn("Hero_ObsidianDestroyer.EssenceAura", unit)
               end
          end

          local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/monkey_king/arcana/water/monkey_king_spring_cast_water_ground.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
          ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
          ParticleManager:ReleaseParticleIndex( nFXIndex )

          EmitSoundOn( "Hero_Wisp.Return", self:GetCaster() )
     end
end
