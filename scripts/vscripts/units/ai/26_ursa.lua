function Spawn( entityKeyValues )
	if not IsServer() then return end
	if thisEntity == nil then return end

	earthshock = thisEntity:FindAbilityByName( "ursa_earthshock" )
	thisEntity:SetContextThink( "Think", Think, 1 )
end

function Think()
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 1 end
    
	local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 865, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
    if earthshock ~= nil and enemies[1] ~= nil then return es(enemies[1]) end
	return 0.5
end

function es(enemy)
    earthshock:EndCooldown()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = earthshock:entindex(),
		Queue = false,
	})
	return 5
end