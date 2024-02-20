LinkLuaModifier("modifier_tombstone2","modifiers/modifier_tombstone2",LUA_MODIFIER_MOTION_NONE)



modifier_tombstone2 = class({})

function modifier_tombstone2:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_RESPAWN,
		MODIFIER_PROPERTY_MODEL_CHANGE
	}
	return funcs
end

function modifier_tombstone2:OnCreated(keys)
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end
--think
function  modifier_tombstone2:OnIntervalThink()
	-- if not IsServer() then return end
    local parent = self:GetParent()
    local parent_location = parent:GetOrigin()
    local caster = self:GetCaster()
    if caster:IsReincarnating() or caster:IsAlive() then -- or parent:HasModifier("modifier_arc_warden_tempest_double") then
        self:GetParent():Destroy()
    end
	local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),parent_location,nil,300,DOTA_UNIT_TARGET_TEAM_FRIENDLY,1,DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,FIND_CLOSEST,false)
	if units[1] and units[1]:IsRealHero() and units[1]:IsAlive() and not units[1]:IsStunned() and not units[1]:IsOutOfGame() and not units[1]:IsSilenced() and not units[1]:IsInvulnerable() then
		if not self.particle then
			self.particle = ParticleManager:CreateParticle("particles/econ/generic/generic_progress_meter/generic_progress_circle.vpcf",0,self:GetParent())
			-- ParticleManager:SetParticleControl( self.particle,1,Vector(100,0,0) )
			ParticleManager:SetParticleControl( self.particle,0,parent_location + Vector(0,0,300) )
		end
		self:IncrementStackCount()
		ParticleManager:SetParticleControl( self.particle,1, Vector(100,self:GetStackCount()/60,0 ) )
        AddFOWViewer(DOTA_TEAM_BADGUYS, parent_location, 600, 6.0, false)
        units[1]:AddNewModifier(caster, self, "modifier_boss_truesight", {duration = 1})
		if self:GetStackCount()>=60 then
			caster:RespawnHero(false,false)
            caster:SetAbsOrigin(parent_location)
		end
	else
		if self.particle then
			ParticleManager:DestroyParticle(self.particle,true)
			self.particle = nil
			self:SetStackCount(0)
		end
	end
end


function  modifier_tombstone2:OnRespawn(keys)
	if keys.unit == self:GetCaster() then
		self:GetParent():Destroy()
	end
end
function  modifier_tombstone2:GetModifierModelChange(keys)
	return "models/props_gameplay/tombstoneb01.vmdl"
end



