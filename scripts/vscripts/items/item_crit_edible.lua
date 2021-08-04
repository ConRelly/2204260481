-----------------------------------------------------------------------------------------------------------
--	Edible item
-----------------------------------------------------------------------------------------------------------
local edible_crit = "modifier_item_imba_greater_crit_edible"
local item_crit = "modifier_item_imba_greater_crit"
LinkLuaModifier( "modifier_item_crit_edible", "items/item_crit_edible.lua", LUA_MODIFIER_MOTION_NONE )

if item_crit_edible == nil then item_crit_edible = class({}) end

function item_crit_edible:OnSpellStart()
    if IsServer() then
       local caster = self:GetCaster()
       if not caster:IsRealHero() or caster:HasModifier("modifier_arc_warden_tempest_double") then return end -- make sure lone druid bear can't have this
       if caster:HasModifier(edible_crit) or caster:HasModifier(item_crit) then return nil end
       caster:AddNewModifier(caster, nil, edible_crit, {})
       caster:EmitSound("Hero_Alchemist.Scepter.Cast")
       caster:RemoveItem(self)   
    end
end
-----------------------------------------------------------------------------------------------------------
--	Edible Daedalus definition
-----------------------------------------------------------------------------------------------------------

if item_imba_greater_crit_edible == nil then item_imba_greater_crit_edible = class({}) end
LinkLuaModifier( "modifier_item_imba_greater_crit_edible", "items/item_crit_edible.lua", LUA_MODIFIER_MOTION_NONE )		-- Owner's bonus attributes, stackable
LinkLuaModifier( "modifier_item_imba_greater_crit_edible_buff", "items/item_crit_edible.lua", LUA_MODIFIER_MOTION_NONE )	-- Critical damage increase counter


function item_imba_greater_crit_edible:GetIntrinsicModifierName()
	return "modifier_item_imba_greater_crit_edible"
end

-----------------------------------------------------------------------------------------------------------
--	Daedalus owner bonus attributes
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_greater_crit_edible == nil then modifier_item_imba_greater_crit_edible = class({}) end
function modifier_item_imba_greater_crit_edible:IsHidden() return false end
function modifier_item_imba_greater_crit_edible:IsDebuff() return false end
function modifier_item_imba_greater_crit_edible:IsPurgable() return false end
function modifier_item_imba_greater_crit_edible:IsPermanent() return true end
function modifier_item_imba_greater_crit_edible:RemoveOnDeath() return false end
function modifier_item_imba_greater_crit_edible:AllowIllusionDuplicate() return true end
function modifier_item_imba_greater_crit_edible:GetTexture()
	return "custom/imba_greater_crit_edible"
end
-- Adds the damage
function modifier_item_imba_greater_crit_edible:OnCreated(keys)
	self.ability = self:GetAbility()
	local parent = self:GetParent()
	if IsServer() then

		if not parent:HasModifier("modifier_item_imba_greater_crit_edible_buff") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_imba_greater_crit_edible_buff", {})
		end
	end	
	if not parent:IsRealHero() then return nil end

	local level = parent:GetLevel()
	self.base_damage = 77 * level
    self.bonus_damage_pct = 66

	self:StartIntervalThink(FrameTime())
end

function modifier_item_imba_greater_crit_edible:OnIntervalThink()
	self:OnCreated(keys)
end	

function modifier_item_imba_greater_crit_edible:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}

	return decFuncs
end

function modifier_item_imba_greater_crit_edible:GetModifierBaseAttack_BonusDamage()
	return self.base_damage
end
function modifier_item_imba_greater_crit_edible:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage_pct
end


-- Removes the crit buff if somehow you lose the edible thing
function modifier_item_imba_greater_crit_edible:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_imba_greater_crit_edible") then
			parent:RemoveModifierByName("modifier_item_imba_greater_crit_edible_buff")
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- Edible Daedalus crit damage buff
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_greater_crit_edible_buff == nil then modifier_item_imba_greater_crit_edible_buff = class({}) end
function modifier_item_imba_greater_crit_edible_buff:IsHidden() return true end
function modifier_item_imba_greater_crit_edible_buff:IsDebuff() return false end
function modifier_item_imba_greater_crit_edible_buff:IsPurgable() return false end
function modifier_item_imba_greater_crit_edible_buff:IsPermanent() return true end
--function modifier_item_imba_greater_crit_edible_buff:GetTexture() return "custom/imba_greater_crit_edible" end
function modifier_item_imba_greater_crit_edible_buff:OnCreated()
	-- Ability
	local parent = self:GetParent()
	local level = parent:GetLevel()
	-- Special values
	self.base_crit = 777
	local crit_increase = 6 * level
	local crit_chance = 6
	local bonus_crit_chance = 4
	if IsServer() then
		if parent:HasScepter() then
			crit_chance = crit_chance + bonus_crit_chance
		end
		if HasSuperScepter(parent) then
			crit_increase = crit_increase * 3
		end
	end
	self.crit_chance = crit_chance
	self.crit_increase = crit_increase
	self:StartIntervalThink(FrameTime())
end

function modifier_item_imba_greater_crit_edible_buff:OnIntervalThink()
	self:OnCreated()
end


function modifier_item_imba_greater_crit_edible_buff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}

	return decFuncs
end
function modifier_item_imba_greater_crit_edible_buff:GetModifierPreAttack_CriticalStrike(params)
	if IsServer() then
		if RollPercentage(self.crit_chance) then
			return self.base_crit + self.crit_increase
		else
			return nil
		end
	end
end