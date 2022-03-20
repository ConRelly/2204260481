LinkLuaModifier("modifier_custom_aphotic_shield", "abilities/bosses/custom_aphotic_shield.lua", LUA_MODIFIER_MOTION_NONE)


custom_aphotic_shield = class({})
function custom_aphotic_shield:OnSpellStart()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_custom_aphotic_shield")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_custom_aphotic_shield", {duration = self:GetSpecialValueFor("duration")})
	end
end


modifier_custom_aphotic_shield = class({})
function modifier_custom_aphotic_shield:IsBuff() return true end
function modifier_custom_aphotic_shield:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_custom_aphotic_shield:OnCreated(keys)
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()

		self.damage_radius = ability:GetSpecialValueFor("radius")
		self.instances_count = ability:GetSpecialValueFor("instances_count")
		self.damage_percentage = ability:GetSpecialValueFor("percentage") * 0.01
		
		self.total_damage = 0

		parent:EmitSound("Hero_Abaddon.AphoticShield.Cast")

		local shield_size = 150
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControl(self.particle, 1, Vector(shield_size, 0, shield_size))
		ParticleManager:SetParticleControl(self.particle, 2, Vector(shield_size, 0, shield_size))
		ParticleManager:SetParticleControl(self.particle, 4, Vector(shield_size, 0, shield_size))
		ParticleManager:SetParticleControl(self.particle, 5, Vector(shield_size, 0, 0))
		ParticleManager:SetParticleControlEnt(self.particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	end
end
function modifier_custom_aphotic_shield:OnDestroy()
	if IsServer() then
		if not self:GetAbility() then return end
		local parent = self:GetParent()
		local ability = self:GetAbility()

		parent:EmitSound("Hero_Abaddon.AphoticShield.Destroy")

		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)

		local damage = self.total_damage * self.damage_percentage

		local units = FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, self.damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for i = 1, self.instances_count do
			for _, unit in ipairs(units) do
				ApplyDamage({
					ability = ability,
					attacker = parent,
					damage = damage / self.instances_count,
					damage_type = ability:GetAbilityDamageType(),
					victim = unit
				})
			end
		end
	end
end
function modifier_custom_aphotic_shield:OnTakeDamage(keys)
	if IsServer() then
		local parent = self:GetParent()
		if keys.unit == parent then
			local damage = keys.damage

			self.total_damage = self.total_damage + damage

			create_popup({
				target = parent,
				value = damage,
				color = Vector(47, 80, 80),
				type = "resist"
			})
		end
	end
end
