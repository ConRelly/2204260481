--------------------------------------------------------------------------------
modifier_spectre_einherjar_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_spectre_einherjar_lua:IsHidden()
    return false
end

function modifier_spectre_einherjar_lua:IsDebuff()
    return false
end

function modifier_spectre_einherjar_lua:IsStunDebuff()
    return false
end

function modifier_spectre_einherjar_lua:IsPurgable()
    return false
end

function modifier_spectre_einherjar_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_spectre_einherjar_lua:OnCreated(kv)
    local agi_multiplier = self:GetAbility():GetSpecialValueFor("agi_multiplier")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.base_attack_bonus_damage = self:GetCaster():GetAgility() * agi_multiplier
    self.min_move_speed = 1000

    if not IsServer() then
        return
    end
    -- references
    self.current_target = nil

    -- Start interval
    self:StartIntervalThink(0.2)
    self:OnIntervalThink()
end

function modifier_spectre_einherjar_lua:OnRefresh(kv)
end

function modifier_spectre_einherjar_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_spectre_einherjar_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
    }

    return funcs
end

function modifier_spectre_einherjar_lua:GetModifierBaseAttack_BonusDamage()
    return self.base_attack_bonus_damage
end

function modifier_spectre_einherjar_lua:GetModifierMoveSpeed_AbsoluteMin()
    return self.min_move_speed
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_spectre_einherjar_lua:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }

    return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_spectre_einherjar_lua:OnIntervalThink()
    -- Check if there's a current target
    if self.current_target == nil or EntIndexToHScript(self.current_target) == nil then
        -- No current target, find one
        local caster = self:GetCaster()
        -- Find Units in Radius
        local enemies = FindUnitsInRadius(
                caster:GetTeamNumber(), -- int, your team number
                caster:GetOrigin(), -- point, center point
                caster, -- handle, cacheUnit. (not known)
                self.radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, -- int, flag filter
                FIND_CLOSEST, -- int, order filter
                false    -- bool, can grow cache
        )

        for _, enemy in pairs(enemies) do
            self:GetParent():SetForceAttackTarget(enemy) -- for creeps
            self:GetParent():MoveToTargetToAttack(enemy) -- for heroes
            self.current_target = enemy:entindex()
            break
        end
    else
        -- There is existing target, target it
        local target_enemy = EntIndexToHScript(self.current_target)
        if target_enemy:IsAlive() and not target_enemy:IsInvulnerable() then
            self:GetParent():SetForceAttackTarget(target_enemy) -- for creeps
            self:GetParent():MoveToTargetToAttack(target_enemy) -- for heroes
        else
            -- Target no longer alive
            self.current_target = nil
        end
    end
end

--------------------------------------------------------------------------------
-- Animation Effects
function modifier_spectre_einherjar_lua:GetStatusEffectName()
    return "particles/status_fx/status_effect_keeper_spirit_form.vpcf"
end

-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
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