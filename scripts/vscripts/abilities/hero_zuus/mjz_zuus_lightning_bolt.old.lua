LinkLuaModifier("modifier_mjz_zuus_lightning_bolt", "abilities/hero_zuus/mjz_zuus_lightning_bolt.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_zuus_lightning_bolt_charges", "abilities/hero_zuus/mjz_zuus_lightning_bolt.lua", LUA_MODIFIER_MOTION_NONE)


mjz_zuus_lightning_bolt = class({})
local ability_class = mjz_zuus_lightning_bolt

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_zuus_lightning_bolt"
end

function ability_class:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self
	local point = self:GetCursorPosition()
	local target = self:GetCursorTarget()
	
	local particle_name = "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf"
	local radius = ability:GetSpecialValueFor("spread_aoe")
	local sight_radius = ability:GetSpecialValueFor("sight_radius")
	local sight_duration = ability:GetSpecialValueFor("sight_duration")
	local ability_damage = ability:GetAbilityDamage()
	local stun_time = GetTalentSpecialValueFor(ability, "stun_time")


	local damage = self:CalcDamage()
	if damage == 0 then 
		return false
	else
		ability:EndCooldown()
		ability:StartCooldown(self:GetRestoreTime())
	end

	-- Checks if the ability was ground targeted (target will be the targeted entity otherwise)
	if target == nil then
		-- Finds all heroes in the radius (the closest hero takes priority over the closest creep)
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO, 0, 0, false)
		local closest = radius
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = point - unit_location
			local distance = (vector_distance):Length2D()
			-- If the hero is closer than the closest checked so far, then we set its distance as the new closest distance and it as the new target
			if distance < closest then
				closest = distance
				target = unit
			end
		end
	end

	-- Checks if the target was set in the last block (checking for heroes in the aoe)
	if target == nil then
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
		local closest = radius
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = point - unit_location
			local distance = (vector_distance):Length2D()
			-- If the hero is closer than the closest checked so far, then we set its distance as the new closest distance and it as the new target
			if distance < closest then
				closest = distance
				target = unit
			end
		end
	end

	-- Gives vision to the caster's team in the radius
	AddFOWViewer(caster:GetTeam(), point, sight_radius, sight_duration, false)

	-- Checks if the target has been set yet
	if target ~= nil then
		-- Applies the ministun and the damage to the target
		target:AddNewModifier(caster, ability, "modifier_stun", {Duration = stun_time})
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

		if create_popup_by_damage_type then
			create_popup_by_damage_type({
				target = target,
				value = damage,
				-- color = Vector(255, 20, 147),
				type = "spell"
			}, ability) 
		end

		-- Renders the particle on the target
		local particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, target)
		-- Raise 1000 value if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 0, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
		ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1000 ))
		ParticleManager:SetParticleControl(particle, 2, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	else
		-- Renders the particle on the ground target
		local particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, caster)
		-- Raise 1000 value if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 0, Vector(point.x,point.y,point.z))
		ParticleManager:SetParticleControl(particle, 1, Vector(point.x,point.y,1000))
		ParticleManager:SetParticleControl(particle, 2, Vector(point.x,point.y,point.z))
	end
end


function ability_class:GetRestoreTime( )
	local caster = self:GetCaster()
	local ability = self
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local charge_restore_time = GetTalentSpecialValueFor(ability, "charge_restore_time")

	return cooldown * caster:GetCooldownReduction()
end

function ability_class:CalcDamage( )
	local caster = self:GetCaster()
	local ability = self
	local pszScriptName = "modifier_mjz_zuus_lightning_bolt_charges"
	local ability_damage = ability:GetAbilityDamage()
	local int_damage_pct = GetTalentSpecialValueFor(ability, "int_damage")
	
	if IsValidEntity(caster) and caster:IsRealHero() then
		local int_damage = caster:GetIntellect(false) * (int_damage_pct / 100)
		ability_damage = ability_damage + int_damage
	end

	local m_charges = caster:FindModifierByName(pszScriptName)
	if m_charges then
		local damage = ability_damage * m_charges:GetStackCount()
		m_charges:SetStackCount(0)
		return damage
	end
	return 0
end

-----------------------------------------------------------------------------------------

modifier_mjz_zuus_lightning_bolt = class({})
function modifier_mjz_zuus_lightning_bolt:IsHidden() return true end
function modifier_mjz_zuus_lightning_bolt:IsPurgable() return false end
-- 效果永久，死亡不消失
function modifier_mjz_zuus_lightning_bolt:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

if IsServer() then
	function modifier_mjz_zuus_lightning_bolt:OnCreated(table)
		local ability = self:GetAbility()
		local flInterval = 0.1
		self._prev_restore_time = 0
		self:StartIntervalThink(0.1)
	end
	function modifier_mjz_zuus_lightning_bolt:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		-- if ability and ability:GetLevel() > 0 then
		-- 	return false
		-- end
		
		local pszScriptName = "modifier_mjz_zuus_lightning_bolt_charges"
		local charges = GetTalentSpecialValueFor(ability, "charges")
		local charge_restore_time = ability:GetRestoreTime()

		local m_charges = parent:FindModifierByName(pszScriptName)
		if m_charges == nil then
			m_charges = parent:AddNewModifier(parent, ability, pszScriptName, {})
		end

		if m_charges and m_charges:GetStackCount() == charges then
			self._prev_restore_time = GameRules:GetGameTime()
			m_charges:SetDuration(-1, true)
			return false
		end

		if m_charges and m_charges:GetStackCount() < charges then
			if m_charges:GetDuration() == -1 then
				m_charges:SetDuration(charge_restore_time + 0.1, true)
			end
		end

		if (GameRules:GetGameTime() - self._prev_restore_time) > charge_restore_time then
			self._prev_restore_time = GameRules:GetGameTime()

			m_charges:IncrementStackCount()
			m_charges:SetDuration(charge_restore_time + 0.1, true)
		end
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_zuus_lightning_bolt_charges = class({})
function modifier_mjz_zuus_lightning_bolt_charges:IsHidden() return false end
function modifier_mjz_zuus_lightning_bolt_charges:IsPurgable() return false end
-- 效果永久，死亡不消失
function modifier_mjz_zuus_lightning_bolt_charges:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end


-----------------------------------------------------------------------------------------
-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(caster, point, radius)
	local iTeamNumber = caster:GetTeamNumber()
	local vPosition = point					-- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE -- 忽视建筑物
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

