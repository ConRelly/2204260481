
mjz_puck_ethereal_jaunt = class({})
local ability_class = mjz_puck_ethereal_jaunt

function ability_class:OnSpellStart()
    if IsServer() then
        -- get first index projectile
        local first = false
        for k,v in pairs(self.projectiles) do
            first = k
            break
        end
        if not first then return end

        -- find oldest projectile
        for idx,projectile in pairs(self.projectiles) do
            if projectile.time < self.projectiles[first].time then
                first = idx
            end
        end

        -- jump to oldest
        local old_pos = self:GetCaster():GetOrigin()
        FindClearSpaceForUnit( self:GetCaster(), ProjectileManager:GetLinearProjectileLocation( first ), true )
        ProjectileManager:ProjectileDodge( self:GetCaster() )

        -- destroy the oldest
        ProjectileManager:DestroyLinearProjectile( first )
        self.projectiles[first].modifier:Destroy()
        self.projectiles[first] = nil
        self:Deactivate()

        -- effects
        self:PlayEffects( old_pos )
    end
end

function ability_class:Deactivate()
	local any = false
	for k,v in pairs(self.projectiles) do
		any = true
		break
	end
	if not any then
		self:SetActivated( false )
	end
end

function ability_class:PlayEffects( point )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_puck/puck_illusory_orb_blink_out.vpcf"
	local sound_cast = "Hero_Puck.EtherealJaunt"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
    ParticleManager:DestroyParticle(effect_cast, false)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end