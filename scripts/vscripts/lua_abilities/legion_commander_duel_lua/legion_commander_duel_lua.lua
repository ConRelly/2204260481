LinkLuaModifier("modifier_legion_commander_duel_lua", "lua_abilities/legion_commander_duel_lua/legion_commander_duel_lua", LUA_MODIFIER_MOTION_NONE)


legion_commander_duel_lua = class({})
function legion_commander_duel_lua:GetIntrinsicModifierName() return "modifier_legion_commander_duel_lua" end

--------------------------------------------------------------------------------

modifier_legion_commander_duel_lua = class({})
function modifier_legion_commander_duel_lua:IsHidden() return self:GetStackCount() < 1 end
function modifier_legion_commander_duel_lua:IsPurgable() return false end
function modifier_legion_commander_duel_lua:AllowIllusionDuplicate() return false end
function modifier_legion_commander_duel_lua:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end
function modifier_legion_commander_duel_lua:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		local modifier = "modifier_legion_commander_duel_lua"
		if parent:HasModifier(modifier) then
			local time = GameRules:GetGameTime() / 60
			if time > 1 then
				local mbuff = parent:FindModifierByName(modifier)
				local stack = math.floor(time / 2)
				--random 25% for a double stack
				if RollPercentage(25) then
					stack = stack * 2
				end
				mbuff:SetStackCount(stack)
			end
		end
	end
end	

function modifier_legion_commander_duel_lua:OnDeath(event)
	if IsServer() then
		local caster = self:GetCaster()
		local target = event.target
		if caster:IsIllusion() then return end
		if caster:PassivesDisabled() then return end
		if not caster:IsAlive() then return end
		if event.unit == nil or event.attacker == nil or event.unit:IsNull() or event.attacker:IsNull() then return end
		if target == nil then target = event.unit end	
		if event.attacker:GetTeamNumber() == caster:GetTeamNumber() and caster:GetTeamNumber() ~= target:GetTeamNumber() then
			local chance = GetTalentSpecialValueFor(self:GetAbility(), "stack_chance")
			if RollPercentage(chance) then
				self:SetStackCount(self:GetStackCount() + 1)

				local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
				ParticleManager:ReleaseParticleIndex(nFXIndex)
			end	
		end
	end   
end
function modifier_legion_commander_duel_lua:GetModifierPreAttack_BonusDamage(params)
	if self:GetParent():PassivesDisabled() then return end
	if self:GetParent():IsIllusion() then return end

	local BonusDamage = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_bonus")
	local DamagePerStr = self:GetStackCount() * self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multiplier")
	return BonusDamage + DamagePerStr
end

--------------------------------------------------------------------------------

-- talents
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