
---------------------------------------------------------------------------------------------------
-- CDOTA_BaseNPC

function CDOTA_BaseNPC:GetPlayerID()
	return self:GetPlayerOwnerID()
end

function CDOTA_BaseNPC:GetAttackRange()
	return self:Script_GetAttackRange()
end

-- 是否学习了指定天赋技能
function CDOTA_BaseNPC:HasTalent(talentName)
	local unit = self
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end


function CDOTA_BaseNPC:Blink(position)
	if self:IsNull() then return end
	EmitSoundOn("DOTA_Item.BlinkDagger.Activate", self)
	ParticleManager:FireParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, self, {[0] = self:GetAbsOrigin()})
	FindClearSpaceForUnit(self, position, true)
	ProjectileManager:ProjectileDodge( self )
	ParticleManager:FireParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, self, {[0] = self:GetAbsOrigin()})
	EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", self)
end

function CDOTA_BaseNPC:Lifesteal(source, lifestealPct, damage, target, damage_type, iSource, bParticles)
	local damageDealt = damage or 0
	local sourceType = iSource or DOTA_LIFESTEAL_SOURCE_NONE
	local sourceCaster = self
	if source then
		sourceCaster = source:GetCaster()
	end
	local particles = true
	if bParticles == false then
		particles = false
	end
	if sourceType == DOTA_LIFESTEAL_SOURCE_ABILITY and source then
		damageDealt = source:DealDamage( sourceCaster, target, damage, {damage_type = damage_type} )
	elseif sourceType == DOTA_LIFESTEAL_SOURCE_ATTACK then
		local oldHP = target:GetHealth()
		self:PerformAttack(target, true, true, true, true, false, false, false)
		damageDealt = math.abs(oldHP - target:GetHealth())
	end
	
	if particles then
		if sourceType == DOTA_LIFESTEAL_SOURCE_ABILITY then
			ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		else
			local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
				ParticleManager:SetParticleControlEnt(lifesteal, 0, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(lifesteal, 1, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(lifesteal)
		end
	end

	local flHeal = damageDealt * lifestealPct / 100
	-- self:HealEvent( flHeal, source, sourceCaster )
	self:HealEventOnly( flHeal, source, sourceCaster )
	return flHeal
end

function CDOTA_BaseNPC:HealEvent(amount, sourceAb, healer, bRegen) -- for future shit
	local healBonus = 1
	local flAmount = amount
	if healer and not healer:IsNull() then
		for _,modifier in ipairs( healer:FindAllModifiers() ) do
			if modifier.GetOnHealBonus then
				healBonus = healBonus + ((modifier:GetOnHealBonus() or 0)/100)
			end
		end
	end
	
	flAmount = flAmount * healBonus
	local params = {amount = flAmount, source = sourceAb, unit = healer, target = self}
	local units = self:FindAllUnitsInRadius(self:GetAbsOrigin(), -1)
	
	for _, unit in ipairs(units) do
		if unit.FindAllModifiers then
			for _, modifier in ipairs( unit:FindAllModifiers() ) do
				if modifier.OnHealed then
					modifier:OnHealed(params)
				end
				if modifier.OnHeal then
					modifier:OnHeal(params)
				end
				if modifier.OnHealRedirect then
					local reduction = modifier:OnHealRedirect(params) or 0
					flAmount = flAmount + reduction
				end
			end
		end
	end
	flAmount = math.min( flAmount, self:GetHealthDeficit() )
	if flAmount > 0 then
		if not bRegen then
			SendOverheadEventMessage(self, OVERHEAD_ALERT_HEAL, self, flAmount, healer)
		end
		self:Heal(flAmount, sourceAb)
	end
	return flAmount
end

function CDOTA_BaseNPC:HealEventOnly(amount, sourceAb, healer, bRegen)
	local healBonus = 1
	local flAmount = amount
	
	flAmount = math.min( flAmount, self:GetHealthDeficit() )
	if flAmount > 0 then
		if not bRegen then
			SendOverheadEventMessage(self, OVERHEAD_ALERT_HEAL, self, flAmount, healer)
		end
		self:Heal(flAmount, sourceAb)
	end
	return flAmount
end

function CDOTA_BaseNPC:FindRandomEnemyInRadius(position, radius, data)
	local enemies = self:FindEnemyUnitsInRadius(position, radius, data)
	return enemies[RandomInt(1, #enemies)]
end

function CDOTA_BaseNPC:FindEnemyUnitsInCone(vDirection, vPosition, flSideRadius, flLength, hData)
	if not self:IsNull() then
		local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_ALL
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = data.order or FIND_ANY_ORDER
		local enemies = self:FindEnemyUnitsInRadius(vPosition, flSideRadius + flLength, hData)
		local unitTable = {}
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil then
					local vToPotentialTarget = enemy:GetOrigin() - vPosition
					local flSideAmount = math.abs( vToPotentialTarget.x * vDirectionCone.x + vToPotentialTarget.y * vDirectionCone.y + vToPotentialTarget.z * vDirectionCone.z )
					local flLengthAmount = ( vToPotentialTarget.x * vDirection.x + vToPotentialTarget.y * vDirection.y + vToPotentialTarget.z * vDirection.z )
					if ( flSideAmount < flSideRadius ) and ( flLengthAmount > 0.0 ) and ( flLengthAmount < flLength ) then
						table.insert(unitTable, enemy)
					end
				end
			end
		end
		return unitTable
	else return {} end
end

function CDOTA_BaseNPC:FindEnemyUnitsInRadius(position, radius, hData)
	if not self:IsNull() then
		local team = self:GetTeamNumber()
		local data = hData or {}
		if data.ability then
			data.team = data.ability:GetAbilityTargetTeam()
			data.type = data.ability:GetAbilityTargetType()
			data.flag = data.ability:GetAbilityTargetFlags()
			data.order = data.ability:GetAbilityDamageType()
		end
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_ALL
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = data.order or FIND_ANY_ORDER
		return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
	else return {} end
end

function CDOTA_BaseNPC:FindEnemyUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindFriendlyUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindAllUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindEnemyUnitsInRing(position, maxRadius, minRadius, hData)
	if not self:IsNull() then
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_ALL
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = data.order or FIND_ANY_ORDER
	
		local innerRing = FindUnitsInRadius(team, position, nil, minRadius, iTeam, iType, iFlag, iOrder, false)
		local outerRing = FindUnitsInRadius(team, position, nil, maxRadius, iTeam, iType, iFlag, iOrder, false)
		local resultTable = {}
		for _, unit in ipairs(outerRing) do
			if not unit:IsNull() then
				local addToTable = true
				for _, exclude in ipairs(innerRing) do
					if unit == exclude then
						addToTable = false
						break
					end
				end
				if addToTable then
					table.insert(resultTable, unit)
				end
			end
		end
		return resultTable
		
	else return {} end
end

function CDOTA_BaseNPC:FindFriendlyUnitsInRadius(position, radius, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end

function CDOTA_BaseNPC:FindAllUnitsInRadius(position, radius, hData)
	if self:IsNull() then return end
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end


------------------- Chill & Freeze       目标冻结
function CDOTA_BaseNPC:AddChill(hAbility, hCaster, chillDuration, chillAmount)
	if not self or self:IsNull() then return end
	local chillBonus = chillAmount or 1
	local bonusDur = chillBonus * 0.1
	local currentChillDuration = 0
	local currentChill =  self:FindModifierByName("modifier_chill_generic")
	if currentChill then
		currentChillDuration = currentChill:GetRemainingTime()
	end
	local appliedDuration = chillDuration
	if currentChillDuration > appliedDuration then
		appliedDuration = currentChillDuration + bonusDur
	else
		appliedDuration = appliedDuration + currentChillDuration
	end
	local modifier = self:AddNewModifier(hCaster, hAbility, "modifier_chill_generic", {Duration = appliedDuration})
	if modifier then
		modifier:SetStackCount( modifier:GetStackCount() + chillBonus)
	end
end

function CDOTA_BaseNPC:GetChillCount()
	if self:HasModifier("modifier_chill_generic") then
		return self:FindModifierByName("modifier_chill_generic"):GetStackCount()
	else
		return 0
	end
end

function CDOTA_BaseNPC:SetChillCount( count, chillDuration )
	if self:HasModifier("modifier_chill_generic") then
		self:FindModifierByName("modifier_chill_generic"):SetStackCount(count)
	elseif chillDuration then
		local modifier = self:AddNewModifier(hCaster, hAbility, "modifier_chill_generic", {Duration = chillDuration})
		if modifier then modifier:SetStackCount(count) end
	else
		error("Target can't be given chill!")
	end
end

function CDOTA_BaseNPC:IsChilled()
	if self:HasModifier("modifier_chill_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveChill()
	if self:HasModifier("modifier_chill_generic") then
		self:RemoveModifierByName("modifier_chill_generic")
	end
end

function CDOTA_BaseNPC:Freeze(hAbility, hCaster, duration)
	self:RemoveModifierByName("modifier_chill_generic")
	self:AddNewModifier(hCaster, hAbility, "modifier_frozen_generic", {Duration = duration})
end

function CDOTA_BaseNPC:IsFrozenGeneric()
	if self:HasModifier("modifier_frozen_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveFreeze()
	if self:HasModifier("modifier_frozen_generic") then
		self:RemoveModifierByName("modifier_frozen_generic")
	end
end


function CDOTA_BaseNPC_Hero:CreateSummon(unitName, position, duration, bControllable)
	local summon = CreateUnitByName(unitName, position, true, self, nil, self:GetTeam())
	if bControllable or bControllable == nil then summon:SetControllableByPlayer( self:GetPlayerID(),  true ) end
	self.summonTable = self.summonTable or {}
	table.insert(self.summonTable, summon)
	summon:SetOwner(self)
	-- local summonMod = summon:AddNewModifier(self, nil, "modifier_summon_handler", {duration = duration})
	if duration and duration > 0 then
		local kill = summon:AddNewModifier(self, nil, "modifier_kill", {duration = duration})
	end
	StartAnimation(summon, {activity = ACT_DOTA_SPAWN, rate = 1.5, duration = 2})
	-- local endDur = summonMod:GetRemainingTime()
	-- return summon, endDur
	return summon
end

function CDOTA_BaseNPC_Hero:RemoveSummon(entity)
	for id,ent in pairs(self.summonTable) do
		if ent == entity then
			table.remove(self.summonTable, id)
		end
	end
end

function CDOTA_BaseNPC_Hero:GetSummons()
	return self.summonTable or {}
end

