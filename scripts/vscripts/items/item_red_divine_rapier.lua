LinkLuaModifier("modifier_item_red_divine_rapier", "items/item_red_divine_rapier.lua", LUA_MODIFIER_MOTION_NONE)


item_red_divine_rapier = class({})
function item_red_divine_rapier:GetIntrinsicModifierName() return "modifier_item_red_divine_rapier" end

item_red_divine_rapier_lv1 = class(item_red_divine_rapier)
item_red_divine_rapier_lv2 = class(item_red_divine_rapier)
item_red_divine_rapier_lv3 = class(item_red_divine_rapier)
item_red_divine_rapier_lv4 = class(item_red_divine_rapier)
item_red_divine_rapier_lv5 = class(item_red_divine_rapier)

modifier_item_red_divine_rapier = class({})

function modifier_item_red_divine_rapier:IsPurgable() return false end
function modifier_item_red_divine_rapier:IsHidden() return true end
function modifier_item_red_divine_rapier:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_item_red_divine_rapier:OnCreated()
end
function modifier_item_red_divine_rapier:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_red_divine_rapier:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() and self:GetParent() then
		if self:GetParent():GetName() ~= "npc_dota_hero_sven" then
			return self:GetAbility():GetSpecialValueFor("bonus_damage")
		end
		return 0
	end	
end
function modifier_item_red_divine_rapier:GetModifierTotalDamageOutgoing_Percentage(params)
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local target = params.target
	if parent == nil then return end
	if target == nil then target = params.unit end
	if target == nil then return end
	if params.attacker ~= parent then return end
	if params.attacker == target then return end
	if ability then
		if parent:IsHero() then
			local damage = ability:GetSpecialValueFor("swrod_master_bonus_ptc")
			if target:GetUnitName() == "npc_boss_juggernaut_4" then
				return damage
			else
				return 0
			end
		end	
		return 0
	end	
end

function modifier_item_red_divine_rapier:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() and self:GetParent() then
		if self:GetParent():GetName() == "npc_dota_hero_sven" then
			return self:GetAbility():GetSpecialValueFor("bonus_damage")
		end	
		return 0
	end	
end

function modifier_item_red_divine_rapier:GetModifierSpellAmplify_Percentage()
	if self:GetAbility()then
		return self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
	end	
end