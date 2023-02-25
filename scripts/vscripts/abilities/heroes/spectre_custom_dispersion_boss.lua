
LinkLuaModifier("modifier_spectre_custom_dispersion_boss", "abilities/heroes/spectre_custom_dispersion_boss.lua", LUA_MODIFIER_MOTION_NONE )

spectre_custom_dispersion_boss = class({})


function spectre_custom_dispersion_boss:GetIntrinsicModifierName()
    return "modifier_spectre_custom_dispersion_boss"
end
function spectre_custom_dispersion_boss:OnUpgrade()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_spectre_custom_dispersion_boss")
	caster:AddNewModifier(caster, self, "modifier_spectre_custom_dispersion_boss" , {})
end

modifier_spectre_custom_dispersion_boss = class({})

function modifier_spectre_custom_dispersion_boss:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end
function modifier_spectre_custom_dispersion_boss:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	if self.ability and not self.ability:IsNull() then
		self.damage_reflect_pct = self.ability:GetSpecialValueFor("damage_reflection_pct") * 0.01
		self.chance = self.ability:GetSpecialValueFor("chance")
		self.damage_block_pct = self.ability:GetSpecialValueFor("damage_block_pct") * 0.01
		self.extra_restore_chance = self.ability:GetSpecialValueFor("extra_restore_chance")

	end	
end

function modifier_spectre_custom_dispersion_boss:OnTakeDamage (event)
	if self.parent and event.unit == self.parent then
		if event.damage_flags ~= 16 then
			if event.damage < 2 then return end
			if not IsServer() then return end
			local post_damage = event.damage
			local original_damage = event.original_damage
			local unit = event.attacker
			if unit and not unit:IsNull() and unit:IsAlive() then
				if self.parent and not self.parent:IsNull() and self.parent:IsAlive() then
					if unit:GetTeam() ~= self.parent:GetTeam() then
						if self.chance == nil then return end
						if RollPercentage(self.chance) then
							if self.ability == nil then return end
							if self.damage_block_pct == nil then return end
							if self.extra_restore_chance == nil then return end
							local vparent = self.parent:GetAbsOrigin()
							local vUnit = unit:GetAbsOrigin()

							local reflect_damage = 0.0
							local particle_name = ""

							reflect_damage = post_damage * self.damage_reflect_pct
							--particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"
							particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_b_fallback_mid.vpcf"
							if self.parent and not self.parent:IsNull() and self.parent:IsAlive() then
								self.parent:SetHealth(self.parent:GetHealth() + (post_damage * self.damage_block_pct) )
								if RollPercentage(self.extra_restore_chance) then
									self.parent:SetHealth(self.parent:GetHealth() + (post_damage * self.damage_block_pct) )
								end	
							
								if unit and not unit:IsNull() and unit:IsAlive() then
									--Create particle
									local particle = ParticleManager:CreateParticle( particle_name, PATTACH_POINT_FOLLOW, self.parent )
									ParticleManager:SetParticleControl(particle, 0, vparent)
									ParticleManager:SetParticleControl(particle, 1, vUnit)
									ParticleManager:SetParticleControl(particle, 2, vparent)
									ParticleManager:ReleaseParticleIndex(particle)
									ApplyDamage({
										ability = self.ability,
										attacker = self.parent,
										damage = reflect_damage,
										damage_type = event.damage_type,
										damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
										victim = unit,
									})
								end
							end	
						end
					end		
				end
			end
		end
	end
end


function modifier_spectre_custom_dispersion_boss:IsHidden()
	return true
end

function modifier_spectre_custom_dispersion_boss:RemoveOnDeath()
	return false
end

function modifier_spectre_custom_dispersion_boss:IsPurgable()
	return false
end