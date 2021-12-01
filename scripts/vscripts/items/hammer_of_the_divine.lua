LinkLuaModifier("modifier_hammer_of_the_divine", "items/hammer_of_the_divine", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hotd_unyielding", "items/hammer_of_the_divine", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hotd_unyielding_counter", "items/hammer_of_the_divine", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hotd_overwhelming_force", "items/hammer_of_the_divine", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hotd_pure_divinity", "items/hammer_of_the_divine", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hotd_pure_divinity_armor_corruption", "items/hammer_of_the_divine", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hotd_base_str", "items/hammer_of_the_divine", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_wraith_rapier", "items/hammer_of_the_divine", LUA_MODIFIER_MOTION_NONE)

--------------------------
-- Hammer Of The Divine --
--------------------------
item_hammer_of_the_divine = item_hammer_of_the_divine or class({})
function item_hammer_of_the_divine:GetIntrinsicModifierName() return "modifier_hammer_of_the_divine" end
function item_hammer_of_the_divine:GetAbilityTextureName()
	if IsClient() then
		if self:GetCaster():HasModifier("modifier_hotd_pure_divinity") then
			return "custom/hammer_of_the_divine_active"
		else
			return "custom/hammer_of_the_divine"
		end
	end
end
function item_hammer_of_the_divine:OnSpellStart()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_hotd_pure_divinity") then
			EmitSoundOn("DOTA_Item.Satanic.Activate", self:GetCaster())
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_hotd_pure_divinity", {duration = self:GetSpecialValueFor("active_duration")})
			self:EndCooldown()
			self:StartCooldown(2)
		else
			self:GetCaster():RemoveModifierByName("modifier_hotd_pure_divinity")
		end
	end
end

-----------------------------------
-- Hammer Of The Divine Modifier --
-----------------------------------
modifier_hammer_of_the_divine = modifier_hammer_of_the_divine or class({})
function modifier_hammer_of_the_divine:IsHidden() return true end
function modifier_hammer_of_the_divine:IsPurgable() return false end
function modifier_hammer_of_the_divine:RemoveOnDeath() return false end
function modifier_hammer_of_the_divine:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_hammer_of_the_divine:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		if self:GetCaster():IsIllusion() then return end
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hotd_base_str", {})
		self.unyielding_hits = 0
		self.overwhelming_hits = 0
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_hammer_of_the_divine:OnDestroy()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_hotd_unyielding") then
			self:GetCaster():RemoveModifierByName("modifier_hotd_unyielding")
		end
		if self:GetCaster():HasModifier("modifier_hotd_unyielding_counter") then
			self:GetCaster():RemoveModifierByName("modifier_hotd_unyielding_counter")
		end
		if self:GetCaster():HasModifier("modifier_hotd_pure_divinity") then
			self:GetCaster():RemoveModifierByName("modifier_hotd_pure_divinity")
		end
	end
end
function modifier_hammer_of_the_divine:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():GetPrimaryAttribute() == 0 or self:GetParent():GetUnitName() == "npc_courier_replacement" then
		else
			self:GetCaster():DropItemAtPositionImmediate(self:GetAbility(), self:GetCaster():GetAbsOrigin())
		end
		if not self:GetParent():HasModifier("modifier_hotd_unyielding") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hotd_unyielding", {})
		end
	end
end
function modifier_hammer_of_the_divine:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS,
	MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_START}
end
function modifier_hammer_of_the_divine:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_base_damage") end
end
function modifier_hammer_of_the_divine:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_strength") end
end
function modifier_hammer_of_the_divine:GetModifierBaseAttackTimeConstant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("base_attack_time") end
end
function modifier_hammer_of_the_divine:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_armor") end
end
function modifier_hammer_of_the_divine:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_hammer_of_the_divine:OnAttackLanded(keys)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if keys.attacker ~= self:GetParent() then return end
	if caster:IsIllusion() then return end
	if self:GetParent():HasModifier("modifier_spectre_einherjar_lua") then return end
	local unyielding_chance = ability:GetSpecialValueFor("unyielding_chance")
	local unyielding_stack_dur = ability:GetSpecialValueFor("unyielding_stack_dur")
	local unyielding_max_stacks = ability:GetSpecialValueFor("unyielding_max_stacks")
	local unyielding_modifier = caster:FindModifierByName("modifier_hotd_unyielding")
	if unyielding_modifier:GetStackCount() == unyielding_max_stacks then return end
	if unyielding_modifier:GetStackCount() < unyielding_max_stacks then
		if (caster:HasAbility("mjz_chaos_knight_chaos_strike") and caster:FindAbilityByName("mjz_chaos_knight_chaos_strike"):IsTrained()) or (caster:HasAbility("mjz_chaos_knight_chaos_strike_2") and caster:FindAbilityByName("mjz_chaos_knight_chaos_strike_2"):IsTrained()) then
			unyielding_chance = ability:GetSpecialValueFor("unyielding_cs_chance")
		end
		if caster:HasAbility("roshan_inherit_buff_datadriven") and caster:FindAbilityByName("roshan_inherit_buff_datadriven"):IsTrained() then
			unyielding_chance = unyielding_chance + ability:GetSpecialValueFor("unyielding_gs_chance")
		end
		if caster:IsRangedAttacker() then
			unyielding_chance = unyielding_chance / 2
		end
		if RollPercentage(unyielding_chance) then
			caster:AddNewModifier(caster, ability, "modifier_hotd_unyielding_counter", {duration = unyielding_stack_dur})
			unyielding_modifier:SetDuration(unyielding_stack_dur, false)
			unyielding_modifier:IncrementStackCount()
		end
		if caster:HasAbility("dawnbreaker_custom_luminosity") and caster:FindAbilityByName("dawnbreaker_custom_luminosity"):IsTrained() then
			if self.unyielding_hits >= ability:GetSpecialValueFor("unyielding_lum_hits") - 1 then
				caster:AddNewModifier(caster, ability, "modifier_hotd_unyielding_counter", {duration = unyielding_stack_dur})
				self.unyielding_hits = 0
				unyielding_modifier:SetDuration(unyielding_stack_dur, false)
				unyielding_modifier:IncrementStackCount()
			else
				self.unyielding_hits = self.unyielding_hits + 1
			end
		end
		if unyielding_modifier:GetStackCount() > unyielding_max_stacks then
			unyielding_modifier:SetStackCount(unyielding_max_stacks)
		end
	end
end
function modifier_hammer_of_the_divine:OnAttackStart(keys)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if keys.attacker ~= self:GetParent() then return end
	if caster:IsIllusion() then return end
	if caster:HasModifier("modifier_hotd_overwhelming_force") then return end
	local overwhelming_chance = ability:GetSpecialValueFor("overwhelming_chance")
	local overwhelming_duration = ability:GetSpecialValueFor("overwhelming_duration")
	local overwhelming_lum_hits = ability:GetSpecialValueFor("overwhelming_lum_hits")
	if (caster:HasAbility("mjz_chaos_knight_chaos_strike") and caster:FindAbilityByName("mjz_chaos_knight_chaos_strike"):IsTrained()) or (caster:HasAbility("mjz_chaos_knight_chaos_strike_2") and caster:FindAbilityByName("mjz_chaos_knight_chaos_strike_2"):IsTrained()) then
		overwhelming_chance = ability:GetSpecialValueFor("overwhelming_cs_chance")
-- NOTE 1
		overwhelming_lum_hits = 6
	end
	if caster:HasAbility("dawnbreaker_custom_luminosity") and caster:FindAbilityByName("dawnbreaker_custom_luminosity"):IsTrained() then
		if (caster:HasAbility("mjz_chaos_knight_chaos_strike") and caster:FindAbilityByName("mjz_chaos_knight_chaos_strike"):IsTrained()) or (caster:HasAbility("mjz_chaos_knight_chaos_strike_2") and caster:FindAbilityByName("mjz_chaos_knight_chaos_strike_2"):IsTrained()) then
-- NOTE 1
			overwhelming_chance = 20
		end
		if self.overwhelming_hits >= overwhelming_lum_hits - 1 then
			caster:AddNewModifier(caster, ability, "modifier_hotd_overwhelming_force", {duration = overwhelming_duration})
			self.overwhelming_hits = 0
		else
			self.overwhelming_hits = self.overwhelming_hits + 1
		end
	end
--[[ 	if caster:IsRangedAttacker() then
		overwhelming_chance = overwhelming_chance / 2
	end ]]
	if RollPercentage(overwhelming_chance) then
		caster:AddNewModifier(caster, ability, "modifier_hotd_overwhelming_force", {duration = overwhelming_duration})
	end
end

---------------------------------
-- Overwhelming Force Modifier --
---------------------------------
modifier_hotd_overwhelming_force = modifier_hotd_overwhelming_force or class({})
function modifier_hotd_overwhelming_force:IsHidden() return true end
function modifier_hotd_overwhelming_force:IsPurgable() return false end
function modifier_hotd_overwhelming_force:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_hotd_overwhelming_force:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end
function modifier_hotd_overwhelming_force:GetModifierDamageOutgoing_Percentage()
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("overwhelming_total_dmg") end
end

-------------------------
-- Unyielding Modifier --
-------------------------
modifier_hotd_unyielding = modifier_hotd_unyielding or class({})
function modifier_hotd_unyielding:IsHidden() return (self:GetStackCount() == 0) end
function modifier_hotd_unyielding:IsPurgable() return false end
function modifier_hotd_unyielding:RemoveOnDeath() return false end
function modifier_hotd_unyielding:DestroyOnExpire() return false end

-----------------------
-- Unyielding Stacks --
-----------------------
modifier_hotd_unyielding_counter = modifier_hotd_unyielding_counter or class({})
function modifier_hotd_unyielding_counter:IsHidden() return true end
function modifier_hotd_unyielding_counter:IsPurgable() return false end
function modifier_hotd_unyielding_counter:RemoveOnDeath() return false end
function modifier_hotd_unyielding_counter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_hotd_unyielding_counter:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local true_base_str = self:GetParent():FindModifierByName("modifier_hotd_base_str"):GetStackCount()
		local unyielding_str = self:GetAbility():GetSpecialValueFor("unyielding_str")
		local bonus_base_str = math.floor(true_base_str * unyielding_str / 100)
		self:SetStackCount(bonus_base_str)
		self:GetParent():SetBaseStrength(self:GetParent():GetBaseStrength() + self:GetStackCount())
	end
end
function modifier_hotd_unyielding_counter:OnDestroy()
	if IsServer() then
		self:GetParent():SetBaseStrength(self:GetParent():GetBaseStrength() - self:GetStackCount())
		if self:GetParent():HasModifier("modifier_hotd_unyielding") then
			self:GetParent():FindModifierByName("modifier_hotd_unyielding"):DecrementStackCount()
		end
	end
end

----------------------------
-- Pure Divinity Modifier --
----------------------------
modifier_hotd_pure_divinity = modifier_hotd_pure_divinity or class({})
function modifier_hotd_pure_divinity:IsHidden() return false end
function modifier_hotd_pure_divinity:IsDebuff() return false end
function modifier_hotd_pure_divinity:GetTexture() return "custom/hammer_of_the_divine_active" end
function modifier_hotd_pure_divinity:GetHeroEffectName()
	return "particles/custom/items/hammer_of_the_divine/hammer_of_the_divine_active_amb.vpcf"
end
function modifier_hotd_pure_divinity:HeroEffectPriority() return 10 end
function modifier_hotd_pure_divinity:GetStatusEffectName()
	return "particles/custom/items/hammer_of_the_divine/hammer_of_the_divine_active_status.vpcf"
end
function modifier_hotd_pure_divinity:StatusEffectPriority() return 10 end
function modifier_hotd_pure_divinity:IsPurgable() return false end
function modifier_hotd_pure_divinity:OnCreated()
	if IsServer() then
		local active_pfx = ParticleManager:CreateParticle("particles/custom/items/hammer_of_the_divine/hammer_of_the_divine_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(active_pfx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(active_pfx)

		local armor_reduction = (self:GetCaster():GetStrength() - self:GetCaster():GetBaseStrength()) * self:GetAbility():GetSpecialValueFor("corr_armor_red_pct") / 100
		self:SetStackCount(-armor_reduction)
	end
end
function modifier_hotd_pure_divinity:OnDestroy()
	if IsServer() then self:GetAbility():UseResources(false, false, true) end
end
function modifier_hotd_pure_divinity:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_TOOLTIP, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_hotd_pure_divinity:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end
function modifier_hotd_pure_divinity:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return -self:GetAbility():GetSpecialValueFor("bonus_armor") + self:GetStackCount() end
end
function modifier_hotd_pure_divinity:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() end
end
function modifier_hotd_pure_divinity:OnAttackLanded(keys)
	if IsServer() then
		if keys.attacker ~= self:GetParent() then return end
		if keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and not self:GetParent():IsIllusion() then
			local debuff = keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_hotd_pure_divinity_armor_corruption", {duration = self:GetAbility():GetSpecialValueFor("corr_duration") * (1 - keys.target:GetStatusResistance())})
			local armor_reduction = (self:GetCaster():GetStrength() - self:GetCaster():GetBaseStrength()) * self:GetAbility():GetSpecialValueFor("corr_armor_red_pct") / 100
			local corruption_armor_red_max = self:GetAbility():GetSpecialValueFor("corr_armor_red_max")
			if armor_reduction > corruption_armor_red_max then
				armor_reduction = corruption_armor_red_max
			end
			debuff:SetStackCount(armor_reduction)
			self:SetStackCount(-armor_reduction)
		end
	end
end

----------------------------------------------
-- Pure Divinity: Armor Corruption Modifier --
----------------------------------------------
modifier_hotd_pure_divinity_armor_corruption = modifier_hotd_pure_divinity_armor_corruption or class({})
function modifier_hotd_pure_divinity_armor_corruption:IsHidden() return false end
function modifier_hotd_pure_divinity_armor_corruption:IsDebuff() return true end
function modifier_hotd_pure_divinity_armor_corruption:IsPurgable() return true end
function modifier_hotd_pure_divinity_armor_corruption:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_hotd_pure_divinity_armor_corruption:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetStackCount() * (-1) end
end

------------------
-- str_modifier --
------------------
modifier_hotd_base_str = modifier_hotd_base_str or class({})
function modifier_hotd_base_str:IsHidden() return true end
function modifier_hotd_base_str:IsPurgable() return false end
function modifier_hotd_base_str:RemoveOnDeath() return false end
function modifier_hotd_base_str:OnCreated()
	if IsServer() then
		self.old_level = self:GetParent():GetLevel()
		local GetBaseStrength = self:GetParent():GetBaseStrength()
		if self:GetParent():HasModifier("item_tome_str") then
			GetBaseStrength = GetBaseStrength + self:GetParent():FindModifierByName("item_tome_str"):GetStackCount()
		end
		self.stacks = GetBaseStrength
		self:SetStackCount(self.stacks)
		self:StartIntervalThink(0.5)
	end
end
function modifier_hotd_base_str:OnIntervalThink()
	local new_level = self:GetParent():GetLevel()
	if new_level > self.old_level then
		self.stacks = self.stacks + (self:GetParent():GetStrengthGain() * (new_level - self.old_level))
		self.old_level = new_level
		self:SetStackCount(self.stacks)
	end
end
function modifier_hotd_base_str:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end
function modifier_hotd_base_str:OnAbilityExecuted(params)
	if IsServer() then
		local caster = self:GetCaster()
		local tome = params.ability
		if params.unit == caster then
			if not caster:IsIllusion() and caster:IsRealHero() then
				if tome:GetName() == "item_tome_str" then
					self.stacks = self.stacks + caster:FindItemInInventory("item_tome_str"):GetSpecialValueFor("bonus")
					self:SetStackCount(self.stacks)
				end
			end
		end
	end
	return 0
end




local craft1 = true
-- Wraith Rapier --
item_wraith_rapier = item_wraith_rapier or class({})
function item_wraith_rapier:GetIntrinsicModifierName() return "modifier_wraith_rapier" end
function item_wraith_rapier:OnOwnerSpawned()
	if craft and craft1 then
		local Parent = self:GetParent()
		local Location = GetGroundPosition(Parent:GetAbsOrigin(), Parent)
		Parent:RemoveItem(Parent:FindItemInInventory("item_resurection_pendant"))
		Parent:RemoveItem(Parent:FindItemInInventory("item_desolator_2"))
		Parent:RemoveItem(Parent:FindItemInInventory("item_witless_shako"))
		Parent:RemoveItem(self)
		Parent:EmitSound("Hero_PhantomAssassin.Arcana_Layer")
		Parent:AddItemByName("item_hammer_of_the_divine")
		craft1 = false
	end
end
function item_wraith_rapier:OnOwnerDied(params)
	if not craft then
		local hOwner = self:GetOwner()
--[[
		if not hOwner:IsRealHero() then
			hOwner:DropItem(self, true, true)
			return
		end
]]
		if _G.first_drop and hOwner:GetUnitName() == "npc_boss_skeleton_king_angry_new" then
			hOwner:DropItem(self, true, true)
			_G.first_drop = false
		end
		if not hOwner:IsReincarnating() then
			hOwner:DropItem(self, true, true)
		end
	end
end

-- Wraith Rapier Modifier --
modifier_wraith_rapier = modifier_wraith_rapier or class({})
function modifier_wraith_rapier:IsHidden() return true end
function modifier_wraith_rapier:IsPurgable() return false end
function modifier_wraith_rapier:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_wraith_rapier:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		if _G.first_drop == nil then _G.first_drop = true end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_wraith_rapier:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_DEATH}
end
function modifier_wraith_rapier:OnIntervalThink()
	if not self:GetCaster():IsIllusion() and self:GetCaster():GetUnitName() ~= "npc_boss_skeleton_king_angry_new" then
		if not self:GetCaster():IsRealHero() then
			self:GetCaster():DropItem(self:GetAbility(), true, true)
		end
	end	
	local pendant = self:GetParent():FindItemInInventory("item_resurection_pendant")
	local desol = self:GetParent():FindItemInInventory("item_desolator_2")
	local shako = self:GetParent():FindItemInInventory("item_witless_shako")
	if pendant and desol and shako then craft = true else craft = false end
end
function modifier_wraith_rapier:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() then
		if self:GetParent():GetUnitName() == "npc_boss_skeleton_king_angry_new" or self:GetParent():GetUnitName() == "npc_dota_hero_skeleton_king" or self:GetParent():GetUnitName() == "npc_dota_hero_death_prophet" then
			return self:GetAbility():GetSpecialValueFor("bonus_base_damage")
		else
			return -self:GetAbility():GetSpecialValueFor("bonus_base_damage")
		end
	end
end
function modifier_wraith_rapier:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		if self:GetParent():GetUnitName() == "npc_boss_skeleton_king_angry_new" or self:GetParent():GetUnitName() == "npc_dota_hero_skeleton_king" or self:GetParent():GetUnitName() == "npc_dota_hero_death_prophet" then
			return self:GetAbility():GetSpecialValueFor("bonus_strength")
		else
			return -self:GetAbility():GetSpecialValueFor("bonus_strength")
		end
	end
end
function modifier_wraith_rapier:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		if self:GetParent():GetUnitName() == "npc_boss_skeleton_king_angry_new" or self:GetParent():GetUnitName() == "npc_dota_hero_skeleton_king" or self:GetParent():GetUnitName() == "npc_dota_hero_death_prophet" then
			return self:GetAbility():GetSpecialValueFor("bonus_armor")
		else
			return -self:GetAbility():GetSpecialValueFor("bonus_armor")
		end
	end
end
