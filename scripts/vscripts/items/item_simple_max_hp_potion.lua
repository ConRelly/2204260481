
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
    self:SpendCharge(0.01)
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
    local parent = self:GetParent()
    
    if parent:GetUnitName() == "npc_dota_hero_pudge" then
        return 2 * parent:GetStrength()  
    end
    return 2 * parent:GetStrength() * (-1)
end


