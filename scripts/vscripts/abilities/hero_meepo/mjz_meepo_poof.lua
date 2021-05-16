
mjz_meepo_poof = class({})
local ability_class = mjz_meepo_poof

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end

function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		local player = caster:GetPlayerOwner()
		local position = caster:GetAbsOrigin()

		local p_name = "particles/units/heroes/hero_meepo/meepo_poof_start.vpcf"
		local part = ParticleManager:CreateParticleForPlayer(p_name, PATTACH_CUSTOMORIGIN, caster, player)
		ParticleManager:SetParticleControl(part, 0, position)
		ParticleManager:SetParticleControl(part, 1, Vector(200,0,0)) 
		self.nPreviewFX = part

		EmitSoundOn('Hero_Meepo.Poof.Channel', caster)
		-- ability:CreateVisibilityNode(position, 200, 4)
	end
	return true
end

function ability_class:OnAbilityPhaseInterrupted()
	if IsServer() then
		StopSoundOn('Hero_Meepo.Poof.Channel', self:GetCaster())
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end
end


if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local position_start = caster:GetAbsOrigin()
		local position_end = self:GetEndPosition() -- caster:GetCursorPosition()
	
		local radius = ability:GetSpecialValueFor("radius")
		local damage = GetTalentSpecialValueFor(ability, "poof_damage")
		local damage_type = ability:GetAbilityDamageType()
	
		-- Damage on start position
		self:DamageInArea(position_start, radius, damage, damage_type)
	
		-- Teleport
		self:Teleport(position_end)
	
		-- Damage on end position
		self:DamageInArea(position_end, radius, damage, damage_type)
	end

	function ability_class:DamageInArea(position, radius, damage, damage_type)
		local ability = self
		local caster = self:GetCaster()

		local units = FindUnitsInRadius(
			caster:GetTeamNumber(),
			position, nil, radius,
			ability:GetAbilityTargetTeam(),
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
		ParticleManager:ReleaseParticleIndex(part2)
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