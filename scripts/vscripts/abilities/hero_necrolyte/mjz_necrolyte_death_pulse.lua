
LinkLuaModifier("modifier_mjz_necrolyte_death_pulse","abilities/hero_necrolyte/mjz_necrolyte_death_pulse.lua", LUA_MODIFIER_MOTION_NONE)


mjz_necrolyte_death_pulse = class({})
local ability_class = mjz_necrolyte_death_pulse


function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius') + self:GetCaster():GetCastRangeBonus()
end
function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('radius') + self:GetCaster():GetCastRangeBonus()
end

function ability_class:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self
	local max_count = ability:GetSpecialValueFor("max_count")
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
	local radius = ability:GetAOERadius()
	
	EmitSoundOn("Hero_Necrolyte.DeathPulse", caster)

	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius,
					DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
					DOTA_UNIT_TARGET_FLAG_NONE,	--DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
					FIND_CLOSEST, false)

	for _,enemy in pairs(enemies) do
		if max_count > 0 then
			max_count = max_count - 1

			ProjectileManager:CreateTrackingProjectile({
				Target = enemy,
				Source = caster,
				Ability = ability,
				EffectName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf",
				bDodgeable = true,
				iMoveSpeed = projectile_speed,
				-- bProvidesVision = true,
				-- iVisionRadius = 250,
				-- iVisionTeamNumber = caster:GetTeamNumber(),
			})
		end
	end

end

function ability_class:OnProjectileHit( hTarget, vLocation ) 
	local caster = self:GetCaster()
	local ability = self
	if hTarget and IsValidEntity(hTarget) then 
		if hTarget:GetTeam() ~= caster:GetTeam() then
			ApplyDamage({
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = self:_CalcDamage(hTarget),
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			})
		else 
			local flheal = self:_CalcHeal(hTarget)
			hTarget:Heal(flheal, caster)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, hTarget, flheal, caster:GetPlayerOwner())
		end
	end
end

function ability_class:_CalcDamage( hTarget)
	local caster = self:GetCaster()
	local ability = self
	local base_damage = ability:GetSpecialValueFor("base_damage")
	local int_damage_multiplier = ability:GetSpecialValueFor("int_damage_multiplier")
	if caster:IsHero() then
		return base_damage + caster:GetIntellect() * int_damage_multiplier
	else
		return base_damage 
	end
end

function ability_class:_CalcHeal( hTarget)
	local ability = self
	local base_heal = GetTalentSpecialValueFor(ability, "base_heal")
	local max_health_heal = ability:GetSpecialValueFor("max_health_heal")
	return base_heal + hTarget:GetMaxHealth() * (max_health_heal / 100)
end


-----------------------------------------------------------------------------------------

modifier_mjz_necrolyte_death_pulse = class({})
local modifier_class = modifier_mjz_necrolyte_death_pulse

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:GetEffectName()
	-- return "particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf"
	return "particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe.vpcf"
end
function modifier_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_class:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end
function modifier_class:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

if IsServer() then
	function modifier_class:OnCreated(table)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local stun_duration = ability:GetSpecialValueFor("stun_duration")

		self:_FireEffect_Start()
		self:_FireEffect_Orig()

		-- Timers:CreateTimer(stun_duration, function()
		-- 	self:_ApplyDamage()
		-- 	self:Destroy()
		-- end)
		self:StartIntervalThink(stun_duration)
	end

	function modifier_class:OnIntervalThink()
		self:StartIntervalThink(-1)
		self:_ApplyDamage()
		self:Destroy()
	end

	function modifier_class:_FireEffect_Start( )
		local caster = self:GetCaster()
		local target = self:GetParent()

		local p_name_start = "particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf"
		local p_name_start_sullen_harvest = "particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf"
		local scythe_fx = ParticleManager:CreateParticle(p_name_start_sullen_harvest, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(scythe_fx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(scythe_fx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(scythe_fx)
	end

	function modifier_class:_FireEffect_Orig( )
		local caster = self:GetCaster()
		local p_name = "particles/units/heroes/hero_necrolyte/necrolyte_scythe_orig.vpcf"
		local orig_fx = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		self:AddParticle(orig_fx, false, false, -1, false, false)
	end

	function modifier_class:_ApplyDamage( )
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()

		local base_damage = ability:GetSpecialValueFor("base_damage")
		local int_damage_multiplier = ability:GetSpecialValueFor("int_damage_multiplier")
		local damage = base_damage + caster:GetIntellect() * int_damage_multiplier
	
		ApplyDamage({
			attacker = caster,
			victim = target,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
		})
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_necrolyte_death_pulse_stun = class({})
local modifier_stun = modifier_mjz_necrolyte_death_pulse_stun

function modifier_stun:IsHidden() return true end
function modifier_stun:IsPurgable() return false end
function modifier_stun:IsDebuff() return false end

function modifier_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_stun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_stun:GetOverrideAnimation( )
	return ACT_DOTA_DISABLED
end

function modifier_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
function modifier_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
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

