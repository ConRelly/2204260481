modifier_sniper_shrapnel_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sniper_shrapnel_lua:IsHidden()
    return false
end

function modifier_sniper_shrapnel_lua:IsDebuff()
    return true
end

function modifier_sniper_shrapnel_lua:IsPurgable()
    return false
end

function modifier_sniper_shrapnel_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sniper_shrapnel_lua:OnCreated(kv)
    -- references
    self.caster = self:GetCaster()
    
    self.ms_slow = self:GetAbility():GetSpecialValueFor("slow_movement_speed") -- special value

    local interval = 1

    if IsServer() then
        local agi_mult = self:GetAbility():GetTalentSpecialValueFor("agi_multiplier")
        -- Talent Tree
        self.damage = self:GetAbility():GetSpecialValueFor("shrapnel_damage") + (self.caster:GetAgility() * agi_mult) -- special value
        -- precache damage
        self.damageTable = {
            victim = self:GetParent(),
            attacker = self.caster,
            damage = self.damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility(), --Optional.
        }

        -- start interval
        self:StartIntervalThink(interval)
        self:OnIntervalThink()
    end
end

function modifier_sniper_shrapnel_lua:OnRefresh(kv)

end

function modifier_sniper_shrapnel_lua:OnDestroy(kv)

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sniper_shrapnel_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end
function modifier_sniper_shrapnel_lua:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_slow
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_sniper_shrapnel_lua:OnIntervalThink()
    ApplyDamage(self.damageTable)
end

