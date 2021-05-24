
mjz_chaos_knight_chaos_bolt = class({})
local ability_class = mjz_chaos_knight_chaos_bolt

function ability_class:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function ability_class:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("cast_range")
end

if IsServer() then
    function ability_class:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local target_count = GetTalentSpecialValueFor(self, "targets")

        local count = 1
        self:_CreateProjectile(target)

        if target_count > 1 then
            local enemies = self:_FindEnemies()

            for _,enemy in pairs(enemies) do
                if count >= target_count then
                    break
                end
                if enemy ~= target then
                    count = count + 1
                    self:_CreateProjectile(enemy)
                end
            end
        end

        EmitSoundOn("Hero_ChaosKnight.ChaosBolt.Cast", caster)
    end

    function ability_class:OnProjectileHit_ExtraData(target, pos, keys)
        local caster = self:GetCaster()
        
        if not target then return nil end
        if target:TriggerSpellAbsorb(self) then return nil end

        -- Ability variables
        local stun_min = self:GetSpecialValueFor("stun_min")
        local stun_max = self:GetSpecialValueFor("stun_max") 
        local damage_min = self:GetSpecialValueFor("damage_min") 
        local damage_max = self:GetSpecialValueFor("damage_max")
        local chaos_bolt_particle = "particles/units/heroes/hero_chaos_knight/chaos_knight_bolt_msg.vpcf"
        local target_location = target:GetAbsOrigin()

        -- Calculate the stun and damage values
        local random = RandomFloat(0, 1)
        local stun = stun_min + (stun_max - stun_min) * random
        local damage = damage_min + (damage_max - damage_min) * (1 - random)
		
		if caster:HasScepter() then
			stun = stun_max
			damage = damage_max
		end
		if HasSuperScepter(caster) then
			local str_multiplier = self:GetSpecialValueFor("str_multiplier_scepter")
			damage = damage + caster:GetStrength() * str_multiplier
		end

        -- Calculate the number of digits needed for the particle
        local stun_digits = string.len(tostring(math.floor(stun))) + 1
        local damage_digits = string.len(tostring(math.floor(damage))) + 1

        -- Create the stun and damage particle for the spell
        local particle = ParticleManager:CreateParticle(chaos_bolt_particle, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(particle, 0, target_location) 

        -- Damage particle
        ParticleManager:SetParticleControl(particle, 1, Vector(9,damage,4)) -- prefix symbol, number, postfix symbol
        ParticleManager:SetParticleControl(particle, 2, Vector(2,damage_digits,0)) -- duration, digits, 0

        -- Stun particle
        ParticleManager:SetParticleControl(particle, 3, Vector(8,stun,0)) -- prefix symbol, number, postfix symbol
        ParticleManager:SetParticleControl(particle, 4, Vector(2,stun_digits,0)) -- duration, digits, 0
        ParticleManager:ReleaseParticleIndex(particle)

        -- Apply the stun duration
        target:AddNewModifier(caster, self, "modifier_stunned", {duration = stun})

        -- Initialize the damage table and deal the damage
        local damage_table = {
            attacker = caster,
            victim = target,
            ability = self,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
        }
        ApplyDamage(damage_table)

        EmitSoundOn("Hero_ChaosKnight.ChaosBolt.Impact", target)
    end

    function ability_class:_FindEnemies( )
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local radius = GetTalentSpecialValueFor(self, "radius")
        
        return FindUnitsInRadius(
            caster:GetTeamNumber(),
            target:GetAbsOrigin(),
            nil,
            radius,
            self:GetAbilityTargetTeam(),
            self:GetAbilityTargetType(),
            self:GetAbilityTargetFlags(),
            FIND_ANY_ORDER,
            false
        )
    end

    function ability_class:_CreateProjectile(target)
        local caster = self:GetCaster()
        local projectile_speed = self:GetSpecialValueFor("chaos_bolt_speed")
        local projectile_name = "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf"
        local info = 
		{
			Target = target,
			Source = caster,
			Ability = self,	
			EffectName = projectile_name,
			iMoveSpeed = projectile_speed,
			vSourceLoc = caster:GetAbsOrigin(),
			bDrawsOnMinimap = false,
			bDodgeable = true,
			bIsAttack = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			flExpireTime = GameRules:GetGameTime() + 60,
			bProvidesVision = false,
			ExtraData = {target = target:entindex()}
		}
		ProjectileManager:CreateTrackingProjectile(info)
    end
end

----------------------------------------------------------------------------------

-- 是否学习指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end

-- 获得技能数据中连接的天赋技能的名字
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