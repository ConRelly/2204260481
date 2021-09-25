LinkLuaModifier( "modifier_mjz_slark_essence_shift_heap", "abilities/hero_slark/mjz_slark_essence_shift.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_slark_essence_shift_heap_aura", "abilities/hero_slark/mjz_slark_essence_shift.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_slark_essence_shift_fast_attack", "abilities/hero_slark/mjz_slark_essence_shift.lua" ,LUA_MODIFIER_MOTION_NONE )

mjz_slark_essence_shift = class({})
local ability_class = mjz_slark_essence_shift
local modifier_stack_name = "modifier_mjz_slark_essence_shift_heap"

function ability_class:GetIntrinsicModifierName()
	return modifier_stack_name
end

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor("heap_range")
end
function ability_class:AllowIllusionDuplicate()
    return true
end    

function ability_class:OnSpellStart()
	if not IsServer() then return end

	local ability = self
	local caster = self:GetCaster()
	local pszScriptName = "modifier_mjz_slark_essence_shift_fast_attack"

	if caster:HasModifier(pszScriptName) then
		return false
	end
	ability:SetActivated(false)
	caster:AddNewModifier(caster, ability, pszScriptName, {})
end

function ability_class:FastAttack(target)
	local ability = self
	local caster = self:GetCaster()
	local attack_count = self:GetTalentSpecialValueFor(ability, 'attack_count')

	caster:EmitSound("Hero_Slark.Pounce.Impact")
	for i = 1, attack_count do
		if IsValidEntity(target) then
			caster:PerformAttack(target, true, true, true, true, true, false, false)
		end
	end

	ability:SetActivated(true)
end

function ability_class:OnEnemyDiedNearby( hVictim, hKiller, kv )
	if hVictim == nil or hKiller == nil or hVictim:IsIllusion()  then
		return
	end

	local caster = self:GetCaster()
	local heap_range = self:GetSpecialValueFor( "heap_range" )

	if hVictim:GetTeamNumber() ~= caster:GetTeamNumber() and caster:IsAlive() then
		local vToCaster = caster:GetOrigin() - hVictim:GetOrigin()
		local flDistance = vToCaster:Length2D()
        local extra_stack = "special_bonus_unique_mjz_slark_essence_shift_attack_count"
		if hKiller == caster or heap_range >= flDistance then
			if self.nKills == nil then
				self.nKills = 0
			end

			self.nKills = self.nKills + 1
			if HasTalent(caster, extra_stack) then
				self.nKills = self.nKills + 1
			end	
			local hBuff = caster:FindModifierByName(modifier_stack_name)
			if hBuff ~= nil then
				hBuff:SetStackCount( self.nKills )
				caster:CalculateStatBonus(false)
			end

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end

function ability_class:GetHeapKills()
	if self.nKills == nil then
		self.nKills = 0
	end
	return self.nKills
end





modifier_mjz_slark_essence_shift_heap = class({})

local modifier_class = modifier_mjz_slark_essence_shift_heap

function modifier_class:IsHidden() return (self:GetStackCount() < 1) end
function modifier_class:IsPurgable() return false end	
function modifier_class:AllowIllusionDuplicate()
    return true
end   
function modifier_class:OnCreated( kv )
	
	local ability = self:GetAbility()
	self.heap_amount = ability:GetSpecialValueFor("heap_amount")
	self.heap_type = ability:GetSpecialValueFor("heap_type")
	self.heap_type = self.heap_type or 1
    if IsServer() then 
        self:SetStackCount( ability:GetHeapKills() )
        self:GetParent():CalculateStatBonus(false)
	end
end

function modifier_class:OnRefresh( kv )
    if not self:GetAbility() then self:Destroy() end
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
        --MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
	}

	return funcs
end

function modifier_class:GetModifierBonusStats_Strength()
	local ability = self:GetAbility()
    if ability then
        local heap_amount = ability:GetSpecialValueFor("heap_amount")	
        local heap_type = ability:GetSpecialValueFor( "heap_type" )
        if heap_type == 2 then
            return self:GetStackCount() * heap_amount
        else
            return 0
        end
    end   
end
function modifier_class:GetModifierBonusStats_Agility()
	local ability = self:GetAbility()
    if ability then
        local heap_amount = ability:GetSpecialValueFor("heap_amount")	
        local heap_type = ability:GetSpecialValueFor( "heap_type" )
        if heap_type == 2 then
            return self:GetStackCount() * heap_amount
        else
            return 0
        end
    end
end
--[[function modifier_class:GetModifierBonusStats_Intellect()
    if self.heap_type == 3 then
        return self:GetStackCount() * self.heap_amount
    else
        return 0
    end
end]]
function modifier_class:GetModifierBaseAttackTimeConstant()
    local ability = self:GetAbility()
    if ability then
	    return self:GetAbility():GetSpecialValueFor("bat")
    end   
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
    local ability = self:GetAbility()
    if ability then
	    return self:GetAbility():GetSpecialValueFor( "heap_range" )
    end
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
        if not IsValidEntity(ability) then return end
        self:Destroy()

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


function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function ability_class:GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or 'value'
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end


function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end


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