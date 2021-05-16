
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

	-- thisEntity.hPSAbility = thisEntity:FindAbilityByName( "boss_antimage_phantom_strike_wrapper" )
	thisEntity.hMantaItem = find_item(thisEntity, "item_manta")

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

	if thisEntity.hMantaItem  then  --and thisEntity.hMantaItem:IsFullyCastable()
		if thisEntity:IsSilenced() then
			thisEntity.hMantaItem:EndCooldown()
			thisEntity.hMantaItem:CastAbility()
			return 0.5
		end
	end
	--[[

	if thisEntity.hPSAbility and thisEntity.hPSAbility:IsFullyCastable() then

		local nSearchRange = thisEntity.hPSAbility:GetCastRange()
		local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		if #hEnemies > 0 then
			local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
			return CastTarget(thisEntity.hPSAbility, hRandomEnemyPlayer )
		end
	end
	]]

	--[[
	if thisEntity.hKickAbility and thisEntity.hKickAbility:IsFullyCastable() then

		local nSearchRange = thisEntity.hKickAbility:GetCastRange()
		local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		if #hEnemies > 0 then
			local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
			CastTargetedAbility( thisEntity, hRandomEnemyPlayer, thisEntity.hKickAbility )
			return 0.5
		end
	end
	]]

	local now = GameRules:GetGameTime()
	thisEntity._prev_attack = thisEntity._prev_attack or 0
	local nSearchRange = 1600
	if (now - thisEntity._prev_attack) > 5 then
		thisEntity._prev_attack = now
			
		local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		if #hEnemies > 0 then
			local hRandomEnemyPlayer = hEnemies[ RandomInt( 1, #hEnemies ) ]
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex  = hRandomEnemyPlayer:entindex(),
				Queue = false,
			})
			return 0.5
		end
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
