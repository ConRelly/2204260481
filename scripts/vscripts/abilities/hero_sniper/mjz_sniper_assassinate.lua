
local MODIFIER_CASTER_NAME = 'modifier_mjz_sniper_assassinate_caster'	-- modifier_sniper_assassinate_caster
local MODIFIER_TARGET_NAME = 'modifier_mjz_sniper_assassinate'			-- modifier_sniper_assassinate
local MODIFIER_VISION_NAME = 'modifier_mjz_sniper_assassinate_vision'	
LinkLuaModifier( MODIFIER_CASTER_NAME, "modifiers/hero_sniper/modifier_mjz_sniper_assassinate.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( MODIFIER_TARGET_NAME, "modifiers/hero_sniper/modifier_mjz_sniper_assassinate.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( MODIFIER_VISION_NAME, "modifiers/hero_sniper/modifier_mjz_sniper_assassinate.lua",LUA_MODIFIER_MOTION_NONE )


mjz_sniper_assassinate = class({})
local ability_class = mjz_sniper_assassinate

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor( "scepter_radius" )
end

function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor( "cast_range" )
end

function ability_class:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return self.BaseClass.GetBehavior( self )
end

function ability_class:GetAbilityDamageType()
	if self:GetCaster():HasScepter() then
		return DAMAGE_TYPE_PHYSICAL
	end
	return DAMAGE_TYPE_MAGICAL
end
function ability_class:GetDamageType()
	if self:GetCaster():HasScepter() then
		return DAMAGE_TYPE_PHYSICAL
	end
	return DAMAGE_TYPE_MAGICAL
end

function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		local aim_duration = ability:GetSpecialValueFor( "aim_duration" )
		local scepter_radius = ability:GetSpecialValueFor( "scepter_radius" )
		local enemies = {}

		if caster:HasScepter() then
			enemies = FindUnitsInRadius( 
				caster:GetTeamNumber(), self:GetCursorPosition(), 
				caster, scepter_radius, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false 
			)
		else
			local hTarget = self:GetCursorTarget()
			table.insert( enemies, hTarget )
		end

		self.hTargets = enemies

		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil then
					enemy:AddNewModifier( caster, ability, MODIFIER_TARGET_NAME, { duration = aim_duration } )
					enemy:AddNewModifier( caster, ability, MODIFIER_VISION_NAME, { duration = aim_duration + 4 } )
				end
			end
		end
		EmitSoundOn( "Ability.AssassinateLoad", caster)
	end

	return true
end

function ability_class:OnAbilityPhaseInterrupted()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		local hTarget = self:GetCursorTarget()
		--[[
			if hTarget ~= nil then
				hTarget:RemoveModifierByName( MODIFIER_TARGET_NAME )
			elseif caster:HasScepter() then
				for i=1,#self.hTargets do
					local enemy = self.hTargets[i]
					if enemy ~= nil then
						enemy:RemoveModifierByName( MODIFIER_TARGET_NAME )
						table.remove( self.hTargets, i )
					end
				end
				
			end
		]]
	end
end

function ability_class:OnSpellStart()	
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		local enemies = self.hTargets or {}
		--[[
			if caster:HasScepter() then
				local scepter_radius = ability:GetSpecialValueFor( "scepter_radius" )
				local enemies = FindUnitsInRadius( 
					caster:GetTeamNumber(), self:GetCursorPosition(), 
					caster, FIND_UNITS_EVERYWHERE, 
					DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false 
				)
			
				local enemies = self.hScepterTargets
			else
				local hTarget = self:GetCursorTarget()
				table.insert( enemies, hTarget )
			end
		]]

		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil then	-- enemy:FindModifierByName( MODIFIER_TARGET_NAME ) ~= nil
					self:_FireProjectile(enemy, false)
				end
			end
		end
	end
end

function ability_class:OnProjectileHit_ExtraData(hTarget, vLocation, keys)
	if not IsServer() then return nil end
	local ability = self
	local caster = self:GetCaster()
	local bInBuckshot = keys.bInBuckshot
	local can = true
	
	if hTarget == nil then return nil end
	if hTarget:TriggerSpellAbsorb(ability) then can = false end
	if hTarget:IsInvulnerable() then can = false end

	if can then
		self:_OnHitTarget(hTarget, bInBuckshot)
	end

	hTarget:RemoveModifierByName( MODIFIER_TARGET_NAME )
	hTarget:RemoveModifierByName( MODIFIER_VISION_NAME )
end

if IsServer() then

	function ability_class:_OnHitTarget(hTarget, bInBuckshot )
		local ability = self
		local caster = self:GetCaster()
		local assassinate_damage = ability:GetSpecialValueFor( "assassinate_damage" )
		local stun_duration = ability:GetSpecialValueFor( "stun_duration" )
		local scepter_crit_bonus = ability:GetSpecialValueFor( "scepter_crit_bonus" )
		local bonus_damage_pct = GetTalentSpecialValueFor(ability, 'bonus_damage_pct')
		
		if bInBuckshot > 0  then
			local buchshot_damage = assassinate_damage * 0.5
			if caster:HasScepter() then
				buchshot_damage	= caster:GetAverageTrueAttackDamage(hTarget) * (scepter_crit_bonus / 100.0)
				buchshot_damage = buchshot_damage * 0.5
			end
			buchshot_damage = buchshot_damage + buchshot_damage * (bonus_damage_pct / 100.0)
			local damage_table = 
			{
				victim = hTarget,
				attacker = caster,
				ability = ability,
				damage = buchshot_damage,
				damage_type = ability:GetAbilityDamageType(),
			}
			ApplyDamage( damage_table )
			EmitSoundOn( "Hero_Sniper.AssassinateDamage_Scatter", hTarget )
		else
			if caster:HasScepter() then
				caster:AddNewModifier( caster, ability, MODIFIER_CASTER_NAME, {} )
				caster:PerformAttack( hTarget, true, true, true, true, false, false, true )
				caster:RemoveModifierByName(MODIFIER_CASTER_NAME)
			else
				assassinate_damage = assassinate_damage + assassinate_damage * (bonus_damage_pct / 100.0)
				local damage_table = 
				{
					victim = hTarget,
					attacker = caster,
					ability = ability,
					damage = assassinate_damage,
					damage_type = ability:GetAbilityDamageType(),
				}
				ApplyDamage( damage_table )
				EmitSoundOn( "Hero_Sniper.AssassinateDamage", hTarget )
			end
	
			-- stun the main target
			hTarget:AddNewModifier( caster, ability, "modifier_stunned", { duration = stun_duration } )
	
			self:_Buckshot(hTarget)
		end

	end

	function ability_class:_FireProjectile( hTarget, bInBuckshot, vSource)
		local ability = self
		local caster = self:GetCaster()
		local projectile_speed = ability:GetSpecialValueFor('projectile_speed')
		local projectile_name = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf"
		local source = caster
		local buchshot = 0
		if bInBuckshot then
			projectile_speed = projectile_speed / 2
			buchshot = 1
			source = vSource
		end
		local info = 
		{
			Target = hTarget,
			Source = source,
			Ability = ability,	
			EffectName = projectile_name,
			iMoveSpeed = projectile_speed,
			vSourceLoc = source:GetAbsOrigin(),
			bDrawsOnMinimap = false,
			bDodgeable = true,
			bIsAttack = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			flExpireTime = GameRules:GetGameTime() + 60,
			bProvidesVision = false,
			ExtraData = {hTarget = hTarget:entindex(), bInBuckshot = buchshot}
		}
		ProjectileManager:CreateTrackingProjectile( info )

		if bInBuckshot then
			EmitSoundOn( "Hero_Sniper.AssassinateProjectile_Scatter", hTarget )
		else
			EmitSoundOn( "Ability.Assassinate", caster )
			EmitSoundOn( "Hero_Sniper.AssassinateProjectile", caster )
		end
	end

	function ability_class:_Buckshot(hTarget)
		local ability = self
		local caster = self:GetCaster()

		local vToTarget = hTarget:GetOrigin() - caster:GetOrigin() 
		vToTarget = vToTarget:Normalized()

		local vSideTarget = Vector( vToTarget.y, -vToTarget.x, 0.0 )
		local scatter_range = ability:GetSpecialValueFor( "scatter_range" )
		local scatter_width = ability:GetSpecialValueFor( "scatter_width" )

		local enemies = FindUnitsInRadius( 
			caster:GetTeamNumber(), hTarget:GetOrigin(), 
			caster, scatter_range + scatter_width, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
		)
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and not enemy:IsInvulnerable() then
					local vToPotentialTarget = enemy:GetOrigin() - hTarget:GetOrigin()
					local flSideAmount = math.abs( vToPotentialTarget.x * vSideTarget.x + vToPotentialTarget.y * vSideTarget.y + vToPotentialTarget.z * vSideTarget.z )
					local flLengthAmount = ( vToPotentialTarget.x * vToTarget.x + vToPotentialTarget.y * vToTarget.y + vToPotentialTarget.z * vToTarget.z )
					local canShot = ( flSideAmount < scatter_width ) and ( flLengthAmount > 0.0 ) and ( flLengthAmount < scatter_range )
					if canShot then
						self:_FireProjectile(enemy, true, hTarget)
					end
				end
			end
		end
	end

end

------------------------------------------------------------------------------

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
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or 'value'
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end

