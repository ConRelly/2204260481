LinkLuaModifier("modifier_mjz_bloodseeker_thirst", "abilities/hero_bloodseeker/mjz_bloodseeker_thirst.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_bloodseeker_thirst_buff", "abilities/hero_bloodseeker/mjz_bloodseeker_thirst.lua", LUA_MODIFIER_MOTION_NONE)


mjz_bloodseeker_thirst = class({})
function mjz_bloodseeker_thirst:GetIntrinsicModifierName() return "modifier_mjz_bloodseeker_thirst" end

------------------------------------------------------------------------------------
if modifier_mjz_bloodseeker_thirst == nil then modifier_mjz_bloodseeker_thirst = class({}) end
function modifier_mjz_bloodseeker_thirst:IsHidden() return true end
function modifier_mjz_bloodseeker_thirst:IsPurgable() return false end
function modifier_mjz_bloodseeker_thirst:RemoveOnDeath() return false end
function modifier_mjz_bloodseeker_thirst:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_mjz_bloodseeker_thirst:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_EXECUTED} end
function modifier_mjz_bloodseeker_thirst:OnAbilityExecuted(keys)
	if IsServer() then
		local caster = self:GetCaster()
		using_items = keys.ability:IsItem()
		caster_allow = keys.unit == caster
		if caster:HasScepter() then
			if keys.unit == caster then
				using_items = nil
			end
		end
		if HasSuperScepter(caster) then
			caster_allow = true
			using_items = nil
		end
		if using_items or keys.ability:IsToggle() or caster:PassivesDisabled() then return nil end
		if caster_allow and caster:IsAlive() and not caster:IsIllusion() then
			local buff_duration = self:GetAbility():GetSpecialValueFor("duration")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_bloodseeker_thirst_buff", {duration = buff_duration})
		end
	end
end

------------------------------------------------------------------------------------
modifier_mjz_bloodseeker_thirst_buff = class({})
function modifier_mjz_bloodseeker_thirst_buff:IsHidden() return false end
function modifier_mjz_bloodseeker_thirst_buff:IsDebuff() return false end
function modifier_mjz_bloodseeker_thirst_buff:IsPurgable() return false end
function modifier_mjz_bloodseeker_thirst_buff:RemoveOnDeath() return false end
function modifier_mjz_bloodseeker_thirst_buff:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_thirst_owner.vpcf"
end
function modifier_mjz_bloodseeker_thirst_buff:OnCreated() if not IsServer() then return end self.stack_table = {} self:StartIntervalThink(1) self:SetStackCount(1) end
function modifier_mjz_bloodseeker_thirst_buff:OnStackCountChanged(prev_stacks)
	if not IsServer() then return end
	if not self:GetAbility() then self:Destroy() return end
	local parent = self:GetParent()
	local max_stacks = GetTalentSpecialValueFor(self:GetAbility(), "max_stacks")
	local ss_bonus_stacks = self:GetAbility():GetSpecialValueFor("ss_bonus_stacks")
	local has_ss = parent:HasModifier("modifier_super_scepter")
	if has_ss then max_stacks = max_stacks + ss_bonus_stacks end
	local stacks = self:GetStackCount()
	if stacks > max_stacks then
		table.remove(self.stack_table, 1)
		self:DecrementStackCount()
	end
	if stacks > prev_stacks then
		table.insert(self.stack_table, GameRules:GetGameTime())
	end
end
function modifier_mjz_bloodseeker_thirst_buff:OnIntervalThink()
	local repeat_needed = true
	local power_buff = self:GetAbility():GetSpecialValueFor("duration")
	while repeat_needed do
		local stacktimer = self.stack_table[1]
		if GameRules:GetGameTime() - stacktimer >= power_buff then
			if self:GetStackCount() == 1 then
				if not self:IsNull() then
					self:Destroy()
				end	
				break
			else
				table.remove(self.stack_table, 1)
				self:DecrementStackCount()
			end
		else
			repeat_needed = false
		end
	end
end
function modifier_mjz_bloodseeker_thirst_buff:OnRefresh() if not IsServer() then return end self:IncrementStackCount() end
function modifier_mjz_bloodseeker_thirst_buff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_mjz_bloodseeker_thirst_buff:GetModifierMoveSpeedBonus_Percentage() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
function modifier_mjz_bloodseeker_thirst_buff:GetModifierAttackSpeedBonus_Constant() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_mjz_bloodseeker_thirst_buff:GetModifierPreAttack_BonusDamage() return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("bonus_damage") * self:GetParent():GetLevel()) end
--
function modifier_mjz_bloodseeker_thirst_buff:GetModifierMoveSpeedBonus_Percentage()
    local ability = self:GetAbility()
    return ability and self:GetStackCount() * ability:GetSpecialValueFor("bonus_movement_speed")
end

function modifier_mjz_bloodseeker_thirst_buff:GetModifierAttackSpeedBonus_Constant()
    local ability = self:GetAbility()
    return ability and self:GetStackCount() * ability:GetSpecialValueFor("bonus_attack_speed")
end

function modifier_mjz_bloodseeker_thirst_buff:GetModifierPreAttack_BonusDamage()
    local ability = self:GetAbility()
	local parent = self:GetParent()
	local multipl = parent:GetLevel()
	local has_ss = parent:HasModifier("modifier_super_scepter")
	local ss_mult  = ability:GetSpecialValueFor("ss_lvl_mult")
	if has_ss then multipl = multipl * ss_mult end
    return ability and self:GetStackCount() * (ability:GetSpecialValueFor("bonus_damage") * multipl)
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