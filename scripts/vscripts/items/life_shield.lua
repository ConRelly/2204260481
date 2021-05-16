-----------------
-- LIFE SHIELD --
-----------------
LinkLuaModifier("modifier_life_shield_1", "items/life_shield.lua", LUA_MODIFIER_MOTION_NONE)
if item_life_shield == nil then item_life_shield = class({}) end
function item_life_shield:GetIntrinsicModifierName() return "modifier_life_shield_1" end

if modifier_life_shield_1 == nil then modifier_life_shield_1 = class({}) end
function modifier_life_shield_1:IsHidden() return true end
function modifier_life_shield_1:IsPurgable() return false end
function modifier_life_shield_1:RemoveOnDeath() return false end
function modifier_life_shield_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_life_shield_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_life_shield_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK}
end
function modifier_life_shield_1:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_life_shield_1:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_life_shield_1:GetModifierPhysical_ConstantBlock()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("block") end
end

-------------------
-- LIFE SHIELD 2 --
-------------------
LinkLuaModifier("modifier_life_shield_2", "items/life_shield.lua", LUA_MODIFIER_MOTION_NONE)
if item_life_shield_2 == nil then item_life_shield_2 = class({}) end
function item_life_shield_2:GetIntrinsicModifierName() return "modifier_life_shield_2" end

if modifier_life_shield_2 == nil then modifier_life_shield_2 = class({}) end
function modifier_life_shield_2:IsHidden() return true end
function modifier_life_shield_2:IsPurgable() return false end
function modifier_life_shield_2:RemoveOnDeath() return false end
function modifier_life_shield_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_life_shield_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_life_shield_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK}
end
function modifier_life_shield_2:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_life_shield_2:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_life_shield_2:GetModifierPhysical_ConstantBlock()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("block") end
end

-------------------
-- LIFE SHIELD 3 --
-------------------
LinkLuaModifier("modifier_life_shield_3", "items/life_shield.lua", LUA_MODIFIER_MOTION_NONE)
if item_life_shield_3 == nil then item_life_shield_3 = class({}) end
function item_life_shield_3:GetIntrinsicModifierName() return "modifier_life_shield_3" end

if modifier_life_shield_3 == nil then modifier_life_shield_3 = class({}) end
function modifier_life_shield_3:IsHidden() return true end
function modifier_life_shield_3:IsPurgable() return false end
function modifier_life_shield_3:RemoveOnDeath() return false end
function modifier_life_shield_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_life_shield_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_life_shield_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK}
end
function modifier_life_shield_3:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_life_shield_3:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_life_shield_3:GetModifierPhysical_ConstantBlock()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("block") end
end


------------------------
-- AVERNUS CHESTPLATE --
------------------------
item_avernus_chestplate = class({})
LinkLuaModifier("modifier_avernus_chestplate", "items/life_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_avernus_chestplate_buff_caster", "items/life_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_avernus_chestplate_buff_ally", "items/life_shield.lua", LUA_MODIFIER_MOTION_NONE)
function item_avernus_chestplate:GetIntrinsicModifierName() return "modifier_avernus_chestplate" end
function item_avernus_chestplate:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local buff_duration = self:GetSpecialValueFor("duration")
		caster:EmitSound("Hero_Abaddon.BorrowedTime")
		caster:AddNewModifier(caster, self, "modifier_avernus_chestplate_buff_caster", {duration = buff_duration})
	end
end
modifier_avernus_chestplate = class({})
function modifier_avernus_chestplate:IsHidden() return true end
function modifier_avernus_chestplate:IsPurgable() return false end
function modifier_avernus_chestplate:IsDebuff() return false end
function modifier_avernus_chestplate:RemoveOnDeath() return false end
function modifier_avernus_chestplate:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_avernus_chestplate:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK}
end
function modifier_avernus_chestplate:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("hp") end
function modifier_avernus_chestplate:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_avernus_chestplate:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
function modifier_avernus_chestplate:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("all_stats") end
function modifier_avernus_chestplate:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("all_stats") end
function modifier_avernus_chestplate:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("all_stats") end
function modifier_avernus_chestplate:GetModifierPhysical_ConstantBlock() return self:GetAbility():GetSpecialValueFor("block") end
modifier_avernus_chestplate_buff_caster = modifier_avernus_chestplate_buff_caster or class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	IsDebuff = function(self) return false end,
	IsAura = function(self) return true end,
	IsAuraActiveOnDeath = function(self) return false end,
	GetModifierAura = function(self) return "modifier_avernus_chestplate_buff_ally" end,
	GetAuraDuration = function(self) return FrameTime() end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_HERO end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetEffectName = function(self) return "particles/custom/items/avernus_chestplate/avernus_chestplate_act.vpcf" end,
	GetEffectAttachType = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
	GetStatusEffectName = function(self) return "particles/custom/items/avernus_chestplate/status_effect_avernus_chestplate_act.vpcf" end,
	StatusEffectPriority = function(self) return 15 end,
})
function modifier_avernus_chestplate_buff_caster:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("redirect_range") end
function modifier_avernus_chestplate_buff_caster:GetAuraEntityReject(hEntity)
	if hEntity == self:GetParent() or hEntity:HasModifier("modifier_avernus_chestplate_buff_caster") then return true end
	return false
end
function modifier_avernus_chestplate_buff_caster:OnCreated()
	if IsServer() then
		local target = self:GetParent()
		target._avernus_buffed_allies = {}
		if RollPercentage(15) then target:EmitSound("Hero_Abaddon.Curse.Proc") end
		target:EmitSound("Hero_Abaddon.BorrowedTime")
		target:Purge(false, true, false, false, false) --(RemovePositiveBuffs, RemoveDebuffs, false, RemoveStuns, false)
	end
end
modifier_avernus_chestplate_buff_ally = modifier_avernus_chestplate_buff_ally or class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	IsDebuff = function(self) return false end,
})
function modifier_avernus_chestplate_buff_ally:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_avernus_chestplate_buff_ally:OnCreated()
	self.parent = self:GetParent()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local buff_list = caster._avernus_buffed_allies
		if buff_list then buff_list[target] = true end
		local target_origin = target:GetAbsOrigin()
		local particle_name = "particles/custom/items/avernus_chestplate/avernus_chestplate_act_ally.vpcf"
		particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_origin, true)
		self:AddParticle(particle, false, false, -1, false, false)
		particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_attack1", target_origin, true)
		self:AddParticle(particle, false, false, -1, false, false)
	end
end
function modifier_avernus_chestplate_buff_ally:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local buff_list = caster._avernus_buffed_allies
		if buff_list then buff_list[self:GetParent()] = nil end
	end
end
function modifier_avernus_chestplate_buff_ally:GetModifierIncomingDamage_Percentage(kv)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local attacker = kv.attacker
		local redirect_pct = (self:GetAbility():GetSpecialValueFor("redirect"))
		local redirect_damage = kv.damage * (redirect_pct/100)
		ApplyDamage({victim = caster, attacker = attacker, damage = redirect_damage, damage_type = DAMAGE_TYPE_PURE})
		particle_hit_fx = ParticleManager:CreateParticle("particles/custom/items/avernus_chestplate/avernus_chestplate_act_hit_parent.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle_hit_fx)
		return -(redirect_pct)
	end
end
