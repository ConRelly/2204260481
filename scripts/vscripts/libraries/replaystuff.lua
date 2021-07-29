require("lib/my")
LinkLuaModifier("modifier_replay", "modifiers/modifier_replay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_recording", "modifiers/modifier_recording.lua", LUA_MODIFIER_MOTION_NONE)

VALID_ORDERS = 
{
	DOTA_UNIT_ORDER_MOVE_TO_POSITION,
	DOTA_UNIT_ORDER_MOVE_TO_TARGET,
	DOTA_UNIT_ORDER_ATTACK_TARGET,
	DOTA_UNIT_ORDER_ATTACK_MOVE,
	DOTA_UNIT_ORDER_CAST_POSITION,
	DOTA_UNIT_ORDER_CAST_TARGET,
	DOTA_UNIT_ORDER_CAST_TARGET_TREE,
	DOTA_UNIT_ORDER_CAST_NO_TARGET,
	DOTA_UNIT_ORDER_CAST_TOGGLE,
	DOTA_UNIT_ORDER_HOLD_POSITION,
	DOTA_UNIT_ORDER_TAUNT,
	DOTA_UNIT_ORDER_CAST_TOGGLE,
	--DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO,
}

function SetupPlayerClone(caster, ability)
	
	local cloneData = {}
	cloneData.name2 = caster
	cloneData.name = caster:GetUnitName()
	cloneData.level = caster:GetLevel()
	cloneData.spawnPoint = caster:GetAbsOrigin()

	--abilities
	cloneData.abilities = {}
	for i=0,30 do
		local cloneAbility = caster:GetAbilityByIndex(i)
		if cloneAbility and cloneAbility:GetAbilityName() ~= "dawnbreaker_luminosity" then 
			local cloneAbilityData = {name = cloneAbility:GetAbilityName(), level = cloneAbility:GetLevel()}
			table.insert(cloneData.abilities, cloneAbilityData)
			--print(cloneAbility:GetAbilityName())
		end
	end

	--items
	cloneData.items = {}
	for i=0,9 do
		local cloneItem = caster:GetItemInSlot(i)
		if cloneItem then 
			local cloneItemData = {name = cloneItem:GetAbilityName(), level = cloneItem:GetLevel(), charges = cloneItem:GetCurrentCharges()}
			table.insert(cloneData.items, cloneItemData)
			--print(cloneItem:GetAbilityName())
		end
	end

	local neutralItem = caster:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT)
	if neutralItem then 
		local cloneItemData = {name = neutralItem:GetAbilityName(), level = neutralItem:GetLevel(), charges = neutralItem:GetCurrentCharges()}
		table.insert(cloneData.items, cloneItemData)
	end

	ability.cloneData = cloneData
end


function AddRecordedAction(modifier, keys)

	local item = modifier:GetAbility()
	local time = modifier:GetDuration() - modifier:GetRemainingTime()


	local caster = keys.unit
	local order = keys.order_type
	local ability = keys.ability
	local position = keys.new_pos
	local target = keys.target
	--local abilityName1 = false
	local IllusionNotCast = {
			--["dark_willow_bedlam_lua"] = true,
			["chen_custom_holy_persuasion"] = true,
			["dark_seer_custom_dark_clone_2"] = true,
			["rubick_spell_steal"] = true,
			["arc_warden_tempest_double"] = true,
			["obs_replay"] = true,
			["item_video_file"] = true,
			["item_resurection_pendant"] = true,
			["dawnbreaker_luminosity"] = true,
			["item_random_get_ability"] = true,
			["item_random_get_ability2"] = true,
			["item_random_get_ability3"] = true,
			["item_remove_ability"] = true,
			["item_remove_doomskill"] = true,
			["item_radiance_armor_blue_edible"] = true,
			["item_radiance_armor_green_edible"] = true,
			["item_radiance_armor_3_edible"] = true,
			["item_mjz_ability_point"] = true,
			["item_mjz_ability_point_2"] = true,
			["item_custom_octarine_core2"] = true,
			["item_arcane_staff_edible"] = true, 
			["item_mjz_aether_lens"] = true,
			["item_mjz_dragon_lance"] = true,
			["item_custom_stat_change_agi"] = true,
			["item_custom_stat_change_int"] = true,
			["item_ultimate_scepter_2"] = true,
			["item_imba_ultimate_scepter_synth2"] = true,
			["item_pocket_tower"] = true,
			["item_pocket_rax"] = true,
			["item_pocket_rax_ranged"] = true,
			["item_conduit"] = true,
			["item_tome_of_knowledge"] = true,
			["item_tome_bargain"] = true,
			["item_tome_of_aghanim"] = true,
			["item_tome_str"] = true,
			["item_tome_agi"] = true,
			["item_tome_int"] = true, 
			["item_moon_shard"] = true,
			["item_mjz_rage_moon_shard"] = true, 
			["beastmaster_wild_axes"] = true,
			["lesser_cancel"] = true,
			["divine_cancel"] = true,
		};
	if ability then
		local abilityName1 = ability:GetAbilityName()
		if IllusionNotCast[abilityName1] == true then
			--print("nil cast")
			return nil
		end	
	end
	--if ability and (ability:GetAbilityName() == "obs_replay" or ability:GetAbilityName() == "item_video_file" or ability:GetAbilityName() == "chen_custom_holy_persuasion" or ability:GetAbilityName() == "dark_seer_custom_dark_clone_2" or ability:GetAbilityName() == "arc_warden_tempest_double") then return end


	if VALID_ORDERS[order] then 
		--print("A valid order was executed: " .. order)
		--print("Time: " .. time)
		local action = 
		{
			time = time,
			order = order,
			position = position,
			ability = ability,
			target = target,
		}
		if target then action.position = target:GetAbsOrigin() end
		table.insert(item.recordedActions, action)
	else 
		--print("An invalid order was executed: " .. order)
	end

end


function PlayVideo(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cloneData = ability.cloneData
	local lifetime = ability.recordTime + 1


	--Create the player clone as recorded
	--local clone = CreateUnitByName(cloneData.name, cloneData.spawnPoint, false, nil, caster, caster:GetTeamNumber())
	local clones = CreateIllusions(caster, cloneData.name2, { duration = lifetime, outgoing_damage = 100, incoming_damage = -50 }, 1, 50, true, true )
	local clone = clones[1]
	--clone:SetOwner(caster:GetPlayerOwner())
	clone:SetAbsOrigin(cloneData.spawnPoint)
	FindClearSpaceForUnit(clone, cloneData.spawnPoint, false)

	clone:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
	--clone:SetPlayerID(caster:GetPlayerID())
	clone:AddNewModifier(caster, ability, "modifier_replay", {duration = lifetime})
	--clone:MakeIllusion()
	clone:SetAbilityPoints(-1)
	--clone:SetOwner(caster)
	-- Create unit		
	
	--Levelup the player
	for i=1,cloneData.level - 1 do
		clone:HeroLevelUp(false)
	end
	--remove illusion skills
	for slot = 0, 8 do
		local oldAbility = clone:GetAbilityByIndex(slot)	
		if oldAbility and oldAbility:GetAbilityName() ~= "dawnbreaker_luminosity" then
			clone:RemoveAbilityByHandle(oldAbility)	
		end
	end	
	--Set ability points
	for k, abilityData in pairs(cloneData.abilities) do 
		if clone:HasAbility(abilityData.name) and abilityData.level > 0 then
			local cloneAbility = clone:FindAbilityByName(abilityData.name)
			cloneAbility:SetLevel(abilityData.level)
		end
	end
	-- remove illusion items
	for slot = 0, 9 do
		local iItem = clone:GetItemInSlot(slot)
		if iItem then
			clone:RemoveItem(clone:GetItemInSlot(slot))
		end
	end
	local neutralItem = clone:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT)
	if neutralItem then
		clone:RemoveItem(clone:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT))
	end	
	--Set items
	
	for k, itemData in pairs(cloneData.items) do 
        

		local item = CreateItem(itemData.name, clone, clone)
		item:SetCurrentCharges(itemData.charges)
		item:SetLevel(itemData.level)
		clone:AddItem(item)
	end

	
	--Lookup all actions and play them over the duration
	for k, action in pairs(ability.recordedActions) do 
		Timers:CreateTimer(action.time, function()
			--print("Playing action with timestamp: " .. action.time)
			if clone:IsNull() or not clone:IsAlive() then return end

			local order = action.order
			local ability = action.ability
			local target = action.target
			local position = action.position
			--Make the player clone do the thing
			if order == DOTA_UNIT_ORDER_MOVE_TO_POSITION then 
				clone:MoveToPosition(action.position)
			elseif order == DOTA_UNIT_ORDER_ATTACK_MOVE then 
				clone:MoveToPositionAggressive(action.position)
			elseif order == DOTA_UNIT_ORDER_MOVE_TO_TARGET and target and not target:IsNull() then 
				clone:MoveToPosition(action.position)
			elseif order == DOTA_UNIT_ORDER_ATTACK_TARGET and target and not target:IsNull() then 
				clone:MoveToPositionAggressive(action.position)
			elseif order == DOTA_UNIT_ORDER_TAUNT then 
				clone:PerformTaunt()				
			end

			if ability then 
				local abilityName = ability:GetAbilityName()
				local cloneAbility = clone:FindAbilityByName(abilityName)
				if not cloneAbility then cloneAbility = clone:FindItemInInventory(abilityName) end
				if cloneAbility and cloneAbility:IsActivated() and cloneAbility:IsFullyCastable() then 
					cloneAbility:EndCooldown()
					if order == DOTA_UNIT_ORDER_CAST_NO_TARGET then 
						clone:CastAbilityNoTarget(cloneAbility, -1)
					elseif order == DOTA_UNIT_ORDER_CAST_POSITION then
						clone:CastAbilityOnPosition(position, cloneAbility, -1)
					elseif order == DOTA_UNIT_ORDER_CAST_TARGET and target and not target:IsNull() then
						local newTarget = FindNewTargetForAbility(clone, cloneAbility, position)
						local abilityNameb = cloneAbility:GetAbilityName()
						if ability_behavior_includes(cloneAbility, DOTA_ABILITY_BEHAVIOR_AUTOCAST) and not cloneAbility:GetAutoCastState() then
							cloneAbility:ToggleAutoCast()
						end
						clone:CastAbilityOnTarget(newTarget, cloneAbility, -1)	
					elseif order == DOTA_UNIT_ORDER_CAST_TOGGLE then
						clone:CastAbilityToggle(cloneAbility, -1)						
					end
					cloneAbility:EndCooldown()
				end
			end
		end)
	end
	--end	

end

function FindNewTargetForAbility(caster, ability, position)
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		position, 
		nil, 
		800, 
		ability:GetAbilityTargetTeam(),
		ability:GetAbilityTargetType(),
		ability:GetAbilityTargetFlags(),
		FIND_CLOSEST, 
		false
	)
	--print(#units)
	if #units > 0 then 
		--print(units[1]:GetName())
		return units[1]
	end

	return nil
end
