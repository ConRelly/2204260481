earthshaker_echo_slam_lua = class({})

--------------------------------------------------------------------------------
-- Ability Start
function earthshaker_echo_slam_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	-- initial damage that was deprecated
	local damage = self:GetAbilityDamage() + (self:GetCaster():GetStrength() * self:GetSpecialValueFor("str_multiplier"))
	local damage_range = self:GetSpecialValueFor("echo_slam_damage_range")

	local init_range = self:GetSpecialValueFor("echo_slam_echo_search_range")
	local echo_range = self:GetSpecialValueFor("echo_slam_echo_range")
	local echo_damage = self:GetSpecialValueFor("echo_slam_echo_damage")

	-- precache projectile
	local projectile_name = "particles/units/heroes/hero_earthshaker/earthshaker_echoslam.vpcf"
	local projectile_speed = 1100

	local info = {
		-- Target = target,
		-- Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional
	
		-- vSourceLoc = caster:GetAbsOrigin(),                -- Optional (HOW)
		bReplaceExisting = false,                         -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)

	-- find echoing units
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		init_range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- if no unit, echo slam?
	if #enemies<1 then
		self:PlayEffects( 0 )
		return
	end

	local echoes = 0
	for _,enemy in pairs(enemies) do
		-- initial damage (deprecated)
		if not enemy:IsMagicImmune() then
			local damageTable = {
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self, --Optional.
			}
			ApplyDamage(damageTable)
		end

		-- Find echoed units
		local targets = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			enemy:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			echo_range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			FIND_CLOSEST,	-- int, order filter
			false	-- bool, can grow cache
		)

		-- echo to enemies other than self
		for _,target in pairs(targets) do
			if target~=enemy then
				info.Target = target
				info.Source = enemy
				ProjectileManager:CreateTrackingProjectile(info)
				echoes = echoes + 1

				-- twice if real heroes
				if enemy:IsRealHero() then
					ProjectileManager:CreateTrackingProjectile(info)
					echoes = echoes + 1
				end
			end
		end
	end

	-- effects
	self:PlayEffects( echoes )
end

--------------------------------------------------------------------------------
-- Projectile
function earthshaker_echo_slam_lua:OnProjectileHit( target, location )
	local damage = self:GetSpecialValueFor("echo_slam_echo_damage") + (self:GetCaster():GetStrength() * self:GetTalentSpecialValueFor("str_multiplier"))
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)
end

--------------------------------------------------------------------------------
function earthshaker_echo_slam_lua:PlayEffects( echoes )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start.vpcf"
	local sound_cast = "Hero_EarthShaker.EchoSlam"

	-- generate data
	if echoes<1 then
		sound_cast = "Hero_EarthShaker.EchoSlamSmall"
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( echoes, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end


-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
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