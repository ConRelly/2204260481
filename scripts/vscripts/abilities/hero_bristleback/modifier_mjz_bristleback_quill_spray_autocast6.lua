require("lib/my")
require("lib/timers")
--local TARGET_ABILITY_NAME = 'bristleback_quill_spray'
--local TARGET_ABILITY_NAME_2 = "zuus_arc_lightning"
--[[local MODIFIER_NAME = 'modifier_mjz_bristleback_quill_spray_autocast6'
local THIS_LUA = "abilities/hero_bristleback/mjz_bristleback_quill_spray_autocast6.lua"

LinkLuaModifier(MODIFIER_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------

mjz_bristleback_quill_spray_autocast6 = class({})
local ability_class = mjz_bristleback_quill_spray_autocast6

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
end]]


--------------------------------------------------------------------------------

modifier_mjz_bristleback_quill_spray_autocast6 = class({})
local modifier_class = modifier_mjz_bristleback_quill_spray_autocast6

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:GetTexture() return "extra_mode" end

--if IsServer() then
function modifier_class:OnCreated(table)
    if IsServer() then
        --local ability = self:GetAbility()
        local skip = RandomInt(18, 35) / 10
        local parent = self:GetParent()
        Timers:CreateTimer({
            endTime = skip, 
            callback = function()
                if parent and parent:IsAlive() then
                    self:StartIntervalThink(1)
                end    
            end
        }) 
    end                    
end

function modifier_class:OnIntervalThink()
    if IsServer() then
        --local ability = self:GetAbility()
        local caster = self:GetParent()
        local parent = self:GetParent()
        if parent == nil then return nil end
        if not parent:IsAlive() and not self:IsNull() then
            self:Destroy()
            return nil
        end
        --if not ability:GetToggleState() then return nil end
        for i=6,parent:GetAbilityCount() -1 do
            if parent == nil then return nil end
            if not parent:IsAlive() and not self:IsNull() then
                self:Destroy()
                return nil
            end            
            local target_ability = parent:GetAbilityByIndex( i ) 
            --local number = parent:GetAbilityCount()
            if target_ability and not target_ability:IsAttributeBonus() and not target_ability:IsPassive() and not target_ability:IsHidden() and not target_ability:IsToggle() and target_ability:GetLevel() > 0 and target_ability:IsCooldownReady() and target_ability:IsFullyCastable() and not IsChanneling(parent) and not target_ability:IsInAbilityPhase() and not ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_CHANNELLED) then  -- Talent-- Dunno
                --print(number .. " skills")
                --if target_ability:IsInAbilityPhase() then return nil end
                --if not target_ability:IsCooldownReady() then return nil end
                if parent == nil then return nil end
                if not parent:IsAlive() then return nil end
                if target_ability == nil then return nil end
                if parent:IsIllusion() then return nil end
                --if not parent:IsRealHero() then return nil end
                if IsChanneling(parent) then return nil end		
                if parent:IsSilenced() then return nil end
                if parent:IsStunned() then return nil end


                local radius_auto = target_ability:GetCastRange(parent:GetAbsOrigin(), parent) + caster:GetCastRangeBonus()
                if radius_auto < 100 then
                    radius_auto = 1000
                end      
                local pos = parent:GetAbsOrigin()
                local charges = target_ability:GetCurrentAbilityCharges() 
                if ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
                    --parent:CastAbilityNoTarget(target_ability, -1)
                    --if IsServer() then
                    parent:SetCursorTargetingNothing(true)
                    if target_ability and parent:IsAlive() then                    
                        target_ability:OnSpellStart()
                        target_ability:UseResources(true, false, true)                     
                        if charges > 0 then
                            target_ability:SetCurrentAbilityCharges(charges - 1) 
                        end
                    end
                    --end                           
                    return nil
                elseif ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then	
                    --parent:CastAbilityOnTarget(parent, target_ability, -1)
                    --if IsServer() then
                    parent:SetCursorCastTarget(parent)
                    if target_ability and parent:IsAlive() then                    
                        target_ability:OnSpellStart()
                        target_ability:UseResources(true, false, true)                     
                        if charges > 0 then
                            target_ability:SetCurrentAbilityCharges(charges - 1) 
                        end
                    end
                    --end                                            
                    return nil           
                end
                --local enemy_list = nil
                --if IsServer() then                           
                local enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
                        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, target_ability:GetAbilityTargetFlags(),
                        FIND_ANY_ORDER, false)
                --end        
                    
                if #enemy_list > 0 then
                    local first_enemy = enemy_list[1]
                            
                    if target_ability == nil then return nil end 
                    if parent == nil then return nil end
                    if ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and (target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH) then
                        --parent:CastAbilityOnTarget(first_enemy, target_ability, -1)
                        --if IsServer() then
                        parent:SetCursorCastTarget(first_enemy)
                        --end    
                        --target_ability:OnSpellStart()
                        --target_ability:UseResources(true, false, true)                                          
                    elseif ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
                        --if IsServer() then
                        parent:SetCursorPosition(first_enemy:GetAbsOrigin())
                        --end
                        --target_ability:OnSpellStart()
                        --target_ability:UseResources(true, false, true)                       
                        --parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), target_ability, -1)
                    elseif ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
                        --if IsServer() then
                        parent:SetCursorTargetingNothing(true)
                        --end   
                        --target_ability:OnSpellStart()
                        --target_ability:UseResources(true, false, true)
                        --parent:CastAbilityNoTarget(target_ability, -1) 
                    elseif ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then	
                        --parent:CastAbilityOnTarget(parent, target_ability, -1)
                        --if IsServer() then
                        parent:SetCursorCastTarget(first_enemy)
                        --end                           
                    else
                        return nil    
                    end
                    if target_ability and parent:IsAlive() and first_enemy:IsAlive() then
                        --if IsServer() then                    
                        target_ability:OnSpellStart()
                        target_ability:UseResources(true, false, true)                     
                        if charges > 0 then
                            target_ability:SetCurrentAbilityCharges(charges - 1) 
                        end
                        --end   
                    end                        
                    return nil
                end
            end       
        end
    end           
end

function modifier_class:OnDestroy( )

end



-----------------------------------------------------------------------------------------
--if IsServer() then
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
--end
