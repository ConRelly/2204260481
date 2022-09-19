require("lib/string")
local count = 0
local count2 = 0
local count3 = 4
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
		Notifications:TopToAll({text="#dota_npc_does_ab", style={color="red"}, duration=7})
		self._physdanage = true
		self:_RenewStats()
	end
	if keys.text == "-dev_guessing_game" and Cheats:IsEnabled() then
		self._physdanage = true
		self:_RenewStats()	
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
				hero:AddItemByName("item_enchanter")
				Notifications:TopToAll({text="Removed multi autocast and restored Enchanter", style={color="yellow"}, duration=3})				 
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
	
	if keys.text == "-ballista" then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
		local Item = hero:GetItemInSlot(16)
		if hero:IsAlive() and IsValidEntity(hero) then
			if Item ~= nil and IsValidEntity(Item) then
				if Item:GetName() == "item_custom_ballista" then
					local charges = Item:GetCurrentCharges() * 5
					hero:RemoveItem(Item)
					hero:ModifyAgility(charges)
					hero:ModifyStrength(charges)
					hero:ModifyIntellect(charges)
				end
			end
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
	
		local playerID = hero:GetPlayerID()
		local player = hero:GetPlayerOwner()
		-- local courier = PlayerResource:GetNthCourierForTeam(playerID, DOTA_TEAM_GOODGUYS) 
	
		
	end


	if keys.text == "-double" and not self._doubleMode and keys.playerid == 0 and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		self._doubleMode = true
		Notifications:TopToAll({text="#game_mode_double_monsters_enabled", style={color="yellow"}, duration=5})
	end

	if keys.text == "-single" and not self._singleMode and keys.playerid == 0 then
		local player_count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
		local playerID = keys.playerid
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if player_count == 1 then
			self._singleMode = true
			mHackGameMode:GM_SinglePlayer()
			_CreateFakeCourier2(hero)
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


	if keys.text == "-challenge" and keys.playerid == 0 and not self.challenge then--     --
		local plyID = keys.playerid
		local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
		local unit = "npc_boss_juggernaut_4"
		local name = "Boss"
		if not self._endlessMode_started and count2 < 1 then
			count2 = count2 + 1			
			Notifications:TopToAll({text= "If you challenge boss before Part 2 max reward will be T2 at lvl 150+. Type Again -challenge if you are sure", style={color="red"}, duration=15})
			return	
		end						
		if 	unit == "npc_boss_juggernaut_4" then
			name = "Juggernaut Sword Master"
		end
		if time < 40 then
			Notifications:TopToAll({text= time .." min, unless at least 40 min have passed you can't Challenge " .. name, style={color="red"}, duration=15})
			count = count + 1
			if count > 8 then
				self.challenge = true	
			end
			return
		end	
		if time > 100 then
			Notifications:TopToAll({text= time .." min Have passed you can't Challenge " .. name.." if More then 100 min have passed", style={color="red"}, duration=15})
			count = count + 1
			if count > 8 then
				self.challenge = true	
			end	
		else

			CreateUnitByName(unit, plyhero:GetAbsOrigin() + RandomVector(RandomFloat(200, 1000)) , true, nil, nil, DOTA_TEAM_BADGUYS)
			Notifications:TopToAll({text="Challenge " .. name.." reach lvl 190(or 150 for part 1) for max reward ", style={color="blue"}, duration=10})
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

	if keys.text == "-dev_challenge" and keys.playerid == 0 and Cheats:IsEnabled() then
		_G._challenge_bosss = 5
	end
	if keys.text == "-dev_challenge0" and keys.playerid == 0 and Cheats:IsEnabled() then
		_G._challenge_bosss = 0
	end

	if keys.text == "-commands" and keys.playerid == 0 then
		local commands = "commands before game starts(0:00): <font color='green'>-full</font>(second part enabled), <font color='green'>-normal</font> (has extra bosses and items), <font color='green'>-fullgame</font> (hard and second part)<font color='green'>-hard</font> (has extra bosses and items)<font color='green'>-extra</font> (bosses above lvl 14 will have extra random skills)<font color='green'>-double</font>(2x enemys) <font color='green'>-all</font> (fullgame hard double) , During game: <font color='green'>-kill</font> (in case you get bugged) <font color='green'>-hide</font> (hide all your passive skills that are max lvl and not on a key bind slot) <font color='green'>-unhide</font>, Host only : <font color='red'>-challenge</font> = sumons a Challenge Boss that you will have to DPS race him for 420 sec. <font color='green'>-effect_rate</font><font color='blue'>number</font>,  number = 1 to 20 , reduce the animation effects rate for some skills. SinglePlayer: <font color='green'>-single</font> = adds an extra courier and gives ancient more regen and armor. <font color='green'>-gon</font> = you will receive a second philosophers stone instead of helper unit" 
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
		local plyID = keys.playerid
		local plyhero = PlayerResource:GetPlayer(plyID):GetName()
		if plyhero and plyhero == "npc_dota_hero_wisp" then
			if count3 > 0 then
				if _G.symbiosisOn then
					_G.symbiosisOn = false
					count3 = count3 - 1
					Notifications:TopToAll({text= "Symbiosis SS effect OFF, comands left: " ..count3, style={color="red"}, duration=6})
				else
					_G.symbiosisOn = true
					count3 = count3 - 1
					Notifications:TopToAll({text= "Symbiosis SS effect ON, comands left: " ..count3, style={color="red"}, duration=6})
				end
			end
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

function AOHGameMode:OnPlayerReconnect(keys)	
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
end

-- 伤害统计UI
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

		if not IsInToolsMode() then
			local now = GameRules:GetGameTime()
			local interval = 250 * 1
			hero._command_kill = hero._command_kill or 0
			if (now - hero._command_kill) < interval then
				return false
			else
				hero._command_kill = now
			end
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

