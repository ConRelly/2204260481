LinkLuaModifier( "modifier_mjz_skywrath_mage_mystic_flare_thinker", "abilities/hero_skywrath_mage/mjz_skywrath_mage_mystic_flare.lua", LUA_MODIFIER_MOTION_NONE )

mjz_skywrath_mage_mystic_flare = class({})
local ability_class = mjz_skywrath_mage_mystic_flare

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_class:OnSpellStart()
	if not IsServer() then return end

	local ability = self
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local duration = ability:GetSpecialValueFor( "duration" )
	local radius = ability:GetSpecialValueFor( "radius" )
	local modifier_thinker_name = "modifier_mjz_skywrath_mage_mystic_flare_thinker"

	self:_CreateThinker(point)

	-- play effects
	local sound_cast = "Hero_SkywrathMage.MysticFlare.Cast"
	EmitSoundOn( sound_cast, caster )

	-- scepter effect
	if caster:HasScepter() then
		local scepter_radius = self:GetSpecialValueFor( "scepter_radius" )
		
		-- find nearby enemies
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			point,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			scepter_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			ability:GetAbilityTargetTeam(),	-- int, team filter
			ability:GetAbilityTargetType(),	-- int, type filter
			ability:GetAbilityTargetFlags(),	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local target = nil
		local creep = nil
		-- prioritize hero
		for _,enemy in pairs(enemies) do
			-- only enemies outside cast aoe
			if (enemy:GetOrigin() - point):Length2D() > radius then
				if enemy:IsHero() then
					target = enemy
					break
				elseif not creep then
					-- store first found creep
					creep = enemy
				end
			end
		end
		-- no secondary hero found, find creep
		if not target then
			target = creep
		end
		
		local another_point = nil
		if target then
			another_point = target:GetOrigin()
		else
			another_point = point + RandomVector(360)
		end

		self:_CreateThinker(another_point)
	end
end

function ability_class:_CreateThinker(point)

	local ability = self
	local caster = self:GetCaster()
	local duration = ability:GetSpecialValueFor( "duration" )
	local radius = ability:GetSpecialValueFor( "radius" )
	local modifier_thinker_name = "modifier_mjz_skywrath_mage_mystic_flare_thinker"

	-- create thinker
	CreateModifierThinker(
		caster, 	-- player source
		ability, 	-- ability source
		modifier_thinker_name, -- modifier name
		{ duration = duration }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)
	
	AddFOWViewer( caster:GetTeamNumber(), point, radius, duration, false)
end

--------------------------------------------------------------------------------

modifier_mjz_skywrath_mage_mystic_flare_thinker = class({})

--------------------------------------------------------------------------------
-- Initializations
function modifier_mjz_skywrath_mage_mystic_flare_thinker:OnCreated( kv )
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local interval = ability:GetSpecialValueFor( "damage_interval" )
	local base_damage = GetTalentSpecialValueFor(ability, "base_damage" )
	local int_multiplier = GetTalentSpecialValueFor(ability, "int_multiplier" )
	self.damage = base_damage + caster:GetIntellect() * int_multiplier
	self.radius = ability:GetSpecialValueFor( "radius" )
	self.damageTable = {
		-- victim = target,
		attacker = caster,
		-- damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability, --Optional.
		-- damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
	}

	-- Start interval
	self:StartIntervalThink( interval )
	self:OnIntervalThink()

	-- play effects
	self:PlayEffects( self.radius, kv.duration, interval )
end

function modifier_mjz_skywrath_mage_mystic_flare_thinker:OnRemoved()
end

function modifier_mjz_skywrath_mage_mystic_flare_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_mjz_skywrath_mage_mystic_flare_thinker:OnIntervalThink()
	local ability = self:GetAbility()

	-- find heroes
	local heroes = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		-- DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		-- DOTA_UNIT_TARGET_HERO,	-- int, type filter
		-- 0,	-- int, flag filter
		ability:GetAbilityTargetTeam(),	-- int, team filter
		ability:GetAbilityTargetType(),	-- int, type filter
		ability:GetAbilityTargetFlags(),	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if #heroes < 1 then return end
	for _,hero in pairs(heroes) do
		self.damageTable.victim = hero
		self.damageTable.damage = self.damage / #heroes
		if HasSuperScepter(self:GetCaster()) then
			self.damageTable.damage = self.damage * 2
		end
		ApplyDamage( self.damageTable )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_mjz_skywrath_mage_mystic_flare_thinker:PlayEffects( radius, duration, interval )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf"
	local sound_cast = "Hero_SkywrathMage.MysticFlare"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, duration, interval ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
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