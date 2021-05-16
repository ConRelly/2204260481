
local MAIN_ABILITY_NAME = "mjz_abyssal_underlord_dark_rift"
local SUB_ABILITY_NAME = 'mjz_abyssal_underlord_dark_rift_cancel'
local ABILITY_SOUND = "Hero_AbyssalUnderlord.DarkRift.Cast" 


modifier_mjz_abyssal_underlord_dark_rift_caster = class({})
local modifier_class = modifier_mjz_abyssal_underlord_dark_rift_caster

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:IsBuff() return true end


if IsServer() then
	function modifier_class:OnCreated(table)
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local originParent = parent:GetAbsOrigin()
		local radius = ability:GetSpecialValueFor('radius')

		-- play the sound
		parent:EmitSound( ABILITY_SOUND )

		local p_name = "particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( p_name, PATTACH_ABSORIGIN_FOLLOW, parent )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetOrigin(), true )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius, radius, 1) )
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 5, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 20, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetOrigin(), true )

		self.particle = nFXIndex
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

		caster:SwapAbilities( main_ability_name, SUB_ABILITY_NAME, true, false )
	end

	function modifier_class:_EndSinging()
		local parent = self:GetParent()
		local originParent = parent:GetAbsOrigin()

		-- stop the sound
		parent:StopSound( ABILITY_SOUND )

		EmitSoundOn( "Hero_AbyssalUnderlord.DarkRift.Complete", self:GetCaster() )

		-- delete the active particle
		if self.particle then
			ParticleManager:DestroyParticle( self.particle, false )
			ParticleManager:ReleaseParticleIndex( self.particle )
		end
	end

end
