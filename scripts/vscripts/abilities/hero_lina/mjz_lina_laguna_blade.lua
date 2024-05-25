LinkLuaModifier("modifier_mjz_lina_laguna_blade_bonus", "abilities/hero_lina/mjz_lina_laguna_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lina_laguna_blade_delay", "abilities/hero_lina/mjz_lina_laguna_blade", LUA_MODIFIER_MOTION_NONE)


mjz_lina_laguna_blade = class({})
function mjz_lina_laguna_blade:GetAbilityTextureName()
	if self:GetCaster():HasScepter() then
		return "mjz_lina_laguna_blade_ti6_immortal"
	end
	return "mjz_lina_laguna_blade"
end
function mjz_lina_laguna_blade:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end
function mjz_lina_laguna_blade:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("splash_radius_scepter")
	end
	return self:GetSpecialValueFor("cast_range")
end
function mjz_lina_laguna_blade:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cast_range_scepter")
	end
	return self:GetSpecialValueFor("cast_range")
end
function mjz_lina_laguna_blade:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		if self:GetCaster():HasModifier("modifier_super_scepter") then
			return self:GetSpecialValueFor("cooldown_scepter_ss")
		else
			return self:GetSpecialValueFor("cooldown_scepter")
		end	
	end
	return self.BaseClass.GetCooldown(self, iLevel)
end
function mjz_lina_laguna_blade:GetManaCost(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("mana_cost_scepter")
	end
	return self.BaseClass.GetManaCost(self, iLevel)
end
function mjz_lina_laguna_blade:GetAbilityTargetFlags()
	if self:GetCaster():HasScepter() then
		return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function mjz_lina_laguna_blade:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local cursor_target = self:GetCursorTarget()

		local base_damage = self:GetSpecialValueFor(value_if_scepter(caster, "damage_scepter", "damage"))
		local base_int_damage = caster:GetIntellect(true) * base_damage
		local damage_per_kill = caster:GetIntellect(true) * self:GetSpecialValueFor("intmult_per_kill")
		local kill_count = caster:GetModifierStackCount("modifier_mjz_lina_laguna_blade_bonus", nil)
		local damage = base_int_damage + damage_per_kill * kill_count

		local targets = {}
		if caster:HasScepter() then
			targets = FindUnitsInRadius(caster:GetTeamNumber(), cursor_target:GetAbsOrigin(), nil, self:GetSpecialValueFor("splash_radius_scepter"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		else
			targets = {cursor_target}
		end

		if caster:HasScepter() then
			caster:EmitSound("Hero_Lina.LagunaBlade.Immortal")
		else
			caster:EmitSound("Ability.LagunaBlade")
		end

		for _, target in ipairs(targets) do
			if target:IsIllusion() then return end

			self:_PlayEffect(caster, target)

			if target:TriggerSpellAbsorb(self) then return end

			local sound_default = "Ability.LagunaBladeImpact"
			local sound_immortal = "Hero_Lina.LagunaBladeImpact.Immortal"
			local sound_name = value_if_scepter(caster, sound_immortal, sound_default)
			target:EmitSound(sound_name)

			if not target:IsMagicImmune() or caster:HasScepter() then
				local kill_grace_duration = self:GetSpecialValueFor("kill_grace_duration")
				target:AddNewModifier(self:GetCaster(), self, "modifier_mjz_lina_laguna_blade_delay", {duration = kill_grace_duration})
				damage = damage / 2
				ApplyDamage({
					attacker = caster,
					victim = target,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self,
				})

				ApplyDamage({
					attacker = caster,
					victim = target,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self,
				})				
			end
		end
	end
end

function mjz_lina_laguna_blade:_PlayEffect(caster, target)
	local particle_name_normal = "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
	local particle_name_ti6 = "particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade.vpcf"
	local particle_name = value_if_scepter(caster, particle_name_ti6, particle_name_normal)

	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
	ParticleManager:DestroyParticle(particle, false)
	ParticleManager:ReleaseParticleIndex(particle)
end


--Kill Counter modifier
modifier_mjz_lina_laguna_blade_bonus = class({})
function modifier_mjz_lina_laguna_blade_bonus:IsHidden() return false end
function modifier_mjz_lina_laguna_blade_bonus:IsDebuff() return false end
function modifier_mjz_lina_laguna_blade_bonus:IsPurgable() return false end
function modifier_mjz_lina_laguna_blade_bonus:RemoveOnDeath() return false end
function modifier_mjz_lina_laguna_blade_bonus:OnCreated()
	if not IsServer() then return end 
	local time = GameRules:GetGameTime() / 60
	if time > 1 then
		local stack = math.floor(time * 8)
		self:SetStackCount(stack)
	end 	
end
function modifier_mjz_lina_laguna_blade_bonus:OnRefresh() if not IsServer() then return end self:IncrementStackCount() end
function modifier_mjz_lina_laguna_blade_bonus:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function modifier_mjz_lina_laguna_blade_bonus:OnTooltip() if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("intmult_per_kill") end end

--Delay Finger modifier
modifier_mjz_lina_laguna_blade_delay = class({})
function modifier_mjz_lina_laguna_blade_delay:IsHidden() return false end
function modifier_mjz_lina_laguna_blade_delay:IsPurgable() return false end
function modifier_mjz_lina_laguna_blade_delay:GetAttributes() if self:GetCaster() and self:GetCaster():HasModifier("modifier_super_scepter") then return MODIFIER_ATTRIBUTE_MULTIPLE end end
function modifier_mjz_lina_laguna_blade_delay:OnRemoved()
	if not IsServer() then return end
	if not self:GetParent():IsAlive() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_lina_laguna_blade_bonus", {})
	end
end
function modifier_mjz_lina_laguna_blade_delay:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_mjz_lina_laguna_blade_delay:OnTooltip() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("intmult_per_kill") end end


--------------------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end
