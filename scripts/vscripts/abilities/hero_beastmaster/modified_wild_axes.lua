--[[
Modified Wild Axes
- Axe spin around hero
- Applies a damage amplification that only affects this skill
- Aghanim's Scepter: adds an second axe, Axes are not inteligent and ajust their range between min 500 and 100 + your attack range ,base on the closest enemy to you in range 
- Shard adds the option to chose between magic and physical dmg type 
- if it has modifier_super_scepter(SS) : add a 3rd axe , increase the spin rate by 1.5 and now the debuff stacks with no limit but with 5x les amp
]]
LinkLuaModifier("modifier_modified_wild_axes_thinker", "abilities/hero_beastmaster/modified_wild_axes.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_modified_wild_axes_amp", "abilities/hero_beastmaster/modified_wild_axes.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_modified_wild_axes_hit_tracker", "abilities/hero_beastmaster/modified_wild_axes.lua", LUA_MODIFIER_MOTION_NONE)

modified_wild_axes = class({})

function modified_wild_axes:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
	return DOTA_ABILITY_BEHAVIOR_TOGGLE
end
function modified_wild_axes:ResetToggleOnRespawn() return false end

function modified_wild_axes:OnToggle()
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_modified_wild_axes_thinker") then
        caster:RemoveModifierByName("modifier_modified_wild_axes_thinker")
    else
        caster:AddNewModifier(caster, self, "modifier_modified_wild_axes_thinker", {})
    end
end

function modified_wild_axes:OnOwnerSpawned()
	local caster = self:GetCaster()
	local ability = self

	if ability and ability:GetToggleState() then
		self:OnToggle()
    end
end

function modified_wild_axes:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
        local range = self:GetCaster():Script_GetAttackRange() + 100
        if range < 500 then
            range = 500
        end
		return range
	end
    return self:GetSpecialValueFor("axe_distance")
end

modifier_modified_wild_axes_thinker = class({})
function modifier_modified_wild_axes_thinker:IsHidden() return true end
function modifier_modified_wild_axes_thinker:IsPurgable() return false end

function modifier_modified_wild_axes_thinker:OnCreated()
    if IsServer() then
        self.ability = self:GetAbility()
        self.caster = self:GetCaster()
        
        self.radius = self.ability:GetCastRange(self.caster:GetAbsOrigin(), self.caster)
        self.angle = 0
        self.speed = self.ability:GetSpecialValueFor("axe_speed") + talent_value(self.caster, "special_bonus_modified_wild_axes_speed")
        self.damage = self.ability:GetSpecialValueFor("base_damage")
        self.damage_amp = self.ability:GetSpecialValueFor("damage_amp_pct") / 100  
        self.amp_duration = self.ability:GetSpecialValueFor("amp_duration")

        -- Adjust for Aghanim's Scepter upgrades
        self.num_axes = 1
        if self.caster:HasScepter() then
            self.num_axes = self.num_axes + 1
        end
        if self.caster:HasModifier("modifier_super_scepter") then
            self.num_axes = self.num_axes + 1
            self.speed = self.speed * 1.5
            self.damage_amp = (self.ability:GetSpecialValueFor("damage_amp_pct") / 100) / 5
        end
        -- Particle
        self.axe_particles = {}
        for i = 1, self.num_axes do
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf", PATTACH_ABSORIGIN, self.caster)
            ParticleManager:SetParticleControl(particle, 0, self.caster:GetAbsOrigin())
            table.insert(self.axe_particles, particle)
        end

        -- Start spinning
        self:StartIntervalThink(0.06)
    end
end


function modifier_modified_wild_axes_thinker:UpdateAxeRange()
    if not (self.caster:HasScepter() and self.caster:HasModifier("modifier_item_aghanims_shard")) then
        return
    end

    local current_time = GameRules:GetGameTime()
    if not self.last_range_check then
        self.last_range_check = current_time
    end
    if current_time - self.last_range_check < 1.0 then
        return
    end
    self.last_range_check = current_time

    local caster_pos = self.caster:GetAbsOrigin()
    local max_attack_range = self.caster:Script_GetAttackRange() + 100
    local min_range = 500
    local nearest_enemy_dist = max_attack_range
    local enemy_min_dist = 250

    -- Find nearest enemy in attack range
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        caster_pos,
        nil,
        max_attack_range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    -- Default to minimum range
    self.radius = min_range

    -- Only adjust if we found a valid enemy
    if #enemies > 0 then
        local enemy_dist = (enemies[1]:GetAbsOrigin() - caster_pos):Length2D()
        if enemy_dist >= enemy_min_dist then
            self.radius = math.max(min_range, math.min(enemy_dist, max_attack_range))
        end
    end
end


function modifier_modified_wild_axes_thinker:OnIntervalThink()
    if not IsServer() then
        return
    end
    if not self.caster:IsAlive() then
        self:Destroy()
        return
    end
    -- Update axe range if needed
    self:UpdateAxeRange()  

    local caster_position = self.caster:GetAbsOrigin()
    local axe_width = self.ability:GetSpecialValueFor("axe_width")

    -- Spin each axe around the caster
    for i = 1, self.num_axes do
        local angle = (self.angle + ((360 / self.num_axes) * i)) * math.pi / 180
        local axe_position = Vector(math.cos(angle) * self.radius, math.sin(angle) * self.radius, 0) + caster_position
        ParticleManager:SetParticleControl(self.axe_particles[i], 0, axe_position)

        -- Check for nearby enemies
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), axe_position, nil, axe_width,
                                          DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                                          DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
        
        for _, enemy in pairs(enemies) do
            -- Only damage if they don't have the hit tracker modifier
            if not enemy:HasModifier("modifier_modified_wild_axes_hit_tracker") then
                
                local has_super_scepter = self.caster:HasModifier("modifier_super_scepter")
                local dmg_type = DAMAGE_TYPE_PHYSICAL
                local lvl = self.caster:GetLevel()    
                local attack_dmg_perlvl = (self:GetAbility():GetSpecialValueFor("attack_dmg_perlvl") / 100 ) * lvl
                local caster_attack = self.caster:GetAverageTrueAttackDamage(self.caster) * attack_dmg_perlvl
                if self.ability:GetAutoCastState() then
                    dmg_type = DAMAGE_TYPE_MAGICAL
                    caster_attack = caster_attack / 4
                end
                local stacks = 0
                local has_amp_modif = enemy:HasModifier("modifier_modified_wild_axes_amp")
                if has_amp_modif then
                    stacks = enemy:FindModifierByName("modifier_modified_wild_axes_amp"):GetStackCount()
                end
                local damage = caster_attack + (self.damage * lvl)
                local amp = 1 + stacks * self.damage_amp
                local amp_damage = damage * amp
                local damage_table = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = amp_damage,
                    damage_type = dmg_type,
                    ability = self.ability
                }
                ApplyDamage(damage_table)

                -- Apply hit tracker to prevent multiple hits in a short period
                if enemy and enemy:IsAlive() then
                    enemy:AddNewModifier(self.caster, self.ability, "modifier_modified_wild_axes_hit_tracker", {duration = 0.45})

                    -- Apply damage amplification modifier
                    if not has_amp_modif then
                        local amp_modifier = enemy:AddNewModifier(self.caster, self.ability, "modifier_modified_wild_axes_amp", {duration = self.amp_duration})
                        amp_modifier:SetStackCount(1)
                    elseif has_super_scepter and has_amp_modif then
                        local amp_modifier = enemy:FindModifierByName("modifier_modified_wild_axes_amp")
                        amp_modifier:IncrementStackCount()
                        amp_modifier:SetDuration(self.amp_duration, true)
                    end
                end
            end
        end
    end

    -- Update angle for next interval
    self.angle = self.angle + self.speed
end

function modifier_modified_wild_axes_thinker:OnDestroy()
    if IsServer() then
        for _, particle in ipairs(self.axe_particles) do
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end
end

modifier_modified_wild_axes_amp = class({})

function modifier_modified_wild_axes_amp:IsHidden()
    return false
end

function modifier_modified_wild_axes_amp:IsDebuff()
    return true
end

function modifier_modified_wild_axes_amp:IsPurgable()
    return true
end

function modifier_modified_wild_axes_amp:GetTexture()
    return "beastmaster_wild_axes"
end

function modifier_modified_wild_axes_amp:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_modified_wild_axes_amp:OnTooltip()
    local ability = self:GetAbility()
    local damage_amp = ability:GetSpecialValueFor("damage_amp_pct") 
    if self:GetCaster():HasModifier("modifier_super_scepter") then
        damage_amp = damage_amp / 5
    end
    if damage_amp then
        return self:GetStackCount() * damage_amp
    end
    return 0
end


function modifier_modified_wild_axes_amp:OnCreated()

end

function modifier_modified_wild_axes_amp:OnRefresh()

end

-- Short-lived modifier to prevent multiple hits per pass
modifier_modified_wild_axes_hit_tracker = class({})

function modifier_modified_wild_axes_hit_tracker:IsHidden()
    return true
end

function modifier_modified_wild_axes_hit_tracker:IsDebuff()
    return true
end

function modifier_modified_wild_axes_hit_tracker:IsPurgable()
    return false
end
