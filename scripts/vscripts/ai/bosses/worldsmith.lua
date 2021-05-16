
require( "ai/ai_core" )
require( "ai/ai_shared" )
require("lib/my")

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.custom_ground_smash = thisEntity:FindAbilityByName( "custom_ground_smash" )
	thisEntity.custom_shifting_quake = thisEntity:FindAbilityByName( "custom_shifting_quake" )
	thisEntity.custom_earth_splitter = thisEntity:FindAbilityByName( "custom_earth_splitter" )
	thisEntity.custom_stone_spire = thisEntity:FindAbilityByName( "custom_stone_spire" )
	thisEntity.hBSAbility = thisEntity:FindAbilityByName( "boss_worldsmith_burrowstrike" )
	
	-- thisEntity.hBootsItem = find_item(thisEntity, "item_phase_boots")

	thisEntity:SetContextThink( "BossThink", BossThink, 0.5 )
end

--------------------------------------------------------------------------------

function BossThink()
	if not IsServer() then
		return
	end

	if thisEntity == nil or thisEntity:IsNull() or ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.1
	end

	if thisEntity:IsChanneling() then
		return 0.1
	end
	
	-- local aTarget = thisEntity:GetAggroTarget()
	-- if aTarget and aTarget:IsMagicImmune() then
	-- 	local now = GameRules:GetGameTime()
	-- 	self._prev_check_magic_time = self._prev_check_magic_time or now

	-- 	if (now - self._prev_check_magic_time) > 4 then
	-- 		self._prev_check_magic_time = now
	-- 		local nSearchRange = 2000
	-- 		local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	-- 		local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
			
	-- 		thisEntity:SetAggroTarget(hRandomEnemyPlayer)
	-- 	end
	-- end

	
	-- if thisEntity.hBootsItem and thisEntity.hBootsItem:IsFullyCastable() then
	-- 	thisEntity.hBootsItem:CastAbility()
	-- 	return 0.5
	-- end

	if thisEntity.custom_earth_splitter and thisEntity.custom_earth_splitter:IsFullyCastable() then
		local nSearchRange = thisEntity.custom_earth_splitter:GetCastRange()
		local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		if #hEnemies > 0 then
			local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
			return CastTargetPos(thisEntity.custom_earth_splitter, hRandomEnemyPlayer )
		end
	end
	

	if thisEntity.hBSAbility and thisEntity.hBSAbility:IsFullyCastable() then
		local aTarget = thisEntity:GetAggroTarget()
		-- if aTarget and aTarget:IsMagicImmune() then
		if true then
			local nSearchRange = thisEntity.hBSAbility:GetCastRange() * 2
			local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
			if #hEnemies > 0 then
				local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
				return CastTarget(thisEntity.hBSAbility, hRandomEnemyPlayer )
			end
		end
	end

	if thisEntity.custom_ground_smash and thisEntity.custom_ground_smash:IsFullyCastable() then
		local nSearchRange = thisEntity.custom_ground_smash:GetCastRange()
		local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if #hEnemies > 0 then
			local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
			return CastTargetPos(thisEntity.custom_ground_smash, hRandomEnemyPlayer )
		end
	end
	
	if thisEntity.custom_shifting_quake and thisEntity.custom_shifting_quake:IsFullyCastable() then
		local nSearchRange = thisEntity.custom_shifting_quake:GetCastRange()
		local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		if #hEnemies > 0 then
			local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
			return CastTargetPos(thisEntity.custom_shifting_quake, hRandomEnemyPlayer )
		end
	end

	if thisEntity.custom_stone_spire and thisEntity.custom_stone_spire:IsFullyCastable() then
		-- local nSearchRange = thisEntity.custom_stone_spire:GetCastRange()
		-- local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		-- if #hEnemies > 0 then
		-- 	local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
		-- end
		return CastAbility(thisEntity.custom_stone_spire )
	end
	
	

	AttackMoveFort()

	return 0.5
end


function AttackMoveFort()
    local ancient = Entities:FindByName(nil, "dota_goodguys_fort")
	
    if ancient:IsAlive() and thisEntity:IsAlive() then
		if not thisEntity:IsInvisible() and not thisEntity:IsChanneling() and thisEntity:GetCurrentActiveAbility() == nil and not thisEntity:IsCommandRestricted() then
			if (CalcDistanceBetweenEntityOBB(thisEntity, ancient) > 800) then
				if not thisEntity:IsDisarmed() then
					local attackOrder = {
						UnitIndex = thisEntity:entindex(), 
						OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
						Position = ancient:GetAbsOrigin()
					}
					ExecuteOrderFromTable(attackOrder)
				else 
					local attackOrder = {
						UnitIndex = thisEntity:entindex(), 
						OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
						Position = thisEntity:GetAbsOrigin()
					}
					ExecuteOrderFromTable(attackOrder)
				end
			end
		end
	end
	
end

--------------------------------------------------------------------------------

function AttackTarget(hAbility, hTarget )
	if hTarget == nil or hTarget:IsNull() or hTarget:IsAlive() == false then
		return 0.1
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		-- Position = hitPosition,
		AbilityIndex = hAbility:entindex(),
		TargetIndex  = hTarget:entindex(),
		Queue = false,
	})

	return 2.0
end


function CastAbility(hAbility )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = hAbility:entindex(),
		Queue = false,
	})
	return 2.0
end

function CastTarget(hAbility, hTarget )
	if hTarget == nil or hTarget:IsNull() or hTarget:IsAlive() == false then
		return 0.1
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		-- Position = hitPosition,
		AbilityIndex = hAbility:entindex(),
		TargetIndex  = hTarget:entindex(),
		Queue = false,
	})

	return 2.0
end

function CastTargetPos(hAbility, hTarget )
	if hTarget == nil or hTarget:IsNull() or hTarget:IsAlive() == false then
		return 0.1
	end

	local hitPosition = hTarget:GetAbsOrigin()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = hitPosition,
		AbilityIndex = hAbility:entindex(),
		-- TargetIndex  = hTarget:entindex(),
		Queue = false,
	})

	return 2.0
end


function CastSnowball( hTarget )
	if hTarget == nil or hTarget:IsNull() or hTarget:IsAlive() == false then
		return 0.1
	end
	local vToTarget = thisEntity:GetOrigin() - hTarget:GetOrigin()
	local distance = vToTarget : Length2D()
	local hitPosition = hTarget:GetOrigin()
	if distance >= 400 then
		vToTarget = hTarget:GetForwardVector() 
		vToTarget = vToTarget:Normalized()
		hitPosition = hTarget:GetOrigin() + vToTarget * 250
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = hitPosition,
		AbilityIndex = thisEntity.hSnowballAbility:entindex(),
		Queue = false,
	})

	return 2.0
end
