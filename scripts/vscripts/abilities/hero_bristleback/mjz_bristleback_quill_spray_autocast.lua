
local TARGET_ABILITY_NAME = 'bristleback_quill_spray_lua'
local TARGET_ABILITY_NAME_2 = "bristleback_viscous_nasal_goo_lua"
local MODIFIER_NAME = 'modifier_mjz_bristleback_quill_spray_autocast'
local THIS_LUA = "abilities/hero_bristleback/mjz_bristleback_quill_spray_autocast.lua"

LinkLuaModifier(MODIFIER_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------

mjz_bristleback_quill_spray_autocast = class({})
function mjz_bristleback_quill_spray_autocast:Spawn()
	if IsServer() then self:SetLevel(1) end
end
function mjz_bristleback_quill_spray_autocast:ProcsMagicStick() return false end
function mjz_bristleback_quill_spray_autocast:IsInnateAbility() return true end
function mjz_bristleback_quill_spray_autocast:OnHeroCalculateStatBonus(params)
	local quill = self:GetCaster():FindAbilityByName(TARGET_ABILITY_NAME)
	local goo = self:GetCaster():FindAbilityByName(TARGET_ABILITY_NAME_2)
	if quill and quill:GetLevel() > 0 then
		self:SetHidden(false)
	elseif goo and goo:GetLevel() > 0 and self:GetCaster():HasScepter() then
		self:SetHidden(false)
	else
		self:SetHidden(true)
	end
end
local ability_class = mjz_bristleback_quill_spray_autocast

function ability_class:OnToggle()
    if IsServer() then
        local caster = self:GetCaster()
        
        if self:GetToggleState() then
            caster:AddNewModifier(caster, self, MODIFIER_NAME, {})
        else
            caster:RemoveModifierByName(MODIFIER_NAME)
        end
    end
end


--------------------------------------------------------------------------------

modifier_mjz_bristleback_quill_spray_autocast = class({})
local modifier_class = modifier_mjz_bristleback_quill_spray_autocast

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        local tick_interval = ability:GetSpecialValueFor('tick_interval')
        self:StartIntervalThink(0.5)
    end

    function modifier_class:OnIntervalThink()
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local target_ability = nil
        local target_ability_2 = nil
        if IsServer() then
            target_ability = parent:FindAbilityByName(TARGET_ABILITY_NAME)
            target_ability_2 = parent:FindAbilityByName(TARGET_ABILITY_NAME_2)
        end   
        if target_ability == nil then return nil end
        if self:CanCastAbility(target_ability) then
            if IsServer() then 
                parent:CastAbilityNoTarget(target_ability, parent:GetPlayerOwnerID())
            end    
        end
        if target_ability_2 == nil then return nil end
        if target_ability_2 and self:CanCastAbility(target_ability_2) then
            self.target_ability_2_cast_time = self.target_ability_2_cast_time or 0
            local time = (GameRules:GetGameTime() - self.target_ability_2_cast_time) > 0.25
            if parent:HasScepter() and time then
                self.target_ability_2_cast_time = GameRules:GetGameTime()
                if IsServer() then
                    parent:CastAbilityNoTarget(target_ability_2, parent:GetPlayerOwnerID())
                end     
            end
        end

        --[[
            parent:SetCursorCastTarget(first_enemy)
            ability:OnSpellStart()
            ability:StartCooldown(ability:GetCooldownTimeRemaining())
        ]]
        
        --[[
            local order = {
                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                UnitIndex = parent:entindex(),
                Position = first_enemy:GetAbsOrigin(),
                AbilityIndex = ability:entindex()
            }
            ExecuteOrderFromTable(order)
        ]]
        
        -- parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), ability, parent:GetPlayerOwnerID())

    end

    function modifier_class:CanCastAbility(target_ability)
		local ability = self:GetAbility()
        local parent = self:GetParent()
        -- local target_ability = self:GetTargetAbility()

        -- if not ability:GetAutoCastState() then return nil end
        if not ability:GetToggleState() then return nil end
        if target_ability == nil then return nil end
        if target_ability:GetLevel() < 1 then return nil end
        if not target_ability:IsFullyCastable() then return nil end
        if not target_ability:IsCooldownReady() then return nil end
        if parent:IsIllusion() then return nil end
        if not parent:IsRealHero() then return nil end
        if IsChanneling(parent) then return nil end		-- 施法中
        if parent:IsSilenced() then return nil end		-- 沉默中
        
        return true
    end

    function modifier_class:HasEnemy()
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local target_ability = self:GetTargetAbility()

        -- local radius_auto = ability:GetSpecialValueFor("radius_auto")
        local radius_auto = 400
        local pos = parent:GetAbsOrigin()
        
        local enemy_list = FindUnitsInRadius(
            caster:GetTeamNumber(), pos, 
            nil, radius_auto, 
            target_ability:GetAbilityTargetTeam(), 
            target_ability:GetAbilityTargetType(), 
            target_ability:GetAbilityTargetFlags(),
            FIND_ANY_ORDER, false
        )
            
        return #enemy_list > 0
    end

    function modifier_class:GetTargetAbility()
        local parent = self:GetParent()
        if self.target_ability == nil then
            self.target_ability = parent:FindAbilityByName(TARGET_ABILITY_NAME)
            self.target_ability_2 = parent:FindAbilityByName(TARGET_ABILITY_NAME_2)
        end
        return self.target_ability
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

