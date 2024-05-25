custom_thrist_like = class({})
LinkLuaModifier("modifier_custom_thrist_like", "abilities/custom_thrist_like", LUA_MODIFIER_MOTION_NONE)

function custom_thrist_like:GetIntrinsicModifierName()
    return "modifier_custom_thrist_like"
end

modifier_custom_thrist_like = class({})

function modifier_custom_thrist_like:IsHidden()
    return true
end

function modifier_custom_thrist_like:IsDebuff()
    return false
end

function modifier_custom_thrist_like:IsPurgable()
    return false
end
function modifier_custom_thrist_like:RemoveOnDeath()
    return false
end

function modifier_custom_thrist_like:OnCreated(kv)
    if IsServer() then
        self:StartIntervalThink(1.0)
    end
end

function modifier_custom_thrist_like:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        local teamNumber = caster:GetTeamNumber()
        local heroes = FindUnitsInRadius(
            teamNumber,
            Vector(0, 0, 0),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false
        )

        for _, hero in ipairs(heroes) do
            AddFOWViewer(teamNumber, hero:GetAbsOrigin(), 1800, 2.0, false)
        end
    end
end

function modifier_custom_thrist_like:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
    }
    return funcs
end

function modifier_custom_thrist_like:GetModifierIgnoreMovespeedLimit(params)
    return 1
end
