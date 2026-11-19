local PendantDelay = {}
local baseSeconds = 5
local maxSeconds = 9
local modifierName = "modifier_resurrection_pendant_courier_delay"

LinkLuaModifier(modifierName, "abilities/other/courier_resurrection_delay", LUA_MODIFIER_MOTION_NONE)

function PendantDelay:GetMinimum(caster)
    if caster and caster:HasModifier("modifier_super_scepter") then
        return baseSeconds / 2
    end
    return baseSeconds
end

function PendantDelay:GetChannelTime(caster)
    local minimum = self:GetMinimum(caster)
    local requested = caster and caster:GetModifierStackCount(modifierName, caster) or 0
    return math.max(minimum, math.min(maxSeconds, requested))
end

function PendantDelay:Initialize(courier, ability)
    return courier:FindModifierByName(modifierName)
        or courier:AddNewModifier(courier, ability, modifierName, {})
end

function PendantDelay:Cycle(courier, ability)
    local setting = self:Initialize(courier, ability)
    if not setting then return end

    local seconds = self:GetChannelTime(courier)
    -- Zero follows the courier's minimum, including future Super Scepter changes.
    local nextSeconds = seconds >= maxSeconds and 0 or math.floor(seconds) + 1
    setting:SetStackCount(nextSeconds)

    local player = PlayerResource:GetPlayer(courier:GetPlayerOwnerID())
    if player then
        Notifications:Top(player, { text = string.format("Pendant delay: %gs", self:GetChannelTime(courier)), duration = 2 })
    end
end

modifier_resurrection_pendant_courier_delay = class({})
function modifier_resurrection_pendant_courier_delay:IsHidden() return false end
function modifier_resurrection_pendant_courier_delay:IsPurgable() return false end
function modifier_resurrection_pendant_courier_delay:RemoveOnDeath() return false end
function modifier_resurrection_pendant_courier_delay:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_resurrection_pendant_courier_delay:GetTexture() return "custom/resurection_pendant_modifier" end

function modifier_resurrection_pendant_courier_delay:DeclareFunctions()
    return { MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_resurrection_pendant_courier_delay:OnTooltip()
    return math.max(PendantDelay:GetMinimum(self:GetParent()), math.min(maxSeconds, self:GetStackCount()))
end

return PendantDelay
