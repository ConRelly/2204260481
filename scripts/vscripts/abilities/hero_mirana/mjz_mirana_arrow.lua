
LinkLuaModifier("modifier_mjz_mirana_arrow", "abilities/hero_mirana/mjz_mirana_arrow.lua", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_mirana_arrow = class({})
local ability_class = mjz_mirana_arrow

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_mirana_arrow"
end

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('arrow_range')
end

function ability_class:OnToggle()
	
end

if IsServer() then
    function ability_class:OnProjectileHit(target, location)
		if not IsServer() then return end
        if target and target:IsAlive() then
            local caster = self:GetCaster()
            local damage_pct = self:GetSpecialValueFor("damage_pct")
            local damage = caster:GetAverageTrueAttackDamage(target) * (damage_pct / 100.0)
			if _G._challenge_bosss > 0 then
				local target_current_hp = math.floor(target:GetHealth() * ( 0.03 * _G._challenge_bosss))
				ApplyDamage({
					ability = self,
					attacker = caster,
					victim = target,				
					damage = target_current_hp,
					damage_type = self:GetAbilityDamageType(),
				})
			end			 
            ApplyDamage({
                ability = self,
				attacker = caster,
                victim = target,				
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
            })


            target:EmitSound("Hero_Mirana.ArrowImpact")
        end

        return true
    end
end



---------------------------------------------------------------------------------------

modifier_mjz_mirana_arrow = class({})
local modifier_class = modifier_mjz_mirana_arrow

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK,
		}
		return funcs
	end


	function modifier_class:OnAttack(keys)
		if keys.attacker ~= self:GetParent() then return end
		
        local attacker = keys.attacker
        local target = keys.target
		local ability = self:GetAbility()
		local arrow_speed = ability:GetSpecialValueFor('arrow_speed')
		local proc_chance = GetTalentSpecialValueFor(ability, 'proc_chance')
		local talent_volley_name = 'special_bonus_unique_mirana_2'

		if not ability:GetToggleState() then return end
		if not RollPercentage(proc_chance) then return end

		local direction = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()
		local vVelocity = direction * arrow_speed
		self:_CreateProjectile(attacker, vVelocity)

		if HasTalent(attacker, talent_volley_name) then
			-- 1点钟方向
			local direction_1 = RotatePosition(Vector(0,0,0), QAngle(0,7,0), attacker:GetForwardVector())
			-- 11点钟方向
			local direction_11 = RotatePosition(Vector(0,0,0), QAngle(0,360 - 7,0), attacker:GetForwardVector())

			local vVelocity_1 = direction_1 * arrow_speed
			self:_CreateProjectile(attacker, vVelocity_1)
			local vVelocity_11 = direction_11 * arrow_speed
			self:_CreateProjectile(attacker, vVelocity_11)
		end

        attacker:EmitSound("Hero_Mirana.ArrowCast")
	end
	
	function modifier_class:_CreateProjectile(attacker, vVelocity)
		local ability = self:GetAbility()
		local arrow_width = ability:GetSpecialValueFor('arrow_width')
		local arrow_range = ability:GetSpecialValueFor('arrow_range')
		local arrow_vision = ability:GetSpecialValueFor('arrow_vision')

		local effect_name = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf"

		-- local fDistance = 3 * attacker:GetBaseAttackRange()
		local fDistance = arrow_range

        ProjectileManager:CreateLinearProjectile({
            EffectName = effect_name,
            Ability = ability,
            vSpawnOrigin = attacker:GetAbsOrigin(), 
            fStartRadius = arrow_width,
            fEndRadius = arrow_width,
            vVelocity = vVelocity,
            fDistance = fDistance,
            Source = attacker,
            iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetType = ability:GetAbilityTargetType(),
			iUnitTargetFlags = ability:GetAbilityTargetFlags(),
			bDeleteOnHit = true,
			bProvidesVision = true,
			iVisionRadius = arrow_vision,
			iVisionTeamNumber = attacker:GetTeamNumber(),
        })
	end

	-- 获得 1 点钟位置
	function CalcOrigin_Clock_1(sourceUnit, targetUnit)
		local source_origin = sourceUnit:GetAbsOrigin()
		local target_origin = targetUnit:GetAbsOrigin()
		local radius = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()
		return vVelocity
	end

	-- 获得 11 点钟位置
	function CalcOrigin_Clock_11(sourceUnit, targetUnit)
		local source_origin = sourceUnit:GetAbsOrigin()
		local target_origin = targetUnit:GetAbsOrigin()
		
	end
end


--[[

	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,			-- 按百分比修改攻击力，负数降低攻击，正数提高攻击
		}
		return funcs
	end


	function modifier_class:GetModifierDamageOutgoing_Percentage( )
		return self:GetAbility():GetSpecialValueFor('bonus_damage_pct')
	end

]]

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