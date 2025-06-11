local LUA_DIR = "abilities/hero_void_spirit/"
local MODIFIERS = {
    "modifier_mjz_void_spirit_astral_atlas_thinker",
    "modifier_mjz_void_spirit_astral_atlas_crit",
    "modifier_void_spirit_astral_step_lua",
}
for _,name in pairs(MODIFIERS) do
    LinkLuaModifier( name, LUA_DIR .. name, LUA_MODIFIER_MOTION_NONE )
end

LinkLuaModifier("modifier_mjz_void_spirit_astral_atlas_scepter_passive", "abilities/hero_void_spirit/mjz_void_spirit_astral_atlas", LUA_MODIFIER_MOTION_NONE)

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

function ability_class:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    local caster = self:GetCaster()
    if caster and caster:HasModifier("modifier_super_scepter") then
        behavior = behavior + DOTA_ABILITY_BEHAVIOR_AUTOCAST
    end
    return behavior
end

--------------------------------------------------------------------------------
-- ACTIVE SPELL CAST
--------------------------------------------------------------------------------
function ability_class:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        -- Active cast is intentionally centered on the caster.
        local origin = caster:GetOrigin() 
        local point = caster:GetOrigin()

        -- Apply the passive scepter modifier on the first active cast with a scepter.
        if not caster:HasModifier("modifier_mjz_void_spirit_astral_atlas_scepter_passive") then
            caster:AddNewModifier(caster, self, "modifier_mjz_void_spirit_astral_atlas_scepter_passive", {})
        end
        
        -- Add crit modifier for the duration of this active cast
        self:_AddCrit()

        -- Original star pattern logic (for active cast)
        local range = self:GetSpecialValueFor("max_travel_distance")
        local centre_pos = point
        local points = 5
        local offset_angle = RandomInt(1, 360)
        local circle_pos_list = {}

        for i = 0, points - 1 do
            local angle = (i / points) * 360 + offset_angle
            local x = range * math.sin(math.rad(angle)) + centre_pos.x
            local y = range * math.cos(math.rad(angle)) + centre_pos.y
            table.insert(circle_pos_list, Vector(x, y, 0))
        end

        -- Create the damaging lines for the star pattern
        for i, start_pos in ipairs(circle_pos_list) do
            local end_index = (i + 2)
            if end_index > #circle_pos_list then
                end_index = end_index - #circle_pos_list
            end
            local end_pos = circle_pos_list[end_index]
            
            self:_CreateAstralLine({
                origin = start_pos, 
                point = end_pos, 
                max_dist = (end_pos - start_pos):Length2D()
            })
        end
        
        -- Remove crit modifier after the cast is complete
        self:_RemoveCrit()
    end
end

--------------------------------------------------------------------------------
-- SUPER SCEPTER PASSIVE MODIFIER
--------------------------------------------------------------------------------
modifier_mjz_void_spirit_astral_atlas_scepter_passive = class({})

function modifier_mjz_void_spirit_astral_atlas_scepter_passive:IsHidden() return true end
function modifier_mjz_void_spirit_astral_atlas_scepter_passive:IsDebuff() return false end
function modifier_mjz_void_spirit_astral_atlas_scepter_passive:IsPurgable() return false end
function modifier_mjz_void_spirit_astral_atlas_scepter_passive:RemoveOnDeath() return false end

function modifier_mjz_void_spirit_astral_atlas_scepter_passive:OnCreated(kv)
    if IsServer() then
        self:StartIntervalThink(1.0) -- Check for targets every second
    end
end

function modifier_mjz_void_spirit_astral_atlas_scepter_passive:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if not IsValidEntity(parent) or not IsValidEntity(ability) then
        self:Destroy()
        return
    end
    if not parent:HasModifier("modifier_super_scepter") then
        return
    end
    -- The passive aura requires the other ability "void_spirit_astral_step" to be on autocast and have at least 2 charges.
    local astral_step_ability = parent:FindAbilityByName("void_spirit_astral_step")
    if not astral_step_ability or not astral_step_ability:GetAutoCastState() or astral_step_ability:GetCurrentAbilityCharges() < 3 then
        return -- Conditions not met, do nothing.
    end

    -- Use one charge from the other ability to fuel this passive proc
    local blast_staff_proc_modifier = nil
    local blast_staff_proc_modifier = nil
    local simulated_keys = {
        ability = astral_step_ability,
        unit = parent,
    }

    if parent:HasItemInInventory("item_blast_staff_3") then
        blast_staff_proc_modifier = parent:FindModifierByName("modifier_item_blast_staff3_proc")
    elseif parent:HasItemInInventory("item_blast_staff_2") then
        blast_staff_proc_modifier = parent:FindModifierByName("modifier_item_blast_staff_proc")
    elseif parent:HasItemInInventory("item_blast_staff_1") then
        blast_staff_proc_modifier = parent:FindModifierByName("modifier_item_blast_staff_proc")
    end

    if blast_staff_proc_modifier then
        -- Artificially trigger the OnAbilityFullyCast event for the item's proc modifier
        blast_staff_proc_modifier:OnAbilityFullyCast(simulated_keys)
    end

    local current_charges = astral_step_ability:GetCurrentAbilityCharges()
    if current_charges and current_charges > 0 then
        astral_step_ability:SetCurrentAbilityCharges(current_charges - 1)
    end

    local origin = parent:GetOrigin()
    local search_range = ability:GetSpecialValueFor("ss_aura_range")
    local pattern_radius = ability:GetSpecialValueFor("radius")

    -- Find the nearest valid enemy
    local nearest_enemy = ability:FindNearestEnemy(origin, search_range)

    if nearest_enemy then
        -- Add crit modifier for this passive proc
        ability:_AddCrit()

        local target_pos = nearest_enemy:GetOrigin()

        -- Randomly select a pattern
        local pattern_types = {"line", "x_form", "cross_form", "smaller_star"}
        local weights = {1, 1, 1, 0.5} -- "smaller_star" is less common
        local selected_pattern = RollPseudoRandom(1, pattern_types, weights) -- Using a cleaner random function

        -- Generate the points for the selected pattern
        local pattern_points = ability:GeneratePatternPoints(selected_pattern, origin, target_pos, pattern_radius)

        -- Create the damaging lines for the pattern
        for _, line_data in ipairs(pattern_points) do
             ability:_CreateAstralLine({
                origin = line_data.origin,
                point = line_data.point,
                max_dist = (line_data.point - line_data.origin):Length2D()
             })
        end

        -- Remove crit modifier after the proc is finished
        ability:_RemoveCrit()
    end
end

--------------------------------------------------------------------------------
-- CORE LOGIC & HELPER FUNCTIONS
--------------------------------------------------------------------------------

-- This is the core function that creates a single damaging line. It's called by both the active cast and the passive aura.
function ability_class:_CreateAstralLine(kv)
    local caster = self:GetCaster()
    local origin = kv.origin
    local point = kv.point

	local min_dist = self:GetSpecialValueFor("min_travel_distance")
	local max_dist = kv.max_dist or self:GetSpecialValueFor("max_travel_distance")
	local radius = self:GetSpecialValueFor("radius")
	local pop_delay = self:GetSpecialValueFor("pop_damage_delay")

	local direction = (point - origin):Normalized()
	local dist = math.min(max_dist, (point - origin):Length2D())
	local target_pos = GetGroundPosition(origin + direction * dist, nil)

	local enemies = FindUnitsInLine(
		caster:GetTeamNumber(),
		origin,
		target_pos,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE -- Does not hit magic immune unless you change this
	)

	for _, enemy in pairs(enemies) do
		caster:PerformAttack(enemy, true, true, true, false, true, false, true)

		enemy:AddNewModifier(
			caster,
			self,
			"modifier_void_spirit_astral_step_lua", -- This modifier handles the delayed damage pop
			{ duration = pop_delay }
		)
		self:PlayEffects2(enemy) -- Impact effect on each enemy
	end
	
	self:PlayEffects1(origin, target_pos) -- Line travel effect
end

-- Helper to find the nearest enemy
function ability_class:FindNearestEnemy(origin, range)
    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        origin,
        nil,
        range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    return enemies[1]
end

-- Helper to generate points for the passive aura patterns
function ability_class:GeneratePatternPoints(pattern_type, caster_pos, target_pos, radius)
    local points_list = {}
    local line_length = radius * 4 -- radius is 370
    local direction_to_target = (target_pos - caster_pos):Normalized()
    local perpendicular_direction = Vector(-direction_to_target.y, direction_to_target.x, 0)
    local ground_z = GetGroundPosition(target_pos, nil).z -- Ensure patterns are on the ground

    target_pos.z = ground_z -- Adjust target Z

    if pattern_type == "line" then
        local start_pos = target_pos - perpendicular_direction * (line_length / 2)
        local end_pos = target_pos + perpendicular_direction * (line_length / 2)
        table.insert(points_list, {origin = start_pos, point = end_pos})

    elseif pattern_type == "x_form" then
        local dir1 = RotatePosition(Vector(0,0,0), QAngle(0, 45, 0), perpendicular_direction)
        local dir2 = RotatePosition(Vector(0,0,0), QAngle(0, 135, 0), perpendicular_direction)
        table.insert(points_list, {origin = target_pos - dir1 * (line_length / 2), point = target_pos + dir1 * (line_length / 2)})
        table.insert(points_list, {origin = target_pos - dir2 * (line_length / 2), point = target_pos + dir2 * (line_length / 2)})

    elseif pattern_type == "cross_form" then
        -- Use world-aligned axes for a static '+' shape, providing clear visual distinction from X-form
        local dir_north_south = Vector(0, 1, 0)
        local dir_east_west = Vector(1, 0, 0)
        table.insert(points_list, {origin = target_pos - dir_north_south * (line_length / 2), point = target_pos + dir_north_south * (line_length / 2)})
        table.insert(points_list, {origin = target_pos - dir_east_west * (line_length / 2), point = target_pos + dir_east_west * (line_length / 2)})

    elseif pattern_type == "smaller_star" then
        local num_points = 5
        local offset_angle = RandomInt(0, 359)
        local vertices = {}
        for i = 0, num_points - 1 do
            local angle = (i / num_points) * 360 + offset_angle
            local x = radius * 1.5 * math.cos(math.rad(angle)) + target_pos.x
            local y = radius * 1.5 * math.sin(math.rad(angle)) + target_pos.y
            vertices[i+1] = Vector(x, y, ground_z)
        end
        -- Connect vertices to form a 5-pointed star (pentagram)
        for i = 1, num_points do
            local start_vertex = vertices[i]
            local end_index = (i + 2)
            if end_index > num_points then end_index = end_index - num_points end
            local end_vertex = vertices[end_index]
            table.insert(points_list, {origin = start_vertex, point = end_vertex})
        end
    end
    return points_list
end

-- Crit modifier management
function ability_class:_AddCrit()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mjz_void_spirit_astral_atlas_crit", {})
end

function ability_class:_RemoveCrit()
    self:GetCaster():RemoveModifierByName("modifier_mjz_void_spirit_astral_atlas_crit")
end

--------------------------------------------------------------------------------
-- VISUAL & SOUND EFFECTS
--------------------------------------------------------------------------------
function ability_class:PlayEffects1(origin, target)
	local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf"
	local sound_start = "Hero_VoidSpirit.AstralStep.Start"
	local sound_end = "Hero_VoidSpirit.AstralStep.End"

	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(effect_cast, 0, origin)
	ParticleManager:SetParticleControl(effect_cast, 1, target)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitSoundOnLocationWithCaster(origin, sound_start, self:GetCaster())
	EmitSoundOnLocationWithCaster(target, sound_end, self:GetCaster())
end

function ability_class:PlayEffects2(target)
	local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

-- A clean way to do weighted random selection using Dota 2's RollPseudoRandomPercentage.
function RollPseudoRandom(unit, t, weights)
    local total_weight = 0
    for _, weight in ipairs(weights) do
        total_weight = total_weight + weight
    end

    -- Use RandomFloat for a roll between 0 and the total_weight
    local roll = RandomFloat(0, total_weight)
    local cumulative_weight = 0
    for i, weight in ipairs(weights) do
        cumulative_weight = cumulative_weight + weight
        if roll <= cumulative_weight then
            return t[i]
        end
    end
    
    return t[#t] -- Fallback to the last item
end