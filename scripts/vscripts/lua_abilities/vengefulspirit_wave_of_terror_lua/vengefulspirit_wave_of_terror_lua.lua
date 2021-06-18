vengefulspirit_wave_of_terror_lua = class({})
LinkLuaModifier("modifier_wave_of_terror_armor_reduction", "lua_abilities/vengefulspirit_wave_of_terror_lua/vengefulspirit_wave_of_terror_lua", LUA_MODIFIER_MOTION_NONE)


function vengefulspirit_wave_of_terror_lua:OnSpellStart()
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection = vDirection:Normalized()

	self.wave_speed = self:GetSpecialValueFor("wave_speed")
	self.wave_width = self:GetSpecialValueFor("wave_width")
	self.vision_aoe = self:GetSpecialValueFor("vision_aoe")
	self.vision_duration = self:GetSpecialValueFor("vision_duration")
	self.duration = self:GetSpecialValueFor("duration")
	self.wave_damage = self:GetSpecialValueFor("wave_damage") + (self:GetSpecialValueFor("damage_agi_multiplier") + talent_value(self:GetCaster(), "special_bonus_unique_wave_of_terror_dmg")) * self:GetCaster():GetAgility()

	local info = {
		EffectName = "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		fStartRadius = self.wave_width,
		fEndRadius = self.wave_width,
		vVelocity = vDirection * self.wave_speed,
		fDistance = self:GetCastRange(self:GetCaster():GetOrigin(), self:GetCaster()),
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		bProvidesVision = true,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iVisionRadius = self.vision_aoe,
	}
	self.flVisionTimer = self.wave_width / self.wave_speed
	self.flLastThinkTime = GameRules:GetGameTime()
	self.nProjID = ProjectileManager:CreateLinearProjectile(info)
	ProjectileManager:CreateLinearProjectile(info)
	EmitSoundOn("Hero_VengefulSpirit.WaveOfTerror", self:GetCaster())
end
function vengefulspirit_wave_of_terror_lua:OnProjectileThink(vLocation)
	self.flVisionTimer = self.flVisionTimer - (GameRules:GetGameTime() - self.flLastThinkTime)

	if self.flVisionTimer <= 0.0 then
		local vVelocity = ProjectileManager:GetLinearProjectileVelocity(self.nProjID)
		AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation + vVelocity * (self.wave_width / self.wave_speed), self.vision_aoe, self.vision_duration, false)
		self.flVisionTimer = self.wave_width / self.wave_speed
	end
end
function vengefulspirit_wave_of_terror_lua:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil then
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.wave_damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self,
		}
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_wave_of_terror_armor_reduction", {duration = self.duration})
		ApplyDamage(damage)
	end
	return false
end

--------------------------------------------------------------------------------
modifier_wave_of_terror_armor_reduction = class({})
function modifier_wave_of_terror_armor_reduction:IsDebuff() return true end
function modifier_wave_of_terror_armor_reduction:IsPurgable() return false end
function modifier_wave_of_terror_armor_reduction:GetEffectName()
	return "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf"
end
function modifier_wave_of_terror_armor_reduction:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_wave_of_terror_armor_reduction:OnCreated()
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction") - math.floor(self:GetAbility():GetSpecialValueFor("armor_agi_multiplier") / 100 * self:GetCaster():GetAgility()) + talent_value(self:GetCaster(), "special_bonus_unique_vengeful_spirit_4")
end
function modifier_wave_of_terror_armor_reduction:OnRefresh()
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction") - math.floor(self:GetAbility():GetSpecialValueFor("armor_agi_multiplier") / 100 * self:GetCaster():GetAgility()) + talent_value(self:GetCaster(), "special_bonus_unique_vengeful_spirit_4")
end
function modifier_wave_of_terror_armor_reduction:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_wave_of_terror_armor_reduction:GetModifierPhysicalArmorBonus(params)
	return self.armor_reduction
end
