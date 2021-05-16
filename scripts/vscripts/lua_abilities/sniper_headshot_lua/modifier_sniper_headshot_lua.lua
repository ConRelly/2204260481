modifier_sniper_headshot_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sniper_headshot_lua:IsHidden()
    return true
end

function modifier_sniper_headshot_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sniper_headshot_lua:OnCreated(kv)
    -- references
    self.proc_chance = self:GetAbility():GetSpecialValueFor("proc_chance") -- special value
    self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration") -- special value
    --self.agi_multiplier = self:GetAbility():GetTalentSpecialValueFor("agi_multiplier") -- special value
    self.knockback_distance = self:GetAbility():GetSpecialValueFor("knockback_distance")
    self.knockback_agi_multiplier = self:GetAbility():GetSpecialValueFor("knockback_agi_multiplier")
end

function modifier_sniper_headshot_lua:OnRefresh(kv)
    -- references
    self:OnCreated(kv)
end

function modifier_sniper_headshot_lua:OnDestroy(kv)

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sniper_headshot_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }

    return funcs
end

function modifier_sniper_headshot_lua:GetModifierPreAttack_BonusDamage(params)
    if IsServer() and not self:GetParent():PassivesDisabled() then
        -- roll dice
        if RandomInt(1, 100) <= self.proc_chance then
            local attackerAgility = self:GetParent():GetAgility()
            -- Talent Tree
            local agi_multiplier = self:GetAbility():GetTalentSpecialValueFor("agi_multiplier")
            local special_take_aim_agi_multiplier_lua = self:GetParent():FindAbilityByName("special_take_aim_agi_multiplier_lua")
            if special_take_aim_agi_multiplier_lua and special_take_aim_agi_multiplier_lua:GetLevel() ~= 0 then
                agi_multiplier = agi_multiplier + special_take_aim_agi_multiplier_lua:GetSpecialValueFor("value")
            end
            local headshotDamage = self:GetAbility():GetAbilityDamage() + (attackerAgility * agi_multiplier)
            --[[params.target:AddNewModifier(
                    self:GetParent(), -- player source
                    self:GetAbility(), -- ability source
                    "modifier_sniper_headshot_lua_slow", -- modifier name
                    {
                        duration = self.slow_duration,
                    } -- kv
            )
            -- Talent Tree
            local special_headshot_silence_lua = self:GetParent():FindAbilityByName("special_headshot_silence_lua")
            if special_headshot_silence_lua and special_headshot_silence_lua:GetLevel() ~= 0 then
                local silence_duration = special_headshot_silence_lua:GetSpecialValueFor("value")
                params.target:AddNewModifier(
                        self:GetParent(), -- player source
                        self:GetAbility(), -- ability source
                        "modifier_generic_silenced_lua", -- modifier name
                        {
                            duration = silence_duration,
                        } -- kv
                )
            end]]

            --[[local enemyOrigin = params.target:GetOrigin()
            local attackerOrigin = self:GetParent():GetOrigin()

            -- knockback
            params.target:AddNewModifier(
                    self:GetParent(), -- player source
                    self:GetAbility(), -- ability source
                    "modifier_generic_knockback_lua", -- modifier name
                    {
                        duration = self.slow_duration,
                        distance = self.knockback_distance + (attackerAgility * self.knockback_agi_multiplier),
                        height = 30,
                        direction_x = enemyOrigin.x - attackerOrigin.x,
                        direction_y = enemyOrigin.y - attackerOrigin.y,
                    } -- kv
            )]]
            return headshotDamage
        end
    end
end

