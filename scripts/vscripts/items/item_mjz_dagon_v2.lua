function OnSpellStart(keys)
    if IsServer() then
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local base_damage = ability:GetSpecialValueFor("damage")
		local damage_per_use = ability:GetSpecialValueFor("damage_per_use")
		local splash_radius_scepter = ability:GetSpecialValueFor("splash_radius_scepter")
		local damage_stats = 0
		if caster:IsRealHero() then
			damage_stats = caster:GetIntellect() * 10
		end
		local use_count = 0
		if ability:IsItem() then
			use_count = ability:GetCurrentCharges()
		end
		local damage = base_damage + damage_per_use * use_count
		if caster:HasModifier("modifier_super_scepter") then
			damage = damage + damage_stats
		end	

		local units = nil
		if caster:HasScepter() then
			local target_type = ability:GetAbilityTargetType()
			local target_team = ability:GetAbilityTargetTeam()
			local target_flags = ability:GetAbilityTargetFlags()
			local radius = splash_radius_scepter
			local position = target:GetAbsOrigin()
			units = FindUnitsInRadius(caster:GetTeam(), position, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)
		else
			units = {target}
		end

		caster:EmitSound("DOTA_Item.Dagon.Activate")
		
		for j,unit in ipairs(units) do
			local dagon_pfx = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_RENDERORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(dagon_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), false)
			ParticleManager:SetParticleControlEnt(dagon_pfx, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), false)
			ParticleManager:SetParticleControl(dagon_pfx, 2, Vector(800, 0, 0))
			ParticleManager:SetParticleControl(dagon_pfx, 3, Vector(0.3, 0, 0))
			ParticleManager:ReleaseParticleIndex(dagon_pfx)
		
			unit:EmitSound("DOTA_Item.Dagon5.Target")
			
			ApplyDamage({
				victim = unit, 
				attacker = caster, 
				damage = damage * 0.50, 
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			})
			Timers:CreateTimer(
				0.05,
				function()
					ApplyDamage({
						victim = unit, 
						attacker = caster, 
						damage = damage * 0.50, 
						damage_type = ability:GetAbilityDamageType(),
						ability = ability,
					})
				end
			)
--[[ 			Timers:CreateTimer(
				0.1,
				function()
					ApplyDamage({
						victim = unit, 
						attacker = caster, 
						damage = damage * 0.30, 
						damage_type = ability:GetAbilityDamageType(),
						ability = ability,
					})
				end
			)  ]]                       
			if ability:IsItem() then
				local iCharges = use_count + 1
				ability:SetCurrentCharges(iCharges)
			end
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
