modifier_power_boss = class({})
function modifier_power_boss:IsBuff() return true end
function modifier_power_boss:IsHidden() return false end
-- function modifier_power_boss:GetTexture() return "custom_avatar_debuff" end
function modifier_power_boss:IsPurgable() return false end
function modifier_power_boss:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		-- MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}
end
--[[
function modifier_power_boss:GetModifierPercentageCooldown() return 10 end
function modifier_power_boss:GetModifierTotalPercentageManaRegen() return 0.5 end
]]
function modifier_power_boss:GetModifierTotalDamageOutgoing_Percentage() return 80 end
function modifier_power_boss:GetModifierStatusResistanceStacking() return 30 end
function modifier_power_boss:GetModifierIncomingDamage_Percentage() return -25 end
function modifier_power_boss:GetModifierMagicalResistanceBonus() return 65 end
function modifier_power_boss:GetModifierPhysicalArmorBonus() return 60 end
function modifier_power_boss:GetModifierExtraHealthPercentage() return 220 end

--[[
function modifier_power_boss:OnAttack(keys)
	if IsServer() then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
		if self.player_count > 5 then
			self:_OnAttack(keys)
		end
	end
end
]]

if IsServer() then
	function modifier_power_boss:OnCreated()
		local parent = self:GetParent()
		--self.player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
	end
end

--[[
function modifier_power_boss:OnDestroy()
	ParticleManager:DestroyParticle(self.particle, false)
	ParticleManager:ReleaseParticleIndex(self.particle)
end
]]

--[[
function modifier_power_boss:_OnAttack(keys)
	if keys.attacker ~= self:GetParent() then return nil end
	if keys.target:IsBuilding() then return nil end
	-- if not self:GetParent():HasScepter() then return nil end
	-- if not self:GetParent():IsRangedAttacker() then return nil end
	-- if self:GetParent():PassivesDisabled() then return nil end
	-- if TargetIsFriendly(self:GetParent(), keys.target) then return nil end
	--if keys.target:IsMagicImmune() then return nil end
	-- if keys.target:IsPhantom() then return nil end
	if keys.target:IsIllusion() then return nil end
	if keys.target:GetTeamNumber() == self:GetParent():GetTeamNumber() then return nil end

	local attacker = keys.attacker
	local target = keys.target

	local prev_attack_time = target._modifier_power_boss_attack or 0
	if GameRules:GetGameTime() < prev_attack_time then
		return nil
	end
	target._modifier_power_boss_attack = GameRules:GetGameTime() + 1.2

	local chance = 20
	local health_pct = 17
	if target:GetMaxHealth() < 2000 then
		health_pct = 4
	elseif target:GetMaxHealth() < 3000 then
		health_pct = 5
	elseif target:GetMaxHealth() < 4000 then
		health_pct = 9
	end

	if RollPercentage( chance ) then
		local damage = target:GetHealth() * (health_pct / 100)
		ApplyDamage({
			ability = nil,
			attacker = attacker,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL, -- DAMAGE_TYPE_PURE
			victim = target,
		})
	end
end
]]