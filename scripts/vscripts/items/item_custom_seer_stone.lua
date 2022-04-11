LinkLuaModifier("modifier_item_custom_seer_stone", "items/item_custom_seer_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_custom_seer_stone_buff", "items/item_custom_seer_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_custom_seer_stone_true_sight", "items/item_custom_seer_stone.lua", LUA_MODIFIER_MOTION_NONE)


item_custom_seer_stone = class({})
function item_custom_seer_stone:GetAOERadius() return self:GetSpecialValueFor("radius") end
function item_custom_seer_stone:GetIntrinsicModifierName() return "modifier_item_custom_seer_stone" end
function item_custom_seer_stone:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Item.SeerStone", caster)

	local seer_stone_pfx = ParticleManager:CreateParticle("particles/items4_fx/seer_stone.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(seer_stone_pfx, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(seer_stone_pfx, 1, Vector(duration * 1.1, radius, 0))
	ParticleManager:ReleaseParticleIndex(seer_stone_pfx)

	local true_sight = CreateUnitByName("npc_dota_invisible_vision_source", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
	true_sight:AddNewModifier(caster, self, "modifier_phased", {})
	true_sight:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
	true_sight:AddNewModifier(caster, self, "modifier_item_gem_of_true_sight", {duration = duration})
	true_sight:AddNewModifier(caster, self, "modifier_item_custom_seer_stone_true_sight", {duration = duration})

	AddFOWViewer(caster:GetTeamNumber(), self:GetCursorPosition(), radius, duration, false)
end


modifier_item_custom_seer_stone = class({})
function modifier_item_custom_seer_stone:IsHidden() return true end
function modifier_item_custom_seer_stone:IsPurgable() return false end
function modifier_item_custom_seer_stone:RemoveOnDeath() return false end
function modifier_item_custom_seer_stone:OnCreated()
	if not IsServer() then return end
	self:GetParent():RemoveModifierByName("modifier_item_custom_seer_stone_buff")
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_custom_seer_stone_buff", {})
end
function modifier_item_custom_seer_stone:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveModifierByName("modifier_item_custom_seer_stone_buff")
end


modifier_item_custom_seer_stone_buff = class({})
function modifier_item_custom_seer_stone_buff:IsHidden() return true end
function modifier_item_custom_seer_stone_buff:IsPurgable() return false end
function modifier_item_custom_seer_stone_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_custom_seer_stone_buff:RemoveOnDeath() return false end
function modifier_item_custom_seer_stone_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
	}
end
function modifier_item_custom_seer_stone_buff:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
function modifier_item_custom_seer_stone_buff:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_bonus")
end
function modifier_item_custom_seer_stone_buff:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_bonus")
end
function modifier_item_custom_seer_stone_buff:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end
function modifier_item_custom_seer_stone_buff:GetModifierCastRangeBonusStacking()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end


modifier_item_custom_seer_stone_true_sight = class({})
function modifier_item_custom_seer_stone_true_sight:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
end

