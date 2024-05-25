LinkLuaModifier("modifier_mjz_puck_illusory_orb_prisoner", "abilities/hero_puck/mjz_puck_illusory_orb.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_puck_illusory_orb_projectile", "abilities/hero_puck/mjz_puck_illusory_orb.lua", LUA_MODIFIER_MOTION_NONE)

local ABLIITY_JAUNT_NAME = "mjz_puck_ethereal_jaunt"

mjz_puck_illusory_orb= class({})
local ability_class = mjz_puck_illusory_orb

-- Shared data
ability_class.projectiles = {}

function ability_class:OnSpellStart()	
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local point = self:GetCursorPosition()
		local base_damage = GetTalentSpecialValueFor(ability, "damage")
		local int_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		local projectile_radius = GetTalentSpecialValueFor(ability, "radius")
		local projectile_distance = GetTalentSpecialValueFor(ability, "max_distance")
		local projectile_speed = GetTalentSpecialValueFor(ability, "orb_speed")
		local vision_radius = GetTalentSpecialValueFor(ability, "orb_vision")
		local vision_duration = GetTalentSpecialValueFor(ability, "vision_duration")

		local damage = base_damage + caster:GetIntellect(true) * int_damage / 100

		local projectile_direction = point - caster:GetOrigin()
		projectile_direction = Vector( projectile_direction.x, projectile_direction.y, 0 ):Normalized()
		local projectile_name = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf"

		-- create projectile
		local info = {
			Source = caster,
			Ability = ability,
			vSpawnOrigin = caster:GetOrigin(),
			
			bDeleteOnHit = false,
			
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			
			EffectName = projectile_name,
			fDistance = projectile_distance,
			fStartRadius = projectile_radius,
			fExpireTime = GameRules:GetGameTime() + 10,
			fEndRadius =projectile_radius,
			vVelocity = projectile_direction * projectile_speed,
		
			bReplaceExisting = false,
			
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber(),
		}
		local projectile = ProjectileManager:CreateLinearProjectile(info)

		-- sound modifier
		local modifier = CreateModifierThinker(
			caster,
			self,
			"modifier_mjz_puck_illusory_orb_projectile",
			{ duration = 20 },
			caster:GetOrigin(),
			caster:GetTeamNumber(),
			false		
		)
		modifier = modifier:FindModifierByName( "modifier_mjz_puck_illusory_orb_projectile" )

		-- register projectile
		local extraData = {}
		extraData.damage = damage
		extraData.location = caster:GetOrigin()
		extraData.time = GameRules:GetGameTime()
		extraData.modifier = modifier
		self.projectiles[projectile] = extraData

		-- activate sub
		self.jaunt:SetActivated( true )
	end
end

if IsServer() then
	function ability_class:OnProjectileThinkHandle( proj )
		-- update location
		local location = ProjectileManager:GetLinearProjectileLocation( proj )
		self.projectiles[proj].location = location
		self.projectiles[proj].modifier:GetParent():SetOrigin( location )
	end

	function ability_class:OnProjectileHitHandle( target, location, proj )
		local ability = self
		if not target then 
			-- destroy reference
			self.projectiles[proj].modifier:Destroy()
			self.projectiles[proj] = nil
			self.jaunt:Deactivate()
			return true
		end
	
		-- damage
		local damageTable = {
			victim = target,
			attacker = self:GetCaster(),
			damage = self.projectiles[proj].damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability, --Optional.
		}
		ApplyDamage(damageTable)
	
		-- effects
		self:PlayEffects( target )
		return false
	end
	
	function ability_class:OnUpgrade()
		if not self.jaunt then
			-- init
			self.jaunt = self:GetCaster():FindAbilityByName( ABLIITY_JAUNT_NAME )
			self.jaunt.projectiles = self.projectiles
			self.jaunt:SetActivated( false )
		end
	
		self.jaunt:UpgradeAbility( true )
	end

	function ability_class:PlayEffects( target )
		-- Get Resources
		local particle_cast = "particles/units/heroes/hero_puck/puck_orb_damage.vpcf"
		local sound_cast = "Hero_Puck.IIllusory_Orb_Damage"
	
		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:DestroyParticle(effect_cast, false)
		ParticleManager:ReleaseParticleIndex( effect_cast )
	
		-- Create Sound
		EmitSoundOn( sound_cast, target )
	end
end


-----------------------------------------------------------------------------------------

modifier_mjz_puck_illusory_orb_projectile = class({})
local modifier_class_projectile = modifier_mjz_puck_illusory_orb_projectile

function modifier_class_projectile:IsHidden() return true end
function modifier_class_projectile:IsPurgable() return false end


function modifier_class_projectile:CheckState()
    local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
    return state  
end

if IsServer() then	

	function modifier_class_projectile:OnCreated( keys )
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		EmitSoundOn("Hero_Puck.Illusory_Orb", parent)
	end

	function modifier_class_projectile:OnDestroy( keys )
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		StopSoundOn("Hero_Puck.Illusory_Orb", parent)
	end

end

-----------------------------------------------------------------------------------------



function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local talentOperation
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    talentOperation = m["LinkedSpecialBonusOperation"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then 
            local talentValue = talent:GetSpecialValueFor("value")
            if talentOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                base = base + base * talentValue * 0.01
            else
                base = base + talentValue
            end
        end
    end
    return base
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

function create_popup_by_damage_type(data, ability)
    local damage_type = ability:GetAbilityDamageType()
    if damage_type == DAMAGE_TYPE_PHYSICAL then
        data.color = Vector(174, 47, 40)
    elseif damage_type == DAMAGE_TYPE_MAGICAL then
        data.color = Vector(91, 147, 209)
    elseif damage_type == DAMAGE_TYPE_PURE then
        data.color = Vector(216, 174, 83)
    else
        data.color = Vector(255, 255, 255)
    end
    create_popup(data)
end

