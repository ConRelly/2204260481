require("lib/string")
require("played_heroes")
require("items/lier_scarlet")
LinkLuaModifier("modifier_reload_bullet_channel_command", "heroes/hero_kardel/abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_prevent_tombstone_channel_custom", "modifiers/modifier_prevent_tombstone_channel.lua", LUA_MODIFIER_MOTION_NONE )
local count = 0
local count2 = 0
local count3 = 4
local kardel_item = true

function AOHGameMode:OnPlayerChat(keys)
	local time = math.floor(GameRules:GetGameTime() / 60)
	if keys.text == "-hard" and not self._hardMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		if GetMapName() ~= "heroattack_on_easy" then
			self._hardMode = true
			_G._hardMode = true
			_G._normal_mode = true
			Notifications:TopToAll({text="NotEasy mode has been activated.", style={color="red"}, duration=5})
			self:_ReadGameConfiguration()
		else
			Notifications:TopToAll({text="You Need to Play Normal Map to activate Hard Mode.", style={color="yellow"}, duration=15})
		end	
	end
	if keys.text == "-endless" and not self._endlessMode and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._endlessMode = true
		Notifications:TopToAll({text="Almost Full Game Enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
	end
	if keys.text == "-full" and not self._endlessMode and not Cheats:IsEnabled() and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		local steam_name = PlayerResource:GetPlayerName(0)
		if keys.playerid == 0 then
			self._endlessMode = true
			Notifications:TopToAll({text="Second part Enabled", style={color="red"}, duration=5})
			self._flPrepTimeBetweenRounds = 12
		else
			Notifications:TopToAll({text="Host( "..steam_name.." ) can type '-full' to enable Second part", style={color="red"}, duration=10})	
		end	
	end
	if keys.text == "-all" and (not self._endlessMode or not self._hardMode or not self._doubleMode) and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		if GetMapName() ~= "heroattack_on_easy" then
			self._endlessMode = true
			self._hardMode = true
			_G._hardMode = true
			self._doubleMode = true
			_G._normal_mode = true
			Notifications:TopToAll({text="Full Game, Hard Double Enabled", style={color="red"}, duration=5})
			self._flPrepTimeBetweenRounds = 12
			self:_ReadGameConfiguration()
		else
			Notifications:TopToAll({text="You Need to Play Normal Map to activate Hard Mode.", style={color="yellow"}, duration=15})
		end	
	end
	function _CreateFakeCourier2(hero)
		local origin = Vector(-2958, 2031, -969) + RandomVector(100)
		local courier_replacement = CreateUnitByName("npc_courier_replacement", origin, true, hero, hero:GetOwner(), hero:GetTeamNumber())
		courier_replacement:SetControllableByPlayer(hero:GetPlayerID(), true)
		courier_replacement:SetTeam(hero:GetTeamNumber())
		courier_replacement:SetOwner(hero)
		--self._nPlayerHelp = courier_replacement
	
		courier_replacement:AddNewModifier(courier_replacement, nil, "modifier_mjz_fake_courier", {})
		courier_replacement:AddNewModifier(courier_replacement, nil, "modifier_meepo_pack_rat", {})
		courier_replacement:AddNewModifier(courier_replacement, nil, "modifier_techies_spoons_stash", {})		
		local playerID = hero:GetPlayerID()
		local player = hero:GetPlayerOwner()
		-- local courier = PlayerResource:GetNthCourierForTeam(playerID, DOTA_TEAM_GOODGUYS) 
	
		
	end



	if keys.text == "-alle" and (not self._endlessMode or not self._doubleMode) and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)		
		self._endlessMode = true
		self._doubleMode = true
		_G._normal_mode = true	
		Notifications:TopToAll({text="Part 2 normal, Double", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
		self:_ReadGameConfiguration()
		if player_count == 1 and not self._singleMode then
			self._singleMode = true
			mHackGameMode:GM_SinglePlayer()
			_CreateFakeCourier2(hero)
			Notifications:TopToAll({text="#game_mode_single_player", style={color="yellow"}, duration=5})
		end	

		if player_count == 1 and self.gon and not self.spawned_gon then
			self.gon = false
			hero:AddItemByName("item_philosophers_stone2")
			Notifications:TopToAll({text="Helper Unit Disabled", style={color="yellow"}, duration=6})
		end				
	end	
	if keys.text == "-allee" and (not self._endlessMode or not self._doubleMode) and not self._extra_mode and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)		
		self._endlessMode = true
		self._doubleMode = true
		_G._normal_mode = true
		self._extra_mode = true
		_G._extra_mode = true		
		Notifications:TopToAll({text="Part 2 normal, Double and Extra Enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
		self:_ReadGameConfiguration()
		if player_count == 1 and not self._singleMode then
			self._singleMode = true
			mHackGameMode:GM_SinglePlayer()
			_CreateFakeCourier2(hero)
			Notifications:TopToAll({text="#game_mode_single_player", style={color="yellow"}, duration=5})
		end	

		if player_count == 1 and self.gon and not self.spawned_gon then
			self.gon = false
			hero:AddItemByName("item_philosophers_stone2")
			Notifications:TopToAll({text="Helper Unit Disabled", style={color="yellow"}, duration=6})
		end				
	end	
	if keys.text == "-allee2" and (not self._endlessMode or not self._doubleMode) and not self._extra_mode and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)		
		self._endlessMode = true
		self._doubleMode = true
		_G._normal_mode = true
		self._extra_mode = true
		_G._extra_mode = true		
		Notifications:TopToAll({text="Part 2 normal, Double and Extra Enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
		self:_ReadGameConfiguration()
		if player_count == 1 and not self._singleMode then
			self._singleMode = true
			mHackGameMode:GM_SinglePlayer()
			_CreateFakeCourier2(hero)
			Notifications:TopToAll({text="#game_mode_single_player", style={color="yellow"}, duration=5})
		end				
	end	
	if keys.text == "-alle2" and (not self._endlessMode or not self._doubleMode) and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)		
		self._endlessMode = true
		self._doubleMode = true
		_G._normal_mode = true		
		Notifications:TopToAll({text="Part 2 normal, Double and Extra Enabled", style={color="red"}, duration=5})
		self._flPrepTimeBetweenRounds = 12
		self:_ReadGameConfiguration()
		if player_count == 1 and not self._singleMode then
			self._singleMode = true
			mHackGameMode:GM_SinglePlayer()
			_CreateFakeCourier2(hero)
			Notifications:TopToAll({text="#game_mode_single_player", style={color="yellow"}, duration=5})
		end	
			
	end			
	if keys.text == "-fullhard" and (not self._endlessMode or not self._hardMode) and not Cheats:IsEnabled() and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		if GetMapName() ~= "heroattack_on_easy" then
			self._endlessMode = true
			self._hardMode = true
			_G._hardMode = true
			_G._normal_mode = true
			Notifications:TopToAll({text="Full Game Hard Enabled", style={color="red"}, duration=5})
			self._flPrepTimeBetweenRounds = 12
			self:_ReadGameConfiguration()
		else
			Notifications:TopToAll({text="You Need to Play Normal Map to activate Hard Mode.", style={color="yellow"}, duration=15})
		end	
	end
	if keys.text == "-fullgame" and (not self._endlessMode or not self._hardMode) and not Cheats:IsEnabled() and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		local steam_name = PlayerResource:GetPlayerName(0)
		if keys.playerid == 0 then
			if GetMapName() ~= "heroattack_on_easy" then
				self._endlessMode = true
				self._hardMode = true
				_G._hardMode = true
				_G._normal_mode = true
				Notifications:TopToAll({text="Full Game Enabled (hard only) ", style={color="red"}, duration=5})
				self._flPrepTimeBetweenRounds = 12
				self:_ReadGameConfiguration()
			else
				Notifications:TopToAll({text="You Need to Play Normal Map to activate Hard Mode.", style={color="yellow"}, duration=15})
			end
		else
			Notifications:TopToAll({text="Host( "..steam_name.." ) can type '-fullgame' to enable Full Game(hard only)(part 2 and 3) ", style={color="red"}, duration=10})	
		end	
	end
	if keys.text == "-testsfull" and (not self._endlessMode or not self._hardMode) and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		local steam_name = PlayerResource:GetPlayerName(0)
		if steam_name ~= "ConRelly" then return end
		if GetMapName() ~= "heroattack_on_easy" then
			self._endlessMode = true
			self._hardMode = true
			_G._hardMode = true
			_G._normal_mode = true
			Notifications:TopToAll({text="Full Game Enabled test (hard only) ", style={color="red"}, duration=5})
			self._flPrepTimeBetweenRounds = 12
			self:_ReadGameConfiguration()
		else
			Notifications:TopToAll({text="You Need to Play Normal Map to activate Hard Mode.", style={color="yellow"}, duration=15})
		end	
	end

	if keys.text == "-extra" and not self._extra_mode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._extra_mode = true
		_G._extra_mode = true
		Notifications:TopToAll({text="Extra Mode Enabled, Bosses over lvl 14 will now get 2-6 random skills(Beta) ", style={color="blue"}, duration=9})		
	end	
	if keys.text == "-normal" and not _G._normal_mode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		_G._normal_mode = true
		Notifications:TopToAll({text="Normal Mode Enabled, Base now has normal armor. ", style={color="blue"}, duration=9})		
	end		

	if keys.text == "-zeromanall" and not self._manaMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._manaMode = true
		Notifications:TopToAll({text="#game_mode_mana_enabled", style={color="blue"}, duration=5})
		-- mHackGameMode:ZeroManaMode()
	end
	if keys.text == "-Nonplussed Colonel " and not Cheats:IsEnabled() and time > 30 and not self.renew then
		Notifications:TopToAll({text="#renew_stats1", style={color="red"}, duration=5})
		self.renew = true
	end
	if keys.text == "-Ironic Enormity" and not Cheats:IsEnabled() and time > 30 and not self.renew then
		Notifications:TopToAll({text="#renew_stats2", style={color="red"}, duration=5})
		self.renew = true
	end
	if keys.text == guessing_game_1 and not Cheats:IsEnabled() and time > 30 and not self._physdanage and not GameRules:IsGamePaused() then
		Notifications:TopToAll({text="#dota_npc_does_ab", style={color="red"}, duration=12})
		self._physdanage = true
		self:_RenewStats()
	end
	if keys.text == "-dev_guessing_game" and Cheats:IsEnabled() then
		self._physdanage = true
		self:_RenewStats()	
	end
	function GetRandomPointOnMap(center, minRadius, maxRadius)
		local direction = RandomVector(1)
		local distance = RandomFloat(minRadius, maxRadius)
		local offset = direction * distance
		local pos = center + offset
		return GetGroundPosition(pos, nil)
	end
	if keys.text == "-dev_rune" and Cheats:IsEnabled() and keys.playerid == 0 then
		local center = Vector(0, 0, 0)
		local minRadius = 50
		local maxRadius = 750
		local runePos = GetRandomPointOnMap(center, minRadius, maxRadius)
		local rune = CreateRune(runePos, DOTA_RUNE_XP)
		print("track rune comand")
	end
	if keys.text == "-dev_location" and Cheats:IsEnabled() and keys.playerid == 0 then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
		local location = hero:GetAbsOrigin()
		print("current location: ".. tostring(location))
	end	
	if keys.text == "-dev_enemy" and keys.playerid == 0 then
		if _G._dev_enemy then
			_G._dev_enemy = false
		else
			_G._dev_enemy = true
			_G._dev_enemy_ano = true
		end	
	end	
	if keys.text == "-autoskip" and keys.playerid == 0 then
		if _G.auto_skipp then
			_G.auto_skipp = false
			Notifications:TopToAll({text="Autoskip OFF", style={color="blue"}, duration=5})	
		else
			_G.auto_skipp = true
			Notifications:TopToAll({text="Autoskip ON", style={color="green"}, duration=5})	
		end	
	end
	if keys.text == "-evo2" and keys.playerid == 0 then
		if _G.evolution_bow_first_option then
			_G.evolution_bow_first_option = false
			Notifications:TopToAll({text="Evolution bow effects second option", style={color="blue"}, duration=7})	
		else
			_G.evolution_bow_first_option = true
			Notifications:TopToAll({text="Default Evolution bow effects", style={color="green"}, duration=7})	
		end	
	end		
	
	if keys.text == guessing_gmae_2 and not Cheats:IsEnabled() and time > 30 and not self._physdanage and not GameRules:IsGamePaused() then
		Notifications:TopToAll({text="#dota_npc_does_bc", style={color="red"}, duration=5})
		self._physdanage = true
	end		

	if keys.text == "-dev_stuff" and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME and Cheats:IsEnabled() then
		if PlayerResource:IsValidPlayerID(0) then
			if PlayerResource:HasSelectedHero(0) then
				if PlayerResource:GetPlayer(0) then
					local hero = PlayerResource:GetSelectedHeroEntity(0)
					hero:AddItemByName("item_dev_undying")
					hero:AddItemByName("item_dev_dagon")
					hero:AddItemByName("item_radiance_armor_3_edible")
					hero:AddItemByName("item_custom_octarine_core2")

					local GoldRingCount = 2
					for i = 1, GoldRingCount do
						Timers:CreateTimer(0.05 * i, function()
							local GoldRing = hero:AddItemByName("item_plain_perma")
							GoldRing:SetPurchaser(hero)
						end)
					end
					hero:AddItemByName("item_spirit_guardian")
					--hero:AddItemByName("item_arcane_staff_edible")
				end
			end
		end
	end

	if keys.text == "-dev_modifiers" and keys.playerid == 0 and Cheats:IsEnabled() then
		for i = 0, 4 do
			print_hero_all_modifiers(i)
		end
	end


	if keys.text == "-autocast" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end
	if keys.text == "-autocast2" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast2") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast2")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast2")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast2")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end
	if keys.text == "-autocast3" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast3") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast3")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast3")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast3")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end
	if keys.text == "-autocast4" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast4") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast4")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast4")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast4")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end
	if keys.text == "-autocast6" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast4_5") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast4_5")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast4_5")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast4_5")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end	
	if keys.text == "-autocast5" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast5") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast5")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast5")
				Notifications:TopToAll({text="refresh", style={color="blue"}, duration=1})
				Timers:CreateTimer({
					endTime = 0.55, 
					callback = function()
						hero:AddAbility("mjz_bristleback_quill_spray_autocast5")	
						--print("refresh skill")
					end
				})				 
			end					   
		end	
	end	
	if keys.text == "-removeauto" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast4") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast4")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast4")
				Notifications:TopToAll({text="Removed autocast", style={color="blue"}, duration=1})				 
			end					   
		end	
	end	
	if keys.text == "-removeauto2" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("mjz_bristleback_quill_spray_autocast4_5") then
			local ability = hero:FindAbilityByName("mjz_bristleback_quill_spray_autocast4_5")
			if not ability:GetToggleState() then
				hero:RemoveAbility("mjz_bristleback_quill_spray_autocast4_5")
				Notifications:TopToAll({text="Removed multi autocast", style={color="yellow"}, duration=3})				 
			end					   
		end	
	end	
	if keys.text == "-removeconsume" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:HasAbility("custom_aegis_cast") then
			local ability = hero:FindAbilityByName("custom_aegis_cast")
			if not ability:GetAutoCastState() then
				hero:RemoveAbility("custom_aegis_cast")
				Notifications:TopToAll({text="Removed Consume Aegis", style={color="blue"}, duration=2})
			else
				Notifications:Top(playerID, {text= "Untoggle the autocast of skill", style={color="red"}, duration=5})			 
			end					   
		end	
	end											
	if keys.text == "-zeromana" then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
		local playerID = keys.playerid
		if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if player_count < 4 then
				self._manaMode = true
				mHackGameMode:ZeroManaMode(hero)
			else
				mHackGameMode:ZeroManaModeAlone(hero)
			end
		end
	end
	--[[if keys.text == "-dpsoff" and self.dpsinfo and keys.playerid == 0 then
		self.dpsinfo = false
		Notifications:TopToAll({text="Damage Counter Off", style={color="red"}, duration=5})		
	end	
	if keys.text == "-dpson" and not self.dpsinfo and keys.playerid == 0 then
		self.dpsinfo = true
		Notifications:TopToAll({text="Damage Counter ON", style={color="green"}, duration=5})		
	end]]	

	if keys.text == "-hide" then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
		
		if PlayerResource:GetPlayer(keys.playerid):GetAssignedHero().playerAbilities == nil then
			PlayerResource:GetPlayer(keys.playerid):GetAssignedHero().playerAbilities = {}
		end
		local MenuAbilities = PlayerResource:GetPlayer(keys.playerid):GetAssignedHero().playerAbilities
		
		for i = 6, hero:GetAbilityCount() - 1 do
			local hAbility = hero:GetAbilityByIndex(i)
			if hAbility and not hAbility:IsAttributeBonus() and not hAbility:IsHidden() and not string.find(hAbility:GetAbilityName(), "empty") and bit.band(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0 then
				if hAbility:GetLevel() == hAbility:GetMaxLevel() then
					hAbility:SetHidden(true)
					table.insert(MenuAbilities, hAbility:GetAbilityName())
				end
			end
		end
	end
	if keys.text == "-unhide" then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
		
		if PlayerResource:GetPlayer(keys.playerid):GetAssignedHero().playerAbilities == nil then
			PlayerResource:GetPlayer(keys.playerid):GetAssignedHero().playerAbilities = {}
		end
		local MenuAbilities = PlayerResource:GetPlayer(keys.playerid):GetAssignedHero().playerAbilities
		
		for i = 6, hero:GetAbilityCount() - 1 do
			local hAbility = hero:GetAbilityByIndex(i)
			if hAbility and not hAbility:IsAttributeBonus() and hAbility:IsHidden() and not string.find(hAbility:GetAbilityName(), "empty") and bit.band(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0 then
				if hAbility:GetLevel() == hAbility:GetMaxLevel() then
					for id,ab in pairs(MenuAbilities) do
						if ab == hAbility:GetAbilityName() then
							table.remove(MenuAbilities, id)
						end
					end
					hAbility:SetHidden(false)
				end
			end
		end
	end
	

	if keys.text == "-saveballista" then
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)

		if hero and IsValidEntity(hero) then
			local best_item = nil
			local max_stacks = -1
			local best_slot = -1

			-- Check normal inventory slots (0-8)
			for i = 0, 8 do
				local item = hero:GetItemInSlot(i)
				if item and (item:GetName() == "item_custom_ballista" or item:GetName() == "item_custom_ballista_2") then
					-- Only allow if the item's owner is the hero
					if item:GetOwner() == hero then
						local current_stacks = item:GetCurrentCharges()
						if current_stacks > max_stacks then
							max_stacks = current_stacks
							best_item = item
							best_slot = i
						end
					end
				end
			end

			-- Check neutral slot (16)
			local neutral_item = hero:GetItemInSlot(16)
			if neutral_item and (neutral_item:GetName() == "item_custom_ballista" or neutral_item:GetName() == "item_custom_ballista_2") then
				if neutral_item:GetOwner() == hero then
					local current_stacks = neutral_item:GetCurrentCharges()
					-- Prioritize neutral slot if stacks are equal or higher than current best in normal slots
					if current_stacks >= max_stacks then
						max_stacks = current_stacks
						best_item = neutral_item
						best_slot = 16
					end
				end
			end

			if best_item then
				_G.saved_ballista_stacks[playerID] = {
					item_name = "ballista_saved_stacks",
					stacks = max_stacks
				}
				-- Mark the item as saved by storing a reference
				best_item:SetShareability(ITEM_NOT_SHAREABLE)
				_G.saved_ballista_items = _G.saved_ballista_items or {}
				_G.saved_ballista_items[playerID] = best_item
				-- Mark the item as "saved" (custom property for later check)
				best_item._is_saved_ballista = true

				Notifications:Top(playerID, {text="Saved Ballista charges: "..max_stacks.." from slot "..best_slot+1 ..". Item is now non-sharable. Your next upgrade will inherit the charges(only next one)", style={color="green"}, duration=12})
			else
				Notifications:Top(playerID, {text="No Ballista found in inventory to save charges from (must be owned by you).", style={color="red"}, duration=7})
			end
		else
			Notifications:Top(playerID, {text="Could not find your hero.", style={color="red"}, duration=5})
		end
	end

	-- Modify -ballista command to check for saved ballista and cap reward if needed
	if keys.text == "-ballista" then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
		if hero:IsAlive() and IsValidEntity(hero) then
			-- Check for item_custom_ballista_2 only in neutral slot (16)
			local item = hero:GetItemInSlot(16)
			local is_saved = false
			if item and item:GetName() == "item_custom_ballista_2" then
				-- Check if this item is the saved one (by reference) or marked as saved
				if (item._is_saved_ballista == true) or (_G.saved_ballista_items and _G.saved_ballista_items[keys.playerid] == item) then
					is_saved = true
				end
				local charges = item:GetCurrentCharges()
				if is_saved then
					charges = math.min(charges, 9)
				end
				local stat_gain = charges * 7
				hero:TakeItem(item)
				hero:ModifyAgility(stat_gain)
				hero:ModifyStrength(stat_gain)
				hero:ModifyIntellect(stat_gain)
				if is_saved then
					Notifications:Top(keys.playerid, {text="Gained +"..stat_gain.." to all stats from Saved Ballista Neutral! (max 8 charges from Saved Ballista)", style={color="yellow"}, duration=6})
					
				else
					Notifications:Top(keys.playerid, {text="Gained +"..stat_gain.." to all stats from Ballista Neutral!", style={color="yellow"}, duration=6})
				end
			else
				-- Check for item_custom_ballista only in main inventory slots (0-5)
				for i = 0, 5 do
					local inv_item = hero:GetItemInSlot(i)
					if inv_item and inv_item:GetName() == "item_custom_ballista" then
						local is_saved = false
						if (inv_item._is_saved_ballista == true) or (_G.saved_ballista_items and _G.saved_ballista_items[keys.playerid] == inv_item) then
							is_saved = true
						end
						local charges = inv_item:GetCurrentCharges()
						if is_saved then
							charges = math.min(charges, 8)
						end
						local stat_gain = charges * 5
						hero:TakeItem(inv_item)
						hero:ModifyAgility(stat_gain)
						hero:ModifyStrength(stat_gain)
						hero:ModifyIntellect(stat_gain)
						if is_saved then
							Notifications:Top(keys.playerid, {text="Gained +"..stat_gain.." to all stats from Saved Ballista! (max 9 charges)", style={color="yellow"}, duration=6})
							
						else
							Notifications:Top(keys.playerid, {text="Gained +"..stat_gain.." to all stats from Ballista!", style={color="yellow"}, duration=6})
						end
						break
					end
				end
			end
		end				
	end

	if keys.text == "-sellstone" then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
		local Item = hero:GetItemInSlot(16)
		local plyID = keys.playerid
		if hero:IsAlive() and IsValidEntity(hero) then
			if Item ~= nil and IsValidEntity(Item) then
				if Item:GetName() == "item_philosophers_stone" then
					local gold = 0
					if time < 4 then
						--hero:RemoveItem(Item)
						hero:TakeItem(Item)
						hero:ModifyGold(10000, true, 0)
						gold = 10000
					else
						--hero:RemoveItem(Item)
						hero:TakeItem(Item)
						hero:ModifyGold(5000, true, 0)	
						gold = 5000
					end	
					Notifications:Top(plyID, {text="Sold Philosophers stone for "..gold .."  gold after ".. time .. " minutes" , style={color="yellow"}, duration=12})
				end
			end
		end				
	end






	if keys.text == "-double" and not self._doubleMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._doubleMode = true
		Notifications:TopToAll({text="#game_mode_double_monsters_enabled", style={color="yellow"}, duration=5})
	end
	if keys.text == "-goldbags" then
		if not _G._no_gold_bags then
			_G._no_gold_bags = true
			Notifications:TopToAll({text="Gold will be divided directly among connected playes", style={color="green"}, duration=7})
		else
			_G._no_gold_bags = false
			Notifications:TopToAll({text="Gold will be given as dropped GoldBags", style={color="yellow"}, duration=7})			
		end	
	end
	if keys.text == "-weapon_fragment" and keys.playerid == 0 then
		if not _G._sell_slayer_fragmets then
			_G._sell_slayer_fragmets = true
			Notifications:TopToAll({text="Weapon Fragments will go directly to shop stock instead of players inventory", style={color="green"}, duration=7})
		else
			_G._sell_slayer_fragmets = false
			Notifications:TopToAll({text="Weapon Fragments reverted to normal drop", style={color="yellow"}, duration=7})			
		end	
	end
	if keys.text == "-alt_random" and keys.playerid == 0 then
		if not _G._second_random_op then
			_G._second_random_op = true
			Notifications:TopToAll({text="Alternative Random for Learning random skills(Default)", style={color="green"}, duration=7})
		else
			_G._second_random_op = false
			Notifications:TopToAll({text="Vanila Random for Learning random skills(old version)", style={color="yellow"}, duration=7})			
		end	
	end	

	if keys.text == "-single" and not self._singleMode and keys.playerid == 0 then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if player_count == 1 then
			self._singleMode = true
			mHackGameMode:GM_SinglePlayer()
			_CreateFakeCourier2(hero)
			hero:AddItemByName("item_resurection_pendant")
			Notifications:TopToAll({text="#game_mode_single_player", style={color="yellow"}, duration=5})
		end
	end
--[[ 	if keys.text == "-endgame" and keys.playerid == 0 and time < 4 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
       	GameRules:SetSafeToLeave(true)
        end_screen_setup(true)
	end ]]
	


	if keys.text == "-refresh" then
		self._physdamage[keys.playerid] = 1
		self._magdamage[keys.playerid] = 1
		self._puredamage[keys.playerid] = 1
	end

	if keys.text == "-renew" then
		-- CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerid), "delete", {})
		-- for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		-- 	if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
		-- 		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerid), "game_begin", {name = PlayerResource:GetSelectedHeroName(playerID), id = playerID})
		-- 	end
		-- end
		self:RenewDamageUI(keys.playerid)
	end

	if keys.text == "-kill" then
		local playerID = keys.playerid
		self:CC_Kill(playerID)
	end

	local playerID = keys.playerid
	local player = PlayerResource:GetSelectedHeroEntity(playerID)
	if keys.text == "-killmepls" and player:HasModifier("modifier_inf_aegis") then
		self:Suicider(playerID)
	end

	
	if keys.text == "-SS" then
		if not _G.super_courier[keys.playerid] then
			_G.super_courier[keys.playerid] = true
			Notifications:RemoveTop(keys.playerid, 1)
			Notifications:Top(keys.playerid, {text="Super Scepter for non-heroes enabled", duration=3, style={color="green"}, continue=false})
		else
			_G.super_courier[keys.playerid] = false
			Notifications:RemoveTop(keys.playerid, 1)
			Notifications:Top(keys.playerid, {text="Super Scepter for non-heroes disabled", duration=3, style={color="red"}, continue=false})
		end
	end

	if keys.text == "-gon" and self.gon and not self.spawned_gon and keys.playerid == 0 then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if player_count == 1 then
			self.gon = false
			hero:AddItemByName("item_philosophers_stone2")
			Notifications:TopToAll({text="Helper Unit Disabled", style={color="yellow"}, duration=6})
		end
	end

	if keys.text == "-demo" or keys.text == "-демо" and Cheats:IsEnabled() then
		if _G.Demo_UI == false then
			CustomUI:DynamicHud_Create(-1, "Custom_Demo_UI", "file://{resources}/layout/custom_game/hud_workshop_testbed.xml", {})
			_G.Demo_UI = true
		else
			CustomUI:DynamicHud_Destroy(-1, "Custom_Demo_UI")
			_G.Demo_UI = false

			if self.m_bFreeSpellsEnabled == true then
				self.m_bFreeSpellsEnabled = false
				SendToServerConsole("toggle dota_ability_debug")
			end
			if self.m_bMaxGold == true then
				self.m_bMaxGold = false
			end
			if self.m_bInvulnerabilityEnabled == true then
				for _, Unit in pairs(AllPlayerUnits) do
					Unit:RemoveModifierByName("lm_take_no_damage")
				end
				self.m_bInvulnerabilityEnabled = false
			end
			self.m_nHeroRenderMode = 0
			SendToServerConsole(tostring(string.format("r_hero_debug_render_mode %i", 0)))
		end
	end


	if keys.text == "-challenge" and not self.challenge then
		local plyID = keys.playerid
		if PlayerResource:GetPlayer(0) then
			if plyID ~= 0 then
				return
			end	
		end
		local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
		local unit = "npc_boss_juggernaut_4"
		local name = "Boss"
		if not self._endlessMode_started and count2 < 1 then
			count2 = count2 + 1			
			Notifications:TopToAll({text= "If you challenge boss before Part 2 max reward will be T2 at lvl 150+ then Extra: Chance for item Random Ability (Rare, max 3) based on bonus level. Type Again -challenge if you are sure", style={color="red"}, duration=15})
			return	
		end						
		if 	unit == "npc_boss_juggernaut_4" then
			name = "Juggernaut Sword Master"
		end
		if time < 30 then
			Notifications:TopToAll({text= time .." min, unless at least 30 min have passed you can't Challenge " .. name, style={color="red"}, duration=15})
			count = count + 1
			if count > 8 then
				self.challenge = true	
			end
			return
		end	
		if time > 140 then
			Notifications:TopToAll({text= time .." min Have passed you can't Challenge " .. name.." if More then 140 min have passed", style={color="red"}, duration=15})
			count = count + 1
			if count > 8 then
				self.challenge = true	
			end	
		else

			CreateUnitByName(unit, plyhero:GetAbsOrigin() + RandomVector(RandomFloat(200, 1000)) , true, nil, nil, DOTA_TEAM_BADGUYS)
			Notifications:TopToAll({text="Challenge " .. name.." reach lvl 400(or 150 for part 1) for max(tier 5) reward , then you get a Chance for item Random Ability based on bonus level.", style={color="blue"}, duration=10})
			self.challenge = true
		end	
	end

	if string.find(keys.text, "-effect_rate") and keys.playerid == 0 then
		print("reduce effect rate")		
		local rate_nr = string.custom_remove2(keys.text)
		print(rate_nr)			 
		_G._effect_rate = 100 / rate_nr

		Notifications:TopToAll({text= "Effect rate for some skills reduced by "..rate_nr.." times", style={color="yellow"}, duration=6})
	end

	if string.find(keys.text, "-itemauto1") then
		print("pass")
		local plyID = keys.playerid	
		local slot_nr = string.custom_remove3(keys.text)
		if slot_nr then
			print(slot_nr)
			if slot_nr == 0 then
				_G._itemauto1[keys.playerid] = nil
				Notifications:Top(plyID, {text= "Item Autocast 1 turned OFF", style={color="yellow"}, duration=6})
			else
				_G._itemauto1[keys.playerid] = slot_nr - 1
				Notifications:Top(plyID, {text= "You have set itemAutocast 1 on slot: "..slot_nr, style={color="red"}, duration=6})
			end
			-- Trigger cache update for the autocast modifier
			local hero = PlayerResource:GetSelectedHeroEntity(plyID)
			if hero and hero:HasModifier("modifier_mjz_bristleback_quill_spray_autocast4_5") then
				local modifier = hero:FindModifierByName("modifier_mjz_bristleback_quill_spray_autocast4_5")
				if modifier then
					modifier.needs_slot_update = true
				end
			end
		end		
	end
	if string.find(keys.text, "-itemauto2") then
		print("pass")
		local plyID = keys.playerid	
		local slot_nr = string.custom_remove4(keys.text)
		if slot_nr then
			print(slot_nr)
			if slot_nr == 0 then
				_G._itemauto2[keys.playerid] = nil
				Notifications:Top(plyID, {text= "Item Autocast 2 turned OFF", style={color="yellow"}, duration=6})
			else
				_G._itemauto2[keys.playerid] = slot_nr - 1
				Notifications:Top(plyID, {text= "You have set itemAutocast 2 on slot: "..slot_nr, style={color="red"}, duration=6})
			end
			-- Trigger cache update for the autocast modifier
			local hero = PlayerResource:GetSelectedHeroEntity(plyID)
			if hero and hero:HasModifier("modifier_mjz_bristleback_quill_spray_autocast4_5") then
				local modifier = hero:FindModifierByName("modifier_mjz_bristleback_quill_spray_autocast4_5")
				if modifier then
					modifier.needs_slot_update = true
				end
			end
		end
	end
--itemauto3
	if string.find(keys.text, "-itemauto3") then
		print("pass")
		local plyID = keys.playerid	
		local slot_nr = string.custom_remove5(keys.text)
		if slot_nr then
			print(slot_nr)
			if slot_nr == 0 then
				_G._itemauto3[keys.playerid] = nil
				Notifications:Top(plyID, {text= "Item Autocast 3 turned OFF", style={color="yellow"}, duration=6})
			else
				_G._itemauto3[keys.playerid] = slot_nr - 1
				Notifications:Top(plyID, {text= "You have set itemAutocast 3 on slot: "..slot_nr, style={color="red"}, duration=6})
			end
			-- Trigger cache update for the autocast modifier
			local hero = PlayerResource:GetSelectedHeroEntity(plyID)
			if hero and hero:HasModifier("modifier_mjz_bristleback_quill_spray_autocast4_5") then
				local modifier = hero:FindModifierByName("modifier_mjz_bristleback_quill_spray_autocast4_5")
				if modifier then
					modifier.needs_slot_update = true
				end
			end
		end
	end
--itemauto4
	if string.find(keys.text, "-itemauto4") then
		print("pass")
		local plyID = keys.playerid	
		local slot_nr = string.custom_remove6(keys.text)
		if slot_nr then
			print(slot_nr)
			if slot_nr == 0 then
				_G._itemauto4[keys.playerid] = nil
				Notifications:Top(plyID, {text= "Item Autocast 4 turned OFF", style={color="yellow"}, duration=6})
			else
				_G._itemauto4[keys.playerid] = slot_nr - 1
				Notifications:Top(plyID, {text= "You have set itemAutocast 4 on slot: "..slot_nr, style={color="red"}, duration=6})
			end
			-- Trigger cache update for the autocast modifier
			local hero = PlayerResource:GetSelectedHeroEntity(plyID)
			if hero and hero:HasModifier("modifier_mjz_bristleback_quill_spray_autocast4_5") then
				local modifier = hero:FindModifierByName("modifier_mjz_bristleback_quill_spray_autocast4_5")
				if modifier then
					modifier.needs_slot_update = true
				end
			end
		end
	end
	if keys.text == "-dev_challenge" and keys.playerid == 0 and Cheats:IsEnabled() then
		_G._challenge_bosss = 5
	end
	if keys.text == "-dev_challenge0" and keys.playerid == 0 and Cheats:IsEnabled() then
		_G._challenge_bosss = 0
	end
	if keys.text == "-dev_test_list" and keys.playerid == 0 and Cheats:IsEnabled() then
		GetLeastPlayedHeroes()
	end

	if keys.text == "-dev_scarlet" and keys.playerid == 0 and Cheats:IsEnabled() then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
		local keys_table = {
			caster = hero,
			forced_benefit_id = 1
		}
		LierScarlet_CombineAscendant(keys_table)
	end

	-- scarlet N command with gold cost and item check
	if string.match(keys.text, "^%-scarlet%d*$") or string.match(keys.text, "^%-scarlet%s*%d*$") then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
		local plyID = keys.playerid
		-- Match both "-scarletN" and "-scarlet N"
		local n = string.match(keys.text, "^%-scarlet%s*(%d*)$")
					or string.match(keys.text, "^%-scarlet(%d*)$")
		local benefit_id = tonumber(n)
		local cost = 30000

		if benefit_id and benefit_id >= 1 and benefit_id <= 5 then
			cost = 60000
		else
			benefit_id = 0
		end

		local item_t_name = "item_lier_scarlet_t"
		local item_m_name = "item_lier_scarlet_m"
		local item_b_name = "item_lier_scarlet_b"

		-- Check if player already has the Scarlet Ascendant modifiers
		if hero:HasModifier("modifier_player_lier_scarlet_ascendant_strength_tier") then
			Notifications:Top(plyID, {text="You already have Scarlet Ascendant! Cannot combine again.", style={color="red"}, duration=7})
			return
		end

		if not (hero:HasItemInInventory(item_t_name) and hero:HasItemInInventory(item_m_name) and hero:HasItemInInventory(item_b_name)) then
			Notifications:Top(plyID, {text="You need all 3 Scarlet items (T, M, B) in inventory!", style={color="red"}, duration=5})
			return
		end

		if hero:GetGold() < cost then
			Notifications:Top(plyID, {text="Not enough gold for Scarlet Ascendant! Need "..cost.." gold.", style={color="red"}, duration=5})
			return
		end

		hero:SpendGold(cost, DOTA_ModifyGold_Unspecified)
		local keys_table = {
			caster = hero,
			forced_benefit_id = benefit_id,
			cost = cost
		}
		LierScarlet_CombineAscendant(keys_table)
		local stat_name = ""
		if benefit_id == 1 then
			stat_name = "Strength"
		elseif benefit_id == 2 then
			stat_name = "Agility"
		elseif benefit_id == 3 then
			stat_name = "Intellect"
		elseif benefit_id == 4 then
			stat_name = "Spell Amplification"
		elseif benefit_id == 5 then
			stat_name = "Base Attack"
		else
			stat_name = nil
		end
		if stat_name then
			Notifications:Top(plyID, {text="Scarlet Ascendant used! ("..cost.." gold) "..stat_name.." gets minimum tier 3 roll.", style={color="yellow"}, duration=10})
		else
			Notifications:Top(plyID, {text="Scarlet Ascendant used! ("..cost.." gold)", style={color="yellow"}, duration=5})
		end
	end




	if keys.text == "-commands" and keys.playerid == 0 then
		local commands = "commands before game starts(0:00): <font color='green'>-full</font>(second part enabled), <font color='green'>-normal</font> (has extra bosses and items), <font color='green'>-fullgame</font> (hard and second part)<font color='green'>-hard</font> (has extra bosses and items)<font color='green'>-extra</font> (bosses above lvl 14 will have extra random skills)<font color='green'>-double</font>(2x enemys) <font color='green'>-all</font> (fullgame hard double) , During game: <font color='green'>-goldbags</font>(enable/disable), <font color='green'>-kill</font> (in case you get bugged) <font color='green'>-hide</font> (hide all your passive skills that are max lvl and not on a key bind slot) <font color='green'>-unhide</font>, Host only : <font color='red'>-challenge</font> = sumons a Challenge Boss that you will have to DPS race him for 420 sec. <font color='green'>-effect_rate</font><font color='blue'>number</font>,  number = 1 to 20 , reduce the animation effects rate for some skills. SinglePlayer: <font color='green'>-single</font> = adds an extra courier and gives ancient more regen and armor. <font color='green'>-gon</font> = you will receive a second philosophers stone instead of helper unit" 
		GameRules:SendCustomMessage(commands, 0, 0)
	end
	if keys.text == "-help" and keys.playerid == 0 then
		local commands = "commands before game starts(0:00): <font color='green'>-full</font>(second part enabled), <font color='green'>-normal</font> (has extra bosses and items), <font color='green'>-fullgame</font> (hard and second part)<font color='green'>-hard</font> (has extra bosses and items)<font color='green'>-extra</font> (bosses above lvl 14 will have extra random skills)<font color='green'>-double</font>(2x enemys) <font color='green'>-all</font> (fullgame hard double) , During game: <font color='green'>-goldbags</font>(enable/disable), <font color='green'>-kill</font> (in case you get bugged) <font color='green'>-hide</font> (hide all your passive skills that are max lvl and not on a key bind slot) <font color='green'>-unhide</font>, Host only : <font color='red'>-challenge</font> = sumons a Challenge Boss that you will have to DPS race him for 420 sec. <font color='green'>-effect_rate</font><font color='blue'>number</font>,  number = 1 to 20 , reduce the animation effects rate for some skills. SinglePlayer: <font color='green'>-single</font> = adds an extra courier and gives ancient more regen and armor. <font color='green'>-gon</font> = you will receive a second philosophers stone instead of helper unit" 
		GameRules:SendCustomMessage(commands, 0, 0)
	end	
	if keys.text == "-guessing game" and keys.playerid == 0 then
		Notifications:TopToAll({text= "Hint 1: Combine 2 words that can be found in 2 round titles(part 1 and 2), the second word is all low caps and the first word can be found in normal and hard, up to round 15. Hint 2 : the 2 words can be found in a Siltbreaker round and a bristleback round", style={color="yellow"}, duration=17})
	end			
	if keys.text == "-stalker" then
		local plyID = keys.playerid
		local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
		if IsStalkerList(plyhero) and _G._stalker_chance < 2 then
			_G._stalker_chance = 2
			Notifications:TopToAll({text= "Kuma Slaker chance Doubled", style={color="green"}, duration=6})
		elseif IsStalkerList(plyhero) and _G._stalker_chance == 2 then
			_G._stalker_chance = 1
			Notifications:TopToAll({text= "Kuma Slaker chance Normal", style={color="red"}, duration=6})
		end	
	end	
	if keys.text == "-symbiosis" then
		if IsServer() then
			local plyID = keys.playerid
			local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero():GetUnitName()
			if plyhero and plyhero == "npc_dota_hero_wisp" then
				if count3 > 0 then
					if _G.symbiosisOn then
						_G.symbiosisOn = false
						count3 = count3 - 1
						Notifications:TopToAll({text= "Symbiosis SS Compatibility effect OFF, comands left: " ..count3, style={color="red"}, duration=6})
					else
						_G.symbiosisOn = true
						count3 = count3 - 1
						Notifications:TopToAll({text= "Symbiosis SS Compatibility effect ON, comands left: " ..count3, style={color="green"}, duration=6})
					end
				end
			end	
		end	
	end

	if keys.text == "-reload_buff" then
		if IsServer() then
			local plyID = keys.playerid
			local hero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
			local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero():GetUnitName()
			if plyhero and plyhero == "npc_dota_hero_sniper" then
				if _G.reload_buff then
					_G.reload_buff = false
					hero:AddNewModifier(hero, nil, "modifier_reload_bullet_channel_command", {})
					Notifications:Top(plyID, {text= "Reload Modifier buff is now Shown", style={color="green"}, duration=6})
				else
					_G.reload_buff = true
					if hero:HasModifier("modifier_reload_bullet_channel_command") then
						hero:RemoveModifierByName("modifier_reload_bullet_channel_command")
					end	
					Notifications:Top(plyID, {text= "Reload Modifier buff is now Hidden" , style={color="red"}, duration=6})
				end
			end	
		end	
	end
	if keys.text == "-kardel" then
		if IsServer() then
			local plyID = keys.playerid
			local hero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
			local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero():GetUnitName()
			local lvl = hero:GetLevel()
			if plyhero and plyhero == "npc_dota_hero_sniper" then
				if lvl == 1 and kardel_item then
					hero:AddItemByName("item_to_kardel")
					kardel_item = false
					Notifications:Top(plyID, {text= "Use the item before you level up" , style={color="red"}, duration=6})
				elseif kardel_item then
					Notifications:Top(plyID, {text= "Level to High to use the item" , style={color="red"}, duration=5})
				end
			end	
		end	
	end


	if keys.text == item_trick_1 then
		local plyID = keys.playerid
		local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
		if plyhero then
			local Item = plyhero:GetItemInSlot(7)
			if Item ~= nil and IsValidEntity(Item) then
				if plyhero.Item then
					if IsValidEntity(plyhero.Item) and Item ~= plyhero.Item then
						plyhero:DropItemAtPositionImmediate(plyhero.Item, plyhero:GetAbsOrigin())
					end
				end		
				plyhero.Item = Item
				if plyhero:HasItemInInventory(plyhero.Item:GetName()) then
					plyhero.Item:SetItemState(1)
					local name_item = plyhero.Item:GetName()
					name_item = string.gsub(name_item, "item_", "")
					name_item = string.gsub(name_item, "_", " ")
					Notifications:Top(plyID, {text="Set item ( "..name_item .." ), you can move that to any backpack slot or stash" , style={color="red"}, duration=12})
					Notifications:Top(plyID, {text="Unequip/equip any other item to gain ( "..name_item .." ) stats" , style={color="yellow"}, duration=12})
				end	
			end
		end	
	end

	----test skills ----
	if string.find(keys.text, "-test_skill") and keys.playerid == 0 and Cheats:IsEnabled() then
		print("pass")
		local player = PlayerResource:GetPlayer(keys.playerid)
		--get the hero entity
		local hero = player:GetAssignedHero()
		--get the skill name from the chat text
		local skillName = string.custom_remove7(keys.text)
		--call the add_skill_with_command function with the hero and skill name
		add_skill_with_command(hero, skillName)
	end



end

function add_skill_with_command(hero, skillName)
    --check if the hero is valid
    if hero and hero:IsRealHero() then
        --check if the hero already has the skill
        if not hero:HasAbility(skillName) then
			if hero:IsRealHero() then
				local GenericSlots = 0
				for i = 0, DOTA_MAX_ABILITIES - 1 do
					local abil = hero:GetAbilityByIndex(i)
					if abil then
						if abil:GetAbilityName() == "generic_hidden" then
							GenericSlots = GenericSlots + 1
						end
					end
				end
				if GenericSlots > 0 then
					for i = 0, DOTA_MAX_ABILITIES - 1 do
						local abil = hero:GetAbilityByIndex(i)
						if abil then
							if abil:GetAbilityName() == "generic_hidden" then
								hero:RemoveAbility("generic_hidden")
							end
						end
					end
					if GenericSlots > 1 then
						for i = 1, GenericSlots - 1 do
							hero:AddAbility("generic_hidden")
						end
					end
				end
			end
            --add the skill to the hero
            local newAbility = hero:AddAbility(skillName)
            print("newAbility:" .. skillName)
            --give the hero some ability points and gold
            hero:SetAbilityPoints(hero:GetAbilityPoints() + 5)
            return true
        end
    end
end



function AOHGameMode:OnPlayerConnect(keys)
	--print('PlayerConnect')
	-- PrintTable(keys)
	local plyID = keys.PlayerID
	if plyID then
		local ply = PlayerResource:GetPlayer(plyID)
		
		self:RenewDamageUI(plyID)
	end
end

--[[ function AOHGameMode:OnPlayerReconnect(keys)	
	print ( 'OnPlayerReconnect' )
	-- PrintTable(keys)
	local plyID = keys.PlayerID
	local ply = PlayerResource:GetPlayer(plyID)
	print("P" .. plyID .. " reconnected.")
	local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
	ply.disconnected = false
	
	self:RenewDamageUI(plyID)
	self:RecountPlayers()
end
function AOHGameMode:OnPlayerDisconnect(keys)	
	print ( 'OnPlayerDisconnect' )
	-- PrintTable(keys)
	--local plyID = keys.PlayerID
	--local ply = PlayerResource:GetPlayer(plyID)
	--print("P" .. plyID .. " disconnected.")
	--local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
	--ply.disconnected = false
	
	self:RecountPlayers()
end ]]

--test
-- Constants
local TARGET_STEAM_ID = "76561198080757809"

function AOHGameMode:OnPlayerReconnect(keys)	
	print('OnPlayerReconnect')
	local plyID = keys.PlayerID
	local ply = PlayerResource:GetPlayer(plyID)
	print("P" .. plyID .. " reconnected.")
	local plyhero = ply:GetAssignedHero()
	--ply.disconnected = false

	-- Check if the reconnected player's Steam ID matches the target Steam ID
	local steamID = tostring(PlayerResource:GetSteamID(plyID))
	if steamID == TARGET_STEAM_ID then
		_G.extra_ally = 0
		print("Target player reconnected. _G.extra_ally set to 0.")
	end
	
	self:RenewDamageUI(plyID)
	self:RecountPlayers()
end

function AOHGameMode:OnPlayerDisconnect(keys)	
	print('OnPlayerDisconnect')
	local plyID = keys.PlayerID
	local ply = PlayerResource:GetPlayer(plyID)
	print("P" .. plyID .. " disconnected.")
	local plyhero = ply:GetAssignedHero()
	--ply.disconnected = true

	-- Check if the disconnected player's Steam ID matches the target Steam ID
	local steamID = tostring(PlayerResource:GetSteamID(plyID))
	if steamID == TARGET_STEAM_ID then
		_G.extra_ally = 2
		print("Target player disconnected. _G.extra_ally set to 2.")
	end
	
	self:RecountPlayers()
end
--end test



function AOHGameMode:RenewDamageUI(playerid)
	local nNewState = GameRules:State_Get()

	if nNewState ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then	 -- 游戏开始
		return false
	end

	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerid), "delete", {})
	for pid = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(pid) and PlayerResource:HasSelectedHero(pid) then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerid), "game_begin", {
				name = PlayerResource:GetSelectedHeroName(pid), 
				id = pid
			})
		end
	end
end

-- 刷新所以玩家的伤害统计UI
function AOHGameMode:RenewAllPlayerDamageUI()
	local now = GameRules:GetGameTime()
	if self._prev_renew_all == nil then
		self._prev_renew_all = now
		return 
	end

	if (now - self._prev_renew_all) < 30 then
		return
	else
		self._prev_renew_all = now
	end

	-- CustomGameEventManager:Send_ServerToAllClients("delete", {})
	-- for playerID = 0, 4 do
	-- 	if PlayerResource:IsValidPlayerID(playerID) then
	-- 		if PlayerResource:HasSelectedHero(playerID) then
	-- 			CustomGameEventManager:Send_ServerToAllClients("game_begin", {name = PlayerResource:GetSelectedHeroName(playerID), id = playerID})
	-- 			-- self:RenewDamageUI(playerID)
	-- 		end
	-- 	end
	-- end
end

function AOHGameMode:CC_Kill( playerID )
	if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		local isAlive = hero:IsAlive()

		if not IsInToolsMode()then

			local now = GameRules:GetGameTime()
			local interval = 250
			if Cheats:IsEnabled() then
				interval = 1
				print("CC_Kill cheats: " .. playerID)
			end			
			hero._command_kill = hero._command_kill or 0
			if (now - hero._command_kill) < interval then
				return false
			else
				hero._command_kill = now
			end
		else
			print("CC_Kill toolsmode: " .. playerID)	
		end	

		-- if isAlive then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			local rezPosition = hero:GetAbsOrigin()
			hero:RespawnHero(false, false)
			hero:SetAbsOrigin(rezPosition)
			Timers:CreateTimer({
				endTime = 0.15, 
				callback = function()
					hero:ForceKill(false)
				end
			})
			--if hero:HasModifier( "modifier_item_plain_ring_perma_invincibility" ) then
			--	hero:RemoveModifierByName( "modifier_item_plain_ring_perma_invincibility" )
			--	hero:SetAbsOrigin(rezPosition)
			--	hero:ForceKill(false)
			--end
			Timers:CreateTimer({
				endTime = 7, 
				callback = function()
					hero:ForceKill(false)
				end
			})
		-- else
		-- 	local nSearchRange = 1000
		-- 	local hEnemies = FindUnitsInRadius( hero:GetTeamNumber(), hero:GetOrigin(), nil, nSearchRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
		-- 	if #hEnemies > 0 then
		-- 		-- return false
		-- 	end
		-- 	local vLocation = hero:GetOrigin()
		-- 	hero:RespawnHero( false, false )
		-- 	hero:RespawnUnit()
		-- 	FindClearSpaceForUnit( hero, vLocation, true )
		-- end
	end
end
function AOHGameMode:Suicider(playerID)
	if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		local isAlive = hero:IsAlive()
		local rezPosition = hero:GetAbsOrigin()
		if isAlive then
			local ring_cd = hero:FindModifierByName("modifier_ring_perma_invincibility_cd")
			if ring_cd and ring_cd:GetStackCount() < 1 then
				ring_cd:SetStackCount(1)
			end
			Timers:CreateTimer(FrameTime(), function() hero:ForceKill(false) end)
		end
	end
end
