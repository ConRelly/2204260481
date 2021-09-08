modifier_legion_commander_duel_lua = class({})

--------------------------------------------------------------------------------
function modifier_legion_commander_duel_lua:IsHidden()
    return false
end

function modifier_legion_commander_duel_lua:IsDebuff()
    return false
end

function modifier_legion_commander_duel_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_legion_commander_duel_lua:OnCreated(kv)
    if self:GetParent():IsIllusion() then return end
    if IsValidEntity(self:GetAbility()) and not self:GetAbility():IsNull() then
        self.damage_bonus = self:GetAbility():GetSpecialValueFor("damage_bonus")
        self.str_multiplier = self:GetAbility():GetSpecialValueFor("str_multiplier")
        if IsServer() then    
            self:SetStackCount(self:GetAbility():GetDuelKills())
            
        end
    end    
end

--------------------------------------------------------------------------------

function modifier_legion_commander_duel_lua:OnRefresh(kv)
    if self:GetParent():IsIllusion() then return end
    self.damage_bonus = self:GetAbility():GetSpecialValueFor("damage_bonus")
    self.str_multiplier = self:GetAbility():GetSpecialValueFor("str_multiplier")
end

--------------------------------------------------------------------------------

function modifier_legion_commander_duel_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return funcs
end

function modifier_legion_commander_duel_lua:OnDeath(event)
    if self:GetParent():IsIllusion() then return end
    if IsServer() then
        if event.unit == nil or event.attacker == nil or event.unit:IsNull() or event.attacker:IsNull() then
            return
        end
        local caster = self:GetCaster()
		local target = event.target
		if target == nil then target = event.unit end    
        if event.attacker:GetTeamNumber() == caster:GetTeamNumber() and caster:GetTeamNumber() ~= target:GetTeamNumber() and caster:IsAlive() and not caster:PassivesDisabled() then
       -- if event.unit:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and self:GetParent():IsAlive() and not self:GetParent():PassivesDisabled() then
            local ability = self:GetAbility()
            local chance = GetTalentSpecialValueFor(ability, "stack_chance")
            if RollPercentage(chance) then
                self:GetAbility():IncrementDuelKills()

                self:SetStackCount(self:GetAbility():GetDuelKills())

                local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
                ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
                ParticleManager:ReleaseParticleIndex(nFXIndex)
            end    
        end
    end   
end

--------------------------------------------------------------------------------

function modifier_legion_commander_duel_lua:GetModifierPreAttack_BonusDamage(params)
    if not self:GetParent():PassivesDisabled() and not self:GetParent():IsIllusion() then
        return self:GetStackCount() * self.damage_bonus + self:GetStackCount() * self.str_multiplier * self:GetParent():GetStrength()
    end

    return 0
end

--------------------------------------------------------------------------------

-- talents
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