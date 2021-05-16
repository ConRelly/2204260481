--------------------------------------------------------------------------------
modifier_maple_shield_lua_aura = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_maple_shield_lua_aura:IsHidden()
    return false
end

function modifier_maple_shield_lua_aura:IsDebuff()
    return false
end

function modifier_maple_shield_lua_aura:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_maple_shield_lua_aura:OnCreated(kv)
    -- references
end

function modifier_maple_shield_lua_aura:OnRefresh(kv)
    -- references
end

function modifier_maple_shield_lua_aura:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_maple_shield_lua_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return funcs
end

function modifier_maple_shield_lua_aura:GetModifierIncomingDamage_Percentage(params)
    if not IsServer() then
        return 0
    end

    -- get data
    local caster = self:GetCaster()
    local attacker = params.attacker

    -- shift damage to owner
    local damageTable = {
        attacker = attacker,
        damage = params.original_damage,
        damage_type = params.damage_type,
        victim = caster,
    }
    ApplyDamage(damageTable)

    -- Person takes no damage
    return -100
end