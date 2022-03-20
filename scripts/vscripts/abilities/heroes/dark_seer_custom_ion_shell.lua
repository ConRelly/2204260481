LinkLuaModifier("modifier_ion_shell_custom", "abilities/heroes/dark_seer_custom_ion_shell.lua", LUA_MODIFIER_MOTION_NONE)

dark_seer_custom_ion_shell = class({})
function dark_seer_custom_ion_shell:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_ion_shell_custom", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("Hero_Dark_Seer.Ion_Shield_Start")
end


modifier_ion_shell_custom = class({})
if IsServer() then
    function modifier_ion_shell_custom:OnCreated()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local interval = self:GetAbility():GetSpecialValueFor("think_interval")

		if caster:HasTalent("dark_seer_custom_bonus_unique_2") then
			interval = interval / talent_value(caster, "dark_seer_custom_bonus_unique_2")
		end

		self.shell_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControlEnt(self.shell_fx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.shell_fx, 1, Vector(65,65,65))

		parent:EmitSound("Hero_Dark_Seer.Ion_Shield_lp")

		self:StartIntervalThink(interval)
    end
	function modifier_ion_shell_custom:OnRefresh()
		local caster = self:GetCaster()
		local interval = self:GetAbility():GetSpecialValueFor("think_interval")
		if caster:HasTalent("dark_seer_custom_bonus_unique_2") then
			interval = interval / talent_value(caster, "dark_seer_custom_bonus_unique_2")
		end
		self:GetParent():EmitSound("Hero_Dark_Seer.Ion_Shield_lp")
		self:StartIntervalThink(interval)
	end
	function modifier_ion_shell_custom:OnDestroy()
		if self.shell_fx then
			ParticleManager:DestroyParticle(self.shell_fx, true)
		end
		self:GetParent():StopSound("Hero_Dark_Seer.Ion_Shield_lp")
		self:GetParent():EmitSound("Hero_Dark_Seer.Ion_Shield_end")
	end
    function modifier_ion_shell_custom:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		if not self:GetAbility() then return end
		if IsValidEntity(parent) and IsValidEntity(caster) then
			local caster_int = caster:GetIntellect()
			local int_dmg  = caster_int * self:GetAbility():GetSpecialValueFor("int_mult")
			local radius = self:GetAbility():GetSpecialValueFor("radius")

			if caster:HasTalent("special_bonus_ds_ion_shell_radius") then
				radius = radius * talent_value(caster, "special_bonus_ds_ion_shell_radius")
			end

			local damage = int_dmg + self:GetAbility():GetSpecialValueFor("damage_per_second") + talent_value(caster, "special_bonus_ds_ion_shell_damage")

			local parent_location = parent:GetAbsOrigin()
			local units = FindUnitsInRadius(caster:GetTeamNumber(), parent_location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, self:GetAbility():GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

			for _,unit in ipairs(units) do
				if unit ~= parent then
					local shell_tgt = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell_damage.vpcf", PATTACH_POINT_FOLLOW, unit) 
					ParticleManager:SetParticleControlEnt(shell_tgt, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent_location, true) 
					ParticleManager:SetParticleControlEnt(shell_tgt, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(shell_tgt)

					ApplyDamage({victim = unit, attacker = caster, ability = self:GetAbility(), damage = damage, damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE})
				end
			end
		end
    end
end
