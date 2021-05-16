
local LUA_DIR = "abilities/hero_void_spirit/"
local MODIFIERS = {
    "modifier_mjz_void_spirit_astral_atlas_thinker",
    "modifier_mjz_void_spirit_astral_atlas_crit",
    "modifier_void_spirit_astral_step_lua",
}
for _,name in pairs(MODIFIERS) do
    LinkLuaModifier( name, LUA_DIR .. name, LUA_MODIFIER_MOTION_NONE )
end

-- special_bonus_unique_void_spirit_8
---------------------------------------------------------------------------------


mjz_void_spirit_astral_atlas = class({})
local ability_class = mjz_void_spirit_astral_atlas

function ability_class:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("max_travel_distance")
end
function ability_class:GetAOERadius()
    return self:GetSpecialValueFor("max_travel_distance")
end

function ability_class:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
	    local origin = caster:GetOrigin()
        local point = caster:GetOrigin() -- self:GetCursorPosition() 

        self:_AddCrit()

        -- -- Emit Sound
        -- local sound_cast = "Hero_VoidSpirit.AetherRemnant.Cast"
        -- EmitSoundOn( sound_cast, caster )

        local range = self:GetSpecialValueFor("max_travel_distance")
        local centre_pos = point
        local points = 5
        local offset_angle = RandomInt(1, 360)
        local cycle = 0
        local i = 0
        local circle_pos_list = {}
        while i < points do
            local b = i / points
            local c = cycle + (360 * b) + offset_angle
            local x = range * math.sin(math.rad(c)) + centre_pos.x
            local y = range * math.cos(math.rad(c)) + centre_pos.y
            local point_loc = Vector(x, y, 0)
            i = i + 1
            table.insert( circle_pos_list, point_loc )

        end
        -- 画星号
        -- for i,pos in ipairs(circle_pos_list) do
            -- self:_CreateThinker(pos, centre_pos)
           --  self:_OnSpellStart(pos, centre_pos)
        -- end
        -- 画五角星
        for i,pos in ipairs(circle_pos_list) do
             -- self:_CreateThinker(pos, centre_pos)
            --  self:_OnSpellStart(pos, centre_pos)

            local start_pos = pos
            local end_pos = circle_pos_list[i + 2]
            if (i + 2) > #circle_pos_list then
                end_pos = circle_pos_list[i + 2 - #circle_pos_list]
            end
            self:_OnSpellStart({
                origin = start_pos, point = end_pos, max_dist = 2000
            })
        end

        -- self:_OnSpellStart(origin, point)

        self:_RemoveCrit()
    end
end

function ability_class:_CreateThinker(origin, point)
    local caster = self:GetCaster()
    --  create thinker
        CreateModifierThinker(
            caster, -- player source
            self, -- ability source
            "modifier_mjz_void_spirit_astral_atlas_thinker", -- modifier name
            {
                dir_x = point.x,
                dir_y = point.y,
                origin = origin,
            }, -- kv
            point,
            caster:GetTeamNumber(),
            false
        )
end

function ability_class:_OnSpellStart(kv)
	-- unit identifier
    local caster = self:GetCaster()
    local origin = kv.origin
    local point = kv.point
    local teleport = kv.teleport

	-- load data
	local min_dist = self:GetSpecialValueFor( "min_travel_distance" )
	local max_dist = kv.max_dist or self:GetSpecialValueFor( "max_travel_distance" )
	local radius = self:GetSpecialValueFor( "radius" )
	local delay = self:GetSpecialValueFor( "pop_damage_delay" )

	-- find destination
	local direction = (point-origin)
	local dist = math.max( math.min( max_dist, direction:Length2D() ), min_dist )
	direction.z = 0
	direction = direction:Normalized()

	local target = GetGroundPosition( origin + direction*dist, nil )

    -- teleport
    if teleport then
        FindClearSpaceForUnit( caster, target, true )
    end
    
	
	-- find units in line
	local enemies = FindUnitsInLine(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		origin,	-- point, start point
		target,	-- point, end point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES	-- int, flag filter
	)

	for _,enemy in pairs(enemies) do
		-- perform attack
		caster:PerformAttack( enemy, true, true, true, false, true, false, true )

		-- add modifier
		enemy:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_void_spirit_astral_step_lua", -- modifier name
			{ duration = delay } -- kv
		)

		-- play effects
		self:PlayEffects2( enemy )
	end

	-- play effects
	self:PlayEffects1( origin, target )
end

function ability_class:_AddCrit()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_mjz_void_spirit_astral_atlas_crit", {})
end

function ability_class:_RemoveCrit()
    local caster = self:GetCaster()
    caster:RemoveModifierByName( "modifier_mjz_void_spirit_astral_atlas_crit")
end

--------------------------------------------------------------------------------
function ability_class:PlayEffects1( origin, target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf"
	local sound_start = "Hero_VoidSpirit.AstralStep.Start"
	local sound_end = "Hero_VoidSpirit.AstralStep.End"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, origin )
	ParticleManager:SetParticleControl( effect_cast, 1, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( origin, sound_start, self:GetCaster() )
	EmitSoundOnLocationWithCaster( target, sound_end, self:GetCaster() )
end

function ability_class:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_impact.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end