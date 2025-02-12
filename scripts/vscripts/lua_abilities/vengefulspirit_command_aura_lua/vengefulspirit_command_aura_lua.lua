vengefulspirit_command_aura_lua = class({})
LinkLuaModifier("modifier_vengefulspirit_command_aura_lua", "lua_abilities/vengefulspirit_command_aura_lua/vengefulspirit_command_aura_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vengefulspirit_command_aura_effect_lua", "lua_abilities/vengefulspirit_command_aura_lua/vengefulspirit_command_aura_lua", LUA_MODIFIER_MOTION_NONE)

function vengefulspirit_command_aura_lua:GetIntrinsicModifierName() return "modifier_vengefulspirit_command_aura_lua" end

modifier_vengefulspirit_command_aura_lua = class({})
function modifier_vengefulspirit_command_aura_lua:IsHidden() return true end
function modifier_vengefulspirit_command_aura_lua:IsAura() return true end
function modifier_vengefulspirit_command_aura_lua:GetModifierAura() return "modifier_vengefulspirit_command_aura_effect_lua" end
function modifier_vengefulspirit_command_aura_lua:GetAuraDuration() return 0.5 end
function modifier_vengefulspirit_command_aura_lua:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function modifier_vengefulspirit_command_aura_lua:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function modifier_vengefulspirit_command_aura_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_vengefulspirit_command_aura_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end

function modifier_vengefulspirit_command_aura_lua:OnCreated()
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_vengefulspirit_command_aura_lua:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end
function modifier_vengefulspirit_command_aura_lua:OnDeath(params)
	if IsServer() then
		if self:GetCaster() == nil or self:GetCaster():PassivesDisabled() or self:GetCaster() ~= self:GetParent() or self:GetAbility():GetLevel() < 1 then return end

		local hAttacker = params.attacker
		local hVictim = params.unit

		if hVictim ~= nil and hAttacker ~= nil and hVictim == self:GetCaster() and hAttacker:GetTeamNumber() ~= hVictim:GetTeamNumber() then
			local hAuraHolder = nil
			if hAttacker ~= nil then
				hAuraHolder = hAttacker
			end

			if hAuraHolder ~= nil then
				hAuraHolder:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_vengefulspirit_command_aura_lua", {}) 

				local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_negative_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, hAuraHolder)
				ParticleManager:SetParticleControlEnt(nFXIndex, 1, hVictim, PATTACH_ABSORIGIN_FOLLOW, nil, hVictim:GetOrigin(), false)
				ParticleManager:ReleaseParticleIndex(nFXIndex)
			end
		end
	end
	return 0
end

function modifier_vengefulspirit_command_aura_lua:OnIntervalThink()
	if self:GetCaster() ~= self:GetParent() and self:GetCaster():IsAlive() then
		if self:IsNull() then return end
		self:Destroy()
	end
end


modifier_vengefulspirit_command_aura_effect_lua = class({})
function modifier_vengefulspirit_command_aura_effect_lua:IsHidden() if self:GetAbility() then return (self:GetAbility():GetLevel() < 1) end end
function modifier_vengefulspirit_command_aura_effect_lua:IsDebuff()
	if self:GetAbility() then
		if IsValidEntity(self:GetCaster()) and IsValidEntity(self:GetParent()) then
			if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then return true end
		end	
		return false
	end	
end
function modifier_vengefulspirit_command_aura_effect_lua:OnCreated()
	if not self:GetAbility() then self:Destroy() end
	self.agi_multiplier = self:GetAbility():GetSpecialValueFor("agi_multiplier") / self:GetAbility():GetSpecialValueFor("agi_per_dmg")
	self.bonus_damage_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
	
end
function modifier_vengefulspirit_command_aura_effect_lua:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_vengefulspirit_command_aura_effect_lua:GetModifierBaseDamageOutgoing_Percentage(params)
	--if not IsServer() then return end
	--if not self:GetParent():IsRealHero() then return end
	if self:GetAbility() and self:GetCaster() then
		if (self:GetCaster():PassivesDisabled() and not self:IsDebuff()) or self:GetAbility():GetLevel() < 1 then return end
		local bonus = self.bonus_damage_pct + (self.agi_multiplier * self:GetCaster():GetAgility())
		if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
			return -bonus
		end
		if not self:GetParent():IsHero() then
			return bonus / 5
		end	
		return bonus
	end
end
