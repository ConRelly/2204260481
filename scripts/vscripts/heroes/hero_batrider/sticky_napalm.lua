LinkLuaModifier("modifier_sticky_napalm_handler", "heroes/hero_batrider/sticky_napalm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sticky_napalm", "heroes/hero_batrider/sticky_napalm", LUA_MODIFIER_MOTION_NONE)

sticky_napalm = class({})
modifier_sticky_napalm_handler = class({})
modifier_sticky_napalm = class({})

-------------------
-- Sticky Napalm --
-------------------
function sticky_napalm:GetAOERadius() return self:GetSpecialValueFor("radius") + talent_value(self:GetCaster(), "special_bonus_unique_sticky_napalm_radius") end
function sticky_napalm:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius") + talent_value(caster, "special_bonus_unique_sticky_napalm_radius")
	caster:EmitSound("Hero_Batrider.StickyNapalm.Cast")
	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Batrider.StickyNapalm.Impact", caster)

	local napalm_impact_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_impact.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(napalm_impact_particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(napalm_impact_particle, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(napalm_impact_particle, 2, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(napalm_impact_particle)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetCursorPosition(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_sticky_napalm", {duration = self:GetSpecialValueFor("duration") * (1 - enemy:GetStatusResistance())})
	end

	AddFOWViewer(caster:GetTeamNumber(), self:GetCursorPosition(), radius, 2, false)
end
function sticky_napalm:GetIntrinsicModifierName() return "modifier_sticky_napalm_handler" end

---------------------------
-- Sticky Napalm HANDLER --
---------------------------
function modifier_sticky_napalm_handler:IsHidden() return true end
function modifier_sticky_napalm_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_IGNORE_CAST_ANGLE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_sticky_napalm_handler:OnAttackLanded(keys)
	if IsServer() then
		if not self:GetAbility() then return end
		local caster = self:GetCaster()
		local target = keys.target
		if caster ~= keys.attacker then return end
		if not caster:HasModifier("modifier_super_scepter") then return end
		local chance = self:GetAbility():GetSpecialValueFor("ss_stack_chance")
		if RollPercentage(chance) then
			target:AddNewModifier(caster, self:GetAbility(), "modifier_sticky_napalm", {duration = self:GetAbility():GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
		end
	end
end

function modifier_sticky_napalm_handler:GetModifierIgnoreCastAngle()
	if not IsServer() then return end
	return 1
end

----------------------------
-- Sticky Napalm Modifier --
----------------------------
function modifier_sticky_napalm:GetEffectName() return "particles/units/heroes/hero_batrider/batrider_stickynapalm_debuff.vpcf" end
function modifier_sticky_napalm:GetStatusEffectName() return "particles/status_fx/status_effect_stickynapalm.vpcf" end
function modifier_sticky_napalm:IsPurgable() return false end
function modifier_sticky_napalm:OnCreated()
	self:Recalculate(self:GetAbility())

	if not IsServer() then return end

	self.non_trigger_inflictors = {
		["sticky_napalm"] = true,
		["item_cloak_of_flames"] = true,
		["item_light_fire_earth_3"] = true,
		["item_light_fire_earth_2"] = true,
		["item_light_fire_earth"] = true,
		["item_fire_radiance"] = true,
		["item_radiance"] = true,
		["item_urn_of_shadows"]	= true,
		["item_spirit_vessel"] = true,
		["item_vessel_of_the_souls"] = true,
	}

	self:SetStackCount(1)

	self.stack_particle = ParticleManager:CreateParticleForTeam("particles/custom/abilities/heroes/batrider_sticky_napalm/batrider_stickynapalm_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(self.stack_particle, 1, Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	self:AddParticle(self.stack_particle, false, false, -1, false, false)
end

function modifier_sticky_napalm:Recalculate(ability)
	local caster = self:GetCaster()
	if caster:IsNull() then return end
	local caster_int = caster:GetIntellect(true)
	self.max_stacks = ability:GetSpecialValueFor("max_stacks")
	self.ms_slow_pct = ability:GetSpecialValueFor("ms_slow_pct")
	self.turn_rate_pct = ability:GetSpecialValueFor("turn_rate_pct")
	self.damage = math.floor( caster_int * (ability:GetSpecialValueFor("damage") + talent_value(self:GetCaster(), "special_bonus_unique_sticky_napalm_damage")))
end
function modifier_sticky_napalm:OnRefresh()
	self:Recalculate(self:GetAbility())

	if not IsServer() then return end
	if self:GetStackCount() < self.max_stacks then self:IncrementStackCount() end
	if self.stack_particle then ParticleManager:SetParticleControl(self.stack_particle, 1, Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0)) end
end
function modifier_sticky_napalm:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_sticky_napalm:GetModifierMoveSpeedBonus_Percentage() return math.min(self:GetStackCount(), self.max_stacks) * self.ms_slow_pct * (-1) end
function modifier_sticky_napalm:GetModifierTurnRate_Percentage() return self.turn_rate_pct * (-1) end
function modifier_sticky_napalm:OnTooltip() return self:GetStackCount() * self.damage end

function modifier_sticky_napalm:OnTakeDamage(keys)
	if not self:GetAbility() then return end
	if keys.attacker == self:GetCaster() and keys.unit == self:GetParent() and (not keys.inflictor or not self.non_trigger_inflictors[keys.inflictor:GetName()]) and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		local damage_debuff_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(damage_debuff_particle)

		ApplyDamage({
			victim 			= self:GetParent(),
			damage 			= self.damage * self:GetStackCount(),
			damage_type		= DAMAGE_TYPE_MAGICAL,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self:GetAbility()
		})
	end
end