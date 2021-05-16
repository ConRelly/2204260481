blood_fiesta = class({})

function blood_fiesta:OnAbilityPhaseStart()
	self:PlayEffects1()
	if _G.hardmode then
		dur = nil
	else
		dur = 2
	end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_black_king_bar_immune", { duration = dur })
	return true
end
function blood_fiesta:OnAbilityPhaseInterrupted()
	self:StopEffects1( false )
	self:GetCaster():RemoveModifierByName("modifier_black_king_bar_immune")
end

function blood_fiesta:OnSpellStart()
	local soul_per_line = 1
	local lines = 0
	local modifier = 20
	if modifier~=nil then
		lines = math.floor(20 / soul_per_line)
	end
	self:Explode( lines )
end

function blood_fiesta:OnProjectileHit_ExtraData( hTarget, vLocation, params )
	if hTarget ~= nil then
		pass = false
		if hTarget:GetTeamNumber()~=self:GetCaster():GetTeamNumber() then
			pass = true
		end
		if pass then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_nevermore_requiem_fear", { duration = self.duration })
		end
	end
	return false
end

function blood_fiesta:Explode( lines )
	self.damage =  self:GetAbilityDamage()
	self.duration = self:GetSpecialValueFor("fear_duration")
	if _G.hardmode then
		self.duration = self.duration * 1.5
	end
	local particle_line = "particles/custom/abilities/blood_fiesta/blood_fiesta.vpcf"
	local line_length = self:GetSpecialValueFor("radius")
	local width_start = self:GetSpecialValueFor("fiesta_line_width_start")
	local width_end = self:GetSpecialValueFor("fiesta_line_width_end")
	local line_speed = self:GetSpecialValueFor("fiesta_line_speed")
	local initial_angle_deg = self:GetCaster():GetAnglesAsVector().y
	local delta_angle = 360/lines
	for i=0,lines-1 do
		local facing_angle_deg = initial_angle_deg + delta_angle * i
		if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
		local facing_angle = math.rad(facing_angle_deg)
		local facing_vector = Vector( math.cos(facing_angle), math.sin(facing_angle), 0 ):Normalized()
		local velocity = facing_vector * line_speed
		local info = {
			Source = self:GetCaster(),
			Ability = self,
			EffectName = particle_line,
			vSpawnOrigin = self:GetCaster():GetOrigin(),
			fDistance = line_length,
			vVelocity = velocity,
			fStartRadius = width_start,
			fEndRadius = width_end,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_SPELL_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bReplaceExisting = false,
			bProvidesVision = false,
		}
		ProjectileManager:CreateLinearProjectile( info )
	end
	self:StopEffects1( true )
	self:PlayEffects2( lines )
end

function blood_fiesta:Implode( lines, modifier )
	local modifierAT = self:AddATValue( modifier )
	modifier.identifier = modifierAT
	local particle_line = "particles/ea_abilities/fear.vpcf"
	local line_length = self:GetSpecialValueFor("radius")
	local width_start = self:GetSpecialValueFor("fiesta_line_width_end")
	local width_end = self:GetSpecialValueFor("fiesta_line_width_start")
	local line_speed = self:GetSpecialValueFor("fiesta_line_speed")
	local initial_angle_deg = self:GetCaster():GetAnglesAsVector().y
	local delta_angle = 360/lines
	for i=0,lines-1 do
		local facing_angle_deg = initial_angle_deg + delta_angle * i
		if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
		local facing_angle = math.rad(facing_angle_deg)
		local facing_vector = Vector( math.cos(facing_angle), math.sin(facing_angle), 0 ):Normalized()
		local velocity = facing_vector * line_speed
		local info = {
			Source = self:GetCaster(),
			Ability = self,
			EffectName = particle_line,
			vSpawnOrigin = self:GetCaster():GetOrigin() + facing_vector * line_length,
			fDistance = line_length,
			vVelocity = -velocity,
			fStartRadius = width_start,
			fEndRadius = width_end,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_SPELL_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bReplaceExisting = false,
			bProvidesVision = false,
			ExtraData = {scepter = true, modifier = modifierAT, }
		}
		ProjectileManager:CreateLinearProjectile( info )
	end
end

function blood_fiesta:PlayEffects1()
	local particle_precast = "particles/custom/abilities/blood_fiesta/blood_fiesta_end.vpcf"
	self.effect_precast = ParticleManager:CreateParticle( particle_precast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	EmitSoundOn("Hero_Nevermore.ROS_Cast_Flames", self:GetCaster())
	EmitSoundOn("hero_bloodseeker.bloodRage", self:GetCaster())
end
function blood_fiesta:StopEffects1( success )
	if not success then
		ParticleManager:DestroyParticle( self.effect_precast, true )
		StopSoundOn("Hero_Nevermore.ROS_Cast_Flames", self:GetCaster())
		StopSoundOn("hero_bloodseeker.bloodRage", self:GetCaster())
	end
	ParticleManager:ReleaseParticleIndex( self.effect_precast )
end
function blood_fiesta:PlayEffects2( lines )
	local particle_cast = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( lines, 0, 0 ) )
	ParticleManager:SetParticleControlForward( effect_cast, 2, self:GetCaster():GetForwardVector() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn("Hero_Nevermore.ROS_Flames", self:GetCaster())
end

function blood_fiesta:GetAT()
	if self.abilityTable==nil then
		self.abilityTable = {}
	end
	return self.abilityTable
end
function blood_fiesta:GetATEmptyKey()
	local table = self:GetAT()
	local i = 1
	while table[i]~=nil do
		i = i+1
	end
	return i
end
function blood_fiesta:AddATValue( value )
	local table = self:GetAT()
	local i = self:GetATEmptyKey()
	table[i] = value
	return i
end
function blood_fiesta:RetATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	return ret
end
function blood_fiesta:DelATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	table[key] = nil
end