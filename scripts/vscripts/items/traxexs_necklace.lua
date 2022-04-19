LinkLuaModifier("modifier_traxexs_necklace", "items/traxexs_necklace", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_traxexs_necklace_chill", "items/traxexs_necklace", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_traxexs_necklace_frozen", "items/traxexs_necklace", LUA_MODIFIER_MOTION_NONE)

-----------------------
-- Traxex's Necklace --
-----------------------
item_traxexs_necklace = class({})
function item_traxexs_necklace:GetAOERadius() return self:GetSpecialValueFor("active_radius") end
function item_traxexs_necklace:GetIntrinsicModifierName() return "modifier_traxexs_necklace" end
function item_traxexs_necklace:OnSpellStart()
	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Crystal.CrystalNova", self:GetCaster())
--[[
	local particle_fx = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle_fx, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(particle_fx, 1, Vector(self:GetSpecialValueFor("active_radius"), 1, 1))
]]
	local particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle_fx, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(particle_fx, 1, Vector(self:GetSpecialValueFor("active_radius"), self:GetSpecialValueFor("chill_duration"), self:GetSpecialValueFor("active_radius")))
	ParticleManager:SetParticleControl(particle_fx, 2, self:GetCursorPosition())

	ParticleManager:ReleaseParticleIndex(particle_fx)

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("active_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		local chill = enemy:AddNewModifier(self:GetCaster(), self, "modifier_traxexs_necklace_chill", {duration = self:GetSpecialValueFor("chill_duration")})
		chill:SetStackCount(chill:GetStackCount() * (1 + self:GetSpecialValueFor("active_chill_bonus")/100) + self:GetSpecialValueFor("active_chill"))
	end
end


modifier_traxexs_necklace = modifier_traxexs_necklace or class({})
function modifier_traxexs_necklace:IsHidden() return true end
function modifier_traxexs_necklace:IsPurgable() return false end
function modifier_traxexs_necklace:RemoveOnDeath() return false end
--function modifier_traxexs_necklace:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end  -- you don't want multiple of same item being best option
function modifier_traxexs_necklace:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE}
end
function modifier_traxexs_necklace:GetModifierBonusStats_Intellect() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_int") end end
function modifier_traxexs_necklace:GetModifierEvasion_Constant() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_evasion") end end
function modifier_traxexs_necklace:GetModifierProcAttack_BonusDamage_Pure(keys)
	if not IsServer() then return end
	local parent = self:GetParent()
	if parent == keys.attacker then
		if keys.target == nil then return end
		if parent:IsIllusion() then return end
		local parent_name = parent:GetUnitName()
		local ms_diff = parent:GetIdealSpeed() - keys.target:GetIdealSpeed()
		if ms_diff > 0 then
			if parent_name ~= "npc_dota_hero_windrunner" then
				ms_diff = ms_diff / 2
			end	
--			SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, keys.target, ms_diff, nil)
			return ms_diff
		end
	end
	return 0
end

------------------------------
-- Traxex's Necklace Active --
------------------------------
--[[
modifier_traxexs_necklace_chill = class({})
function modifier_traxexs_necklace_chill:IsDebuff() return true end
function modifier_traxexs_necklace_chill:IsHidden() return false end
function modifier_traxexs_necklace_chill:IsPurgable() return true end
function modifier_traxexs_necklace_chill:GetEffectName() return "particles/items2_fx/veil_of_discord_debuff.vpcf" end
function modifier_traxexs_necklace_chill:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_traxexs_necklace_chill:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
end
function modifier_traxexs_necklace_chill:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_traxexs_necklace_chill:GetModifierIncomingDamage_Percentage(keys)
	if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		return self.spell_amp
	end
end
function modifier_traxexs_necklace_chill:OnTooltip() return self.spell_amp end
]]

modifier_traxexs_necklace_chill = class({})
function modifier_traxexs_necklace_chill:IsDebuff() return true end
function modifier_traxexs_necklace_chill:IsPurgable() return true end
function modifier_traxexs_necklace_chill:GetTexture() return "ancient_apparition_cold_feet" end
function modifier_traxexs_necklace_chill:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_traxexs_necklace_chill:GetStatusEffectName() return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_dire.vpcf" end
function modifier_traxexs_necklace_chill:StatusEffectPriority() return 10 end
function modifier_traxexs_necklace_chill:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_traxexs_necklace_chill:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
end
function modifier_traxexs_necklace_chill:OnStackCountChanged(old)
	if not IsServer() then return end
	if self:GetParent():HasModifier("modifier_traxexs_necklace_frozen") then return end
	if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("chill_max") then
		if self:GetParent():HasModifier("modifier_traxexs_necklace_chill") then
			self:GetParent():RemoveModifierByName("modifier_traxexs_necklace_chill")
		end
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_traxexs_necklace_frozen", {duration = self:GetAbility():GetSpecialValueFor("freeze_duration")})
	end
end
function modifier_traxexs_necklace_chill:OnIntervalThink()
	if not IsServer() then return end
	local stacks = self:GetStackCount()
	if stacks >= self:GetAbility():GetSpecialValueFor("chill_max") then
		if self:GetParent():HasModifier("modifier_traxexs_necklace_chill") then
			self:GetParent():RemoveModifierByName("modifier_traxexs_necklace_chill")
		end
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_traxexs_necklace_frozen", {duration = self:GetAbility():GetSpecialValueFor("freeze_duration")})
	end
	self:SetStackCount(stacks - (stacks * self:GetAbility():GetSpecialValueFor("chill_thaw_pct") / 100))
end
function modifier_traxexs_necklace_chill:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_traxexs_necklace_chill:GetModifierMoveSpeedBonus_Percentage()
	return math.max(self:GetStackCount() / 10) * (-1)
end




modifier_traxexs_necklace_frozen = class({})
function modifier_traxexs_necklace_frozen:IsHidden() return false end
function modifier_traxexs_necklace_frozen:IsDebuff() return true end
function modifier_traxexs_necklace_frozen:IsPurgeException() return true end
function modifier_traxexs_necklace_frozen:GetTexture() return "winter_wyvern_cold_embrace" end
function modifier_traxexs_necklace_frozen:GetStatusEffectName() return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf" end
function modifier_traxexs_necklace_frozen:StatusEffectPriority() return 11 end
function modifier_traxexs_necklace_frozen:GetEffectName() return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf" end

function modifier_traxexs_necklace_frozen:OnCreated()
	if self:GetParent():IsMagicImmune() then self:Destroy() return end
	if IsServer() then
--		self:SetDuration(self:GetAbility():GetSpecialValueFor("freeze_duration"))
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_traxexs_necklace_frozen:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_traxexs_necklace_chill") then
		self:GetParent():RemoveModifierByName("modifier_traxexs_necklace_chill")
	end
end
function modifier_traxexs_necklace_frozen:OnDestroy()
	if not IsServer() then return end
	local shatter = true
	if self:GetParent():IsMagicImmune() then
		shatter = false
	end
	if shatter then
		local damage = self:GetParent():GetMaxHealth() * self:GetAbility():GetSpecialValueFor("freeze_shatter_hp_damage") / 100
		if self:GetStackCount() == 1 then
			damage = damage * 2
		end
		local radius = self:GetAbility():GetSpecialValueFor("freeze_shatter_radius")
--[[
		local shatter_crack = ParticleManager:CreateParticle("particles/item/skadi/skadi_ground.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleAlwaysSimulate(shatter_crack)
		ParticleManager:SetParticleControl(shatter_crack, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(shatter_crack, 2, Vector(radius * 1.15, 1, 1))
		ParticleManager:ReleaseParticleIndex(shatter_crack)
]]
		local shatter_crack = ParticleManager:CreateParticle("particles/custom/items/wr_exclusive/wr_exclusive_frozen_broke.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(shatter_crack, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(shatter_crack, 1, Vector(radius, self:GetRemainingTime(), radius))
		ParticleManager:ReleaseParticleIndex(shatter_crack)

		EmitSoundOn("Hero_Ancient_Apparition.IceBlast.Target", self:GetParent())

		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, target in pairs(enemies) do
			if target:IsMagicImmune() then return end
			ApplyDamage({
				victim = target,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,--DAMAGE_TYPE_MAGICAL,
				damage_flags = DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR,--DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR,
			})
		end
	end
end
function modifier_traxexs_necklace_frozen:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_INVISIBLE] = false}
end
function modifier_traxexs_necklace_frozen:DeclareFunctions()
	return {MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end
function modifier_traxexs_necklace_frozen:GetModifierPercentageCasttime() return -95 end
function modifier_traxexs_necklace_frozen:GetModifierTurnRate_Percentage() return -95 end
