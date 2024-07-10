
LinkLuaModifier("modifier_force_max_hp", "items/item_simple_max_hp_potion.lua", LUA_MODIFIER_MOTION_NONE)

if item_simple_max_hp_potion == nil then
    item_simple_max_hp_potion = class({})
end

function item_simple_max_hp_potion:OnSpellStart()
    local caster = self:GetCaster()
    local modiff = "modifier_force_max_hp"
    if caster:HasModifier(modiff) then
        caster:RemoveModifierByName(modiff)
    else
        caster:AddNewModifier(caster, self, modiff, {})
    end    
    self:SpendCharge()
end


if modifier_force_max_hp == nil then
    modifier_force_max_hp = class({})
end

function modifier_force_max_hp:IsHidden()
    return false
end

function modifier_force_max_hp:IsDebuff()
    return false
end

function modifier_force_max_hp:IsPurgable()
    return false
end

function modifier_force_max_hp:RemoveOnDeath()
    return false
end
function modifier_force_max_hp:GetTexture()
    return "greater_salve2"
end

function modifier_force_max_hp:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
    return funcs
end

function modifier_force_max_hp:GetModifierHealthBonus()
    return 2 * self:GetParent():GetStrength() * (-1)
end


