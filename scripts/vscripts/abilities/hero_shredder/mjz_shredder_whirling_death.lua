
mjz_shredder_whirling_death = class({})
local ability_class = mjz_shredder_whirling_death

function ability_class:GetAOERadius()
    return self:GetSpecialValueFor('radius')
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local caster = self:GetCaster()
		local ability = self
		local radius = ability:GetSpecialValueFor("radius")
		local casterPosition = caster:GetAbsOrigin()

        self:_ApplyDamage()
        self:_PlayEffect()
		KillTreesInRadius(caster, casterPosition, radius)
    end
    
    function ability_class:_PlayEffect( )
        local caster = self:GetCaster()
		local ability = self
		local radius = ability:GetSpecialValueFor("radius")
		local casterPosition = caster:GetAbsOrigin()
		local particle = "particles/units/heroes/hero_shredder/shredder_whirling_death.vpcf"
		local sound_cast = "Hero_Shredder.WhirlingDeath.Cast"

		EmitSoundOn(sound_cast, caster)   

		local nFXIndex = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(nFXIndex, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil, casterPosition, true)
		ParticleManager:SetParticleControlEnt(nFXIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", casterPosition, true)
        ParticleManager:SetParticleControlEnt(nFXIndex, 2, caster, PATTACH_ABSORIGIN_FOLLOW, nil, casterPosition, true)
        ParticleManager:ReleaseParticleIndex(nFXIndex)
    end

    function ability_class:_ApplyDamage()
        local caster = self:GetCaster()
		local ability = self
        local radius = ability:GetSpecialValueFor("radius")
        local base_damage = GetTalentSpecialValueFor(ability, 'base_damage')
        local str_damage_pct = GetTalentSpecialValueFor(ability, 'str_damage_pct')
        local damage = base_damage + caster:GetStrength() * (str_damage_pct / 100.0)

        local damageTable = {
            attacker = caster,
            victim = nil,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            ability = ability,
        }
        
        local unit_list = FindUnitsInRadius(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil, radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false
        )
        
        for _,unit in pairs(unit_list) do
            if unit then
                damageTable.victim = unit
                ApplyDamage(damageTable)
            end
        end
    end
end



-----------------------------------------------------------------------------------------


function KillTreesInRadius(caster, center, radius)
    local particles = {
        "particles/newplayer_fx/npx_tree_break.vpcf",
        "particles/newplayer_fx/npx_tree_break_b.vpcf",
    }
    local particle = particles[math.random(1, #particles)]

    local trees = GridNav:GetAllTreesAroundPoint(center, radius, true)
    for _,tree in pairs(trees) do
        local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_fx, 0, tree:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_fx)
    end
    GridNav:DestroyTreesAroundPoint(center, radius, false)
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