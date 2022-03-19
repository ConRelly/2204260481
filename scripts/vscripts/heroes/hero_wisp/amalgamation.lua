LinkLuaModifier("amalgamation_modifier", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_magic_armor", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_phys_armor", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
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
function amalgamation:GetManaCost(lvl)
	if self:GetCaster():HasModifier("amalgamation_modifier") then
		return 0
	end
	return 0--self.BaseClass.GetManaCost(self, lvl)
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
	if caster:HasModifier("modifier_life_stealer_infest") then return UF_FAIL_CUSTOM end
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
	if self:GetCaster() == target then return "#dota_hud_error_cant_cast_on_self" end
	if self:GetCaster():HasModifier("amalgamation_target") then return "#DOTA_Error_amalgamation_no_inception" end
	if self:GetCaster():HasModifier("modifier_life_stealer_infest") then return "#DOTA_Error_amalgamation_no_inception" end
end

function amalgamation:StartSymbiosis(target)
	local caster = self:GetCaster()
	if caster:HasModifier("amalgamation_target") then return end
	EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Bane.Nightmare", caster)

	local Modifier = target:AddNewModifier(caster, self, "amalgamation_target", {})
	local SymbiotModifier = caster:AddNewModifier(caster, self, "amalgamation_modifier", {})
	SymbiotModifier:SetHost(target, Modifier)
	Modifier:InitSymbiot(SymbiotModifier)
--	Timers:CreateTimer(FrameTime(), function()
		self:EndCooldown()
		self:StartCooldown(1)
--	end)
end

function amalgamation:EndSymbiosis()
	local SymbiotModifier = self:GetCaster():FindModifierByName("amalgamation_modifier")
	SymbiotModifier:Terminate(nil)
	self:UseResources(false, false, true)
end


-------------------------
-- Amalgamation Caster --
-------------------------
amalgamation_modifier = class({})
function amalgamation_modifier:IsHidden() return true end
function amalgamation_modifier:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_modifier:AllowIllusionDuplicate() return false end
function amalgamation_modifier:GetModifierModelChange() return "models/development/invisiblebox.vmdl" end
function amalgamation_modifier:GetModifierInvisibilityLevel() return 1 end
function amalgamation_modifier:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA + 11111 end

function amalgamation_modifier:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
--		self.scale = self:GetParent():GetModelScale()
--		self:GetParent():SetModelScale(0.001)
	end
end

function amalgamation_modifier:OnDestroy()
	if IsServer() then
		if self.Modifier ~= nil then self.Modifier:Destroy() end
--		self:GetParent():SetModelScale(self.scale)
		EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), "Hero_Bane.Nightmare.End", self:GetParent())
	end
end

function amalgamation_modifier:SetHost(target, Modifier)
	self.Host = target
	self.Modifier = Modifier
	local AbdPos = self.Host:GetAbsOrigin()
--	local up = Vector(0,0,0)
	self:GetParent():SetAbsOrigin(AbdPos)
end

function amalgamation_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_SPENT_MANA,
		MODIFIER_EVENT_ON_SET_LOCATION,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function amalgamation_modifier:OnStackCountChanged(old)
	if IsServer() then self:GetParent():CalculateStatBonus(true) end
end
function amalgamation_modifier:GetModifierManaBonus()
	if self:GetAbility() then return self:GetStackCount() end
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
		if self:GetAbility():GetCooldownTimeRemaining() < 1 then
			self:GetAbility():StartCooldown(1)
		end
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
		local parent = self:GetParent()
		local ability = kv.ability
		if kv.unit ~= parent then return end
		if self.Host == nil then return end
--		if ability and ability:GetAbilityName() == "amalgamation" then return end
		if kv.cost <= 0 then return end
		local casterID = self:GetCaster():GetPlayerOwnerID()
		local targetID = self.Host:GetPlayerOwnerID()
		local mana = self.Host:GetMana()
		if self.Host:GetMana() >= kv.cost then
			self.Host:SpendMana(kv.cost, nil)
		else
			local hpcost = kv.cost - mana
			self.Host:SetMana(0)
			ApplyDamage({
				victim = self.Host,
				attacker = parent,
				damage = hpcost,
				damage_type = DAMAGE_TYPE_PURE,
				ability = nil,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL
			})
		end
		parent:SetMana(parent:GetMaxMana())
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
		local AbdPos = self.Host:GetAbsOrigin()
--		local up = Vector(0,0,0)
		self:GetParent():SetAbsOrigin(AbdPos)
		self:SetStackCount(self.Host:GetMaxMana())
	end
end


-------------------------
-- Amalgamation Target --
-------------------------
amalgamation_target = class({})
function amalgamation_target:IsHidden() return false end
function amalgamation_target:AllowIllusionDuplicate() return false end
function amalgamation_target:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end

function amalgamation_target:OnCreated()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end
function amalgamation_target:OnDestroy()
	if IsServer() then
		if self:GetParent():HasModifier("amalgamation_target_magic_armor") then
			self:GetParent():RemoveModifierByName("amalgamation_target_magic_armor")
		end
		if self:GetParent():HasModifier("amalgamation_target_phys_armor") then
			self:GetParent():RemoveModifierByName("amalgamation_target_phys_armor")
		end
	end
end
function amalgamation_target:OnIntervalThink()
	if IsServer() then
		local HostMagicResist = math.floor(self:GetCaster():GetMagicalArmorValue() * self:GetAbility():GetSpecialValueFor("magic_armor"))
		local HostArmor = math.floor(self:GetCaster():GetPhysicalArmorValue(false) * self:GetAbility():GetSpecialValueFor("physical_armor") / 100)
		local HostMagicResist_Modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "amalgamation_target_magic_armor", {})
		HostMagicResist_Modifier:SetStackCount(HostMagicResist)

		local HostArmor_Modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "amalgamation_target_phys_armor", {})
		HostArmor_Modifier:SetStackCount(HostArmor)

		local casterID = self:GetCaster():GetPlayerOwnerID()
		local targetID = self:GetParent():GetPlayerOwnerID()
		if PlayerResource:IsDisableHelpSetForPlayerID(targetID, casterID) then
			local amalgamation_modifier = self:GetCaster():FindModifierByName("amalgamation_modifier")
			amalgamation_modifier:Terminate(nil)
		end
	end
end

function amalgamation_target:InitSymbiot(Modifier)
	if IsServer() then
		self.symbiot = Modifier
		self.maxdistance = Modifier:GetAbility():GetSpecialValueFor("range_scepter")
	end
end

function amalgamation_target:Show(time)
	if self:GetParent():IsInvisible() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_dustofappearance", {duration = time})
	end
end

function amalgamation_target:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE}
end

function amalgamation_target:OnDeath(kv)
	if IsServer() then
		if kv.unit == self:GetParent() then if self.symbiot ~= nil then self.symbiot:Terminate(kv.attacker) end return end
		if not self:GetParent():IsRealHero() then return end
		if not self:GetCaster():HasScepter() then return end
--		local stat = kv.unit:GetPrimaryAttribute()
		if kv.unit:GetTeam() ~= self:GetParent():GetTeam() then
			local dist = CalcDistanceBetweenEntityOBB(kv.unit, self:GetParent())
			if dist > self.maxdistance then return end
			local amount = self.symbiot:GetAbility():GetSpecialValueFor("stat_scepter")
--			if stat == 0 then
				self:GetParent():ModifyStrength(amount)
--			elseif stat == 1 then
				self:GetParent():ModifyAgility(amount)
--			elseif stat == 2 then
				self:GetParent():ModifyIntellect(amount)
--			end
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "amalgamation_bonus", {})
		end
	end
end

function amalgamation_target:GetModifierTotalPercentageManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end


-----------------------------------
-- Amalgamation Target Reduction --
-----------------------------------
amalgamation_target_magic_armor = class({})
function amalgamation_target_magic_armor:IsHidden() return true end
function amalgamation_target_magic_armor:RemoveOnDeath() return false end
function amalgamation_target_magic_armor:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_magic_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function amalgamation_target_magic_armor:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetStackCount() end
end

amalgamation_target_phys_armor = class({})
function amalgamation_target_phys_armor:IsHidden() return true end
function amalgamation_target_phys_armor:RemoveOnDeath() return false end
function amalgamation_target_phys_armor:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_phys_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function amalgamation_target_phys_armor:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetStackCount() end
end


------------------------
-- Amalgamation Bonus --
------------------------
amalgamation_bonus = class({})
function amalgamation_bonus:RemoveOnDeath() return false end
function amalgamation_bonus:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function amalgamation_bonus:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(1)
	end
end

function amalgamation_bonus:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(self:GetStackCount() + 1)
	end
end

function amalgamation_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function amalgamation_bonus:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stat_scepter") end
end
