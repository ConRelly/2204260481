LinkLuaModifier("modifier_mjz_zuus_static_field", "abilities/hero_zuus/mjz_zuus_static_field.lua", LUA_MODIFIER_MOTION_NONE)

mjz_zuus_static_field = class({})
local ability_class = mjz_zuus_static_field

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_zuus_static_field"
end

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius') + self:GetCaster():GetCastRangeBonus()
end

-----------------------------------------------------------------------------------------

modifier_mjz_zuus_static_field = class({})
local modifier_class = modifier_mjz_zuus_static_field

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated()
		local parent = self:GetParent()
		local ability = self:GetAbility()
	end

	function modifier_class:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		}
	end

	function modifier_class:OnAbilityExecuted( params )
		if params.unit == self:GetParent() then
			local hUnit = params.unit
			local hAbility = params.ability 
			if IsAbiltiy(hUnit, hAbility) then
				self:_ApplyDamage()
			end
		end
		return 0
	end

	function modifier_class:_ApplyDamage()
		local caster = self:GetParent()
		local ability = self:GetAbility()

		if caster:PassivesDisabled() then return nil end

		local radius = ability:GetSpecialValueFor('radius')
		local base_damage = ability:GetSpecialValueFor("base_damage")
		local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		local damage = base_damage + caster:GetIntellect(false) * (intelligence_damage / 100.0)

		local sound_name = "Hero_Zuus.StaticField"
		local particle_name = "particles/units/heroes/hero_zuus/zuus_static_field.vpcf"
		
		EmitSoundOn(sound_name, caster)
		
		local units = FindTargetEnemy(caster, caster:GetAbsOrigin(), radius)

		for _,unit in pairs(units) do
			local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, unit)
			ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)

			

			ApplyDamage({
				attacker = caster,
				victim = unit,
				ability = ability,
				damage_type = ability:GetAbilityDamageType(),
				damage = damage
			})	
		end
	end

	function IsAbiltiy(caster, ability)
		if ability == nil then return false end
		if ability:IsItem() then return false end
		if ability:IsToggle() then return false end
		if ability:IsPassive() then return false end
	
		local is_ability = false
		for i=0, 15 do
			local ability_index = caster:GetAbilityByIndex(i)
			if ability_index ~= null then
				if ability_index:GetName() == ability:GetName() then
					is_ability = true
				end
			end
		end
		return is_ability
	end

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

