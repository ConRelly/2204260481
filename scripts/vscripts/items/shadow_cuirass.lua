item_shadow_cuirass = class({})
LinkLuaModifier("modifier_seal_act", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_cuirass", "items/shadow_cuirass.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("heal_mod", "items/shadow_cuirass.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bmheal_mod", "items/shadow_cuirass.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_cuirass_echo", "items/shadow_cuirass.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_cuirass_echo_haste", "items/shadow_cuirass.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_cuirass_echo_debuff_slow", "items/shadow_cuirass.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_cuirass_echo_cd", "items/shadow_cuirass.lua", LUA_MODIFIER_MOTION_NONE)

local interval = FrameTime()
function item_shadow_cuirass:OnSpellStart()
 	if IsServer() then
		local caster = self:GetCaster()
		local sacrifice_pct = self:GetSpecialValueFor("sacrifice_pct")
		local heal_duration = self:GetSpecialValueFor("heal_duration")
		self.self_damage = caster:GetMaxHealth() * sacrifice_pct / 100
		local fx_bs = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_shadow_strike_body.vpcf", PATTACH_ABSORIGIN, caster)
		ApplyDamage({victim = caster, attacker = caster, damage = self.self_damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL, ability = self})
		caster:RemoveModifierByName("bmheal_mod")
		caster:RemoveModifierByName("heal_mod")

		--UP: Blade Mail
		if caster:HasModifier("modifier_item_blade_mail") then
			caster:AddNewModifier(caster, self, "bmheal_mod", {duration = heal_duration, heal_duration = heal_duration})
		
		else------------

			caster:AddNewModifier(caster, self, "heal_mod", {duration = heal_duration, heal_duration = heal_duration})
		end
 	end
end
function item_shadow_cuirass:GetIntrinsicModifierName() return "modifier_shadow_cuirass" end

--------------------------------------------------------------------------------
modifier_shadow_cuirass = class({})
function modifier_shadow_cuirass:IsHidden() return true end
function modifier_shadow_cuirass:GetEffectName() return "particles/custom/items/shadow_cuirass/shadow_cuirass.vpcf" end
function modifier_shadow_cuirass:IsPurgable() return false end
function modifier_shadow_cuirass:RemoveOnDeath() return false end
function modifier_shadow_cuirass:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_shadow_cuirass:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_shadow_cuirass:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end
end
function modifier_shadow_cuirass:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("agi") end
end
function modifier_shadow_cuirass:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_shadow_cuirass:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_shadow_cuirass:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_shadow_cuirass:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_shadow_cuirass:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen") end
end
function modifier_shadow_cuirass:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		Timers:CreateTimer(interval, function()
			caster:AddNewModifier(caster, ability, "modifier_seal_act", {})
		end)
		self.reflect = self:GetAbility():GetSpecialValueFor("reflect")
		if not self:GetAbility() then self:Destroy() return end
		self.echo_modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_shadow_cuirass_echo", {})
	end
end
function modifier_shadow_cuirass:OnAttackLanded(kv)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = kv.attacker
		if attacker == caster then
			if not caster:IsIllusion() then
				caster.att_target = kv.target
			end
		end
	end
end
function modifier_shadow_cuirass:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local damage_type = params.damage_type
		local reflect_damage = damage * (self.reflect / 100)
		if attacker ~= nil and target == caster and reflect_damage ~= 0 then
			if not caster:IsIllusion() then
				if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
					local wb = ParticleManager:CreateParticle("particles/custom/items/shadow_cuirass/shadow_cuirass_bm_reflect.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControlEnt(wb, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetOrigin(), true)
					ApplyDamage({ 
						victim = attacker,
						attacker = caster,
						damage = reflect_damage,
						damage_type = damage_type,
						damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
						ability = self:GetAbility()
					})
				end

				--UP: Blade Mail
				if caster:HasModifier("modifier_item_blade_mail") then
					if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
						if caster:GetAttackCapability() == 1 then
							if caster.att_target ~= nil then
								if caster.att_target ~= caster then
									local sw = ParticleManager:CreateParticle("particles/custom/items/shadow_sword/reflect.vpcf", PATTACH_ABSORIGIN, caster.att_target)
									ParticleManager:SetParticleControlEnt(sw, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), true)
									ApplyDamage({
										victim = caster.att_target,
										attacker = caster,
										damage = reflect_damage,
										damage_type = DAMAGE_TYPE_PURE,
										damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
										ability = self:GetAbility()
									})
								end
							end
						end
					end
				else
				----------------

					if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
						if caster:GetAttackCapability() == 1 then
							if caster.att_target ~= nil then
								if caster.att_target ~= caster then
									local sw = ParticleManager:CreateParticle("particles/custom/items/shadow_sword/reflect.vpcf", PATTACH_ABSORIGIN, caster.att_target)
									ParticleManager:SetParticleControlEnt(sw, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), true)
									ApplyDamage({
										victim = caster.att_target,
										attacker = caster,
										damage = reflect_damage,
										damage_type = DAMAGE_TYPE_PURE,
										damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
										ability = self:GetAbility()
									})
								end
							end
						end
					end
				end
			end
		end
	end
end
function modifier_shadow_cuirass:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		caster:RemoveModifierByName("modifier_seal_act")
	end
	if self.echo_modifier then
		if self.echo_modifier:IsNull() then return end
		self.echo_modifier:Destroy()
	end
end

------------------------------------------------------------------------------------------------------------------------
heal_mod = class({})
function heal_mod:IsPurgable() return true end
function heal_mod:RemoveOnDeath() return true end
function heal_mod:GetTexture() return "custom/shadow_cuirass" end
function heal_mod:OnCreated(keys)
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.heal_duration = keys.heal_duration
		self:StartIntervalThink(interval)
	end
end
function heal_mod:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local heal_pct = self:GetAbility():GetSpecialValueFor("heal_pct")
		local bmheal_pct = self:GetAbility():GetSpecialValueFor("bmheal_pct")
		local heal_per_interval = self:GetCaster():GetMaxHealth() * heal_pct / self.heal_duration / 100 * interval
		local bmheal_per_interval = self:GetCaster():GetMaxHealth() * bmheal_pct / self.heal_duration / 100 * interval

		--UP: Blade Mail
		if caster:HasModifier("modifier_item_blade_mail") then
			caster:Heal(bmheal_per_interval, caster)

		else------------

			caster:Heal(heal_per_interval, caster)
		end
	end
end
function heal_mod:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function heal_mod:OnTooltip() return self:GetAbility():GetSpecialValueFor("heal_pct") end

------------------------------------------------------------------------------------------------------------------------
bmheal_mod = class({})
function bmheal_mod:IsPurgable() return true end
function bmheal_mod:RemoveOnDeath() return true end
function bmheal_mod:GetTexture() return "custom/shadow_cuirass" end
function bmheal_mod:OnCreated(keys)
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.heal_duration = keys.heal_duration
		self:StartIntervalThink(interval)
	end
end
function bmheal_mod:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local bmheal_pct = self:GetAbility():GetSpecialValueFor("bmheal_pct")
		local bmheal_per_interval = self:GetCaster():GetMaxHealth() * bmheal_pct / self.heal_duration / 100 * interval
		caster:Heal(bmheal_per_interval, caster)
	end
end
function bmheal_mod:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function bmheal_mod:OnTooltip() return self:GetAbility():GetSpecialValueFor("bmheal_pct") end

------------------------------------------------------------------------------------------------------------------------
modifier_shadow_cuirass_echo = modifier_shadow_cuirass_echo or class({})
function modifier_shadow_cuirass_echo:IsHidden() return true end
function modifier_shadow_cuirass_echo:IsPurgable() return false end
function modifier_shadow_cuirass_echo:RemoveOnDeath() return false end
function modifier_shadow_cuirass_echo:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_shadow_cuirass_echo:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	local item = self:GetAbility()
	self.parent = self:GetParent()
end
function modifier_shadow_cuirass_echo:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_START } end
function modifier_shadow_cuirass_echo:OnAttackStart(keys)
	local item = self:GetAbility()
	local parent = self:GetParent()
	if keys.attacker == parent and item and not parent:IsIllusion() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self and not self:GetParent():HasModifier("modifier_shadow_cuirass_echo_cd") then
--		item:UseResources(false,false,true)
		parent:AddNewModifier(parent, item, "modifier_shadow_cuirass_echo_haste", {})
		if not keys.target:IsBuilding() and not keys.target:IsOther() then
			keys.target:AddNewModifier(self.parent, self:GetAbility(), "modifier_shadow_cuirass_echo_debuff_slow", {duration = self:GetAbility():GetSpecialValueFor("duration")})
		end
		if parent:HasModifier("modifier_shadow_cuirass_echo_haste") then
			local mod = parent:FindModifierByName("modifier_shadow_cuirass_echo_haste")
			mod:DecrementStackCount()
			if mod:GetStackCount() < 1 then
				if mod:IsNull() then return end
				mod:Destroy()
			end
		end
	end
end
function modifier_shadow_cuirass_echo:OnRemoved()
	if not IsServer() then return end
	if (self:GetParent():FindModifierByName("modifier_shadow_cuirass_echo_haste")) then
		self:GetParent():FindModifierByName("modifier_shadow_cuirass_echo_haste"):Destroy()
	end
end

-------------------------------------------
modifier_shadow_cuirass_echo_haste = modifier_shadow_cuirass_echo_haste or class({})
function modifier_shadow_cuirass_echo_haste:IsDebuff() return false end
function modifier_shadow_cuirass_echo_haste:IsHidden() return true end
function modifier_shadow_cuirass_echo_haste:IsPurgable() return false end
function modifier_shadow_cuirass_echo_haste:IsPurgeException() return false end
function modifier_shadow_cuirass_echo_haste:IsStunDebuff() return false end
function modifier_shadow_cuirass_echo_haste:RemoveOnDeath() return true end
function modifier_shadow_cuirass_echo_haste:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	local item = self:GetAbility()
	self.parent = self:GetParent()
	if item then
		self.duration = item:GetSpecialValueFor("duration")
		local max_hits = 2
		self:SetStackCount(max_hits)
		self.attack_speed_buff = math.max(item:GetSpecialValueFor("attack_speed_buff"), self.parent:GetIncreasedAttackSpeed() * 3)
	end
end
function modifier_shadow_cuirass_echo_haste:OnRefresh() self:OnCreated() end
function modifier_shadow_cuirass_echo_haste:DeclareFunctions() return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK } end
function modifier_shadow_cuirass_echo_haste:OnAttack(keys)
	if self.parent == keys.attacker then
		keys.target:AddNewModifier(self.parent, self:GetAbility(), "modifier_shadow_cuirass_echo_debuff_slow", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_cuirass_echo_cd", {duration = self:GetAbility():GetSpecialValueFor("echo_cd")})
	end
end
function modifier_shadow_cuirass_echo_haste:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("attack_speed_buff") end

-------------------------------------------
modifier_shadow_cuirass_echo_debuff_slow = modifier_shadow_cuirass_echo_debuff_slow or class({})
function modifier_shadow_cuirass_echo_debuff_slow:IsDebuff() return true end
function modifier_shadow_cuirass_echo_debuff_slow:IsHidden() return false end
function modifier_shadow_cuirass_echo_debuff_slow:IsPurgable() return true end
function modifier_shadow_cuirass_echo_debuff_slow:IsStunDebuff() return false end
function modifier_shadow_cuirass_echo_debuff_slow:RemoveOnDeath() return true end
function modifier_shadow_cuirass_echo_debuff_slow:GetTexture() return "custom/shadow_cuirass" end
function modifier_shadow_cuirass_echo_debuff_slow:DeclareFunctions() return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_shadow_cuirass_echo_debuff_slow:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	local item = self:GetAbility()
	if item then
		self.slow = item:GetSpecialValueFor("slow_speed") * (-1)
	end
end
function modifier_shadow_cuirass_echo_debuff_slow:GetModifierAttackSpeedBonus_Constant() return self.slow end
function modifier_shadow_cuirass_echo_debuff_slow:GetModifierMoveSpeedBonus_Percentage() return self.slow end

-------------------------------------------
modifier_shadow_cuirass_echo_cd = modifier_shadow_cuirass_echo_cd or class({})
function modifier_shadow_cuirass_echo_cd:IgnoreTenacity() return true end
function modifier_shadow_cuirass_echo_cd:IsPurgable() return false end
function modifier_shadow_cuirass_echo_cd:IsDebuff() return true end
function modifier_shadow_cuirass_echo_cd:RemoveOnDeath() return false end
function modifier_shadow_cuirass_echo_cd:IsHidden() return true end
function modifier_shadow_cuirass_echo_cd:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK} end
function modifier_shadow_cuirass_echo_cd:OnAttack(keys)
	self:GetCaster():RemoveModifierByName("modifier_shadow_cuirass_echo_haste")
end
