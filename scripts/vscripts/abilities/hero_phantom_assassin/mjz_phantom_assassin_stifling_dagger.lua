LinkLuaModifier("modifier_mjz_stifling_dagger_slow", "modifiers/hero_phantom_assassin/modifier_mjz_phantom_assassin_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_stifling_dagger_attack_factor", "modifiers/hero_phantom_assassin/modifier_mjz_phantom_assassin_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_stifling_dagger_attack_bonus", "modifiers/hero_phantom_assassin/modifier_mjz_phantom_assassin_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------------

mjz_phantom_assassin_stifling_dagger = class({})

function mjz_phantom_assassin_stifling_dagger:GetAOERadius()
	return self:GetSpecialValueFor('search_radius')
end

function mjz_phantom_assassin_stifling_dagger:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('cast_range')
end


function mjz_phantom_assassin_stifling_dagger:OnSpellStart( )
	if not IsServer() then return nil end
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()

	local search_radius = GetTalentSpecialValueFor(ability, "search_radius")
	local target_count =  GetTalentSpecialValueFor(ability, "target_count")
	local dagger_speed = ability:GetSpecialValueFor('dagger_speed')

	local effect_name = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf"
	local projectile_info = 
	{
		Target = target,
		Source = caster,
		Ability = ability,	
		EffectName = effect_name,
			iMoveSpeed = dagger_speed,
		vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
		bDrawsOnMinimap = false,                          -- Optional
			bDodgeable = true,                                -- Optional
			bIsAttack = false,                                -- Optional
			bVisibleToEnemies = true,                         -- Optional
			bReplaceExisting = false,                         -- Optional
			flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
		bProvidesVision = true,                           -- Optional
		iVisionRadius = 400,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile(projectile_info)
	caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")

	local count = 1
	local units = GetTargets(caster, ability, target, search_radius)
	for _,unit in pairs(units) do
		if count < target_count and unit ~= target then
			count = count + 1
			projectile_info.Target = unit
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end
end

function mjz_phantom_assassin_stifling_dagger:OnProjectileHit(target, location)
	if not IsServer() then return nil end
	local caster = self:GetCaster()
	local ability = self

	local base_damage = GetTalentSpecialValueFor(ability, "base_damage")
	local slow_duration = GetTalentSpecialValueFor(ability, 'slow_duration')
	local MODIFIER_SLOW = 'modifier_mjz_stifling_dagger_slow'
	local MODIFIER_ATTACK_FACTOR = 'modifier_mjz_stifling_dagger_attack_factor'
	local MODIFIER_ATTACK_BONUS = 'modifier_mjz_stifling_dagger_attack_bonus'

	if target:TriggerSpellAbsorb(ability) then return nil end

	--[[
		ApplyDamage({
			victim = target, 
			attacker = caster, 
			ability = ability, 
			damage = base_damage, 
			damage_type = ability:GetAbilityDamageType()
		})
	]]

	caster:AddNewModifier(caster, ability, MODIFIER_ATTACK_FACTOR, {duration = 0.03})
	caster:AddNewModifier(caster, ability, MODIFIER_ATTACK_BONUS, {duration = 0.03})
	-- caster:AttackReady()
	-- print('PerformAttack ....')
	caster:PerformAttack (
        target,     -- handle hTarget 
        true,       -- bool bUseCastAttackOrb, 
        true,       -- bool bProcessProcs,
        true,       -- bool bSkipCooldown
        false,      -- bool bIgnoreInvis
        false,       -- bool bUseProjectile
        false,      -- bool bFakeAttack
        true        -- bool bNeverMiss  可敌先机
	)
	-- print('PerformAttack done.')
	caster:RemoveModifierByName(MODIFIER_ATTACK_BONUS)
	caster:RemoveModifierByName(MODIFIER_ATTACK_FACTOR)

	target:AddNewModifier(caster, ability, MODIFIER_SLOW, {duration = slow_duration})
end

----------------------------------------------------------------------------------------------

function GetTargets( caster, ability, target, radius )
	return FindUnitsInRadius(
		caster:GetTeam(),
		target:GetAbsOrigin(),
		nil, radius, 
		ability:GetAbilityTargetTeam(), 
		ability:GetAbilityTargetType(), 
		ability:GetAbilityTargetFlags(), 
		FIND_ANY_ORDER, false)
end


function RandomFromTable(table, count)
	return table[RandomInt(1, #table)]
end


-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
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
