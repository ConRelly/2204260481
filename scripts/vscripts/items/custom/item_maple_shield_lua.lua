item_maple_shield_lua = class({})
LinkLuaModifier("modifier_maple_shield_lua", "items/custom/item_maple_shield_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maple_shield_lua_aura", "items/custom/item_maple_shield_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maple_shield_lua_aura_triger", "items/custom/item_maple_shield_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maple_shield_lua_aura_limiter", "items/custom/item_maple_shield_lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_maple_shield_lua:GetIntrinsicModifierName() return "modifier_maple_shield_lua" end
function item_maple_shield_lua:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		if (caster:GetPrimaryAttribute() == 1 or caster:GetPrimaryAttribute() == 2) or caster:HasModifier("modifier_maple_shield_lua_aura_limiter") or (caster:GetUnitName() == "npc_dota_hero_brewmaster") then
			self:EndCooldown()
			self:StartCooldown(5)
			return nil
		end
		local duration = self:GetSpecialValueFor("duration")
		local lim_duration = math.ceil(duration * 2.5)

		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_maple_shield_lua_aura_triger", {duration = duration})
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_maple_shield_lua_aura_limiter", {duration = lim_duration})
	end
end

--------------------------------------------------------------------------------
modifier_maple_shield_lua = class({})
function modifier_maple_shield_lua:IsHidden() return true end
function modifier_maple_shield_lua:IsDebuff() return false end
function modifier_maple_shield_lua:IsPurgable() return false end
function modifier_maple_shield_lua:OnCreated(kv)
	local caster = self:GetCaster()
	--if caster:GetPrimaryAttribute() ~= 0 then return nil end
	self.xp_boost = 0
	self.armor_str_multiplier = self:GetAbility():GetSpecialValueFor("armor_str_multiplier")
	self.hp_spell_multiplier = self:GetAbility():GetSpecialValueFor("hp_spell_multiplier")
	self.bonus_str = self:GetAbility():GetSpecialValueFor("bonus_str") 
	self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
	self.status = self:GetAbility():GetSpecialValueFor("status_resit")
	self.magic_resit = self:GetAbility():GetSpecialValueFor("magic_resit")   
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
	self.mana_bonus = self:GetAbility():GetSpecialValueFor("mana_bonus")
	self.primary = false
	self.armor_bonus = math.floor(self:GetParent():GetStrength() * self.armor_str_multiplier)
	if IsServer() then	
		if caster:GetPrimaryAttribute() == 0 then
			self.primary = true
		end
	end
	if self.primary then
		self.xp_boost = self:GetAbility():GetSpecialValueFor("xp_boost")
		self.hp_spell_multiplier = self:GetAbility():GetSpecialValueFor("hp_spell_multiplier") * 2
		self.bonus_str = self:GetAbility():GetSpecialValueFor("bonus_str") * 2
	end
	self:StartIntervalThink(10)
end

function modifier_maple_shield_lua:OnIntervalThink()
	self:OnCreated()	
end
function modifier_maple_shield_lua:OnRefresh(kv)
	-- references
	--self:OnCreated(kv)
end
function modifier_maple_shield_lua:OnDestroy() end

function modifier_maple_shield_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_EXP_RATE_BOOST,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS
	}
end
function modifier_maple_shield_lua:GetModifierPhysicalArmorBonus()
	return self.armor_bonus
end


function modifier_maple_shield_lua:GetModifierHealthBonus()
	return math.floor(self:GetParent():GetSpellAmplification(false) * self.hp_spell_multiplier)
end
function modifier_maple_shield_lua:GetModifierStatusResistanceStacking() return self.status end
function modifier_maple_shield_lua:GetModifierPercentageExpRateBoost() return self.xp_boost end
function modifier_maple_shield_lua:GetModifierMagicalResistanceBonus() return self.magic_resit end
function modifier_maple_shield_lua:GetModifierBonusStats_Strength() return self.bonus_str end
function modifier_maple_shield_lua:GetModifierSpellAmplify_Percentage() return self.spell_amp end
function modifier_maple_shield_lua:GetModifierManaBonus() return self.mana_bonus end

function modifier_maple_shield_lua:IsAura() return HasAuraActive(self:GetCaster()) end
function modifier_maple_shield_lua:GetModifierAura() return "modifier_maple_shield_lua_aura" end
function modifier_maple_shield_lua:GetAuraRadius() return self.aura_radius end
function modifier_maple_shield_lua:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function modifier_maple_shield_lua:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function modifier_maple_shield_lua:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function modifier_maple_shield_lua:GetAuraEntityReject(hEntity)
	-- Those that also has this modifier will not receive shield aura
	if hEntity and hEntity:HasModifier("modifier_maple_shield_lua") or hEntity:HasModifier("modifier_maple_shield_lua_aura_limiter") then
		return true
	end
	return false
end

--------------------------------------------------------------------------------
modifier_maple_shield_lua_aura = class({})
function modifier_maple_shield_lua_aura:IsHidden() return false end
function modifier_maple_shield_lua_aura:IsDebuff() return false end
function modifier_maple_shield_lua_aura:IsPurgable() return false end
function modifier_maple_shield_lua_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_maple_shield_lua_aura:GetModifierIncomingDamage_Percentage(params)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local attacker = params.attacker

	-- shift damage to owner
	local damageTable = {
		attacker = attacker,
		damage = params.original_damage,
		damage_type = params.damage_type,
		victim = caster,
	}
	ApplyDamage(damageTable)

	-- Person takes no damage
	return -100
end

modifier_maple_shield_lua_aura_triger = class({})
function modifier_maple_shield_lua_aura_triger:IsHidden() return false end
function modifier_maple_shield_lua_aura_triger:IsDebuff() return false end
function modifier_maple_shield_lua_aura_triger:IsPurgable() return false end
function modifier_maple_shield_lua_aura_triger:RemoveOnDeath() return false end
function modifier_maple_shield_lua_aura_triger:OnCreated()
	if IsServer() then
		self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
		local caster = self:GetParent()
		if caster:HasModifier("modifier_super_scepter") then
			if caster:HasModifier("modifier_marci_unleash_flurry") then
				self.chance = self:GetAbility():GetSpecialValueFor("block_chance_marci")
			end                                 
		end		
	end	
end
function modifier_maple_shield_lua_aura_triger:OnDestroy() end
function modifier_maple_shield_lua_aura_triger:CheckState()
	return {[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED ] = true}
end
function modifier_maple_shield_lua_aura_triger:DeclareFunctions()
	return {MODIFIER_PROPERTY_AVOID_DAMAGE, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE}
end
function modifier_maple_shield_lua_aura_triger:GetModifierAvoidDamage(params)
	if IsServer() then
		if RollPercentage(self.chance) then
			local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:ReleaseParticleIndex(iParticleID)
			return 1
	   -- else
		--	return 0
		end   
	end	
end

function modifier_maple_shield_lua_aura_triger:GetAbsoluteNoDamagePure()  
    return 1
end

function HasAuraActive(npc)
	local modifier_active_aura = "modifier_maple_shield_lua_aura_triger"
	if npc:HasModifier(modifier_active_aura) then
		return true 
	end
	return false	
end 

modifier_maple_shield_lua_aura_limiter = class({})
function modifier_maple_shield_lua_aura_limiter:IsHidden() return false end
function modifier_maple_shield_lua_aura_limiter:IsDebuff() return true end
function modifier_maple_shield_lua_aura_limiter:IsPurgable() return false end
function modifier_maple_shield_lua_aura_limiter:RemoveOnDeath() return false end
function modifier_maple_shield_lua_aura_limiter:OnCreated() if IsServer() then end	end
function modifier_maple_shield_lua_aura_limiter:OnDestroy() end
