-- Applies to engine healing events, independent of the ability/item source.
local HealingGuard = { enabled = true, installed = false }
local MAX_HEAL = 1000000
-- Bounds current HP + this heal; does not change a unit's maximum HP stat.
local MAX_HEALTH_AFTER_HEAL = 100000000
local min, huge, valueType = math.min, math.huge, type

function HealingGuard:Init()
    self.enabled = true
    GameRules:GetGameModeEntity():SetHealingFilter(Dynamic_Wrap(HealingGuard, "Filter"), self)
    self.installed = true
    print("[HealingGuard] v2 installed, ON. Heal cap: min(max HP, 1000000, 100000000-current HP).")
end

function HealingGuard:Filter(keys)
    if not self.enabled then return true end

    -- Reject overflowed/invalid amounts before any entity lookup or engine call.
    local amount = keys.heal
    if valueType(amount) ~= "number" or amount ~= amount or amount < 0 or amount == huge then
        keys.heal = 0
        return false
    end
    if amount == 0 then return true end

    local index = keys.entindex_target_const
    if valueType(index) ~= "number" or index <= 0 then return false end
    local target = EntIndexToHScript(index)
    if not target or target:IsNull() then return false end

    local maxHealth = target:GetMaxHealth()
    local health = target:GetHealth()
    -- Both getters return numbers. Keep checks for corrupted health values.
    if maxHealth <= 0 or maxHealth ~= maxHealth or maxHealth == huge
        or health < 0 or health ~= health or health == huge then
        keys.heal = 0
        return false
    end

    -- Preserve fractional healing. Do not cap to missing HP before anti-heal.
    local capped = min(amount, maxHealth, MAX_HEAL, MAX_HEALTH_AFTER_HEAL - health)
    if capped <= 0 then
        keys.heal = 0
        return false
    end
    keys.heal = capped
    return true
end

local function Notify(playerID, message)
    print("[HealingGuard] " .. message)
    if PlayerResource:GetPlayer(playerID) then
        Notifications:Top(playerID, { text = message, duration = 6, style = { color = "yellow" } })
    end
end

function HealingGuard:HandleChatCommand(keys)
    local text = keys.text
    if text ~= "-healguard" and text ~= "-healguard on" and text ~= "-healguard off" then return false end
    local playerID = keys.playerid
    if valueType(playerID) ~= "number" or not PlayerResource:IsValidPlayerID(playerID) then return true end

    if text == "-healguard" then
        Notify(playerID, "Healing guard " .. (self.enabled and "ON" or "OFF")
            .. (self.installed and " (installed)." or " (NOT installed)."))
        return true
    end
    if playerID ~= 0 or not (IsInToolsMode() or Cheats:IsEnabled()) then
        Notify(playerID, "Healing guard on/off requires the test host and Tools mode or cheats.")
        return true
    end
    self.enabled = text == "-healguard on"
    local message = "Healing guard " .. (self.enabled and "ON" or "OFF (testing only)")
    print("[HealingGuard] " .. message)
    Notifications:TopToAll({ text = message, duration = 6, style = { color = "yellow" } })
    return true
end

return HealingGuard
