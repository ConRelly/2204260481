item_seal_act = class({})
LinkLuaModifier("immortal_all_in_one", "modifiers/immortal_all_in_one.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seal_act", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seal_armor", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seal_ghost_state", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seal_charges_cd", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seal_charges_cd_ultimate", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
function item_seal_act:OnSpellStart()
	if IsServer() then
		EmitSoundOn("DOTA_Item.GhostScepter.Activate", self:GetCaster())
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_seal_ghost_state", kv)
	end
end
function item_seal_act:OnChannelFinish(bInterrupted) if IsServer() then self:GetCaster():RemoveModifierByName("modifier_seal_ghost_state") end end
function item_seal_act:GetAbilityTextureName() return "custom/item_seal_1" end
function item_seal_act:GetIntrinsicModifierName() return "modifier_seal_act" end

modifier_seal_act = class({})
function modifier_seal_act:IsHidden() return false end
function modifier_seal_act:GetTexture() return "custom/item_seal_1" end
function modifier_seal_act:IsPurgable() return false end
function modifier_seal_act:RemoveOnDeath() return false end
function modifier_seal_act:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, 
	MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_seal_act:OnCreated(kv)
	self.needupwave = true
	self.col_ud = 0
	self.bonus_spell_lifesteal_per_wave = self:GetAbility():GetSpecialValueFor("bonus_spell_lifesteal_per_wave")
	self.bonus_spell_amp_for_wave = self:GetAbility():GetSpecialValueFor("bonus_spell_amp_for_wave")
	self.bonus_attack_speed_for_wave = self:GetAbility():GetSpecialValueFor("bonus_attack_speed_for_wave")
	self.bonus_armor_for_wave = self:GetAbility():GetSpecialValueFor("bonus_armor_for_wave")
	self.bonus_mag_res_for_wave = self:GetAbility():GetSpecialValueFor("bonus_mag_res_for_wave")
	self.bonus_all_stats_for_wave = self:GetAbility():GetSpecialValueFor("bonus_all_stats_for_wave")
	self.bonus_spell_amp_for_wave = self:GetAbility():GetSpecialValueFor("bonus_spell_amp_for_wave")

	if IsServer() then if not self:GetAbility() then self:GetCaster():RemoveModifierByName("immortal_all_in_one") self:Destroy() end
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "immortal_all_in_one", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_seal_charges_cd", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_seal_charges_cd_ultimate", {})
	end
		
	if IsServer() and not self:GetCaster():IsIllusion() then
		if self:GetCaster().sealpart ~= true and not self:GetCaster():IsIllusion() then
			local nFXIndex = ParticleManager:CreateParticle("particles/my_sf_fire_arcana_shadowraze.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
			ParticleManager:ReleaseParticleIndex(nFXIndex)
			self:GetCaster().sealpart = true
		end
		self:SetStackCount(-1-self:GetCaster():GetPlayerID())
	end
	self:OnWaveChange(0)
end
function modifier_seal_act:OnDestroy() if IsServer() then self:GetCaster():RemoveModifierByName("immortal_all_in_one") self:GetCaster():RemoveModifierByName("modifier_seal_charges_cd") self:GetCaster():RemoveModifierByName("modifier_seal_charges_cd_ultimate") self:Destroy() end end

----------------------------------------
function modifier_seal_act:OnWaveChange(wave)
	self:GetModifierSpellLifesteal({})
	self:GetModifierPreAttack_BonusDamage({})
	self:GetModifierAttackSpeedBonus_Constant({})
	self:GetModifierPhysicalArmorBonus({})
	self:GetModifierMagicalResistanceBonus({})
	self:GetModifierBonusStats_Strength({})
	self:GetModifierBonusStats_Agility({})
	self:GetModifierBonusStats_Intellect({})
	self:GetModifierSpellAmplify_Percentage({})
end
----------------------------------------

function modifier_seal_act:GetModifierSpellLifesteal(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_spell_lifesteal_per_wave--math.floor((self.bonus_spell_lifesteal_per_wave + _G.bonuses[6][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."0",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."0")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:GetModifierPreAttack_BonusDamage(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_spell_amp_for_wave--math.ceil((self.bonus_spell_amp_for_wave + _G.bonuses[1][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."1",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."1")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:GetModifierAttackSpeedBonus_Constant(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_attack_speed_for_wave--math.floor((self.bonus_attack_speed_for_wave + _G.bonuses[4][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."2",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."2")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:GetModifierPhysicalArmorBonus(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_armor_for_wave--math.floor((self.bonus_armor_for_wave + _G.bonuses[2][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."3",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."3")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:GetModifierMagicalResistanceBonus(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_mag_res_for_wave--math.floor((self.bonus_mag_res_for_wave + _G.bonuses[3][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."4",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."4")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:GetModifierBonusStats_Strength(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_all_stats_for_wave--math.floor((self.bonus_all_stats_for_wave + _G.bonuses[5][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."5",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."5")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:GetModifierBonusStats_Agility(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_all_stats_for_wave--math.floor((self.bonus_all_stats_for_wave + _G.bonuses[5][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."6",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."6")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:GetModifierBonusStats_Intellect(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_all_stats_for_wave--math.floor((self.bonus_all_stats_for_wave + _G.bonuses[5][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."7",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."7")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:GetModifierSpellAmplify_Percentage(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			local damag = 0
			if 1 ~= nil then
				damag = self.bonus_spell_amp_for_wave--math.floor((self.bonus_spell_amp_for_wave + _G.bonuses[7][self:GetCaster():GetPlayerID()]) * _G.GAME_ROUND)
				CustomNetTables:SetTableValue("RelicStats_Tabel",tostring(self:GetCaster():GetPlayerID()).."8",{param = damag})
				return damag
			end
		end
	end
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."8")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

---------------------------------------------------
function modifier_seal_act:OnTooltip(params)
	local atr = CustomNetTables:GetTableValue("RelicStats_Tabel",tostring(-1-self:GetStackCount()).."0")
	if atr ~= nil then
		return atr.param
	end
	return 0
end

function modifier_seal_act:OnAbilityExecuted(params)
	if IsServer() then
	local caster = self:GetCaster()
	local used_ability = params.ability
	local cdr_per_cast = self:GetAbility():GetSpecialValueFor("cdr_per_cast")
		if not caster:IsIllusion() then
			if params.unit == caster then
				if not used_ability:IsItem() and not used_ability:IsToggle() then
					for i=0, 6 do
						local abil = caster:GetAbilityByIndex(i)
						local abil_cd = abil:GetCooldownTimeRemaining()
						if abil_cd > 0 then
							if abil_cd - cdr_per_cast > 0 then
								abil:EndCooldown()
								abil:StartCooldown(abil_cd - cdr_per_cast)
							else
								abil:EndCooldown()
							end
						end
					end
				end
			end
		end
	end
	return 0
end

function modifier_seal_act:OnAbilityFullyCast(params)
	if IsServer() then
	local caster = self:GetCaster()
	local used_ability = params.ability
	local stack_ability = caster:FindModifierByName("modifier_seal_charges_cd")
	local stack_ultimate = caster:FindModifierByName("modifier_seal_charges_cd_ultimate")
		if not caster:IsIllusion() then
			if params.unit == caster then
				if not used_ability:IsItem() and not used_ability:IsToggle() then
					if used_ability:GetAbilityType() == 0 then
						stack_ability:SetStackCount(stack_ability:GetStackCount() + 1)
--						CreatePop(self:GetParent(), 1, stack_ability:GetStackCount())
					elseif used_ability:GetAbilityType() == 1 then
						stack_ultimate:SetStackCount(stack_ultimate:GetStackCount() + 1)
--						CreatePop(self:GetParent(), 2, stack_ultimate:GetStackCount())
					end
					if stack_ability:GetStackCount() == 10 then
						for i=0, 6 do
							local abil = caster:GetAbilityByIndex(i)
							local abil_cd = abil:GetCooldownTimeRemaining()
							local half_crd = abil_cd / 2
							local charges = abil:GetCurrentAbilityCharges()
							if abil:GetAbilityType() == 0 then
								abil:SetCurrentAbilityCharges(charges + 1)
								abil:EndCooldown()
								abil:StartCooldown(abil_cd - half_crd)
							end
						end
						stack_ultimate:SetStackCount(stack_ultimate:GetStackCount() + 1)
--						CreatePop(self:GetParent(), 2, stack_ultimate:GetStackCount())
						stack_ability:SetStackCount(0)
					end
					if stack_ultimate:GetStackCount() == 10 then
						for i=0, 6 do
							local abil = caster:GetAbilityByIndex(i)
							local abil_cd = abil:GetCooldownTimeRemaining()
							local half_crd = abil_cd / 2
							local charges = abil:GetCurrentAbilityCharges()
							if abil:GetAbilityType() == 1 then
								abil:SetCurrentAbilityCharges(charges + 1)
								abil:EndCooldown()
								abil:StartCooldown(abil_cd - half_crd)
							end
						end
						stack_ultimate:SetStackCount(0)
					end
				end
			end
		end
	end
	return 0
end

function CreatePop(target, num, count)
	if num == 1 then
		create_popup({
			target = target,
			value = count,
			color = Vector(255, 255, 255),
			type = "null",
			pos = 9
		})
	end
	if num == 2 then
		create_popup({
			target = target,
			value = count,
			color = Vector(255, 0, 0),
			type = "null_ultimate",
			pos = 9
		})
	end
end

function modifier_seal_act:OnAttackLanded(params)
	if IsServer() then
	local overload_raduis = self:GetAbility():GetSpecialValueFor("overload_raduis")
	local overload_dmg = self:GetAbility():GetSpecialValueFor("overload_dmg")
		if not self:GetCaster():IsIllusion() then
			if self:GetCaster() == params.attacker then
				self.col_ud = self.col_ud + 1
				if self.col_ud >= 3 then
					local unts = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, overload_raduis, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
					if #unts > 0 then
						local blessRNG = math.random(1,#unts)
						local lightningBolt = ParticleManager:CreateParticle("particles/econ/events/ti9/maelstorm_ti9.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
						ParticleManager:SetParticleControl(lightningBolt,0,Vector(self:GetCaster():GetAbsOrigin().x,self:GetCaster():GetAbsOrigin().y,self:GetCaster():GetAbsOrigin().z + self:GetCaster():GetBoundingMaxs().z ))  
						ParticleManager:SetParticleControl(lightningBolt,1,Vector(unts[blessRNG]:GetAbsOrigin().x,unts[blessRNG]:GetAbsOrigin().y,unts[blessRNG]:GetAbsOrigin().z + unts[blessRNG]:GetBoundingMaxs().z ))
						ApplyDamage({victim = unts[blessRNG], attacker = self:GetCaster(), damage = self:GetCaster():GetAttackDamage() * (overload_dmg / 100), damage_type = DAMAGE_TYPE_MAGICAL})
					end
					self.col_ud = 0
				end
			end
		end
	end
end

function modifier_seal_act:OnTakeDamage(params)
	if IsServer() then
	local parent = self:GetParent()
	local reinforcing_dur = self:GetAbility():GetSpecialValueFor("reinforcing_dur")
	local taken_dmg = self.taken_damage
		if not parent:IsIllusion() and parent:GetHealth() > 0 then
			if params.unit == parent then
				if taken_dmg == nil then
					taken_dmg = 0
				end
				taken_dmg = taken_dmg + params.damage
				local maax = parent:GetMaxHealth()/10
				if taken_dmg >= maax and (not parent:IsIllusion()) then
					taken_dmg = 0
					local heroes = HeroList:GetAllHeroes()
					local list = {}
					if not parent:HasModifier("modifier_seal_armor") then
						parent:AddNewModifier(parent, nil, "modifier_seal_armor", {duration = reinforcing_dur})
					else
						for i=1, #heroes do
							if heroes[i]:IsAlive() then
								table.insert(list, heroes[i])
							end
						end
						if #list > 0 then
							list[RandomInt(1, #list)]:AddNewModifier(parent, nil, "modifier_seal_armor", {duration = reinforcing_dur})
						end
					end
				end
			end
		end
	end
	return 0
end

--------------------------------------------------------------------------------
modifier_seal_armor = class({})
function modifier_seal_armor:IsHidden() return false end
function modifier_seal_armor:IsDebuff() return false end
function modifier_seal_armor:IsPurgable() return false end
function modifier_seal_armor:RemoveOnDeath() return false end
function modifier_seal_armor:GetEffectName() return "particles/units/heroes/hero_dazzle/dazzle_armor_friend_shield.vpcf" end
function modifier_seal_armor:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_seal_armor:GetTexture() return "modifier_halloffame_glow" end
function modifier_seal_armor:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_seal_armor:GetModifierPhysicalArmorBonus() return 8 end

---------------------------------------------------------------------------------
modifier_seal_ghost_state = class({})
function modifier_seal_ghost_state:GetStatusEffectName() return "particles/status_fx/status_effect_ghost.vpcf" end
function modifier_seal_ghost_state:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.extra_spell_damage_percent = self.ability:GetSpecialValueFor("extra_spell_damage_percent")
	self:StartIntervalThink(FrameTime())
end
function modifier_seal_ghost_state:OnIntervalThink()
	if not IsServer() then return end
	if self.parent:IsMagicImmune() then
		self:GetCaster():RemoveModifierByName("modifier_seal_ghost_state")
	end
end
function modifier_seal_ghost_state:OnRefresh() self:OnCreated() end
function modifier_seal_ghost_state:OnDestroy()
	if self:IsNull() then return end
	self:Destroy()
end
function modifier_seal_ghost_state:CheckState() return {[MODIFIER_STATE_ATTACK_IMMUNE] = true, [MODIFIER_STATE_DISARMED] = true} end
function modifier_seal_ghost_state:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL}
end
function modifier_seal_ghost_state:GetModifierMagicalResistanceDecrepifyUnique()
    return self.extra_spell_damage_percent
end
function modifier_seal_ghost_state:GetAbsoluteNoDamagePhysical()
	return 1
end

---------------------------------------------------------------------------------
if modifier_seal_charges_cd == nil then modifier_seal_charges_cd = class({}) end
function modifier_seal_charges_cd:IsHidden() return false end
function modifier_seal_charges_cd:IsDebuff() return false end
function modifier_seal_charges_cd:IsPurgable() return false end
function modifier_seal_charges_cd:RemoveOnDeath() return false end
function modifier_seal_charges_cd:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end

---------------------------------------------------------------------------------
if modifier_seal_charges_cd_ultimate == nil then modifier_seal_charges_cd_ultimate = class({}) end
function modifier_seal_charges_cd_ultimate:IsHidden() return false end
function modifier_seal_charges_cd_ultimate:IsDebuff() return false end
function modifier_seal_charges_cd_ultimate:IsPurgable() return false end
function modifier_seal_charges_cd_ultimate:RemoveOnDeath() return false end
function modifier_seal_charges_cd_ultimate:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
