-----------------
-- Titan Relic --
-----------------
if item_titan_relic == nil then item_titan_relic = class({}) end
LinkLuaModifier("modifier_titan_relic", "items/titan_relic.lua", LUA_MODIFIER_MOTION_NONE)
function item_titan_relic:GetAbilityTextureName() return "custom/titan_relic" end
function item_titan_relic:GetIntrinsicModifierName() return "modifier_titan_relic" end
if modifier_titan_relic == nil then modifier_titan_relic = class({}) end
function modifier_titan_relic:IsHidden() return true end
function modifier_titan_relic:IsPurgable() return false end
function modifier_titan_relic:RemoveOnDeath() return false end
function modifier_titan_relic:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_titan_relic:OnCreated()
	if IsServer() then if not self:GetAbility() or self:GetAbility():IsNull() then self:Destroy() return end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_titan_relic:OnIntervalThink()
	if IsServer() then
		if self:GetAbility():IsFullyCastable() then
			self:GetCaster():Purge(false,true,false,false,false)
			self:GetAbility():UseResources(false, false, true)
			local purge = ParticleManager:CreateParticle("particles/custom/abilities/refresh_players/heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:ReleaseParticleIndex(purge)
			local stacks = self:GetStackCount() + 1
			self:SetStackCount(stacks)
			if self:GetStackCount() == 3 then
				self:GetCaster():Purge(false,true,false,true,false)
				self:GetCaster():Heal(self:GetCaster():GetMaxHealth() * self:GetAbility():GetSpecialValueFor("heal_pct") / 100, self:GetCaster())
				self:SetStackCount(0)
			end
		end
	end
end
function modifier_titan_relic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_MODIFIER_ADDED,
	}
end
function modifier_titan_relic:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("base_attack_damage") end
end
function modifier_titan_relic:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_resistance") end
end
function modifier_titan_relic:GetModifierStatusResistanceStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("status_resistance") end
end
function modifier_titan_relic:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_amp") end
end
function modifier_titan_relic:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_ms") end
end
function modifier_titan_relic:OnModifierAdded(keys)
	local pass = true
	if self:GetAbility() and keys.unit and keys.unit:FindAllModifiers() then
		if keys.unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			for _, modifier in pairs(keys.unit:FindAllModifiers()) do
				if modifier:IsDebuff() and modifier:GetDuration() > 0 and modifier:GetCaster() == self:GetCaster() and modifier:GetAbility():GetCaster() == self:GetCaster() and GameRules:GetGameTime() - modifier:GetCreationTime() <= FrameTime() then
					Timers:CreateTimer(FrameTime(), function()
						if modifier and pass and not self:IsNull() and self:GetAbility() then
							modifier:SetDuration(modifier:GetRemainingTime() * (1 + (self:GetAbility():GetSpecialValueFor("debuff_amp") / 100)), true)
							pass = false
						end
					end)
				end
			end
		else
			for _, modifier in pairs(keys.unit:FindAllModifiers()) do
				if modifier:GetDuration() > 0 and modifier:GetCaster() == self:GetCaster() and modifier:GetAbility():GetCaster() == self:GetCaster() and GameRules:GetGameTime() - modifier:GetCreationTime() <= FrameTime() then
					Timers:CreateTimer(FrameTime(), function()
						if modifier and pass and not self:IsNull() and self:GetAbility() then
							modifier:SetDuration(modifier:GetRemainingTime() * (1 + (self:GetAbility():GetSpecialValueFor("buff_amp") / 100)), true)
							pass = false
						end
					end)
				end
			end
		end
	end
end