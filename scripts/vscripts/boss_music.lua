

if BossMusic == nil then
	_G.BossMusic = class({})
end


function BossMusic:InitGameMode()

	--ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
--	ListenToGameEvent("npc_spawned",Dynamic_Wrap( self, 'OnNPCSpawned' ), self )
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
end








function BossMusic:OnEntityKilled(keys)

	local unit = EntIndexToHScript(keys.entindex_killed)
	if unit:GetUnitLabel() == "npc_dota_boss_aghanim" then
		Sounds:RemoveGlobalLoopingSound("monkey_king")
	end
end

BossMusic:InitGameMode()