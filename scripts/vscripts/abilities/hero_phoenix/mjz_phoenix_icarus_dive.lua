
local THIS_LUA = "abilities/hero_phoenix/mjz_phoenix_icarus_dive.lua"
local MODIFIER_CASTER_NAME = "modifier_mjz_phoenix_icarus_dive"
local MODIFIER_SPECIAL_NAME = "modifier_mjz_phoenix_icarus_dive_special"

LinkLuaModifier(MODIFIER_CASTER_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_SPECIAL_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_phoenix_icarus_dive = class({})
local ability_class = mjz_phoenix_icarus_dive

function mjz_phoenix_icarus_dive:GetAbilityTextureName()
	if self:GetCaster():HasScepter() then return "custom/abilities/mjz_phoenix_icarus_dive" end
	return "mjz_phoenix_icarus_dive"
end
function mjz_phoenix_icarus_dive:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level) - talent_value(self:GetCaster(), "special_bonus_unique_mjz_phoenix_icarus_dive_cdr")
end
function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetAOERadius()
end

function ability_class:GetAOERadius()
	local caster = self:GetCaster()
	local abiltiy = self
	local modifer_talent = MODIFIER_SPECIAL_NAME --"special_bonus_unique_phoenix_4"
	local talent_value = 1100
	local radius = abiltiy:GetSpecialValueFor('dragon_slave_distance')
	local has_talent = caster:HasModifier(modifer_talent)

	if IsServer() then
		local sp = caster:FindAbilityByName("special_bonus_unique_phoenix_4")
		if sp and sp:GetLevel() > 0 then
			if not caster:HasModifier(MODIFIER_SPECIAL_NAME) then
				caster:AddNewModifier(caster, ability, MODIFIER_SPECIAL_NAME, {})
			end
		end
	end

	if has_talent then
		radius = radius + talent_value
	end
	return radius
end


if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local projectile_name = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf"
		local p_name = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf"
		if caster:HasScepter() then
			projectile_name = p_name
		end
		local projectile_distance = GetTalentSpecialValueFor(ability, "dragon_slave_distance" )
		local projectile_speed = self:GetSpecialValueFor( "dragon_slave_speed" )
		local projectile_start_radius = self:GetSpecialValueFor( "dragon_slave_width_initial" )
		local projectile_end_radius = self:GetSpecialValueFor( "dragon_slave_width_end" )
		
		local direction = point - caster:GetOrigin()
		direction.z = 0
		local projectile_direction = direction:Normalized()


		 local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
        vDirection = vDirection:Normalized()
        local fDistance = (self:GetCursorPosition() - self:GetCaster():GetOrigin()):Length2D()
		-- projectile_distance = projectile_distance + caster:GetCastRangeBonus()
		projectile_distance = fDistance

		-- create projectile
		local info = {
			Source = caster,
			Ability = ability,
			vSpawnOrigin = caster:GetAbsOrigin(),
			
			bDeleteOnHit = false,
			
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = ability:GetAbilityTargetFlags(),
			iUnitTargetType = ability:GetAbilityTargetType(),
			
			EffectName = projectile_name,
			fDistance = projectile_distance,
			fStartRadius = projectile_start_radius,
			fEndRadius = projectile_end_radius,
			vVelocity = projectile_direction * projectile_speed,

			bProvidesVision = true,
			iVisionTeamNumber = caster:GetTeamNumber(),
            iVisionRadius = 300,
		}

		self.m_hMod = caster:AddNewModifier( caster, ability, "modifier_mjz_phoenix_icarus_dive", {} )

		-- Play effects
		local sound_cast = "Hero_Lina.DragonSlave.Cast"
		local sound_projectile = "Hero_Lina.DragonSlave"
		EmitSoundOn( sound_cast, self:GetCaster() )
		EmitSoundOn( sound_projectile, self:GetCaster() )

		
		ProjectileManager:CreateLinearProjectile(info)

	end
    function ability_class:GetPrimaryStatValue()
        local STRENGTH = 0
        local AGILITY = 1
        local INTELLIGENCE = 2
        local unit = self:GetParent()
        local pa = unit:GetPrimaryAttribute()
        local PrimaryStatValue = 0
        if pa == STRENGTH  then
            PrimaryStatValue = unit:GetStrength()
        elseif pa == AGILITY  then
            PrimaryStatValue = unit:GetAgility()
        elseif pa == INTELLIGENCE  then
            PrimaryStatValue = unit:GetIntellect()
        end
        return PrimaryStatValue
    end	
end

function ability_class:OnProjectileHit_ExtraData( hTarget, vLocation, table )
    if hTarget == nil then
		local caster = self:GetCaster()
        caster:SetAbsOrigin(vLocation)
        FindClearSpaceForUnit( caster, vLocation, true)

        if self.m_hMod and caster:IsAlive() and caster:HasModifier("modifier_mjz_phoenix_icarus_dive") then
			if self.m_hMod:IsNull() then return end
            self.m_hMod:Destroy()
        end
    end

    return false
end

function ability_class:OnProjectileHitHandle( target, location, projectile )
	if not target then return end
	local ability = self
	local caster = self:GetCaster()
	local caster_attr = caster:GetPrimaryStatValue()
	local attr_mult = self:GetSpecialValueFor("attr_damage")
	local bonus_dmg = caster_attr * attr_mult
	-- 0 = strength, 1 = agility, 2 = intelligence.
	-- apply damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetAbilityDamage() + bonus_dmg,
		damage_type = self:GetAbilityDamageType(),
		ability = ability, --Optional.
	}
	ApplyDamage( damageTable )

	-- get direction
	local direction = ProjectileManager:GetLinearProjectileVelocity( projectile )
	direction.z = 0
	direction = direction:Normalized()

	-- play effects
	self:PlayEffects( target, direction )
end

function ability_class:PlayEffects( target, direction )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf"
	local p_cast = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_impact_headflame.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( p_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

-----------------------------------------------------------------------------------------

modifier_mjz_phoenix_icarus_dive = class({})

function modifier_mjz_phoenix_icarus_dive:IsHidden() return true end
function modifier_mjz_phoenix_icarus_dive:IsPurgable() return true end

function modifier_mjz_phoenix_icarus_dive:OnCreated( kv )
    if IsServer() then
        self:GetParent():AddNoDraw()
    end
end
function modifier_mjz_phoenix_icarus_dive:OnDestroy(  )
     if IsServer() then
        self:GetParent():RemoveNoDraw()
    end
end

function modifier_mjz_phoenix_icarus_dive:CheckState()
	local state = {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end


-----------------------------------------------------------------------------------------

modifier_mjz_phoenix_icarus_dive_special = class({})

function modifier_mjz_phoenix_icarus_dive_special:IsHidden() return true end
function modifier_mjz_phoenix_icarus_dive_special:IsPurgable() return true end
-- 效果永久，死亡不消失
function modifier_mjz_phoenix_icarus_dive_special:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

-----------------------------------------------------------------------------------------

-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
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