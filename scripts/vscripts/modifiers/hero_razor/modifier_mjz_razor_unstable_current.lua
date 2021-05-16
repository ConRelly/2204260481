
modifier_mjz_razor_unstable_current = class({})
local modifier_class = modifier_mjz_razor_unstable_current

function modifier_class:IsPassive()
	return true
end
function modifier_class:IsHidden()
	return true
end
function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end


if IsServer() then
    function modifier_class:OnRefresh(table)
    end
    
    function modifier_class:OnCreated( kv )
        local caster = self:GetParent()
        local ability = self:GetAbility()
        
        if IsServer() then
            if not caster:IsIllusion() then
                self:StartIntervalThink(0.25)		
            end
        end
    end
    
    function modifier_class:OnDestroy()
        self:StartIntervalThink(-1)		-- stop
    end

    function modifier_class:OnIntervalThink( )
        local ability = self:GetAbility()
        
        if ability:IsToggle() then
            self:_MovementSpeed()
            self:_SpellStart()
        end
    end
    
    function modifier_class:_SpellStart( )
        local caster = self:GetCaster()
        local ability = self:GetAbility()

        if caster:IsIllusion() then return nil end

		if ability:_IsReady() then
			local radius = ability:GetAOERadius()
			local enemy_list = FindTargetEnemy(caster, caster:GetAbsOrigin(), radius)

			if #enemy_list > 0 then
                ability:_StartCooldown()

				caster:EmitSound('Hero_Razor.UnstableCurrent.Strike')

                local damage_base = GetTalentSpecialValueFor(ability, 'passive_area_damage')
				local attack_damage_pct = ability:GetSpecialValueFor('attack_damage_pct')
				local caster_attack = caster:GetAverageTrueAttackDamage(caster)
                local damage_attack = caster_attack * ( attack_damage_pct / 100)
                local damage_amount = damage_base + damage_attack

				for _,enemy in pairs(enemy_list) do
					self:_SpellTarget(enemy, damage_amount)
				end
			end
		end
    end

	function modifier_class:_SpellTarget( target, damage )
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		target:EmitSound('Hero_Razor.UnstableCurrent.Target')

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_unstable_current.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "follow_origin", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT, "follow_origin", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)

		local damage_info = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		}
		ApplyDamage( damage_info )
    end
    
    function modifier_class:_MovementSpeed( )
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local specialName = 'movement_speed_pct'
        local talentName = 'special_bonus_unique_razor_3'

        local movement_speed_pct = GetTalentSpecialValueFor(ability, specialName)
        
        local modifier_name = 'modifier_mjz_razor_unstable_current_speed'
        local modifier = caster:FindModifierByName(modifier_name)
        if modifier then
            if modifier:GetStackCount() ~= movement_speed_pct then
                modifier:SetStackCount(movement_speed_pct)
            end
        else
            caster:AddNewModifier(caster, ability, modifier_name, {movement_speed_pct = movement_speed_pct})
            modifier = caster:FindModifierByName(modifier_name)
            modifier:SetStackCount(movement_speed_pct)
        end
    end
end


LinkLuaModifier("modifier_mjz_razor_unstable_current_speed", "modifiers/hero_razor/modifier_mjz_razor_unstable_current.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_razor_unstable_current_speed = class({})
local modifier_speed = modifier_mjz_razor_unstable_current_speed

function modifier_speed:IsHidden()
	return true
end
function modifier_speed:IsPurgable()	-- 能否被驱散
	return false
end
function modifier_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_speed:GetModifierMoveSpeedBonus_Percentage(keys)
    local movement_speed_pct = self:GetStackCount()
    return movement_speed_pct
end


 
---------------------------------------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end


-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
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

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor2(ability, value, talentName)
    local base = ability:GetSpecialValueFor(value)
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
	-- 仅针对可见的单位、忽视建筑物、支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

