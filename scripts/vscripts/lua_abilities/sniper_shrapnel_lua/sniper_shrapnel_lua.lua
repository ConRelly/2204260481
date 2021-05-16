sniper_shrapnel_lua = class({})
LinkLuaModifier( "modifier_sniper_shrapnel_lua", "lua_abilities/sniper_shrapnel_lua/modifier_sniper_shrapnel_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sniper_shrapnel_lua_thinker", "lua_abilities/sniper_shrapnel_lua/modifier_sniper_shrapnel_lua_thinker", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function sniper_shrapnel_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function sniper_shrapnel_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local total_duration = self:GetSpecialValueFor( "damage_delay" ) + self:GetTalentSpecialValueFor( "duration" )
	-- Talent Tree
	local special_shrapnel_duration_lua = self:GetCaster():FindAbilityByName("special_shrapnel_duration_lua")
	if special_shrapnel_duration_lua and special_shrapnel_duration_lua:GetLevel() ~= 0 then
		total_duration = total_duration + special_shrapnel_duration_lua:GetSpecialValueFor("value")
	end

	-- logic
	CreateModifierThinker(
		caster,
		self,
		"modifier_sniper_shrapnel_lua_thinker",
		{duration = total_duration},
		point,
		caster:GetTeamNumber(),
		false
	)

	-- effects
	self:PlayEffects( point )
end

--------------------------------------------------------------------------------
function sniper_shrapnel_lua:PlayEffects( point )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
	local sound_cast = "Hero_Sniper.ShrapnelShoot"

	-- Get Data
	local height = 2000

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		self:GetCaster():GetOrigin(), -- unknown
		false -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, point + Vector( 0, 0, height ) )
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