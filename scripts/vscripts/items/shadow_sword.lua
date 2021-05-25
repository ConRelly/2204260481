----------------
--SHADOW SWORD--
----------------
LinkLuaModifier("modifier_shadow_sword_1", "items/shadow_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_shadow_sword == nil then item_shadow_sword = class({}) end
function item_shadow_sword:GetIntrinsicModifierName() return "modifier_shadow_sword_1" end

if modifier_shadow_sword_1 == nil then modifier_shadow_sword_1 = class({}) end
function modifier_shadow_sword_1:IsHidden() return true end
function modifier_shadow_sword_1:IsPurgable() return false end
function modifier_shadow_sword_1:RemoveOnDeath() return false end
function modifier_shadow_sword_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_shadow_sword_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_shadow_sword_1:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_shadow_sword_1:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_shadow_sword_1:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_shadow_sword_1:OnAttackLanded(kv)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = kv.attacker
		if not caster:HasModifier("modifier_kingsbane") and not caster:HasModifier("modifier_shadow_cuirass") then
			if attacker == caster then
				if not caster:IsIllusion() then
					caster.att_target = kv.target
				end
			end
		end
	end
end
function modifier_shadow_sword_1:OnTakeDamage(params)
	if IsServer() then
		local reflect = self:GetAbility():GetSpecialValueFor("reflect")
		local caster = self:GetCaster()
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local reflect_damage = damage * (reflect / 100)
		if not caster:HasModifier("modifier_kingsbane") and not caster:HasModifier("modifier_shadow_cuirass") then
			if attacker ~= nil and target == caster and reflect_damage ~= 0 then
				if not caster:IsIllusion() then
					if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
						if caster:GetAttackCapability() == 1 then
							if caster.att_target ~= nil then
								if caster.att_target ~= caster then
									local sw = ParticleManager:CreateParticle("particles/custom/items/shadow_sword/reflect.vpcf", PATTACH_ABSORIGIN, caster.att_target)
									ParticleManager:SetParticleControlEnt(sw, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), true)
									ApplyDamage({victim = caster.att_target, attacker = caster, damage = reflect_damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, ability = self:GetAbility()})
								end
							end
						end
					end
				end
			end
		end
	end
end

-----------------
--SHADOW SWORD2--
-----------------
LinkLuaModifier("modifier_shadow_sword_2", "items/shadow_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_shadow_sword_2 == nil then item_shadow_sword_2 = class({}) end
function item_shadow_sword_2:GetIntrinsicModifierName() return "modifier_shadow_sword_2" end

if modifier_shadow_sword_2 == nil then modifier_shadow_sword_2 = class({}) end
function modifier_shadow_sword_2:IsHidden() return true end
function modifier_shadow_sword_2:IsPurgable() return false end
function modifier_shadow_sword_2:RemoveOnDeath() return false end
function modifier_shadow_sword_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_shadow_sword_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_shadow_sword_2:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_shadow_sword_2:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_shadow_sword_2:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_shadow_sword_2:OnAttackLanded(kv)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = kv.attacker
		if not caster:HasModifier("modifier_kingsbane") and not caster:HasModifier("modifier_shadow_cuirass") then
			if attacker == caster then
				if not caster:IsIllusion() then
					caster.att_target = kv.target
				end
			end
		end
	end
end
function modifier_shadow_sword_2:OnTakeDamage(params)
	if IsServer() then
		local reflect = self:GetAbility():GetSpecialValueFor("reflect")
		local caster = self:GetCaster()
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local reflect_damage = damage * (reflect / 100)
		if not caster:HasModifier("modifier_kingsbane") and not caster:HasModifier("modifier_shadow_cuirass") then
			if attacker ~= nil and target == caster and reflect_damage ~= 0 then
				if not caster:IsIllusion() then
					if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
						if caster:GetAttackCapability() == 1 then
							if caster.att_target ~= nil then
								if caster.att_target ~= caster then
									local sw = ParticleManager:CreateParticle("particles/custom/items/shadow_sword/reflect.vpcf", PATTACH_ABSORIGIN, caster.att_target)
									ParticleManager:SetParticleControlEnt(sw, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), true)
									ApplyDamage({victim = caster.att_target, attacker = caster, damage = reflect_damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()})
								end
							end
						end
					end
				end
			end
		end
	end
end

-----------------
--SHADOW SWORD3--
-----------------
LinkLuaModifier("modifier_shadow_sword_3", "items/shadow_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_shadow_sword_3 == nil then item_shadow_sword_3 = class({}) end
function item_shadow_sword_3:GetIntrinsicModifierName() return "modifier_shadow_sword_3" end

if modifier_shadow_sword_3 == nil then modifier_shadow_sword_3 = class({}) end
function modifier_shadow_sword_3:IsHidden() return true end
function modifier_shadow_sword_3:IsPurgable() return false end
function modifier_shadow_sword_3:RemoveOnDeath() return false end
function modifier_shadow_sword_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_shadow_sword_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_shadow_sword_3:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_shadow_sword_3:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_shadow_sword_3:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_shadow_sword_3:OnAttackLanded(kv)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = kv.attacker
		if not caster:HasModifier("modifier_kingsbane") and not caster:HasModifier("modifier_shadow_cuirass") then
			if attacker == caster then
				if not caster:IsIllusion() then
					caster.att_target = kv.target
				end
			end
		end
	end
end
function modifier_shadow_sword_3:OnTakeDamage(params)
	if IsServer() then
		local reflect = self:GetAbility():GetSpecialValueFor("reflect")
		local caster = self:GetCaster()
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local reflect_damage = damage * (reflect / 100)
		if not caster:HasModifier("modifier_kingsbane") and not caster:HasModifier("modifier_shadow_cuirass") then
			if attacker ~= nil and target == caster and reflect_damage ~= 0 then
				if not caster:IsIllusion() then
					if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
						if caster:GetAttackCapability() == 1 then
							if caster.att_target ~= nil then
								if caster.att_target ~= caster then
									local sw = ParticleManager:CreateParticle("particles/custom/items/shadow_sword/reflect.vpcf", PATTACH_ABSORIGIN, caster.att_target)
									ParticleManager:SetParticleControlEnt(sw, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), true)
									ApplyDamage({victim = caster.att_target, attacker = caster, damage = reflect_damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()})
								end
							end
						end
					end
				end
			end
		end
	end
end


-------------
--KINGSBANE--
-------------
LinkLuaModifier("modifier_kingsbane", "items/shadow_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kingsbane_echo", "items/shadow_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kingsbane_echo_haste", "items/shadow_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kingsbane_echo_debuff_slow", "items/shadow_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kingsbane_echo_cd", "items/shadow_sword.lua", LUA_MODIFIER_MOTION_NONE)
if item_kingsbane == nil then item_kingsbane = class({}) end
function item_kingsbane:GetIntrinsicModifierName() return "modifier_kingsbane" end

if modifier_kingsbane == nil then modifier_kingsbane = class({}) end
function modifier_kingsbane:IsHidden() return true end
function modifier_kingsbane:IsPurgable() return false end
function modifier_kingsbane:RemoveOnDeath() return false end
function modifier_kingsbane:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_kingsbane:OnCreated(kv)
	if IsServer() then
		if not self:GetAbility() then self:Destroy() return end
		self.echo_modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kingsbane_echo", {})
	end
end
function modifier_kingsbane:OnDestroy()
	if IsServer() then
		if self.echo_modifier then
			self.echo_modifier:Destroy()
		end
	end
end
function modifier_kingsbane:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_kingsbane:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end
end
function modifier_kingsbane:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
end
function modifier_kingsbane:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("attack_speed") end
end
function modifier_kingsbane:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_kingsbane:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("int") end
end
function modifier_kingsbane:OnAttackLanded(kv)
	if IsServer() then
		local caster = self:GetCaster()
		if not caster:IsIllusion() then
			local attacker = kv.attacker
			if not caster:HasModifier("modifier_shadow_cuirass") then
				if attacker == caster then
					caster.att_target = kv.target
				end
			end
		end
	end
end
function modifier_kingsbane:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		if not caster:IsIllusion() then
			local reflect = self:GetAbility():GetSpecialValueFor("reflect")
			local target = params.unit
			local attacker = params.attacker
			local damage = params.damage
			local reflect_damage = damage * (reflect / 100)
			if not caster:HasModifier("modifier_shadow_cuirass") then
				if attacker ~= nil and target == caster and reflect_damage ~= 0 then
					if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
						if caster:GetAttackCapability() == 1 then
							if caster.att_target ~= nil then
								if caster.att_target ~= caster then
									local sw = ParticleManager:CreateParticle("particles/custom/items/shadow_sword/reflect.vpcf", PATTACH_ABSORIGIN, caster.att_target)
									ParticleManager:SetParticleControlEnt(sw, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), true)
									ApplyDamage({victim = caster.att_target, attacker = caster, damage = reflect_damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION, ability = self:GetAbility()})
								end
							end
						end
					end
				end
			end
		end
	end
end


------------------
--KINGSBANE ECHO--
------------------
modifier_kingsbane_echo = modifier_kingsbane_echo or class({})
function modifier_kingsbane_echo:IsHidden() return true end
function modifier_kingsbane_echo:IsPurgable() return false end
function modifier_kingsbane_echo:RemoveOnDeath() return false end
function modifier_kingsbane_echo:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_kingsbane_echo:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end
	local item = self:GetAbility()
	self.parent = self:GetParent()
end
function modifier_kingsbane_echo:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_START} end
function modifier_kingsbane_echo:OnAttackStart(keys)
	local item = self:GetAbility()
	local parent = self:GetParent()
	if keys.attacker == parent and item and not parent:IsIllusion() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self and not self:GetParent():HasModifier("modifier_kingsbane_echo_cd") then
--		item:UseResources(false,false,true)
		parent:AddNewModifier(parent, item, "modifier_kingsbane_echo_haste", {})
		if not keys.target:IsBuilding() and not keys.target:IsOther() then
			keys.target:AddNewModifier(self.parent, self:GetAbility(), "modifier_kingsbane_echo_debuff_slow", {duration = self:GetAbility():GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})
		end
		if self:GetParent():HasModifier("modifier_kingsbane_echo_haste") then
			local mod = self:GetParent():FindModifierByName("modifier_kingsbane_echo_haste")
			mod:DecrementStackCount()
			if mod:GetStackCount() < 1 then
				mod:Destroy()
			end
		end
	end
end
function modifier_kingsbane_echo:OnRemoved()
	if not IsServer() then return end
	if (self:GetParent():FindModifierByName("modifier_kingsbane_echo_haste")) then
		self:GetParent():FindModifierByName("modifier_kingsbane_echo_haste"):Destroy()
	end
end

--Kingsbane echo haste
modifier_kingsbane_echo_haste = modifier_kingsbane_echo_haste or class({})
function modifier_kingsbane_echo_haste:IsDebuff() return false end
function modifier_kingsbane_echo_haste:IsHidden() return true end
function modifier_kingsbane_echo_haste:IsPurgable() return false end
function modifier_kingsbane_echo_haste:IsPurgeException() return false end
function modifier_kingsbane_echo_haste:IsStunDebuff() return false end
function modifier_kingsbane_echo_haste:RemoveOnDeath() return true end
function modifier_kingsbane_echo_haste:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end
	local item = self:GetAbility()
	self.parent = self:GetParent()
	if item then
		self.duration = item:GetSpecialValueFor("duration")
		local max_hits = 2
		self:SetStackCount(max_hits)
		self.attack_speed_buff = math.max(item:GetSpecialValueFor("attack_speed_buff"), self.parent:GetIncreasedAttackSpeed() * 3)
	end
end
function modifier_kingsbane_echo_haste:OnRefresh() self:OnCreated() end
function modifier_kingsbane_echo_haste:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK} end
function modifier_kingsbane_echo_haste:OnAttack(keys)
	if self.parent == keys.attacker then
		keys.target:AddNewModifier(self.parent, self:GetAbility(), "modifier_kingsbane_echo_debuff_slow", {duration = self:GetAbility():GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance())})
	end
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kingsbane_echo_cd", {duration = self:GetAbility():GetSpecialValueFor("echo_cd")})
	end
end
function modifier_kingsbane_echo_haste:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("attack_speed_buff") end

--Kingsbane echo slow
modifier_kingsbane_echo_debuff_slow = modifier_kingsbane_echo_debuff_slow or class({})
function modifier_kingsbane_echo_debuff_slow:IsDebuff() return true end
function modifier_kingsbane_echo_debuff_slow:IsHidden() return false end
function modifier_kingsbane_echo_debuff_slow:IsPurgable() return true end
function modifier_kingsbane_echo_debuff_slow:IsStunDebuff() return false end
function modifier_kingsbane_echo_debuff_slow:RemoveOnDeath() return true end
function modifier_kingsbane_echo_debuff_slow:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_kingsbane_echo_debuff_slow:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end
	local item = self:GetAbility()
	if item then
		self.slow = item:GetSpecialValueFor("slow_speed") * (-1)
	end
end
function modifier_kingsbane_echo_debuff_slow:GetModifierAttackSpeedBonus_Constant() return self.slow end
function modifier_kingsbane_echo_debuff_slow:GetModifierMoveSpeedBonus_Percentage() return self.slow end

modifier_kingsbane_echo_cd = modifier_kingsbane_echo_cd or class({})
function modifier_kingsbane_echo_cd:IsHidden() return false end
function modifier_kingsbane_echo_cd:IsPurgable() return false end
function modifier_kingsbane_echo_cd:IsDebuff() return true end
function modifier_kingsbane_echo_cd:IgnoreTenacity() return true end
function modifier_kingsbane_echo_cd:RemoveOnDeath() return false end
function modifier_kingsbane_echo_cd:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK} end
function modifier_kingsbane_echo_cd:OnAttack(keys)
	self:GetCaster():RemoveModifierByName("modifier_kingsbane_echo_haste")
end
