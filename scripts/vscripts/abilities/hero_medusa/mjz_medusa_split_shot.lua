
function OnToggleOn( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster._attacking = false
	caster._active_split_shot = true
end

function OnToggleOff( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster._attacking = false	
	if caster:IsAlive() then	-- 死亡时自动关闭
		caster._active_split_shot = false
	end
end

function OnOwnerSpawned( keys )
	-- print('OnOwnerSpawned')
	print('active: '.. tostring( keys.caster._active_split_shot))
	local caster = keys.caster
	local ability = keys.ability
	if caster._active_split_shot then
		ability:ToggleAbility()
	end
end

function OnOwnerDied( keys )
	-- print('OnOwnerDied')
	local caster = keys.caster
	local ability = keys.ability
	-- 死亡后 Toggle 状态为 false
	-- caster._active_split_shot = ability:GetToggleState()
end

-- 是否使用攻击法球
function IsUseCastAttackOrb( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:GetSpecialValueFor('UseCastAttackOrb') > 0 then
		return true
	end

	if HasTalent(caster, 'special_bonus_unique_medusa_4') then
		return true
	end

	return false
end

function OnAttackStart( keys )
	if IsUseCastAttackOrb(keys) then
		UseOrbAttack(keys)
	else
		SplitShotLaunch(keys)
	end
end

------------------------------------------------------------------------

function UseOrbAttack( keys )
	local caster = keys.caster
	if caster._attacking then
		return
	end

	-- print('UseOrbAttack')
	caster._attacking = true
	
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Targeting variables
	local target_type = ability:GetAbilityTargetType()
	local target_team = ability:GetAbilityTargetTeam()
	local target_flags = ability:GetAbilityTargetFlags()
	local attack_target = caster:GetAttackTarget()

	-- Ability variables
	local radius = ability:GetLevelSpecialValueFor("range", ability_level)
	radius = radius + caster:GetAttackRangeBuffer()
	-- local max_targets = ability:GetLevelSpecialValueFor("arrow_count", ability_level)
	local max_targets = GetTalentSpecialValueFor(ability, "arrow_count")
	-- local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
	-- local split_shot_projectile = keys.split_shot_projectile

	-- local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)
	local split_shot_targets = FindTargetEnemy(caster, caster_location, radius)
	
	for _,v in pairs(split_shot_targets) do
		if v ~= attack_target then
			AttackTarget(caster, v, true)
			max_targets = max_targets - 1
		end
		-- If we reached the maximum amount of targets then break the loop
		if max_targets == 0 then break end
	end
	caster._attacking = false
end

function AttackTarget( attacker, target, bUseCastAttackOrb)
	attacker:PerformAttack (
        target,     			-- handle hTarget 
        true,       			-- bool bProcessProcs,		
        bUseCastAttackOrb,     	-- bool bUseCastAttackOrb, 	是否使用攻击法球、特效
        true,       			-- bool bSkipCooldown		是否跳过攻击间隔
        true,      				-- bool bIgnoreInvis		是否忽略隐形单位
        true,      				-- bool bUseProjectile		是否使用攻击投射物
        false,      			-- bool bFakeAttack			
        false      				-- bool bNeverMiss			是否不会Miss
    )
end

-------------------------------------------------------------------------

--[[
	Creates additional attack projectiles for units within the specified radius around the caster]]
function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Targeting variables
	local target_type = ability:GetAbilityTargetType()
	local target_team = ability:GetAbilityTargetTeam()
	local target_flags = ability:GetAbilityTargetFlags()
	local attack_target = caster:GetAttackTarget()

	-- Ability variables
	local radius = ability:GetLevelSpecialValueFor("range", ability_level)
	-- local max_targets = ability:GetLevelSpecialValueFor("arrow_count", ability_level)
	local max_targets = GetTalentSpecialValueFor(ability, "arrow_count")
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
	local split_shot_projectile = keys.split_shot_projectile

	-- local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)
	local split_shot_targets = FindTargetEnemy(caster, caster_location, radius)

	-- Create projectiles for units that are not the casters current attack target
	for _,v in pairs(split_shot_targets) do
		if v ~= attack_target then
			local projectile_info = 
			{
				EffectName = split_shot_projectile,
				Ability = ability,
				vSpawnOrigin = caster_location,
				Target = v,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = projectile_speed,
				bReplaceExisting = false,
				bProvidesVision = false
			}
			ProjectileManager:CreateTrackingProjectile(projectile_info)
			max_targets = max_targets - 1
		end
		-- If we reached the maximum amount of targets then break the loop
		if max_targets == 0 then break end
	end
end

-- Apply the auto attack damage to the hit unit
function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage_amount = caster:GetAttackDamage()

	local dmg_table_target = {
		victim = target,
		attacker = caster,
		damage = damage_amount,
        damage_type = ability:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY,  -- 无视技能免疫
	    ability = ability,
	}
	ApplyDamage(dmg_table_target)
end

---------------------------------------------------------------------------------------------------------------

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
