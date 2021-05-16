

function OnSpellStart( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local point = event.point
	local ability = event.ability
	local target_point = event.target_points[1]
	local playerOwnerID = caster:GetPlayerOwnerID()
	local search_radius = ability:GetLevelSpecialValueFor( "search_radius" , ability:GetLevel() - 1 )

	local modifier_name_dagger_in_path = "modifier_spectre_spectral_dagger_in_path"

	local can_work = false
	local point = target_point

	-- 转移到中了幽鬼之刃的敌方单位的位置
	local enemy_list = FindTargetEnemy(caster, target_point, search_radius)
	for _,enemy in pairs(enemy_list) do
		if enemy and enemy:HasModifier(modifier_name_dagger_in_path) then
			can_work = true
			point = enemy:GetAbsOrigin()
			break
		end
	end
	
	-- 转移到幻象的位置，幻象会消失
	if not can_work then
		local hero_list = FindTargetHero(caster, target_point, search_radius)
		for _,hero in pairs(hero_list) do
			if hero and hero:IsHero() and hero:IsIllusion() then
				if hero:GetPlayerOwnerID() == playerOwnerID then
					can_work = true
					point = hero:GetAbsOrigin()
					if hero._mjz_spectre_haunt_illusion then
						local caster_point = caster:GetAbsOrigin()
						hero:SetAbsOrigin(caster_point)
						FindClearSpaceForUnit(hero, caster_point, false)
					else
						hero:Kill(nil, nil)
					end
					break					
				end
			end
		end
	end
	
	if can_work then
		caster:SetAbsOrigin(point)
		FindClearSpaceForUnit(caster, point, false)
	end
end

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
    local iTypeFilter = DOTA_UNIT_TARGET_ALL --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE     -- 忽视建筑物
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

-- 搜索目标位置所有的友方英雄单位
function FindTargetHero(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_FRIENDLY  -- 目标是友方单位
    -- 目标单位类型
    local iTypeFilter =DOTA_UNIT_TARGET_HERO         
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE     -- 忽视建筑物
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end