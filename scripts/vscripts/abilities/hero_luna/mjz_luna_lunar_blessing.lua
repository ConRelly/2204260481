
function AddBuff(event)
    if not event.target:HasModifier("modifier_item_custom_apex") then
		event.target:AddNewModifier(event.caster, event.ability, "modifier_mjz_luna_lunar_blessing_buff", {})
	end	
end

function RemoveBuff(event)
	event.target:RemoveModifierByName("modifier_mjz_luna_lunar_blessing_buff")
end

----------------------------------------------------------------------

LinkLuaModifier("modifier_mjz_luna_lunar_blessing_buff", "abilities/hero_luna/mjz_luna_lunar_blessing.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_luna_lunar_blessing_buff = class ({})
local modifier_class = modifier_mjz_luna_lunar_blessing_buff
function modifier_class:IsHidden() return false end
function modifier_class:IsBuff() return true end
function modifier_class:IsPurgable() return false end

-- function modifier_class:GetTexture()
-- 	return "modifiers/modifier_mjz_luna_lunar_blessing_buff"
-- end

function modifier_class:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
end
function modifier_class:GetModifierBonusStats_Strength(kv)
	return self.str_bonus
end
function modifier_class:GetModifierBonusStats_Agility(kv)
	return self.agi_bonus
end
function modifier_class:GetModifierBonusStats_Intellect(kv)
	return self.int_bonus
end

function modifier_class:OnCreated(kv)
	if not IsServer() then return end
	self:_Init(kv)
	self:StartIntervalThink(2)
end

function modifier_class:OnRefresh(kv)
	self:OnCreated(kv)
end

function modifier_class:OnIntervalThink()
	local unit = self:GetParent()
	if unit and IsValidEntity(unit) and unit:IsRealHero() then
		if self._PrimaryStatValue ~= self:_GetPrimaryStatValue() then
			self:_Init()
			self._PrimaryStatValue = self:_GetPrimaryStatValue()
		end
		if unit:HasModifier("modifier_item_custom_apex") then
			unit:RemoveModifierByName("modifier_mjz_luna_lunar_blessing_buff")
		end	
	end
end

function modifier_class:_Init()
	if not IsServer() then return end
	local unit = self:GetParent()
	if self:GetAbility() then
		self.primary_attribute_per = self:GetAbility():GetSpecialValueFor("primary_attribute_per")			
	else
		self.primary_attribute_per = 1
	end

	self.str_bonus = 0
	self.agi_bonus = 0
	self.int_bonus = 0
	if unit and IsValidEntity(unit) and unit:IsRealHero() then
		if not IsServer() then return end
		local pa = unit:GetPrimaryAttribute()

		unit:CalculateStatBonus(false)

		local PrimaryStatValue = self:_GetPrimaryStatValue()

		local bonus = PrimaryStatValue * (self.primary_attribute_per / 100)
		if math.abs( bonus ) < 1 then bonus = 1 end

		--STRENGTH = 0
		--AGILITY = 1
		--INTELLIGENCE = 2
		--all(universall) = 3  probably
		if pa == 0 then
			self.str_bonus = bonus
		elseif pa == 1 then
			self.agi_bonus = bonus
		elseif pa == 2 then
			self.int_bonus = bonus
		else
			local bonus1 = math.floor(unit:GetIntellect() * (self.primary_attribute_per / 100))
			local bonus2 = math.floor(unit:GetAgility() * (self.primary_attribute_per / 100))
			local bonus3 = math.floor(unit:GetStrength() * (self.primary_attribute_per / 100))			
			self.int_bonus = bonus1 
			self.agi_bonus = bonus2 
			self.str_bonus = bonus3 
		end
	end
end

function modifier_class:_GetPrimaryStatValue()
	if not IsServer() then return end
	--STRENGTH = 0
	--AGILITY = 1
	--INTELLIGENCE = 2
	local unit = self:GetParent()
	local pa = unit:GetPrimaryAttribute()
	local PrimaryStatValue = 0
	if pa == 0 then
		PrimaryStatValue = unit:GetStrength()
	elseif pa == 1 then
		PrimaryStatValue = unit:GetAgility()
	elseif pa == 2 then
		PrimaryStatValue = unit:GetIntellect()
	else
		PrimaryStatValue = unit:GetAgility()
	end
	return PrimaryStatValue
end