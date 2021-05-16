
---------------------------------------------------------------------------------------------------
-- ParticleManager

function ParticleManager:FireParticle(effect, attach, owner, cps)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)
	if cps then
		for cp, value in pairs(cps) do
			if type(value) == "userdata" then
				ParticleManager:SetParticleControl(FX, tonumber(cp), value)
			elseif type(value) == "table" then
				ParticleManager:SetParticleControlEnt(FX, cp, value.owner or owner, value.attach or attach, value.point or "attach_hitloc", (value.owner or owner):GetAbsOrigin(), true)
			else
				ParticleManager:SetParticleControlEnt(FX, cp, owner, attach, value, owner:GetAbsOrigin(), true)
			end
		end
	end
	ParticleManager:ReleaseParticleIndex(FX)
end

function ParticleManager:ClearParticle(cFX, bImmediate)
	if cFX then
		self:DestroyParticle(cFX, bImmediate or false)
		self:ReleaseParticleIndex(cFX)
	end
end


