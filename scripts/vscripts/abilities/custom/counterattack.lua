LinkLuaModifier("modifier_jotaro_counterattack", "heroes/hero_jotaro/counterattack", LUA_MODIFIER_MOTION_NONE)
if not jotaro_counterattack then
	jotaro_counterattack = class({})
end
function jotaro_counterattack:GetIntrinsicModifierName()
	return "modifier_jotaro_counterattack"
end
if not modifier_jotaro_counterattack then
	modifier_jotaro_counterattack = class({})
end
function modifier_jotaro_counterattack:IsHidden()
	return true
end

if IsServer() then
	function modifier_jotaro_counterattack:OnCreated(t)
		self.ab = self:GetAbility()
		self.parent = self:GetParent()
	end
	function modifier_jotaro_counterattack:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK_LANDED}
	end
	function modifier_jotaro_counterattack:OnAttackLanded(data)
		local mult = 1
		if self.parent:HasModifier("modifier_item_special_jotaro") or self.parent:HasModifier("modifier_item_special_jotaro_upgrade") then
			mult = 2
		end	
		local trigger_chance = self.ab:GetSpecialValueFor("trigger_chance")*mult

		if data.target == self.parent and self.parent:IsAlive() and RollPercentage(trigger_chance) then
			self.parent:SetHealth(data.damage + self.parent:GetHealth())
			local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_WORLDORIGIN, self.parent)
			ParticleManager:SetParticleControl(nFX, 0, data.attacker:GetAbsOrigin() )
			ParticleManager:SetParticleControl(nFX, 1, data.attacker:GetAbsOrigin() )
			ParticleManager:SetParticleControl(nFX, 2, Vector(1,1,1) )
			ParticleManager:SetParticleControl(nFX, 4, data.attacker:GetAbsOrigin() )
			ParticleManager:SetParticleControl(nFX, 5, Vector(1,1,1) )
			ParticleManager:ReleaseParticleIndex(nFX)
			self.parent:PerformAttack(data.attacker, true, true, true, true, false, false, true)
			EmitSoundOn("jotaro_counterattack", data.attacker)

			self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)
		end
	end
end
