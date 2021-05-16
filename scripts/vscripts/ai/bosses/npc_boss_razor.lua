function Spawn(entityKeyValues)
	thisEntity:SetContextThink("AIThink", AIThink, 0.25)
end


function AIThink()

    local ancient = Entities:FindByName(nil, "dota_goodguys_fort")
    local attackOrder = nil
    local attackOrder_Origin = {
        UnitIndex = thisEntity:entindex(), 
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        Position = thisEntity:GetAbsOrigin()
    }

    if ancient and ancient:IsAlive() and thisEntity:IsAlive() then
		if not thisEntity:IsInvisible() and not thisEntity:IsChanneling() and thisEntity:GetCurrentActiveAbility() == nil and not thisEntity:IsCommandRestricted() then
			if (CalcDistanceBetweenEntityOBB(thisEntity, ancient) > 800) then
				if not thisEntity:IsDisarmed() then
					attackOrder = {
						UnitIndex = thisEntity:entindex(), 
						OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
						Position = ancient:GetAbsOrigin()
					}
					ExecuteOrderFromTable(attackOrder)
				else 
					attackOrder = attackOrder_Origin
				end
			end
		end
    end

    local mName = "modifier_razor_static_link_buff"
    if thisEntity:IsAlive() and thisEntity:HasModifier(mName) then
        local nSearchRange = 640
        local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )    
        if #hEnemies > 0 then
            attackOrder = attackOrder_Origin
        end
    end

    if attackOrder then
        ExecuteOrderFromTable(attackOrder)
    end

	return 1
end