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

	function ability_class:_TargetInNearby( target )
		local caster = self:GetCaster()
		
		local attack_range = caster:Script_GetAttackRange()
		local distance = self:CalcDistanceBetween(target, caster)
		if distance <= attack_range then
			return true
		else
			return false
		end
	end

	-- 计算两个实体之间的距离
	function ability_class:CalcDistanceBetween( target, caster)
		local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
		local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
		return (target_loc - caster_loc):Length2D()
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

    function modifier_class:OnAttackStart(keys)
        if keys.attacker ~= self:GetParent() then return nil end

		local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
		local target = keys.target
		
		self.last_attack_target = target
		self.last_attack_time = GameRules:GetGameTime()

    end

--[[
    function modifier_class:OnAttackLanded(keys)
		if not IsServer() then return end
        local parent = self:GetParent()
		local target = keys.target
		if not parent:HasTalent("special_bonus_unique_mjz_windrunner_focusfire_ministun") then return end
        if keys.attacker ~= parent then return end

		local ministun_chance = parent:FindTalentCustomValue("special_bonus_unique_mjz_windrunner_focusfire_ministun", "ministun_chance")
		local ministun_duration = parent:FindTalentCustomValue("special_bonus_unique_mjz_windrunner_focusfire_ministun", "ministun_duration")
		local focusfire_target = self:GetAbility():GetFocusfireTarget()
		
		if target == focusfire_target then
			if RollPercentage(ministun_chance) then
				target:AddNewModifier(parent, self:GetAbility(), "modifier_stunned", {duration = ministun_duration})
			end
		end
	end
]]

	function modifier_class:OnCreated()
		local parent = self:GetParent()
		
		self.last_attack_target = nil
		self.last_attack_time = 0
		self.on_PerformAttack = false

		if not parent:HasModifier(MODIFIER_BUFF_NAME) then
			parent:AddNewModifier(self:GetCaster(), self:GetAbility(), MODIFIER_BUFF_NAME, {})
		end
		if not parent:HasModifier(MODIFIER_DEBUFF_NAME) then
			parent:AddNewModifier(self:GetCaster(), self:GetAbility(), MODIFIER_DEBUFF_NAME, {})
		end

		-- self:StartIntervalThink(0.05)
		self:StartIntervalThink( math.max( 0.31, ( parent:GetLastAttackTime( ) - GameRules:GetGameTime() ) + parent:GetSecondsPerAttack() ) )
	end

	function modifier_class:OnRefresh(table)
		ForceRefreshModifier(self:GetParent(), MODIFIER_BUFF_NAME)
		ForceRefreshModifier(self:GetParent(), MODIFIER_DEBUFF_NAME)
	end

	function modifier_class:OnIntervalThink()
		if not IsServer() then return end
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if not ability ~= nil and not IsValidEntity(ability) then
			if self:IsNull() then return end
			self:Destroy()
			return
		end
		if ability:GetFocusfireTarget() == nil then return end
		local focusfire_target = ability:GetFocusfireTarget()
		local can_PerformAttack = false

		if focusfire_target == nil then return end
		if not IsValidEntity(focusfire_target) then return end
		if not focusfire_target:IsAlive() then return end

		-- if self.on_PerformAttack then
		-- 	can_PerformAttack = false
		-- else
		-- 	if (GameRules:GetGameTime() - self.last_attack_time) > 0.25 then
		-- 		can_PerformAttack = ability:_TargetInNearby(focusfire_target)
		-- 	end
		-- end
		can_PerformAttack = true

		if can_PerformAttack then
			self.on_PerformAttack = true
			parent:PerformAttack (focusfire_target, true, true, true, true, true, false, false)

			-- self:_SetForwardVector(focusfire_target)
		else
			self.on_PerformAttack = false
		end
		
		self:StartIntervalThink( parent:GetSecondsPerAttack( ) - 0.03 )
	end
	
	function modifier_class:OnDestroy()
        local parent = self:GetParent()

		if IsValidEntity(parent) then
			parent:RemoveGesture(ACT_DOTA_ATTACK)
			parent:RemoveModifierByName(MODIFIER_BUFF_NAME)
			parent:RemoveModifierByName(MODIFIER_DEBUFF_NAME)
		end
	end

	function modifier_class:_OnAttackTarget( target )
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local focusfire_target = ability:GetFocusfireTarget()
		
		if target ~= focusfire_target then
			RemoveModifierByName(parent, MODIFIER_BUFF_NAME)
			RemoveModifierByName(parent, MODIFIER_DEBUFF_NAME)
		else
			if not parent:HasModifier(MODIFIER_BUFF_NAME) then
				parent:AddNewModifier(caster, ability, MODIFIER_BUFF_NAME, {})
			end
			if not parent:HasModifier(MODIFIER_DEBUFF_NAME) then
				parent:AddNewModifier(caster, ability, MODIFIER_DEBUFF_NAME, {})
			end
		end
	end

	function modifier_class:_SetForwardVector( focusfire_target )
		local parent = self:GetParent()
		
		local NOW = GameRules:GetGameTime()
		self.prev_setfv = self.prev_setfv or 0
		if (NOW - self.prev_setfv) > 0.25 then
			self.prev_setfv = NOW
			parent:SetForwardVector( self:CalculateDirection(focusfire_target, parent) )
			-- parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.7 / parent:GetAttackSpeed())
		end
	end

	function modifier_class:CalculateDirection(ent1, ent2)
		local pos1 = ent1
		local pos2 = ent2
		if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
		if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
		local direction = (pos1 - pos2):Normalized()
		direction.z = 0
		return direction
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
function modifier_buff:OnRefresh()
	self:OnCreated()
end

function modifier_buff:DeclareFunctions() 
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} 
end

function modifier_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end

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
function modifier_debuff:OnRefresh()
	self:OnCreated()
end

function modifier_debuff:DeclareFunctions() 
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} 
end

function modifier_debuff:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount()
end

-----------------------------------------------------------------------------------------

function ForceRefreshModifier( unit, modifier_name )
	if unit then
		local m = unit:FindModifierByName(modifier_name)
		if m then m:ForceRefresh() end
	end
end

function NewModifierByName(unit, modifier_name )
	if unit and IsValidEntity(unit) then
		if unit:HasModifier(modifier_name) then
			unit:RemoveModifierByName(modifier_name)
		end
	end
end

function RemoveModifierByName(unit, modifier_name )
	if unit and IsValidEntity(unit) then
		if unit:HasModifier(modifier_name) then
			unit:RemoveModifierByName(modifier_name)
		end
	end
end

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