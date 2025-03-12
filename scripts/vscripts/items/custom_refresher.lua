require("lib/my")
require("lib/refresh")

LinkLuaModifier("modifier_item_custom_refresher", "items/custom_refresher.lua", LUA_MODIFIER_MOTION_NONE)

item_custom_refresher = class({})

item_custom_refresher.nonrefresh_abilities = {
	terrorblade_custom_dark_realm = true,
	undying_tombstone = true,
	doom_devour_lua = true,
	necrolyte_custom_reapers_scythe = true,
	ancient_apparition_ice_blast = true,
	treant_custom_ultimate_sacrifice = true,
	obsidian_destroyer_custom_mana_amp = true,
	obs_replay = true,
	arcane_supremacy = true,
	muerta_pierce_the_veil = true,
}

item_custom_refresher.nonrefresh_items = {
	item_maiar_pendant = true,
	item_custom_fusion_rune = true,
	item_conduit = true,
	item_custom_refresher = true,
	item_plain_ring = true,
	item_helm_of_the_undying = true, 
	item_echo_wand = true,
	item_custom_ex_machina = true,
	item_minotaur_horn = true,
	item_bloodthorn = true,
	item_cursed_bloodthorn = true,
	item_resurection_pendant = true,
	item_random_get_ability_spell = true,
	item_random_get_ability = true,
	item_random_get_ability3 = true,
	item_inf_aegis = true,
	item_video_file = true,
	item_master_of_weapons_sword = true,
	item_master_of_weapons_sword2 = true,
	item_master_of_weapons_sword3 = true,
	item_master_of_weapons_sword4 = true,
	item_master_of_weapons_sword5 = true,
	item_spellbook_destruction = true,	
}

function item_custom_refresher:OnSpellStart()
    local caster = self:GetCaster()
	local ultimate_percentage = self:GetSpecialValueFor("ultimate_percentage")
	local cooldown = self:GetSpecialValueFor("cooldown")
    if not caster:IsTempestDouble() then
        caster:EmitSound("DOTA_Item.Refresher.Activate")
        local fx = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(fx)
		self:StartCooldown(cooldown)
        refresh_abilities_mult(caster, self.nonrefresh_abilities, ultimate_percentage * 0.01)
        refresh_items(caster, self.nonrefresh_items)
    end
end

function item_custom_refresher:GetIntrinsicModifierName() return "modifier_item_custom_refresher" end


modifier_item_custom_refresher = class({})
function modifier_item_custom_refresher:IsHidden() return true end
function modifier_item_custom_refresher:IsPurgable() return false end
function modifier_item_custom_refresher:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_custom_refresher:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_item_custom_refresher:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
end
function modifier_item_custom_refresher:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
end
