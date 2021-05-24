----------------------
-- Arcane Supremacy --
----------------------

LinkLuaModifier("modifier_arcane_supremacy", "heroes/hero_rubick/arcane_supremacy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arcane_supremacy_buff", "heroes/hero_rubick/arcane_supremacy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_super_scepter", "items/item_aghanim_synth", LUA_MODIFIER_MOTION_NONE)

arcane_supremacy = class({})
modifier_arcane_supremacy = class({})
function arcane_supremacy:GetIntrinsicModifierName() return "modifier_arcane_supremacy" end
function arcane_supremacy:OnSpellStart()
	 if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
		if caster == target then self:StartCooldown(10) return end
		if not target:IsRealHero() then self:StartCooldown(10) return end
		if not caster:HasShard() and not caster:HasScepter() and not HasSuperScepter(caster) then self:StartCooldown(10) return end
		local duration = self:GetSpecialValueFor("buff_duration")
		local base_cd = self:GetSpecialValueFor("base_cd")
		local cd_shard = 0
		local cd_scepter = 0
		local cd_super = 0
		if caster:HasShard() then
			cd_shard = self:GetSpecialValueFor("bonus_cd_shard")
			target:AddNewModifier(caster, nil, "modifier_item_aghanims_shard", {duration = duration})
		end
		if caster:HasScepter() then
			cd_scepter = self:GetSpecialValueFor("bonus_cd_scepter")
			target:AddNewModifier(caster, self, "modifier_item_ultimate_scepter_consumed", {duration = duration})
		end
		if HasSuperScepter(caster) then
			cd_super = self:GetSpecialValueFor("bonus_cd_super")
			target:AddNewModifier(caster, self, "modifier_super_scepter", {duration = duration})
		end
		cd = base_cd + cd_shard + cd_scepter + cd_super
		self:StartCooldown(cd)
		target:AddNewModifier(caster, self, "modifier_arcane_supremacy_buff", {duration = duration})
 	end
end

-------------------------------
-- Arcane Supremacy Modifier --
-------------------------------
function modifier_arcane_supremacy:IsHidden() return true end
function modifier_arcane_supremacy:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_arcane_supremacy:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_cast_range") end
end
function modifier_arcane_supremacy:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_amp") end
end

---------------------------
-- Arcane Supremacy Buff --
---------------------------
modifier_arcane_supremacy_buff = modifier_arcane_supremacy_buff or class({})
function modifier_arcane_supremacy_buff:IsDebuff() return false end
function modifier_arcane_supremacy_buff:IsHidden() return false end
function modifier_arcane_supremacy_buff:IsPurgable() return false end
--function modifier_arcane_supremacy_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
