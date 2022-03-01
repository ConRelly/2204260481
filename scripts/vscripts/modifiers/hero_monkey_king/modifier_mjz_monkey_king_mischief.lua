LinkLuaModifier("modifier_mjz_monkey_king_mischief_transform","modifiers/hero_monkey_king/modifier_mjz_monkey_king_mischief_transform.lua", LUA_MODIFIER_MOTION_NONE)

local MAIN_ABILITY_NAME = 'mjz_monkey_king_mischief'
local SUB_ABILITY_NAME = 'mjz_monkey_king_untransform'
local MODIFIER_TRANSFORM_NAME = 'modifier_mjz_monkey_king_mischief_transform'

modifier_mjz_monkey_king_mischief = class({})
local modifier_class = modifier_mjz_monkey_king_mischief

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:CheckState()
    return {
        [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]				= true,
        [MODIFIER_STATE_LOW_ATTACK_PRIORITY] 		= true,	
    }
end

if IsServer() then
    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, ability, MODIFIER_TRANSFORM_NAME, {})
    end

    function modifier_class:OnDestroy()
        self:Exposed()
    end

    function modifier_class:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_START,
            MODIFIER_EVENT_ON_TAKEDAMAGE,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }
    end

    function modifier_class:OnAttackStart( keys )
        if keys.attacker == self:GetParent() then
            if self:IsNull() then return end
            self:Destroy()
        end
    end
    
    function modifier_class:OnTakeDamage( keys )	
        if keys.unit == self:GetParent() or keys.attacker == self:GetParent() then
            if self:IsNull() then return end
            self:Destroy()
        end
    end
    
    function modifier_class:OnAbilityFullyCast( keys )
        if keys.unit == self:GetParent() then
            if keys.ability:GetAbilityName() ~= MAIN_ABILITY_NAME then
                if self:IsNull() then return end
                self:Destroy() 
            end
        end
    end

    function modifier_class:Exposed()
        local caster = self:GetCaster()
        local parent = self:GetParent()

        RemoveModifierByName(parent, MODIFIER_TRANSFORM_NAME)

        -- Swap sub_ability
        caster:SwapAbilities( SUB_ABILITY_NAME, MAIN_ABILITY_NAME, false, true )
    end
end

-----------------------------------------------------------------------------------------

function RemoveModifierByName(unit, modifier_name )
    if unit:HasModifier(modifier_name) then
        unit:RemoveModifierByName(modifier_name)
    end
end