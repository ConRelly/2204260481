-------------
--ICE SWORD--
-------------
LinkLuaModifier("modifier_ice_sword_1", "items/ice_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_ice_sword == nil then item_ice_sword = class({}) end
function item_ice_sword:GetIntrinsicModifierName() return "modifier_ice_sword_1" end
function item_ice_sword:OnSpellStart()
	self.target = self:GetCursorTarget()
	self.caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	self.target:EmitSound("Hero_Ancient_Apparition.IceBlast.Target")
	ApplyDamage({victim = self.target, attacker = self.caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL,})
	local blast_fx = ParticleManager:CreateParticle("particles/custom/items/ice_sword/blast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(blast_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(blast_fx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(blast_fx)
end

if modifier_ice_sword_1 == nil then modifier_ice_sword_1 = class({}) end
function modifier_ice_sword_1:IsHidden() return true end
function modifier_ice_sword_1:IsPurgable() return false end
function modifier_ice_sword_1:RemoveOnDeath() return false end
function modifier_ice_sword_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_sword_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_sword_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_ice_sword_1:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_ice_sword_1:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_ice_sword_1:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end

--------------
--ICE SWORD2--
--------------
LinkLuaModifier("modifier_ice_sword_2", "items/ice_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_ice_sword_2 == nil then item_ice_sword_2 = class({}) end
function item_ice_sword_2:GetIntrinsicModifierName() return "modifier_ice_sword_2" end
function item_ice_sword_2:OnSpellStart()
	self.target = self:GetCursorTarget()
	self.caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	self.target:EmitSound("Hero_Ancient_Apparition.IceBlast.Target")
	ApplyDamage({victim = self.target, attacker = self.caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL,})
	local blast_fx = ParticleManager:CreateParticle("particles/custom/items/ice_sword/blast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(blast_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(blast_fx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(blast_fx)
end

if modifier_ice_sword_2 == nil then modifier_ice_sword_2 = class({}) end
function modifier_ice_sword_2:IsHidden() return true end
function modifier_ice_sword_2:IsPurgable() return false end
function modifier_ice_sword_2:RemoveOnDeath() return false end
function modifier_ice_sword_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_sword_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_sword_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_ice_sword_2:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_ice_sword_2:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_ice_sword_2:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end

--------------
--ICE SWORD3--
--------------
LinkLuaModifier("modifier_ice_sword_3", "items/ice_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_ice_sword_3 == nil then item_ice_sword_3 = class({}) end
function item_ice_sword_3:GetIntrinsicModifierName() return "modifier_ice_sword_3" end
function item_ice_sword_3:OnSpellStart()
	self.target = self:GetCursorTarget()
	self.caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	self.target:EmitSound("Hero_Ancient_Apparition.IceBlast.Target")
	ApplyDamage({victim = self.target, attacker = self.caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL,})
	local blast_fx = ParticleManager:CreateParticle("particles/custom/items/ice_sword/blast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(blast_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(blast_fx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(blast_fx)
end

if modifier_ice_sword_3 == nil then modifier_ice_sword_3 = class({}) end
function modifier_ice_sword_3:IsHidden() return true end
function modifier_ice_sword_3:IsPurgable() return false end
function modifier_ice_sword_3:RemoveOnDeath() return false end
function modifier_ice_sword_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_sword_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_sword_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_ice_sword_3:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_ice_sword_3:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_ice_sword_3:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end


-------------
--ICE DAGON--
-------------
LinkLuaModifier("modifier_ice_dagon", "items/ice_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_ice_dagon == nil then item_ice_dagon = class({}) end
function item_ice_dagon:GetIntrinsicModifierName() return "modifier_ice_dagon" end
function item_ice_dagon:OnSpellStart()
	self.target = self:GetCursorTarget()
	self.caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	ApplyDamage({victim = self.target, attacker = self.caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL,})
	local blast_fx = ParticleManager:CreateParticle("particles/custom/items/ice_sword/dagon_blast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(blast_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(blast_fx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(blast_fx, 2, Vector(600))
	self.caster:EmitSound("DOTA_Item.Dagon.Activate")
	self.target:EmitSound("DOTA_Item.Dagon5.Target")
	ParticleManager:ReleaseParticleIndex(blast_fx)
end

if modifier_ice_dagon == nil then modifier_ice_dagon = class({}) end
function modifier_ice_dagon:IsHidden() return true end
function modifier_ice_dagon:IsPurgable() return false end
function modifier_ice_dagon:RemoveOnDeath() return false end
function modifier_ice_dagon:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_dagon:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_ice_dagon:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_ice_dagon:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end
end
function modifier_ice_dagon:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_ice_dagon:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_ice_dagon:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_ice_dagon:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_ice_dagon:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_stats") end
end
function modifier_ice_dagon:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end

