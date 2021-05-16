require("lib/chat_handler")
function HackGameMode:OnPlayerChat(keys)
	
	if keys.text == "-dummy" and keys.playerid == 0 and Cheats:IsEnabled() and not self._dummy and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        self:_CreateDummyTarget(false, 2)
		Notifications:TopToAll({text="Create Invis Dummy On Spawn", style={color="blue"}, duration=5})

	end

	if keys.text == "-rumy" and keys.playerid == 0 and Cheats:IsEnabled() and not self._dummy and GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        self:_CreateDummyTarget(false, 2)
		Notifications:TopToAll({text="Create Invis Dummy On Spawn", style={color="blue"}, duration=5})

	end
	if keys.text == "-asd" and keys.playerid == 0 and Cheats:IsEnabled() then
		local plyID = keys.playerid
		local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
		local skip = 0.2
		local unit = "npc_bristle_large"		
		for n = 1, 20 do	
            Timers:CreateTimer({
				endTime = skip, 
				callback = function()
					CreateUnitByName(unit, plyhero:GetAbsOrigin() + RandomVector(RandomFloat(200, 1000)) , true, nil, nil, DOTA_TEAM_BADGUYS)
				end
			})			
			skip = skip + 0.1
		end
		Notifications:TopToAll({text="Create " .. unit, style={color="blue"}, duration=5})
	end
end