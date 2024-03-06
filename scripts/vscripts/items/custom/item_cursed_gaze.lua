-----------------------------------------------------------------------------------------------------------
--	Bloodthorn definition
-----------------------------------------------------------------------------------------------------------

item_cursed_gaze = item_cursed_gaze or class({})
LinkLuaModifier( "modifier_item_imba_bloodthorn", "items/custom/item_cursed_gaze.lua", LUA_MODIFIER_MOTION_NONE )			-- Owner's bonus attributes, stackable
LinkLuaModifier( "modifier_item_imba_bloodthorn_attacker_crit", "items/custom/item_cursed_gaze.lua", LUA_MODIFIER_MOTION_NONE )		-- Active attackers' crit buff
LinkLuaModifier( "modifier_item_imba_bloodthorn_debuff", "items/custom/item_cursed_gaze.lua", LUA_MODIFIER_MOTION_NONE )	-- Active debuff
LinkLuaModifier( "modifier_item_imba_bloodthorn_debuff_disarm", "items/custom/item_cursed_gaze.lua", LUA_MODIFIER_MOTION_NONE ) -- disarm owner on hit effect

function item_cursed_gaze:GetAbilityTextureName()
	return "cursed_gaze"
end

function item_cursed_gaze:GetIntrinsicModifierName()
	return "modifier_item_imba_bloodthorn" end

function item_cursed_gaze:OnSpellStart()
	if IsServer() then

		-- Parameters
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local curse_duration = self:GetSpecialValueFor("curse_duration")

		-- If the target possesses a ready Linken's Sphere, do nothing
		if target:GetTeam() ~= caster:GetTeam() then
			if target:TriggerSpellAbsorb(self) then
				return nil
			end
		end

		-- If the target is magic immune (Lotus Orb/Anti Mage), do nothing
		if target:IsMagicImmune() then
			return nil
		end

		-- Play the cast sound
		target:EmitSound("DOTA_Item.Nullifier.Target")
		target:EmitSound("DOTA_Item.Orchid.Activate")
		if target:HasModifier("modifier_item_imba_bloodthorn_debuff") then
			target:RemoveModifierByName("modifier_item_imba_bloodthorn_debuff")
		end		


		-- Apply the Orchid debuff
		target:AddNewModifier(caster, self, "modifier_item_imba_bloodthorn_debuff", {duration = curse_duration })
		caster:AddNewModifier(self:GetCaster(), self, "modifier_item_imba_bloodthorn_debuff_disarm", {duration = curse_duration})
	end
end

-----------------------------------------------------------------------------------------------------------
--	Bloodthorn owner bonus attributes (stackable)
-----------------------------------------------------------------------------------------------------------

modifier_item_imba_bloodthorn = modifier_item_imba_bloodthorn or class({})

function modifier_item_imba_bloodthorn:IsHidden()		return true end
function modifier_item_imba_bloodthorn:IsPurgable()		return false end
function modifier_item_imba_bloodthorn:RemoveOnDeath()	return false end
function modifier_item_imba_bloodthorn:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

-- Adds the unique modifier when created
function modifier_item_imba_bloodthorn:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	self.item = self:GetAbility()
	self.parent = self:GetParent()
	if self.parent:IsHero() and self.item then
		self.bonus_health = self.item:GetSpecialValueFor("bonus_health")
		self.bonus_armor = self.item:GetSpecialValueFor("bonus_armor")
		self.bonus_damage = self.item:GetSpecialValueFor("bonus_damage")
		self.bonus_mana_regen = self.item:GetSpecialValueFor("bonus_mana_regen")
		self.magic_resist = self.item:GetSpecialValueFor("bonus_magic_resist")
		self.status_resist = self.item:GetSpecialValueFor("status_resistance")
		--self:CheckUnique(true)
	end
end

function modifier_item_imba_bloodthorn:OnDestroy(keys)
	if IsServer() then
		--self:CheckUnique(false)
	end
end

-- Attribute bonuses
function modifier_item_imba_bloodthorn:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		
		-- MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_item_imba_bloodthorn:GetModifierHealthBonus()
	return self.bonus_health end

function modifier_item_imba_bloodthorn:GetModifierPhysicalArmorBonus()
	return self.bonus_armor end

function modifier_item_imba_bloodthorn:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage end

function modifier_item_imba_bloodthorn:GetModifierConstantManaRegen()
	return self.bonus_mana_regen end

function modifier_item_imba_bloodthorn:GetModifierMagicalResistanceBonus()
	return self.magic_resist end

function modifier_item_imba_bloodthorn:GetModifierStatusResistanceStacking()
	return self.status_resist end	

-- -- Roll for the crit chance
-- function modifier_item_imba_bloodthorn:GetModifierPreAttack_CriticalStrike(keys)
	-- if self:GetAbility() then
		-- local owner = self:GetParent()

		-- -- If this unit is the attacker, roll for a crit
		-- if owner == keys.attacker then
			-- if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self) then
				-- return self:GetAbility():GetSpecialValueFor("crit_damage")
			-- end
		-- end
	-- end
-- end

-----------------------------------------------------------------------------------------------------------
--	Cursed Gaze active debuff
-----------------------------------------------------------------------------------------------------------
modifier_item_imba_bloodthorn_debuff = modifier_item_imba_bloodthorn_debuff or class({})
function modifier_item_imba_bloodthorn_debuff:IsHidden() return false end
function modifier_item_imba_bloodthorn_debuff:IsDebuff() return true end
function modifier_item_imba_bloodthorn_debuff:IsPurgable() return false end

-- Modifier particle
function modifier_item_imba_bloodthorn_debuff:GetEffectName()
	return "particles/items4_fx/nullifier_mute_debuff.vpcf"
end

function modifier_item_imba_bloodthorn_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

-- Reset damage storage tracking, track debuff parameters to prevent errors if the item is unequipped
function modifier_item_imba_bloodthorn_debuff:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local caster = self:GetCaster()
		local marci_bonus = 0
		if caster:HasModifier("modifier_super_scepter") then
			if caster:HasModifier("modifier_marci_unleash_flurry") then
				marci_bonus = 5
			end                                 
		end 		
		self.target_crit_multiplier = self:GetAbility():GetSpecialValueFor("target_crit_multiplier") + marci_bonus	
	end
end

-- Declare modifier states
function modifier_item_imba_bloodthorn_debuff:CheckState()
	return {
		--[MODIFIER_STATE_SILENCED]		= true,
		[MODIFIER_STATE_EVADE_DISABLED] = true,
	}
end

-- Declare modifier events/properties
function modifier_item_imba_bloodthorn_debuff:DeclareFunctions()
	return {
		--MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
	}
end

-- Grant the crit modifier to attackers
function modifier_item_imba_bloodthorn_debuff:OnAttackStart(keys)
	if IsServer() then
		local owner = self:GetParent()
		--local caster = self:GetCaster()

		-- If this unit is the target, grant the attacker a crit buff
		if owner == keys.target then
			local attacker = keys.attacker
			attacker:AddNewModifier(owner, self:GetAbility(), "modifier_item_imba_bloodthorn_attacker_crit", {duration = 1.0, target_crit_multiplier = self.target_crit_multiplier})
			--caster:AddNewModifier(owner, self:GetAbility(), "modifier_item_imba_bloodthorn_debuff_disarm", {duration = 1.0, target_crit_multiplier = self.target_crit_multiplier})
			--caster:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_imba_bloodthorn_debuff_disarm", {duration = 2.0})
		end
	end
end

-- Track damage taken
--[[function modifier_item_imba_bloodthorn_debuff:OnTakeDamage(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.unit

		-- If this unit is the one suffering damage, amplify and store it
		if owner == target then
			owner.orchid_damage_storage = owner.orchid_damage_storage + keys.damage
		end
	end
end]]

-- When the debuff ends, deal damage
function modifier_item_imba_bloodthorn_debuff:OnDestroy()
	if IsServer() then

		-- Parameters
		--[[local owner = self:GetParent()
		local ability = self:GetAbility()
		local caster = ability:GetCaster()
		local damage_factor = ability:GetSpecialValueFor("silence_damage_percent")

		-- If damage was taken, play the effect and damage the owner
		if owner.orchid_damage_storage > 0 then

			-- Calculate and deal damage
			local damage = owner.orchid_damage_storage * damage_factor * 0.01
			ApplyDamage({attacker = caster, victim = owner, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

			-- Fire damage particle
			local orchid_end_pfx = ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_OVERHEAD_FOLLOW, owner)
			ParticleManager:SetParticleControl(orchid_end_pfx, 0, owner:GetAbsOrigin())
			ParticleManager:SetParticleControl(orchid_end_pfx, 1, Vector(100, 0, 0))
			ParticleManager:ReleaseParticleIndex(orchid_end_pfx)
		end

		-- Clear damage taken variable
		self:GetParent().orchid_damage_storage = nil]]
	end
end

------------------------------------------------------------
-- Disarm debuff
-------
modifier_item_imba_bloodthorn_debuff_disarm = modifier_item_imba_bloodthorn_debuff_disarm or class({})
function modifier_item_imba_bloodthorn_debuff_disarm:IsHidden() return false end
function modifier_item_imba_bloodthorn_debuff_disarm:IsDebuff() return true end
function modifier_item_imba_bloodthorn_debuff_disarm:IsPurgable() return false end

function modifier_item_imba_bloodthorn_debuff_disarm:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	return {
		[MODIFIER_STATE_DISARMED] = true,
		--[MODIFIER_STATE_SILENCED] = true
	}
end
-----------------------------------------------------------------------------------------------------------
--	Bloodthorn active attacker crit buff
-----------------------------------------------------------------------------------------------------------
modifier_item_imba_bloodthorn_attacker_crit = modifier_item_imba_bloodthorn_attacker_crit or class({})
function modifier_item_imba_bloodthorn_attacker_crit:IsHidden() return true end
function modifier_item_imba_bloodthorn_attacker_crit:IsDebuff() return false end
function modifier_item_imba_bloodthorn_attacker_crit:IsPurgable() return false end



-- Track parameters to prevent errors if the item is unequipped
function modifier_item_imba_bloodthorn_attacker_crit:OnCreated(keys)
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	if IsServer() then
		self.target_crit_multiplier = keys.target_crit_multiplier
	end
end

-- Declare modifier events/properties
function modifier_item_imba_bloodthorn_attacker_crit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

-- Grant the crit damage multiplier
function modifier_item_imba_bloodthorn_attacker_crit:GetModifierPreAttack_CriticalStrike()
	if IsServer() then
		return self.target_crit_multiplier
	end
end

-- Remove the crit modifier when the attack is concluded
function modifier_item_imba_bloodthorn_attacker_crit:OnAttackLanded(keys)
	if IsServer() then

		-- If this unit is the attacker, remove its crit modifier
		if self:GetParent() == keys.attacker then
			self:GetParent():RemoveModifierByName("modifier_item_imba_bloodthorn_attacker_crit")

			-- Increase the crit damage count
			local debuff_modifier = keys.target:FindModifierByName("modifier_item_imba_bloodthorn_debuff")
			
			if debuff_modifier then
				debuff_modifier.target_crit_multiplier = debuff_modifier.target_crit_multiplier + self:GetAbility():GetSpecialValueFor("crit_mult_increase")
			end
		end
	end
end