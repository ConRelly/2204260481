modifier_sniper_headshot_lua_slow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sniper_headshot_lua_slow:IsHidden()
    return false
end

function modifier_sniper_headshot_lua_slow:IsDebuff()
    return true
end

function modifier_sniper_headshot_lua_slow:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sniper_headshot_lua_slow:OnCreated(kv)
    self.slow = self:GetAbility():GetSpecialValueFor("slow") -- special value
    if IsServer() then
        -- effects
        local sound_cast = "Hero_Sniper.HeadShot"
        EmitSoundOn(sound_cast, self:GetParent())
    end
end

function modifier_sniper_headshot_lua_slow:OnRefresh(kv)
end

function modifier_sniper_headshot_lua_slow:OnDestroy(kv)

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sniper_headshot_lua_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end
function modifier_sniper_headshot_lua_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_sniper_headshot_lua_slow:GetEffectName()
    return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function modifier_sniper_headshot_lua_slow:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end