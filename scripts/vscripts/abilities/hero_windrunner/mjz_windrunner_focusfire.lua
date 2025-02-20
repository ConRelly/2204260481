local MODIFIER_CASTER_NAME = "modifier_mjz_windrunner_focusfire" 
local MODIFIER_BUFF_NAME = "modifier_mjz_windrunner_focusfire_attackspeed_buff" 
local MODIFIER_DEBUFF_NAME = "modifier_mjz_windrunner_focusfire_damage_debuff" 

LinkLuaModifier(MODIFIER_CASTER_NAME, "abilities/hero_windrunner/mjz_windrunner_focusfire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_BUFF_NAME, "abilities/hero_windrunner/mjz_windrunner_focusfire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_DEBUFF_NAME, "abilities/hero_windrunner/mjz_windrunner_focusfire", LUA_MODIFIER_MOTION_NONE)


mjz_windrunner_focusfire = class({})
local ability_class = mjz_windrunner_focusfire

function ability_class:GetCastRange(vLocation, hTarget)
	-- return self.BaseClass.GetCastRange(self, vLocation, hTarget) 
	return self:GetCaster():Script_GetAttackRange()
end

function ability_class:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cooldown_scepter")
	end
    return self.BaseClass.GetCooldown(self, iLevel)
end

if IsServer() then
	function ability_class:OnSpellStart()
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		if self:GetCaster():HasScepter() then
			duration = self:GetSpecialValueFor("duration_scepter")
		end

--		local modifier = caster:FindModifierByName(MODIFIER_CASTER_NAME)
--		if modifier then
--			modifier:SetDuration(duration, true)
--			modifier:ForceRefresh()
--		else
			caster:AddNewModifier(caster, self, MODIFIER_CASTER_NAME, {duration = duration})
--		end
		
		EmitSoundOn("Ability.Focusfire", caster)
	end

	function ability_class:GetFocusfireTarget()
		local caster = self:GetCaster()

		local at = caster:GetAttackTarget()
		if at and at == self.focusfire_target then
			return at
		end
		if at and IsValidEntity(at) and at:GetTeam() ~= caster:GetTeam() then
			self.focusfire_target = at
			return at
		else
			local focusfire_target = self.focusfire_target
			if focusfire_target and IsValidEntity(focusfire_target) then
				if self:_TargetInNearby(focusfire_target) then
					return focusfire_target
				end
			end
		end

		local radius = caster:Script_GetAttackRange()
		local re = caster:FindRandomEnemyInRadius(caster:GetAbsOrigin(), radius)
		return re
	end

	function ability_class:_TargetInNearby(target)
		local caster = self:GetCaster()
		if caster and target and not target:IsNull() then
			local attack_range = caster:Script_GetAttackRange()
			local distance = CalcDistanceBetweenEntityOBB(target, caster)

			local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
			local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
			local distance = (target_loc - caster_loc):Length2D()

			if distance <= attack_range then
				return true
			else
				return false
			end
		end	
		return false
	end
end



---------------------------------------------------------------------------------------

modifier_mjz_windrunner_focusfire = class({})
local modifier_class = modifier_mjz_windrunner_focusfire

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK,
		--MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
end
function modifier_class:GetActivityTranslationModifiers() return "focusfire" end

if IsServer() then
	function modifier_class:OnCreated()
		local parent = self:GetParent()
		
		self.last_attack_target = nil

		parent:AddNewModifier(self:GetCaster(), self:GetAbility(), MODIFIER_BUFF_NAME, {})
		parent:AddNewModifier(self:GetCaster(), self:GetAbility(), MODIFIER_DEBUFF_NAME, {})

		self:StartIntervalThink(parent:GetSecondsPerAttack(false)) -- false/true is for ignoring temporary attack speed buff. GetSecondsPerAttack(ignoreTempAttackSpeed: bool): float
	end

	function modifier_class:OnRefresh(table)
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), MODIFIER_BUFF_NAME, {})
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), MODIFIER_DEBUFF_NAME, {})
	end

    function modifier_class:OnAttackStart(keys)
        if keys.attacker ~= self:GetParent() then return end
		self.last_attack_target = keys.target
    end

	function modifier_class:OnIntervalThink()
		if not IsServer() then return end
		local ability = self:GetAbility()
		if not ability ~= nil and not IsValidEntity(ability) then
			if self:IsNull() then return end
			self:Destroy()
			return
		end

		local target = ability:GetFocusfireTarget()

		if target == nil then return end
		if not IsValidEntity(target) then return end
		if not target:IsAlive() then return end

		self:GetParent():PerformAttack(target, true, true, true, true, true, false, false)
		
		self:StartIntervalThink(self:GetParent():GetSecondsPerAttack(false) - 0.03)
	end
	
	function modifier_class:OnDestroy()
        local parent = self:GetParent()

		if IsValidEntity(parent) then
			parent:RemoveModifierByName(MODIFIER_BUFF_NAME)
			parent:RemoveModifierByName(MODIFIER_DEBUFF_NAME)
		end
	end
end


---------------------------------------------------------------------------------------

modifier_mjz_windrunner_focusfire_attackspeed_buff = class({})
local modifier_buff = modifier_mjz_windrunner_focusfire_attackspeed_buff
function modifier_buff:IsHidden() return true end
function modifier_buff:IsPurgable() return false end
function modifier_buff:OnCreated()
	self:SetStackCount(self:GetAbility():GetSpecialValueFor("bonus_attack_speed"))
end
function modifier_buff:OnRefresh() self:OnCreated() end
function modifier_buff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_buff:GetModifierAttackSpeedBonus_Constant() return self:GetStackCount() end

---------------------------------------------------------------------------------------

modifier_mjz_windrunner_focusfire_damage_debuff = class({})
local modifier_debuff = modifier_mjz_windrunner_focusfire_damage_debuff
function modifier_debuff:IsHidden() return true end
function modifier_debuff:IsPurgable() return false end
function modifier_debuff:OnCreated()
	if not IsServer() then return end
	if self:GetCaster():HasScepter() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("damage_reduction_scepter"))
	else
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("damage_reduction"))
	end
end
function modifier_debuff:OnRefresh() self:OnCreated() end
function modifier_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} end
function modifier_debuff:GetModifierDamageOutgoing_Percentage() return self:GetStackCount() end

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
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end