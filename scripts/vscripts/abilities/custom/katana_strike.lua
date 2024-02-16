LinkLuaModifier("modifier_katana_strike_bonus", "abilities/custom/katana_strike.lua", 0)

katana_strike = class({})

function katana_strike:OnSpellStart()
    if IsServer() then
        --self.original_target = self:GetCursorTarget()
        self.blink_distance = 100  -- Adjust as needed
        self.num_strikes = 14  -- Adjust as needed
        self.strike_interval = 0.5  -- Adjust as needed
        self.current_strikes = 0
        self:FindInitialTarget()
    end
end

function katana_strike:FindInitialTarget()
    if IsServer() then
        local caster = self:GetCaster()
        -- Check if the initial target is valid
        if self.target and not self.target:IsNull() and IsValidEntity(self.target) and self.target:IsAlive() and RollPercentage(30) then
            --self.target = initialTarget
        else
            -- If the initial target is not valid, find a new target
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for _, enemy in pairs(enemies) do
                if enemy:IsAlive() then
                    self.target = enemy
                    break
                end
            end
        end
        
        -- If a valid target is found, proceed with katana strike
        if self.target and not self.target:IsNull() and IsValidEntity(self.target) and self.target:IsAlive() then
            self:PerformKatanaStrike()
        else
            -- If no valid target is found, end the ability
            --self:EndCooldown()
        end
    end
end


function katana_strike:PerformKatanaStrike()
    if IsServer() then
        if self:GetCaster() and self:GetCaster():IsAlive() and self.current_strikes < self.num_strikes then
            local caster = self:GetCaster()
            local target = self.target
            local caster_missing_hp = caster:GetMaxHealth() - caster:GetHealth()
            local extra_dmg = self:GetSpecialValueFor("missing_hp") * caster_missing_hp * 0.01	        
            local damage = self:GetSpecialValueFor("damage") + extra_dmg
            local caster_position = caster:GetAbsOrigin()

            if target == nil or not IsValidEntity(target) or not target:IsAlive() then 
                self:FindInitialTarget()
                return
            end

            -- Perform blink effect
            local particle = "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2_sparkles.vpcf"
            local nFXIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
            ParticleManager:SetParticleControl(nFXIndex, 0, caster_position)
            ParticleManager:SetParticleControl(nFXIndex, 1, caster_position)
            ParticleManager:SetParticleControl(nFXIndex, 2, caster_position)
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        
            local center = Vector(0, 0, 0) -- Center of the map
            -- Calculate distance from the target to the center of the map
            local distanceToCenter = (target:GetAbsOrigin() - center):Length2D()

            -- Check if the distance is greater than 2900 units
            if distanceToCenter > 2300 then
                -- Calculate direction towards the center of the map
                local directionToCenter = (center - target:GetAbsOrigin()):Normalized()
                -- Set target forward vector towards the center of the map
                target:SetForwardVector(directionToCenter)
            else
                -- Set target forward vector to a random direction
                local randomDirection = Vector(RandomFloat(-1, 1), RandomFloat(-1, 1), 0):Normalized()
                target:SetForwardVector(randomDirection)   
            end



            --postion facing and blink
            local newPosition = target:GetAbsOrigin() + target:GetForwardVector() *- 120
            FindClearSpaceForUnit(caster, newPosition, false)
            caster:SetForwardVector(target:GetForwardVector() * Vector(1, 1, 0))



            -- Perform attack
            caster:PerformAttack(target, false, false, true, true, false, false, true)


            local distance = self:GetSpecialValueFor("distance")
            local knockbackProperties = {
                center_x = caster:GetAbsOrigin().x,
                center_y = caster:GetAbsOrigin().y,
                center_z = caster:GetAbsOrigin().z,
                duration = self:GetSpecialValueFor("knockback_duration"),
                knockback_duration = self:GetSpecialValueFor("knockback_duration"),
                knockback_distance = distance,
                knockback_height = 350,
                should_stun = true,
            }
            --EmitSoundOn("Hero_Tusk.WalrusKick.Target", target)
            EmitSoundOn( "Hero_MonkeyKing.TreeJump.Cast", target)
            target:AddNewModifier(caster, self, "modifier_knockback", knockbackProperties)

            -- Apply damage
            damageTable = {
                victim = target,
                attacker = caster,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self, --Optional.
            }
            ApplyDamage(damageTable)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damage, nil)

            -- Schedule next strike
            Timers:CreateTimer(self.strike_interval, function()
                self.current_strikes = self.current_strikes + 1
                self:FindInitialTarget()
            end)
        elseif self:GetCaster() and self:GetCaster():IsAlive() then
            -- After all strikes, apply damage and add modifier if needed
            if self.target == nil or not IsValidEntity(self.target) or not self.target:IsAlive() then
                self:FindInitialTarget()
                return
            end
            local caster = self:GetCaster()
            local caster_missing_hp = caster:GetMaxHealth() - caster:GetHealth()
            local extra_dmg = self:GetSpecialValueFor("missing_hp") * caster_missing_hp * 0.01	        
            local damage = self:GetSpecialValueFor("damage") + extra_dmg        
            ApplyDamage({
                victim = self.target,
                attacker = caster,
                damage = damage * 10,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            })
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damage, nil)
            caster:AddNewModifier(caster, self, "modifier_katana_strike_bonus", { duration = self:GetSpecialValueFor("duration") })
        end
    end
end



modifier_katana_strike_bonus = class({})

function modifier_katana_strike_bonus:IsHidden() return true end
function modifier_katana_strike_bonus:IsPurgable() return false end
function modifier_katana_strike_bonus:IsDebuff() return false end
function modifier_katana_strike_bonus:IsPurgeException() return true end

function modifier_katana_strike_bonus:OnCreated(params)
    if IsServer() then
        if self:GetCaster() then
            self:GetCaster():AddNoDraw()
        end
    end
end
function modifier_katana_strike_bonus:OnDestroy()
    if IsServer() then
        if self:GetCaster() then
            self:GetCaster():RemoveNoDraw()
        end
    end
end

function modifier_katana_strike_bonus:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true
    }
end
