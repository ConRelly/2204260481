LinkLuaModifier("modifier_spectre_einherjar_lua", "lua_abilities/spectre_einherjar_lua/modifier_spectre_einherjar_lua.lua", LUA_MODIFIER_MOTION_NONE)

spectre_einherjar_lua = class({})

function spectre_einherjar_lua:OnSpellStart()
    local caster = self:GetCaster()
    local spawn_location = caster:GetOrigin()
    local duration = self:GetTalentSpecialValueFor("duration")
    local illusion_damage_incoming = self:GetSpecialValueFor("illusion_damage_incoming")
    local illusion_damage_outgoing = self:GetSpecialValueFor("illusion_damage_outgoing")
    if caster:HasScepter() then
        illusion_damage_incoming = self:GetSpecialValueFor("scepter_illusion_damage_incoming")
    end

    local modifyEinherjar = function(illusion)
        -- set facing
        illusion:SetForwardVector(caster:GetForwardVector())

        -- set level, abilities and items
        while illusion:GetLevel() < caster:GetLevel() do
            illusion:HeroLevelUp(false)
        end
        illusion:SetAbilityPoints(0)
        local abilityCount = caster:GetAbilityCount()
        for i = 0, abilityCount - 1 do
            local ability = caster:GetAbilityByIndex(i)
            if ability then
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
        local eslot = nil
        for slot = 0, 5 do
            -- remove anything in current slot
            local iItem = illusion:GetItemInSlot(slot)
            if iItem then
                illusion:RemoveItem(illusion:GetItemInSlot(slot))
            end

            -- add item to slot
            local item = caster:GetItemInSlot(slot)
            if item then
                illusion:AddItemByName(item:GetName())

                -- rearrange slot
                if eslot and eslot ~= slot then
                    illusion:SwapItems(eslot, slot)
                end
            elseif not eslot then
                eslot = slot
            end
        end       

        -- make illusion
        illusion:MakeIllusion()
        illusion:SetControllableByPlayer(caster:GetPlayerID(), false) -- (playerID, bSkipAdjustingPosition)
        illusion:SetPlayerID(caster:GetPlayerID())

        -- Add illusion modifier
        illusion:AddNewModifier(
                caster,
                self,
                "modifier_illusion",
                {
                    duration = duration,
                    outgoing_damage = illusion_damage_outgoing,
                    incoming_damage = illusion_damage_incoming,
                }
        )

        illusion:AddNewModifier(caster, self, "modifier_spectre_einherjar_lua", {})
        -- set health
        illusion:SetHealth(caster:GetHealth())
        illusion:SetMana(caster:GetMana())
    end

    -- Create unit
    CreateUnitByNameAsync(
            caster:GetUnitName(), -- szUnitName
            spawn_location, -- vLocation,
            true, -- bFindClearSpace,
            caster, -- hNPCOwner,
            caster:GetPlayerOwner(), -- hUnitOwner,
            caster:GetTeamNumber(), -- iTeamNumber
            modifyEinherjar
    )

    -- Play sound effects
    local sound_cast = "Hero_Spectre.Haunt"
    EmitSoundOn(sound_cast, caster)
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
