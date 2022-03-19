require("lib/my")
LinkLuaModifier("modifier_nevermore_custom_necromastery", "abilities/heroes/nevermore_custom_necromastery.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_necromastery_shard", "abilities/heroes/nevermore_custom_necromastery.lua", LUA_MODIFIER_MOTION_NONE)


------------------
-- Necromastery --
------------------
nevermore_custom_necromastery = class({})
function nevermore_custom_necromastery:GetIntrinsicModifierName() return "modifier_nevermore_custom_necromastery" end
function nevermore_custom_necromastery:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end
function nevermore_custom_necromastery:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return 3
	end
	return 0
end
function nevermore_custom_necromastery:OnSpellStart()
	local necromastery = self:GetCaster():FindModifierByName("modifier_nevermore_custom_necromastery")
	local stacks = necromastery:GetStackCount()
	if stacks < 1 then return end
	necromastery:SetStackCount(stacks - 1)
	local shard_stacks = self:GetCaster():FindModifierByName("modifier_necromastery_shard")
	if self:GetCaster():HasModifier("modifier_necromastery_shard") then
		shard_stacks:SetStackCount(shard_stacks:GetStackCount() + 1)
	else
		shard_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_necromastery_shard", {})
		shard_modifier:SetStackCount(1)
	end
end


---------------------------
-- Necromastery Modifier --
---------------------------
modifier_nevermore_custom_necromastery = class({})
function modifier_nevermore_custom_necromastery:IsHidden() return false end
function modifier_nevermore_custom_necromastery:IsPurgable() return false end
function modifier_nevermore_custom_necromastery:OnCreated()
	if IsServer() then
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		if self.parent:IsIllusion() or self.parent:HasModifier("modifier_arc_warden_tempest_double") then
			local mod1 = "modifier_nevermore_custom_necromastery"
			print("Necromastery Illusion")
			local owner = PlayerResource:GetSelectedHeroEntity(self.parent:GetPlayerOwnerID())
			if owner then
				if self.parent:HasModifier(mod1) and owner:HasModifier(mod1) then
					local modifier1 = self.parent:FindModifierByName(mod1)
					local modifier2 = owner:FindModifierByName(mod1)
					modifier1:SetStackCount(modifier2:GetStackCount())
				end
			end
		end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_nevermore_custom_necromastery:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():HasModifier("modifier_item_aghanims_shard") then return end
		local stacks = self:GetCaster():FindModifierByName("modifier_nevermore_custom_necromastery"):GetStackCount()
		if stacks < 1 then return end
		if self:GetAbility():IsCooldownReady() and not self:GetParent():PassivesDisabled() then
			if self:GetAbility():GetAutoCastState() then
				self:GetAbility():OnSpellStart()
				self:GetAbility():UseResources(false, false, true)
			end
		end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_nevermore_custom_necromastery:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_DEATH}
end
function modifier_nevermore_custom_necromastery:GetModifierPreAttack_BonusDamage() return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("necromastery_damage_per_soul") + talent_value(self:GetParent(), "special_bonus_unique_nevermore_1")) end
function modifier_nevermore_custom_necromastery:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("spell_amp_per_soul")
end
function modifier_nevermore_custom_necromastery:OnAttackLanded(keys)
	if IsServer() then
		local attacker = keys.attacker
		local target = keys.target
		local max_souls = self.ability:GetSpecialValueFor("necromastery_max_souls")
		if self.parent:HasScepter() then
			max_souls = max_souls + self.ability:GetSpecialValueFor("scepter_bonus_souls")
		end
		if attacker == self.parent and not target:IsNull() then
			if self:GetStackCount() < max_souls then
				self:IncrementStackCount()
				if self.parent:HasModifier("modifier_item_aghanims_shard") then
					self:IncrementStackCount()
				end
				if self:GetStackCount() > max_souls then
					self:SetStackCount(max_souls)
				end
				ProjectileManager:CreateTrackingProjectile({
					Target = self.parent,
					Source = target,
					Ability = self.ability,
					EffectName = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf",
					bDodgeable = false,
					bProvidesVision = false,
					iMoveSpeed = 1500,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				})
			end
		end
	end
end
function modifier_nevermore_custom_necromastery:OnDeath(keys)
	if IsServer() then
		if keys.unit == self.parent then
			local release = self:GetAbility():GetSpecialValueFor("necromastery_soul_release")
			local new_stack_count = math.ceil(self:GetStackCount() * (100 - release) / 100)
			self:SetStackCount(new_stack_count)
			if self.parent:HasAbility("nevermore_custom_requiem") then
				local requiem = self.parent:FindAbilityByName("nevermore_custom_requiem")
				if requiem and requiem:GetLevel() >= 1 then
					requiem:OnSpellStart()
				end
			end
		end
	end
end


----------------------------------
-- Aghanim's Shard Upgrade Crit --
----------------------------------
modifier_necromastery_shard = class({})
function modifier_necromastery_shard:IsHidden() return (self:GetStackCount() < 2) end
function modifier_necromastery_shard:IsPurgable() return false end
function modifier_necromastery_shard:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_necromastery_shard:GetModifierProjectileName()
	return "particles/units/heroes/hero_nevermore/sf_necromastery_attack.vpcf"
end
function modifier_necromastery_shard:GetModifierCritDMG()
	self:GetParent():RemoveModifierByName("modifier_necromastery_shard")
	return 100 + (100 * self:GetStackCount())
end
function modifier_necromastery_shard:OnTooltip()
	return 100 + (100 * self:GetStackCount())
end

