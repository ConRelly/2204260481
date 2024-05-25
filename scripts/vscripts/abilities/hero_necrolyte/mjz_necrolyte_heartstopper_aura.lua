LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura_counter","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura_effect","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)

-----------------------
-- Heartstopper Aura --
-----------------------
mjz_necrolyte_heartstopper_aura = class({})
function mjz_necrolyte_heartstopper_aura:GetIntrinsicModifierName() return "modifier_mjz_necrolyte_heartstopper_aura_counter" end
function mjz_necrolyte_heartstopper_aura:GetAOERadius()
	return self:GetSpecialValueFor("radius") + self:GetCaster():GetCastRangeBonus()
end

--------------------------------
-- Heartstopper Aura Modifier --
--------------------------------
modifier_mjz_necrolyte_heartstopper_aura_counter = class({})
local modifier_counter = modifier_mjz_necrolyte_heartstopper_aura_counter
function modifier_counter:IsHidden() return (self:GetStackCount() < 1) end
function modifier_counter:IsPurgable() return false end
function modifier_counter:DestroyOnExpire() return false end
function modifier_counter:OnCreated()
	self:SetStackCount(0)
end
function modifier_counter:OnRefresh()
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if self:GetAbility():IsNull() then return end
	local stack_duration = self:GetAbility():GetSpecialValueFor("regen_duration")
	self:SetStackCount(self:GetStackCount() + 1)
	self:SetDuration(stack_duration, true)
	Timers:CreateTimer(stack_duration, function()
		if self ~= nil and not self:IsNull() and not self:GetAbility():IsNull() and not self:GetParent():IsNull() and not self:GetCaster():IsNull() and self:GetStackCount() > 0 then
			self:SetStackCount(self:GetStackCount() - 1)
		end
	end)
end

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
function modifier_counter:IsAura() return true end
function modifier_counter:IsAuraActiveOnDeath() return false end
function modifier_counter:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("interval") - 0.1 end
function modifier_counter:GetModifierAura() return "modifier_mjz_necrolyte_heartstopper_aura_effect" end
function modifier_counter:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_counter:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_counter:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_counter:GetAuraRadius() return self:GetAbility():GetAOERadius() end

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
		if not self:GetAbility() then return end
		if self:GetCaster():PassivesDisabled() then return nil end
		if self:GetParent() ~= event.unit then return end

		local count = 1
		if self:GetParent():IsRealHero() then 
			count = self:GetAbility():GetSpecialValueFor("hero_multiplier") 
		end
		for i=1,count do
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_necrolyte_heartstopper_aura_counter", {})
		end
	end

	function modifier_effect:OnIntervalThink()
		local ability = self:GetAbility()
		if not ability then return end
		if ability:IsNull() then return end
		local caster = self:GetCaster()
		if caster:PassivesDisabled() then return end
		local parent = self:GetParent()
		if not caster:IsAlive() or not parent:IsAlive() then return end

		local base_damage = ability:GetSpecialValueFor("base_damage")
		local modif = caster:FindModifierByName("modifier_mjz_necrolyte_reapers_scythe_ss_stacks")
		if modif then
			local ss_bonus_damage =  modif:GetStackCount() * modif:GetAbility():GetSpecialValueFor("ss_bonus_damage") * caster:GetLevel()
			base_damage = base_damage + ss_bonus_damage
			print(ss_bonus_damage .. " ss_bonus_damage")
		end
		local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage") * caster:GetIntellect(true)

		ApplyDamage({
			attacker = caster,
			victim = parent,
			ability = ability,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			damage = (base_damage + intelligence_damage) * ability:GetSpecialValueFor("interval")
		})
	end
end


-----------------------------------------------------------------------------------------

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

