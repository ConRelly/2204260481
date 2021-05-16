function Spawn( entityKeyValues )
	if not IsServer() then return end
	if thisEntity == nil then return end

	thisEntity:SetContextThink( "BloodThink", LichThink, 0.1 )
end

function LichThink()
	ultyAbility = thisEntity:FindAbilityByName( "rupture_datadriven" )
	fiesta = thisEntity:FindAbilityByName( "blood_fiesta" )
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 1 end
    
	local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )

    if ultyAbility ~= nil and ultyAbility:IsFullyCastable() and enemies[1] ~= nil then
		return cast(enemies[1])
	end
    if fiesta ~= nil and fiesta:IsFullyCastable() and enemies[1] ~= nil then
		return bf_cast(enemies[1])
	end
	return 0.1
end

function cast( enemy )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = ultyAbility:entindex(),
        TargetIndex = enemy:entindex(),
		Queue = false,
	})
	return 0.2
end
function bf_cast( enemy )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = fiesta:entindex(),
		Queue = false,
	})
	return 0.3
end