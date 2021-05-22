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
function modifier_mjz_bloodseeker_thirst:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_mjz_bloodseeker_thirst:OnAttackLanded(keys)
	if keys.attacker == self:GetParent() and self:GetParent():IsAlive() and not self:GetParent():IsIllusion() and self:GetParent():GetTeamNumber() ~= keys.target:GetTeamNumber() and RollPseudoRandom(self:GetAbility():GetSpecialValueFor("stack_chance"), self:GetAbility()) then
		local power_buff = self:GetAbility():GetSpecialValueFor("duration")
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_bloodseeker_thirst_buff", {duration = power_buff})
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
	local max_stacks = GetTalentSpecialValueFor(self:GetAbility(), "max_stacks")
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
		local item_time = self.stack_table[1]
		if GameRules:GetGameTime() - item_time >= power_buff then
			if self:GetStackCount() == 1 then
				self:Destroy()
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
function modifier_mjz_bloodseeker_thirst_buff:GetModifierPreAttack_BonusDamage() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_damage") end

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