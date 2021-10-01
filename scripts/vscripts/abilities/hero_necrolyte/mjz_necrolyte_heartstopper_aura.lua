LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura_counter","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_stack_counter","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura_effect","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)

-----------------------
-- Heartstopper Aura --
-----------------------
mjz_necrolyte_heartstopper_aura = class({})
function mjz_necrolyte_heartstopper_aura:GetIntrinsicModifierName() return "modifier_mjz_necrolyte_heartstopper_aura_counter" end
function mjz_necrolyte_heartstopper_aura:GetAOERadius()
	if self:GetToggleState() then
		return self:GetSpecialValueFor("radius") + self:GetCaster():GetCastRangeBonus()
	else return 0 end
end
function mjz_necrolyte_heartstopper_aura:OnToggle()
	if IsServer() then
		if self:GetToggleState() then aura_effect = true else aura_effect = false end
	end
end
function mjz_necrolyte_heartstopper_aura:OnUpgrade()
	if IsServer() then
		if self:GetLevel() == 1 then
			self:ToggleAbility()
		end
	end
end

--------------------------------
-- Heartstopper Aura Modifier --
--------------------------------
modifier_mjz_necrolyte_heartstopper_aura_counter = class({})
local modifier_counter = modifier_mjz_necrolyte_heartstopper_aura_counter

function modifier_counter:IsHidden() return (self:GetStackCount() == 0) end
function modifier_counter:IsPurgable() return false end

function modifier_counter:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end
function modifier_counter:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("health_regen") end
end
function modifier_counter:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("mana_regen") end
end

-----------------------------------------------------------------------------------------
function modifier_counter:IsAura() return aura_effect end
function modifier_counter:GetModifierAura() return "modifier_mjz_necrolyte_heartstopper_aura_effect" end
function modifier_counter:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_counter:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_counter:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_counter:GetAuraRadius() return self:GetAbility():GetAOERadius() end

------------------------------
-- Heartstopper Aura Stacks --
------------------------------
modifier_mjz_necrolyte_heartstopper_stack_counter = class({})
local modifier_stacks = modifier_mjz_necrolyte_heartstopper_stack_counter
function modifier_stacks:IsHidden() return true end
function modifier_stacks:IsPurgable() return false end
function modifier_stacks:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_stacks:OnDestroy()
	if not IsServer() then return end
	self:GetParent():FindModifierByName("modifier_mjz_necrolyte_heartstopper_aura_counter"):DecrementStackCount()
end

------------------------------
-- Heartstopper Aura Effect --
------------------------------
modifier_mjz_necrolyte_heartstopper_aura_effect = class({})
local modifier_effect = modifier_mjz_necrolyte_heartstopper_aura_effect

function modifier_effect:IsHidden() return false end
function modifier_effect:IsPurgable() return false end
function modifier_effect:IsDebuff() return true end

if IsServer() then
	function modifier_effect:OnCreated()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval"))
	end

	function modifier_effect:DeclareFunctions()
		return {MODIFIER_EVENT_ON_DEATH}
	end
	function modifier_effect:OnDeath(event)
		if self:GetCaster():PassivesDisabled() then return nil end
		if self:GetParent() ~= event.unit then return end

		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local regen_duration = ability:GetSpecialValueFor("regen_duration")
		local hero_multiplier = ability:GetSpecialValueFor("hero_multiplier")

		local count = 1
		if parent:IsRealHero() then 
			count = hero_multiplier 
		end
		for i=1,count do
			local modifier_counter = caster:AddNewModifier(caster, ability, "modifier_mjz_necrolyte_heartstopper_stack_counter", {duration = regen_duration})

			caster:FindModifierByName("modifier_mjz_necrolyte_heartstopper_aura_counter"):IncrementStackCount()
		end
	end

	function modifier_effect:OnIntervalThink()
		if not self:GetAbility():GetToggleState() then return end
		if self:GetCaster():PassivesDisabled() then return end

		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local interval = ability:GetSpecialValueFor("interval")
		local base_damage = ability:GetSpecialValueFor("base_damage")
		local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		local damage = base_damage + caster:GetIntellect() * (intelligence_damage / 100)

		ApplyDamage({
			attacker = caster,
			victim = self:GetParent(),
			ability = ability,
			damage_type = ability:GetAbilityDamageType(),
			damage = damage * interval
		})
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

