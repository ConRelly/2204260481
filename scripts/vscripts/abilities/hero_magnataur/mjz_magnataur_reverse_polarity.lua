

function OnAbilityPhaseStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local radius = ability:GetSpecialValueFor("pull_radius")
    EmitGlobalSound("Hero_Magnataur.ReversePolarity.Anim")

    local p_name =  "particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf"
    -- ParticleManager:FireParticle(p_name, PATTACH_POINT, caster, {[0]=Vector(1,0,0), [1]=Vector(radius,radius,radius), [2]=Vector(0.3,0,0), [3]=caster:GetAbsOrigin() + caster:GetForwardVector()*200})
    local nParticleIndex = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(nParticleIndex, 0, caster, PATTACH_POINT_FOLLOW, nil, caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nParticleIndex, 1, Vector(radius, 0, 0))
		ParticleManager:SetParticleControl(nParticleIndex, 2, Vector(ability:GetCastPoint(), 0, 0))
		ParticleManager:SetParticleControl(nParticleIndex, 3, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nParticleIndex)
end

function OnSpellStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local radius = ability:GetSpecialValueFor("pull_radius")
    EmitSoundOn("Hero_Magnataur.ReversePolarity.Cast", caster)

    local vCreeps = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, -1, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
	 for _,hCreep in ipairs(vCreeps) do
	 	if hCreep:GetTeam()~=DOTA_TEAM_NEUTRALS then
			hCreep:SetAbsOrigin(caster:GetAbsOrigin())
			FindClearSpaceForUnit(hCreep, caster:GetAbsOrigin(), true)
			hCreep:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
			hCreep:EmitSound("Hero_Magnataur.ReversePolarity.Stun")
		end
	 end
end

function ReversePolarity(keys)
	local caster = keys.caster
	local target = keys.target
    local ability = keys.ability
    
    if IsIgnoreTarget(target) then return false end
	
	local hero_stun_duration = ability:GetSpecialValueFor("hero_stun_duration")
	local creep_stun_duration = ability:GetSpecialValueFor("creep_stun_duration")
	local pull_offset = ability:GetSpecialValueFor("pull_offset")
    local polarity_damage = ability:GetSpecialValueFor("polarity_damage")

    ApplyDamage({
        ability = ability,
        attacker = caster,
        damage = polarity_damage,
        damage_type = ability:GetAbilityDamageType(),
        victim = target
    })

	-- The angle the caster is facing
	local caster_angle = caster:GetForwardVector()
	-- The caster's position
	local caster_origin = caster:GetAbsOrigin()
	-- The vector from the caster to the target position
	local offset_vector = caster_angle * pull_offset
	-- The target's new position
	local new_location = caster_origin + offset_vector
	
	-- Moves all the targets to the position
	target:SetAbsOrigin(new_location)
	FindClearSpaceForUnit(target, new_location, true)
	
	-- Applies the stun modifier based on the unit's type
	if target:IsHero() == true then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = hero_stun_duration})
	else
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = creep_stun_duration})
    end
	target:EmitSound("Hero_Magnataur.ReversePolarity.Stun")

end

function IsIgnoreTarget( target )
    if target == nil then return true end
    if not IsValidEntity(target) then return true end
    if not target:IsAlive() then return true end
    --if target:GetTeam() == DOTA_TEAM_NEUTRALS then return true end
    local unitName = target:GetUnitName()
    local ignoreUnitNameList = {
        "npc_dota_campfire", "npc_dota_hero_target_dummy"
    }
    for _,name in pairs(ignoreUnitNameList) do
        if unitName == name then
            return true
        end
    end
    return false
end