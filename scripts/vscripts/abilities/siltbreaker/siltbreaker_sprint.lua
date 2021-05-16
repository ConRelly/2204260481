
siltbreaker_sprint = class({})
LinkLuaModifier( "modifier_siltbreaker_sprint", "modifiers/siltbreaker/modifier_siltbreaker_sprint", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function siltbreaker_sprint:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function siltbreaker_sprint:OnSpellStart()
	if IsServer() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_siltbreaker_sprint", { duration = self:GetSpecialValueFor( "duration" ) } )
		EmitSoundOn( "Siltbreaker.Sprint", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

