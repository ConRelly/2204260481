--LinkLuaModifier("modifier_spectre_einherjar_lua", "lua_abilities/spectre_einherjar_lua/modifier_spectre_einherjar_lua.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/illusion")
require("lib/my")
LinkLuaModifier( "modifier_death", "abilities/custom/dark_seer_custom_dark_clone_2", LUA_MODIFIER_MOTION_NONE)
dark_seer_custom_dark_clone_2 = class({})

function dark_seer_custom_dark_clone_2:OnSpellStart()
    local caster = self:GetCaster()
    local target = caster:GetCursorCastTarget()
    local spawn_location = caster:GetOrigin()
    local duration = self:GetTalentSpecialValueFor("duration")
    local illusion_damage_incoming = self:GetSpecialValueFor("illusion_damage_incoming")
    local illusion_damage_outgoing = self:GetSpecialValueFor("illusion_damage_outgoing")
    local aghbuf = "modifier_item_ultimate_scepter_consumed"
   -- if caster:HasScepter() then
   --     illusion_damage_incoming = self:GetSpecialValueFor("scepter_illusion_damage_incoming")
    --end

    local modifyEinherjar = function(illusion)
        -- set facing
        illusion:SetForwardVector(caster:GetForwardVector())

        -- set level, abilities and items
        while illusion:GetLevel() < target:GetLevel() do
            illusion:HeroLevelUp(false)
        end
        illusion:SetAbilityPoints(0)
        local abilityCount = target:GetAbilityCount()
        for i = 0, abilityCount - 1 do
            local ability = target:GetAbilityByIndex(i)
            --local abilityName = ability:GetAbilityName()
            if ability ~= nil and ability:GetAbilityName() ~= "chen_custom_holy_persuasion" and ability:GetAbilityName() ~= "dark_seer_custom_dark_clone_2" and ability:GetAbilityName() ~= "rubick_spell_steal" and ability:GetAbilityName() ~= "arc_warden_tempest_double" then
                local abilityLevel = ability:GetLevel()
                if illusion:GetAbilityByIndex(i) then
                    illusion:GetAbilityByIndex(i):SetLevel(abilityLevel)
                else
                    -- Add ability
                    local abilityName = ability:GetAbilityName()
                    local newAbility = illusion:AddAbility(abilityName)
                    newAbility:SetLevel(abilityLevel)
                end
            end
        end
        illusion:SetPlayerID(caster:GetPlayerID())
        illusion:SetControllableByPlayer(caster:GetPlayerID(), false) -- (playerID, bSkipAdjustingPosition)
        copy_items(target, illusion)
        disable_inventory(illusion)
        --[[local eslot = nil
        for slot = 0, 5 do
            -- remove anything in current slot
            local iItem = illusion:GetItemInSlot(slot)
            if iItem then
                illusion:RemoveItem(illusion:GetItemInSlot(slot))
            end

            -- add item to slot
            local item = target:GetItemInSlot(slot)
            if item then
                illusion:AddItemByName(item:GetName())

                -- rearrange slot
                if eslot and eslot ~= slot then
                    illusion:SwapItems(eslot, slot)
                end
            elseif not eslot then
                eslot = slot
            end
        end]]       

        -- make illusion
        --illusion:MakeIllusion()
        
        

        -- Add illusion modifier
        --[[illusion:AddNewModifier(
                caster,
                self,
                "modifier_illusion",
                {
                    duration = duration,
                    outgoing_damage = illusion_damage_outgoing,
                    incoming_damage = illusion_damage_incoming,
                }
        )]]

        illusion:AddNewModifier(caster, self, "modifier_death", {})
        illusion:AddNewModifier(caster, self, "modifier_arc_warden_tempest_double", {})
        illusion:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
        if caster:HasScepter() then
            illusion:AddNewModifier( caster, self, aghbuf, {})
        end
        -- set health
        illusion:SetHealth(target:GetHealth())
        illusion:SetMana(target:GetMana())
    end

    -- Create unit
    CreateUnitByNameAsync(
            target:GetUnitName(), -- szUnitName
            spawn_location, -- vLocation,
            true, -- bFindClearSpace,
            caster, -- hNPCOwner,
            caster:GetPlayerOwner(), -- hUnitOwner,
            caster:GetTeamNumber(), -- iTeamNumber
            modifyEinherjar
    )

    -- Play sound effects
    local sound_cast = "Hero_Dark_Seer.Wall_of_Replica_Start"
    EmitSoundOn(sound_cast, caster)
end

modifier_death = class({})

function modifier_death:IsHidden()
	return true
end
function modifier_death:IsPurgable()
	return false
end
function modifier_death:RemoveOnDeath()
    return false
end
function modifier_death:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
    return funcs
end


function modifier_death:OnTakeDamage(keys)
    local unit = keys.unit

    if unit == self:GetParent() and unit:GetHealth() <= 1 then
        kill_illusion(unit)
    end
end


function modifier_death:GetMinHealth(keys)
    return 1
end


-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end
