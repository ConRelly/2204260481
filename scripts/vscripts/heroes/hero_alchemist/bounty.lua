
function GiveGoldToPlayers(keys)	
 	local gameTime = math.floor(GameRules:GetGameTime()/60)
	local baseGold = keys.ability:GetSpecialValueFor("base_gold")
	local goldPerMin = keys.ability:GetSpecialValueFor("gold_per_min")
	local gold = baseGold + gameTime*goldPerMin 
	
	GiveGoldPlayers(gold)
end
