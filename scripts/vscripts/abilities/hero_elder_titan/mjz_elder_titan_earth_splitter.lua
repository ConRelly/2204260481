-- LinkLuaModifier("modifier_mjz_elder_titan_earth_splitter", "abilities/hero_elder_titan/mjz_elder_titan_earth_splitter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_elder_titan_earth_splitter_slow", "abilities/hero_elder_titan/mjz_elder_titan_earth_splitter.lua", LUA_MODIFIER_MOTION_NONE)

mjz_elder_titan_earth_splitter = class({})
local ability_class = mjz_elder_titan_earth_splitter

-- function ability_class:GetIntrinsicModifierName()
-- 	return "modifier_mjz_elder_titan_earth_splitter"
-- end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local ab_return = caster:FindAbilityByName("elder_titan_return_spirit")

		self:_Spell(caster)
		
		local unitSpirit = self:_FindSpirit()
		if unitSpirit and IsValidEntity(unitSpirit) and unitSpirit:IsAlive() then
			if ab_return and not ab_return:IsHidden() then
				unitSpirit:StartGesture(ACT_DOTA_CAST_ABILITY_5)
				self:_Spell(unitSpirit)
			end
		else
			-- print("spirit not found")
		end
	end

	function ability_class:_Spell(spawnUnit)
		local ability = self
		local caster = self:GetCaster()
		spawnUnit = spawnUnit or caster
		local crack_time = GetTalentSpecialValueFor(ability, "crack_time")

		EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", spawnUnit)

		local point_list = self:_GetPointList(spawnUnit)
		for _,point in pairs(point_list) do
			self:_SpellPoint(point, spawnUnit)
		end

		Timers:CreateTimer(crack_time, function ()
			EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", spawnUnit)
		end)
	end

	function ability_class:_GetPointList(spawnUnit)
		local ability = self
		local caster = self:GetCaster()
		spawnUnit = spawnUnit or caster
		local casterLoc = spawnUnit:GetAbsOrigin()
		local casterAngle = spawnUnit:GetAngles().y
		local crack_distance = GetTalentSpecialValueFor(ability, "crack_distance")
		local angle = 0

		-- 正前方
		local point_zero = GetRotationPoint(casterLoc, crack_distance, casterAngle)

		-- 360度
		local point_list_360 = {}
		for i=1,16 do
			local point = GetRotationPoint(casterLoc, crack_distance, angle + RandomInt(-5, 10))
			table.insert( point_list_360, point )
			angle = angle + (360 / 16)
		end

		-- 前方三个点，角度 30
		local point_list_fan_3 = {}
		local point_30 = GetRotationPoint(casterLoc, crack_distance, casterAngle + 30)
		local point_330 = GetRotationPoint(casterLoc, crack_distance, casterAngle + 330)
		table.insert( point_list_fan_3, point_zero )
		table.insert( point_list_fan_3, point_30 )
		table.insert( point_list_fan_3, point_330 )

		if caster:HasScepter() then
			return point_list_fan_3
		else
			return {point_zero}
		end
	end

	function ability_class:_SpellPoint(point, spawnUnit)
		local ability = self
		local caster = self:GetCaster()
		spawnUnit = spawnUnit or caster
		local casterLoc = spawnUnit:GetAbsOrigin()
		local crack_time = GetTalentSpecialValueFor(ability, "crack_time")
		local crack_width = GetTalentSpecialValueFor(ability, "crack_width")
		local str_damage_multiplier = GetTalentSpecialValueFor(ability, "str_damage_multiplier")
		local damage = caster:GetStrength() * str_damage_multiplier
		local slow_duration = GetTalentSpecialValueFor(ability, "slow_duration")
		local modifier_slow_name = 'modifier_mjz_elder_titan_earth_splitter_slow'

		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(p, 0, casterLoc)
		ParticleManager:SetParticleControl(p, 1, point)
		ParticleManager:SetParticleControl(p, 3, Vector(0, crack_time, 0))
		ParticleManager:SetParticleControl(p, 11, point)
		ParticleManager:SetParticleControl(p, 12, point)

		Timers:CreateTimer(crack_time, function ()
			local unitGroup = GetUnitsInLine(caster, ability, casterLoc, point, crack_width)
			for _,unit in pairs(unitGroup) do
				unit:AddNewModifier(caster, ability, modifier_slow_name, {duration = slow_duration})

				local damageTable = {
					victim = unit,
					attacker = caster,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(),
					ability = ability,
				}
				ApplyDamage(damageTable)
			end
		end)
	end

	function ability_class:_FindSpirit()
		local caster = self:GetCaster()
		local unitName = "npc_dota_elder_titan_ancestral_spirit"
		local radius = 3000
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		-- for _,unit in pairs(units) do
		-- 	print("find : " .. unit:GetUnitName())
		-- 	if unit:GetUnitName() == unitName then
		-- 		return unit
		-- 	end
		-- end

		local es = Entities:FindAllByName(unitName)
		for _,unit in pairs(es) do
			-- print("find : " .. unit:GetName())
			if unit:GetName() == unitName then
				return unit
			end
		end

		return nil
	end
end

---------------------------------------------------------------------------------------

-- modifier_mjz_elder_titan_earth_splitter = class({})

-- function modifier_mjz_elder_titan_earth_splitter:IsHidden() return false end
-- function modifier_mjz_elder_titan_earth_splitter:IsPurgable() return true end



---------------------------------------------------------------------------------------

modifier_mjz_elder_titan_earth_splitter_slow = class({})
local modifier_class = modifier_mjz_elder_titan_earth_splitter_slow

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return true end
function modifier_class:IsDebuff() return true end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_class:GetModifierMoveSpeedBonus_Percentage( )
	return self:GetAbility():GetSpecialValueFor('slow_pct')
end

-----------------------------------------------------------------------------------------

-- 获取旋转后的点
function GetRotationPoint( originPoint, radius, angle )
	local radAngle = math.rad(angle)
	local x = math.cos(radAngle) * radius + originPoint.x
	local y = math.sin(radAngle) * radius + originPoint.y
	local position = Vector(x, y, originPoint.z)
	return position
end

-- 寻找直线范围单位
function GetUnitsInLine( caster, ability, start_point, end_point, width )
	local teamNumber = caster:GetTeamNumber()
	local targetTeam = ability:GetAbilityTargetTeam()
	local targetType = ability:GetAbilityTargetType()
	local targetFlag = ability:GetAbilityTargetFlags()
	local unitGroup = FindUnitsInLine( teamNumber, start_point, end_point, caster, width, targetTeam, targetType, targetFlag)
    return unitGroup
end

-- 寻找扇形单位
function GetUnitsInSector( cacheUnit, ability, position, forwardVector, angle, radius )
	local teamNumber = cacheUnit:GetTeamNumber()
	local teamFilter = ability:GetAbilityTargetTeam()
	local typeFilter = ability:GetAbilityTargetType()
	local flagFilter = ability:GetAbilityTargetFlags()
	local unitGroup = FindUnitsInRadius( teamNumber, position, cacheUnit, radius, teamFilter, typeFilter, flagFilter, 0, false )
	local returnGroup = {}
	for k, v in pairs( unitGroup ) do
		local unitPosition = v:GetAbsOrigin()
		local unitVector = unitPosition - position
		local NAN = math.floor(unitVector:Dot(forwardVector) / math.sqrt((unitVector.x ^ 2 + unitVector.y ^ 2) * (forwardVector.x ^ 2 + forwardVector.y ^ 2)))
		--print("nan:"..nan)
		if NAN == 1 then
			table.insert( returnGroup, v )
			--print("nan")
		else
			local unitAngle = math.abs(math.deg(math.acos( unitVector:Dot(forwardVector) / math.sqrt((unitVector.x ^ 2 + unitVector.y ^ 2) * (forwardVector.x ^ 2 + forwardVector.y ^ 2)))))
			--print("angle:"..unitAngle)
			--print("dot:"..unitVector:Dot(forwardVector))
			--print("acos"..( unitVector:Dot(forwardVector) / math.sqrt((unitVector.x ^ 2 + unitVector.y ^ 2) * (forwardVector.x ^ 2 + forwardVector.y ^ 2))))
			local deleteAngle = angle * 0.5
			if unitAngle < deleteAngle then
				table.insert( returnGroup, v )
				--print("units:"..#returnGroup)
			end
		end
	end
    return returnGroup
end


function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	direction.z = 0
	return direction
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