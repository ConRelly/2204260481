
local sub_ability_name = 'mjz_naga_siren_song_of_the_siren_cancel'

modifier_mjz_naga_siren_song_of_the_siren_caster = class({})
local modifier_class = modifier_mjz_naga_siren_song_of_the_siren_caster

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:IsBuff() return true end


if IsServer() then
	function modifier_class:OnCreated(table)
		local parent = self:GetParent()
		local originParent = parent:GetAbsOrigin()

		-- play the sound
		parent:EmitSound( "Hero_NagaSiren.SongOfTheSiren" )

		-- play the start up particle
		local part = ParticleManager:CreateParticle( "particles/units/heroes/hero_siren/naga_siren_siren_song_cast.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( part, 0, originParent )
		ParticleManager:ReleaseParticleIndex( part )

		-- create the "effect active" particle
		-- doing it this way so we can set up a custom attach point
		self.partAura = ParticleManager:CreateParticle( "particles/units/heroes/hero_siren/naga_siren_song_aura.vpcf", PATTACH_POINT_FOLLOW, parent )
		ParticleManager:SetParticleControlEnt( self.partAura, 0, parent, PATTACH_POINT_FOLLOW, "attach_mouth", originParent, true )
	end

	function modifier_class:OnDestroy()
		self:_SwapAbilities()
		self:_EndSinging()
	end

	function modifier_class:_SwapAbilities( )
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		-- Swap the sub_ability back to normal
		local main_ability_name = ability:GetAbilityName()
		-- local sub_ability_name = 'mjz_naga_siren_song_of_the_siren_cancel'

		caster:SwapAbilities( main_ability_name, sub_ability_name, true, false )
	end

	function modifier_class:_EndSinging()
		local parent = self:GetParent()
		local originParent = parent:GetAbsOrigin()

		-- stop the sound
		parent:StopSound( "Hero_NagaSiren.SongOfTheSiren" )

		-- delete the active particle
		if self.partAura then
			ParticleManager:DestroyParticle( self.partAura, false )
			ParticleManager:ReleaseParticleIndex( self.partAura )
		end

		-- create the end particle
		local part = ParticleManager:CreateParticle( "particles/units/heroes/hero_siren/naga_siren_siren_song_end.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( part, 0, originParent )
		ParticleManager:ReleaseParticleIndex( part )
	end
end
