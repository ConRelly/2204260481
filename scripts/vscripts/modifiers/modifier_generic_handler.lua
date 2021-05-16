--[[	Generic talent multihandler (uses stacks to communicate CDR to client)
		Author: Firetoad
		Date:	13.03.2017	]]

if modifier_generic_handler == nil then modifier_generic_handler = class({}) end
function modifier_generic_handler:IsHidden() return true end
function modifier_generic_handler:IsDebuff() return false end
function modifier_generic_handler:IsPurgable() return false end
function modifier_generic_handler:IsPermanent() return true end

function modifier_generic_handler:OnCreated()
	if IsServer() then
		self.health_regen_amp = 0
		
		self.forbidden_inflictors = {
			"item_blade_mail",
			"luna_moon_glaive"
		}
		self:StartIntervalThink(1)
	end
end

-- Handler for Arc Warden / Meepo (if ported)
function modifier_generic_handler:OnAbilityFullyCast(keys)
	if (keys.ability:GetName() == "arc_warden_tempest_double") and (keys.unit == self:GetParent()) then
		local heroes = FindUnitsInRadius(keys.unit:GetTeamNumber(), keys.unit:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		for _, hero in ipairs(heroes) do
			if hero:IsTempestDouble() then
				if hero:GetPlayerOwner() and keys.unit:GetPlayerOwner() then
					if hero:GetPlayerOwner() == keys.unit:GetPlayerOwner() then
						keys.unit:CopyTalents(hero, DOTA_TALENT_COPY_GENERIC)
					end
				end
			end
		end
	end
end

function modifier_generic_handler:DeclareFunctions()
	return {-- MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_generic_handler:OnIntervalThink()
	-- Rough Out of Bounds warp back logic
	if self:GetParent():GetAbsOrigin().x >= 8000 then
		FindClearSpaceForUnit(self:GetParent(), GetGroundPosition(Vector(7500, self:GetParent():GetAbsOrigin().y, self:GetParent():GetAbsOrigin().z), nil), true)
	elseif self:GetParent():GetAbsOrigin().x <= -8000 then
		FindClearSpaceForUnit(self:GetParent(), GetGroundPosition(Vector(-7500, self:GetParent():GetAbsOrigin().y, self:GetParent():GetAbsOrigin().z), nil), true)
	elseif self:GetParent():GetAbsOrigin().y >= 8000 then
		FindClearSpaceForUnit(self:GetParent(), GetGroundPosition(Vector(self:GetParent():GetAbsOrigin().x, 7500, self:GetParent():GetAbsOrigin().z), nil), true)
	elseif self:GetParent():GetAbsOrigin().y <= -8000 then
		FindClearSpaceForUnit(self:GetParent(), GetGroundPosition(Vector(self:GetParent():GetAbsOrigin().x, -7500, self:GetParent():GetAbsOrigin().z), nil), true)
	end
end

-- Damage amp/reduction handler
--function modifier_generic_handler:GetModifierIncomingDamage_Percentage()
--	if IsServer() then
--		return self:GetParent():GetIncomingDamagePct()
--	end
--end

--- Enum DamageCategory_t
-- DOTA_DAMAGE_CATEGORY_ATTACK = 1
-- DOTA_DAMAGE_CATEGORY_SPELL = 0
function modifier_generic_handler:OnTakeDamage(keys)
	if keys.attacker == self:GetParent() and not keys.unit:IsBuilding() and not keys.unit:IsOther() and keys.unit:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		-- Spell lifesteal handler
		if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and keys.inflictor and self:GetParent():GetSpellLifesteal() > 0 and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
			-- Also do nothing if the inflictor is forbidden
			for _, forbidden_inflictor in pairs(self.forbidden_inflictors) do
				if keys.inflictor:GetName() == forbidden_inflictor then return end
			end
			
			-- Particle effect
			self.lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
			ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, keys.attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
			if keys.unit:IsIllusion() then
				if keys.damage_type == DAMAGE_TYPE_PHYSICAL and keys.unit.GetPhysicalArmorValue and GetReductionFromArmor then
					keys.damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetPhysicalArmorValue(false)))
				elseif keys.damage_type == DAMAGE_TYPE_MAGICAL and keys.unit.GetMagicalArmorValue then
					keys.damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetMagicalArmorValue()))
				elseif keys.damage_type == DAMAGE_TYPE_PURE then
					keys.damage = keys.original_damage
				end
			end
			
			keys.attacker:Heal(math.max(keys.damage, 0) * self:GetParent():GetSpellLifesteal() * 0.01, keys.attacker)
		-- Attack lifesteal handler
		elseif keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetLifesteal() > 0 then
			if not keys.attacker:IsRealHero() and (keys.attacker:GetMaxHealth() <= 0 or keys.attacker:GetHealth() <= 0) then
				keys.attacker:SetMaxHealth(keys.attacker:GetBaseMaxHealth())
				keys.attacker:SetHealth(1)
			end
			
			local lifesteal_particle = "particles/generic_gameplay/generic_lifesteal.vpcf"
			
			-- This is a weird custom function...causes issues with Slardar's Rain Cloud among other things
			-- keys.attacker:Heal(math.max(self:GetParent():GetRealDamageDone(keys.target), 0) * self:GetParent():GetLifesteal() / 100, keys.attacker)
			
			self.lifesteal_pfx = ParticleManager:CreateParticle(lifesteal_particle, PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
			ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, keys.attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
			
			if keys.unit:IsIllusion() and keys.unit.GetPhysicalArmorValue and GetReductionFromArmor then
				keys.damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetPhysicalArmorValue(false)))
			end
			keys.attacker:Heal(keys.damage * self:GetParent():GetLifesteal() * 0.01, keys.attacker)
		end
	end
end

function modifier_generic_handler:GetModifierPreAttack_CriticalStrike()
	if IsServer() then
		if self:GetAbility() and (keys.target and not keys.target:IsOther() and not keys.target:IsBuilding() and keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber()) then
			local CritDMG = self:GetParent():GetCritDMG()
			DMG = 100 + CritDMG
		end
	end
	return DMG
end

function modifier_generic_handler:OnAttackStart(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() and (self:GetParent():IsIllusion() and self:GetParent():GetHealth() <= 0) or (self:GetParent().GetPlayerID and self:GetParent():GetPlayerID() == -1 and not self:GetParent():GetName() == "npc_dota_target_dummy") then
		self:GetParent():ForceKill(false)
		self:GetParent():RemoveSelf()
	end
end