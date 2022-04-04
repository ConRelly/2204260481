LinkLuaModifier("modifier_luna_eclipse_lua", "lua_abilities/luna_eclipse_lua/luna_eclipse_lua", LUA_MODIFIER_MOTION_NONE)


luna_eclipse_lua = class({})
function luna_eclipse_lua:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("radius")
	end
	return 0
end

function luna_eclipse_lua:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function luna_eclipse_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cast_range_scepter")
	end
	return self:GetSpecialValueFor("radius")
end

function luna_eclipse_lua:OnAbilityPhaseStart()
	if not IsServer() then return end

	local precast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_eclipse_precast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(precast_particle,	0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(precast_particle)

	return true
end

function luna_eclipse_lua:OnSpellStart()
	if not IsServer() then return end

	if self:GetCaster():HasScepter() then
		if self:GetCursorTarget() then
			self:GetCursorTarget():EmitSound("Hero_Luna.Eclipse.Cast")
		elseif self:GetCursorPosition() then
			EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Luna.Eclipse.Cast", self:GetCaster())
		end
	else
		self:GetCaster():EmitSound("Hero_Luna.Eclipse.Cast")
	end

	if self:GetCaster():HasScepter() and self:GetCursorTarget() then
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_luna_eclipse_lua", {})
	else
		local modifier_params = {}
		
		if self:GetCaster():HasScepter() and self:GetCursorPosition() then
			modifier_params.x = self:GetCursorPosition().x
			modifier_params.y = self:GetCursorPosition().y
			modifier_params.z = self:GetCursorPosition().z
		end
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_luna_eclipse_lua", modifier_params)
	end
	
	local night_duration = self:GetSpecialValueFor("night_duration")
	if self:GetCaster():HasScepter() and self:GetTalentSpecialValueFor("beams_scepter") * self:GetSpecialValueFor("beam_interval_scepter") > night_duration then
		night_duration = self:GetTalentSpecialValueFor("beams_scepter") * self:GetSpecialValueFor("beam_interval_scepter")
	elseif not self:GetCaster():HasScepter() and self:GetTalentSpecialValueFor("beams") * self:GetSpecialValueFor("beam_interval") > night_duration then
		night_duration = self:GetTalentSpecialValueFor("beams") * self:GetSpecialValueFor("beam_interval")
	end

	GameRules:BeginTemporaryNight(night_duration)
end



-- Eclipse Modifier
modifier_luna_eclipse_lua = class({})
function modifier_luna_eclipse_lua:IsHidden() return false end
function modifier_luna_eclipse_lua:IsDebuff() return false end
function modifier_luna_eclipse_lua:IsPurgable() return false end
function modifier_luna_eclipse_lua:RemoveOnDeath() return talent_value(self:GetCaster(), "special_bonus_luna_eclipse_end") == 0 end --true
function modifier_luna_eclipse_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_luna_eclipse_lua:OnCreated(params)
	if not IsServer() then return end
	if self:GetCaster():HasScepter() then
		self.beams = self:GetAbility():GetTalentSpecialValueFor("beams_scepter")
		self.beam_interval = self:GetAbility():GetSpecialValueFor("beam_interval_scepter")
	else
		self.beams = self:GetAbility():GetTalentSpecialValueFor("beams")
		self.beam_interval = self:GetAbility():GetSpecialValueFor("beam_interval")
	end
	self.hit_count = self:GetAbility():GetSpecialValueFor("hit_count")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")

	local eclipse_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_eclipse.vpcf", PATTACH_POINT, self:GetCaster())
	ParticleManager:SetParticleControl(eclipse_particle, 1, Vector(self.radius, 0, 0))

	if params.x then
		self.target_position = Vector(params.x, params.y, params.z)
		ParticleManager:SetParticleControl(eclipse_particle, 0, self.target_position)
	end

	self:AddParticle(eclipse_particle, false, false, -1, false, false)

	self.counter = 0
	self.hits = {}

	self:StartIntervalThink(self.beam_interval)
end

function modifier_luna_eclipse_lua:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility()then return end
	if self:GetAbility():IsNull() then return end
	local point = self.target_position or self:GetParent():GetAbsOrigin()

	AddFOWViewer(self:GetCaster():GetTeamNumber(), point, self.radius, self.beam_interval, true)

	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

	local valid_enemy = false
	local lucent_beam = self:GetCaster():FindAbilityByName("luna_lucent_beam_lua")

	for _, enemy in pairs(units) do
		if not self.hits[enemy:GetEntityIndex()] then
			self.hits[enemy:GetEntityIndex()] = 0
		end
		
		if (not self:GetCaster():HasScepter() and self.hits[enemy:GetEntityIndex()] < self.hit_count) or self:GetCaster():HasScepter() then
			self.hits[enemy:GetEntityIndex()] = self.hits[enemy:GetEntityIndex()] + 1

			enemy:EmitSound("Hero_Luna.Eclipse.Target")

			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_eclipse_impact.vpcf", PATTACH_POINT, self:GetCaster())
			ParticleManager:SetParticleControl(particle, 1, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(particle,	5, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle)
			
			if lucent_beam then
				ApplyDamage({
					attacker = self:GetCaster(),
					victim = enemy,
					ability = lucent_beam,
					damage = lucent_beam:GetTalentSpecialValueFor("beam_damage"),
					damage_type = lucent_beam:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
			if math.random(100) < self:GetAbility():GetSpecialValueFor("new_moon_chance") then
				local moonlight_buff = self:GetCaster():FindModifierByName("modifier_mjz_luna_under_the_moonlight_buff")
				moonlight_buff:SetStackCount(moonlight_buff:GetStackCount() + 1)
			end
			valid_enemy = true
			break
		end
	end
	if not valid_enemy then
		local random_location = RandomVector(RandomInt(0, self.radius))
		
		EmitSoundOnLocationWithCaster((self.target_position or self:GetParent():GetAbsOrigin()) + random_location, "Hero_Luna.Eclipse.NoTarget", self:GetCaster())
		
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_eclipse_impact_notarget.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(particle, 1, (self.target_position or self:GetParent():GetAbsOrigin()) + random_location)
		ParticleManager:SetParticleControl(particle, 5, (self.target_position or self:GetParent():GetAbsOrigin()) + random_location)
		ParticleManager:ReleaseParticleIndex(particle)
	end

	self.counter = self.counter + 1
	if self.counter>=self.beams then
		self:StartIntervalThink(-1)
		if self:IsNull() then return end
		self:Destroy()
	end
end

--------------------------------------------------------------------------------


--talents
function HasTalent(unit, talentName)
	if unit:HasAbility(talentName) then
		if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

function GetTalentSpecialValueFor(ability, value)
	local base = ability:GetSpecialValueFor(value)
	local talentName
	local valueName
	local kv = ability:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
					valueName = m["LinkedSpecialBonusField"]
				end
			end
		end
	end
	if talentName then 
		local talent = ability:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then
			valueName = valueName or 'value'
			base = base + talent:GetSpecialValueFor(valueName) 
		end
	end
	return base
end
