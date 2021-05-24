
local THIS_LUA = "abilities/hero_axe/mjz_axe_culling_blade.lua"

LinkLuaModifier("modifier_mjz_axe_culling_blade_checker",THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_culling_blade_boost",THIS_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_axe_culling_blade = class({})
local ability_class = mjz_axe_culling_blade

function ability_class:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function ability_class:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor('splash_radius_scepter')
	end
	return self:GetSpecialValueFor('cast_range')
end
function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('cast_range')
end


if IsServer() then
	function ability_class:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self
		local target = self:GetCursorTarget()
		local base_damage = ability:GetSpecialValueFor("base_damage")
		local str_damage_multiplier = ability:GetSpecialValueFor("str_damage_multiplier")
		local splash_radius_scepter = ability:GetSpecialValueFor("splash_radius_scepter")

		local damage = base_damage + caster:GetStrength() * str_damage_multiplier
	
		local damage_table = {
			attacker = caster,
			victim = target,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
		}

		target:AddNewModifier(caster, ability, 'modifier_mjz_axe_culling_blade_checker', {})
		ApplyDamage(damage_table)
		self:PlayEffect(target)

		if caster:HasScepter() then
			local enemy_list = FindTargetEnemy(caster, target:GetAbsOrigin(), splash_radius_scepter)
			for _,enemy in pairs(enemy_list) do
				if enemy ~= target then
					damage_table.victim = enemy
					ApplyDamage(damage_table)
					self:PlayEffect(enemy)
				end
			end
		end

		target:RemoveModifierByName('modifier_mjz_axe_culling_blade_checker')
	end

	function ability_class:OnCullingBladeSuccess(target)
		local caster = self:GetCaster()
		local ability = self
		local speed_radius = ability:GetSpecialValueFor("speed_radius")
		local speed_duration = ability:GetSpecialValueFor("speed_duration")
		local sound_success = "Hero_Axe.Culling_Blade_Success"
		local modifier_boost_name = 'modifier_mjz_axe_culling_blade_boost'

		EmitSoundOn(sound_success, caster)

		local unit_list = FindTargetFriendly(caster, target:GetAbsOrigin(), speed_radius)
		for _,unit in pairs(unit_list) do
			unit:AddNewModifier(caster, ability, modifier_boost_name, {duration = speed_duration})
		end
	end

	function ability_class:OnCullingBladeFail(target)
		local caster = self:GetCaster()
		local ability = self
		local sound_fail = "Hero_Axe.Culling_Blade_Fail"
		EmitSoundOn(sound_fail, caster)
	end

	function ability_class:PlayEffect(target )
		local caster = self:GetCaster()
		local ability = self

		local p_name = "particles/units/heroes/hero_axe/axe_culling_blade.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( p_name, PATTACH_CUSTOMORIGIN, target );
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true );
		ParticleManager:ReleaseParticleIndex( nFXIndex );
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_axe_culling_blade_checker = class({})
local modifier_checker = modifier_mjz_axe_culling_blade_checker

function modifier_checker:IsHidden() return true end
function modifier_checker:IsPurgable() return false end
function modifier_checker:IsDebuff() return false end
function modifier_checker:IsBuff() return false end


if IsServer() then
	function modifier_checker:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_DEATH,
		}
	end

	function modifier_checker:OnDeath( )
		local ability = self:GetAbility()
		local target = self:GetParent()
		self.success = true
		ability:OnCullingBladeSuccess(target)
		self:Destroy()
	end

	function modifier_checker:OnCreated(table)
		self.success = false
	end
	
	function modifier_checker:OnDestroy()
		local ability = self:GetAbility()
		local target = self:GetParent()
		if self.success == false then
			ability:OnCullingBladeFail(target)
		end
	end
end
-----------------------------------------------------------------------------------------

modifier_mjz_axe_culling_blade_boost = class({})
local modifier_boost = modifier_mjz_axe_culling_blade_boost

function modifier_boost:IsHidden() return false end
function modifier_boost:IsPurgable() return true end
function modifier_boost:IsBuff() return true end

function modifier_boost:GetEffectName()
	return "particles/units/heroes/hero_axe/axe_cullingblade_sprint.vpcf"
end
function modifier_boost:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_boost:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_boost:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor('attack_speed_bonus')
end

function modifier_boost:GetModifierMoveSpeedBonus_Percentage(  )
	return self:GetAbility():GetSpecialValueFor('move_speed_bonus')
end

if IsServer() then
	function modifier_boost:OnCreated(table)
		local parent = self:GetParent()
		local p_name = "particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf"
		local p_boost = ParticleManager:CreateParticle(p_name, PATTACH_CUSTOMORIGIN, parent)
		ParticleManager:ReleaseParticleIndex(p_boost)
	end
end

-----------------------------------------------------------------------------------------


-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(caster, point, radius)
	local iTeamNumber = caster:GetTeamNumber()
	local vPosition = point 				-- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES     -- 无视魔法免疫
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	local bCanGrowCache = false             -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

-- 搜索目标位置所有的友方单位
function FindTargetFriendly(caster, point, radius)
	local iTeamNumber = caster:GetTeamNumber()
	local vPosition = point 				-- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_FRIENDLY  -- 目标是友方单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES     -- 无视魔法免疫
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

