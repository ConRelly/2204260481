item_durandal = class({})
LinkLuaModifier("modifier_seal_act", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_durandal", "items/durandal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_durandal_shield", "items/durandal.lua", LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------------------------------------------------------
function item_durandal:ProcsMagicStick() return false end
function item_durandal:GetAbilityTextureName()
	if IsClient() then
		local icon = "custom/durandal_off"
		if self:GetToggleState() then
			icon = "custom/durandal"
		else
			icon = "custom/durandal_off"
		end
		return icon
	end
end
function item_durandal:GetIntrinsicModifierName() return "modifier_item_durandal" end
function item_durandal:OnOwnerSpawned() if self.toggle_state then self:ToggleAbility() end end
function item_durandal:OnOwnerDied() self.toggle_state = self:GetToggleState() end
function item_durandal:OnToggle()
	if not IsServer() then return end
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_durandal_shield", {})
	else
		self:GetCaster():RemoveModifierByNameAndCaster("modifier_durandal_shield", self:GetCaster())
	end
end

----------------------------------------------------------------------------------------------------------------------------
modifier_item_durandal = class({})
function modifier_item_durandal:IsHidden() return true end
function modifier_item_durandal:IsPurgable() return false end
function modifier_item_durandal:RemoveOnDeath() return false end
function modifier_item_durandal:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_durandal:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_item_durandal:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("dmg") end
end
function modifier_item_durandal:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_item_durandal:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi") end
end
function modifier_item_durandal:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_item_durandal:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_item_durandal:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_item_durandal:GetModifierTotalPercentageManaRegen()
	if self:GetAbility() then
		mana_regen = nil
		if self:GetCaster():HasModifier("modifier_durandal_shield") then
			mana_regen = 0
		else
			mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen")
		end
		return mana_regen
	end
end
function modifier_item_durandal:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms") end
end
function modifier_item_durandal:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_damage") end
end
function modifier_item_durandal:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_item_durandal:OnCreated(kv)
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		Timers:CreateTimer(FrameTime(), function()
			caster:AddNewModifier(caster, ability, "modifier_seal_act", {})
		end)
	end
end
function modifier_item_durandal:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		caster:RemoveModifierByName("modifier_seal_act")
	end
end
function modifier_item_durandal:OnTakeDamage(params)
	if IsServer() then
		local ability = self:GetAbility()
		local unit = params.unit
		local target = params.target
		local attacker = params.attacker
		local incdamage = params.damage
		local threshold = self:GetAbility():GetSpecialValueFor("cost_constant")
		local mana_usege = self:GetAbility():GetSpecialValueFor("mana_usege")
		local crit_damage_mult = self:GetAbility():GetSpecialValueFor("crit_damage_mult")
		if attacker == self:GetCaster() and
		not attacker:IsIllusion() and
		attacker:IsRealHero() and
		not attacker:IsTempestDouble() and
		unit:IsAlive() and
		bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and
		bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
			local mana = attacker:GetMana()
			local health = attacker:GetHealth()
			local damageTable = incdamage * ((crit_damage_mult - 100) / 100)
			local popup_dmg = damageTable + incdamage
			local mana_cost = damageTable *  (mana_usege / 100) * (threshold / (threshold + attacker:GetIntellect()))
			if not attacker:HasModifier("immortal_spells_req_hp") then
				if mana >= mana_cost and mana >= threshold then
					if unit and unit ~= attacker and unit:GetTeamNumber() ~= attacker:GetTeamNumber() then
						if params.damage_type ~= 1 then
							SpellCrit(ability, unit, attacker, damageTable, params.damage_type, params.damage_flags, popup_dmg, Vector(100, 149, 237))
							attacker:SpendMana(mana_cost, nil)
						end
					end
				end
			else
				if health >= mana_cost and health >= threshold then
					if unit and unit ~= attacker and unit:GetTeamNumber() ~= attacker:GetTeamNumber() then
						if params.damage_type ~= 1 then
							SpellCrit(ability, unit, attacker, damageTable, params.damage_type, params.damage_flags, popup_dmg, Vector(100, 149, 18))
							attacker:SetHealth(attacker:GetHealth() - mana_cost)
						end
					end
				end
			end
		end
	end
end
function SpellCrit(ability, victim, attacker, damage, damage_type, damage_flags, popup_dmg, popup_color)
	if IsServer() then
		ApplyDamage({ victim = victim, damage = damage, damage_type = damage_type, damage_flags = damage_flags + DOTA_DAMAGE_FLAG_HPLOSS, attacker = attacker, ability = ability})
		create_popup({target = victim, value = popup_dmg, color = popup_color, type = "crit", pos = 4})
	end
end

----------------------------------------------------------------------------------------------------------------------------
modifier_durandal_shield = class({})
function modifier_durandal_shield:GetEffectName() return "particles/custom/items/durandal/mana_shield.vpcf" end
function modifier_durandal_shield:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_durandal_shield:IsPurgable() return false end
function modifier_durandal_shield:RemoveOnDeath() return false end
function modifier_durandal_shield:OnCreated()
	if not IsServer() then return end
	if not self:GetAbility() then self:Destroy() return end
	self.damage_per_mana = self:GetAbility():GetSpecialValueFor("damage_per_mana")
	self.absorb = self:GetAbility():GetSpecialValueFor("absorb")
	self.mana_raw = self:GetCaster():GetMana()
	self.mana_pct = self:GetCaster():GetManaPercent()
end
function modifier_durandal_shield:DeclareFunctions()
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_durandal_shield:GetModifierIncomingDamage_Percentage(keys)
	if not IsServer() then return end
	if not (keys.damage_type == DAMAGE_TYPE_MAGICAL and self:GetCaster():IsMagicImmune()) and self:GetCaster().GetMana then
		local mana_to_block	= keys.original_damage * self.absorb * 0.01 / self.damage_per_mana
		if mana_to_block >= self:GetCaster():GetMana() then
			self:GetCaster():EmitSound("Hero_QueenOfPain.Attack")
			local shield_particle = ParticleManager:CreateParticle("particles/custom/items/durandal/mana_shield_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:ReleaseParticleIndex(shield_particle)
		end
		local mana_before = self:GetCaster():GetMana()
		self:GetCaster():Script_ReduceMana(mana_to_block, nil)
		local mana_after = self:GetCaster():GetMana()
		return math.min(self.absorb, self.absorb * self:GetCaster():GetMana() / math.max(mana_to_block, 1)) * (-1)
	end
end