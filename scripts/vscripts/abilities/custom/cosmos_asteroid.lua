
cosmos_asteroid = class({})

function cosmos_asteroid:GetAOERadius()
    return self:GetSpecialValueFor("impact_radius")
end

function cosmos_asteroid:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local radius = self:GetSpecialValueFor("impact_radius")
        local strike_zone = self:GetSpecialValueFor("strike_zone_radius")
        local num_meteors = self:GetSpecialValueFor("num_meteors")
        local interval = 0.5
        local land_time = self:GetSpecialValueFor("land_time")
		local caster_missing_hp = caster:GetMaxHealth() - caster:GetHealth()
		local extra_dmg = self:GetSpecialValueFor("missing_hp") * caster_missing_hp * 0.01	        
        local damage = self:GetSpecialValueFor("impact_damage") + extra_dmg
        local stun_duration = self:GetSpecialValueFor("stun_duration")
        local stun_duration_2 = stun_duration * 2

        for i = 1, num_meteors do
            Timers:CreateTimer((i - 1) * interval, function()
                local random_radius = RandomFloat(0, strike_zone)
                local random_angle = RandomFloat(0, 360)
                local random_offset = Vector(math.cos(math.rad(random_angle)), math.sin(math.rad(random_angle)), 0) * random_radius
                local location = caster:GetAbsOrigin() + random_offset

                local meteor_particle = ParticleManager:CreateParticle("particles/stygian/cosmos_asteroid.vpcf", PATTACH_WORLDORIGIN, caster)
                ParticleManager:SetParticleControl(meteor_particle, 0, location + Vector(radius, 0, 1000))
                ParticleManager:SetParticleControl(meteor_particle, 1, location)
                ParticleManager:SetParticleControl(meteor_particle, 2, Vector(land_time, 0, 0))
                ParticleManager:ReleaseParticleIndex(meteor_particle)

                Timers:CreateTimer(land_time, function()
                    GridNav:DestroyTreesAroundPoint(location, radius, false)

                    local nFXIndex = ParticleManager:CreateParticle("particles/stygian/cosmos_asteroid_stomp_magical.vpcf", PATTACH_WORLDORIGIN, caster)
                    ParticleManager:SetParticleControl(nFXIndex, 0, location)
                    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(radius, radius, 0))
                    ParticleManager:ReleaseParticleIndex(nFXIndex)

                    EmitSoundOnLocationWithCaster(location, "Hero_ElderTitan.EchoStomp", caster)
                    EmitSoundOnLocationWithCaster(location, "Hero_ShadowDemon.ShadowPoison.Impact", caster)

                    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                        location,
                        nil,
                        radius,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false)

                    for _, enemy in pairs(enemies) do
                        
                        enemy:EmitSound("")

                        local impactDamage = damage

                        local damageTable = {
                            victim = enemy,
                            damage = impactDamage/2,
                            damage_type = DAMAGE_TYPE_PURE,
                            damage_flags = DOTA_DAMAGE_FLAG_NONE,
                            attacker = caster,
                            ability = self
                        }

                        ApplyDamage(damageTable)

                        local damageTable = {
                            victim = enemy,
                            damage = impactDamage/2,
                            damage_type = DAMAGE_TYPE_MAGICAL,
                            damage_flags = DOTA_DAMAGE_FLAG_NONE,
                            attacker = caster,
                            ability = self
                        }  
                        ApplyDamage(damageTable)                      
                       -- local duration_dummy = enemy:HasModifier("modifier_cosmos_space_mist_debuff") and stun_duration_2 or stun_duration
                        local duration_dummy = 0
                        if enemy:HasModifier("modifier_cosmos_space_mist_debuff") then
                            duration_dummy = stun_duration_2
                        else
                            duration_dummy = stun_duration
                        end  
                                              
                        enemy:AddNewModifier(caster, self, "modifier_stunned", { duration = duration_dummy })
                    end
                end)
            end)
        end
    end
end

