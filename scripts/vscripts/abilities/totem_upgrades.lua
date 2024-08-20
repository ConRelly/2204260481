-- abilities/totem_upgrades.lua

LinkLuaModifier("modifier_totem_aura", "abilities/totem_upgrades.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_totem_aura_effect", "abilities/totem_upgrades.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_totem_upgrade_tracker", "abilities/totem_upgrades.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hero_totem_buff", "abilities/totem_upgrades.lua", LUA_MODIFIER_MOTION_NONE)

-- Totem Aura ability
totem_aura = class({})


function totem_aura:GetIntrinsicModifierName()
    return "modifier_totem_aura"
end

-- Totem Aura modifier (applied to the totem)
modifier_totem_aura = class({})

function modifier_totem_aura:IsHidden() return false end
function modifier_totem_aura:IsDebuff() return false end
function modifier_totem_aura:IsPurgable() return false end

function modifier_totem_aura:GetAuraRadius()
    return 7200 
end

function modifier_totem_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_totem_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end
function modifier_totem_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_totem_aura:GetModifierAura()
    return "modifier_totem_aura_effect"
end

function modifier_totem_aura:IsAura()
    return true
end

-- Totem Aura Effect modifier (applied to units in range)
modifier_totem_aura_effect = class({})

function modifier_totem_aura_effect:IsHidden() return false end
function modifier_totem_aura_effect:IsDebuff() return false end
function modifier_totem_aura_effect:IsPurgable() return false end

function modifier_totem_aura_effect:OnCreated()
    self:OnRefresh()
end

function modifier_totem_aura_effect:OnRefresh()
    if IsServer() then
        local totem = self:GetAuraOwner()
        if totem then
            local upgrade_ability = totem:FindAbilityByName("totem_upgrade_tracker")
            if upgrade_ability then
                local level = upgrade_ability:GetLevel()
                --set the self:stack count to the level
                if level then
                    self:SetStackCount(level)
                end
            end
        end
    end
end

function modifier_totem_aura_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end

--set the bonuses base on stack count
function modifier_totem_aura_effect:GetModifierMagicalResistanceBonus()
    if self:GetStackCount() >= 50 then
        return self:GetStackCount() * 0.8
    else
        return self:GetStackCount() * 0.4
    end
end

function modifier_totem_aura_effect:GetModifierPhysicalArmorBonus()
    if self:GetStackCount() >= 50 then
        return self:GetStackCount() * 6
    else
        return self:GetStackCount() * 3
    end
end

function modifier_totem_aura_effect:GetModifierStatusResistance()
    if self:GetStackCount() >= 50 then
        return self:GetStackCount() * 0.5
    else
        return self:GetStackCount() * 0.25
    end
end

function modifier_totem_aura_effect:GetModifierSpellAmplify_Percentage()
    if self:GetStackCount() >= 50 then
        return self:GetStackCount() * 4
    else
        return self:GetStackCount() * 2
    end
end

function modifier_totem_aura_effect:GetModifierBaseDamageOutgoing_Percentage()
    if self:GetStackCount() >= 50 then
        return self:GetStackCount() * 2
    else
        return self:GetStackCount() * 1
    end
end

function modifier_totem_aura_effect:GetModifierMoveSpeed_AbsoluteMin()
    local parent = self:GetParent()
    if parent and parent:HasModifier("modifier_hero_totem_buff") then
        local stacks = parent:GetModifierStackCount("modifier_hero_totem_buff", parent)
        return 600 + (20 * stacks)
    end
end    


--add calculate cost in tooltip base on stacks (1000 + (level * 250))
function modifier_totem_aura_effect:OnTooltip()
    local stacks = self:GetStackCount()
    local cost = 1000 + (stacks * 250)
    return cost
end    
--return stack count
function modifier_totem_aura_effect:OnTooltip2()
    local stacks = self:GetStackCount()
    return stacks
end


-- Totem Upgrade Tracker ability
if totem_upgrade_tracker == nil then
    totem_upgrade_tracker = class({})
end

function totem_upgrade_tracker:GetIntrinsicModifierName()
    return "modifier_totem_upgrade_tracker"
end

-- Totem Upgrade Tracker modifier
modifier_totem_upgrade_tracker = class({})

function modifier_totem_upgrade_tracker:IsHidden() return false end
function modifier_totem_upgrade_tracker:IsDebuff() return false end
function modifier_totem_upgrade_tracker:IsPurgable() return false end
function modifier_totem_upgrade_tracker:CheckState()
    local state = {
        [MODIFIER_STATE_MUTED] = true,
    }
    return state
end



-- Totem Upgrade ability (for players to use)
if item_totem_upgrade == nil then
    item_totem_upgrade = class({})
end
function item_totem_upgrade:Spawn()
    if IsServer() then
        if _G.totem_aura_check then
            _G.totem_aura_check = false
            local hero = PlayerResource:GetSelectedHeroEntity(0)	
            local origin = Vector(-1694.63, 2700.81, 448) + RandomVector(50)
            local totem = CreateUnitByName("npc_dota_totem_item_holder", origin, true, nil, nil, DOTA_TEAM_GOODGUYS)
            totem:SetHasInventory(true)
            totem:SetOwner(hero)
            totem:SetControllableByPlayer(0, true)
            totem:AddNewModifier(totem, nil, "modifier_invulnerable", {})
            totem:AddNewModifier(totem, nil, "modifier_meepo_pack_rat", {})
            
        end    
    end    
end    


--spell start 
function item_totem_upgrade:OnSpellStart()
    if IsServer() then
        if not self then
            print("Error: self is nil")
            return
        end

        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local player = caster:GetPlayerOwnerID()

        if not IsValidEntity(caster) then
            print("Error: Invalid caster")
            return
        end

        if not IsValidEntity(target) then
            DisplayError(player, "Invalid upgrade target!")
            return
        end

        if not target:HasAbility("totem_upgrade_tracker") then
            DisplayError(player, "Target does not have the required ability!")
            return
        end

        local upgrade_ability = target:FindAbilityByName("totem_upgrade_tracker")
        if not upgrade_ability then
            DisplayError(player, "Could not find the upgrade tracker ability!")
            return
        end

        local current_level = upgrade_ability:GetLevel()
        
        if current_level >= 50 then
            self:HandleMaxLevelUpgrade(caster, player)
        else
            self:HandleNormalUpgrade(caster, target, player, upgrade_ability, current_level)
        end
    end
end

function item_totem_upgrade:HandleMaxLevelUpgrade(caster, player)
    local charges = self:GetCurrentCharges()
    if charges <= 0 then
        DisplayError(player, "Totem is at maximum level and item has no charges!")
        return
    end

    local hero = caster
    if not hero:IsRealHero() or hero:GetUnitName() == "npc_courier_replacement" then
        DisplayError(player, "Only real heroes can receive the totem buff!")
        return
    end

    self:ApplyTotemBuff(hero, charges)
    DisplaySuccess(player, "Totem buff applied to hero with " .. charges .. " stacks!")
    hero:RemoveItem(self)
end

function item_totem_upgrade:ApplyTotemBuff(hero, charges)
    local modifier = hero:FindModifierByName("modifier_hero_totem_buff")
    if modifier then
        charges = charges + modifier:GetStackCount()
        modifier:SetStackCount(charges)
    else
        modifier = hero:AddNewModifier(hero, self, "modifier_hero_totem_buff", {})
        if modifier then
            modifier:SetStackCount(charges)
        else
            print("Error: Failed to create modifier_hero_totem_buff")
        end
    end
end

function item_totem_upgrade:HandleNormalUpgrade(caster, target, player, upgrade_ability, current_level)
    local gold_cost = 1000 + (current_level * 250)
    if caster:GetGold() < gold_cost then
        DisplayError(player, "Not enough gold, need " .. gold_cost .. " to upgrade the totem!")
        return
    end

    caster:SpendGold(gold_cost, DOTA_ModifyGold_PurchaseItem)
    upgrade_ability:SetLevel(current_level + 1)
    
    if not pcall(function() ApplyUpgradeEffects(target) end) then
        print("Error: Failed to apply upgrade effects")
    end

    self:SetCurrentCharges(self:GetCurrentCharges() + 1)
    DisplaySuccess(player, "Totem upgraded to level " .. (current_level + 1) .. ". Item charges: " .. self:GetCurrentCharges())
    
    self:RefreshAura(target)
end

function item_totem_upgrade:RefreshAura(target)
    local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, 7200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
    for _, unit in ipairs(units) do
        if IsValidEntity(unit) and unit:IsAlive() and unit:HasModifier("modifier_totem_aura_effect") then
            unit:RemoveModifierByName("modifier_totem_aura_effect")
        end
    end
end



-- New modifier for the hero buff
modifier_hero_totem_buff = class({})

function modifier_hero_totem_buff:IsHidden() return true end
function modifier_hero_totem_buff:IsDebuff() return false end
function modifier_hero_totem_buff:IsPurgable() return false end
function modifier_hero_totem_buff:RemoveOnDeath() return false end


function ApplyUpgradeEffects(target)
    local particle = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    target:EmitSound("General.LevelUp")
end

function DisplayError(player, message)
    Notifications:Bottom(player, {text=message, duration=8, style={color="red"}})
end

function DisplaySuccess(player, message)
    Notifications:Bottom(player, {text=message, duration=8, style={color="green"}})
end

