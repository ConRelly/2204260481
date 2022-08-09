LinkLuaModifier("modifier_mjz_phoenix_sun_ray_check","modifiers/hero_phoenix/modifier_mjz_phoenix_sun_ray_thinker.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_phoenix_sun_ray_thinker = class({})
local modifier_class = modifier_mjz_phoenix_sun_ray_thinker

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:CheckState() 
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] 	    = true,
		[MODIFIER_STATE_INVULNERABLE] 			= true,
		[MODIFIER_STATE_NO_HEALTH_BAR] 			= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP]		    = true,
		[MODIFIER_STATE_UNSELECTABLE]		    = true,
	}
	return state
end

if IsServer() then
    function modifier_class:OnCreated(table)
        local parent = self:GetParent()
        parent:AddNewModifier(nil, nil, 'modifier_phased', {})  -- 添加相位状态
    end

    function modifier_class:OnCreated(table)
        local parent = self:GetParent()
        parent:RemoveModifierByName('modifier_phased')          -- 移除相位状态
    end
end

---------------------------------------------------------------

function modifier_class:IsAura() return true end
function modifier_class:GetModifierAura()
	return "modifier_mjz_phoenix_sun_ray_check"
end
function modifier_class:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "thinker_radius" )
end
function modifier_class:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end
function modifier_class:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end
function modifier_class:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

---------------------------------------------------------------


modifier_mjz_phoenix_sun_ray_check = class({})
local modifier_check = modifier_mjz_phoenix_sun_ray_check

function modifier_check:IsHidden() return true end
function modifier_check:IsPurgable() return false end

if IsServer() then
    function modifier_check:OnCreated(table)
        local ability = self:GetAbility()
        local tick_interval = ability:GetSpecialValueFor('tick_interval')
        self:StartIntervalThink(tick_interval)
    end

    function modifier_check:OnIntervalThink()
        self:_CheckForCollision()
    end

    function modifier_check:_CheckForCollision( )
        local caster			= self:GetCaster()
        local target			= self:GetParent()
        local ability			= self:GetAbility()
    
        local pathLength		= ability:GetSpecialValueFor('beam_range')
        local pathRadius		= ability:GetSpecialValueFor('radius')
    
        local tickInterval		= ability:GetSpecialValueFor('tick_interval')
        local baseDamage		= ability:GetSpecialValueFor('base_dmg')
        local hpPercentDamage	= ability:GetSpecialValueFor('hp_perc_dmg') + talent_value(caster, "special_bonus_unique_phoenix_5")
        local base_heal         = ability:GetSpecialValueFor('base_heal')
        local hp_perc_heal      = ability:GetSpecialValueFor('hp_perc_heal')
        local particle_burn_name = "particles/units/heroes/hero_phoenix/phoenix_sunray_beam_enemy.vpcf"
        local particle_heal_name = "particles/units/heroes/hero_phoenix/phoenix_sunray_beam_friend.vpcf"
    
        if target == caster then return nil end

        -- Calculate distance
        local pathStartPos	= caster:GetAbsOrigin() * Vector( 1, 1, 0 )
        local pathEndPos	= pathStartPos + caster:GetForwardVector() * pathLength
    
        local distance = DistancePointSegment( target:GetAbsOrigin() * Vector( 1, 1, 0 ), pathStartPos, pathEndPos )
        if distance > pathRadius then
            return
        end
        local enemy_distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
        -- Calculate damage
        local damage = baseDamage + caster:GetMaxHealth() * (hpPercentDamage / 100.0)
        damage = damage * tickInterval
		if _G._challenge_bosss > 0 then
            local target_health = target:GetHealthPercent()
            local limiter = _G._challenge_bosss + 1
            if limiter < 2 then limiter = 2 end
            if target_health > 50 then 
                local bonus_dmg_distance = math.floor(enemy_distance / 17) * limiter
                bonus_dmg_distance = bonus_dmg_distance / 100
                if bonus_dmg_distance > limiter then
                    bonus_dmg_distance = limiter
                end 
                if bonus_dmg_distance < 1 then
                    bonus_dmg_distance = 1
                end 
                print("above 50% bonus: "..bonus_dmg_distance)                 
                damage = damage * bonus_dmg_distance
            else
                local bonus_dmg_distance = math.floor(200 /  enemy_distance) * limiter
                bonus_dmg_distance = bonus_dmg_distance / 100
                if bonus_dmg_distance > limiter then
                    bonus_dmg_distance = limiter
                end 
                if bonus_dmg_distance < 1 then
                    bonus_dmg_distance = 1
                end 
                print("below 50% bonus: "..bonus_dmg_distance)                  
                damage = damage * bonus_dmg_distance                
            end    
		end        
        -- Check team
        -- local isEnemy = caster:IsOpposingTeam( target:GetTeamNumber() )
        local isEnemy = TargetIsEnemy(caster, target)
    
        if isEnemy then
            -- Remove HP
            ApplyDamage( {
                victim		= target,
                attacker	= caster,
                damage		= damage,
                damage_type	= ability:GetAbilityDamageType(),
            } )
    
            -- Fire burn particle
            local pfx = ParticleManager:CreateParticle( particle_burn_name, PATTACH_ABSORIGIN, target )
            ParticleManager:SetParticleControlEnt( pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
            ParticleManager:ReleaseParticleIndex( pfx )
    
        else
            -- Healing
            local heal_amount = base_heal + caster:GetMaxHealth() * (hp_perc_heal / 100.0)
            heal_amount = heal_amount * tickInterval
            target:Heal( heal_amount, caster )

            create_popup({
                target = target,
                value = heal_amount,
                color = Vector(0, 255, 0),  -- greed
                type = "heal"
            }) 
    
            local pfx = ParticleManager:CreateParticle( particle_heal_name, PATTACH_ABSORIGIN, target )
            ParticleManager:ReleaseParticleIndex( pfx )
        end
    end
end



----------------------------------------------------------------------------------

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Distance between a point and a segment.
]]
function DistancePointSegment( p, v, w )
	local l = w - v
	local l2 = l:Dot( l )
	t = ( p - v ):Dot( w - v ) / l2
	if t < 0.0 then
		return ( v - p ):Length2D()
	elseif t > 1.0 then
		return ( w - p ):Length2D()
	else
		local proj = v + t * l
		return ( proj - p ):Length2D()
	end
end


function TargetIsFriendly(caster, target )
	local nTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY 	-- ability:GetAbilityTargetTeam()
	local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
	local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end

function TargetIsEnemy(caster, target )
	local nTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY 	-- ability:GetAbilityTargetTeam()
	local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
	local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end

--[[
    A quick function to create popups.
    Example:
    create_popup({
        target = target,
        value = value,
        color = Vector(255, 20, 147),
        type = "spell_custom"
	}) 
	伤害类型的颜色：
		物理：Vector(174, 47, 40)
		魔法：Vector(91, 147, 209)
		纯粹：Vector(216, 174, 83)
	spell_custom: 
        block | crit | damage | evade | gold | heal | mana_add | mana_loss | miss | poison | spell | xp
    Color:
        red 	={255,0,0},
        orange	={255,127,0},
        yellow	={255,255,0},
        green 	={0,255,0},
        blue 	={0,0,255},
        indigo 	={0,255,255},
        purple 	={255,0,255},
]]
function create_popup(data)
    local target = data.target
    local value = math.floor(data.value)

    local type = data.type or "miss"
    local color = data.color or Vector(255, 255, 255)
    local duration = data.duration or 1.0

    local size = string.len(value)

    local pre = data.pre or nil
    if pre ~= nil then
        size = size + 1
    end

    local pos = data.pos or nil
    if pos ~= nil then
        size = size + 1
    end

    local particle_path = "particles/msg_fx/msg_" .. type .. ".vpcf"
    local particle = ParticleManager:CreateParticle(particle_path, PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 1, Vector(pre, value, pos))
    ParticleManager:SetParticleControl(particle, 2, Vector(duration, size, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
    ParticleManager:ReleaseParticleIndex(particle)
end
