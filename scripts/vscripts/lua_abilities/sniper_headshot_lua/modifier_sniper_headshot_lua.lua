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
    if self:GetAbility() then
        self.proc_chance = self:GetAbility():GetSpecialValueFor("proc_chance") -- special value
        if self:GetParent():HasModifier("modifier_super_scepter") then
            self.proc_chance = self:GetAbility():GetSpecialValueFor("proc_chance") + self:GetAbility():GetSpecialValueFor("bonus_proc_chance")
        else
            self:StartIntervalThink(10)    
        end 
        self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration") -- special value
        --self.agi_multiplier = self:GetAbility():GetTalentSpecialValueFor("agi_multiplier") -- special value
        self.knockback_distance = self:GetAbility():GetSpecialValueFor("knockback_distance")
        self.knockback_agi_multiplier = self:GetAbility():GetSpecialValueFor("knockback_agi_multiplier")
        
    end    
end

function modifier_sniper_headshot_lua:OnRefresh(kv)
    -- references
    self:OnCreated(kv)
end

function modifier_sniper_headshot_lua:OnDestroy(kv)

end

function modifier_sniper_headshot_lua:OnIntervalThink()
    if self and not self:IsNull() and self:GetAbility() then
        self:OnCreated(kv)  -- just so Super scepter chance gets updated in case is activated after max lvl.
    end    
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
    if IsServer() and not self:GetParent():PassivesDisabled() and self:GetAbility() then
        -- roll dice
        if RandomInt(1, 100) <= self.proc_chance then
            local attackerAgility = self:GetParent():GetAgility()
            local parent = self:GetParent()
            local bonus_agi_mult = 0
            if parent:HasModifier("modifier_super_scepter") then
                bonus_agi_mult = parent:GetLevel()
            end   
            local agi_multiplier = self:GetAbility():GetSpecialValueFor("agi_multiplier") + talent_value(self:GetParent(), "special_bonus_unique_sniper_headshot_lua_agi_multiplier") + bonus_agi_mult
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

