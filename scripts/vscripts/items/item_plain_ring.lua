require("lib/my")

LinkLuaModifier("modifier_item_plain_ring_aura", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring_buff", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring_invincibility", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plain_ring_frenzy", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)


item_plain_ring = class({})
function item_plain_ring:GetIntrinsicModifierName() return "modifier_item_plain_ring_aura" end


modifier_item_plain_ring_aura = class({})
function modifier_item_plain_ring_aura:IsHidden() return true end
function modifier_item_plain_ring_aura:IsPurgable() return false end
function modifier_item_plain_ring_aura:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_plain_ring_aura:OnCreated(keys)
	if IsServer() then
		local parent = self:GetParent()
		if parent then
			if not parent:IsIllusion() or not parent:HasModifier("modifier_arc_warden_tempest_double") then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_plain_ring", {})
				EmitSoundOn("Hero_Antimage.Counterspell.Absorb", parent)
			end
		end
	end	
end
function modifier_item_plain_ring_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_item_plain_ring_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_item_plain_ring_aura:IsAura() return true end
function modifier_item_plain_ring_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_plain_ring_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_plain_ring_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_plain_ring_aura:GetModifierAura() return "modifier_item_plain_ring_buff" end


modifier_item_plain_ring_buff = class({})
function modifier_item_plain_ring_buff:IsHidden() return false end
function modifier_item_plain_ring_buff:IsPurgable() return false end
function modifier_item_plain_ring_buff:GetTexture() return "plain_ring" end
function modifier_item_plain_ring_buff:OnCreated()
	self.aura_armor = self:GetAbility():GetSpecialValueFor("aura_armor")
	self.aura_mana_regen = self:GetAbility():GetSpecialValueFor("aura_mana_regen")
end
function modifier_item_plain_ring_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_item_plain_ring_buff:GetModifierPhysicalArmorBonus() return self.aura_armor end
function modifier_item_plain_ring_buff:GetModifierConstantManaRegen() return self.aura_mana_regen end


modifier_item_plain_ring = class({})
function modifier_item_plain_ring:IsHidden() return true end
function modifier_item_plain_ring:IsPurgable() return false end
function modifier_item_plain_ring:OnCreated(keys)
	if IsServer() then
		local extra = 0
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		if self.parent:GetLevel() > 88 then
			extra = 10
		end	
		self.invincibility_duration = self.ability:GetSpecialValueFor("duration") + extra
		self.cooldown = self.ability:GetCooldown(0)
	end
end
function modifier_item_plain_ring:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_item_plain_ring:OnTakeDamage(keys)
	if IsServer() then
		local attacker = keys.attacker
		local unit = keys.unit
		if self.parent == unit and self.ability:IsCooldownReady() and self.parent:GetHealth() < 100  then
			if has_item(self.parent, "item_plain_ring") and not unit:IsNull() and IsValidEntity(unit) then
				self.parent:SetHealth(self.parent:GetMaxHealth() * 0.15)
				self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_item_plain_ring_invincibility", {duration = self.invincibility_duration})
				self.ability:StartCooldown(self.cooldown * self.parent:GetCooldownReduction())
				Timers:CreateTimer({
					endTime = 0.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
					callback = function()
						if unit and not unit:IsNull() and IsValidEntity(unit) and unit:IsAlive() then
							self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_item_plain_ring_frenzy", {duration = self.invincibility_duration + 7})
							--self.parent:SetAbsOrigin (attacker:GetAbsOrigin ())
							--FindClearRandomPositionAroundUnit(self.parent, attacker, 250)
							--attacker:SetHealth(450)
							--self.parent:PerformAttack (attacker, true, true, true, true, false, false, true)
						end						
					end
				})			
				--self.parent:EmitSoundParams("Hero_Juggernaut.OmniSlash.Damage", 0, 1.5, 0)
			else
				self:Destroy()
			end
		end
	end	
end


modifier_item_plain_ring_invincibility = class({})
function modifier_item_plain_ring_invincibility:IsPurgable() return false end
function modifier_item_plain_ring_invincibility:GetTexture() return "plain_ring_invincibility" end
function modifier_item_plain_ring_invincibility:GetEffectName() return "particles/world_shrine/dire_shrine_regen.vpcf" end
function modifier_item_plain_ring_invincibility:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_plain_ring_invincibility:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}	
end
function modifier_item_plain_ring_invincibility:GetMinHealth()
	return 1
end
function modifier_item_plain_ring_invincibility:GetModifierIncomingDamage_Percentage()
	return -400
end
function modifier_item_plain_ring_invincibility:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
			--ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		if parent:GetLevel() > 80 then
			parent:SetHealth(parent:GetMaxHealth() * 0.35)
		end	
		parent:Heal((parent:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("min_health") * 0.01), parent)		
	end	
end


modifier_item_plain_ring_frenzy = class({})
function modifier_item_plain_ring_frenzy:IsHidden() return true end
function modifier_item_plain_ring_frenzy:IsPurgable() return false end
--function modifier_item_plain_ring_frenzy:RemoveOnDeath() return false end
function modifier_item_plain_ring_frenzy:DeclareFunctions()
	return {
    MODIFIER_PROPERTY_STATUS_RESISTANCE,
    MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
	MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
	MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_plain_ring_frenzy:GetModifierStatusResistance()
	return 100
end
function modifier_item_plain_ring_frenzy:GetModifierHealAmplify_PercentageTarget()
	return 100
end
function modifier_item_plain_ring_frenzy:GetModifierMoveSpeed_Absolute()
	return 800
end
function modifier_item_plain_ring_frenzy:GetModifierAttackSpeedBonus_Constant()
	return 500
end
function modifier_item_plain_ring_frenzy:GetModifierTotalDamageOutgoing_Percentage()
	return 120
end
function modifier_item_plain_ring_frenzy:GetModifierPercentageCooldown()
	return 90
end
function modifier_item_plain_ring_frenzy:GetModifierPercentageCasttime()
	return 100
end
function modifier_item_plain_ring_frenzy:GetModifierSpellAmplify_Percentage()
	return 100
end
