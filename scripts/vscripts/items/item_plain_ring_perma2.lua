require("lib/my")

function add_perma(keys)
	if keys.caster:IsHero() and not keys.caster:HasModifier("modifier_arc_warden_tempest_double") then
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_plain_ring_perma2", {duration = -1, invincibility_duration = keys.ability:GetSpecialValueFor("duration"), cooldown = keys.ability:GetSpecialValueFor("cooldown"), min_health = keys.ability:GetSpecialValueFor("min_health")})
		keys.caster:RemoveItem(find_item(keys.caster, "item_plain_perma"))
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_plain_ring_perma_armor", {})
		
	end
end

LinkLuaModifier("modifier_item_plain_ring_perma2", "items/item_plain_ring_perma2.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_plain_ring_perma2 = class({})

function modifier_item_plain_ring_perma2:GetTexture()
	return "plain_ring"
end

function modifier_item_plain_ring_perma2:IsHidden()
	return false
end
function modifier_item_plain_ring_perma2:IsPurgable()
	return false
end
function modifier_item_plain_ring_perma2:RemoveOnDeath()
    return false
end


function modifier_item_plain_ring_perma2:OnIntervalThink()
	if IsServer() then
		if self.cooldownCounter > 0 then
			self.cooldownCounter = self.cooldownCounter -1
		else
			self:StartIntervalThink(-1)
		end
		self:SetStackCount(self.cooldownCounter)
	end
end

function modifier_item_plain_ring_perma2:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		
	}
end

function modifier_item_plain_ring_perma2:OnCreated(keys)
	if IsServer() then
		self.parent = self:GetParent()
		self.invincibility_duration = keys.invincibility_duration
		self.cooldown = keys.cooldown
		self.cooldownCounter = 0
		self:SetStackCount(0)
		self.ability = self:GetAbility()
		self.min_health = keys.min_health
	end	
end


function modifier_item_plain_ring_perma2:OnTakeDamage(keys)
	if IsServer() then
		local attacker = keys.attacker
		local unit = keys.unit
		if self.parent == unit and self.cooldownCounter == 0 and self.parent:GetHealth() < 25  then
			self.parent:SetHealth(26)
			self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_plain_ring_perma_invincibility2", {duration = self.invincibility_duration, min_health = self.min_health})
			self.cooldownCounter = self.cooldown       --math.floor(self.cooldown * self.parent:GetCooldownReduction())
			self:StartIntervalThink(1)
		end
	end	
end


LinkLuaModifier("modifier_item_plain_ring_perma_armor", "items/item_plain_ring_perma2.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_plain_ring_perma_armor = class({})

function modifier_item_plain_ring_perma_armor:IsHidden()
	return true
end
function modifier_item_plain_ring_perma_armor:IsPurgable()
	return false
end
function modifier_item_plain_ring_perma_armor:RemoveOnDeath()
    return false
end
function modifier_item_plain_ring_perma_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		
	}
end

function modifier_item_plain_ring_perma_armor:GetModifierPhysicalArmorBonus()
	return 20
end

LinkLuaModifier("modifier_item_plain_ring_perma_invincibility2", "items/item_plain_ring_perma2.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_plain_ring_perma_invincibility2 = class({})

function modifier_item_plain_ring_perma_invincibility2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		
	}
end

function modifier_item_plain_ring_perma_invincibility2:IsPurgable()
	return false
end


function modifier_item_plain_ring_perma_invincibility2:GetMinHealth()
	return 10
end

function modifier_item_plain_ring_perma_invincibility2:GetModifierIncomingDamage_Percentage()
	return -400
end



function modifier_item_plain_ring_perma_invincibility2:OnCreated(keys)
	if IsServer() then
		local parent = self:GetParent()
		self.min_health = keys.min_health
	end	
end
function modifier_item_plain_ring_perma_invincibility2:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
			ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			parent:Heal((parent:GetMaxHealth() * self.min_health * 0.01), parent)
	end	
end

function modifier_item_plain_ring_perma_invincibility2:GetTexture()
	return "plain_ring_invincibility"
end
function modifier_item_plain_ring_perma_invincibility2:GetEffectName()
	return "particles/world_shrine/dire_shrine_regen.vpcf"
end

function modifier_item_plain_ring_perma_invincibility2:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end