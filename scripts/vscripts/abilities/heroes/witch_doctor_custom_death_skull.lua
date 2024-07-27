require("lib/timers")
require("lib/my")

witch_doctor_custom_death_skull = class({})
if IsServer() then
    function witch_doctor_custom_death_skull:OnSpellStart()
        self.caster = self:GetCaster()
        self.velocity = self:GetSpecialValueFor("velocity")
        self.offset = self:GetSpecialValueFor("offset")
        self.damage = self:GetSpecialValueFor("damage")
        self.int_as_damage = (self:GetSpecialValueFor("int_as_damage") * 0.01) * self.caster:GetIntellect(false)
        self.interval = self:GetSpecialValueFor("interval")
		self.mult_dmg = 1
		if _G._challenge_bosss > 0 then
			for i = 1, _G._challenge_bosss do
				self.mult_dmg = self.mult_dmg * 1.1
			end 
		end		
		self.total_damage = (self.damage + self.int_as_damage) * self.mult_dmg
        if self.caster:HasScepter() then
            local aps = 1 / self.caster:GetAttacksPerSecond(false)
            self.interval = math.min(self.interval, aps)
        end

        local talent = self.caster:FindAbilityByName("witch_doctor_custom_bonus_unique_1")
        if talent and talent:GetLevel() > 0 then
            self.interval = self.interval / talent_value(self.caster, "witch_doctor_custom_bonus_unique_1")
        end

        self.accumulated_time = 0.0
        self.target_location = self:GetCursorPosition()
        self.direction = self.target_location - self:GetCaster():GetOrigin()

        -- Check for auto-fire condition
        if self.caster:HasModifier("modifier_hero_totem_buff") and
           	self.caster:GetModifierStackCount("modifier_hero_totem_buff", self.caster) > 19 then
            self:StartAutoFire()
        else
            self:LaunchSkull(self.direction:Normalized())
        end
    end

    function witch_doctor_custom_death_skull:OnChannelThink(flInterval)
        if not self.is_auto_firing then
            self.accumulated_time = self.accumulated_time + flInterval
            if self.accumulated_time >= self.interval then
                self.accumulated_time = self.accumulated_time - self.interval

                local target_pos = self.target_location + RandomVector(self.offset)
                local direction = self:FindClosestEnemyDirection()

                if direction then
                	self:LaunchSkull(direction)
				end
            end
        end
    end

    function witch_doctor_custom_death_skull:OnProjectileHit(target, pos)
        if target ~= nil and not target:IsInvulnerable() then
            local damage = self.total_damage

            ApplyDamage({
                ability = self,
                attacker = self.caster,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                victim = target
            })
            EmitSoundOn("Hero_WitchDoctor_Ward.Attack", target)
        end
        return true
    end

    function witch_doctor_custom_death_skull:LaunchSkull(direction)
        local direction_2d = (direction * Vector(1, 1, 0)):Normalized()
        local dist = self:GetCastRange(self:GetCaster():GetOrigin(), self:GetCaster()) + self:GetCaster():GetCastRangeBonus()
        
        ProjectileManager:CreateLinearProjectile({
            EffectName = "particles/custom/abilities/heroes/witch_doctor_death_skull/wd_death_skull.vpcf",
            Ability = self,
            vSpawnOrigin = self:GetCaster():GetOrigin(),
            fStartRadius = 100,
            fEndRadius = 100,
            vVelocity = direction_2d * self.velocity,
            fDistance = dist,
            Source = self:GetCaster(),
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            bDeleteOnHit = true,
            fExpireTime = GameRules:GetGameTime() + (dist / self.velocity)
        })
        self.caster:EmitSound("Hero_WitchDoctor_Ward.Attack")
    end

    function witch_doctor_custom_death_skull:StartAutoFire()
        self.is_auto_firing = true
        self.caster:Stop()
        self:UseResources(false, false, false, true) -- Set the cooldown

        local auto_fire_duration = 10
        local cooldown_time = 15

        -- Set cooldown
        self:StartCooldown(cooldown_time)

        -- Start auto-fire
        local end_time = GameRules:GetGameTime() + auto_fire_duration
        Timers:CreateTimer(function()
            if GameRules:GetGameTime() > end_time or not self.caster:IsAlive() then
                self.is_auto_firing = false
                return nil
            end

            local direction = self:FindClosestEnemyDirection()

            if direction then
                self:LaunchSkull(direction)
            end

            return self.interval
        end)
    end

    -- Helper function to find the closest enemy (for Option 2)
    function witch_doctor_custom_death_skull:FindClosestEnemyDirection()
        local caster_pos = self.caster:GetOrigin()
        local search_radius = self:GetCastRange(caster_pos, self.caster) + self.caster:GetCastRangeBonus()
        local enemies = FindUnitsInRadius(
            self.caster:GetTeamNumber(),
            caster_pos,
            nil,
            search_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false
        )

        if #enemies > 0 then
            return (enemies[1]:GetOrigin() - caster_pos):Normalized()
        end
        return nil
    end
end