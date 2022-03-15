LinkLuaModifier("amalgamation_modifier", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_bonus", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)

------------------
-- Amalgamation --
------------------
amalgamation = class({})

function amalgamation:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	if self:GetCaster():HasModifier("amalgamation_modifier") then
		behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return behavior
end

function amalgamation:OnSpellStart()
	if self:GetCaster():HasModifier("amalgamation_modifier") then
		self:EndSymbiosis()
	else
		self:StartSymbiosis(self:GetCursorTarget())
	end
end

function amalgamation:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	local casterID = caster:GetPlayerOwnerID()
	local targetID = target:GetPlayerOwnerID()
	if caster == target then return UF_FAIL_CUSTOM end
	if caster:HasModifier("amalgamation_target") then return UF_FAIL_CUSTOM end
--	if target:IsCourier() then return UF_SUCCESS end
--	if target:HasAbility("life_stealer_infest") then return UF_FAIL_CUSTOM end
	if IsServer() and not target:IsOpposingTeam(caster:GetTeamNumber()) and PlayerResource:IsDisableHelpSetForPlayerID(targetID,casterID) then
		return UF_FAIL_DISABLE_HELP
	end

	return UnitFilter(target,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_CHECK_DISABLE_HELP,
		caster:GetTeamNumber())
end

function amalgamation:GetCustomCastErrorTarget(target)
	if self:GetCaster() == target then return "#DOTA_Error_amalgamation_no_self_target" end
--	if target:HasAbility("life_stealer_infest") then return "#DOTA_Error_amalgamation_no_infest_target" end
	if self:GetCaster():HasModifier("amalgamation_target") then return "#DOTA_Error_amalgamation_no_inception" end
end
function amalgamation:StartSymbiosis(target)
	if self:GetCaster():HasModifier("amalgamation_target") then return end
	EmitSoundOnLocationWithCaster(self:GetCaster():GetOrigin(), "Hero_Bane.Nightmare", self:GetCaster())
	local Modifier = target:AddNewModifier(self:GetCaster(), self, "amalgamation_target", {})
	local SymbiotModifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "amalgamation_modifier", {})
	SymbiotModifier:SetHost(target, Modifier)
	Modifier:InitSymbiot(SymbiotModifier)
	self:StartCooldown(1)
end

function amalgamation:EndSymbiosis()
	local SymbiotModifier = self:GetCaster():FindModifierByName("amalgamation_modifier")
	SymbiotModifier:Terminate(nil)
	self:UseResources(false, false, true)
end


---------------------------
-- Amalgamation Modifier --
---------------------------
amalgamation_modifier = class({})
function amalgamation_modifier:IsHidden() return false end
function amalgamation_modifier:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_modifier:AllowIllusionDuplicate() return false end
function amalgamation_modifier:GetModifierModelChange() return "models/development/invisiblebox.vmdl" end
function amalgamation_modifier:GetModifierInvisibilityLevel() return 1 end

function amalgamation_modifier:OnCreated(kv)
	if IsServer() then
--		self.Host = kv.target:GetParent()
		self:StartIntervalThink(FrameTime())
--		self.scale = self:GetParent():GetModelScale()
--		self:GetParent():SetModelScale(0.001)
	end
--	self.hasScepter = self:GetParent():HasScepter()
end

function amalgamation_modifier:SetHost(target, Modifier)
	self.Host = target
	self.Modifier = Modifier
--	local pos = self.Host:GetAbsOrigin()
--	local up = Vector(0,0,300)
--	self:GetParent():SetAbsOrigin(pos+up)
--	self:GetParent():Setparent(self.Host,"overhead_follow")
end

function amalgamation_modifier:OnDestroy()
	if IsServer() then
		if self.Modifier ~= nil then self.Modifier:Destroy() end
		self:GetParent():SetModelScale(self.scale)
		EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), "Hero_Bane.Nightmare.End", self:GetParent())
	end
end

function amalgamation_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
--		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_EVENT_ON_SPENT_MANA,
		MODIFIER_EVENT_ON_SET_LOCATION,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
end

function amalgamation_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
	}
	if (self.Host ~= nil) then
		state[MODIFIER_STATE_STUNNED] = self.Host:IsStunned()
		state[MODIFIER_STATE_SILENCED] = self.Host:IsSilenced()
		state[MODIFIER_STATE_MUTED] = self.Host:IsMuted()
		state[MODIFIER_STATE_COMMAND_RESTRICTED] = self.Host:IsCommandRestricted()
	end
	return state
end

function amalgamation_modifier:OnDeath(kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
		self:Destroy()
	end
end

function amalgamation_modifier:OnTakeDamage(kv)
	if IsServer() then
		if kv.unit ~= self.Host then return end
--		if self:GetAbility():GetCooldownTimeRemaining() < 3 then
--			self:GetAbility():StartCooldown(3)
--		end
	end
end
function amalgamation_modifier:OnSetLocation(kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
		local casterID = self:GetCaster():GetPlayerOwnerID()
		local targetID = self:GetParent():GetPlayerOwnerID()
		if PlayerResource:IsDisableHelpSetForPlayerID(targetID,casterID) then
			if self:GetAbility():IsCooldownReady() then
				self:Terminate(nil)
			end
		else
			if self.Host ~= nil and not self.Host:HasModifier("modifier_life_stealer_infest") then
				ProjectileManager:ProjectileDodge(self.Host)
				FindClearSpaceForUnit(self.Host,self:GetParent():GetOrigin(),true)
			end
		end
	end
end
function amalgamation_modifier:OnSpentMana(kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
		if self.Host == nil then return end
		local casterID = self:GetCaster():GetPlayerOwnerID()
		local targetID = self:GetParent():GetPlayerOwnerID()
		if PlayerResource:IsDisableHelpSetForPlayerID(targetID, casterID) then
			if self:GetAbility():IsCooldownReady() then
				self:Terminate(nil)
			end
		else
			local parent = self:GetParent()
		
			-- Tether semi-nerf, prevent players having hearts and giving massive health regen constantly
--			local tether = parent:FindAbilityByName("wisp_tether")
--			if tether then
--				tether:StartCooldown(60)
--			end

			local mana = self.Host:GetMana()
			if self.Host:GetMana() >= kv.cost then
				self.Host:SpendMana(kv.cost, kv.ability)
			else
				-- Using spells when the host has no mana burns the hosts health, either the cost of the spell or 20% of max health, whichever is higher
				local hpcost = kv.cost - mana
--				if hpcost < self.Host:GetMaxHealth() / 5 then
--					hpcost = self.Host:GetMaxHealth() / 5
--				end

				-- If hero is below 25% of health, you cannot use hosts health
--				if self.Host:GetHealth() < hpcost then
					self.Host:SetMana(0)
--				else
--					parent:SetMana(parent:GetMaxMana())
					local damage = {
						victim = self.Host,
						attacker = self:GetParent(),
						damage = hpcost,
						damage_type = DAMAGE_TYPE_PURE,
						ability = kv.ability,
						damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL
					}
					ApplyDamage(damage)
--				end
			end
			parent:SetMana(parent:GetMaxMana())
--			local mana = (parent:GetMana() / parent:GetMaxMana()) * self.Host:GetMaxMana()
--			self.Host:SetMana(mana);
		end
	end
end

function amalgamation_modifier:Terminate(attacker)
	if attacker then
		self:GetParent():Kill(self:GetAbility(), attacker)
	end
	self:Destroy()
end

function amalgamation_modifier:OnAttackLanded(kv)
	if IsServer() then
		if kv.attacker ~= self:GetParent() then return end
		if self.Host == nil then return end
		self.Modifier:Show(self:GetAbility():GetSpecialValueFor("vis_duration"))
	end
end

function amalgamation_modifier:OnAbilityExecuted(kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
		if self.Host == nil then return end
		self.Modifier:Show(self:GetAbility():GetSpecialValueFor("vis_duration"))
	end
end

function amalgamation_modifier:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():IsAlive() then self:Terminate(nil) end
		if self.Host == nil then return end
		local parent = self:GetParent()
--		local mana = (self.Host:GetMana() / self.Host:GetMaxMana()) * parent:GetMaxMana()
--		parent:SetMana(mana)
		local pos = self.Host:GetAbsOrigin()
		local up = Vector(0, 0, 0)
		parent:SetAbsOrigin(pos+up)
	end
end


------------------------
-- Amalgamation Bonus --
------------------------
amalgamation_bonus = class({})
function amalgamation_bonus:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function amalgamation_bonus:OnCreated(kv)
	if IsServer() then
		if kv.stacks ~= nil then
		    self:SetStackCount(kv.stacks)
		else
			self:SetStackCount(1)
		end
	end
end

function amalgamation_bonus:OnRefresh(kv)
	if IsServer() then
		if kv.stacks ~= nil then
			local stacks = self:GetStackCount() + kv.stacks
			self:SetStackCount(stacks)
		end
	end
end


-------------------------
-- Amalgamation Target --
-------------------------
amalgamation_target = class({})
function amalgamation_target:IsHidden() return false end
function amalgamation_target:AllowIllusionDuplicate() return false end
function amalgamation_target:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end
--[[
function amalgamation_target:OnCreated(kv)
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle("particles/spell_lab/symbiotic_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(self.nFXIndex, false, false, -1, false, true)

	end
end
]]
function amalgamation_target:InitSymbiot(Modifier)
	if IsServer() then
		self.symbiot = Modifier
		self.maxdistance = Modifier:GetAbility():GetSpecialValueFor("range_scepter")
	end
end

function amalgamation_target:OnDeath(kv)
	if IsServer() then
		if kv.unit == self:GetParent() then if self.symbiot ~= nil then self.symbiot:Terminate(kv.attacker) end return end
		if not self:GetParent():IsRealHero() then return end
		if not self:GetCaster():HasScepter() then return end
--		local stat = kv.unit:GetPrimaryAttribute()
		if kv.unit:IsRealHero() and kv.unit:GetTeam() ~= self:GetParent():GetTeam() then
			local dist = CalcDistanceBetweenEntityOBB(kv.unit, self:GetParent())
			if dist > self.maxdistance then return end
			local amount = self.symbiot:GetAbility():GetSpecialValueFor("stat_scepter")
			-- TODO: Make over head alerts right... they might be float values so these commented functions won't work.
--			if stat == 0 then
				self:GetParent():ModifyStrength(amount)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, self:GetParent(), amount, nil)
--			elseif stat == 1 then
				self:GetParent():ModifyAgility(amount)
--				SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), amount, nil)
--			elseif stat == 2 then
				self:GetParent():ModifyIntellect(amount)
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "amalgamation_bonus", {stacks = amount})
--				SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self:GetParent(), amount, nil)
--			end
		end
	end
end

function amalgamation_target:Show(time)
	if self:GetParent():IsInvisible() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_dustofappearance", {duration = time})
	end
end

function amalgamation_target:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function amalgamation_target:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus") end
end
function amalgamation_target:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus") end
end
function amalgamation_target:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus") end
end
function amalgamation_target:GetModifierPercentageManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function amalgamation_target:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("physical_armor") end
end
function amalgamation_target:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("magic_armor") end
end
