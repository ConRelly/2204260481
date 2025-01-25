LinkLuaModifier("modifier_xp_booster_cdr", "items/item_xp_booster_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xp_booster_passive", "items/item_xp_booster_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xp_booster_consumed", "items/item_xp_booster_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xp_booster_aura", "items/item_xp_booster_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xp_booster_aura_effect", "items/item_xp_booster_edible.lua", LUA_MODIFIER_MOTION_NONE)

item_xp_booster_edible = class({})


-- Variables
local BONUS_XP_PERCENT = 25
local STAT_GAIN_INTERVAL = 3
local INT_GAIN = 1
local AGI_STR_GAIN = 2
local CDR_TIME_THRESHOLD = 100  -- 100 minutes 

function item_xp_booster_edible:GetIntrinsicModifierName()
    return self:GetParent():GetUnitName() == "npc_dota_totem_item_holder" and 
        "modifier_xp_booster_aura" or 
        "modifier_xp_booster_passive"
end

function item_xp_booster_edible:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    
    if caster:IsHero() and not caster:HasModifier("modifier_xp_booster_consumed") then
        local buff = caster:AddNewModifier(caster, self, "modifier_xp_booster_consumed", {})
        local game_time = math.floor(GameRules:GetGameTime() / 60)
        if game_time >= CDR_TIME_THRESHOLD then
            local cdr_mod = caster:AddNewModifier(caster, self, "modifier_xp_booster_cdr", {})
            cdr_mod:SetStackCount(caster:GetLevel() / 10)
        end
        self:SpendCharge(0.01)
    end
end

-- Aura Handler Modifier (NPC only)
modifier_xp_booster_aura = class({})
function modifier_xp_booster_aura:IsHidden() return true end
function modifier_xp_booster_aura:IsPurgable() return false end

function modifier_xp_booster_aura:OnCreated()
    self.aura_rage = 7200
    if IsServer() then
        self:StartIntervalThink(1.0)
        self:UpdateStacks()
    end
end

function modifier_xp_booster_aura:OnIntervalThink()
    if not IsServer() then return end
    
    -- Merge all items into lowest slot
    local parent = self:GetParent()
    local items = {}
    for i = 0, 8 do
        local item = parent:GetItemInSlot(i)
        if item and item:GetName() == "item_xp_booster_edible" then
            table.insert(items, {item = item, slot = i})
        end
    end

    if #items > 1 then
        table.sort(items, function(a,b) return a.slot < b.slot end)
        local mainItem = items[1].item
        
        -- Sum charges and destroy others
        for i = 2, #items do
            mainItem:SetCurrentCharges(mainItem:GetCurrentCharges() + items[i].item:GetCurrentCharges())
            parent:TakeItem(items[i].item)
        end
        
        self:UpdateStacks()
    end
end

function modifier_xp_booster_aura:UpdateStacks()
    local current_charges = 0
    for i = 0, 8 do
        local item = self:GetParent():GetItemInSlot(i)
        if item and item:GetName() == "item_xp_booster_edible" then
            current_charges = item:GetCurrentCharges()
            break -- Only one item exists after merge
        end
    end
    self:SetStackCount(current_charges)
    self.aura_rage = 0
    Timers:CreateTimer(1, function()  -- 1 frame delay
        if not self:IsNull() then
            self.aura_rage = 7200
        end
    end)    
end

-- Aura Configuration
function modifier_xp_booster_aura:IsAura() return true end
function modifier_xp_booster_aura:GetAuraRadius() return self.aura_rage end
function modifier_xp_booster_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_xp_booster_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_xp_booster_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_xp_booster_aura:GetModifierAura() return "modifier_xp_booster_aura_effect" end

-- Aura Effect Modifier
modifier_xp_booster_aura_effect = class({})
function modifier_xp_booster_aura_effect:IsHidden() return false end
function modifier_xp_booster_aura_effect:DeclareFunctions()
    return {MODIFIER_PROPERTY_EXP_RATE_BOOST}
end
function modifier_xp_booster_aura_effect:GetModifierPercentageExpRateBoost()
    return 15 + 5 * self:GetAuraOwner():GetModifierStackCount("modifier_xp_booster_aura", nil)
end

---not new--


-- Passive modifier (XP boost)

modifier_xp_booster_passive = class({})
function modifier_xp_booster_passive:IsHidden()
    return true
end
function modifier_xp_booster_passive:DeclareFunctions()
    return {MODIFIER_PROPERTY_EXP_RATE_BOOST}
end

function modifier_xp_booster_passive:GetModifierPercentageExpRateBoost()
    return BONUS_XP_PERCENT
end

modifier_xp_booster_consumed = class({})

function modifier_xp_booster_consumed:IsHidden()
    return false
end
function modifier_xp_booster_consumed:IsPurgable()
    return false
end
function modifier_xp_booster_consumed:RemoveOnDeath()
    return false
end
function modifier_xp_booster_consumed:GetTexture()
    return "xp_booster_edible"
end


function modifier_xp_booster_consumed:OnCreated()
    if IsServer() then
        self.stat_stacks = 0
        self:StartIntervalThink(STAT_GAIN_INTERVAL)
    end
end

function modifier_xp_booster_consumed:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        if parent:HasModifier("modifier_xp_booster_passive") then return end
        
        parent:ModifyIntellect(INT_GAIN)
        parent:ModifyAgility(AGI_STR_GAIN)
        parent:ModifyStrength(AGI_STR_GAIN)
        
        self.stat_stacks = self.stat_stacks + 1
        self:SetStackCount(self.stat_stacks)
    end
end

function modifier_xp_booster_consumed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end

function modifier_xp_booster_consumed:OnTooltip()
    return self:GetStackCount()
end
function modifier_xp_booster_consumed:OnTooltip2()
    return self:GetStackCount() * 2
end

-- CDR modifier

modifier_xp_booster_cdr = class({})

function modifier_xp_booster_cdr:IsHidden()
    return false
end
function modifier_xp_booster_cdr:IsPurgable()
    return false
end
function modifier_xp_booster_cdr:RemoveOnDeath()
    return false
end
function modifier_xp_booster_cdr:GetTexture()
    return "xp_booster_edible"
end

function modifier_xp_booster_cdr:DeclareFunctions()
    return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function modifier_xp_booster_cdr:GetModifierPercentageCooldown()
    return self:GetStackCount()
end



