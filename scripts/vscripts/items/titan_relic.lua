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
function modifier_titan_relic:AllowIllusionDuplicate() return false end
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
			self:GetAbility():UseResources(true, false, false, true)
			local purge = ParticleManager:CreateParticle("particles/items_fx/bloodstone_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
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
--list with self debuffs that player will benifit from them being longer
local consider_debuff = {

	modifier_spirit_guardian_heal_cd = true,
}

function modifier_titan_relic:OnModifierAdded(keys)
	local target = keys.unit
	local buff = keys.added_buff
	if buff:IsNull() then return end
	if buff:GetCaster() ~= self:GetCaster() then return end
	if self:GetParent():IsIllusion() then return end
	if self:GetParent():HasModifier("modifier_arc_warden_tempest_double") then return end
	if buff:GetName() == "modifier_kill" then return end
	if buff.passed ~= nil then return end
	if not buff:GetAbility() then return end
	if self:GetAbility() and target and not self:IsNull() and buff:GetDuration() > 0 and buff:GetAbility():GetCaster() == self:GetCaster() then
		if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			if buff:IsDebuff() then
				buff.passed = true
				buff:SetDuration(buff:GetDuration() * (1 + (self:GetAbility():GetSpecialValueFor("debuff_amp") / 100)), true)
			end
		else
			buff.passed = true
			if consider_debuff[buff:GetName()] then
				buff:SetDuration(buff:GetDuration() * (1 + (self:GetAbility():GetSpecialValueFor("debuff_amp") / 100)), true)
			else
				buff:SetDuration(buff:GetDuration() * (1 + (self:GetAbility():GetSpecialValueFor("buff_amp") / 100)), true)
			end	
		end
	end
end
