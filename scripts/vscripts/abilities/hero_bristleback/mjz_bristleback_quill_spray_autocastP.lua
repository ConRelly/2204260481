require("lib/my")
local MODIFIER_NAME = 'modifier_mjz_bristleback_quill_spray_autocastp'
local THIS_LUA = "abilities/hero_bristleback/mjz_bristleback_quill_spray_autocastp.lua"

LinkLuaModifier(MODIFIER_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------

mjz_bristleback_quill_spray_autocastp = class({})
local ability_class = mjz_bristleback_quill_spray_autocastp

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

modifier_mjz_bristleback_quill_spray_autocastp = class({})
local modifier_class = modifier_mjz_bristleback_quill_spray_autocastp

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
--function modifier_class:IsPermanent() return true end

function modifier_class:OnCreated(table)
    if IsServer() then
        local ability = self:GetAbility()
        local tick_interval = ability:GetSpecialValueFor('tick_interval')  
        self:StartIntervalThink(tick_interval) 
        
    end         
end


local NoAutocastItem = {
    
    --["item_pipe_of_dezun"] = true,

};


function modifier_class:OnIntervalThink()
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        if not ability:GetToggleState() then return nil end
        if parent == nil then return nil end
        if not IsValidEntity(parent) then return nil end
        --AutoAgro
        if not IsChanneling(parent) then
            AttackNearestEnemy(parent)
        end   
        --Autocast for items
        for i=0, 3 do
            local item = parent:GetItemInSlot(i)
            if item and IsValidEntity(item) and item:IsFullyCastable() and item:IsActivated() then
                -- more checks 
                local ability = item:GetAbilityName()
                if ability == nil then return end
                if ability == "" then return end
                if NoAutocastItem[ability] == true then return end                
                if not IsValidEntity(parent) then return nil end
                if not item:IsCooldownReady() then return nil end
                if parent:IsIllusion() then return nil end
                if IsChanneling(parent) and not ability_behavior_includes(item, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL) then
                    return nil
                end                   
                if item:GetCooldown(item:GetLevel()) <= 0 then return end
                if parent:IsInvisible() then return end
                self.pirate_cast = false
                self:use_ability(item, caster, parent)
            end
        end 
        local item = parent:GetItemInSlot(16)
        if item and IsValidEntity(item) and item:IsFullyCastable() and item:IsActivated() then
            -- more checks 
            local ability = item:GetAbilityName()
            if ability == nil then return end
            if ability == "" then return end
            if NoAutocastItem[ability] == true then return end                
            if not IsValidEntity(parent) then return nil end
            if not item:IsCooldownReady() then return nil end
            if parent:IsIllusion() then return nil end
            if IsChanneling(parent) and not ability_behavior_includes(item, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL) then
                return nil
            end                   
            if item:GetCooldown(item:GetLevel()) <= 0 then return end
            if parent:IsInvisible() then return end
            self.pirate_cast = false
            self:use_ability(item, caster, parent)
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
    local Item = unit:GetItemInSlot( 16 )
    if Item ~= nil then
        if Item:IsChanneling() then
            return true
        end
    end    
	return false
end



function modifier_class:use_ability(ability, caster, parent )
    if not IsServer() then return end
    --local parent = caster:GetOwner() 
    local pirate_loc1 = Vector(-980.678894, -1213.073242, 320.000000)-- +  RandomVector(40)
    local pirate_loc2 = Vector(964.100281, -1222.740845, 320.000000)-- + RandomVector(40)
    local radius_auto = ability:GetCastRange(parent:GetAbsOrigin(), parent) + caster:GetCastRangeBonus() - 50
    if ability:GetAbilityName() == "item_pirate_hat" then
        self.pirate_cast = true
        radius_auto = 7200
    end
    if radius_auto < 100 then
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
    if ability:GetAbilityTargetTeam() == 1 and ability:GetAbilityTargetType() ~= 0 then  
        enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
            ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
            FIND_ANY_ORDER, false)  
            --print(" Frist check Ability: "..ability:GetAbilityName() )      
    elseif ability:GetAbilityTargetType() ~= 0 then   
        local target_team = ability:GetAbilityTargetTeam() 
        if target_team == 4 then
            target_team = 2
        end                          
        enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
            target_team, ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
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
        --print("enemy: "..first_enemy:GetUnitName().." Ability: "..ability:GetAbilityName() )                
        if ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and (ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH) then
            if ability and IsValidEntity(ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                parent:CastAbilityOnTarget(first_enemy, ability, parent:GetPlayerOwnerID())
            end   
        elseif ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_POINT) then
            if ability and IsValidEntity(ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                if self.pirate_cast then
                    local location = Vector(0, 0 , 0) 
                    local roll = RandomInt(1, 2)
                    if roll > 1 then
                        location =  pirate_loc1
                    else
                        location =  pirate_loc2
                    end    
                    parent:CastAbilityOnPosition(location, ability, parent:GetPlayerOwnerID())
                else
                    parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), ability, parent:GetPlayerOwnerID())  
                end
            end   
        elseif ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if ability and IsValidEntity(ability) and IsValidEntity(parent) and parent:IsAlive() then
                parent:CastAbilityNoTarget(ability, parent:GetPlayerOwnerID()) 
            end    
        elseif ability_behavior_includes(ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then	
            if ability and IsValidEntity(ability) and IsValidEntity(parent) and first_enemy:IsAlive() then
                parent:CastAbilityOnTarget(first_enemy, ability, parent:GetPlayerOwnerID())
            end    
        else
            return nil    
        end    
        return nil
    end
end   