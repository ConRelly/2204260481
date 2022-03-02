require("lib/my")

LinkLuaModifier("modifier_item_speed_orb_consumed", "items/consumables.lua", LUA_MODIFIER_MOTION_NONE)



modifier_item_speed_orb_consumed = modifier_item_speed_orb_consumed or class({})

function modifier_item_speed_orb_consumed:IsPermanent() return true end
function modifier_item_speed_orb_consumed:RemoveOnDeath() return false end
function modifier_item_speed_orb_consumed:IsHidden() return false end 	
function modifier_item_speed_orb_consumed:IsDebuff() return false end 	
function modifier_item_speed_orb_consumed:IsPurgable() return false end
function modifier_item_speed_orb_consumed:GetTexture() return "speed_orb" end


function modifier_item_speed_orb_consumed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            
    }
    return funcs 
end
function modifier_item_speed_orb_consumed:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount() * 100
end 

function item_consumable_used(keys)
    EmitSoundOn("Item.MoonShard.Consume", keys.caster)
    increase_modifier(keys.caster, keys.caster, keys.ability, keys.modifier)
    keys.ability:SpendCharge()
end