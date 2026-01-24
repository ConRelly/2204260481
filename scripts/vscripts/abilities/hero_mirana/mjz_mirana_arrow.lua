
LinkLuaModifier("modifier_mjz_mirana_arrow", "abilities/hero_mirana/mjz_mirana_arrow.lua", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_mirana_arrow = class({})
local ability_class = mjz_mirana_arrow

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_mirana_arrow"
end
--if caster has aghanim scepter, arrow becomes toggle ability for pure damage effect
function ability_class:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end
function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('arrow_range')
end
--ability dmg type pure if is toggled
function ability_class:GetAbilityDamageType()
	if self:GetToggleState() then
		return DAMAGE_TYPE_PURE
	end
	return DAMAGE_TYPE_MAGICAL
end

function ability_class:OnToggle()

end

if IsServer() then
    function ability_class:OnProjectileHit(target, location)
		if not IsServer() then return end
        if target and target:IsAlive() then
            local caster = self:GetCaster()
            local damage_pct = self:GetSpecialValueFor("damage_pct")
            local damage = caster:GetAverageTrueAttackDamage(target) * (damage_pct / 100.0)

            local damage_type = DAMAGE_TYPE_MAGICAL
            if self:GetToggleState() then
                damage_type = DAMAGE_TYPE_PURE
                damage = damage / 8
            end

			if _G._challenge_bosss > 0 then
				local target_current_hp = math.floor(target:GetHealth() * ( 0.03 * _G._challenge_bosss))
                --if dmg type is pure 8 times less dmg
                if damage_type == DAMAGE_TYPE_PURE then
                    target_current_hp = target_current_hp / 8
                end
				ApplyDamage({
					ability = self,
					attacker = caster,
					victim = target,				
					damage = target_current_hp,
					damage_type = damage_type,
				})
			end			 
            if caster:HasModifier("modifier_mirana_leap_buff") and caster:HasModifier("modifier_super_scepter") and RollPercentage(25) then
                local caster_lvl = caster:GetLevel()
                local crit_multiplier = 1.0
                if caster_lvl <= 100 then
                    crit_multiplier = 1.0 + (0.05 * caster_lvl)
                else
                    crit_multiplier = 1.0 + (0.05 * 100) + (0.25 * (caster_lvl - 100))
                end
                damage = damage * crit_multiplier
                
                -- Particle effect for crit
                local crit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                ParticleManager:SetParticleControlEnt(crit_pfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(crit_pfx)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage, nil)
            end

            ApplyDamage({
                ability = self,
				attacker = caster,
                victim = target,				
                damage = damage,
                damage_type = damage_type,
            })


            --target:EmitSound("Hero_Mirana.ArrowImpact")
            target:EmitSoundParams("Hero_Mirana.ArrowImpact", 1, 0.2, 0)
        end

        return true
    end
end



---------------------------------------------------------------------------------------

modifier_mjz_mirana_arrow = class({})
local modifier_class = modifier_mjz_mirana_arrow

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK,
		}
		return funcs
	end

    function modifier_class:OnCreated()
        if not IsServer() then return end
        self:StartIntervalThink(0.4)
    end

    function modifier_class:OnIntervalThink()
        if not IsServer() then return end
        local caster = self:GetParent()
        local ability = self:GetAbility()
        local arrow_speed = ability:GetSpecialValueFor('arrow_speed')
        if not caster:HasModifier("modifier_super_scepter") then return end
        -- Leap Root Auto Fire (0.4s interval)
        local enemies_all = FindUnitsInRadius(
            caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            ability:GetSpecialValueFor('arrow_range'),
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
            FIND_ANY_ORDER,
            false
        )

        for _, enemy in pairs(enemies_all) do
            if (enemy:HasModifier("modifier_mirana_leap_root") or enemy:HasModifier("modifier_mirana_starfall_starstruck")) and enemy:IsAlive() then
                local direction = (enemy:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
                direction.z = 0
                local vVelocity = direction * arrow_speed
                self:_CreateProjectileAtLocation(caster:GetAbsOrigin(), vVelocity)
                caster:EmitSoundParams("Hero_Mirana.ArrowCast", 1, 0.2, 0)
            end
        end

        -- Check if CASTER has Super Scepter (Maintain 1.0s interval)
        if not self.scepter_timer then self.scepter_timer = 0 end
        self.scepter_timer = self.scepter_timer + 0.4
        if self.scepter_timer >= 1.0 then
            self.scepter_timer = 0
            if caster:HasModifier("modifier_super_scepter") then
                local arrow_speed = ability:GetSpecialValueFor('arrow_speed')
                -- Find all allies on the map
                local allies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    9000,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    FIND_ANY_ORDER,
                    false
                )

                for _, ally in pairs(allies) do
                    -- Check if ALLY has Moonlight Shadow modifier
                    if ally:HasModifier("modifier_mirana_moonlight_shadow") and ally:IsAlive() and ally:HasModifier("modifier_super_scepter") then
                        local enemies = FindUnitsInRadius(
                            caster:GetTeamNumber(),
                            ally:GetAbsOrigin(),
                            nil,
                            9000,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                            FIND_CLOSEST,
                            false
                        )

                        if #enemies > 0 then
                            local target = enemies[1]
                            local direction = (target:GetAbsOrigin() - ally:GetAbsOrigin()):Normalized()
                            direction.z = 0
                            local vVelocity = direction * arrow_speed
                            
                            -- Firing from ally position, but Mirana (caster) remains the Source for stats
                            self:_CreateProjectileAtLocation(ally:GetAbsOrigin(), vVelocity)
                            --ally:EmitSound("Hero_Mirana.ArrowCast")
                            ally:EmitSoundParams("Hero_Mirana.ArrowCast", 1, 0.2, 0)
                        end
                    end
                end
            end
        end
    end

	function modifier_class:OnAttack(keys)
		if keys.attacker ~= self:GetParent() then return end
		
        local attacker = keys.attacker
        local target = keys.target
		local ability = self:GetAbility()
		local arrow_speed = ability:GetSpecialValueFor('arrow_speed')
		local proc_chance = GetTalentSpecialValueFor(ability, 'proc_chance')
		local talent_volley_name = 'special_bonus_unique_mirana_2'

		-- Toggle is now for Damage Type, so it doesn't disable the ability
		if not RollPercentage(proc_chance) then return end

		local direction = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()
		local vVelocity = direction * arrow_speed
		self:_CreateProjectile(attacker, vVelocity)

		if HasTalent(attacker, talent_volley_name) then
			-- 1点钟方向
			local direction_1 = RotatePosition(Vector(0,0,0), QAngle(0,7,0), attacker:GetForwardVector())
			-- 11点钟方向
			local direction_11 = RotatePosition(Vector(0,0,0), QAngle(0,360 - 7,0), attacker:GetForwardVector())

			local vVelocity_1 = direction_1 * arrow_speed
			self:_CreateProjectile(attacker, vVelocity_1)
			local vVelocity_11 = direction_11 * arrow_speed
			self:_CreateProjectile(attacker, vVelocity_11)
		end

        --attacker:EmitSound("Hero_Mirana.ArrowCast")
        attacker:EmitSoundParams("Hero_Mirana.ArrowCast", 1, 0.2, 0)
	end
	
	function modifier_class:_CreateProjectile(attacker, vVelocity)
        self:_CreateProjectileAtLocation(attacker:GetAbsOrigin(), vVelocity)
	end

    function modifier_class:_CreateProjectileAtLocation(vLocation, vVelocity)
		local ability = self:GetAbility()
        local caster = self:GetParent()
		local arrow_width = ability:GetSpecialValueFor('arrow_width')
		local arrow_range = ability:GetSpecialValueFor('arrow_range')
		local arrow_vision = ability:GetSpecialValueFor('arrow_vision')

		local effect_name = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf"
		local fDistance = arrow_range

        ProjectileManager:CreateLinearProjectile({
            EffectName = effect_name,
            Ability = ability,
            vSpawnOrigin = vLocation, 
            fStartRadius = arrow_width,
            fEndRadius = arrow_width,
            vVelocity = vVelocity,
            fDistance = fDistance,
            Source = caster,
            iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetType = ability:GetAbilityTargetType(),
			iUnitTargetFlags = ability:GetAbilityTargetFlags(),
			bDeleteOnHit = true,
			bProvidesVision = true,
			iVisionRadius = arrow_vision,
			iVisionTeamNumber = caster:GetTeamNumber(),
        })
    end

	function CalcOrigin_Clock_1(sourceUnit, targetUnit)
		local source_origin = sourceUnit:GetAbsOrigin()
		local target_origin = targetUnit:GetAbsOrigin()
		local radius = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()
		return vVelocity
	end

	function CalcOrigin_Clock_11(sourceUnit, targetUnit)
		local source_origin = sourceUnit:GetAbsOrigin()
		local target_origin = targetUnit:GetAbsOrigin()
		
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
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end