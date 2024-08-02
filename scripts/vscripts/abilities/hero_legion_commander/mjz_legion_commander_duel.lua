
local MODIFIER_LUA = "modifiers/hero_legion_commander/modifier_mjz_legion_commander_duel.lua"
local MODIFIER_CASTER_NAME = "modifier_mjz_legion_commander_duel_caster"
local MODIFIER_CASTER_SCEPTER_NAME = "modifier_mjz_legion_commander_duel_scepter"
local MODIFIER_ENEMY_NAME = "modifier_mjz_legion_commander_duel_enemy"

LinkLuaModifier(MODIFIER_CASTER_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_CASTER_SCEPTER_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_ENEMY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_legion_commander_duel = class({})
local ability_class = mjz_legion_commander_duel

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('cast_range')
end

function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('cast_range')
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_origin = caster:GetAbsOrigin()
		local target_origin = target:GetAbsOrigin()
		local duration_normal = ability:GetSpecialValueFor('duration')
		local duration_scepter = ability:GetSpecialValueFor('duration_scepter')
		local duration = value_if_scepter(caster, duration_scepter, duration_normal)

		-- 林肯法球
        if target:TriggerSpellAbsorb(ability) then return nil end

		caster:EmitSound("Hero_LegionCommander.Duel.Cast")

		local p_name = "particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf"
		if ability._particle ~= nil then
			ParticleManager:DestroyParticle(ability._particle, true)
			ParticleManager:ReleaseParticleIndex(ability._particle)
		end		
		ability._particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN, caster)
		local center_point = target_origin + ((caster_origin - target_origin) / 2)
		ParticleManager:SetParticleControl(ability._particle, 0, center_point)  --The center position.
		ParticleManager:SetParticleControl(ability._particle, 7, center_point)  --The flag's position (also centered).

		self:_SetForceAttack()

		if caster:HasScepter() then
			caster:AddNewModifier(caster, ability, MODIFIER_CASTER_SCEPTER_NAME, {duration = duration})
		end

		caster:AddNewModifier(caster, ability, MODIFIER_CASTER_NAME, {duration = duration})
		target:AddNewModifier(caster, ability, MODIFIER_ENEMY_NAME, {duration = duration})

	end

	function ability_class:_SetForceAttack( )
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		--[[local order_target = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}]]

		local order_caster =
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}

		target:Stop()

		--ExecuteOrderFromTable(order_target)
		ExecuteOrderFromTable(order_caster)

		--caster:SetForceAttackTarget(target)
		--target:SetForceAttackTarget(caster)
	end

	function ability_class:OnTargetDeath(target)
		local ability = self
		local caster = self:GetCaster()

		ability:EndCooldown()
		caster:RemoveModifierByName(MODIFIER_CASTER_NAME)
		caster:RemoveModifierByName(MODIFIER_CASTER_SCEPTER_NAME)

		caster:EmitSound("Hero_LegionCommander.Duel.Victory")
		local p_name = "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf"
		local duel_victory_particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:DestroyParticle(duel_victory_particle, false)
		ParticleManager:ReleaseParticleIndex(duel_victory_particle)
	end
end



---------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------


function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
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