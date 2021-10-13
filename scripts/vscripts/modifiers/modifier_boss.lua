resist80 = {
	["npc_boss_shredder"] = true,
}

resist70 = {
	["npc_dota_creature_snowball_tuskar_2"] = true,
	["npc_boss_spectre"] = true,
	["npc_boss_skeleton_king_angry"] = true,
	["npc_boss_skeleton_king_angry_new"] = true,
	["npc_boss_skeleton_king_ultimate"] = true,
	["npc_boss_juggernaut_2"] = true,
	["npc_boss_juggernaut_3"] = true,
	["npc_dota_boss_aghanim"] = true,
}

resist50 = {
	["npc_boss_kobold_foreman2"] = true,
	["npc_boss_spiritbreaker"] = true,
	["npc_boss_demon_marauder"] = true,
	["npc_boss_wisp"] = true,
	["npc_boss_wisp_new"] = true,
	["npc_boss_skeletal_archer_new"] = true,
	["npc_boss_randomstuff_aiolos"] = true,
	["npc_boss_randomstuff_aiolos_demo"] = true,
	["npc_boss_guesstuff_Moran"] = true,
}

resist30 = {
	["npc_boss_techies_direct"] = true,
	["npc_boss_techies_indirect"] = true,
	["npc_boss_skeleton_king"] = true,
	["npc_boss_skeleton_king_new"] = true,
	["npc_dota_creature_siltbreaker"] = true,
}

resist25 = {
	["npc_boss_tiny"] = true,
	["npc_boss_nyx"] = true,
	["npc_boss_antimage"] = true,
}

resist20 = {
	["npc_boss_faceless_void"] = true,
	["npc_boss_treant"] = true,
	["npc_boss_dragon_guard"] = true,
	["npc_boss_lycan"] = true,
	["npc_boss_medusa"] = true,
	["npc_boss_tinker"] = true,
	["npc_boss_nevermore"] = true,
	["npc_boss_ember_spirit"] = true,
	["npc_boss_ember_spirit2"] = true,
	["npc_boss_mirana"] = true,
	["npc_boss_mirana2"] = true,
	["npc_boss_forged_spirit"] = true,
	["npc_boss_crystal_queen"] = true,
}

modifier_boss = class({})
function modifier_boss:IsBuff() return true end
function modifier_boss:IsHidden() return false end
function modifier_boss:GetTexture() return "earth_spirit_rolling_boulder" end
function modifier_boss:IsPurgable() return false end
function modifier_boss:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end
function modifier_boss:GetModifierTotalDamageOutgoing_Percentage() return self:GetStackCount() end
function modifier_boss:GetModifierMoveSpeedBonus_Percentage() return self:GetStackCount() * 0.25 end
function modifier_boss:GetModifierExtraHealthPercentage() return self:GetStackCount() * 0.6 end
function modifier_boss:GetModifierStatusResistanceStacking() return self.status_resist end
function modifier_boss:OnCreated()
	local UnitName = self:GetParent():GetUnitName()
	if resist80[UnitName] then
		self.status_resist = 80
	elseif resist70[UnitName] then
		self.status_resist = 70
	elseif resist50[UnitName] then
		self.status_resist = 50
	elseif resist30[UnitName] then
		self.status_resist = 30
	elseif resist25[UnitName] then
		self.status_resist = 25
	elseif resist20[UnitName] then
		self.status_resist = 20
	else
		self.status_resist = 0
	end
	self:StartIntervalThink(2)
end
function modifier_boss:OnIntervalThink()
	self:IncrementStackCount()
end

