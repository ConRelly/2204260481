
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity:SetContextThink( "MeranthGuardThink", MeranthGuardThink, 0.5 )
end

--------------------------------------------------------------------------------

function MeranthGuardThink()
	if ( not thisEntity ) or ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 1
	end

	if ( not thisEntity.bAcqRangeModified ) and thisEntity.hMaster then
		SetAggroRange( thisEntity, 6000 )
	end
end

--------------------------------------------------------------------------------

function SetAggroRange( hUnit, fRange )
	--print( string.format( "Set search radius and acquisition range (%.2f) for unit %s", fRange, hUnit:GetUnitName() ) )
	hUnit.fSearchRadius = fRange
	hUnit:SetAcquisitionRange( fRange )
	hUnit.bAcqRangeModified = true
end
