modifier_aoh_spawn_recovery = class({})

function modifier_aoh_spawn_recovery:IsHidden() return true end
function modifier_aoh_spawn_recovery:IsPurgable() return false end
function modifier_aoh_spawn_recovery:RemoveOnDeath() return false end
function modifier_aoh_spawn_recovery:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_aoh_spawn_recovery:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_RESPAWN,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

local function SpawnProtectionValue(self)
	if not IsServer() then return 0 end
	-- Cover the engine's return to life until the visible spawn buff is applied.
	local hero = self:GetParent()
	local spawn = hero.aohSpawnProtection
	local gameMode = GameRules.GameMode
	return spawn and spawn.reincarnating and gameMode and gameMode:IsSpawnDamageProtected(hero) and 1 or 0
end

modifier_aoh_spawn_recovery.GetAbsoluteNoDamagePhysical = SpawnProtectionValue
modifier_aoh_spawn_recovery.GetAbsoluteNoDamageMagical = SpawnProtectionValue
modifier_aoh_spawn_recovery.GetAbsoluteNoDamagePure = SpawnProtectionValue
modifier_aoh_spawn_recovery.GetMinHealth = SpawnProtectionValue

function modifier_aoh_spawn_recovery:OnRespawn(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then return end
	GameRules.GameMode:RunSpawnCallback("ArmSpawnProtection", keys.unit, true)
end

function modifier_aoh_spawn_recovery:OnDeath(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then return end
	local reincarnating = keys.reincarnate
	if reincarnating ~= nil then reincarnating = reincarnating == true or reincarnating == 1 end
	GameRules.GameMode:RunSpawnCallback("TrySpawnRecovery", keys.unit, reincarnating)
end
