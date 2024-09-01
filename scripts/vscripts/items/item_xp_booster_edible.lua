LinkLuaModifier("modifier_xp_booster_cdr", "items/item_xp_booster_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xp_booster_passive", "items/item_xp_booster_edible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xp_booster_consumed", "items/item_xp_booster_edible.lua", LUA_MODIFIER_MOTION_NONE)
-- Define the item
item_xp_booster_edible = class({})

-- Variables
local BONUS_XP_PERCENT = 25
local STAT_GAIN_INTERVAL = 3
local INT_GAIN = 1
local AGI_STR_GAIN = 2
local CDR_PERCENT = 10
local CDR_TIME_THRESHOLD = 100  -- 100 minutes 

function item_xp_booster_edible:GetIntrinsicModifierName()
    return "modifier_xp_booster_passive"
end

function item_xp_booster_edible:OnSpellStart()
    if not IsServer() then return end
    
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_xp_booster_consumed") then return end
    local game_time = math.floor(GameRules:GetGameTime() / 60)
    
    -- Apply the buff
    local buff = caster:AddNewModifier(caster, self, "modifier_xp_booster_consumed", {})
    
    -- Apply CDR if eaten after 100 minutes
    if game_time >= CDR_TIME_THRESHOLD then
        caster:AddNewModifier(caster, self, "modifier_xp_booster_cdr", {})
        local cdr = caster:GetLevel() / 10
        local modif = caster:FindModifierByName("modifier_xp_booster_cdr")
        if modif then
            modif:SetStackCount(cdr)   
        end
    end
    --spend charge /consume item
    self:SpendCharge(0.01)
    
end

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

-- Consumed buff modifier

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



