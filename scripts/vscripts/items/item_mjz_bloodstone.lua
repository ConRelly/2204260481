LinkLuaModifier( "modifier_item_mjz_bloodstone", "items/item_mjz_bloodstone", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_bloodstone_buff", "items/item_mjz_bloodstone", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_bloodstone_active", "items/item_mjz_bloodstone", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

local item_mjz_bloodstone_active_mana_cost = function(ability, iLevel)
	if ability and IsValidEntity(ability:GetCaster()) then
		local mana_cost_per = ability:GetSpecialValueFor("mana_cost_percentage") --ability:GetLevelSpecialValueFor("mana_cost_percentage", iLevel) 
		local max_mana = ability:GetCaster():GetMaxMana()
		local spend_mana = max_mana * mana_cost_per / 100
		return spend_mana
	end
	return 0
end

local item_mjz_bloodstone_active = function(ability)
	if IsServer() then
		local caster = ability:GetCaster()
		local restore_duration = ability:GetSpecialValueFor("restore_duration")
		if caster and IsValidEntity(caster) and caster:IsAlive() then
			caster:AddNewModifier(caster, ability, "modifier_item_mjz_bloodstone_active", {duration = restore_duration})
		end
	end
end
---------------------------------------------------------------------------------------

item_mjz_bloodstone_2 = class({})

function item_mjz_bloodstone_2:GetIntrinsicModifierName()
	return "modifier_item_mjz_bloodstone"
end
function item_mjz_bloodstone_2:GetManaCost(iLevel)
	return item_mjz_bloodstone_active_mana_cost(self, iLevel)
end
function item_mjz_bloodstone_2:OnSpellStart()
	item_mjz_bloodstone_active(self)
end

---------------------------------------------------------------------------------------

item_mjz_bloodstone_3 = class({})

function item_mjz_bloodstone_3:GetIntrinsicModifierName()
	return "modifier_item_mjz_bloodstone"
end
function item_mjz_bloodstone_3:GetManaCost(iLevel)
	return item_mjz_bloodstone_active_mana_cost(self, iLevel)
end
function item_mjz_bloodstone_3:OnSpellStart()
	item_mjz_bloodstone_active(self)
end
---------------------------------------------------------------------------------------

item_mjz_bloodstone_4 = class({})

function item_mjz_bloodstone_4:GetIntrinsicModifierName()
	return "modifier_item_mjz_bloodstone"
end
function item_mjz_bloodstone_4:GetManaCost(iLevel)
	return item_mjz_bloodstone_active_mana_cost(self, iLevel)
end
function item_mjz_bloodstone_4:OnSpellStart()
	item_mjz_bloodstone_active(self)
end
---------------------------------------------------------------------------------------

item_mjz_bloodstone_5 = class({})

function item_mjz_bloodstone_5:GetIntrinsicModifierName()
	return "modifier_item_mjz_bloodstone"
end
function item_mjz_bloodstone_5:GetManaCost(iLevel)
	return item_mjz_bloodstone_active_mana_cost(self, iLevel)
end
function item_mjz_bloodstone_5:OnSpellStart()
	item_mjz_bloodstone_active(self)
end
---------------------------------------------------------------------------------------

item_mjz_bloodstone_ultimate = class({})

function item_mjz_bloodstone_ultimate:GetIntrinsicModifierName()
	return "modifier_item_mjz_bloodstone"
end
function item_mjz_bloodstone_ultimate:GetManaCost(iLevel)
	return item_mjz_bloodstone_active_mana_cost(self, iLevel)
end
function item_mjz_bloodstone_ultimate:OnSpellStart()
	item_mjz_bloodstone_active(self)
end

---------------------------------------------------------------------------------------

if modifier_item_mjz_bloodstone == nil then modifier_item_mjz_bloodstone = class({}) end
function modifier_item_mjz_bloodstone:IsHidden() return true end
function modifier_item_mjz_bloodstone:IsPurgable() return false end
function modifier_item_mjz_bloodstone:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_mjz_bloodstone:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end
function modifier_item_mjz_bloodstone:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
end
function modifier_item_mjz_bloodstone:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_item_mjz_bloodstone:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana") end
end
function modifier_item_mjz_bloodstone:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
end
function modifier_item_mjz_bloodstone:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
end


if IsServer() then
	function modifier_item_mjz_bloodstone:OnCreated(table)
		local parent = self:GetParent()
		if IsValidEntity(parent) and parent:IsRealHero() then
			self:StartIntervalThink(0.25)
		end
	end

	function modifier_item_mjz_bloodstone:OnIntervalThink()
		local parent = self:GetParent()
		if IsValidEntity(parent) and parent:IsRealHero() then
			local mt = {"modifier_item_mjz_bloodstone_buff",}
			for _,mname in pairs(mt) do
				if not parent:HasModifier(mname) then
					parent:AddNewModifier(self:GetCaster(), self:GetAbility(), mname, {})
				end
			end
		end
	end

	function modifier_item_mjz_bloodstone:OnDestroy()
		local parent = self:GetParent()
		if IsValidEntity(parent) and parent:IsAlive() then
			local mt = {"modifier_item_mjz_bloodstone_buff",}
			for _,mname in pairs(mt) do
				parent:RemoveModifierByName(mname)
			end
		end
	end
end

-------------------------------------------------------------------------------

modifier_item_mjz_bloodstone_buff = class({})
function modifier_item_mjz_bloodstone_buff:IsHidden() return true end
function modifier_item_mjz_bloodstone_buff:IsPurgable() return false end
function modifier_item_mjz_bloodstone_buff:IsBuff() return true end
function modifier_item_mjz_bloodstone_buff:GetTexture() return "item_mjz_bloodstone" end
function modifier_item_mjz_bloodstone_buff:DeclareFunctions()
	if self:GetAbility():GetName() == "item_mjz_bloodstone_ultimate" then
		return {
			MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		}
	else
		return {MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE}
	end
end

function modifier_item_mjz_bloodstone_buff:GetModifierMPRegenAmplify_Percentage()
	local ability = self:GetAbility()
	if IsValidEntity(ability) then
		return ability:GetSpecialValueFor("mana_regen_multiplier") or 0
	end
end
function modifier_item_mjz_bloodstone_buff:GetModifierSpellAmplify_Percentage()
	local ability = self:GetAbility()
	if IsValidEntity(ability) then
		return ability:GetSpecialValueFor("spell_amp") or 0
	end
end
function modifier_item_mjz_bloodstone_buff:GetModifierPercentageManacostStacking()
	local ability = self:GetAbility()
	if IsValidEntity(ability) then
		return ability:GetSpecialValueFor("manacost_reduction") or 0
	end
end

-------------------------------------------------------------------------------

modifier_item_mjz_bloodstone_active = class({})
function modifier_item_mjz_bloodstone_active:IsHidden() return false end
function modifier_item_mjz_bloodstone_active:IsPurgable() return false end
function modifier_item_mjz_bloodstone_active:IsBuff() return true end
function modifier_item_mjz_bloodstone_active:GetTexture() 
	return "item_mjz_bloodstone" 
end

if IsServer() then
	function modifier_item_mjz_bloodstone_active:OnCreated()
		self:StartIntervalThink(0.25)
	end

	function modifier_item_mjz_bloodstone_active:OnIntervalThink()
		local caster = self:GetCaster()
		local mana_cost_percentage = self:GetAbility():GetSpecialValueFor("mana_cost_percentage")
		local restore_duration = self:GetAbility():GetSpecialValueFor("restore_duration")

		if caster and IsValidEntity(caster) and caster:IsAlive() then
			local flManaSpent = caster:GetMaxMana() * (mana_cost_percentage / 100)
			local flAmount = flManaSpent / restore_duration * 0.25
			local hInflictor = caster
			
			caster:Heal(flAmount, hInflictor)
		end
	end
end