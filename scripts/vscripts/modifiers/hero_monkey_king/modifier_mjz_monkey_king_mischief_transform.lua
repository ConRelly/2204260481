
require("modifiers/hero_monkey_king/model_list")

LinkLuaModifier("modifier_mjz_monkey_king_mischief_flying","modifiers/hero_monkey_king/modifier_mjz_monkey_king_mischief_transform.lua", LUA_MODIFIER_MOTION_NONE)

local DEFAULT_MODEL = "models/props_gameplay/treasure_chest001.vmdl"

-----------------------------------------------------------------------------------------

modifier_mjz_monkey_king_mischief_transform = class({})
local modifier_transform = modifier_mjz_monkey_king_mischief_transform

function modifier_transform:IsHidden() return true end
function modifier_transform:IsPurgable() return false end

function modifier_transform:GetEffectName()
	return "particles/units/heroes/hero_monkey_king/monkey_king_disguise.vpcf"
end

function modifier_transform:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        -- MODIFIER_PROPERTY_MOVESPEED_MAX,
        -- MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
end

function modifier_transform:GetModifierModelChange()
    local model_index = self:GetStackCount()
    local model = MODEL_LIST[model_index]
    if model then
        return model
    else
        return DEFAULT_MODEL
    end
end

function modifier_transform:GetModifierMoveSpeed_Absolute( params )
    return self:GetAbility():GetSpecialValueFor('movespeed')
end

-- function modifier_transform:GetModifierMoveSpeed_Max( params )
--     return self:GetAbility():GetSpecialValueFor('movespeed')
-- end

-- function modifier_transform:GetModifierMoveSpeed_Limit( params )
--     return self:GetAbility():GetSpecialValueFor('movespeed')
-- end

if IsServer() then
    function modifier_transform:OnCreated(table)
        local ability = self:GetAbility()
        local model_index = ability._model_index or 0

        if ability:GetAutoCastState() == false then
            model_index = model_index + 1
        end

        if model_index > #MODEL_LIST then
            model_index = 1
        end

        ability._model_index = model_index
        self:SetStackCount(model_index)
    end

    function modifier_transform:OnDestroy()
        self:Exposed()
    end


    function modifier_transform:Exposed()
        local parent = self:GetParent()

        RemoveModifierByName(parent, "modifier_mjz_monkey_king_mischief_flying")

        -- Play the Mischief particle effect again
        local poof = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_disguise.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(poof, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(poof)
    end
end

-----------------------------------------------------------------------------------------

modifier_mjz_monkey_king_mischief_flying = class({})
local modifier_flying = modifier_mjz_monkey_king_mischief_flying

function modifier_flying:IsHidden() return true end
function modifier_flying:IsPurgable() return false end

function modifier_flying:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = true,
    }
end

-----------------------------------------------------------------------------------------

function RemoveModifierByName(unit, modifier_name )
    if unit:HasModifier(modifier_name) then
        unit:RemoveModifierByName(modifier_name)
    end
end