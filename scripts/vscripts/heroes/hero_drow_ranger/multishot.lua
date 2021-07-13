LinkLuaModifier("modifier_dr_multishot", "heroes/hero_drow_ranger/multishot", LUA_MODIFIER_MOTION_NONE)

---------------
-- Multishot --
---------------
dr_multishot = dr_multishot or class({})
function dr_multishot:OnSpellStart()
	self.targets_hit = {}
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_dr_multishot", {duration = self:GetChannelTime()})
end

function dr_multishot:OnChannelFinish(bInterrupted)
	self:GetCaster():RemoveModifierByName("modifier_dr_multishot")
end

function dr_multishot:OnProjectileHit_ExtraData(target, location, ExtraData)
	if not self.targets_hit[ExtraData.volley_index] then
		self.targets_hit[ExtraData.volley_index] = {}
	end
		
	if target and not self.targets_hit[ExtraData.volley_index][target:entindex()] then
		target:EmitSound("Hero_DrowRanger.ProjectileImpact")
	
		if self:GetCaster():HasAbility("drow_ranger_frost_arrows_lua") and self:GetCaster():FindAbilityByName("drow_ranger_frost_arrows_lua"):IsTrained() then
			if not target:IsMagicImmune() then
				--if not target:HasModifier("modifier_drow_ranger_frost_arrows_lua")
					target:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("drow_ranger_frost_arrows_lua"), "modifier_drow_ranger_frost_arrows_lua", {duration = self:GetSpecialValueFor("arrow_slow_duration") * (1 - target:GetStatusResistance())})
				--end
			end
		end

		local damage_per_arrow = self:GetCaster():GetAttackDamage() * self:GetSpecialValueFor("arrow_damage_pct") * 0.01
		ApplyDamage({
			victim 			= target,
			damage 			= damage_per_arrow,
			damage_type		= DAMAGE_TYPE_PHYSICAL,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self
		})
		
		self.targets_hit[ExtraData.volley_index][target:entindex()] = true
		return true
	end
end

------------------------
-- Multishot Modifier --
------------------------
modifier_dr_multishot = modifier_dr_multishot or class({})
function modifier_dr_multishot:IsHidden() return true end
function modifier_dr_multishot:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
	self.arrows_per_salvo		= ability:GetSpecialValueFor("arrow_per_wave")
	self.arrow_damage_pct		= ability:GetSpecialValueFor("arrow_damage_pct") + talent_value(self:GetCaster(), "special_bonus_unique_drow_ranger_1")
	self.arrow_slow_duration	= ability:GetSpecialValueFor("arrow_slow_duration")
	self.arrow_width			= ability:GetSpecialValueFor("arrow_width")
	self.arrow_speed			= ability:GetSpecialValueFor("arrow_speed")
	self.arrow_range_multiplier	= ability:GetSpecialValueFor("arrow_range_multiplier")
	self.arrow_angle			= ability:GetSpecialValueFor("arrow_angle")
	self.arrow_waves			= ability:GetSpecialValueFor("arrow_waves")
	self.arrow_interval			= ability:GetSpecialValueFor("arrow_interval")
	self.initial_delay			= ability:GetSpecialValueFor("initial_delay")

	self.volley_interval		= (ability:GetChannelTime() - self.initial_delay) / self.arrow_waves
	self.angle_per_arrow		= self.arrow_angle / 12
	self.adjusted_angle			= self.angle_per_arrow * self.arrows_per_salvo
	
	self.num_arrow_in_salvo = 1
	self.volley_index = 1
	
	self:GetCaster():EmitSound("Hero_DrowRanger.Multishot.Channel")

	self.first_salvo = true
	
	self:StartIntervalThink(self.initial_delay)
end

function modifier_dr_multishot:OnIntervalThink()	
	self:GetCaster():EmitSound("Hero_DrowRanger.Multishot.Attack")
	-- self:GetCaster():EmitSound("Hero_DrowRanger.Multishot.FrostArrows")
	
	ProjectileManager:CreateLinearProjectile({
		Ability				= self:GetAbility(),
		EffectName			= "particles/units/heroes/hero_drow/drow_multishot_proj_linear_proj.vpcf",
		vSpawnOrigin		= self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1")),
		fDistance			= self:GetCaster():Script_GetAttackRange() * self.arrow_range_multiplier,
		fStartRadius		= self.arrow_width,
		fEndRadius			= self.arrow_width,
		Source				= self:GetCaster(),
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime 		= GameRules:GetGameTime() + 10.0,
		bDeleteOnHit		= true,
		vVelocity			= RotatePosition(Vector(0, 0, 0), QAngle(0, - self.adjusted_angle + (self.angle_per_arrow * self.num_arrow_in_salvo * 2), 0), self:GetCaster():GetForwardVector()) * self.arrow_speed,
		bProvidesVision		= true,
		iVisionRadius		= 100,
		iVisionTeamNumber	= self:GetCaster():GetTeamNumber(),
		
		ExtraData			= {volley_index	= self.volley_index}
	})
	
	if self.num_arrow_in_salvo < self.arrows_per_salvo then
		self:StartIntervalThink(self.arrow_interval)
	else
		self:StartIntervalThink(math.max((self.volley_interval - (self.arrow_interval * (self.arrows_per_salvo - 1))), 0))
		self.volley_index = self.volley_index + 1
	end
	self.num_arrow_in_salvo = (self.num_arrow_in_salvo % self.arrows_per_salvo) + 1
end

function modifier_dr_multishot:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():StopSound("Hero_DrowRanger.Multishot.Channel")
end
