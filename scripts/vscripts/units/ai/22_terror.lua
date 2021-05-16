function Spawn( entityKeyValues )
	if not IsServer() then return end
	if thisEntity == nil then return end

	sunder = thisEntity:FindAbilityByName( "cast_sunder" )
	buffAbility = thisEntity:FindAbilityByName( "sunder_buff" )
	thisEntity:SetContextThink( "TerrorThink", TitanTankThink, 1 )
end

function TitanTankThink()
	if ( not thisEntity:IsAlive() ) then return -1 end
	if GameRules:IsGamePaused() == true then return 1 end

	local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 9999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )

	local maxhealth = 0
	local unitmaxhealth = nil
	for i = 1, #enemies do
		local enemy = enemies[i]
		if enemy ~= nil then
			local unithealth = enemy:GetHealth()
			if unithealth > maxhealth then
				maxhealth = unithealth
				unitmaxhealth = enemy
			end
		end
	end

	if sunder ~= nil and sunder:IsFullyCastable() and unitmaxhealth ~= nil then
		if thisEntity:GetHealth() / thisEntity:GetMaxHealth() * 100 < 20 then
			return swap(unitmaxhealth)
		end
	end
	return 0.5
end


function swap( enemy )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = sunder:entindex(),
        TargetIndex = enemy:entindex(),
		Queue = false,
	})
    ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = buffAbility:entindex(),
		Queue = false,
	})
	return 1
end