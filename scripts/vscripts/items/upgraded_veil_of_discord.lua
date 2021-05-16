----------------------------
--UPGRADED VEIL OF DISCORD--
----------------------------
item_upgraded_veil_of_discord = item_upgraded_veil_of_discord or class({})
LinkLuaModifier("modifier_veil_of_discord", "items/upgraded_veil_of_discord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_veil_debuff_aura", "items/upgraded_veil_of_discord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_veil_buff", "items/upgraded_veil_of_discord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_veil_buff_aura", "items/upgraded_veil_of_discord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_veil_active_debuff", "items/upgraded_veil_of_discord.lua", LUA_MODIFIER_MOTION_NONE)

function item_upgraded_veil_of_discord:OnSpellStart()
	local caster = self:GetCaster()
	local target_loc = self:GetCursorPosition()
	local particle = "particles/items2_fx/veil_of_discord.vpcf"
	caster:EmitSound("DOTA_Item.VeilofDiscord.Activate")
	local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_fx, 0, target_loc)
	ParticleManager:SetParticleControl(particle_fx, 1, Vector(self:GetSpecialValueFor("debuff_radius"), 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_fx)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_loc, nil, self:GetSpecialValueFor("debuff_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_veil_active_debuff", {duration = self:GetSpecialValueFor("debuff_duration") * (1 - enemy:GetStatusResistance())})
	end
end
function item_upgraded_veil_of_discord:GetAOERadius() return self:GetSpecialValueFor("debuff_radius") end
function item_upgraded_veil_of_discord:GetIntrinsicModifierName() return "modifier_veil_of_discord" end

-------------------
-- ACTIVE DEBUFF --
-------------------
modifier_veil_active_debuff = modifier_veil_active_debuff or class({})
function modifier_veil_active_debuff:IsDebuff() return true end
function modifier_veil_active_debuff:IsHidden() return false end
function modifier_veil_active_debuff:IsPurgable() return true end
function modifier_veil_active_debuff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
end
function modifier_veil_active_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_veil_active_debuff:GetModifierIncomingDamage_Percentage(keys)
	if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		return self.spell_amp
	end
end
function modifier_veil_active_debuff:OnTooltip() return self.spell_amp end
function modifier_veil_active_debuff:GetEffectName() return "particles/items2_fx/veil_of_discord_debuff.vpcf" end
function modifier_veil_active_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_veil_of_discord = modifier_veil_of_discord or class({})
function modifier_veil_of_discord:IsHidden() return true end
function modifier_veil_of_discord:IsPurgable() return false end
function modifier_veil_of_discord:RemoveOnDeath() return false end
function modifier_veil_of_discord:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_veil_of_discord:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	local ability = self:GetAbility()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), ability, "modifier_veil_buff", {})
	end
	if self:GetParent():IsHero() and ability then
		self.all_stats = ability:GetSpecialValueFor("all_stats")
		self.mana = ability:GetSpecialValueFor("mana")
	end
end
function modifier_veil_of_discord:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS}
end
function modifier_veil_of_discord:GetModifierBonusStats_Intellect() return self.all_stats end
function modifier_veil_of_discord:GetModifierBonusStats_Agility() return self.all_stats end
function modifier_veil_of_discord:GetModifierBonusStats_Strength() return self.all_stats end
function modifier_veil_of_discord:GetModifierManaBonus() return self.mana end

-----------------
-- DEBUFF AURA --
-----------------
function modifier_veil_of_discord:IsAura() return true end
function modifier_veil_of_discord:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_veil_of_discord:GetAuraSearchType() return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO end
function modifier_veil_of_discord:GetModifierAura() return "modifier_veil_debuff_aura" end
function modifier_veil_of_discord:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_veil_of_discord:OnDestroy()
	if IsServer() and self and not self:IsNull() and self:GetParent() and not self:GetParent():IsNull() then
		self:GetParent():RemoveModifierByName("modifier_veil_buff")
	end
end

--- DEBUFF AURA MODIFIER
modifier_veil_debuff_aura = modifier_veil_debuff_aura or class({})
function modifier_veil_debuff_aura:IsDebuff() return true end
function modifier_veil_debuff_aura:IsHidden() return false end
function modifier_veil_debuff_aura:IsPurgable() return false end
function modifier_veil_debuff_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")
	self.status_resistance = self:GetAbility():GetSpecialValueFor("status_resistance")
end
function modifier_veil_debuff_aura:DeclareFunctions()  
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end
function modifier_veil_debuff_aura:GetModifierMagicalResistanceBonus() return self.magic_resistance * (-1) end
function modifier_veil_debuff_aura:GetModifierStatusResistanceStacking() return self.status_resistance * (-1) end

---------------
-- BUFF AURA --
---------------
modifier_veil_buff = modifier_veil_buff or class({})
function modifier_veil_buff:IsHidden() return true end
function modifier_veil_buff:IsPurgable() return false end
function modifier_veil_buff:RemoveOnDeath() return false end
function modifier_veil_buff:IsAura() return true end
function modifier_veil_buff:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_veil_buff:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_veil_buff:GetModifierAura() return "modifier_veil_buff_aura" end
function modifier_veil_buff:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end

--- BUFF AURA MODIFIER
modifier_veil_buff_aura = modifier_veil_buff_aura or class({})
function modifier_veil_buff_aura:IsDebuff() return false end
function modifier_veil_buff_aura:IsHidden() return false end
function modifier_veil_buff_aura:IsPurgable() return true end
function modifier_veil_buff_aura:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	self.aura_mana_regen = self:GetAbility():GetSpecialValueFor("aura_mana_regen")
	self.aura_spell_power = self:GetAbility():GetSpecialValueFor("aura_spell_power")
end
function modifier_veil_buff_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_veil_buff_aura:GetModifierConstantManaRegen() return self.aura_mana_regen end
function modifier_veil_buff_aura:GetModifierSpellAmplify_Percentage() return self.aura_spell_power end
