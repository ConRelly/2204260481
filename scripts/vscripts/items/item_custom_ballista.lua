require("lib/popup")
item_custom_ballista = class({})
function item_custom_ballista:GetIntrinsicModifierName() return "modifier_item_custom_ballista" end
function item_custom_ballista:Spawn()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 1
		self:SetCurrentCharges(1)
		if caster:HasModifier("modifier_super_scepter") then
			self:SetPurchaseTime(0)
			if RollPercentage(2) then
				stacks = RandomInt(6, 20)
			elseif RollPercentage(7) then
				stacks = RandomInt(5, 13)
			elseif RollPercentage(15) then
				stacks = RandomInt(5, 10)
			else
				stacks = RandomInt(2, 7)
			end	
			self:SetCurrentCharges(stacks)
		end	
	end
end


LinkLuaModifier("modifier_item_custom_ballista", "items/item_custom_ballista.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_ballista = class({})
function modifier_item_custom_ballista:IsHidden() return true end
function modifier_item_custom_ballista:IsPurgable() return false end
function modifier_item_custom_ballista:RemoveOnDeath() return false end
if IsServer() then
	function modifier_item_custom_ballista:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.parent:RemoveModifierByName("modifier_item_custom_ballista_buff")
		self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_custom_ballista_buff", {})	
	end
	function modifier_item_custom_ballista:OnDestroy()
		if self.parent and IsValidEntity(self.parent) then
			self.parent:RemoveModifierByName("modifier_item_custom_ballista_buff")
		end
	end
end
LinkLuaModifier("modifier_item_custom_ballista_buff", "items/item_custom_ballista.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_ballista_buff = class({})
function modifier_item_custom_ballista_buff:IsHidden() return true end
function modifier_item_custom_ballista_buff:IsPurgable() return false end
function modifier_item_custom_ballista_buff:RemoveOnDeath() return false end
function modifier_item_custom_ballista_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_custom_ballista_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK}
	
end
function modifier_item_custom_ballista_buff:GetModifierAttackRangeBonus()
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_range_bonus") end
end
function modifier_item_custom_ballista_buff:GetModifierBonusStats_Strength()
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_strength") * self:GetAbility():GetCurrentCharges() end
end
function modifier_item_custom_ballista_buff:GetModifierBonusStats_Agility()
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_agility") * self:GetAbility():GetCurrentCharges() end
end
function modifier_item_custom_ballista_buff:GetModifierBonusStats_Intellect()
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_intellect") * self:GetAbility():GetCurrentCharges() end
end
function modifier_item_custom_ballista_buff:GetModifierConstantHealthRegen()
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health_regen") * self:GetAbility():GetCurrentCharges() end
end
function modifier_item_custom_ballista_buff:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("base_attack_damage") * self:GetAbility():GetCurrentCharges() end
end


if IsServer() then
	function modifier_item_custom_ballista_buff:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage") * self:GetAbility():GetCurrentCharges()
		--self.chance = self:GetAbility():GetSpecialValueFor("chance")
		self.attacks = 0
	end
	function modifier_item_custom_ballista_buff:GetModifierProcAttack_Feedback(keys)
        local attacker = keys.attacker
		local target = keys.target
		local parent = self:GetParent()
		self.attacks = self.attacks + 1
		if self.attacks > 9 then
			local damageTable = {
				victim = target,
				attacker = attacker,
				damage = self.bonus_damage,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = 16 + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
				ability = self.ability, 
			}
			ApplyDamage(damageTable)
			create_popup({
				target = target,
				value = self.bonus_damage,
				color = Vector(183, 47, 234),
				type = "spell",
				pos = 6
			})
			self.attacks = 0
		end	
	end
end
