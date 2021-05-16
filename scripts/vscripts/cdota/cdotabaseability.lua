
---------------------------------------------------------------------------------------------------
-- CDOTABaseAbility

function CDOTABaseAbility:DealDamage(attacker, target, damage, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	if self:IsNull() or target:IsNull() or attacker:IsNull() then return end
	local internalData = data or {}
	local damageType =  internalData.damage_type or self:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL
	local damageFlags = internalData.damage_flags or DOTA_DAMAGE_FLAG_NONE
	local localdamage = damage or self:GetAbilityDamage() or 0
	local spellText = spellText or 0
	local ability = self or internalData.ability
	local oldHealth = target:GetHealth()
	ApplyDamage({victim = target, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	if target:IsNull() then return oldHealth end
	local newHealth = target:GetHealth()
	local returnDamage = oldHealth - newHealth
	if spellText > 0 then
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,target,returnDamage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
	end
	return returnDamage
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local ability = self
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

function CDOTABaseAbility:FireLinearProjectile(FX, velocity, distance, width, data, bDelete, bVision, vision)
	local internalData = data or {}
	local delete = false
	if bDelete then delete = bDelete end
	local provideVision = true
	if bVision then provideVision = bVision end
	local info = {
		EffectName = FX,
		Ability = self,
		vSpawnOrigin = internalData.origin or self:GetCaster():GetAbsOrigin(), 
		fStartRadius = width,
		fEndRadius = internalData.width_end or width,
		vVelocity = velocity,
		fDistance = distance or 1000,
		Source = internalData.source or self:GetCaster(),
		iUnitTargetTeam = internalData.team or DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = internalData.type or DOTA_UNIT_TARGET_ALL,
		iUnitTargetFlags = internalData.type or DOTA_UNIT_TARGET_FLAG_NONE,
		iSourceAttachment = internalData.attach or DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		bDeleteOnHit = delete,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		ExtraData = internalData.extraData
	}
	local projectile = ProjectileManager:CreateLinearProjectile( info )
	return projectile
end

function CDOTABaseAbility:FireTrackingProjectile(FX, target, speed, data, iAttach, bDodge, bVision, vision)
	local internalData = data or {}
	local dodgable = true
	if bVision ~= nil then dodgable = bDodge end
	local provideVision = false
	if bVision ~= nil then provideVision = bVision end
	origin = self:GetCaster():GetAbsOrigin()
	if internalData.origin then
		origin = internalData.origin
	elseif internalData.source then
		origin = internalData.source:GetAbsOrigin()
	end
	local projectile = {
		Target = target,
		Source = internalData.source or self:GetCaster(),
		Ability = self,	
		EffectName = FX,
	    iMoveSpeed = speed,
		vSourceLoc= origin or self:GetCaster():GetAbsOrigin(),
		bDrawsOnMinimap = false,
        bDodgeable = dodgable,
        bIsAttack = false,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        flExpireTime = internalData.duration,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iSourceAttachment = iAttach or 3,
		ExtraData = internalData.extraData
	}
	return ProjectileManager:CreateTrackingProjectile(projectile)
end


