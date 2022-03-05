require("lib/my")
--local TARGET_ABILITY_NAME = 'bristleback_quill_spray'
--local TARGET_ABILITY_NAME_2 = "zuus_arc_lightning"
local MODIFIER_NAME = 'modifier_mjz_bristleback_quill_spray_autocast4'
local THIS_LUA = "abilities/hero_bristleback/mjz_bristleback_quill_spray_autocast4.lua"

LinkLuaModifier(MODIFIER_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------

mjz_bristleback_quill_spray_autocast4 = class({})
local ability_class = mjz_bristleback_quill_spray_autocast4

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

modifier_mjz_bristleback_quill_spray_autocast4 = class({})
local modifier_class = modifier_mjz_bristleback_quill_spray_autocast4

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end


function modifier_class:OnCreated(table)
    if IsServer() then
        local ability = self:GetAbility()
        local tick_interval = ability:GetSpecialValueFor('tick_interval')

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


};

function modifier_class:OnIntervalThink()
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        if not ability:GetToggleState() then return nil end
        if parent == nil then return nil end
        --local target_ability = parent:GetAbilityByIndex(2)
        --local target_ability_2 = self.target_ability_2
        if not IsValidEntity(parent) then return nil end
        for i=6,parent:GetAbilityCount() -1 do

            if parent == nil then return nil end
            local target_ability = parent:GetAbilityByIndex( i )       
            if target_ability and IsValidEntity(target_ability) and not target_ability:IsAttributeBonus() and not target_ability:IsHidden() and not target_ability:IsToggle() and target_ability:IsActivated() and target_ability:GetLevel() > 0 then  -- Talent-- Dunno
                if target_ability:IsInAbilityPhase() then return nil end
                --if not ability:GetToggleState() then return nil end
                local ability_name = target_ability:GetAbilityName()
                if NoAutocast[ability_name] == true then return end
                if not IsValidEntity(parent) then return nil end
                if not target_ability:IsCooldownReady() then return nil end
                if target_ability == nil then return nil end
                --if target_ability:GetLevel() < 1 then return nil end
                if not target_ability:IsFullyCastable() then return nil end
                if parent:IsIllusion() then return nil end
                if not parent:IsRealHero() then return nil end
                if IsChanneling(parent) then return nil end		-- 施法中
                if parent:IsSilenced() then return nil end		-- 沉默中
                if parent:HasModifier("modifier_brewmaster_primal_split") and not target_ability:GetAbilityName() ~= "brewmaster_primal_split" then return nil end

                local radius_auto = target_ability:GetCastRange(parent:GetAbsOrigin(), parent) + caster:GetCastRangeBonus() - 50
                if radius_auto < 100 then
                    radius_auto = 500
                end    
                local pos = parent:GetAbsOrigin()
                    if ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) and not (target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH)  then
                        if target_ability and IsValidEntity(target_ability) and IsValidEntity(parent) and parent:IsAlive() then
                            parent:CastAbilityNoTarget(target_ability, parent:GetPlayerOwnerID())
                        end    
                        return nil
                    end   
                local enemy_list = 0
                if target_ability:GetAbilityTargetType() ~= 0 then                          
                    enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
                        target_ability:GetAbilityTargetTeam(), target_ability:GetAbilityTargetType(), target_ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                        FIND_ANY_ORDER, false)
                elseif target_ability:GetAbilityTargetTeam() ~= 0 then
                        enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
                            target_ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                            FIND_ANY_ORDER, false)                         
                else
                    enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
                        DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_ability:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                        FIND_ANY_ORDER, false) 
                end                       
                if #enemy_list > 0 then
                    local first_enemy = enemy_list[1]
                    if target_ability == nil then return nil end 
                    if parent == nil then return nil end                   
                        if ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and (target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH) then
                            if target_ability and IsValidEntity(target_ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                                parent:CastAbilityOnTarget(first_enemy, target_ability, parent:GetPlayerOwnerID())
                            end   
                        elseif ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
                            if target_ability and IsValidEntity(target_ability) and IsValidEntity(first_enemy) and IsValidEntity(parent) and parent:IsAlive() and first_enemy:IsAlive() then
                                parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), target_ability, parent:GetPlayerOwnerID())
                            end   
                        elseif ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
                            if target_ability and IsValidEntity(target_ability) and IsValidEntity(parent) and parent:IsAlive() then
                                parent:CastAbilityNoTarget(target_ability, parent:GetPlayerOwnerID()) 
                            end    
                        elseif ability_behavior_includes(target_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and target_ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then	
                            if target_ability and IsValidEntity(target_ability) and IsValidEntity(parent) and parent:IsAlive() then
                                parent:CastAbilityOnTarget(parent, target_ability, parent:GetPlayerOwnerID())
                            end    
                        else
                            return nil    
                        end    
                    return nil
                end
            end       
        end 
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

