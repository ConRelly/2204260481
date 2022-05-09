--[[Author: Nightborn
	Date: August 27, 2016
]]

LinkLuaModifier("modifier_spectre_custom_dispersion", "abilities/heroes/spectre_custom_dispersion.lua", LUA_MODIFIER_MOTION_NONE )

spectre_custom_dispersion = class({})


function spectre_custom_dispersion:GetIntrinsicModifierName()
    return "modifier_spectre_custom_dispersion"
end
function spectre_custom_dispersion:OnUpgrade()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_spectre_custom_dispersion")
	caster:AddNewModifier(caster, self, "modifier_spectre_custom_dispersion" , {})
end
--[[Author: Nightborn
	Date: August 27, 2016
]]

modifier_spectre_custom_dispersion = class({})

function modifier_spectre_custom_dispersion:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end
function modifier_spectre_custom_dispersion:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	if self.ability and not self.ability:IsNull() then
		local base_defense_ptc = (self.ability:GetSpecialValueFor("damage_reflection_pct") + talent_value(self.parent, "special_bonus_unique_spectre_5")) * 0.01
		self.damage_reflect_pct = base_defense_ptc
		self.defense_ptc = base_defense_ptc
		--self.min_radius = self.ability:GetSpecialValueFor("min_radius")
		if self.parent:HasModifier("modifier_super_scepter") then
			self.defense_ptc = (self.ability:GetSpecialValueFor("damage_reflection_pct_ss") + talent_value(self.parent, "special_bonus_unique_spectre_5")) * 0.01
			self.damage_reflect_pct = self.defense_ptc * 3
		end	
		local think_interval = 3 -- probably good to avoid updating globals to offten
		self:StartIntervalThink(think_interval)
	end	
end
function modifier_spectre_custom_dispersion:OnRefresh()
	if self.ability and not self.ability:IsNull() then
		local base_defense_ptc = (self.ability:GetSpecialValueFor("damage_reflection_pct") + talent_value(self.parent, "special_bonus_unique_spectre_5")) * 0.01
		self.damage_reflect_pct = base_defense_ptc
		self.defense_ptc = base_defense_ptc
		if self.parent:HasModifier("modifier_super_scepter") then
			self.defense_ptc = (self.ability:GetSpecialValueFor("damage_reflection_pct_ss") + talent_value(self.parent, "special_bonus_unique_spectre_5")) * 0.01
			self.damage_reflect_pct = self.defense_ptc * 3
		end	
	end	
end

if IsServer() then
	function modifier_spectre_custom_dispersion:OnTakeDamage (event)
		
		if event.unit == self.parent then
			if event.damage_flags ~= 16 then
				local post_damage = event.damage
				local original_damage = event.original_damage
				local unit = event.attacker
				if unit:GetTeam() ~= self.parent:GetTeam() then
					if post_damage < 2 then return end  -- make dmg checks grater then 1 dmg to keep the option for future stuff that might deal only 1 dmg(1 hit).
					local vparent = self.parent:GetAbsOrigin()
					local vUnit = unit:GetAbsOrigin()
					--local distance = (vUnit - vparent):Length2D()
					local reflect_damage = 0.0
					local particle_name = ""

					
					
					--Within 300 radius		
					--if distance <= self.min_radius then
					reflect_damage = original_damage * self.damage_reflect_pct
					particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"
					if self.parent:IsAlive() then
						self.parent:SetHealth(self.parent:GetHealth() + (post_damage * self.defense_ptc) )
					end
					--Between 301 and 475 radius
					--[[ else
						local ratio = self.damage_reflect_pct * (1 - (distance - self.min_radius) * 0.142857 * 0.01)
						reflect_damage = original_damage *  ratio
						particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_b_fallback_mid.vpcf"
						if self.parent:IsAlive() then
							self.parent:SetHealth(self.parent:GetHealth() + (post_damage * ratio) )
						end
					end ]]
					
					--Create particle
					local particle = ParticleManager:CreateParticle( particle_name, PATTACH_POINT_FOLLOW, self.parent )
					ParticleManager:SetParticleControl(particle, 0, vparent)
					ParticleManager:SetParticleControl(particle, 1, vUnit)
					ParticleManager:SetParticleControl(particle, 2, vparent)	
					ApplyDamage({
						ability = self.ability,
						attacker = self.parent,
						damage = reflect_damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
						victim = unit,
					})

				end
			end
		end

	end

	function modifier_spectre_custom_dispersion:OnIntervalThink()
		if self.parent and not self.parent:IsNull() then
			self:OnRefresh()
		end	
	end
end
function modifier_spectre_custom_dispersion:IsHidden()
	return true
end

function modifier_spectre_custom_dispersion:RemoveOnDeath()
	return false
end

function modifier_spectre_custom_dispersion:IsPurgable()
	return false
end