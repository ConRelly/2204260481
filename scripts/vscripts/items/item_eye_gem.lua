LinkLuaModifier("modifier_item_eye_gem", "items/item_eye_gem.lua", LUA_MODIFIER_MOTION_NONE)

item_eye_gem = class({})

function item_eye_gem:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if caster:HasModifier("modifier_item_eye_gem") then
        caster:RemoveModifierByName("modifier_item_eye_gem")
    else
        -- The effect must outlive the consumed item.
        caster:AddNewModifier(caster, nil, "modifier_item_eye_gem", {})
    end

    EmitSoundOn("Item.MoonShard.Consume", caster)
    self:SpendCharge(0.01)
end

modifier_item_eye_gem = class({})

function modifier_item_eye_gem:IsHidden() return false end
function modifier_item_eye_gem:IsDebuff() return true end
function modifier_item_eye_gem:IsPurgable() return false end
function modifier_item_eye_gem:IsPurgeException() return false end
function modifier_item_eye_gem:RemoveOnDeath() return false end
function modifier_item_eye_gem:IsPermanent() return true end
function modifier_item_eye_gem:GetTexture() return "item_eye_gem" end

function modifier_item_eye_gem:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_item_eye_gem:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA + 1000000
end

function modifier_item_eye_gem:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = false,
    }
end
