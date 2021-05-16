LinkLuaModifier("modifier_mjz_visage_familiar_soul_link","abilities/hero_visage/mjz_visage_familiar_soul_link.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_visage_familiar_soul_link_damage","abilities/hero_visage/mjz_visage_familiar_soul_link.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_visage_familiar_soul_link_health","abilities/hero_visage/mjz_visage_familiar_soul_link.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_visage_familiar_soul_link_attack_range","abilities/hero_visage/mjz_visage_familiar_soul_link.lua", LUA_MODIFIER_MOTION_NONE)

local modifier_damage_name = 'modifier_mjz_visage_familiar_soul_link_damage'
local modifier_health_name = 'modifier_mjz_visage_familiar_soul_link_health'
local modifier_attack_range_name = 'modifier_mjz_visage_familiar_soul_link_attack_range'

mjz_visage_familiar_soul_link = class({})
local ability_class = mjz_visage_familiar_soul_link

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_visage_familiar_soul_link"
end

-----------------------------------------------------------------------------------------

modifier_mjz_visage_familiar_soul_link = class({})
local modifier_class = modifier_mjz_visage_familiar_soul_link

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		self.base_attack_range = parent:GetBaseAttackRange()

		if not parent:HasModifier(modifier_damage_name) then
			parent:AddNewModifier(parent, ability, modifier_damage_name, {})
		end
		if not parent:HasModifier(modifier_health_name) then
			parent:AddNewModifier(parent, ability, modifier_health_name, {})
		end
		if not parent:HasModifier(modifier_attack_range_name) then
			parent:AddNewModifier(parent, ability, modifier_attack_range_name, {})
		end

		self:OnIntervalThink()
		self:StartIntervalThink(2.5)
	end

	function modifier_class:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local bonus_damage_pct = ability:GetSpecialValueFor('bonus_damage_pct')
		local bonus_health_pct = ability:GetSpecialValueFor('bonus_health_pct')
		local attack_range_pct = ability:GetSpecialValueFor('attack_range_pct')

		-- local hero = parent:GetPlayerOwner():GetAssignedHero()
		local owner = parent:GetOwner()
		if owner then
			local owner_damage = owner:GetAverageTrueAttackDamage(owner)
			local bonus_damage = owner_damage * (bonus_damage_pct / 100.0)
			SetModifierStackCount(parent, modifier_damage_name, bonus_damage)

			local bonus_health = owner:GetMaxHealth() * (bonus_health_pct / 100.0)
			SetModifierStackCount(parent, modifier_health_name, bonus_health, true)

			local owner_attack_range = owner:GetBaseAttackRange() -- + owner:GetAttackRangeBuffer()
			local attack_range = owner_attack_range * (attack_range_pct / 100.0)
			local attack_range_bonus = attack_range - self.base_attack_range
			SetModifierStackCount(parent, modifier_attack_range_name, attack_range_bonus)
		end
	end

	function SetModifierStackCount(parent, modifier_name, stack_count, is_refresh)
		local modifier = parent:FindModifierByName(modifier_name)
		if modifier then
			if modifier:GetStackCount() ~= stack_count then
				modifier:SetStackCount(stack_count)
			end
			if is_refresh then
				modifier:ForceRefresh()
			end
		end
	end
end


-----------------------------------------------------------------------------------------

modifier_mjz_visage_familiar_soul_link_damage = class({})
local modifier_damage = modifier_mjz_visage_familiar_soul_link_damage

function modifier_damage:IsHidden() return true end
function modifier_damage:IsPurgable() return false end

function modifier_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end
function modifier_damage:GetModifierPreAttack_BonusDamage( )
	return self:GetStackCount()
end

-----------------------------------------------------------------------------------------

modifier_mjz_visage_familiar_soul_link_health = class({})
local modifier_health = modifier_mjz_visage_familiar_soul_link_health

function modifier_health:IsHidden() return true end
function modifier_health:IsPurgable() return false end

-- only hero
--[[ 
	function modifier_health:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_HEALTH_BONUS
		}
	end
	function modifier_health:GetModifierHealthBonus()
		return self:GetStackCount()
	end	
]]

if IsServer() then
	function modifier_health:OnCreated(table)
		local parent = self:GetParent()
		self.base_health = parent:GetMaxHealth()
	end

	function modifier_health:OnRefresh(table)
		local parent = self:GetParent()
		local ability = self:GetAbility()

		local lose_health = parent:GetMaxHealth() - parent:GetHealth()
		local max_health = self.base_health + self:GetStackCount()
		local new_health = max_health - lose_health

		parent:SetBaseMaxHealth(max_health)
		parent:SetMaxHealth(max_health)

		parent:SetHealth(new_health)
		-- void ModifyHealth(int iDesiredHealthValue, handle hAbility, bool bLethal, int iAdditionalFlags)
		parent:ModifyHealth(new_health, ability, false, 0)
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_visage_familiar_soul_link_attack_range = class({})
local modifier_attack_range = modifier_mjz_visage_familiar_soul_link_attack_range

function modifier_attack_range:IsHidden() return true end
function modifier_attack_range:IsPurgable() return false end

function modifier_attack_range:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end
function modifier_attack_range:GetModifierAttackRangeBonus()
	return self:GetStackCount()
end	

-----------------------------------------------------------------------------------------

-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end

