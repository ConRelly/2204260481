require("lib/my")
require("lib/popup")

item_arcane_staff = class({})
function item_arcane_staff:GetIntrinsicModifierName() return "modifier_item_arcane_staff" end

LinkLuaModifier("modifier_item_arcane_staff", "items/arcane_staff.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_arcane_staff = class({})
function modifier_item_arcane_staff:IsHidden() return false end
function modifier_item_arcane_staff:IsPurgable() return false end
function modifier_item_arcane_staff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_arcane_staff:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_item_arcane_staff:IsDebuff() return false end	
function modifier_item_arcane_staff:GetTexture() return "arcane_staff" end	
function modifier_item_arcane_staff:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
if IsServer() then
	function modifier_item_arcane_staff:OnCreated()
		local parent = self:GetParent()
		if parent:IsRealHero() and not parent:IsTempestDouble() then
			local PlayerID = parent:GetPlayerID()
			_G.AOHGameMode.SetArcane(PlayerID, true)
		end
	end 
	function modifier_item_arcane_staff:OnDestroy()
		local parent = self:GetParent()
		if parent:IsRealHero() and not parent:IsTempestDouble() then
			local PlayerID = parent:GetPlayerID()
			_G.AOHGameMode.SetArcane(PlayerID, false)
		end
	end 
end
function modifier_item_arcane_staff:GetModifierPreAttack_BonusDamage() return 60 end
function modifier_item_arcane_staff:GetModifierBonusStats_Intellect() return 80 end


-- this will run multiple times every second, keep it optimized.
function arcane_staff_calculate_crit(attacker, victim, damageTable)
	if attacker and attacker:IsHero() then
		local mana = attacker:GetMana()
		local max_mana = attacker:GetMaxMana()
		local mana_req = 150
		local damage_mult = 1.8
		local pass = true
		local mana_cost = damageTable.damage * (190 / (190 + attacker:GetIntellect()))	
		--if attacker:HasModifier("modifier_broken_wings_divinity") then mana_cost = 0 mana_req = 0 end
		if attacker:HasModifier("modifier_spellbook_destruction_mana_drain") then
			mana = max_mana
			pass = false
		end
		if mana >= mana_cost and mana >= mana_req then
			if victim and victim ~= attacker and victim:GetTeamNumber() ~= attacker:GetTeamNumber() then
				damageTable.damage = damageTable.damage * damage_mult
				create_popup({
					target = victim,
					value = damageTable.damage,
					color = Vector(100, 149, 237),
					type = "crit",
					pos = 4
				})
				if pass then
					attacker:SpendMana(mana_cost, nil)
				end
			end
		end
	end
    return damageTable
end