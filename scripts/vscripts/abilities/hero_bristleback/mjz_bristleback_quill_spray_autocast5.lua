
--local TARGET_ABILITY_NAME = 'bristleback_quill_spray'
local TARGET_ABILITY_NAME_2 = "shadow_demon_shadow_poison"
local MODIFIER_NAME = 'modifier_mjz_bristleback_quill_spray_autocast5'
local THIS_LUA = "abilities/hero_bristleback/mjz_bristleback_quill_spray_autocast5.lua"

LinkLuaModifier(MODIFIER_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------

mjz_bristleback_quill_spray_autocast5 = class({})
local ability_class = mjz_bristleback_quill_spray_autocast5

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

modifier_mjz_bristleback_quill_spray_autocast5 = class({})
local modifier_class = modifier_mjz_bristleback_quill_spray_autocast5

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

--if IsServer() then
function modifier_class:OnCreated(table)
    local ability = self:GetAbility()
    local tick_interval = ability:GetSpecialValueFor('tick_interval')
    self:StartIntervalThink(tick_interval)       
end

function modifier_class:OnIntervalThink()
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local target_ability = nil
    if not IsValidEntity(parent) then return nil end
    if IsServer() then   
        target_ability = parent:FindAbilityByName(TARGET_ABILITY_NAME_2)
    end   
    if target_ability == nil then return nil end
    if not IsValidEntity(target_ability) then return nil end
    if not ability:GetToggleState() then return nil end
    if not target_ability:IsCooldownReady() then return nil end
    if target_ability:GetLevel() < 1 then return nil end
    if not target_ability:IsFullyCastable() then return nil end
    if parent:IsIllusion() then return nil end
    if not parent:IsRealHero() then return nil end
    if IsChanneling(parent) then return nil end		-- 施法中
    if parent:IsSilenced() then return nil end		-- 沉默中        

    --if self:CanCastAbility(target_ability) then 
    --    parent:CastAbilityNoTarget(target_ability, parent:GetPlayerOwnerID())
    --end

    --[[if target_ability_2 and self:CanCastAbility(target_ability_2) then
        self.target_ability_2_cast_time = self.target_ability_2_cast_time or 0
        local time = (GameRules:GetGameTime() - self.target_ability_2_cast_time) > 0.25
        --if parent:HasScepter() and time then
        --    self.target_ability_2_cast_time = GameRules:GetGameTime()
        --      parent:CastAbilityNoTarget(target_ability_2, parent:GetPlayerOwnerID())
        --end
    end]]

    local radius_auto = 1850 + caster:GetCastRangeBonus()
    local pos = parent:GetAbsOrigin()        
    local enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
            target_ability:GetAbilityTargetTeam(), target_ability:GetAbilityTargetType(), target_ability:GetAbilityTargetFlags(),
            FIND_ANY_ORDER, false)  
    if #enemy_list > 0 then
        local first_enemy = enemy_list[1]
                
    
        --[[parent:SetCursorCastTarget(first_enemy)
        target_ability:OnSpellStart()
        target_ability:StartCooldown(target_ability:GetCooldownTimeRemaining())]]
    
    
    
        --[[local order = {
            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,     --OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            UnitIndex = parent:entindex(),
            TargetIndex = first_enemy:entindex(),              --Position = first_enemy:GetAbsOrigin(),
            AbilityIndex = target_ability:entindex()
        }
        ExecuteOrderFromTable(order)]]
        if IsServer() then
            if not IsValidEntity(first_enemy) then return nil end
            if not IsValidEntity(target_ability) then return nil end 
            if not IsValidEntity(parent) then return nil end 
            if not first_enemy:IsAlive() then return nil end
            if not parent:IsAlive() then return nil end
            parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), target_ability, parent:GetPlayerOwnerID())
        end    
        --parent:CastAbilityOnTarget(first_enemy, target_ability, parent:GetPlayerOwnerID()) --parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), target_ability, parent:GetPlayerOwnerID())
    end   
end

--end


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

