
function HackGameMode:_RegisterCommand( )
    -- Custom console commands
	Convars:RegisterCommand( "test_func", function(...) return print( ... ) end, "Test Function.", FCVAR_CHEAT )
    
    Convars:RegisterCommand( "mjz_win", function(command) 
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
        GameRules:SetSafeToLeave(true)
        end_screen_setup(true)
    end, "mjz_win", FCVAR_CHEAT )

	Convars:RegisterCommand( "mjz_hero_point", function(command) 
        print_all_hero_point()
    end, "mjz_hero_point", FCVAR_CHEAT )

    Convars:RegisterCommand( "mjz_hero_all_modifiers", function(command) 
        print_hero_all_modifiers()
    end, "mjz_hero_all_modifiers", FCVAR_CHEAT )

    Convars:RegisterCommand( "mjz_hero_base_attack_time", function(command) 
        print_hero_base_attack_time()
    end, "mjz_hero_base_attack_time", FCVAR_CHEAT )
    
    Convars:RegisterCommand( "mjz_clear_tree", function(command) 
        local point = PlayerInstanceFromIndex(1):GetAssignedHero():GetAbsOrigin()
        local radius = 1000
        GridNav:DestroyTreesAroundPoint( point, radius, false )        
    end, "mjz_clear_tree", FCVAR_CHEAT )

    Convars:RegisterCommand( "mjz_show_modifier", function(command, modifier_name) 
        local hero = PlayerInstanceFromIndex(1):GetAssignedHero()
        local modifier = hero:FindModifierByName(modifier_name)
        if modifier then
            print('Show Modifier: '..modifier_name)
            for k,v in pairs(modifier) do
                print("    ",k,v)
            end
        end
    end, "mjz_show_modifier", FCVAR_CHEAT )

    Convars:RegisterCommand( "mjz_show_ability", function(command, ability_name) 
        local hero = PlayerInstanceFromIndex(1):GetAssignedHero()
        local ability = hero:FindAbilityByName(ability_name)
        if ability then
            print('Show Ability: '..ability_name)
            for k,v in pairs(ability) do
                print("    ",k,v)
            end
        end
    end, "mjz_show_ability", FCVAR_CHEAT )
    
    Convars:RegisterCommand( "mjz_hero_show_item", function(command, ability_name) 
        local hero = PlayerInstanceFromIndex(1):GetAssignedHero()
        for i=0,99 do
            local ability = hero:GetItemInSlot(i)
            if ability then
                print('Show Item ' .. i .. " :" .. ability:GetName())
            end
        end
	end, "mjz_hero_show_item", FCVAR_CHEAT )
	
	Convars:RegisterCommand( "mjz_holdout_start", function(command, ability_name) 
        if not HOLDOUT_ENABLED then
			ActivateCHoldoutGameMode()
		end
    end, "mjz_holdout_start", FCVAR_CHEAT )


    Convars:RegisterCommand( "mjz_hero_god", function(command, ability_name) 
        CallAllHeroFunc(function ( hero )
            hero:AddNewModifier(hero, nil, "modifier_mjz_god", {})
        end)
    end, "mjz_hero_god", FCVAR_CHEAT )

    
end

