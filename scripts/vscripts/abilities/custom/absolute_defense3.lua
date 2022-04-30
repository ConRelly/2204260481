LinkLuaModifier("modifier_jotaro_absolute_defense3", "abilities/custom/absolute_defense3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jotaro_absolute_defense_cooldown3", "abilities/custom/absolute_defense3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jotaro_absolute_defense_absolute3", "abilities/custom/absolute_defense3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring_perma_invincibility", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
if not jotaro_absolute_defense3 then
	jotaro_absolute_defense3 = class({})
end


function jotaro_absolute_defense3:GetIntrinsicModifierName()
	return "modifier_jotaro_absolute_defense3"
end

if IsServer() then
	function jotaro_absolute_defense3:OnSpellStart()
		local caster = self:GetCaster()
		caster:RemoveModifierByNameAndCaster("modifier_jotaro_absolute_defense_cooldown3", caster)
		caster:RemoveModifierByNameAndCaster("modifier_jotaro_absolute_defense3", caster)
		caster:AddNewModifier(caster, self, "modifier_jotaro_absolute_defense_absolute3", {duration=self:GetDuration()})
	end
end
if not modifier_jotaro_absolute_defense3 then
	modifier_jotaro_absolute_defense3 = class({})
end
function modifier_jotaro_absolute_defense3:IsHidden()
	return true
end
function modifier_jotaro_absolute_defense3:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

if IsServer() then
	function modifier_jotaro_absolute_defense3:OnCreated(t)
		self.ab = self:GetAbility()
		self.parent = self:GetParent()

	end
	function modifier_jotaro_absolute_defense3:DeclareFunctions()
		return {MODIFIER_PROPERTY_AVOID_DAMAGE}
	end
	function modifier_jotaro_absolute_defense3:GetModifierAvoidDamage(t)
		if self.ab:IsCooldownReady() and t.target == self.parent and self.parent:GetMaxHealth()*self.ab:GetSpecialValueFor("hp_pct")/100 <= t.damage and self.ab:GetLevel() >= 1 then
			if self.parent:HasModifier("modifier_item_helm_of_the_undying_active") then return 0 end
			
			--self.parent:SetHealth(t.damage + self.parent:GetHealth())
			local part = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CENTER_FOLLOW, self.parent)
			ParticleManager:ReleaseParticleIndex(part)
			--self.parent:EmitSound("jotaro_absolute_defense")
			self.ab:StartCooldown(self.ab:GetSpecialValueFor("cooldown"))
			local parent = self.parent
			local ability = self.ab
			self.parent:AddNewModifier(self.parent, ability, "modifier_item_plain_ring_perma_invincibility", {duration = 2, min_health = 0})
			--self.ab:UseResources(true, true, true)
			return 1
		end
		return 0
	end
end
function modifier_jotaro_absolute_defense3:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
if not modifier_jotaro_absolute_defense_absolute3 then
	modifier_jotaro_absolute_defense_absolute3 = class({})
end
if IsServer() then
	function modifier_jotaro_absolute_defense_absolute3:OnCreated(t)
		self.ab = self:GetAbility()
		self.parent = self:GetParent()
	end
	function modifier_jotaro_absolute_defense_absolute3:DeclareFunctions()
		return {MODIFIER_EVENT_ON_TAKEDAMAGE}
	end
	function modifier_jotaro_absolute_defense_absolute3:OnTakeDamage(t)
		if t.unit == self.parent and self.parent:GetMaxHealth()*self.ab:GetSpecialValueFor("hp_pct") <= t.damage then
			self.parent:SetHealth(t.damage + self.parent:GetHealth())
			local part = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:ReleaseParticleIndex(part)
			if self:IsNull() then return end
			self:Destroy()
		end
	end
	function modifier_jotaro_absolute_defense_absolute3:OnDestroy()
		self.parent:AddNewModifier(self.parent, self.ab, "modifier_jotaro_absolute_defense3", {})
	end
end
function modifier_jotaro_absolute_defense3:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
if not modifier_jotaro_absolute_defense_cooldown3 then
	modifier_jotaro_absolute_defense_cooldown3 = class({})
end
function modifier_jotaro_absolute_defense_cooldown3:IsHidden()
	return false
end
function modifier_jotaro_absolute_defense_cooldown3:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
if IsServer() then
	function modifier_jotaro_absolute_defense_cooldown3:OnCreated(t)
		self.ab = self:GetAbility()
		self.parent = self:GetParent()
	end
	function modifier_jotaro_absolute_defense_cooldown3:OnDestroy()
		self.parent:AddNewModifier(self.parent, self.ab, "modifier_jotaro_absolute_defense3", {})
	end
end