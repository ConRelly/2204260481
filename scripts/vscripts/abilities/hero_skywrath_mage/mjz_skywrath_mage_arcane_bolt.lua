
mjz_skywrath_mage_arcane_bolt = class({})
local ability_class = mjz_skywrath_mage_arcane_bolt

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor("cast_range")
end

function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local target_count = GetTalentSpecialValueFor(ability, "target_count")
		local target_count_scepter = GetTalentSpecialValueFor(ability, "target_count_scepter")

		local count = target_count
		if caster:HasScepter() then
			count = target_count_scepter
		end

		local target_list = self:_GetTargets(count)

		for i=1,count do
			if #target_list < i then
				self:_FireArcaneBolt(target)
			else
				self:_FireArcaneBolt(target_list[i])
			end
		end

		EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Cast", caster)
	end

	function ability_class:_GetTargets(count)
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local search_radius = ability:GetSpecialValueFor("search_radius")

		local target_list = {target}

		local hero_list = FindTargetHeroEnemy(caster, target, search_radius)
		for _,hero in pairs(hero_list) do
			if #target_list >= count then
				break
			end
			if hero ~= target then
				table.insert(target_list, hero)
			end
		end

		local basic_list = FindTargetBaseEnemy(caster, target, search_radius)
		for _,basic in pairs(basic_list) do
			if #target_list >= count then
				break
			end
			if basic ~= target then
				table.insert(target_list, basic)
			end
		end

		return target_list
	end

	function ability_class:_FireArcaneBolt(target)
		local ability = self
		local caster = self:GetCaster()
		local bolt_speed = ability:GetSpecialValueFor("bolt_speed")
		local bolt_vision = ability:GetSpecialValueFor("bolt_vision")
		local particle_projectile = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf"

		local intelligence = 0
		if IsValidEntity(caster) and caster:IsHero() then
			intelligence = caster:GetIntellect(false)
			if caster:HasModifier("modifier_item_echo_wand") then
				bolt_speed = bolt_speed * 4
			end	
		end

		-- Fire projectile at target
		local arcane_bolt_projectile = {
			Target = target,
			Source = caster,
			Ability = ability,
			EffectName = particle_projectile,
			iMoveSpeed = bolt_speed,
			bDodgeable = false, 
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			bProvidesVision = true,
			iVisionRadius = bolt_vision,
			iVisionTeamNumber = caster:GetTeamNumber(),
			ExtraData = {int = intelligence}
		}
		ProjectileManager:CreateTrackingProjectile(arcane_bolt_projectile)

	end

	function ability_class:OnProjectileHit_ExtraData(target, location, extra_data)
		local caster = self:GetCaster()
		local ability = self
		local sound_impact = "Hero_SkywrathMage.ArcaneBolt.Impact"    

		-- Ability specials
		local bolt_damage = ability:GetSpecialValueFor("bolt_damage")
		local int_multiplier = ability:GetSpecialValueFor("int_multiplier")
		local vision_duration  = ability:GetSpecialValueFor("vision_duration")
		local bolt_vision = ability:GetSpecialValueFor("bolt_vision")

		-- Extra data
		local caster_int = extra_data.int

		-- If there was no target, do nothing
		if not target then
			return nil
		end

		-- If the target became magic immune, do nothing
		if target:IsMagicImmune() then
			return nil
		end

		-- If target has Linken's Sphere off cooldown, do nothing
		if target:GetTeam() ~= caster:GetTeam() then
			if target:TriggerSpellAbsorb(ability) then
				return nil
			end
		end

		-- Play sound
		EmitSoundOn(sound_impact, target)

		-- Add flying vision in the impact area
		AddFOWViewer(caster:GetTeamNumber(),
					location,
					bolt_vision,
					vision_duration,
					false)

		-- Calculate damage
		local damage = bolt_damage + caster_int * int_multiplier

		-- Deal damage to target
		local damageTable = {
			victim = target,
			attacker = caster, 
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability
		}
			
		ApplyDamage(damageTable)
	end
	
end



-----------------------------------------------------------------------------------------

-- 搜索目标位置所有的英雄敌人单位
function FindTargetHeroEnemy(unit, target, radius)
	local iTeamNumber = unit:GetTeamNumber()
	local vPosition = target:GetAbsOrigin() -- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE     -- 忽视建筑物
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	iOrder = FIND_ANY_ORDER								-- 随机
	local bCanGrowCache = false             -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

-- 搜索目标位置所有的基础敌人单位
function FindTargetBaseEnemy(unit, target, radius)
	local iTeamNumber = unit:GetTeamNumber()
	local vPosition = target:GetAbsOrigin() -- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE     -- 忽视建筑物
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	iOrder = FIND_ANY_ORDER								-- 随机
	local bCanGrowCache = false             -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
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