LinkLuaModifier("modifier_true_master", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_sword", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_dagger", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_dagger_bleed", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_gun", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_gun_reload", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)

true_master = class({})
function true_master:GetIntrinsicModifierName() return "modifier_true_master" end
function true_master:GetCooldown(lvl)
    return self:GetSpecialValueFor("fixed_cooldown") / self:GetCaster():GetCooldownReduction()
end
function true_master:OnSpellStart()
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_true_master_gun") then
		self:GetCaster():RemoveModifierByName("modifier_true_master_gun")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_true_master_sword", {})
	elseif self:GetCaster():HasModifier("modifier_true_master_sword") then
		self:GetCaster():RemoveModifierByName("modifier_true_master_sword")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_true_master_dagger", {})
	elseif self:GetCaster():HasModifier("modifier_true_master_dagger") then
		self:GetCaster():RemoveModifierByName("modifier_true_master_dagger")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_true_master_gun", {})
	end
end

modifier_true_master = class({})
function modifier_true_master:IsHidden() return true end
function modifier_true_master:IsPurgable() return false end
function modifier_true_master:RemoveOnDeath() return false end
function modifier_true_master:OnCreated()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_true_master_sword", {})
end
function modifier_true_master:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING, MODIFIER_PROPERTY_MODEL_SCALE}
end
function modifier_true_master:GetModifierPercentageCooldownStacking()
	if self:GetParent():GetLevel() >= 35 then
		return 30
	end
	return 0
end
function modifier_true_master:GetModifierModelScale()
	return -50
end

-----------
-- Sword --
-----------
modifier_true_master_sword = class({})
function modifier_true_master_sword:IsHidden() return false end
function modifier_true_master_sword:IsPurgable() return false end
function modifier_true_master_sword:RemoveOnDeath() return false end
function modifier_true_master_sword:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end
function modifier_true_master_sword:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("sword_bonus_attack_range")
end
function modifier_true_master_sword:GetModifierPreAttack_CriticalStrike(params)
	if IsServer() then
		if RollPercentage(self:GetAbility():GetSpecialValueFor("sword_crit_chance")) then
			return self:GetAbility():GetSpecialValueFor("sword_crit_damage")
		end
		return 0
	end
end

------------
-- Dagger --
------------
modifier_true_master_dagger = class({})
function modifier_true_master_dagger:IsHidden() return false end
function modifier_true_master_dagger:IsPurgable() return false end
function modifier_true_master_dagger:RemoveOnDeath() return false end
function modifier_true_master_dagger:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAX_ATTACK_RANGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT, MODIFIER_PROPERTY_AVOID_DAMAGE, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end
function modifier_true_master_dagger:GetModifierMaxAttackRange()
	return self:GetAbility():GetSpecialValueFor("dagger_max_attack_range")
end
function modifier_true_master_dagger:GetModifierMoveSpeedBonus_Constant()
	if self:GetCaster():GetLevel() >= 65 then
		return self:GetAbility():GetSpecialValueFor("dagger_65_bonus_ms")
	end
	return 0
end
function modifier_true_master_dagger:GetModifierIgnoreMovespeedLimit() return 1 end
function modifier_true_master_dagger:GetModifierBaseAttackTimeConstant() return self:GetAbility():GetSpecialValueFor("dagger_fixed_bat") end
function modifier_true_master_dagger:GetModifierAvoidDamage(keys)
	if keys.damage > 0 then
		if RollPercentage(self:GetAbility():GetSpecialValueFor("dagger_dodge_chance")) then
			return 1
		end
	end
	return 0
end

modifier_true_master_dagger_bleed = class({})
function modifier_true_master_dagger_bleed:IsHidden() return false end
function modifier_true_master_dagger_bleed:IsPurgable() return true end
function modifier_true_master_dagger_bleed:GetTexture() return "custom/abilities/mows_bleed" end
function modifier_true_master_dagger_bleed:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_true_master_dagger_bleed:OnCreated()
	if not IsServer() then return end
	self.bleed_damage = self:GetCaster():GetAttackDamage() * 0.33
	self:StartIntervalThink(1)
end
function modifier_true_master_dagger_bleed:OnIntervalThink()
	if not IsServer() then return end
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = nil,
		damage = self.bleed_damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
	})
end

---------
-- Gun --
---------
modifier_true_master_gun = class({})
function modifier_true_master_gun:IsHidden() return false end
function modifier_true_master_gun:IsPurgable() return false end
function modifier_true_master_gun:RemoveOnDeath() return false end
function modifier_true_master_gun:OnCreated()
	if not IsServer() then return end
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_true_master_gun_reload", {})
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	AttachWearable(self:GetParent(), "models/items/pangolier/pangolier_immortal_musket/pangolier_immortal_musket.vmdl", nil)
end
function modifier_true_master_gun:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveModifierByName("modifier_true_master_gun_reload")
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	RemoveWearables(self:GetParent())
end
function modifier_true_master_gun:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT, MODIFIER_PROPERTY_FIXED_ATTACK_RATE}
end
function modifier_true_master_gun:GetModifierAttackPointConstant()
	return -0.3
end
function modifier_true_master_gun:GetModifierAttackRangeBonus()
	return 99999
end
function modifier_true_master_gun:GetModifierFixedAttackRate() return 0.33 end
function modifier_true_master_gun:OnAttackStart(keys)
	if not IsServer() then return end
	if self:GetParent() == keys.attacker then
		self:GetParent():EmitSound("Hero_Pangolier.Swashbuckle.Musket")
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_1_END)

		self.pierce_proc = false
		if RollPercentage(self:GetAbility():GetSpecialValueFor("dagger_true_strike")) then
			self.pierce_proc = true
		end
	end
end
function modifier_true_master_gun:OnAttackLanded(keys)
	if not IsServer() then return end
	if self:GetParent() == keys.attacker then
		local instance = 4
		for i = 1, (instance - 1) do
			ApplyDamage({
				victim = keys.target,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = self:GetParent():GetAttackDamage() * 1.33,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			})
		end
	end
end
function modifier_true_master_gun:GetModifierProjectileName()
	return "particles/econ/items/shadow_fiend/sf_desolation/sf_base_attack_desolation_desolator.vpcf"
end
function modifier_true_master_gun:GetActivityTranslationModifiers() return "musket" end
function modifier_true_master_gun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = false}
	if self.pierce_proc then
		state = {[MODIFIER_STATE_STUNNED] = false, [MODIFIER_STATE_CANNOT_MISS] = true}
	end
	return state
end

modifier_true_master_gun_reload = class({})
function modifier_true_master_gun_reload:IsHidden() return self:GetStackCount() > 0 end
function modifier_true_master_gun_reload:IsDebuff() return true end
function modifier_true_master_gun_reload:IsPurgable() return false end
function modifier_true_master_gun_reload:RemoveOnDeath() return false end
function modifier_true_master_gun_reload:DestroyOnExpire() return false end
function modifier_true_master_gun_reload:OnCreated()
	self:SetStackCount(3)
end
function modifier_true_master_gun_reload:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end
function modifier_true_master_gun_reload:OnAttack(keys)
	if not IsServer() then return end
	if self:GetParent() == keys.attacker then
		if self:GetStackCount() > 0 then
			self:SetStackCount(self:GetStackCount() - 1)
		end
		if self:GetStackCount() == 0 then
			Timers:CreateTimer(1, function()
				if self:GetAbility() then
					self:SetStackCount(3)
				end
			end)
		end
	end
end
function modifier_true_master_gun_reload:CheckState()
	local state = {}
	if self:GetStackCount() == 0 then
		state = {[MODIFIER_STATE_DISARMED] = true}
	else
		state = {[MODIFIER_STATE_DISARMED] = false}
	end
	return state
end



function AttachWearable(unit, modelPath,part)
	local wearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelPath, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})

	wearable:FollowEntity(unit, true)
	
	if part ~= nil then
		local mask1_particle = ParticleManager:CreateParticle(part, PATTACH_ABSORIGIN_FOLLOW, wearable)
		ParticleManager:SetParticleControlEnt(mask1_particle, 0, wearable, PATTACH_POINT_FOLLOW, "attach_part", unit:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(mask1_particle, 1, wearable, PATTACH_POINT_FOLLOW, "attach_part", unit:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(mask1_particle, 2, wearable, PATTACH_POINT_FOLLOW, "attach_part", unit:GetOrigin(), true)
	end
	
	unit.wearables = unit.wearables or {}
	table.insert(unit.wearables, wearable)
	return wearable
end

function RemoveWearables(unit)
	if not unit.wearables or #unit.wearables == 0 then return end
	for _, part in pairs(unit.wearables) do
		part:RemoveSelf()
	end
	unit.wearables = {}
end