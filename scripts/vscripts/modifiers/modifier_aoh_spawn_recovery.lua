modifier_aoh_spawn_recovery = class({})

function modifier_aoh_spawn_recovery:IsHidden() return true end
function modifier_aoh_spawn_recovery:IsPurgable() return false end
function modifier_aoh_spawn_recovery:RemoveOnDeath() return false end
function modifier_aoh_spawn_recovery:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_aoh_spawn_recovery:DeclareFunctions()
	return {MODIFIER_EVENT_ON_RESPAWN, MODIFIER_EVENT_ON_DEATH}
end

function modifier_aoh_spawn_recovery:OnRespawn(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then return end
	GameRules.GameMode:RunSpawnCallback("ArmSpawnProtection", keys.unit, true)
end

function modifier_aoh_spawn_recovery:OnDeath(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then return end
	GameRules.GameMode:RunSpawnCallback("TrySpawnRecovery", keys.unit, keys.reincarnate == true or keys.reincarnate == 1)
end
