LinkLuaModifier("immortal_all_in_one", "modifiers/immortal_all_in_one", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("immortal_shield", "modifiers/immortal_all_in_one", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("immortal_shield_cd", "modifiers/immortal_all_in_one", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("immortal_heal_cd", "modifiers/immortal_all_in_one", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("immortal_heal", "modifiers/immortal_all_in_one", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("immortal_grave", "modifiers/immortal_all_in_one", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("immortal_spells_req_hp", "modifiers/immortal_all_in_one", LUA_MODIFIER_MOTION_NONE)

local grave_chance = 20		-- % PseudoRandom
local grave_duration = 1	-- Seconds
local shield_cd = 12		-- Seconds
local heal_duration = 3		-- Seconds
local heal_cd = 5			-- Seconds
local heal = 5				-- % Max Health

immortal_all_in_one = class({})
function immortal_all_in_one:IsHidden() return true end
function immortal_all_in_one:IsDebuff() return false end
function immortal_all_in_one:IsPurgable() return false end
function immortal_all_in_one:RemoveOnDeath() return false end
function immortal_all_in_one:OnCreated()
	if IsServer() then
		if not self:GetCaster():HasModifier("immortal_shield_cd") and not self:GetCaster():HasModifier("immortal_shield") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "immortal_shield", {})
		end
		self:StartIntervalThink(FrameTime())
	end
end
function immortal_all_in_one:OnIntervalThink()
	if IsServer() then
		if not self:GetCaster():HasModifier("immortal_shield_cd") and not self:GetCaster():HasModifier("immortal_shield") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "immortal_shield", {})
		end
	end
end
function immortal_all_in_one:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function immortal_all_in_one:GetModifierAttackRangeBonus(params)
	if self:GetParent():IsRangedAttacker() then
		return 200
	end
	return 0
end

function immortal_all_in_one:OnTakeDamage(event)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			if event.unit == self:GetCaster() then
				if self:GetCaster():HasModifier("immortal_shield") then
					self:GetCaster():RemoveModifierByName("immortal_shield")
					local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
					ParticleManager:SetParticleControlEnt(pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(pfx)
				end
			end
			if event.unit == self:GetCaster() then
				if self:GetCaster():GetHealth() <= 0 and RollPseudoRandom(grave_chance, self:GetAbility()) then
					self:GetCaster():SetHealth(1)
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "immortal_grave", {duration = grave_duration})
				end
			end
		end
		if event.unit == self:GetCaster() then
			if not self:GetCaster():HasModifier("immortal_heal_cd") then
				if event.damage > self:GetCaster():GetMaxHealth()*(40/100) then
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "immortal_heal", {duration = heal_duration})
				end
			end
		end
	end
end

function immortal_all_in_one:OnAbilityExecuted(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			if params.unit == self:GetParent() then
				if not params.ability:IsItem() and not params.ability:IsToggle() then
					if RollPercentage(10) then
						local target = FindUnitsInRadius(params.unit:GetTeam(), params.unit:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
						for i=1, #target do
							ParticleManager:CreateParticle("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, target[i])
							ParticleManager:CreateParticle("particles/items3_fx/mango_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, target[i])
							target[i]:Heal(target[i]:GetMaxHealth()*(5/100),params.unit)
							target[i]:GiveMana(target[i]:GetMaxMana()*(2/100))
						end
					end
				end
			end
		end
	end
	return 0
end

---------------------
-- Immortal Shield --
---------------------
immortal_shield = class({})
function immortal_shield:IsHidden() return true end
function immortal_shield:IsDebuff() return false end
function immortal_shield:IsPurgable() return false end
function immortal_shield:RemoveOnDeath() return true end
function immortal_shield:OnDestroy()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "immortal_shield_cd", {duration = shield_cd})
	end
end
function immortal_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_AVOID_DAMAGE}
end
function immortal_shield:GetModifierAvoidDamage() return 1 end
-- immortal_shield_cd
immortal_shield_cd = class({})
function immortal_shield_cd:IsHidden() return true end
function immortal_shield_cd:IsDebuff() return true end
function immortal_shield_cd:IsPurgable() return false end
function immortal_shield_cd:RemoveOnDeath() return true end

-------------------
-- Immortal Heal --
-------------------
immortal_heal = class({})
function immortal_heal:IsHidden() return false end
function immortal_heal:IsDebuff() return false end
function immortal_heal:IsPurgable() return true end
function immortal_heal:RemoveOnDeath() return true end
function immortal_heal:GetTexture() return "custom/immortal_heal" end
function immortal_heal:OnCreated()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "immortal_heal_cd", {duration = heal_cd})
	end
end
function immortal_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end
function immortal_heal:GetModifierHealthRegenPercentage(event) return heal end
function immortal_heal:GetEffectName() return "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf" end
-- immortal_heal_cd
immortal_heal_cd = class({})
function immortal_heal_cd:IsHidden() return true end
function immortal_heal_cd:IsDebuff() return true end
function immortal_heal_cd:IsPurgable() return false end
function immortal_heal_cd:RemoveOnDeath() return true end

--------------------
-- Immortal Grave --
--------------------
immortal_grave = class({})
function immortal_grave:IsHidden() return false end
function immortal_grave:IsDebuff() return false end
function immortal_grave:IsPurgable() return false end
function immortal_grave:RemoveOnDeath() return true end
function immortal_grave:GetTexture() return "custom/immortal_grave" end
function immortal_grave:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH}
end
function immortal_grave:GetMinHealth(event) return 1 end
function immortal_grave:GetEffectName() return "particles/econ/items/dazzle/dazzle_ti6/dazzle_ti6_shallow_grave.vpcf" end

-- immortal_spells_req_hp
immortal_spells_req_hp = class({})
function immortal_spells_req_hp:IsHidden() return false end
function immortal_spells_req_hp:IsDebuff() return false end
function immortal_spells_req_hp:IsPurgable() return false end
function immortal_spells_req_hp:RemoveOnDeath() return false end
function immortal_spells_req_hp:GetTexture() return "custom/spells_req_hp" end
function immortal_spells_req_hp:DeclareFunctions() return {MODIFIER_PROPERTY_SPELLS_REQUIRE_HP, MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function immortal_spells_req_hp:GetModifierSpellsRequireHP() return 1 end
function immortal_spells_req_hp:GetModifierPercentageManacostStacking() return -100 end
function immortal_spells_req_hp:GetModifierConstantHealthRegen() return self:GetCaster():GetManaRegen() end
