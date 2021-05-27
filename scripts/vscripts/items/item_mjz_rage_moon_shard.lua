LinkLuaModifier("modifier_mjz_rage_moon_shard",  "items/item_mjz_rage_moon_shard.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_rage_moon_shard_stats",  "items/item_mjz_rage_moon_shard.lua",LUA_MODIFIER_MOTION_NONE)

item_mjz_rage_moon_shard = item_mjz_rage_moon_shard or class({})
function item_mjz_rage_moon_shard:GetIntrinsicModifierName() return "modifier_mjz_rage_moon_shard" end
function item_mjz_rage_moon_shard:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if target:HasModifier("modifier_mjz_rage_moon_shard_stats") then return nil end
		target:AddNewModifier(caster, self, "modifier_mjz_rage_moon_shard_stats", {})
		target:EmitSound("Item.MoonShard.Consume")
		caster:RemoveItem(self)
	end
end


modifier_mjz_rage_moon_shard = modifier_mjz_rage_moon_shard or class({})
function modifier_mjz_rage_moon_shard:IsHidden() return true end
function modifier_mjz_rage_moon_shard:IsPurgable() return false end
function modifier_mjz_rage_moon_shard:RemoveOnDeath() return false end
function modifier_mjz_rage_moon_shard:OnCreated()
	if IsServer() then
		self.bonus_night_vision = self:GetAbility():GetSpecialValueFor("bonus_night_vision")
		self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
		if self:GetParent():HasModifier("modifier_mjz_rage_moon_shard_stats") then
			self.bonus_night_vision = self:GetAbility():GetSpecialValueFor("bonus_night_vision") - self:GetAbility():GetSpecialValueFor("consumed_bonus_night_vision")
			self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed") - self:GetAbility():GetSpecialValueFor("consumed_bonus_attack_speed")
		end
	end
end
function modifier_mjz_rage_moon_shard:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BONUS_NIGHT_VISION}
end
function modifier_mjz_rage_moon_shard:GetBonusNightVision()
	if self:GetAbility() then return self.bonus_night_vision end
end
function modifier_mjz_rage_moon_shard:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self.bonus_attack_speed end
end

modifier_mjz_rage_moon_shard_stats = modifier_mjz_rage_moon_shard_stats or class({})
function modifier_mjz_rage_moon_shard_stats:IsHidden() return false end
function modifier_mjz_rage_moon_shard_stats:IsPurgable() return false end
function modifier_mjz_rage_moon_shard_stats:AllowIllusionDuplicate() return true end
function modifier_mjz_rage_moon_shard_stats:GetTexture() return "modifiers/mjz_rage_moon_shard" end
function modifier_mjz_rage_moon_shard_stats:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_mjz_rage_moon_shard_stats:GetBonusNightVision()
	return 800
end
function modifier_mjz_rage_moon_shard_stats:GetModifierAttackSpeedBonus_Constant()
	return 160
end