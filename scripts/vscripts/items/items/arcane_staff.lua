require("libraries/popup")
item_arcane_staff = class({})
function item_arcane_staff:GetIntrinsicModifierName() return "modifier_item_arcane_staff" end

LinkLuaModifier("modifier_item_arcane_staff", "items/arcane_staff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_arcane_staff = class({})
function modifier_item_arcane_staff:IsHidden() return false end
function modifier_item_arcane_staff:IsPurgable() return false end
function modifier_item_arcane_staff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_arcane_staff:IsDebuff() return false end
function modifier_item_arcane_staff:GetTexture() return "rapier" end
function modifier_item_arcane_staff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
if IsServer() then
	function modifier_item_arcane_staff:OnCreated()
		local parent = self:GetParent()
		if parent:IsRealHero() and not parent:IsTempestDouble() then
			local PlayerID = parent:GetPlayerID()
			_G.GameMode.SetArcane(PlayerID, true)
		end
	end 
	function modifier_item_arcane_staff:OnDestroy()
		local parent = self:GetParent()
		if parent:IsRealHero() and not parent:IsTempestDouble() then
			local PlayerID = parent:GetPlayerID()
			_G.GameMode.SetArcane(PlayerID, false)
		end
	end
end
function modifier_item_arcane_staff:GetModifierPreAttack_BonusDamage() return 60 end
function modifier_item_arcane_staff:GetModifierBonusStats_Intellect() return 80 end

