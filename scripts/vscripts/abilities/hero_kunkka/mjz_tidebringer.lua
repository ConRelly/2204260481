LinkLuaModifier("modifier_mjz_tidebringer", "abilities/hero_kunkka/mjz_tidebringer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_tidebringer_sword_particle", "abilities/hero_kunkka/mjz_tidebringer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_tidebringer_manual", "abilities/hero_kunkka/mjz_tidebringer", LUA_MODIFIER_MOTION_NONE)

-----------------
-- Tidebringer --
-----------------
mjz_kunkka_tidebringer = class({})
function mjz_kunkka_tidebringer:GetIntrinsicModifierName() return "modifier_mjz_tidebringer" end
function mjz_kunkka_tidebringer:GetCastRange(location, target) return self:GetCaster():Script_GetAttackRange() end
function mjz_kunkka_tidebringer:IsStealable() return false end
function mjz_kunkka_tidebringer:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		caster:MoveToTargetToAttack(self:GetCursorTarget())
		caster:AddNewModifier(caster, self, "modifier_mjz_tidebringer_manual", {})
		self:EndCooldown()
	end
end
function mjz_kunkka_tidebringer:OnUpgrade()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_mjz_tidebringer")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mjz_tidebringer", {})

		local caster_tidebringer = self:GetCaster():FindAbilityByName("mjz_kunkka_tidebringer")
		if caster_tidebringer and caster_tidebringer:GetLevel() == 1 then
			caster_tidebringer:ToggleAutoCast()
		end
	end
end

--------------------------
-- Tidebringer Modifier --
--------------------------
modifier_mjz_tidebringer = class({})
function modifier_mjz_tidebringer:IsHidden() return true end
function modifier_mjz_tidebringer:RemoveOnDeath() return false end
function modifier_mjz_tidebringer:IsPurgable() return false end
function modifier_mjz_tidebringer:OnCreated()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_mjz_tidebringer:OnDestroy()
	if self:GetCaster():HasModifier("modifier_mjz_tidebringer_sword_particle") then
		self:GetCaster():RemoveModifierByName("modifier_mjz_tidebringer_sword_particle")
	end
	if self:GetCaster():HasModifier("modifier_mjz_tidebringer_manual") then
		self:GetCaster():RemoveModifierByName("modifier_mjz_tidebringer_manual")
	end	
end
function modifier_mjz_tidebringer:OnIntervalThink()
	if IsServer() then
		if self:GetAbility() and not self:GetAbility():IsNull() and self:GetCaster() and not self:GetCaster():IsNull() then
			if (not self:GetCaster():HasModifier("modifier_mjz_tidebringer_sword_particle")) and self:GetAbility():IsCooldownReady() and (self:GetCaster():GetUnitName() == "npc_dota_hero_kunkka") or (self:GetCaster():GetUnitName() == "npc_dota_hero_kunkka_mjz") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_tidebringer_sword_particle", {})
			end
		end	
	end
end
function modifier_mjz_tidebringer:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_mjz_tidebringer:OnAttackStart(params)
	if self:GetAbility() then
		local parent = self:GetParent()
		local target = params.target
		if (parent == params.attacker) and (target:GetTeamNumber() ~= parent:GetTeamNumber()) and (target.IsCreep or target.IsHero) then
			local strength_damage_pct = self:GetAbility():GetTalentSpecialValueFor("strength_damage_pct")
			local str_damage = params.attacker:GetStrength() * (strength_damage_pct / 100)
			if not target:IsBuilding() then
				if self:GetAbility():IsCooldownReady() and not (parent:PassivesDisabled()) then
					if self:GetCaster():HasModifier("modifier_mjz_tidebringer_manual") or self:GetAbility():GetAutoCastState() then
						self.pass_attack = true
						self.bonus_damage = self:GetAbility():GetSpecialValueFor("damage_bonus") + str_damage
					else
						self.pass_attack = false
						self.bonus_damage = 0
					end
				end
			end
		end
	end
end
function modifier_mjz_tidebringer:OnAttackLanded(params)
	local ability = self:GetAbility()
	if self:GetParent():PassivesDisabled() then return end
	if self:GetAbility() then
		local parent = self:GetParent()
		local target = params.target
		if params.attacker == parent and (not parent:IsIllusion()) and self.pass_attack then
			self.pass_attack = false
			self.bonus_damage = 0
			local range = self:GetAbility():GetSpecialValueFor("cleave_distance")
			local radius_start = self:GetAbility():GetSpecialValueFor("cleave_starting_width")
			local radius_end = self:GetAbility():GetSpecialValueFor("cleave_ending_width")
			parent:RemoveModifierByName("modifier_mjz_tidebringer_sword_particle")
			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
				target:EmitSound("Hero_Kunkka.TidebringerDamage")
                local cleaveDamage = params.damage * (ability:GetTalentSpecialValueFor("cleave_damage") / 100)

				local enemies_to_cleave = FindUnitsInCone(self:GetParent():GetTeamNumber(), CalculateDirection(params.target, self:GetParent()), self:GetParent():GetAbsOrigin(), radius_start, radius_end, range, nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)

				DoCleaveAttack(params.attacker, params.target, ability, cleaveDamage, radius_start, radius_end, range, "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf")
				ability:UseResources(false, false, true)
				if self:GetCaster():HasModifier("modifier_mjz_tidebringer_manual") then
					self:GetCaster():RemoveModifierByName("modifier_mjz_tidebringer_manual")
				end
			end
		end
	end
	return 0
end
function modifier_mjz_tidebringer:GetModifierPreAttack_BonusDamage(params)
	self.bonus_damage = self.bonus_damage or 0
	return self.bonus_damage
end

-------------------
-- Sword Effects --
-------------------
modifier_mjz_tidebringer_sword_particle = class({})
function modifier_mjz_tidebringer_sword_particle:IsHidden() return true end
function modifier_mjz_tidebringer_sword_particle:RemoveOnDeath() return false end
function modifier_mjz_tidebringer_sword_particle:IsPurgable() return false end
function modifier_mjz_tidebringer_sword_particle:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		caster.tidebringer_weapon_pfx = caster.tidebringer_weapon_pfx or 0
		if caster.tidebringer_weapon_pfx == 0 then
			EmitSoundOn("Hero_Kunkaa.Tidebringer", caster)
			caster.tidebringer_weapon_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(caster.tidebringer_weapon_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_tidebringer", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(caster.tidebringer_weapon_pfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
		end
	end
end
function modifier_mjz_tidebringer_sword_particle:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		caster:EmitSound("Hero_Kunkka.Tidebringer.Attack")
		ParticleManager:DestroyParticle(caster.tidebringer_weapon_pfx, true)
		ParticleManager:ReleaseParticleIndex(caster.tidebringer_weapon_pfx)
		caster.tidebringer_weapon_pfx = 0
	end
end

----------------
-- Manual Use --
----------------
modifier_mjz_tidebringer_manual = class({})
function modifier_mjz_tidebringer_manual:IsHidden() return true end
function modifier_mjz_tidebringer_manual:RemoveOnDeath() return false end
function modifier_mjz_tidebringer_manual:IsPurgable() return false end


function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	return direction
end
