
function OnSpellStart(keys)
    if IsServer() then
        _OnSpellStart(keys)
    end
end


function _OnSpellStart(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local base_damage = ability:GetSpecialValueFor("damage")
    local damage_per_use = ability:GetSpecialValueFor("damage_per_use")
    local splash_radius_scepter = ability:GetSpecialValueFor("splash_radius_scepter")
    local use_count = 0
    if ability:IsItem() then
        use_count = ability:GetCurrentCharges()
    end
    local damage = base_damage + damage_per_use * use_count
    

    local units = nil
    if caster:HasScepter() and false then
        local target_type = ability:GetAbilityTargetType()
        local target_team = ability:GetAbilityTargetTeam()
        local target_flags = ability:GetAbilityTargetFlags()
        local radius = splash_radius_scepter
        local position = target:GetAbsOrigin()
        units = FindUnitsInRadius(caster:GetTeam(), position, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)
    else
        units = {target}
    end


    --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.    
    local particle_effect_intensity = 300 + 100 * 5    --(100 * ability_level)  
    caster:EmitSound("DOTA_Item.Dagon.Activate")
    
    for j,unit in ipairs(units) do
        local victim = unit

        local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(dagon_particle, 1, victim, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
        ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
        ParticleManager:ReleaseParticleIndex(dagon_particle)
	
        victim:EmitSound("DOTA_Item.Dagon5.Target")
        
        ApplyDamage({
            victim = victim, 
            attacker = caster, 
            damage = damage, 
            damage_type = ability:GetAbilityDamageType(),
            ability = ability,
        })

        if ability:IsItem() then
            local iCharges = use_count + 1
            ability:SetCurrentCharges(iCharges)
        end
    end
end



function _UpdateTooltip( item_dagon )
    local owner = item_dagon:GetOwner()
    local modifier = item_dagon._modifier_tooltip
    local count = item_dagon._kill_count or 0
	-- local newCount = owner:GetModifierStackCount(modifier, owner) + 1

    if not owner:HasModifier(modifier) then
        item_dagon:ApplyDataDrivenModifier(owner, owner, modifier, nil)
    end
    owner:SetModifierStackCount(modifier, owner, count)    
end
