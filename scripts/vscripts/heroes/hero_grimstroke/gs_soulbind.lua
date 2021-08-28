require("libraries/tempTable")
LinkLuaModifier("modifier_gs_soulbind", "heroes/hero_grimstroke/gs_soulbind", LUA_MODIFIER_MOTION_NONE)


--------------
-- Soulbind --
--------------
gs_soulbind = class({})
function gs_soulbind:GetAOERadius()
	return self:GetSpecialValueFor("chain_latch_radius")
end
function gs_soulbind:GetCooldown(level)
	return (self.BaseClass.GetCooldown(self, level) - talent_value(self:GetCaster(), "special_bonus_gs_soulbind_cd")) / self:GetCaster():GetCooldownReduction()
end
function gs_soulbind:OnSpellStart()
	everyone = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _, one_of_all in pairs(everyone) do
		if one_of_all:HasModifier("modifier_gs_soulbind") then
			one_of_all:RemoveModifierByName("modifier_gs_soulbind")
		end
	end
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	local duration = self:GetSpecialValueFor("chain_duration")
	EmitSoundOn("Hero_Grimstroke.SoulChain.Cast", self:GetCaster())
	target:AddNewModifier(self:GetCaster(), self, "modifier_gs_soulbind", {duration = duration, primary = true})
	if self:GetCaster():GetTeamNumber() == target:GetTeamNumber() then
		particle_cast = "particles/units/heroes/hero_grimstroke/grimstroke_cast_soulchain_ally.vpcf"
	else
		particle_cast = "particles/units/heroes/hero_grimstroke/grimstroke_cast_soulchain.vpcf"
	end
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end


-----------------------
-- Soulbind Modifier --
-----------------------
modifier_gs_soulbind = class({})
function modifier_gs_soulbind:IsHidden() return false end
--function modifier_gs_soulbind:RemoveOnDeath() return false end
function modifier_gs_soulbind:IsBuff()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then return true end return false
end
function modifier_gs_soulbind:IsDebuff()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then return false end return true
end
function modifier_gs_soulbind:IsStunDebuff() return false end
function modifier_gs_soulbind:IsPurgable() return false end
function modifier_gs_soulbind:OnCreated(kv)
	if IsServer() then
		self.radius = self:GetAbility():GetSpecialValueFor("chain_latch_radius")
		self.primary = (kv.primary == 1)
		if kv.pair then self.pair = tempTable:RetValue(kv.pair) else self.pair = nil end
		self:StartIntervalThink(0.05)
		self:OnIntervalThink()
		self:PlayEffects1(self.primary)
	end
end
function modifier_gs_soulbind:OnRefresh(kv)
	if IsServer() then
		if kv.pair then self.pair = tempTable:RetValue(kv.pair) end
		if not kv.duration then self:SetDuration(-1, true) else self:SetDuration(kv.duration, true) end
		if (kv.primary == 1) and (not self.primary) then
			self.primary = true
			self.pair.primary = false
		end
		if self.primary and self.pair and (not self.pair:IsNull()) then
			local pair = tempTable:AddValue(self)
			self.pair = self.pair:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gs_soulbind", {primary = false, pair = pair})
		end
	end
end
function modifier_gs_soulbind:OnRemoved()
	if IsServer() then
		self.primary = true
		self.pair = nil
	end
end
function modifier_gs_soulbind:OnDestroy(kv)
	if IsServer() then
		self:PlayEffects2(false)
		self:Destroy()
		self.primary = true
		self.pair = nil
	end
end
function modifier_gs_soulbind:CheckState()
	if not IsServer() then return end
	local state = {}
	if self.pair then
		state[MODIFIER_STATE_TETHERED] = true
	end
	return state
end
function modifier_gs_soulbind:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end
function modifier_gs_soulbind:OnAbilityFullyCast(params)
	if IsServer() then
		local ability = params.ability
--		if not self.primary then return end
		if not self.pair then return end
		if not params.target then return end
		if params.target ~= self:GetParent() then return end
		if ability == self:GetAbility() then return end
		if ability.soulbind then return end
		local ready = false
		if ability:IsCooldownReady() then ready = true end
		ability:EndCooldown()
		ability:RefundManaCost()
		ability.soulbind = true
		params.unit:SetCursorCastTarget(self.pair:GetParent())
		ability:CastAbility()
		ability.soulbind = nil
		if not (ability:IsCooldownReady() == ready) then ability:EndCooldown() end
		self:PlayEffects3()
	end
end
function modifier_gs_soulbind:OnIntervalThink()
	if self.primary then
		if not self.pair then
			self:FindPair()
		end
	elseif self.pair then
		if self.pair:IsNull() then
			self:PlayEffects2(false)
			self:Destroy()
			self.pair = nil
		else
			self:Bind()
		end
	end
end
function modifier_gs_soulbind:FindPair()
	local targets = nil
	local target = nil
	local finding = true
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, target in pairs(targets) do if target and target ~= self:GetParent() then finding = false end end
		if finding then
			targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		end
	else
		targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	end
	for _, target in pairs(targets) do
		if target ~= self:GetParent() then
			if (not target:HasModifier("modifier_gs_soulbind")) then
				local pair = tempTable:AddValue(self)
				self.pair = target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gs_soulbind", {primary = false, pair = pair})
				self:PlayEffects2(true)
				break
			end
		end
	end
end
function modifier_gs_soulbind:Bind()
	local vectorToPair = self.pair:GetParent():GetOrigin() - self:GetParent():GetOrigin()
	local distanceToPair = vectorToPair:Length2D()
	if distanceToPair < 1000 then
	else
		if self.primary then
			self.pair:Destroy()
			self.pair = nil
			self:PlayEffects2( false )
		end
	end
end
function modifier_gs_soulbind:PlayEffects1(primary)
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		effect_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_ally.vpcf"
		marker_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_marker_ally.vpcf"
	else
		effect_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf"
		marker_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_marker.vpcf"
	end
	local effect_fx = ParticleManager:CreateParticle(effect_pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(effect_fx, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true)
	self:AddParticle(effect_fx, false, false, -1, false, false)
	if primary then
		local primary_fx = ParticleManager:CreateParticle(marker_pfx, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(primary_fx, false, false, -1, false, true)
	end
	EmitSoundOn("Hero_Grimstroke.SoulChain.Target", target)
end
function modifier_gs_soulbind:PlayEffects2(connect)
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		chains_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain2.vpcf"
	else
		chains_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain.vpcf"
	end
	if connect then
		chains_fx = ParticleManager:CreateParticle(chains_pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(chains_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
		ParticleManager:SetParticleControlEnt(chains_fx, 1, self.pair:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
		EmitSoundOn("Hero_Grimstroke.SoulChain.Partner", self.pair:GetParent())
	else
		if chains_fx then
			ParticleManager:DestroyParticle(chains_fx, false)
			ParticleManager:ReleaseParticleIndex(chains_fx)
		end
	end
end
function modifier_gs_soulbind:PlayEffects3()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		proc_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_ally_proc.vpcf"
		proc_tgt_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_ally_proc_tgt.vpcf"
	else
		proc_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_proc.vpcf"
		proc_tgt_pfx = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_proc_tgt.vpcf"
	end
	local primary_proc_fx = ParticleManager:CreateParticle(proc_pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(primary_proc_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:SetParticleControlEnt(primary_proc_fx, 1, self.pair:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:ReleaseParticleIndex(primary_proc_fx)

	local primary_proc_tgt_fx = ParticleManager:CreateParticle(proc_tgt_pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(primary_proc_tgt_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:ReleaseParticleIndex(primary_proc_tgt_fx)

	local pair_proc_tgt_fx = ParticleManager:CreateParticle(proc_tgt_pfx, PATTACH_ABSORIGIN_FOLLOW, self.pair:GetParent())
	ParticleManager:SetParticleControlEnt(pair_proc_tgt_fx, 0, self.pair:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:ReleaseParticleIndex(pair_proc_tgt_fx)
end
