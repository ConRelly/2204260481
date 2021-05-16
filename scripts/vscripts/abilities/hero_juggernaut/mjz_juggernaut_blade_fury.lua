

function BladeFuryStop(event)
    local caster = event.caster

    caster:StopSound("Hero_Juggernaut.BladeFuryStart")
end


function AttackTarget( keys )
	local caster = keys.caster
	local attacker = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	attacker:PerformAttack (
        target,     			-- handle hTarget 
        true,       			-- bool bProcessProcs,		
        true,     				-- bool bUseCastAttackOrb, 	是否使用攻击法球、特效
        true,       			-- bool bSkipCooldown		是否跳过攻击间隔
        true,      				-- bool bIgnoreInvis		是否忽略隐形单位
        false,      			-- bool bUseProjectile		是否使用攻击投射物
        false,      			-- bool bFakeAttack			
        false      				-- bool bNeverMiss			是否不会Miss
    )
end

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
