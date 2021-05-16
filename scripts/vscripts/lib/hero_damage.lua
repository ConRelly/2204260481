
if HeroDamageStat == nil then
    _G.HeroDamageStat = class({
        _magdamage = {}, _physdamage = {}, _puredamage = {}, _damagecount = {},
    })
    _G.HeroDamageStat.GLOBAL_PLAYER_DATA = {}
end

function HeroDamageStat:InitGameMode( )
    
end

function HeroDamageStat:OnUpdateThink( )
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(playerID) then
            local heroName = PlayerResource:GetSelectedHeroName(playerID)
			CustomGameEventManager:Send_ServerToAllClients("hero_damage", {id = playerID, name = heroName, damage_type = "mage", damage_table = self._magdamage[playerID] })
			CustomGameEventManager:Send_ServerToAllClients("hero_damage", {id = playerID, name = heroName, damage_type = "phys", damage_table = self._physdamage[playerID] })
			CustomGameEventManager:Send_ServerToAllClients("hero_damage", {id = playerID, name = heroName, damage_type = "pure", damage_table = self._puredamage[playerID] })
        end
    end
end

function HeroDamageStat:OnDamageDealt(playerID, damageTable)
    local attacker_index = damageTable.entindex_attacker_const
	local victim_index = damageTable.entindex_victim_const
	if attacker_index and victim_index then
        local attacker = EntIndexToHScript(attacker_index)
        local victim = EntIndexToHScript(victim_index)
        if attacker and victim then
			if attacker.GetPlayerOwnerID then
				local attackerPlayerId = attacker:GetPlayerOwnerID()
                if victim and victim:GetDayTimeVisionRange() ~= 1337 then   -- ~= npc_conduit
                    if attackerPlayerId and attackerPlayerId >= 0 and attacker:IsOpposingTeam(victim:GetTeam()) then
                        local ability = nil
                        if damageTable.entindex_inflictor_const then
                            ability = EntIndexToHScript(damageTable.entindex_inflictor_const)
                        end
                        self:ModifyDamage(attackerPlayerId, damageTable.damagetype_const, damageTable.damage, ability)
                    end
                end
            end
        end
    end
end

function HeroDamageStat:ModifyDamage(playerID, damagetype, damage, ability)
    local inflictor = "other"
    if ability then
        inflictor = ability:GetName()  -- ITEM: item_
        -- print("Damage Ability: " .. ability:GetName())
    end  

    if damagetype == DAMAGE_TYPE_MAGICAL then
        self._magdamage[playerID] = self._magdamage[playerID] or {}
        self._magdamage[playerID][inflictor] = self._magdamage[playerID][inflictor] or 0
        self._magdamage[playerID][inflictor] = self._magdamage[playerID][inflictor] + damage
    elseif damagetype == DAMAGE_TYPE_PHYSICAL then
        if inflictor == "other" then
            inflictor = "attack"
        end

        self._physdamage[playerID] = self._physdamage[playerID] or {}
        self._physdamage[playerID][inflictor] = self._physdamage[playerID][inflictor] or 0
        self._physdamage[playerID][inflictor] = self._physdamage[playerID][inflictor] + damage
    else
        self._puredamage[playerID] = self._puredamage[playerID] or {}
        self._puredamage[playerID][inflictor] = self._puredamage[playerID][inflictor] or 0
        self._puredamage[playerID][inflictor] = self._puredamage[playerID][inflictor] + damage
    end

      
end

function HeroDamageStat:SetValue(playerID, key, value)
    local data = self.GLOBAL_PLAYER_DATA[playerID]
    if not data then
        self.GLOBAL_PLAYER_DATA[playerID] = {}
        data = self.GLOBAL_PLAYER_DATA[playerID]
    end
    if not data.values then 
        data.values = {} 
    end
	data.values[key] = value
end

function HeroDamageStat:GetValue(playerID, key)
    local data = self.GLOBAL_PLAYER_DATA[playerID]
    if data then
        local values = data.values
        if values then
            local value = values[key]
            if value then
                return value
            end
        end
    end
	return 0
end

function HeroDamageStat:ModifyValue(playerID, key, value)
	local new_value = self:GetValue(playerID, key) + value
    self:SetValue(playerID, key, new_value)
	return new_value
end


if GameRules.gHeroDamage == nil then
    GameRules.gHeroDamage = HeroDamageStat()
    _G.gHeroDamage = GameRules.gHeroDamage
end
