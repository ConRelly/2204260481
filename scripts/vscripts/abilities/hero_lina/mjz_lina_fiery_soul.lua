LinkLuaModifier("modifier_mjz_lina_fiery_soul_buff", "modifiers/hero_lina/modifier_mjz_lina_fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lina_fiery_soul", "abilities/hero_lina/mjz_lina_fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)

mjz_lina_fiery_soul = class({})

function mjz_lina_fiery_soul:GetIntrinsicModifierName()
	return "modifier_mjz_lina_fiery_soul"
end

function mjz_lina_fiery_soul:GetAbilityTextureName()
    if self:GetCaster():HasScepter() then
        return "mjz_lina_fiery_soul_arcana"
    end
    return "mjz_lina_fiery_soul"
end

--------------------------------------------------------------------------------

modifier_mjz_lina_fiery_soul = class({})

function modifier_mjz_lina_fiery_soul:IsHidden() return true end
function modifier_mjz_lina_fiery_soul:IsPurgable() return false end

if IsServer() then
    function modifier_mjz_lina_fiery_soul:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        }
        return funcs 
    end

    function modifier_mjz_lina_fiery_soul:OnAbilityExecuted(params)
        if params.unit ~= self:GetParent() then return nil end
        if params.ability and params.ability:IsItem() then return nil end

        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local max_stacks = ability:GetSpecialValueFor('max_stacks')
        local stack_duration = ability:GetSpecialValueFor('stack_duration')
        local buff_name = 'modifier_mjz_lina_fiery_soul_buff'

        if not caster:HasModifier(buff_name) then
            caster:AddNewModifier(caster, ability, buff_name, {})            
        end

        local modifier_buff = caster:FindModifierByName(buff_name)
        local buff_stacks = modifier_buff:GetStackCount()
        if buff_stacks < max_stacks then
            buff_stacks = buff_stacks + 1
        end

        modifier_buff:SetStackCount(buff_stacks)
        modifier_buff:SetDuration(stack_duration, true)
        modifier_buff:ForceRefresh()
    end
end

--------------------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end


function SetModifierStackCount(owner, ability, modifier_name, count, duration)
    if not owner:HasModifier(modifier_name) then
        owner:AddNewModifier(owner, ability, modifier_name, {duration = duration})            
    end
    owner:SetModifierStackCount(modifier_name, owner, count)  
end