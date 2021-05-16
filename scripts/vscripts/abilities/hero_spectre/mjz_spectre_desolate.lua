
function Desolate (keys)
	if not IsServer() then return nil end

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() -1 
	
	local alone_enemy = ability:GetLevelSpecialValueFor("alone_enemy", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local damage = ability:GetLevelSpecialValueFor("bonus_damage", ability_level)
	local damage_type = ability:GetAbilityDamageType()
	
	local target_is_alone = true
	if alone_enemy == 1 then	-- 只作用于落单的敌人
		local units = FindUnitsInRadius(
			caster:GetTeamNumber(),
	        target:GetAbsOrigin(),
	        nil,
	        radius,
	        DOTA_UNIT_TARGET_TEAM_ENEMY,
	        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	        DOTA_UNIT_TARGET_FLAG_NO_INVIS,
	        FIND_ANY_ORDER,
	        false
		)
		for _,unit in pairs(units) do
			if unit:GetTeam() == target:GetTeam() and unit ~= target then
				target_is_alone = false
			end
		end
	end
	
	local work_condition = target_is_alone and target:IsAlive() -- and not target:IsMagicImmune()
    if work_condition then
    	EmitSoundOn("Hero_Spectre.Desolate", caster)

    	local particle_name = "particles/units/heroes/hero_spectre/spectre_desolate.vpcf"
    	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT, target)
		local pelel = caster:GetForwardVector()
		local target_point = target:GetAbsOrigin()
		local particle_point = Vector(target_point.x, target_point.y, GetGroundPosition(target_point, target).z + 140)

        ParticleManager:SetParticleControl(particle, 0, particle_point)
        ParticleManager:SetParticleControlForward(particle, 0, caster:GetForwardVector())

		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = damage_type,
		}
		 
		ApplyDamage(damageTable)
 
    end

end
