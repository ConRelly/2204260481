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
		self.forbidden_inflictors = {
			"item_blade_mail",
			"luna_moon_glaive"
		}
		self:StartIntervalThink(0.5)
		local parent = self:GetParent()
		local plyID = parent:GetPlayerID()
		
		piety = true
		if self:GetParent():GetUnitName() == "npc_dota_hero_lina" and not self:GetParent():HasModifier("modifier_sourcery") and self:GetParent():IsRealHero() and not self:GetParent():IsIllusion() and not piety then
			self:GetParent():AddItemByName("item_to_piety")
			piety = true
		end
		kardel = false
		if self:GetParent():GetUnitName() == "npc_dota_hero_sniper" and not self:GetParent():HasModifier("modifier_kardels_skills") and self:GetParent():IsRealHero() and not self:GetParent():IsIllusion() and not kardel then
			Notifications:Top(plyID, {text= "Sniper: You can type '-kardel' to get an item that allows you to change in kardel hero form.(for lvl 1 only)" , style={color="green"}, duration=15})
			--self:GetParent():AddItemByName("item_to_kardel")
			kardel = true
		end
	end
end
function modifier_generic_handler:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(math.floor(self:GetParent():GetCustomStackingCooldownReduction() * 100))
	end
	if self:GetParent():HasModifier("modifier_item_trusty_shovel") or self:GetParent():HasModifier("modifier_ritual_shovel") then
		_G.lopata = false
	end
end

-- Handler for Arc Warden / Meepo (if ported)
--[[ function modifier_generic_handler:OnAbilityFullyCast(keys)
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
end]]

function modifier_generic_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

--- Enum DamageCategory_t
-- DOTA_DAMAGE_CATEGORY_ATTACK = 1
-- DOTA_DAMAGE_CATEGORY_SPELL = 0
function modifier_generic_handler:OnTakeDamage(keys)
	if keys.attacker == self:GetParent() and not keys.unit:IsBuilding() and not keys.unit:IsOther() and keys.unit:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		local spell_heal = 15
		local normal_hit_heal = 8
-- Spell lifesteal handler
		if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and keys.inflictor and self:GetParent():GetSpellLifesteal() > 0 and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
			if RollPercentage(spell_heal) then
				for _, forbidden_inflictor in pairs(self.forbidden_inflictors) do
					if keys.inflictor:GetName() == forbidden_inflictor then return end
				end
				
				self.lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
				ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, keys.attacker:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
				if keys.unit:IsIllusion() then
					if keys.damage_type == DAMAGE_TYPE_PHYSICAL and keys.unit.GetPhysicalArmorValue and GetReductionFromArmor then
						keys.damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetPhysicalArmorValue(false)))
					elseif keys.damage_type == DAMAGE_TYPE_MAGICAL and keys.unit.GetMagicalArmorValue then
						keys.damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:Script_GetMagicalArmorValue(false, keys.unit)))
					elseif keys.damage_type == DAMAGE_TYPE_PURE then
						keys.damage = keys.original_damage
					end
				end
				-- Define the maximum healing limit
				local MAX_HEAL = 400000

				-- Calculate the healing amount
				local healAmount = math.max(keys.damage, 0) * self:GetParent():GetSpellLifesteal() * 0.01

				-- Limit the healing to the maximum value
				healAmount = math.min(healAmount, MAX_HEAL)

				-- Apply the healing
				keys.attacker:HealWithParams(healAmount, keys.inflictor, false, true, self:GetCaster(), true)				


				--keys.attacker:HealWithParams(math.max(keys.damage, 0) * self:GetParent():GetSpellLifesteal() * 0.01, keys.inflictor, false, true, self:GetCaster(), true)
--				keys.attacker:Heal(math.max(keys.damage, 0) * self:GetParent():GetSpellLifesteal() * 0.01, keys.attacker)
			end	
-- Pure spell lifesteal handler
		elseif keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and keys.inflictor and self:GetParent():GetPureSpellLifesteal() > 0 and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
			if RollPercentage(spell_heal) then
				for _, forbidden_inflictor in pairs(self.forbidden_inflictors) do
					if keys.inflictor:GetName() == forbidden_inflictor then return end
				end

				self.lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
				ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, keys.attacker:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
				-- Define the maximum healing limit
				local MAX_HEAL = 400000

				-- Calculate the healing amount
				local healAmount = math.max(keys.original_damage, 0) * self:GetParent():GetPureSpellLifesteal() * 0.01

				-- Limit the healing to the maximum value
				healAmount = math.min(healAmount, MAX_HEAL)
				-- == DEBUG PRINTS START ==

				local attacker_name = keys.attacker:GetUnitName()
				local current_hp = keys.attacker:GetHealth()
				local max_hp = keys.attacker:GetMaxHealth()
				local damage_val = math.max(keys.original_damage, 0) -- Use keys.original_damage for pure spell lifesteal
				local ls_percent = self:GetParent():GetPureSpellLifesteal() -- Or the relevant Get function for the block
				local calculated_heal_raw = damage_val * ls_percent * 0.01
				local capped_heal = math.min(calculated_heal_raw, MAX_HEAL) -- Assuming MAX_HEAL is defined above

--[[ 				print("-------------------- LIFESTEAL DEBUG --------------------")
				print("Attacker: " .. tostring(attacker_name))
				print("Attacker HP Before Heal: " .. string.format("%.2f", current_hp) .. " / " .. string.format("%.2f", max_hp))
				print("Source Damage (Original): " .. string.format("%.2f", damage_val))
				print("Lifesteal Percent (Pure Spell): " .. string.format("%.2f", ls_percent))
				print("Calculated Raw Heal Amount: " .. string.format("%.2f", calculated_heal_raw))
				print("Capped Heal Amount to Apply: " .. string.format("%.2f", capped_heal))
				print("Is Attacker currently at 1 HP? " .. tostring(current_hp == 1))
				print("---------------------------------------------------------") ]]

				-- == DEBUG PRINTS END ==

				-- Apply the healing
				keys.attacker:HealWithParams(healAmount, keys.inflictor, false, true, self:GetCaster(), true)
			
				
				--keys.attacker:HealWithParams(math.max(keys.original_damage, 0) * self:GetParent():GetPureSpellLifesteal() * 0.01, keys.inflictor, false, true, self:GetCaster(), true)
--				keys.attacker:Heal(math.max(keys.original_damage, 0) * self:GetParent():GetPureSpellLifesteal() * 0.01, keys.attacker)
			end	

-- Attack lifesteal handler
		elseif keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetLifesteal() > 0 then
			if RollPercentage(normal_hit_heal) then
				if not keys.attacker:IsRealHero() and (keys.attacker:GetMaxHealth() <= 0 or keys.attacker:GetHealth() <= 0) then
					keys.attacker:SetMaxHealth(keys.attacker:GetBaseMaxHealth())
					keys.attacker:SetHealth(1)
				end
				
				self.lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
				ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, keys.attacker:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
				
				if keys.unit:IsIllusion() and keys.unit.GetPhysicalArmorValue and GetReductionFromArmor then
					keys.damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetPhysicalArmorValue(false)))
				end
				-- Define the maximum healing limit
				local MAX_HEAL = 400000

				-- Calculate the healing amount
				local healAmount = math.max(keys.damage, 0) * self:GetParent():GetLifesteal() * 0.01

				-- Limit the healing to the maximum value
				healAmount = math.min(healAmount, MAX_HEAL)

				-- Apply the healing
				keys.attacker:HealWithParams(healAmount, keys.inflictor, false, true, self:GetCaster(), true)				

				--keys.attacker:HealWithParams(keys.damage * self:GetParent():GetLifesteal() * 0.01, keys.inflictor, true, true, self:GetCaster(), false)
--				keys.attacker:Heal(keys.damage * self:GetParent():GetLifesteal() * 0.01, keys.attacker)
			end	
-- Pure attack lifesteal handler
		elseif keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetPureLifesteal() > 0 then
			if RollPercentage(normal_hit_heal) then
				if not keys.attacker:IsRealHero() and (keys.attacker:GetMaxHealth() <= 0 or keys.attacker:GetHealth() <= 0) then
					keys.attacker:SetMaxHealth(keys.attacker:GetBaseMaxHealth())
					keys.attacker:SetHealth(1)
				end
				
				self.lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
				ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, keys.attacker:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
				-- Define the maximum healing limit
				local MAX_HEAL = 400000

				-- Calculate the healing amount
				local healAmount = math.max(keys.original_damage, 0) * self:GetParent():GetPureLifesteal() * 0.01

				-- Limit the healing to the maximum value
				healAmount = math.min(healAmount, MAX_HEAL)

				-- Apply the healing
				keys.attacker:HealWithParams(healAmount, keys.inflictor, false, true, self:GetCaster(), true)	
				
				--keys.attacker:HealWithParams(keys.original_damage * self:GetParent():GetPureLifesteal() * 0.01, keys.inflictor, true, true, self:GetCaster(), false)
--				keys.attacker:Heal(keys.original_damage * self:GetParent():GetPureLifesteal() * 0.01, keys.attacker)
			end
		end
	end
end

function modifier_generic_handler:GetModifierPreAttack_CriticalStrike()
	if IsServer() then
		local CritDMG = self:GetParent():GetCritDMG()
		DMG = 100 + CritDMG
		return DMG
	end
end

function modifier_generic_handler:GetModifierPercentageCooldown()
	return self:GetStackCount()
end

function modifier_generic_handler:GetModifierCooldownReduction_Constant()
	return talent_value(self:GetParent(), "special_bonus_unique_redution_cd")
end

function modifier_generic_handler:CheckState()
	if IsServer() then
		if self:GetParent().bAbsoluteNoCC then return end
		local disarm = nil
		local silence = nil
		local mute = nil
		if self:GetParent():HasTalent("special_bonus_unique_undisarmed") then
			disarm = false
		end
		if self:GetParent():HasTalent("special_bonus_unique_unsilenced") then
			silence = false
		end
		if self:GetParent():HasTalent("special_bonus_unique_unmuted") then
			mute = false
		end
	end
	return {
		[MODIFIER_STATE_DISARMED] = disarm,
		[MODIFIER_STATE_SILENCED] = silence,
		[MODIFIER_STATE_MUTED] = silence,
	}
end

--[[
function modifier_generic_handler:OnAttackStart(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() and (self:GetParent():IsIllusion() and self:GetParent():GetHealth() <= 0) or (self:GetParent().GetPlayerID and self:GetParent():GetPlayerID() == -1 and not self:GetParent():GetName() == "npc_dota_target_dummy") then
		self:GetParent():ForceKill(false)
		self:GetParent():RemoveSelf()
	end
end
]]
