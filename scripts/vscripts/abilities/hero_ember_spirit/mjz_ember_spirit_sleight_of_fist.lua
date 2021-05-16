
require("lib/timers_v1_05")

local MODIFIER_LUA = 'modifiers/hero_ember_spirit/modifier_mjz_ember_spirit_sleight_of_fist.lua'
local MODIFIER_CASTER_NAME = 'modifier_mjz_ember_spirit_sleight_of_fist_caster'
local MODIFIER_DUMMY_NAME = 'modifier_mjz_ember_spirit_sleight_of_fist_dummy'
local MODIFIER_TARGET_NAME = 'modifier_mjz_ember_spirit_sleight_of_fist_target'
local MODIFIER_CRIT_NAME = 'modifier_mjz_ember_spirit_sleight_of_fist_crit'
local MODIFIER_CHARGE_COUNTER_NAME = 'modifier_mjz_ember_spirit_sleight_of_fist_charge_counter'
local MODIFIER_CHARGE_NAME = 'modifier_mjz_ember_spirit_sleight_of_fist_charge'


LinkLuaModifier(MODIFIER_CASTER_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_DUMMY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_TARGET_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_CRIT_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_CHARGE_COUNTER_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_CHARGE_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)


---------------------------------------------------------------------------------------
mjz_ember_spirit_sleight_of_fist = class({})

local ability_class = mjz_ember_spirit_sleight_of_fist

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end

function ability_class:GetIntrinsicModifierName()
	return MODIFIER_CHARGE_COUNTER_NAME
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local targetPoint = self:GetCursorPosition()
       

		if not caster:HasModifier(MODIFIER_CASTER_NAME) then
			caster:AddNewModifier(caster, ability, MODIFIER_CASTER_NAME, {})
		end

		caster:EmitSound("Hero_EmberSpirit.SleightOfFist.Cast")

		self:sleight_of_fist_init(caster, ability, targetPoint)

		self:_RestoreCharge()
	end

	function ability_class:_RestoreCharge()
		local ability = self
		local caster = self:GetCaster()
		local charge_count = GetTalentSpecialValueFor(ability, 'charge_count')
		local charge_restore_time = ability:GetSpecialValueFor('charge_restore_time')

		if charge_count == 0 then return nil end

		local current_charge = ability._current_charge or 0
		if current_charge > 0 then
			current_charge = current_charge - 1	
		end

		ability._current_charge = current_charge
		if caster:HasModifier(MODIFIER_CHARGE_COUNTER_NAME) then
			caster:SetModifierStackCount( MODIFIER_CHARGE_COUNTER_NAME, caster, ability._current_charge )
		end
		
		if current_charge > 0 then
			ability:EndCooldown()
			ability:StartCooldown(0.5)
		else
			ability:StartCooldown( ability:GetCooldownTimeRemaining() )
		end

		if ability._current_charge < charge_count then
			local modifier = caster:FindModifierByName(MODIFIER_CHARGE_NAME)
			if modifier then
				modifier:ForceRefresh()
			else
				caster:AddNewModifier(caster, ability, MODIFIER_CHARGE_NAME, {duration = charge_restore_time})
			end
		end
	end

	--[[
		Author: kritth
		Date: 13.01.2015.
		Mark targets, jump to attack, ignore if invisible
	]]
	function ability_class:sleight_of_fist_init( caster, ability, targetPoint)
		-- Cannot cast multiple stacks
		if caster.sleight_of_fist_active ~= nil and caster.sleight_of_fist_action == true then
			ability:RefundManaCost()
			return nil
		end

		-- Inheritted variables
		-- local caster = keys.caster
		-- local targetPoint = keys.target_points[1]
		-- local ability = keys.ability
		local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
		local attack_interval = ability:GetLevelSpecialValueFor( "attack_interval", ability:GetLevel() - 1 )
		local modifierTargetName = MODIFIER_TARGET_NAME
		local modifierHeroName = MODIFIER_CRIT_NAME
		local modifierCreepName = MODIFIER_CRIT_NAME
		local casterModifierName = MODIFIER_CASTER_NAME
		local dummyModifierName = MODIFIER_DUMMY_NAME
		local particleSlashName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf"
		local particleTrailName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf"
		local particleCastName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf"
		local slashSound = "Hero_EmberSpirit.SleightOfFist.Damage"
		
		-- Targeting variables
		-- local targetTeam = ability:GetAbilityTargetTeam()		-- DOTA_UNIT_TARGET_TEAM_ENEMY
		-- local targetType = ability:GetAbilityTargetType()		-- DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		-- local targetFlag = ability:GetAbilityTargetFlags() 		-- DOTA_UNIT_TARGET_FLAG_NO_INVIS
		-- local unitOrder = FIND_ANY_ORDER
		
		-- Necessary varaibles
		local counter = 0
		caster.sleight_of_fist_active = true
		local dummy_name = 'npc_dota_invisible_vision_source' 	-- caster:GetName()
		local dummy = CreateUnitByName(dummy_name , caster:GetAbsOrigin(), false, caster, nil, caster:GetTeamNumber() )
		dummy:SetForwardVector(caster:GetForwardVector())
		dummy:AddNewModifier(caster, ability, dummyModifierName, {})
		
		-- Casting particles
		local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( castFxIndex, 0, targetPoint )
		ParticleManager:SetParticleControl( castFxIndex, 1, Vector( radius, 0, 0 ) )
		
		Timers:CreateTimer( 0.1, function()
				ParticleManager:DestroyParticle( castFxIndex, false )
				ParticleManager:ReleaseParticleIndex( castFxIndex )
			end
		)
		
		-- Start function
		local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
		
		local units = self:FindEnemies(caster, ability, targetPoint)
		
		for _, target in pairs( units ) do
			counter = counter + 1
			target:AddNewModifier(caster, ability, modifierTargetName, {})

			Timers:CreateTimer( counter * attack_interval, function()
					-- Only jump to it if it's alive
					if target:IsAlive() then
						-- Create trail particles
						local trailFxIndex = ParticleManager:CreateParticle( particleTrailName, PATTACH_CUSTOMORIGIN, target )
						ParticleManager:SetParticleControl( trailFxIndex, 0, target:GetAbsOrigin() )
						ParticleManager:SetParticleControl( trailFxIndex, 1, caster:GetAbsOrigin() )
						
						Timers:CreateTimer( 0.1, function()
								ParticleManager:DestroyParticle( trailFxIndex, false )
								ParticleManager:ReleaseParticleIndex( trailFxIndex )
								return nil
							end
						)
						
						-- Move hero there
						FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )
						
						if target:IsHero() then
							caster:AddNewModifier(caster, ability, modifierHeroName, {})
						else
							caster:AddNewModifier(caster, ability, modifierCreepName, {})
						end
						
						caster:PerformAttack (
							target,     -- handle hTarget 
							true,       --bUseCastAttackOrb, 
							true,       --bProcessProcs,
							true,       -- bool bSkipCooldown
							false,      -- bool bIgnoreInvis
							false,       -- bool bUseProjectile
							false,      -- bool bFakeAttack
							false        -- bool bNeverMiss  可敌先机
						)
						
						-- Slash particles
						local slashFxIndex = ParticleManager:CreateParticle( particleSlashName, PATTACH_ABSORIGIN_FOLLOW, target )
						StartSoundEvent( slashSound, caster )
						
						Timers:CreateTimer( 0.1, function()
								ParticleManager:DestroyParticle( slashFxIndex, false )
								ParticleManager:ReleaseParticleIndex( slashFxIndex )
								StopSoundEvent( slashSound, caster )
								return nil
							end
						)
						
						-- Clean up modifier
						caster:RemoveModifierByName( modifierHeroName )
						caster:RemoveModifierByName( modifierCreepName )
						target:RemoveModifierByName( modifierTargetName )
					end
					return nil
				end
			)
		end
		
		-- Return caster to origin position
		Timers:CreateTimer( ( counter + 1 ) * attack_interval, function()
				FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
				dummy:RemoveSelf()
				caster:RemoveModifierByName( casterModifierName )
				caster.sleight_of_fist_active = false
				return nil
			end
		)
	end

	function ability_class:FindEnemies(caster, ability, targetPoint)
		-- Targeting variables
		local targetTeam = ability:GetAbilityTargetTeam()		-- DOTA_UNIT_TARGET_TEAM_ENEMY
		local targetType = ability:GetAbilityTargetType()		-- DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local targetFlag = ability:GetAbilityTargetFlags() 		-- DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local unitOrder = FIND_ANY_ORDER

		local radius = ability:GetSpecialValueFor( "radius")
		
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(), targetPoint, caster, radius, targetTeam,
			targetType, targetFlag, unitOrder, false
		)

		local attack_count = GetTalentSpecialValueFor(ability, "attack_count")  or 10

		local units = {}
		local count = attack_count
		for i=1,attack_count do
			if count > 0 then 
				for _, enemy in pairs( enemies ) do
					if count > 0 then
						count = count - 1
						table.insert( units, enemy )
					end
				end
			end
		end
		
		return units
	end
end


-----------------------------------------------------------------------------------------

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

mjz_ember_spirit_sleight_of_fist2 = class(mjz_ember_spirit_sleight_of_fist)