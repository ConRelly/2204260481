modifier_sand_king_sand_storm_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sand_king_sand_storm_lua:IsHidden()
	return false
end

function modifier_sand_king_sand_storm_lua:IsDebuff()
	return false
end

function modifier_sand_king_sand_storm_lua:IsPurgable()
	return false
end

function modifier_sand_king_sand_storm_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sand_king_sand_storm_lua:OnCreated( kv )
	-- references

	
	self.radius = self:GetAbility():GetSpecialValueFor( "sand_storm_radius" ) -- special value
	self.interval = 0.5

	if IsServer() then
		-- initialize
		self.damage = self:GetAbility():GetTalentSpecialValueFor( "sand_storm_damage" ) + (self:GetCaster():GetStrength() * self:GetAbility():GetTalentSpecialValueFor("str_multiplier")) -- special value
		self.active = true
		self.damageTable = {
			-- victim = target,
			attacker = self:GetParent(),
			damage = self.damage * self.interval,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}

		-- Start interval
		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()

		-- start effects
		self:PlayEffects( self.radius )
	end
end

function modifier_sand_king_sand_storm_lua:OnRefresh( kv )
	-- references
	
	self.radius = self:GetAbility():GetSpecialValueFor( "sand_storm_radius" ) -- special value

	if IsServer() then
		-- initialize
		self.damage = self:GetAbility():GetTalentSpecialValueFor( "sand_storm_damage" ) + (self:GetCaster():GetStrength() * self:GetAbility():GetTalentSpecialValueFor("str_multiplier")) -- special value
		self.damageTable.damage = self.damage * self.interval
		self.active = kv.start
		self:SetDuration( kv.duration, true )
	end
end

function modifier_sand_king_sand_storm_lua:OnDestroy( kv )
	if IsServer() then
		-- stop effects
		self:StopEffects()
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sand_king_sand_storm_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}

	return funcs
end

function modifier_sand_king_sand_storm_lua:GetModifierInvisibilityLevel()
	return 1
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_sand_king_sand_storm_lua:CheckState()
	local state = {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_sand_king_sand_storm_lua:OnIntervalThink()
	if self.active==0 then return end

	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		self:GetAbility():GetAbilityTargetTeam(),	-- int, team filter
		self:GetAbility():GetAbilityTargetType(),	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- damage enemies
	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end

	-- effects: reposition cloud
	if self.effect_cast then
		ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_sand_king_sand_storm_lua:PlayEffects( radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf"
	local sound_cast = "Ability.SandKing_SandStorm.loop"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( radius, radius, radius ) )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_sand_king_sand_storm_lua:StopEffects()
	-- Stop particles
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )

	-- Stop sound
	local sound_cast = "Ability.SandKing_SandStorm.loop"
	StopSoundOn( sound_cast, self:GetParent() )
end


function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end


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