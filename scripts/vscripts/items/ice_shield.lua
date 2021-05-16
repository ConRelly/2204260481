----------------
-- Ice Shield --
----------------
LinkLuaModifier("modifier_ice_shield", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_shield_attacker_slow", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_shield_ally_aura", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)

if item_ice_shield == nil then item_ice_shield = class({}) end
function item_ice_shield:GetIntrinsicModifierName() return "modifier_ice_shield" end

-- Ice Shield Modifier --
if modifier_ice_shield == nil then modifier_ice_shield = class({}) end
function modifier_ice_shield:IsHidden() return true end
function modifier_ice_shield:IsPurgable() return false end
function modifier_ice_shield:RemoveOnDeath() return false end
function modifier_ice_shield:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_shield:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_shield:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACKED} end
function modifier_ice_shield:OnAttacked(params)
	if IsServer() then
		local target = params.target
		local attacker = params.attacker
		local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
		if target == self:GetParent() and target ~= self:GetParent():GetTeamNumber() then
			if attacker ~= nil then
				attacker:EmitSound("Hero_Lich.FrostArmorDamage")
				attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ice_shield_attacker_slow", {duration = slow_duration * (1 - attacker:GetStatusResistance())})
			end
		end
	end
end

function modifier_ice_shield:IsAura() return true end
function modifier_ice_shield:IsAuraActiveOnDeath() return false end
function modifier_ice_shield:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_ice_shield:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_ice_shield:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ice_shield:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_ice_shield:GetModifierAura() return "modifier_ice_shield_ally_aura" end

-- Ice Shield Attacker Debuff --
modifier_ice_shield_attacker_slow = class({})
function modifier_ice_shield_attacker_slow:IsHidden() return false end
function modifier_ice_shield_attacker_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_ice_shield_attacker_slow:StatusEffectPriority() return 10 end
function modifier_ice_shield_attacker_slow:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end
function modifier_ice_shield_attacker_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_ice_shield_attacker_slow:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attacker_slow_as") * (-1) end
end
function modifier_ice_shield_attacker_slow:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attacker_slow_ms") * (-1) end
end

-- Ice Shield Ally Aura --
modifier_ice_shield_ally_aura = modifier_ice_shield_ally_aura or class({})
function modifier_ice_shield_ally_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_shield_ally_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_ice_shield_ally_aura:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_aura") end
end
function modifier_ice_shield_ally_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end

------------------
-- Ice Shield 2 --
------------------
LinkLuaModifier("modifier_ice_shield_2", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_shield_2_attacker_slow", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_shield_2_ally_aura", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)

if item_ice_shield_2 == nil then item_ice_shield_2 = class({}) end
function item_ice_shield_2:GetIntrinsicModifierName() return "modifier_ice_shield_2" end

-- Ice Shield Modifier --
if modifier_ice_shield_2 == nil then modifier_ice_shield_2 = class({}) end
function modifier_ice_shield_2:IsHidden() return true end
function modifier_ice_shield_2:IsPurgable() return false end
function modifier_ice_shield_2:RemoveOnDeath() return false end
function modifier_ice_shield_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_shield_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_shield_2:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACKED} end
function modifier_ice_shield_2:OnAttacked(params)
	if IsServer() then
		local target = params.target
		local attacker = params.attacker
		local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
		if target == self:GetParent() and target ~= self:GetParent():GetTeamNumber() then
			if attacker ~= nil then
				attacker:EmitSound("Hero_Lich.FrostArmorDamage")
				attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ice_shield_2_attacker_slow", {duration = slow_duration * (1 - attacker:GetStatusResistance())})
			end
		end
	end
end

function modifier_ice_shield_2:IsAura() return true end
function modifier_ice_shield_2:IsAuraActiveOnDeath() return false end
function modifier_ice_shield_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_ice_shield_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_ice_shield_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ice_shield_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_ice_shield_2:GetModifierAura() return "modifier_ice_shield_2_ally_aura" end

-- Ice Shield Attacker Debuff --
modifier_ice_shield_2_attacker_slow = class({})
function modifier_ice_shield_2_attacker_slow:IsHidden() return false end
function modifier_ice_shield_2_attacker_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_ice_shield_2_attacker_slow:StatusEffectPriority() return 10 end
function modifier_ice_shield_2_attacker_slow:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end
function modifier_ice_shield_2_attacker_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_ice_shield_2_attacker_slow:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attacker_slow_as") * (-1) end
end
function modifier_ice_shield_2_attacker_slow:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attacker_slow_ms") * (-1) end
end

-- Ice Shield Ally Aura --
modifier_ice_shield_2_ally_aura = modifier_ice_shield_2_ally_aura or class({})
function modifier_ice_shield_2_ally_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_shield_2_ally_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_ice_shield_2_ally_aura:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_aura") end
end
function modifier_ice_shield_2_ally_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end

------------------
-- Ice Shield 3 --
------------------
LinkLuaModifier("modifier_ice_shield_3", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_shield_3_attacker_slow", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_shield_3_ally_aura", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)

if item_ice_shield_3 == nil then item_ice_shield_3 = class({}) end
function item_ice_shield_3:GetIntrinsicModifierName() return "modifier_ice_shield_3" end

-- Ice Shield Modifier --
if modifier_ice_shield_3 == nil then modifier_ice_shield_3 = class({}) end
function modifier_ice_shield_3:IsHidden() return true end
function modifier_ice_shield_3:IsPurgable() return false end
function modifier_ice_shield_3:RemoveOnDeath() return false end
function modifier_ice_shield_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_shield_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_shield_3:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACKED} end
function modifier_ice_shield_3:OnAttacked(params)
	if IsServer() then
		local target = params.target
		local attacker = params.attacker
		local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
		if target == self:GetParent() and target ~= self:GetParent():GetTeamNumber() then
			if attacker ~= nil then
				attacker:EmitSound("Hero_Lich.FrostArmorDamage")
				attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ice_shield_3_attacker_slow", {duration = slow_duration * (1 - attacker:GetStatusResistance())})
			end
		end
	end
end

function modifier_ice_shield_3:IsAura() return true end
function modifier_ice_shield_3:IsAuraActiveOnDeath() return false end
function modifier_ice_shield_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_ice_shield_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_ice_shield_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ice_shield_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_ice_shield_3:GetModifierAura() return "modifier_ice_shield_3_ally_aura" end

-- Ice Shield Attacker Debuff --
modifier_ice_shield_3_attacker_slow = class({})
function modifier_ice_shield_3_attacker_slow:IsHidden() return false end
function modifier_ice_shield_3_attacker_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_ice_shield_3_attacker_slow:StatusEffectPriority() return 10 end
function modifier_ice_shield_3_attacker_slow:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end
function modifier_ice_shield_3_attacker_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_ice_shield_3_attacker_slow:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attacker_slow_as") * (-1) end
end
function modifier_ice_shield_3_attacker_slow:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attacker_slow_ms") * (-1) end
end

-- Ice Shield Ally Aura --
modifier_ice_shield_3_ally_aura = modifier_ice_shield_3_ally_aura or class({})
function modifier_ice_shield_3_ally_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_shield_3_ally_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_ice_shield_3_ally_aura:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_aura") end
end
function modifier_ice_shield_3_ally_aura:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end


--------------------
-- Shiva's Shield --
--------------------
if item_shivas_shield == nil then item_shivas_shield = class({}) end
LinkLuaModifier("modifier_shiva_shield", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shiva_shield_slow", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shiva_shield_debuff", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shiva_shield_debuff_aura", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shivas_shield_blast_slow", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shiva_frost_goddess_breath", "items/ice_shield.lua", LUA_MODIFIER_MOTION_NONE)

function item_shivas_shield:GetIntrinsicModifierName() return "modifier_shiva_shield" end
function item_shivas_shield:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local blast_radius = self:GetSpecialValueFor("blast_radius")
	local blast_speed = self:GetSpecialValueFor("blast_speed")
	local blast_slow_duration = self:GetSpecialValueFor("blast_slow_duration")
	local damage = self:GetSpecialValueFor("blast_damage")
	local blast_duration = blast_radius / blast_speed
	local current_loc = self:GetCaster():GetAbsOrigin()

	self:GetCaster():EmitSound("DOTA_Item.ShivasGuard.Activate")

	local blast_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(blast_pfx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(blast_pfx, 1, Vector(blast_radius, blast_duration * 1.33, blast_speed))
	ParticleManager:ReleaseParticleIndex(blast_pfx)

	local targets_hit = {}
	local current_radius = 0
	local tick_interval = 0.1
	Timers:CreateTimer(tick_interval, function()
		AddFOWViewer(self:GetCaster():GetTeamNumber(), current_loc, current_radius, 0.1, false)
		
		current_radius = current_radius + blast_speed * tick_interval
		current_loc = self:GetCaster():GetAbsOrigin()

		local nearby_enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), current_loc, nil, current_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(nearby_enemies) do
			local enemy_has_been_hit = false
			for _,enemy_hit in pairs(targets_hit) do
				if enemy == enemy_hit then enemy_has_been_hit = true end
			end
			if not enemy_has_been_hit then
				local hit_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
				ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
				ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(hit_pfx)

				ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
				enemy:AddNewModifier(caster, ability, "modifier_shivas_shield_blast_slow", {duration = blast_slow_duration * (1 - enemy:GetStatusResistance())})
				targets_hit[#targets_hit + 1] = enemy
			end
		end
		if current_radius < blast_radius then
			return tick_interval
		end
	end)
end

-----------------------------
-- Shiva's Shield Modifier --
-----------------------------
if modifier_shiva_shield == nil then modifier_shiva_shield = class({}) end
function modifier_shiva_shield:IsHidden() return true end
function modifier_shiva_shield:IsPurgable() return false end
function modifier_shiva_shield:RemoveOnDeath() return false end
function modifier_shiva_shield:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_shiva_shield:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shiva_shield_debuff", {})
	end
end
function modifier_shiva_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_EVENT_ON_ATTACKED}
end
function modifier_shiva_shield:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_shiva_shield:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_shiva_shield:OnAttacked(params)
	if IsServer() then
		local target = params.target
		local attacker = params.attacker
		local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
		if target == self:GetParent() and target ~= self:GetParent():GetTeamNumber() then
			if attacker ~= nil then
				attacker:EmitSound("Hero_Lich.FrostArmorDamage")
				attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shiva_shield_slow", {duration = slow_duration * (1 - attacker:GetStatusResistance())})
			end
		end
	end
end
function modifier_shiva_shield:OnDestroy()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_shiva_shield_debuff") then
			self:GetCaster():RemoveModifierByName("modifier_shiva_shield_debuff")
		end
	end
end

function modifier_shiva_shield:IsAura() return true end
function modifier_shiva_shield:IsAuraActiveOnDeath() return false end
function modifier_shiva_shield:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_shiva_shield:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_shiva_shield:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_shiva_shield:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_shiva_shield:GetModifierAura() return "modifier_shiva_frost_goddess_breath" end

-----------------------------------------
-- Shiva's Shield Slow Aura (Modifier) --
-----------------------------------------
modifier_shiva_shield_debuff = class({})
function modifier_shiva_shield_debuff:IsHidden() return true end
function modifier_shiva_shield_debuff:IsPurgable() return false end
function modifier_shiva_shield_debuff:RemoveOnDeath() return false end
function modifier_shiva_shield_debuff:IsAura() return true end
function modifier_shiva_shield_debuff:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_shiva_shield_debuff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_shiva_shield_debuff:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function modifier_shiva_shield_debuff:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function modifier_shiva_shield_debuff:GetModifierAura() return "modifier_shiva_shield_debuff_aura" end

----------------------------------------
-- Shiva's Shield Passive Aura Debuff --
----------------------------------------
modifier_shiva_shield_debuff_aura = class({})
function modifier_shiva_shield_debuff_aura:IsHidden() return false end
function modifier_shiva_shield_debuff_aura:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end
function modifier_shiva_shield_debuff_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE}
end
function modifier_shiva_shield_debuff_aura:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("slow_attack_speed_aura") * (-1) end
end
function modifier_shiva_shield_debuff_aura:GetModifierHPRegenAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("heal_red_aura") * (-1) end
end

------------------------------------
-- Shiva's Shield Attacker Debuff --
------------------------------------
modifier_shiva_shield_slow = class({})
function modifier_shiva_shield_slow:IsHidden() return false end
function modifier_shiva_shield_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_shiva_shield_slow:StatusEffectPriority() return 10 end
function modifier_shiva_shield_slow:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end
function modifier_shiva_shield_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_shiva_shield_slow:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attacker_slow_as") * (-1) end
end
function modifier_shiva_shield_slow:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attacker_slow_ms") * (-1) end
end

-------------------------------
-- Shiva's Shield Blast Slow --
-------------------------------
modifier_shivas_shield_blast_slow = class({})
function modifier_shivas_shield_blast_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_shivas_shield_blast_slow:StatusEffectPriority() return 10 end
function modifier_shivas_shield_blast_slow:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end
function modifier_shivas_shield_blast_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_shivas_shield_blast_slow:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("blast_movement_speed_debuff") * (-1) end
end

---------------------------------------------------
-- modifier_shiva_frost_goddess_breath --
---------------------------------------------------
modifier_shiva_frost_goddess_breath = modifier_shiva_frost_goddess_breath or class({})
function modifier_shiva_frost_goddess_breath:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_shiva_frost_goddess_breath:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_shiva_frost_goddess_breath:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_aura") end
end
function modifier_shiva_frost_goddess_breath:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor_aura") end
end
