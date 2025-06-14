require("lib/popup")
item_custom_ballista = class({})
item_custom_ballista_2 = item_custom_ballista
function item_custom_ballista:GetIntrinsicModifierName() return "modifier_item_custom_ballista" end
function item_custom_ballista:Spawn()
	if IsServer() then
		local caster = self:GetParent()
		local playerID = caster:GetPlayerID()
		local saved_data = _G.saved_ballista_stacks[playerID]
		local stacks = 1

		self:SetCurrentCharges(1)

		-- Check for saved ballista stacks using the generic identifier
		if saved_data and saved_data.item_name == "ballista_saved_stacks" then
			stacks = saved_data.stacks
			_G.saved_ballista_stacks[playerID] = nil -- Clear saved stacks after use
			Notifications:Top(playerID, {text="Applied saved Ballista stacks: "..stacks, style={color="green"}, duration=7})

			-- Mark this item as having loaded saved stacks
			self._is_saved_ballista = true
			_G.saved_ballista_items = _G.saved_ballista_items or {}
			_G.saved_ballista_items[playerID] = self

			-- Make the item non-sharable after applying saved stacks
			self:SetShareability(ITEM_NOT_SHAREABLE)
		else
			-- Existing logic for rolling random stacks
			if caster:HasModifier("modifier_super_scepter") then
				self:SetPurchaseTime(0)
				if RollPercentage(1) then
					stacks = RandomInt(15, 40)
				elseif RollPercentage(2) then
					stacks = RandomInt(10, 30)
				elseif RollPercentage(7) then
					stacks = RandomInt(9, 25)
				elseif RollPercentage(15) then
					stacks = RandomInt(8, 18)
				else
					stacks = RandomInt(4, 12)
				end
			end
		end

		self:SetCurrentCharges(stacks)
		-- trigger drop and pickup of the item with delay to apply the modifier if it is item_custom_ballista_2
		if self:GetName() == "item_custom_ballista_2" then
			Timers:CreateTimer(0.1, function()
				if IsValidEntity(caster) and caster:IsAlive() and IsValidEntity(self) then
					caster:DropItemAtPositionImmediate(self, caster:GetAbsOrigin())
					Timers:CreateTimer(0.1, function()
						if IsValidEntity(self) and IsValidEntity(caster) and caster:IsAlive() then
							caster:PickupDroppedItem(self:GetContainer())
						end
					end)
				end
			end)
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
		if not attacker:IsRealHero() then return end
		if self.attacks > 8 then
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
		else
			self.attacks = self.attacks + 1
		end	
	end
end
