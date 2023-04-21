-----------------
-- Angel Armor --
-----------------
item_angel_armor = class({})
LinkLuaModifier("modifier_angel_armor", "items/angel_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_angel_armor_buff_caster", "items/angel_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_angel_armor_buff_ally", "items/angel_armor.lua", LUA_MODIFIER_MOTION_NONE)
function item_angel_armor:GetIntrinsicModifierName() return "modifier_angel_armor" end
function item_angel_armor:OnOwnerSpawned() if self.toggle_state then self:ToggleAbility() end end
function item_angel_armor:OnOwnerDied() self.toggle_state = self:GetToggleState() end
function item_angel_armor:OnToggle()
	if not IsServer() then return end
	if self:GetToggleState() then
		Timers:CreateTimer(1, function()
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_angel_armor_buff_caster", {})
		end)
	else
		self:GetCaster():RemoveModifierByNameAndCaster("modifier_angel_armor_buff_caster", self:GetCaster())
	end
end

modifier_angel_armor = class({})
function modifier_angel_armor:IsHidden() return true end
function modifier_angel_armor:IsPurgable() return false end
function modifier_angel_armor:IsDebuff() return false end
function modifier_angel_armor:RemoveOnDeath() return false end
function modifier_angel_armor:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_angel_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_angel_armor:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("hp") end
function modifier_angel_armor:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_angel_armor:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
function modifier_angel_armor:GetModifierTotal_ConstantBlock()
	if self:GetParent():IsRangedAttacker() then
		return self:GetAbility():GetSpecialValueFor("block_ranged")
	else
		return self:GetAbility():GetSpecialValueFor("block_melee")
	end
end
function modifier_angel_armor:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("attack_speed_aura") end
modifier_angel_armor_buff_caster = modifier_angel_armor_buff_caster or class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	IsDebuff = function(self) return false end,
	IsAura = function(self) return true end,
	IsAuraActiveOnDeath = function(self) return false end,
	GetModifierAura = function(self) return "modifier_angel_armor_buff_ally" end,
	GetAuraDuration = function(self) return FrameTime() end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_HERO end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetEffectName = function(self) return "particles/custom/items/avernus_chestplate/avernus_chestplate_act.vpcf" end,
	GetEffectAttachType = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
	GetStatusEffectName = function(self) return "particles/custom/items/avernus_chestplate/status_effect_avernus_chestplate_act.vpcf" end,
	StatusEffectPriority = function(self) return 15 end,
})
function modifier_angel_armor_buff_caster:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_angel_armor_buff_caster:GetAuraEntityReject(hEntity)
	if hEntity == self:GetParent() or hEntity:HasModifier("modifier_angel_armor_buff_caster") then return true end
	return false
end
function modifier_angel_armor_buff_caster:OnCreated()
	if IsServer() then
		local target = self:GetParent()
		target._angel_buffed_allies = {}
		if RollPercentage(15) then target:EmitSound("Hero_Abaddon.Curse.Proc") end
		target:EmitSound("Hero_Abaddon.BorrowedTime")
		target:Purge(false, true, false, false, false) --(RemovePositiveBuffs, RemoveDebuffs, false, RemoveStuns, false)
	end
end
function modifier_angel_armor_buff_caster:DeclareFunctions() return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK} end
function modifier_angel_armor_buff_caster:GetModifierTotal_ConstantBlock()
	if self:GetParent():IsRangedAttacker() then
		return self:GetAbility():GetSpecialValueFor("block_ranged")
	else
		return self:GetAbility():GetSpecialValueFor("block_melee")
	end
end
modifier_angel_armor_buff_ally = modifier_angel_armor_buff_ally or class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	IsDebuff = function(self) return false end,
})
function modifier_angel_armor_buff_ally:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_angel_armor_buff_ally:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local buff_list = caster._angel_buffed_allies
		if buff_list then buff_list[target] = true end
		local target_origin = target:GetAbsOrigin()
		local particle_name = "particles/custom/items/avernus_chestplate/avernus_chestplate_act_ally.vpcf"
		particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_origin, true)
		self:AddParticle(particle, false, false, -1, false, false)
		particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_attack1", target_origin, true)
		self:AddParticle(particle, false, false, -1, false, false)
		self:StartIntervalThink(0.4)
	end
end
function modifier_angel_armor_buff_ally:OnIntervalThink()
	if not IsServer() then return end
		particle_hit_fx = ParticleManager:CreateParticle("particles/custom/items/angel_armor/angel_armor_tether.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle_hit_fx)
end
function modifier_angel_armor_buff_ally:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local buff_list = caster._angel_buffed_allies
		if buff_list then buff_list[self:GetParent()] = nil end
	end
end
function modifier_angel_armor_buff_ally:GetModifierPhysicalArmorBonus()
	return self:GetCaster():GetPhysicalArmorValue(false)*(self:GetAbility():GetSpecialValueFor("armor_pct")/100)
end
function modifier_angel_armor_buff_ally:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("attack_speed_aura") end
--[[
function modifier_angel_armor_buff_ally:GetModifierIncomingDamage_Percentage(kv)
	if IsServer() then
		local attacker = kv.attacker
		local armor_pct = self:GetAbility():GetSpecialValueFor("armor_pct")
		local allydamage = kv.damage * (armor_pct/100)
		ApplyDamage({victim = self:GetCaster(), attacker = attacker, damage = allydamage, damage_type = DAMAGE_TYPE_PURE})
		particle_hit_fx = ParticleManager:CreateParticle("particles/custom/items/avernus_chestplate/avernus_chestplate_act_hit_parent.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle_hit_fx)
		return 0
	end
end
function modifier_angel_armor_buff_ally:GetModifierMagicalResistanceBonus()
	return self:GetCaster():Script_GetMagicalArmorValue(false, self:GetCaster())*25
end
]]
