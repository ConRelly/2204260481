
require( "ai/ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
    thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( {
        BehaviorNone, 
        -- BehaviorAttack,
        BehaviorEarthshock, 
    } )
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end
--[[

function CollectRetreatMarkers()
	local result = {}
	local i = 1
	local wp = nil
	while true do
		wp = Entities:FindByName( nil, string.format("waypoint_%d", i ) )
		if not wp then
			return result
		end
		table.insert( result, wp:GetOrigin() )
		i = i + 1
	end
end
POSITIONS_retreat = CollectRetreatMarkers()
]]



--------------------------------------------------------------------------------------------------------

BehaviorNone = {}

function BehaviorNone:Evaluate()
	return 1 -- must return a value > 0, so we have a default
end

function BehaviorNone:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	--local ancient =  Entities:FindByName( nil, "dota_goodguys_fort" )
	-- local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	-- if #enemies > 0 then
	-- 	desire = #enemies
	-- end

    local idle_enabled = false
	local idle = RandomInt(1, 2)

	if idle == 2 and idle_enabled then
		local pos = thisEntity:GetAbsOrigin() + RandomVector( 800 )
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position  = pos
		}
	else
		-- self.order =
		-- {
		-- 	UnitIndex = thisEntity:entindex(),
		-- 	OrderType = DOTA_UNIT_ORDER_NONE
		-- }
	end
	
end

function BehaviorNone:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end


--------------------------------------------------------------------------------------------------------
-- 切肉刀
BehaviorEarthshock = {}

function BehaviorEarthshock:Evaluate()
	local desire = 0

	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.ability = thisEntity:FindAbilityByName( "boss_ursa_earthshock" )

	if self.ability and self.ability:IsFullyCastable() then
		local range = 600 --self.cleaverAbility:GetCastRange(thisEntity:GetAbsOrigin(), thisEntity)
		self.target = RandomEnemyHeroInRange( thisEntity, range )
		if self.target then
			self.targetPoint = self.target:GetOrigin() + RandomVector( 100 )
			desire = 4
		end
	end

	return desire
end

function BehaviorEarthshock:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5

    print("BehaviorEarthshock  Begin")
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.ability:entindex(),
		-- Position = self.targetPoint
	}

end

BehaviorEarthshock.Continue = BehaviorEarthshock.Begin


--------------------------------------------------------------------------------------------------------


AICore.possibleBehaviors = {
    BehaviorNone,
    -- BehaviorAttack, 
    BehaviorEarthshock, 

}


--------------------------------------------------------------------------------------------------------

function RandomEnemyHeroInRange( entity, range )
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), entity, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	local list =  {}
	for k,unit in pairs(enemies) do
		table.insert( list, unit )
	end
	if #list > 0 then
		local index = RandomInt( 1, #list )
		return list[index]
	else
		return nil
	end
end