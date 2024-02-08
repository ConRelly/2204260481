LinkLuaModifier( "modifier_thinker_cosmos_space_mist", "abilities/custom/cosmos_space_mist.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_cosmos_space_mist_debuff", "abilities/custom/cosmos_space_mist.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

cosmos_space_mist = class ( {})

function cosmos_space_mist:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local team_id = caster:GetTeamNumber()

        local thinker = CreateModifierThinker(caster, self, "modifier_thinker_cosmos_space_mist", {duration = self:GetSpecialValueFor("duration")}, point, team_id, false)
    end
end

modifier_thinker_cosmos_space_mist = class ({})

function modifier_thinker_cosmos_space_mist:OnCreated(event)
    if IsServer() then
        local nWarpFX = ParticleManager:CreateParticle ("particles/effects/charity_warp.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(nWarpFX, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(nWarpFX, 1, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(nWarpFX, 3, self:GetParent():GetAbsOrigin())
        self:AddParticle( nWarpFX, false, false, -1, false, true )

        EmitSoundOn("Hero_ShadowDemon.Disruption.Cast", self:GetParent())
    end
end

function modifier_thinker_cosmos_space_mist:OnDestroy()
    if IsServer() then

    end
end

function modifier_thinker_cosmos_space_mist:CheckState() return
    {[MODIFIER_STATE_PROVIDES_VISION] = true}
end

function modifier_thinker_cosmos_space_mist:IsAura()
    return true
end

function modifier_thinker_cosmos_space_mist:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_thinker_cosmos_space_mist:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_thinker_cosmos_space_mist:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_thinker_cosmos_space_mist:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_thinker_cosmos_space_mist:GetModifierAura()
    return "modifier_cosmos_space_mist_debuff"
end

modifier_cosmos_space_mist_debuff = class ( {})

function modifier_cosmos_space_mist_debuff:IsDebuff()
    return true
end

function modifier_cosmos_space_mist_debuff:OnCreated(event)

end


function modifier_cosmos_space_mist_debuff:GetEffectName()
    return "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_stifling_dagger_debuff_arcana.vpcf"
end

function modifier_cosmos_space_mist_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

function modifier_cosmos_space_mist_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_cosmos_space_mist_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow_pct") * (-1)
end

function modifier_cosmos_space_mist_debuff:GetModifierMagicalResistanceBonus( params )
    return self:GetAbility():GetSpecialValueFor( "magical_resistance_reduction" )* (-1)
end

function modifier_cosmos_space_mist_debuff:GetModifierMiss_Percentage()
    return self:GetAbility():GetSpecialValueFor("miss_chance")
end

