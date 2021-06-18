vengefulspirit_magic_missile_lua = class({})

--------------------------------------------------------------------------------
-- AOE Radius
function vengefulspirit_magic_missile_lua:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
--------------------------------------------------------------------------------
function vengefulspirit_magic_missile_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = target:GetOrigin()
	local search = self:GetSpecialValueFor("radius")
	targets = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		target,	-- handle, cacheUnit. (not known)
		search,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(targets) do
		local info = {
			EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
			Ability = self,
			iMoveSpeed = self:GetSpecialValueFor("magic_missile_speed"),
			Source = caster,
			Target = enemy,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end
	EmitSoundOn("Hero_VengefulSpirit.MagicMissile", caster)
end

--------------------------------------------------------------------------------

function vengefulspirit_magic_missile_lua:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and (not hTarget:IsInvulnerable()) and (not hTarget:TriggerSpellAbsorb(self)) and (not hTarget:IsMagicImmune()) then
		EmitSoundOn("Hero_VengefulSpirit.MagicMissileImpact", hTarget)
		local magic_missile_stun = self:GetSpecialValueFor("magic_missile_stun")
		local magic_missile_damage = self:GetSpecialValueFor("magic_missile_damage") + self:GetSpecialValueFor("agi_multiplier") * self:GetCaster():GetAgility()

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = magic_missile_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage(damage)
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = magic_missile_stun})
	end

	return true
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
