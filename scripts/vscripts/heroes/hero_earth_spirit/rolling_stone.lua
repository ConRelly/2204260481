LinkLuaModifier("modifier_rolling_stone", "heroes/hero_earth_spirit/rolling_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rolling_stone_thinker", "heroes/hero_earth_spirit/rolling_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rolling_stone_buff", "heroes/hero_earth_spirit/rolling_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rolling_stone_remnantbuff", "heroes/hero_earth_spirit/rolling_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rolling_stone_stun", "heroes/hero_earth_spirit/rolling_stone", LUA_MODIFIER_MOTION_NONE)

----------------------------------------------------------------------------

rolling_stone = class({})
function rolling_stone:ResetToggleOnRespawn() return true end
function rolling_stone:OnToggle()
	if IsServer() then
		local caster = self:GetCaster()
		if self:GetToggleState() then
			EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Cast", caster)
			caster:AddNewModifier(caster, self, "modifier_rolling_stone_thinker", {})
			caster:AddNewModifier(caster, self, "modifier_rolling_stone_buff", {})
			if caster:HasAbility("earth_spirit_rolling_boulder") then
				caster:FindAbilityByName("earth_spirit_rolling_boulder"):SetActivated(false)
			end	
		else
			EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Destroy", caster)
			if caster:HasAbility("earth_spirit_rolling_boulder") then
				caster:FindAbilityByName("earth_spirit_rolling_boulder"):SetActivated(true)
			end	
			caster:RemoveModifierByName("modifier_rolling_stone_thinker")
			caster:RemoveModifierByName("modifier_rolling_stone_buff")
		end
	end
end

----------------------------------------------------------------------------

modifier_rolling_stone_thinker = class({})
function modifier_rolling_stone_thinker:IsHidden() return true end
function modifier_rolling_stone_thinker:IsPurgable() return false end
function modifier_rolling_stone_thinker:OnCreated()
	if IsServer() then
		local drain_pct = self:GetAbility():GetSpecialValueFor("health_percentage") / 100
		local Health = self:GetCaster():GetHealth()
		local Health_per_tick = Health * drain_pct
		self:GetCaster():ModifyHealth(Health - Health_per_tick, self:GetAbility(), true, 0)
	end
	self.interval = 0.25
	self:StartIntervalThink(self.interval)
end
function modifier_rolling_stone_thinker:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local drain_pct = ability:GetSpecialValueFor("health_percentage") / 100

		local Health = caster:GetHealth()
		local Health_per_tick = Health * drain_pct * self.interval

		caster:ModifyHealth(Health - Health_per_tick, ability, true, 0)
		KillTreesInRadius(caster, caster:GetAbsOrigin(), 300, ability)
	end
end

modifier_rolling_stone_remnantbuff = class({})
function modifier_rolling_stone_remnantbuff:IsHidden() return true end
function modifier_rolling_stone_remnantbuff:IsPurgable() return false end

----------------------------------------------------------------------------

modifier_rolling_stone_buff = class({})
function modifier_rolling_stone_buff:IsPurgable() return false end
function modifier_rolling_stone_buff:IsHidden() return false end

function modifier_rolling_stone_buff:CheckState()
	local Flying = nil
	if self:GetCaster():HasModifier("modifier_super_scepter") then Flying = true end
	local state = {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = Flying,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end
function modifier_rolling_stone_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
end
function modifier_rolling_stone_buff:GetModifierIgnoreMovespeedLimit()
	if self:GetCaster():HasModifier("modifier_super_scepter") then return 1 else return 0 end
end
function modifier_rolling_stone_buff:GetModifierMoveSpeedBonus_Constant()
	if self:GetCaster():HasModifier("modifier_rolling_stone_remnantbuff") then
		return self:GetAbility():GetSpecialValueFor("bonus_ms") + self:GetAbility():GetSpecialValueFor("remnant_bonus_ms")
	end
	return self:GetAbility():GetSpecialValueFor("bonus_ms")
end
function modifier_rolling_stone_buff:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then
		if self:GetCaster():HasModifier("modifier_rolling_stone_remnantbuff") then
			if (self:GetParent():GetName() == "npc_dota_hero_earth_spirit") then
				return (self:GetAbility():GetSpecialValueFor("dmg_reduction") + talent_value(self:GetCaster(), "special_earth_spirit_rolling_stone_dmg_reduction")) * (-1)
			end	
			return 0
		end
		return self:GetAbility():GetSpecialValueFor("dmg_reduction") * (-1)
	end
end

function modifier_rolling_stone_buff:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local tick_rate = 1
--		EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Loop", caster)
		caster:EmitSoundParams("Hero_EarthSpirit.RollingBoulder.Loop", 1, 0.5, 0)

		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_rollingboulder.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		if _G._challenge_bosss > 1 then
			tick_rate = tick_rate / _G._challenge_bosss
		end	
		self:StartIntervalThink(tick_rate)
	end
end

function modifier_rolling_stone_buff:OnDestroy()
	StopSoundOn("Hero_EarthSpirit.RollingBoulder.Loop", self:GetCaster())
	StopSoundEvent("Hero_EarthSpirit.RollingBoulder.Loop", self:GetCaster())
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end

function modifier_rolling_stone_buff:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local str_damage = caster:GetStrength() * self:GetAbility():GetSpecialValueFor("str_damage") / 100
		local speed_dmg = caster:GetIdealSpeed() * self:GetAbility():GetSpecialValueFor("speed_dmg") / 100
		local radius = self:GetAbility():GetSpecialValueFor("radius")
		local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration") + talent_value(caster, "special_earth_spirit_rolling_stone_stun_duration")
		if caster:HasModifier("modifier_super_scepter") then 
			str_damage = str_damage + speed_dmg
		end

		local unit_list = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, unit in pairs(unit_list) do
			if unit then
				ApplyDamage({
					victim = unit,
					attacker = caster,
					damage = str_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self:GetAbility(),
				})
				if stun_duration > 0 then
					unit:AddNewModifier(caster, self:GetAbility(), "modifier_rolling_stone_stun", {duration = stun_duration})
				end	
			end
		end
		local randomSeed = math.random(1, 100)
		if randomSeed <= _G._effect_rate then
			local effect_cast = ParticleManager:CreateParticle("particles/custom/abilities/heroes/earth_spirit_rolling_stone/rolling_stone_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
			ParticleManager:ReleaseParticleIndex(effect_cast)
		end	
	end
end

modifier_rolling_stone_stun = class({})
function modifier_rolling_stone_stun:IsHidden() return true end
function modifier_rolling_stone_stun:IsDebuff() return true end
function modifier_rolling_stone_stun:IsStunDebuff() return true end
function modifier_rolling_stone_stun:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_rolling_stone_stun:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_rolling_stone_stun:GetOverrideAnimation(params) return ACT_DOTA_DISABLED end
function modifier_rolling_stone_stun:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_rolling_stone_stun:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

-----------------------------------------------------------------------------------------

function KillTreesInRadius(caster, center, radius, ability)
	local particles = {
		"particles/newplayer_fx/npx_tree_break.vpcf",
		"particles/newplayer_fx/npx_tree_break_b.vpcf",
	}
	local particle = particles[math.random(1, #particles)]

	local trees = GridNav:GetAllTreesAroundPoint(center, radius, true)
	for _, tree in pairs(trees) do
		local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_fx, 0, tree:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_fx)
	end
	GridNav:DestroyTreesAroundPoint(center, radius, false)

	local RemnantAroundCaster = FindUnitsInRadius(caster:GetTeamNumber(), center, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_CLOSEST, false)
	for _, r in ipairs(RemnantAroundCaster) do
		if r:GetUnitName() == "npc_dota_earth_spirit_stone" then
			r:Kill(nil, nil)
			caster:AddNewModifier(caster, ability, "modifier_rolling_stone_remnantbuff", {duration = 10})
		end
	end
end
