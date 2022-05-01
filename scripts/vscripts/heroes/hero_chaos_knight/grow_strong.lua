LinkLuaModifier("modifier_grow_strong", "heroes/hero_chaos_knight/grow_strong.lua", LUA_MODIFIER_MOTION_NONE)


grow_strong = class({})
function grow_strong:Spawn()
	if not IsServer() then return end
	if self:GetCaster():GetUnitName() == "npc_dota_hero_chaos_knight" then
		self:SetLevel(1)
	end
end
function grow_strong:GetIntrinsicModifierName() return "modifier_grow_strong" end


modifier_grow_strong = class({})
function modifier_grow_strong:IsHidden() return false end
function modifier_grow_strong:IsPurgable() return false end
function modifier_grow_strong:RemoveOnDeath() return false end
function modifier_grow_strong:GetEffectName()
    return "particles/econ/courier/courier_greevil_naked/courier_greevil_naked_ambient_3.vpcf"
end
function modifier_grow_strong:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_grow_strong:OnCreated()
	if not IsServer() then return end
	if self:GetAbility() and self:GetAbility():IsTrained() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("grow_interval"))
	end	
end
function modifier_grow_strong:OnRefresh()
	if not IsServer() then return end
	if self:GetAbility() and self:GetAbility():IsTrained() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("grow_interval"))
	end	
end
function modifier_grow_strong:OnIntervalThink()
	if not IsServer() then return end
	if self:GetAbility() and self:GetAbility():IsTrained() then
		self:SetStackCount(self:GetStackCount() + 1)
		if self:GetAbility() and not self:GetAbility():IsNull() and self:GetCaster() then
			if self:GetCaster():HasTalent("special_bonus_unique_ck_grow_strong") then
				self:GetCaster():ModifyStrength(self:GetAbility():GetSpecialValueFor("grow_str") * talent_value(self:GetCaster(), "special_bonus_unique_ck_grow_strong") * 0.5)
			end
			self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("grow_interval"))
		end
	end	
end
function modifier_grow_strong:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end
function modifier_grow_strong:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("grow_str") end 
end
function modifier_grow_strong:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("grow_armor") + self:GetAbility():GetSpecialValueFor("grow_armor") * talent_value(self:GetCaster(), "special_bonus_unique_ck_grow_strong")) end	
end
function modifier_grow_strong:GetModifierModelScale()
	if self:GetAbility() then
		local scale = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("grow_model")
		local max_scale = self:GetAbility():GetSpecialValueFor("max_scale")
		if scale > max_scale then scale = max_scale end
		return scale
	end	
end
function modifier_grow_strong:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() then
		if keys.attacker == self:GetCaster() then
			if self:GetAbility() then
				if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) then
					keys.target:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_stunned", {Duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
					EmitSoundOn("DOTA_Item.MKB.Minibash", keys.target)
					EmitSoundOn("Hero_ChaosKnight.ChaosStrike", keys.target)
					return self:GetAbility():GetSpecialValueFor("crit_per_str") * self:GetStackCount() + 100
				end
			end
		end
	end
end
