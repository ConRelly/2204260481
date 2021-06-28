---------------------------
-- AEGIS OF THE IMMORTAL --
---------------------------
item_inf_aegis = class({})
LinkLuaModifier("modifier_inf_aegis", "items/aegis.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_inf_aegis_stats", "items/aegis.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
function item_inf_aegis:GetIntrinsicModifierName() return "modifier_inf_aegis" end
function item_inf_aegis:GetCooldown(level)
--[[
	--UP: without Seal
	if not self:GetCaster():HasModifier("immortal_all_in_one") then
		return 60
	end
	------------------
]]
	return self.BaseClass.GetCooldown(self, level)
end
function item_inf_aegis:IsRefreshable() return false end
function item_inf_aegis:item(keys, self)
	local unit = keys.unit
	if not self.caster:HasModifier("modifier_item_aegis") then
		self.reincarnation_death = true
		self.ability:UseResources(false, false, true)
		particle_death_fx = ParticleManager:CreateParticle(self.particle_death, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleAlwaysSimulate(particle_death_fx)
		ParticleManager:SetParticleControl(particle_death_fx, 0, unit:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_death_fx, 1, Vector(self.reincarnate_delay, 0, 0))
		ParticleManager:SetParticleControl(particle_death_fx, 11, Vector(200, 0, 0))
		ParticleManager:ReleaseParticleIndex(particle_death_fx)
		particle_aegis_timer = ParticleManager:CreateParticle(self.particle_at, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(particle_aegis_timer, 1, Vector(0, 0, 0))
		ParticleManager:SetParticleControl(particle_aegis_timer, 3, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_aegis_timer)
		if GameRules:IsDaytime() then
			AddFOWViewer(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), self.caster:GetDayTimeVisionRange(), self.reincarnate_delay, true)
		else
			AddFOWViewer(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), self.caster:GetNightTimeVisionRange(), self.reincarnate_delay, true)
		end
	else
		self.reincarnation_death = false
	end
end

modifier_inf_aegis = class({})
function modifier_inf_aegis:IsHidden() return true end
function modifier_inf_aegis:IsPurgable() return false end
function modifier_inf_aegis:IsPurgeException() return false end
function modifier_inf_aegis:IsDebuff() return false end
function modifier_inf_aegis:RemoveOnDeath() return false end
function modifier_inf_aegis:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.particle_death = "particles/items_fx/aegis_respawn_timer.vpcf"
		self.particle_at = "particles/items_fx/aegis_timer.vpcf"
		self.reincarnate_delay = self:GetAbility():GetSpecialValueFor("reincarnate_delay")
		if not self:GetCaster():HasModifier("modifier_inf_aegis_stats") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_inf_aegis_stats", {})
		end
	end
end
function modifier_inf_aegis:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_inf_aegis:OnDeath(keys)
	if IsServer() then
		local aegis_charges = self:GetCaster():FindModifierByName("modifier_aegis")
		if aegis_charges and aegis_charges:GetStackCount() > 0 then return end
		if self.ability:IsOwnersManaEnough() and self.ability:IsCooldownReady() then
			if self:GetCaster():IsRealHero() and self:GetCaster() == keys.unit then
				item_inf_aegis:item(keys, self)
				self:GetCaster():EmitSound("Aegis.Timer")
				self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("cooldown"))
				self:GetCaster():FindModifierByName("modifier_inf_aegis_stats"):IncrementStackCount()
				Timers:CreateTimer(self:GetAbility():GetSpecialValueFor("reincarnate_delay"), function()
					self:GetParent():RespawnUnit()
				end)
				Timers:CreateTimer(self:GetAbility():GetSpecialValueFor("reincarnate_delay") + 0.11, function()
					self.caster:AddNewModifier(self.caster, self.ability, "modifier_aegis_buff", {duration = 14})
				end)
			end
		end
	end
end

-----------------------
-- AEGIS BONUS STATS --
-----------------------
if modifier_inf_aegis_stats == nil then modifier_inf_aegis_stats = class({}) end
function modifier_inf_aegis_stats:IsHidden() return false end
function modifier_inf_aegis_stats:IsDebuff() return false end
function modifier_inf_aegis_stats:IsPurgable() return false end
function modifier_inf_aegis_stats:IsPurgeException() return false end
function modifier_inf_aegis_stats:IsDebuff() return false end
function modifier_inf_aegis_stats:RemoveOnDeath() return false end
function modifier_inf_aegis_stats:OnCreated()
	self:SetStackCount(1)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
		if not self:GetAbility() then self:Destroy() end
	end
end
function modifier_inf_aegis_stats:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_EVENT_ON_DEATH} end
function modifier_inf_aegis_stats:OnDeath(keys)
	if IsServer() then
		local unit = keys.unit
		local aegis_charges = self:GetCaster():FindModifierByName("modifier_aegis")
		if aegis_charges and aegis_charges:GetStackCount() > 0 then return end
		if self:GetAbility():IsOwnersManaEnough() and self:GetAbility():IsCooldownReady() then
			if self:GetCaster():IsRealHero() and self:GetParent() == unit then
--				self:IncrementStackCount()
			end
		end
	end
end
function modifier_inf_aegis_stats:OnTooltip() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("proc_stats") end
function modifier_inf_aegis_stats:GetModifierBonusStats_Strength() if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("proc_stats") end end
function modifier_inf_aegis_stats:GetModifierBonusStats_Agility() if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("proc_stats") end end
function modifier_inf_aegis_stats:GetModifierBonusStats_Intellect() if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("proc_stats") end end
