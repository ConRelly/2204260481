LinkLuaModifier("modifier_mjz_undying_punch", "abilities/hero_undying/mjz_undying_punch", LUA_MODIFIER_MOTION_NONE)

-------------------
-- Undying Punch --
-------------------
mjz_undying_punch = class({})
function mjz_undying_punch:Spawn() if IsServer() then self:SetLevel(1) end end
function mjz_undying_punch:GetIntrinsicModifierName() return "modifier_mjz_undying_punch" end

modifier_mjz_undying_punch = class({})
function modifier_mjz_undying_punch:IsHidden() return true end
function modifier_mjz_undying_punch:IsPurgable() return false end
function modifier_mjz_undying_punch:OnCreated()
	self:StartIntervalThink(FrameTime())
end
function modifier_mjz_undying_punch:OnIntervalThink()
	if not IsServer() then return end
	local Flesh_Golem = self:GetCaster():FindAbilityByName("undying_flesh_golem")
	if Flesh_Golem:IsTrained() then
		self:GetAbility():SetLevel(Flesh_Golem:GetLevel())
	end
	if self:GetCaster():HasModifier("modifier_undying_flesh_golem") then
		self:GetAbility():SetHidden(false)
		self:GetAbility():SetActivated(true)
		self:SetStackCount(self:GetCaster():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("hp_leech_percent") / 100))
	else
		self:GetAbility():SetHidden(true)
		self:GetAbility():SetActivated(false)
		self:SetStackCount(0)
	end
end
function modifier_mjz_undying_punch:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end
function modifier_mjz_undying_punch:OnAttackLanded(keys)
	if not IsServer() then return end
	local parent = self:GetParent()
	local attacker = keys.attacker
	if attacker == parent and not parent:IsIllusion() and parent:GetHealth() > 0 and self:GetAbility():IsActivated() then
		local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(lifesteal_pfx)

		attacker:Heal(self:GetStackCount(), attacker)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, self:GetStackCount(), nil)
	end
end
function modifier_mjz_undying_punch:GetModifierPreAttack_BonusDamage() return self:GetStackCount() end
function modifier_mjz_undying_punch:GetModifierExtraHealthPercentage() if self:GetCaster():HasScepter() then return 20 else return 0 end end
