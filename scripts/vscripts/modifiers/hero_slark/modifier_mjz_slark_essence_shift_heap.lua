
modifier_mjz_slark_essence_shift_heap = class({})

local modifier_class = modifier_mjz_slark_essence_shift_heap

function modifier_class:IsHidden( )
    return false
end
function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end	
function modifier_class:GetPriority()
	return MODIFIER_PRIORITY_LOW 
end
function modifier_class:OnCreated( kv )
     
        local ability = self:GetAbility()
        self.heap_amount = ability:GetSpecialValueFor("heap_amount")
        self.heap_type = ability:GetSpecialValueFor( "heap_type" )
        self.heap_type = self.heap_type or 1
    if IsServer() then 
        self:SetStackCount( ability:GetHeapKills() )
        self:GetParent():CalculateStatBonus(false)
	end
end

function modifier_class:OnRefresh( kv )
    local ability = self:GetAbility()
    self.heap_amount = ability:GetSpecialValueFor("heap_amount")
    if IsServer() then
		self:GetParent():CalculateStatBonus(false)
	end
end

function modifier_class:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
	}

	return funcs
end

function modifier_class:GetModifierBonusStats_Strength()
    if self.heap_type == 2 then
        return self:GetStackCount() * self.heap_amount
    else
        return 0
    end
end
function modifier_class:GetModifierBonusStats_Agility()
    if self.heap_type == 2 then
        return self:GetStackCount() * self.heap_amount
    else
        return 0
    end
end
function modifier_class:GetModifierBonusStats_Intellect()
    if self.heap_type == 3 then
        return self:GetStackCount() * self.heap_amount
    else
        return 0
    end
end
function modifier_class:GetModifierBaseAttackTimeConstant()
	return self:GetAbility():GetSpecialValueFor("bat")
end	

--------------------------------------------------------------

function modifier_class:IsAura()
	return true
end

function modifier_class:GetModifierAura()
	return "modifier_mjz_slark_essence_shift_heap_aura"
end

function modifier_class:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_class:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_class:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_class:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "heap_range" )
end


-------------------------------------------------------------------

modifier_mjz_slark_essence_shift_heap_aura = class({})
local modifier_heap_aura = modifier_mjz_slark_essence_shift_heap_aura

function modifier_heap_aura:IsHidden()
    return true
end
function modifier_heap_aura:IsPurgable()	-- 能否被驱散
	return false
end

if IsServer() then
    function modifier_heap_aura:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_DEATH
        }
    end
    function modifier_heap_aura:OnDeath(event)
        if self:GetParent() ~= event.unit then return end

        if IsServer() then
            local ability = self:GetAbility()
            local hVictim = event.unit
            local hKiller = event.attacker
            ability:OnEnemyDiedNearby(hVictim, hKiller, event)
        end
   
    end
end


-------------------------------------------------------------------

modifier_mjz_slark_essence_shift_fast_attack = class({})
local modifier_fast_attack = modifier_mjz_slark_essence_shift_fast_attack

function modifier_fast_attack:IsHidden()
    return false
end
function modifier_fast_attack:IsPurgable()	-- 能否被驱散
	return false
end

function modifier_fast_attack:DeclareFunctions()
    if IsServer() then
        return {
            MODIFIER_EVENT_ON_ATTACK,			
        }
    else
        return {
            MODIFIER_PROPERTY_TOOLTIP
        }
    end 
end
function modifier_fast_attack:OnTooltip()
	return self:GetStackCount()
end


if IsServer() then
   
    function modifier_fast_attack:OnAttack(keys)
        if keys.attacker ~= self:GetParent() then return nil end
        
        if self.expend then return nil end
        self.expend = true

		if keys.target:IsBuilding() then return nil end
		-- if self:GetParent():PassivesDisabled() then return nil end
        if self:TargetIsFriendly(self:GetParent(), keys.target) then return nil end
        
        
        local attacker = keys.attacker
		local target = keys.target
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
        if not self:IsNull() then
            self:Destroy()
        end            

        ability:FastAttack(target)
    end	

    function modifier_fast_attack:OnCreated()
		local ability = self:GetAbility()
        local attack_count = GetTalentSpecialValueFor(ability, 'attack_count')
        self:SetStackCount(attack_count)
    end

    function modifier_fast_attack:OnDestroy()
		local ability = self:GetAbility()
        ability:SetActivated(true)
    end
    
    function modifier_fast_attack:TargetIsFriendly(caster, target )
        local nTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY 	-- ability:GetAbilityTargetTeam()
        local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
        local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
        local nTeam = caster:GetTeamNumber()
        local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
        return ufResult == UF_SUCCESS
    end
    
end



-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end
