require("lib/my")
local MODIFIER_NAME = 'modifier_mjz_bristleback_quill_spray_autocast4_5'
local THIS_LUA = "abilities/hero_bristleback/mjz_bristleback_quill_spray_autocast4_5.lua"

LinkLuaModifier(MODIFIER_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------

mjz_bristleback_quill_spray_autocast4_5 = class({})
local ability_class = mjz_bristleback_quill_spray_autocast4_5



function ability_class:OnOwnerSpawned()
	local caster = self:GetCaster()
	local ability = self

	if ability and ability:GetToggleState() then
		caster:AddNewModifier(caster, ability, MODIFIER_NAME, {})
    end
end
function ability_class:ResetToggleOnRespawn() return false end

function ability_class:OnToggle()
    if IsServer() then
        local ability = self
        local caster = self:GetCaster()
        if ability:GetToggleState() then
            caster:AddNewModifier(caster, ability, MODIFIER_NAME, {})
        else
            caster:RemoveModifierByName(MODIFIER_NAME)
        end
    end
end


--------------------------------------------------------------------------------

modifier_mjz_bristleback_quill_spray_autocast4_5 = class({})
local modifier_class = modifier_mjz_bristleback_quill_spray_autocast4_5

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
--function modifier_class:IsPermanent() return true end

function modifier_class:OnCreated(table)
    if IsServer() then
        local ability = self:GetAbility()
        local tick_interval = ability:GetSpecialValueFor('tick_interval')
        self.cached_item_slots = {} -- Initialize cache
        self.needs_slot_update = true -- Initial build needed
        self:StartIntervalThink(tick_interval)

    end
end

local NoAutocast = {
    
    ["drow_ranger_frost_arrows_lua"] = true,
    ["clinkz_searing_arrows"] = true,
    ["ancient_apparition_chilling_touch"] = true,
    ["obsidian_destroyer_arcane_orb"] = true,
    ["enchantress_impetus"] = true,
    ["mjz_kunkka_tidebringer"] = true,
    ["huskar_burning_spear"] = true,
    ["rubick_spell_steal"] = true,
    ["custom_aegis_cast"] = true,
    ["brewmaster_drunken_brawler"] = true,
    ["dawnbreaker_solar_guardian"] = true,
    ["dawnbreaker_land"] = true,
    ["faceless_void_time_walk_reverse"] = true,
    
};

local TargetSpell = {
    
    ["tinker_warp_grenade"] = true,
    ["hoodwink_hunters_boomerang"] = true,
    ["mjz_spectre_haunt_single"] = true,
    ["razor_static_link"] = true,
    ["shadow_demon_demonic_cleanse"] = true,
    ["antimage_counterspell_ally"] = true,
};
local PointSpell = {
    
    --["techies_sticky_bomb"] = true,
    --["hoodwink_hunters_boomerang"] = true,


};
local PointSpell_self_target = {
    
    ["earthshaker_enchant_totem"] = true,

};
local NoAutocastItem = {
    
    ["item_echo_wand"] = true,
    ["item_remove_ability"] = true,
    ["item_totem_upgrade"] = true,
    ["item_xp_booster_edible"] = true,
};

local NoSelfTarget = {
    ["marci_guardian"] = true,
    ["marci_bodyguard"] = true,
    ["antimage_counterspell_ally"] = true,
};

function modifier_class:OnIntervalThink()
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local starting_skill = 6
        if not ability:GetToggleState() then return nil end
        if parent == nil then return nil end
        if not IsValidEntity(parent) then return nil end
        if parent:HasModifier("modifier_mows_image") then return end 
        if parent:HasModifier("modifier_fountain_invulnerability") then return end
        if parent:HasModifier("modifier_arc_warden_tempest_double") then
            starting_skill = 0
        end
        for i=starting_skill,parent:GetAbilityCount() -1 do

            if parent == nil then return nil end
            local target_ability = parent:GetAbilityByIndex( i )   
            if target_ability == nil then return nil end  
            --let print some debug info (basically the pass checks for the ability , atrribute bonus , hidden , toggle , activated , level , cooldown , passive)
--[[             print("ability name: ".. target_ability:GetAbilityName())
            print("ability level: ".. target_ability:GetLevel())
            print("ability cooldown: ".. target_ability:GetCooldown(target_ability:GetLevel()))
            --bolean value must be check acordly (to avoid error "attempt to concatenate a boolean value")
            print("ability is cooldown ready: ".. tostring(target_ability:IsCooldownReady()))
            print("ability is passive: ".. tostring(target_ability:IsPassive()))
            print("ability is hidden: ".. tostring(target_ability:IsHidden()))
            print("ability is toggle: ".. tostring(target_ability:IsToggle()))
            print("ability is activated: ".. tostring(target_ability:IsActivated())) ]]
            if target_ability and IsValidEntity(target_ability) and not target_ability:IsAttributeBonus() and not target_ability:IsHidden() and not target_ability:IsToggle() and target_ability:IsActivated() and target_ability:GetLevel() > 0 and target_ability:IsCooldownReady() and not target_ability:IsPassive() and not ( NoAutocast[target_ability:GetAbilityName()] == true) and not (target_ability:GetCooldown(target_ability:GetLevel()) <= 0) then  
                --print("initial pass")
                --print("cooldown: " .. target_ability:GetCooldown(target_ability:GetLevel()))
                --if (target_ability:GetCooldown(target_ability:GetLevel()) <= 0) then return end
                --print("pass 0")
                if target_ability:IsInAbilityPhase() then return nil end
                --if not ability:GetToggleState() then return nil end
                local ability_name = target_ability:GetAbilityName()
                --if NoAutocast[ability_name] == true then return end                
                if not IsValidEntity(parent) then return nil end
                if not target_ability:IsCooldownReady() then return nil end
                if target_ability == nil then return nil end
                --if target_ability:GetLevel() < 1 then return nil end
                if not target_ability:IsFullyCastable() then return nil end
                if parent:IsIllusion() then return nil end
                if not parent:IsRealHero() then return nil end
                --print("ability name: ".. ability_name)
                if parent:IsChanneling() and not ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL) then
                    return nil
                end
                --print("pass 0.5")
                if parent:IsSilenced() then return nil end		
                if parent:HasModifier("modifier_brewmaster_primal_split") and not target_ability:GetAbilityName() ~= "brewmaster_primal_split" then return nil end
				--if target_ability:GetCooldown(target_ability:GetLevel()) <= 0 then return end
                --print("pass 1")
                local cast_range = target_ability:GetCastRange(parent:GetAbsOrigin(), parent)
                local range_bonus = caster:GetCastRangeBonus()
                local radius_auto = 500 -- Default value

                if cast_range and range_bonus then
                    radius_auto = cast_range + range_bonus - 50
                    if radius_auto < 100 then
                        radius_auto = 500
                    end
                end
                --print("radius_auto = " .. radius_auto)
                --print("pass 1.5")
                if radius_auto then
                    if radius_auto < 100 then
                        radius_auto = 500
                    end
                else
                    radius_auto = 500
                    --print("radius_auto(fix) = 500")
                end   
                local pos = parent:GetAbsOrigin()
                --print("pass 2")
                if ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) and not (target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH)  then
                    --print("A no target : name: " .. ability_name)
                    if target_ability and IsValidEntity(target_ability) and IsValidEntity(parent) and parent:IsAlive() then
                        parent:CastAbilityNoTarget(target_ability, parent:GetPlayerOwnerID())
                    end 
                    --print("no target")  
                    return nil
                end  
                --print("pass 3") 
                local enemy_list = 0
                if target_ability:GetAbilityTargetType() ~= 0 then
                    if target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH then
                        enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
                            DOTA_UNIT_TARGET_TEAM_ENEMY, target_ability:GetAbilityTargetType(), target_ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                            FIND_ANY_ORDER, false)                     
                    else    
                        enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
                            target_ability:GetAbilityTargetTeam(), target_ability:GetAbilityTargetType(), target_ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                            FIND_ANY_ORDER, false)
                            --print("pass1")
                    end        
                elseif target_ability:GetAbilityTargetTeam() ~= 0 then
                    enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
                        target_ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                        FIND_ANY_ORDER, false) 
                        --print("pass2")
                else
                    enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
                        DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                        FIND_ANY_ORDER, false)   
                        --print("pass3")                          
                end                     
                if #enemy_list > 0 then
                    --print("more then 1 enemy pass")
                    local first_enemy = enemy_list[1]
                    if target_ability == nil then return nil end 
                    if parent == nil then return nil end
                    --print("decide what to cast")                
                    if (ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) or TargetSpell[target_ability:GetAbilityName()]) and (target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH) then
                        --print("cast1")
                        if target_ability and IsValidEntity(target_ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                            parent:CastAbilityOnTarget(first_enemy, target_ability, parent:GetPlayerOwnerID())   
                        end
                    elseif (ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_POINT) and PointSpell_self_target[target_ability:GetAbilityName()]) then
                        --print("point self cast")
                        if target_ability and IsValidEntity(target_ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                            parent:CastAbilityOnTarget(parent, target_ability, parent:GetPlayerOwnerID())
                        end                           
                    elseif (ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_POINT) or PointSpell[target_ability:GetAbilityName()]) then
                        --print("cast2")
                        if target_ability and IsValidEntity(target_ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                            parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), target_ability, parent:GetPlayerOwnerID())
                        end   
                    elseif ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
                        --print("cast3")
                        if target_ability and IsValidEntity(target_ability) and IsValidEntity(parent) and parent:IsAlive() then
                            parent:CastAbilityNoTarget(target_ability, parent:GetPlayerOwnerID()) 
                        end  
                    elseif (ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
                        --print("cast4")
                        if NoSelfTarget[target_ability:GetAbilityName()] then
                            local allied_heroes = FindUnitsInRadius(
                                parent:GetTeamNumber(),
                                parent:GetAbsOrigin(),
                                nil,
                                target_ability:GetCastRange(parent:GetAbsOrigin(), nil),
                                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                DOTA_UNIT_TARGET_HERO,
                                DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                                FIND_CLOSEST,
                                false
                            )
                            
                            for _, hero in ipairs(allied_heroes) do
                                if hero ~= parent and IsValidEntity(hero) and hero:IsAlive() then
                                    parent:CastAbilityOnTarget(hero, target_ability, parent:GetPlayerOwnerID())
                                    return
                                end
                            end
                        else
                            --print("cast5")
                            if target_ability and IsValidEntity(target_ability) and IsValidEntity(parent) and parent:IsAlive() then
                                parent:CastAbilityOnTarget(parent, target_ability, parent:GetPlayerOwnerID())
                            end
                        end
                    elseif TargetSpell[target_ability:GetAbilityName()] and target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
                        --print("cast6")
                        if NoSelfTarget[target_ability:GetAbilityName()] then
                            local allied_heroes = FindUnitsInRadius(
                                parent:GetTeamNumber(),
                                parent:GetAbsOrigin(),
                                nil,
                                target_ability:GetCastRange(parent:GetAbsOrigin(), nil),
                                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                DOTA_UNIT_TARGET_HERO,
                                DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                                FIND_CLOSEST,
                                false
                            )
                            
                            for _, hero in ipairs(allied_heroes) do
                                if hero ~= parent and IsValidEntity(hero) and hero:IsAlive() then
                                    parent:CastAbilityOnTarget(hero, target_ability, parent:GetPlayerOwnerID())
                                    return
                                end
                            end
                        else
                            --print("cast7")
                            if target_ability and IsValidEntity(target_ability) and IsValidEntity(parent) and parent:IsAlive() then
                                parent:CastAbilityOnTarget(parent, target_ability, parent:GetPlayerOwnerID())
                            end
                        end                                                        
                    else
                        return nil    
                    end    
                    return nil
                end
            end       
        end 
        --Autocast for items
        local playerID = parent:GetPlayerOwnerID()
        if PlayerResource:GetPlayer(playerID) then
            -- Check if update is needed
            if self.needs_slot_update then
                self.cached_item_slots = {} -- Clear cache
                if _G._itemauto1[playerID] ~= nil then
                    table.insert(self.cached_item_slots, _G._itemauto1[playerID])
                end
                if _G._itemauto2[playerID] ~= nil then
                    table.insert(self.cached_item_slots, _G._itemauto2[playerID])
                end
                if _G._itemauto3[playerID] ~= nil then
                    table.insert(self.cached_item_slots, _G._itemauto3[playerID])
                end
                if _G._itemauto4[playerID] ~= nil then
                    table.insert(self.cached_item_slots, _G._itemauto4[playerID])
                end
                self.needs_slot_update = false -- Reset flag
            end

            if parent:HasModifier("modifier_arc_warden_tempest_double") then
                -- Tempest Double logic remains unchanged for now, still checks slots 0-4 + 16 directly
                -- If Tempest Double should also respect itemauto commands, this needs adjustment
                for slot=0 ,4 do
                    local item = parent:GetItemInSlot(slot)
                    if item and IsValidEntity(item) and item:IsFullyCastable() then
                        -- more checks 
                        local ability = item:GetAbilityName()
                        if ability == nil then return end
                        if ability == "" then return end
                        if NoAutocastItem[ability] == true then return end                
                        if not IsValidEntity(parent) then return nil end
                        if not item:IsCooldownReady() then return nil end
                        if item == nil then return nil end
                        if not item:IsActivated() then return end
                        if parent:IsIllusion() then return nil end
                        if not parent:IsRealHero() then return nil end
                        if parent:IsChanneling() and not ability_behavior_includes(item, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL) then
                            return nil
                        end                    
                        if item:GetCooldown(item:GetLevel()) <= 0 then return end
                        if parent:IsInvisible() then
                            AttackNearestEnemy(parent)
                        end
                        use_ability(item, caster, parent)
                    end
                end 
                local item = parent:GetItemInSlot(16)     
                if item and IsValidEntity(item) and item:IsFullyCastable() then
                    -- more checks 
                    local ability = item:GetAbilityName()
                    if ability == nil then return end
                    if ability == "" then return end
                    if NoAutocastItem[ability] == true then return end                
                    if not IsValidEntity(parent) then return nil end
                    if not item:IsCooldownReady() then return nil end
                    if item == nil then return nil end
                    if not item:IsActivated() then return end
                    if parent:IsIllusion() then return nil end
                    if not parent:IsRealHero() then return nil end
                    if parent:IsChanneling() and not ability_behavior_includes(item, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL) then
                        return nil
                    end                    
                    if item:GetCooldown(item:GetLevel()) <= 0 then return end
                    if parent:IsInvisible() then
                        AttackNearestEnemy(parent)
                    end
                    use_ability(item, caster, parent)
                end
            else
                -- Use the cached table
                for _, slot in ipairs(self.cached_item_slots) do
                    local item = parent:GetItemInSlot(slot)
                    if item and IsValidEntity(item) and item:IsFullyCastable() then
                        -- more checks 
                        local ability = item:GetAbilityName()
                        if ability == nil then return end
                        if ability == "" then return end
                        if NoAutocastItem[ability] == true then return end                
                        if not IsValidEntity(parent) then return nil end
                        if not item:IsCooldownReady() then return nil end
                        if item == nil then return nil end
                        if not item:IsActivated() then return end
                        if parent:IsIllusion() then return nil end
                        if not parent:IsRealHero() then return nil end
                        if parent:IsChanneling() and not ability_behavior_includes(item, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL) then
                            return nil
                        end                    
                        if item:GetCooldown(item:GetLevel()) <= 0 then return end
                        if parent:IsInvisible() then
                            AttackNearestEnemy(parent)
                        end
                        use_ability(item, caster, parent)
                    end
                end
            end
        end           
    end          
end


----keep search and attack ---- 
function FindEnemiesInRange(unit, range)
    local enemies = FindUnitsInRadius(
      unit:GetTeamNumber(),
      unit:GetAbsOrigin(),
      nil,
      range,
      DOTA_UNIT_TARGET_TEAM_ENEMY,
      DOTA_UNIT_TARGET_ALL,
      DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
      FIND_CLOSEST,
      false
    )
    
    if #enemies > 0 then
      return enemies[1]
    else
      return nil
    end
end
  
  
function AttackNearestEnemy(unit)
    local agro_range = 7500
    local range = unit:GetAttackRange()
    local agro_enemy = FindEnemiesInRange(unit, agro_range)
    local enemy = FindEnemiesInRange(unit, range)
    if agro_enemy then
        unit:MoveToTargetToAttack(agro_enemy)
    end
    if enemy then
        unit:PerformAttack(enemy, true, true, true, false, true, false, false)
    end
end


-----------------------------------------------------------------------------------------

function IsChanneling(unit)
	local ability_count = unit:GetAbilityCount()
	for i=0,(ability_count-1) do
		local ability = unit:GetAbilityByIndex(i)
		if ability ~= nil then
			if ability:IsChanneling() then
				return true
			end
		end
	end
	for itemSlot = 0, 5, 1 do
		local Item = unit:GetItemInSlot( itemSlot )
		if Item ~= nil then
			if Item:IsChanneling() then
				return true
			end
		end
	end
	return false
end



function use_ability(ability, caster, parent )
    if not IsServer() then return end
    --local parent = caster:GetOwner()
    local radius_auto = ability:GetCastRange(parent:GetAbsOrigin(), parent) + caster:GetCastRangeBonus() - 50  
    if radius_auto then
        if radius_auto < 100 then
            radius_auto = 500
        end
    else
        radius_auto = 500
    end    
    local pos = parent:GetAbsOrigin()
    if ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) and not (ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH)  then
        if ability and IsValidEntity(ability) and IsValidEntity(parent) and parent:IsAlive() then
            parent:CastAbilityNoTarget(ability, parent:GetPlayerOwnerID())
        end    
        return nil
    end   
    local enemy_list = 0
    if ability:GetAbilityTargetType() ~= 0 then                          
        enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
            ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
            FIND_ANY_ORDER, false)
    elseif ability:GetAbilityTargetTeam() ~= 0 then
        enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
            ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
            FIND_ANY_ORDER, false) 
    else
        enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
            DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
            FIND_ANY_ORDER, false)                             
    end                     
    if #enemy_list > 0 then
        local first_enemy = enemy_list[1]
        if ability == nil then return nil end 
        if parent == nil then return nil end                   
        if ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and (ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH) then
            if ability and IsValidEntity(ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                parent:CastAbilityOnTarget(first_enemy, ability, parent:GetPlayerOwnerID())
            end   
        elseif ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_POINT) then
            if ability and IsValidEntity(ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), ability, parent:GetPlayerOwnerID())
            end   
        elseif ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if ability and IsValidEntity(ability) and IsValidEntity(parent) and parent:IsAlive() then
                parent:CastAbilityNoTarget(ability, parent:GetPlayerOwnerID()) 
            end    
        elseif ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then	
            if ability and IsValidEntity(ability) and IsValidEntity(parent) and parent:IsAlive() then
                parent:CastAbilityOnTarget(parent, ability, parent:GetPlayerOwnerID())
            end  
        else
            return nil    
        end    
        return nil
    end
end
