LinkLuaModifier("modifier_mjz_meepo_puff_buff", "abilities/hero_meepo/mjz_meepo_poof.lua", LUA_MODIFIER_MOTION_NONE)

mjz_meepo_poof = class({})
local ability_class = mjz_meepo_poof

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end

function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local caster = self:GetCaster()
		local player = caster:GetPlayerOwner()
		local position = caster:GetAbsOrigin()

		local p_name = "particles/units/heroes/hero_meepo/meepo_poof_start.vpcf"
		local part = ParticleManager:CreateParticleForPlayer(p_name, PATTACH_CUSTOMORIGIN, caster, player)
		ParticleManager:SetParticleControl(part, 0, position)
		ParticleManager:SetParticleControl(part, 1, Vector(200,0,0)) 
		self.nPreviewFX = part

		EmitSoundOn('Hero_Meepo.Poof.Channel', caster)
	end
	return true
end

function ability_class:OnAbilityPhaseInterrupted()
	if IsServer() then
		StopSoundOn('Hero_Meepo.Poof.Channel', self:GetCaster())
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end
	return true
end


if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local position_start = caster:GetAbsOrigin()
		local position_end = self:GetEndPosition() -- caster:GetCursorPosition()
		local radius = ability:GetSpecialValueFor("radius")
		local lvl = caster:GetLevel()
		local stats = caster:GetAgility() + caster:GetStrength()
		local stats_mult = ability:GetSpecialValueFor("poof_damage") --GetTalentSpecialValueFor(ability, "poof_damage")
		local damage = stats * stats_mult
		local damage_type = ability:GetAbilityDamageType()
		local modif_buff = "modifier_mjz_meepo_puff_buff"
		local ss_chance = ability:GetSpecialValueFor("extra_stack_chance")
		local ss_chance3x = ability:GetSpecialValueFor("extra_stack_chance3x")
		local ss_chance6x = ability:GetSpecialValueFor("extra_stack_chance6x")
		if HasTalent(caster,"special_bonus_mjz_meepo_poof_01") then
			if not caster:HasModifier(modif_buff) then
				caster:AddNewModifier(caster, ability, modif_buff, {})
			else
				local modif_b = caster:FindModifierByName(modif_buff)
				modif_b:IncrementStackCount()
				if HasSuperScepter(caster) then
					if RollPercentage(ss_chance6x) then
						modif_b:SetStackCount(modif_b:GetStackCount() + 6)
					elseif RollPercentage(ss_chance3x) then
						modif_b:SetStackCount(modif_b:GetStackCount() + 3)
					elseif RollPercentage(ss_chance) then
						modif_b:IncrementStackCount()
					end	
				end	
			end	
			local modif_b = caster:FindModifierByName(modif_buff)
			local bonus_dmg = modif_b:GetStackCount() * lvl
			damage = damage + bonus_dmg
		end

		-- Damage on start position
		self:DamageInArea(position_start, radius, damage, damage_type)
	
		-- Teleport

		if ability:GetAutoCastState() then 
			FindClearRandomPositionAroundUnit(caster, caster, math.random(250))		
		else
			self:Teleport(position_end)
		end	
		
	
		-- Damage on end position
		self:DamageInArea(position_end, radius, damage, damage_type)
	end

	function ability_class:DamageInArea(position, radius, damage, damage_type)
		local ability = self
		local caster = self:GetCaster()

		local units = FindUnitsInRadius(
			caster:GetTeamNumber(),
			position, nil, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_CLOSEST, false
		)

		for _,unit in pairs(units) do
			if unit~= nil then
				local damageTable = {
					victim = unit,
					attacker = caster,
					damage = damage,
					damage_type = damage_type,
					--damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
					ability = ability, --Optional.
				}
				ApplyDamage(damageTable)
			end
		end
	end
		
	function ability_class:IsValidPoofTarget(unit)
		local caster = self:GetCaster()
		local can = false

		if (not unit:IsHero()) or unit:GetTeamNumber() ~= caster:GetTeamNumber() then
			return
		end

		--TODO talent_meepo_poof_allied_heroes
		--TODO talent_meepo_poof_allied_creeps
		--TODO talent_meepo_poof_allied_buildings

		if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
			can = true
		end

		if unit:GetTeamNumber() == caster:GetTeamNumber() and (not unit:IsIllusion()) then
			can = true
		end

		return can
	end

	function ability_class:GetEndPosition()
		local ability = self
		local caster = self:GetCaster()

		-- Check cursor target
		--[[
			local target = caster:GetCursorTarget()
			if target ~= nil and self:IsValidPoofTarget(target) then
				return target:GetAbsOrigin()
			end
		]]

		local search_radius = ability:GetSpecialValueFor('search_radius')
		-- local search_radius = FIND_UNITS_EVERYWHERE
		
		-- Check nearby units
		local units = FindUnitsInRadius(caster:GetTeamNumber(),
			caster:GetCursorPosition(),
			nil, search_radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			--TODO talent_meepo_poof_allied_creeps
			--TODO talent_meepo_poof_allied_buildings
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST, false
		)
		for i,unit in pairs(units) do
			if units ~= nil and self:IsValidPoofTarget(unit) then
				return unit:GetAbsOrigin()
			end
		end

		return caster:GetAbsOrigin()
	end

	function ability_class:Teleport(position)
		local ability = self
		local caster = self:GetCaster()
	
		FindClearSpaceForUnit(caster, position, true)
		-- caster:SetAbsPosition(position)

		EmitSoundOn("Hero_Meepo.Poof.End", caster)

		local part2 = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_poof_end.vpcf", PATTACH_ABSORIGIN, caster) 
		ParticleManager:SetParticleControl(part2, 0, position) 
		ParticleManager:SetParticleControl(part2, 1, Vector(200,0,0)) 
		ParticleManager:DestroyParticle(part2, false)
		ParticleManager:ReleaseParticleIndex(part2)
	end


end
--------------------------------------------
modifier_mjz_meepo_puff_buff = class({})


function modifier_mjz_meepo_puff_buff:IsHidden()  return false end
function modifier_mjz_meepo_puff_buff:IsPurgable()  return false end
function modifier_mjz_meepo_puff_buff:RemoveOnDeath()  return false end
function modifier_mjz_meepo_puff_buff:AllowIllusionDuplicate() return true end

function modifier_mjz_meepo_puff_buff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,		
    }
end

function modifier_mjz_meepo_puff_buff:GetModifierBonusStats_Strength()
    return self:GetStackCount() * 2
end
function modifier_mjz_meepo_puff_buff:OnCreated()
    if not IsServer() then return nil end
    local parent = self:GetParent()
    if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
        local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
        if owner then       
            if owner:HasModifier("modifier_mjz_meepo_puff_buff") then
				local modif_1 = owner:FindModifierByName("modifier_mjz_meepo_puff_buff")
				local stacks = modif_1:GetStackCount()
                self:SetStackCount(stacks)
            end    
        end    
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