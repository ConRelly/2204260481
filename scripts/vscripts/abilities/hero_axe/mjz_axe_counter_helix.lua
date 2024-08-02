
function OnAttackStart( keys )
	local caster = keys.caster
	if HasTalent(caster, 'special_bonus_unique_axe_3_custom') then
		CounterHelix(keys)
	end
end

function OnAttacked( keys )
	CounterHelix(keys)
end


function CounterHelix( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local helix_modifier = keys.helix_modifier

	-- If the caster has the helix modifier then do not trigger the counter helix
	-- as its considered to be on cooldown
	if not caster:HasModifier(helix_modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, helix_modifier, {})
	end
end

function ActionDamageToTarget( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local target = event.target
	local attacker = caster
	local ability = event.ability
	
	if caster:IsIllusion() then return nil end

	local caster_strength = caster:GetStrength()
	local damage_type = ability:GetAbilityDamageType()
	local damage_base = ability:GetLevelSpecialValueFor('damage', ability:GetLevel() - 1)
	local strength_per = ability:GetLevelSpecialValueFor('strength_per', ability:GetLevel() - 1)
	local damage_amount = damage_base + caster_strength * (strength_per / 100)
	
	-- print('damage_amount: '..damage_amount)

	local dmg_table_target = {
		victim = target,
		attacker = attacker,
		damage = damage_amount,
		damage_type = damage_type,
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY,  -- 无视技能免疫
		ability = ability,
	}
	ApplyDamage(dmg_table_target)
end



-----------------------------------------------------------------------------

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
	local iTeamNumber = unit:GetTeamNumber()
	local vPosition = point   				-- 搜索中心点
	local hCacheUnit = nil				  -- 通常值
	local flRadius = radius				 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP		   
	-- 忽视建筑物、支持魔法免疫
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
	local iOrder = FIND_CLOSEST						 -- 寻找最近的
	local bCanGrowCache = false			 -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end


-- 是否学习指定天赋技能
function HasTalent(unit, talentName)
	if unit:HasAbility(talentName) then
		if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
	if unit:HasAbility(talentName) then
		return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
	end
	return nil
end


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

