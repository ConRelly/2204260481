LinkLuaModifier("modifier_jotaro_absolute_defense", "abilities/custom/absolute_defense", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jotaro_absolute_defense_cooldown", "abilities/custom/absolute_defense", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jotaro_absolute_defense_absolute", "abilities/custom/absolute_defense", LUA_MODIFIER_MOTION_NONE)
if not jotaro_absolute_defense then
	jotaro_absolute_defense = class({})
end
jotaro_absolute_defense_2 = class(jotaro_absolute_defense)

function jotaro_absolute_defense:GetIntrinsicModifierName()
	return "modifier_jotaro_absolute_defense"
end
function jotaro_absolute_defense_2:GetIntrinsicModifierName()
	return "modifier_jotaro_absolute_defense"
end
if IsServer() then
function jotaro_absolute_defense:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByNameAndCaster("modifier_jotaro_absolute_defense_cooldown", caster)
	caster:RemoveModifierByNameAndCaster("modifier_jotaro_absolute_defense", caster)
	caster:AddNewModifier(caster, self, "modifier_jotaro_absolute_defense_absolute", {duration=self:GetDuration()})
end
end
if not modifier_jotaro_absolute_defense then
	modifier_jotaro_absolute_defense = class({})
end
function modifier_jotaro_absolute_defense:IsHidden()
	return true
end
function modifier_jotaro_absolute_defense:GetPriority()
	return MODIFIER_PRIORITY_HiGH 
end
if IsServer() then
	function modifier_jotaro_absolute_defense:OnCreated(t)
		self.ab = self:GetAbility()
		self.parent = self:GetParent()
	end
	function modifier_jotaro_absolute_defense:DeclareFunctions()
		return {MODIFIER_PROPERTY_AVOID_DAMAGE}
	end
	function modifier_jotaro_absolute_defense:GetModifierAvoidDamage(t)
		if self.ab:IsCooldownReady() and t.target == self.parent and self.parent:GetMaxHealth()*self.ab:GetSpecialValueFor("hp_pct")/100 <= t.damage then
			--self.parent:SetHealth(t.damage + self.parent:GetHealth())
			local part = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CENTER_FOLLOW, self.parent)
			ParticleManager:ReleaseParticleIndex(part)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCKED, t.target, 0, nil)
			--self.parent:EmitSound("jotaro_absolute_defense")
			self.ab:UseResources(true, true, true)
			return 1
		end
		return 0
	end
end
function modifier_jotaro_absolute_defense:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
if not modifier_jotaro_absolute_defense_absolute then
	modifier_jotaro_absolute_defense_absolute = class({})
end
if IsServer() then
	function modifier_jotaro_absolute_defense_absolute:OnCreated(t)
		self.ab = self:GetAbility()
		self.parent = self:GetParent()
	end
	function modifier_jotaro_absolute_defense_absolute:DeclareFunctions()
		return {MODIFIER_EVENT_ON_TAKEDAMAGE}
	end
	function modifier_jotaro_absolute_defense_absolute:OnTakeDamage(t)
		if t.unit == self.parent and self.parent:GetMaxHealth()*self.ab:GetSpecialValueFor("hp_pct") <= t.damage then
			self.parent:SetHealth(t.damage + self.parent:GetHealth())
			local part = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:ReleaseParticleIndex(part)
			if self:IsNull() then return end
			self:Destroy()
		end
	end
	function modifier_jotaro_absolute_defense_absolute:OnDestroy()
		self.parent:AddNewModifier(self.parent, self.ab, "modifier_jotaro_absolute_defense", {})
	end
end
function modifier_jotaro_absolute_defense:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
if not modifier_jotaro_absolute_defense_cooldown then
	modifier_jotaro_absolute_defense_cooldown = class({})
end
function modifier_jotaro_absolute_defense_cooldown:IsHidden()
	return false
end
function modifier_jotaro_absolute_defense_cooldown:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
if IsServer() then
	function modifier_jotaro_absolute_defense_cooldown:OnCreated(t)
		self.ab = self:GetAbility()
		self.parent = self:GetParent()
	end
	function modifier_jotaro_absolute_defense_cooldown:OnDestroy()
		self.parent:AddNewModifier(self.parent, self.ab, "modifier_jotaro_absolute_defense", {})
	end
end