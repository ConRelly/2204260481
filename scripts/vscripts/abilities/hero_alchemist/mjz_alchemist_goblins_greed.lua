LinkLuaModifier("modifier_mjz_alchemist_goblins_greed", "abilities/hero_alchemist/mjz_alchemist_goblins_greed.lua", LUA_MODIFIER_MOTION_NONE)


mjz_alchemist_goblins_greed = class({})
function mjz_alchemist_goblins_greed:GetIntrinsicModifierName() return "modifier_mjz_alchemist_goblins_greed" end

modifier_mjz_alchemist_goblins_greed = class({})
function modifier_mjz_alchemist_goblins_greed:IsHidden() return true end
function modifier_mjz_alchemist_goblins_greed:IsPurgable() return false end
function modifier_mjz_alchemist_goblins_greed:AllowIllusionDuplicate() return false end

function modifier_mjz_alchemist_goblins_greed:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		if self:GetParent():IsRealHero() then
			local flInterval = self:GetAbility():GetSpecialValueFor("interval")
			self:StartIntervalThink(flInterval)
		end
	end
end
function modifier_mjz_alchemist_goblins_greed:OnIntervalThink()
	if self:GetParent():PassivesDisabled() then return end
	if self:GetParent():HasModifier("modifier_arc_warden_tempest_double") then return end
	local gold = self:GetAbility():GetSpecialValueFor("gold")
	self:GetParent():ModifyGold(gold, true, 0)
end