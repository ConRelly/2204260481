LinkLuaModifier("modifier_mjz_techies_suicide_dummy", "abilities/hero_techies/mjz_techies_suicide.lua", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------

function SuicideJump( keys )
    local caster = keys.caster
    local target = keys.target 
    local ability = keys.ability
    local charge_speed = ability:GetLevelSpecialValueFor("charge_speed", (ability:GetLevel() - 1)) * 1/30
	
	-- Dummy
	local target_point = ability:GetCursorPosition()
	local dummy_name = 'npc_dota_invisible_vision_source' -- npc_dummy_unit
	local dummy = CreateUnitByName(dummy_name, target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = 10})
	dummy:AddNewModifier(caster, ability, "modifier_mjz_techies_suicide_dummy", {})
	-- dummy:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
	
	target = dummy 

	-- Motion Controller Data
    ability.target = target
    ability.velocity = charge_speed
    ability.life_break_z = 0
    ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target) - GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
    ability.traveled = 0

    -- caster:StartGesture(ACT_DOTA_ATTACK_STATUE)
end


function SuicideAttack( keys )
	local caster = keys.caster --施法者
	local point = keys.target_points[1]

	--添加相位移动，避免卡地形
	caster:AddNewModifier(nil, nil, "modifier_phased", {duration=0.7}) --[[Returns:void
	No Description Set
	]]
	local length_ever =  (point - caster:GetAbsOrigin()):Length()
	length_ever = length_ever / 10
	--for i=1,10 do
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("suicide_attack_time"), 
	function( )
	--判断单位是否死亡，是否存在，是否被击晕，是否正在施法
		if caster:IsAlive() and IsValidEntity(caster) and not(caster:IsStunned()) and caster:IsChanneling() then
			local caster_abs = caster:GetAbsOrigin()
		
			if (point - caster_abs):Length()>25 then
				local face = (point - caster_abs):Normalized() 
				local vec = face * length_ever
				caster:SetAbsOrigin(caster_abs + vec) --[[Returns:void
				SetAbsOrigin
				]]
				return 0.049
			else
				return nil
			end
		end
	end ,0)

end

function SuicideSucceeded( keys)
	local caster = keys.caster
	local ability = keys.ability

	if IsServer() then
		local radius = GetTalentSpecialValueFor(ability, 'radius')
		local base_damage = GetTalentSpecialValueFor(ability, 'damage')
		local hp_cost = GetTalentSpecialValueFor(ability, 'hp_cost')

		local silence_duration = GetTalentSpecialValueFor(ability, 'silence_duration')
		local damage = base_damage + caster:GetMaxHealth() * hp_cost / 100
		local ptc_hp_damage = ability:GetSpecialValueFor("current_hp") / 100

		EmitSoundOn("Hero_Techies.Suicide", caster)

		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
		-- ParticleManager:SetParticleControl(pfx, 2, Vector(1.5,1.5,1.5))

		KillTreesInRadius(caster, caster:GetAbsOrigin(), radius)

		-- local enemy_list = FindTargetEnemy(caster, caster:GetAbsOrigin(), radius)
		local enemy_list = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
			ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false )

		for _,enemy in pairs(enemy_list) do
			enemy:AddNewModifier(caster, ability, 'modifier_silence', {duration = silence_duration})
			local current_hp = math.floor(enemy:GetHealth() * ptc_hp_damage)
			ApplyDamage({ 
				victim = enemy, attacker = caster, ability = ability,
				damage = damage, damage_type = ability:GetAbilityDamageType() 
			})
			ApplyDamage({ 
				victim = enemy, attacker = caster, ability = ability,
				damage = current_hp, damage_type = ability:GetAbilityDamageType() 
			})			
		end
		caster:ModifyHealth(caster:GetHealth() - caster:GetMaxHealth() * (ability:GetSpecialValueFor("max_health_cost") / 100), ability, true, DOTA_DAMAGE_FLAG_HPLOSS)
	end
end

----------------------------------------------------------------------------
-- For this: gfycat.com/BraveHideousGiantschnauzer -> check: bit.ly/1KWulqA
--[[
	"06"
	{
		"var_type"							"FIELD_INTEGER"
		"charge_speed"						"1000"
	}
	"07"
	{
		"var_type"							"FIELD_FLOAT"
		"max_distance"						"1400"
	}
]]

function OnMotionDone( caster, target, ability )
	SuicideSucceeded({
		caster = caster, ability = ability
	})
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function JumpHorizonal( keys )
    -- Variables
    local caster = keys.target
    local ability = keys.ability
    local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()

    local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel()-1)


    -- Max distance break condition
    if (target_loc - caster_loc):Length2D() >= max_distance then
    	caster:InterruptMotionControllers(true)
    end

    -- Moving the caster closer to the target until it reaches the enemy
    if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
        ability.traveled = ability.traveled + ability.velocity
    else
        caster:InterruptMotionControllers(true)

        -- Move the caster to the ground
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))

		OnMotionDone(caster, target, ability)
    end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function JumpVertical( keys )
    -- Variables
    local caster = keys.target
    local ability = keys.ability
    local target = ability.target
    local caster_loc = caster:GetAbsOrigin()
    local caster_loc_ground = GetGroundPosition(caster_loc, caster)

    -- If we happen to be under the ground just pop the caster up
    if caster_loc.z < caster_loc_ground.z then
    	caster:SetAbsOrigin(caster_loc_ground)
    end

    -- For the first half of the distance the unit goes up and for the second half it goes down
    if ability.traveled < ability.initial_distance/2 then
        -- Go up
        -- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
        ability.life_break_z = ability.life_break_z + ability.velocity/2
        -- Set the new location to the current ground location + the memorized z point
        caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.life_break_z))
    elseif caster_loc.z > caster_loc_ground.z then
        -- Go down
        ability.life_break_z = ability.life_break_z - ability.velocity/2
        caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.life_break_z))
    end

end

-----------------------------------------------------------------------------------------

modifier_mjz_techies_suicide_dummy = class({})

function modifier_mjz_techies_suicide_dummy:IsHidden() return true end
function modifier_mjz_techies_suicide_dummy:IsPurgable() return false end

function modifier_mjz_techies_suicide_dummy:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
	return state
end

-----------------------------------------------------------------------------------------


function KillTreesInRadius(caster, center, radius)
    local particles = {
        "particles/newplayer_fx/npx_tree_break.vpcf",
        "particles/newplayer_fx/npx_tree_break_b.vpcf",
    }
    local particle = particles[math.random(1, #particles)]

    local trees = GridNav:GetAllTreesAroundPoint(center, radius, true)
    for _,tree in pairs(trees) do
        local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_fx, 0, tree:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_fx)
    end
    GridNav:DestroyTreesAroundPoint(center, radius, false)
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
	-- 支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
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


-- 是否学习了天赋技能
function HasTalentSpecialValueFor(ability, value)
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
		return talent and talent:GetLevel() > 0 
    end
    return false
end
