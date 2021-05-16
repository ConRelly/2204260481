--[[
Pudge AI
]]

require( "ai/ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if PlayerResource:IsFakeClient(thisEntity:GetPlayerID()) then
		thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
		behaviorSystem = AICore:CreateBehaviorSystem( {
			BehaviorNone, 
			BehaviorAttack,
			BehaviorCleaver, 
			-- BehaviorRunAway,
			BehaviorThrowHook,
			-- BehaviorMeatHook,
			-- BehaviorUpgradeAbility,
			BehaviorItemGrapplingHook,
		} )
	end
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

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

	local idle = RandomInt(1, 2)

	if idle == 2 then
		local pos = thisEntity:GetAbsOrigin() + RandomVector( 800 )
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position  = pos
		}
	else
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_NONE
		}
	end
	
end

function BehaviorNone:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

--------------------------------------------------------------------------------------------------------

BehaviorAttack = {}

function BehaviorAttack:Evaluate()
	local range = 5000
	local target = RandomEnemyHeroInRange(thisEntity, range)

	if target then
		self.target = target
		return 2
	else
		return 0
	end
end

function BehaviorAttack:Begin()
	self.endTime = GameRules:GetGameTime() + 1

	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = self.target:GetAbsOrigin()
	}
end

BehaviorAttack.Continue = BehaviorAttack.Begin

--------------------------------------------------------------------------------------------------------

BehaviorDismember = {}

function BehaviorDismember:Evaluate()
	self.dismemberAbility = thisEntity:FindAbilityByName("pudge_dismember")
	local target
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.dismemberAbility and self.dismemberAbility:IsFullyCastable() then
		local range = self.dismemberAbility:GetCastRange()
		target = RandomEnemyHeroInRange( thisEntity, range )
	end

	if target then
		desire = 5
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorDismember:Begin()
	self.endTime = GameRules:GetGameTime() + 5

	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = self.target:entindex(),
		AbilityIndex = self.dismemberAbility:entindex()
	}
end

BehaviorDismember.Continue = BehaviorDismember.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorDismember:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end

--------------------------------------------------------------------------------------------------------
-- 切肉刀
BehaviorCleaver = {}

function BehaviorCleaver:Evaluate()
	local desire = 0

	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.cleaverAbility = thisEntity:FindAbilityByName( "pudge_wars_cleaver" )

	if self.cleaverAbility and self.cleaverAbility:IsFullyCastable() then
		local range = 1200 --self.cleaverAbility:GetCastRange(thisEntity:GetAbsOrigin(), thisEntity)
		self.target = RandomEnemyHeroInRange( thisEntity, range )
		if self.target then
			self.targetPoint = self.target:GetOrigin() + RandomVector( 100 )
			desire = 4
		end
	end

	return desire
end

function BehaviorCleaver:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5

	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.cleaverAbility:entindex(),
		Position = self.targetPoint
	}

end

BehaviorCleaver.Continue = BehaviorCleaver.Begin

--------------------------------------------------------------------------------------------------------

BehaviorThrowHook = {}

function BehaviorThrowHook:Evaluate()
	local desire = 0

	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.hookAbility = thisEntity:FindAbilityByName( "pudge_wars_custom_hook" )

	if self.hookAbility and self.hookAbility:IsFullyCastable() then
		local range = 1500--self.hookAbility:GetCastRange(thisEntity:GetAbsOrigin(), thisEntity)
		self.target = RandomEnemyHeroInRange( thisEntity, range )
		if self.target then
			self.targetPoint = self.target:GetOrigin() + RandomVector( 100 )
			desire = 5
		end
	end

	--[[

	local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			local enemyVec = enemy:GetOrigin() - thisEntity:GetOrigin()
			local myForward = thisEntity:GetForwardVector()
			local dotProduct = enemyVec:Dot( myForward )
			if dotProduct > 0 then
				desire = 2
			end
		end
	end
	]]

	return desire
end

function BehaviorThrowHook:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5

	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.hookAbility:entindex(),
		Position = self.targetPoint
	}
end

BehaviorThrowHook.Continue = BehaviorThrowHook.Begin

--------------------------------------------------------------------------------------------------------

BehaviorMeatHook = {}

function BehaviorMeatHook:Evaluate()
	local desire = 0

	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.hookAbility = thisEntity:FindAbilityByName( "pudge_meat_hook" )

	if self.hookAbility and self.hookAbility:IsFullyCastable() then
		local range = 1200--self.hookAbility:GetCastRange(thisEntity:GetAbsOrigin(), thisEntity)
		self.target = RandomEnemyHeroInRange( thisEntity, range )
		if self.target then
			self.targetPoint = self.target:GetOrigin() + RandomVector( 100 )
			desire = 5
		end
	end

	
	local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			local enemyVec = enemy:GetOrigin() - thisEntity:GetOrigin()
			local myForward = thisEntity:GetForwardVector()
			local dotProduct = enemyVec:Dot( myForward )
			if dotProduct > 0 then
				desire = 2
			end
		end
	end

	return desire
end

function BehaviorMeatHook:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5

	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.hookAbility:entindex(),
		Position = self.targetPoint
	}
end

BehaviorMeatHook.Continue = BehaviorMeatHook.Begin

--------------------------------------------------------------------------------------------------------
-- 物品：抓勾
BehaviorItemGrapplingHook = {}

function BehaviorItemGrapplingHook:Evaluate()
	local desire = 0

	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.itemGHOOK = thisEntity:FindItemInInventory('item_grappling_hook')

	if self.itemGHOOK and self.itemGHOOK:IsFullyCastable() then
		local pos = thisEntity:GetAbsOrigin()
		local c1 = pos.z < 1.0
		local c2 = (RandomInt(1, 5) == 5) -- 五分之一机会使用
		if c1 or c2 then
			self.targetPoint = thisEntity:GetForwardVector() + RandomVector(400)
			desire = 6
		end
	end

	return desire
end

function BehaviorItemGrapplingHook:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5

	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.itemGHOOK:entindex(),
		Position = self.targetPoint
	}
end

BehaviorItemGrapplingHook.Continue = BehaviorItemGrapplingHook.Begin

--------------------------------------------------------------------------------------------------------

BehaviorRunAway = {}

function BehaviorRunAway:Evaluate()
	local desire = 0
	local happyPlaceIndex =  RandomInt( 1, #POSITIONS_retreat )
	escapePoint = POSITIONS_retreat[ happyPlaceIndex ]
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	if #enemies > 0 then
		desire = #enemies
	end

	for i=0,DOTA_ITEM_MAX-1 do
		local item = thisEntity:GetItemInSlot( i )
		if item and item:GetAbilityName() == "item_force_staff" then
			self.forceAbility = item
		end
		if item and item:GetAbilityName() == "item_phase_boots" then
			self.phaseAbility = item
		end
		-- if item and item:GetAbilityName() == "item_ancient_janggo" then
		-- 	self.drumAbility = item
		-- end
		-- if item and item:GetAbilityName() == "item_urn_of_shadows" then
		-- 	self.urnAbility = item
		-- end
	end

	return desire
end


function BehaviorRunAway:Begin()
	self.endTime = GameRules:GetGameTime() + 6

	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = thisEntity:entindex(),
		AbilityIndex = self.forceAbility:entindex()
	}
end

function BehaviorRunAway:Think(dt)

	--[[

	ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = thisEntity:entindex(),
			AbilityIndex = self.forceAbility:entindex()
		})
	]]

	if self.forceAbility and not self.forceAbility:IsFullyCastable() then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = escapePoint
		})
		-- ExecuteOrderFromTable({
		-- 	UnitIndex = thisEntity:entindex(),
		-- 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		-- 	AbilityIndex = self.drumAbility:entindex()
		-- })
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = self.phaseAbility:entindex()
		})
	end

	if self.urnAbility and self.urnAbility:IsFullyCastable() and self.endTime < GameRules:GetGameTime() + 2 then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = thisEntity:entindex(),
			AbilityIndex = self.urnAbility:entindex()
		})
	end
end

BehaviorRunAway.Continue = BehaviorRunAway.Begin

--------------------------------------------------------------------------------------------------------

BehaviorUpgradeAbility = {}

function BehaviorUpgradeAbility:Evaluate()
	local modifier = thisEntity:FindModifierByName('modifier_ability_points')
	if modifier and modifier:GetStackCount() > 0 then
		return 10
	else
		return 0
	end
end

function BehaviorUpgradeAbility:Begin()
	self.endTime = GameRules:GetGameTime() + 1

	local alist = {
		"pudge_wars_upgrade_hook_damage",
		"pudge_wars_upgrade_hook_range",
		"pudge_wars_upgrade_hook_speed",
		"pudge_wars_upgrade_hook_size",
	}
	local ability_name = alist[ RandomInt(1, #alist) ]
	local ability = thisEntity:FindAbilityByName(ability_name)

	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_TRAIN_ABILITY,
		AbilityIndex = ability:GetEntityIndex(),
	}
end

BehaviorUpgradeAbility.Continue = BehaviorUpgradeAbility.Begin

--------------------------------------------------------------------------------------------------------


if PlayerResource and PlayerResource:IsFakeClient(thisEntity:GetPlayerID()) then

	AICore.possibleBehaviors = {
		BehaviorNone,
		BehaviorAttack, 
		BehaviorCleaver, 
		-- BehaviorRunAway,
		BehaviorThrowHook,
		-- BehaviorMeatHook,
		-- BehaviorUpgradeAbility,
		BehaviorItemGrapplingHook,
	}
end

--------------------------------------------------------------------------------------------------------



function GetUnitEnemyTeam( unit )
	if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		return DOTA_TEAM_GOODGUYS
	else
		return DOTA_TEAM_BADGUYS
	end
end

function IsPudgePlayer( unit )
	if unit and unit:HasAbility('pudge_wars_custom_hook') then
		return unit:GetUnitName() == "npc_dota_hero_pudge" --or unit:GetName() == "npc_dota_hero_pudge" --string.find(unit:GetClassname(), "pudge") -- --or 
	end
	return false
end


function RandomEnemyHeroInRange( entity, range )
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), entity, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	local list =  {}
	for k,unit in pairs(enemies) do
		if IsPudgePlayer(unit) then
			table.insert( list, unit )
		end
	end
	if #list > 0 then
		local index = RandomInt( 1, #list )
		return list[index]
	else
		return nil
	end
end
function RandomEnemyHeroInRange2( entity, range )
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), entity, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	if #enemies > 0 then
		for k,v in pairs(enemies) do
			local index = RandomInt( 1, #enemies )
			local unit =  v --enemies[index]
			if IsPudgePlayer(unit) then
				return unit
			end
		end
	else
		return nil
	end
end
