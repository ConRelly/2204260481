require("lib/timers")
require("lib/my")


witch_doctor_custom_death_skull = class({})
if IsServer() then
	function witch_doctor_custom_death_skull:OnSpellStart()
		self.caster = self:GetCaster()
        self.velocity = self:GetSpecialValueFor("velocity")
        self.offset = self:GetSpecialValueFor("offset")
		self.range = self:GetSpecialValueFor("range")
		self.damage = self:GetSpecialValueFor("damage")
		self.int_as_damage = self:GetSpecialValueFor("int_as_damage") * 0.01
		self.interval = self:GetSpecialValueFor("interval")

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

        self:LaunchSkull(self.direction:Normalized())
    end
    function witch_doctor_custom_death_skull:OnChannelThink(flInterval)
        self.accumulated_time = self.accumulated_time + flInterval
        if self.accumulated_time >= self.interval then
            self.accumulated_time = self.accumulated_time - self.interval

			local target_pos = self.target_location + RandomVector(self.offset)
            local direction = (target_pos - self:GetCaster():GetOrigin()):Normalized()
            --local direction = (direction * Vector(1, 1, 0)):Normalized()
            self:LaunchSkull(direction)
        end
    end
    function witch_doctor_custom_death_skull:OnProjectileHit(target, pos)
        if target ~= nil and not target:IsInvulnerable() then
			
			local damage = self.damage + (self.int_as_damage * self.caster:GetIntellect(true))

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
        ProjectileManager:CreateLinearProjectile({
			EffectName = "particles/custom/abilities/heroes/witch_doctor_death_skull/wd_death_skull.vpcf",
			Ability = self,
			vSpawnOrigin = self:GetCaster():GetOrigin(),
			fStartRadius = 100,
			fEndRadius = 100,
			vVelocity = direction * self.velocity,
			fDistance = self:GetCastRange(self:GetCaster():GetOrigin(), self:GetCaster()),
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bDeleteOnHit = true,
		})
		self.caster:EmitSound("Hero_WitchDoctor_Ward.Attack")
    end
end
