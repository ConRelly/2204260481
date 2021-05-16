-----------------
--RING OF WATER--
-----------------
LinkLuaModifier("modifier_ring_of_water_1", "items/ring_of_water.lua", LUA_MODIFIER_MOTION_NONE)
if item_ring_of_water == nil then item_ring_of_water = class({}) end
function item_ring_of_water:GetIntrinsicModifierName() return "modifier_ring_of_water_1" end

if modifier_ring_of_water_1 == nil then modifier_ring_of_water_1 = class({}) end
function modifier_ring_of_water_1:IsHidden() return true end
function modifier_ring_of_water_1:IsPurgable() return false end
function modifier_ring_of_water_1:RemoveOnDeath() return false end
function modifier_ring_of_water_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ring_of_water_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ring_of_water_1:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT }
end
function modifier_ring_of_water_1:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_ring_of_water_1:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_ring_of_water_1:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agil") end
end
function modifier_ring_of_water_1:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion") end
end

------------------
--RING OF WATER2--
------------------
LinkLuaModifier("modifier_ring_of_water_2", "items/ring_of_water.lua", LUA_MODIFIER_MOTION_NONE)
if item_ring_of_water_2 == nil then item_ring_of_water_2 = class({}) end
function item_ring_of_water_2:GetIntrinsicModifierName() return "modifier_ring_of_water_2" end

if modifier_ring_of_water_2 == nil then modifier_ring_of_water_2 = class({}) end
function modifier_ring_of_water_2:IsHidden() return true end
function modifier_ring_of_water_2:IsPurgable() return false end
function modifier_ring_of_water_2:RemoveOnDeath() return false end
function modifier_ring_of_water_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ring_of_water_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ring_of_water_2:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT }
end
function modifier_ring_of_water_2:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_ring_of_water_2:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_ring_of_water_2:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agil") end
end
function modifier_ring_of_water_2:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion") end
end

------------------
--RING OF WATER3--
------------------
LinkLuaModifier("modifier_ring_of_water_3", "items/ring_of_water.lua", LUA_MODIFIER_MOTION_NONE)
if item_ring_of_water_3 == nil then item_ring_of_water_3 = class({}) end
function item_ring_of_water_3:GetIntrinsicModifierName() return "modifier_ring_of_water_3" end

if modifier_ring_of_water_3 == nil then modifier_ring_of_water_3 = class({}) end
function modifier_ring_of_water_3:IsHidden() return true end
function modifier_ring_of_water_3:IsPurgable() return false end
function modifier_ring_of_water_3:RemoveOnDeath() return false end
function modifier_ring_of_water_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ring_of_water_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ring_of_water_3:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT }
end
function modifier_ring_of_water_3:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_ring_of_water_3:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_ring_of_water_3:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agil") end
end
function modifier_ring_of_water_3:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion") end
end


-------------------
--WATER BUTTERFLY--
-------------------
LinkLuaModifier("modifier_water_butterfly", "items/ring_of_water.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_water_butterfly_boost", "items/ring_of_water.lua", LUA_MODIFIER_MOTION_NONE)
if item_water_butterfly == nil then item_water_butterfly = class({}) end
function item_water_butterfly:GetIntrinsicModifierName() return "modifier_water_butterfly" end
function item_water_butterfly:OnSpellStart()
	local caster = self:GetCaster()
	local allies = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_ANY_ORDER,
		false)
	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_water_butterfly_boost", {duration = self:GetSpecialValueFor("duration")})
	end
end

if modifier_water_butterfly == nil then modifier_water_butterfly = class({}) end
function modifier_water_butterfly:IsHidden() return true end
function modifier_water_butterfly:IsPurgable() return false end
function modifier_water_butterfly:RemoveOnDeath() return false end
function modifier_water_butterfly:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_water_butterfly:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_butterfly:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_water_butterfly:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_water_butterfly:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_water_butterfly:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agil") end
end
function modifier_water_butterfly:GetModifierEvasion_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("evasion") end
end
function modifier_water_butterfly:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end

-------------------------
--WATER BUTTERFLY BOOST--
-------------------------
if modifier_water_butterfly_boost == nil then modifier_water_butterfly_boost = class({}) end
function modifier_water_butterfly_boost:IsHidden() return false end
function modifier_water_butterfly_boost:IsDebuff() return false end
function modifier_water_butterfly_boost:IsPurgable() return false end
function modifier_water_butterfly_boost:GetEffectName() return "particles/econ/events/ti7/phase_boots_ti7.vpcf" end
function modifier_water_butterfly_boost:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_water_butterfly_boost:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_butterfly_boost:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN }
end
function modifier_water_butterfly_boost:CheckState()
	return { [MODIFIER_STATE_NO_UNIT_COLLISION] = true }
end
function modifier_water_butterfly_boost:GetModifierMoveSpeedOverride()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("boost_ms") end
end
function modifier_water_butterfly_boost:GetModifierMoveSpeed_AbsoluteMin()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("boost_min_ms") end
end