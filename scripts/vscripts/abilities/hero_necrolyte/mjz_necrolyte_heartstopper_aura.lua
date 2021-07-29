LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura_counter","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura_regen","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura_effect","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)

local modifier_regen_name = "modifier_mjz_necrolyte_heartstopper_aura_regen"
local modifier_counter_name = "modifier_mjz_necrolyte_heartstopper_aura_counter"

mjz_necrolyte_heartstopper_aura = class({})
local ability_class = mjz_necrolyte_heartstopper_aura

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_necrolyte_heartstopper_aura"
end

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor("radius") + self:GetCaster():GetCastRangeBonus()
end
function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius") + self:GetCaster():GetCastRangeBonus()
end

function ability_class:OnToggle()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()

		if ability:GetToggleState() then
			--caster:AddNewModifier( caster, ability, "", nil )
		else
			--caster:RemoveModifierByName("")
		end
	end
end

function ability_class:OnUpgrade()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()

		if ability:GetLevel() == 1 then
			ability:ToggleAbility()
		end
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_necrolyte_heartstopper_aura = class({})
local modifier_class = modifier_mjz_necrolyte_heartstopper_aura

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if not parent:HasModifier(modifier_counter_name) then
			parent:AddNewModifier(parent, ability, modifier_counter_name, {})
		end
	end
end

-----------------------------------------------------------------------------------------

function modifier_class:IsAura() return true end

function modifier_class:GetModifierAura()
	return "modifier_mjz_necrolyte_heartstopper_aura_effect"
end

function modifier_class:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_class:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_class:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_class:GetAuraRadius()
	-- return self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetParent():GetCastRangeBonus()
	return self:GetAbility():GetAOERadius()
end

-----------------------------------------------------------------------------------------

modifier_mjz_necrolyte_heartstopper_aura_counter = class({})
local modifier_counter = modifier_mjz_necrolyte_heartstopper_aura_counter

function modifier_counter:IsHidden() return (self:GetAbility():GetLevel() < 1) end
function modifier_counter:IsPurgable() return false end

if IsServer() then
	function modifier_counter:UpdateTooltip()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local modifier_regen_list = parent:FindAllModifiersByName(modifier_regen_name)
		self:SetStackCount(#modifier_regen_list)
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_necrolyte_heartstopper_aura_regen = class({})
local modifier_regen = modifier_mjz_necrolyte_heartstopper_aura_regen

function modifier_regen:IsHidden() return true end
function modifier_regen:IsPurgable() return false end
function modifier_regen:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_regen:GetModifierConstantHealthRegen( )
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("health_regen") end
end
function modifier_regen:GetModifierConstantManaRegen( )
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
if IsServer() then
	function modifier_regen:OnDestroy()
		local parent = self:GetParent()
		local modifier_counter = parent:FindModifierByName(modifier_counter_name)
		if modifier_counter then
			modifier_counter:UpdateTooltip()
		end
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_necrolyte_heartstopper_aura_effect = class({})
local modifier_effect = modifier_mjz_necrolyte_heartstopper_aura_effect

function modifier_effect:IsHidden() return false end
function modifier_effect:IsPurgable() return false end
function modifier_effect:IsDebuff() return true end

if IsServer() then
	function modifier_effect:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_DEATH,
		}
	end
	function modifier_effect:OnDeath( event )
		if self:GetParent() ~= event.unit then return end

		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		if caster:PassivesDisabled() then return nil end

		local regen_duration = ability:GetSpecialValueFor("regen_duration")
		local hero_multiplier = ability:GetSpecialValueFor("hero_multiplier")

		local count = 1
		if parent:IsRealHero() then 
			count = hero_multiplier 
		end
		for i=1,count do
			caster:AddNewModifier(caster, ability, modifier_regen_name, {duration = regen_duration})
		end

		local modifier_counter = caster:FindModifierByName(modifier_counter_name)
		if modifier_counter then
			modifier_counter:UpdateTooltip()
		end
	end

	function modifier_effect:OnCreated(table)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local interval = ability:GetSpecialValueFor("interval")
		self:StartIntervalThink(interval)
	end

	function modifier_effect:OnIntervalThink()
		if not self:_Enabled() then return nil end

		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local target = self:GetParent()

		local interval = ability:GetSpecialValueFor("interval")
		local base_damage = ability:GetSpecialValueFor("base_damage")
		local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		local damage = base_damage + caster:GetIntellect() * (intelligence_damage / 100.0)
		damage = damage * interval

		ApplyDamage({
			attacker = caster,
			victim = target,
			ability = ability,
			damage_type = ability:GetAbilityDamageType(),
			damage = damage
		})
	end

	function modifier_effect:_Enabled( )
		local ability = self:GetAbility()
		return ability:GetToggleState()
	end

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

