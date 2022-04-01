LinkLuaModifier("modifier_mows", "items/master_of_weapons_sword", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mows_slasher", "items/master_of_weapons_sword", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mows_image", "items/master_of_weapons_sword", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mows_remove_as_limit", "items/master_of_weapons_sword", LUA_MODIFIER_MOTION_NONE)

if item_master_of_weapons_sword == nil then item_master_of_weapons_sword = class({}) end
function item_master_of_weapons_sword:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_123123_ability") then
		return 12 / self:GetCaster():GetCooldownReduction()
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end
function item_master_of_weapons_sword:GetIntrinsicModifierName() return "modifier_mows" end

function item_master_of_weapons_sword:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:AddNewModifier(caster, self, "modifier_mows_remove_as_limit", {})
	local additional_duration = math.floor(caster:GetDisplayAttackSpeed() / 1500)
	print("Print DisplayAttackSpeed", caster:GetDisplayAttackSpeed())
	print("Print additional_duration", additional_duration)
	local duration = self:GetSpecialValueFor("duration") + caster:FindTalentValue("special_bonus_imba_juggernaut_10") + (additional_duration * 1)

	local previous_position = caster:GetAbsOrigin()
	
	caster:Purge(false, true, false, false, false)

	local image = CreateUnitByName(caster:GetUnitName(), target:GetAbsOrigin(), true, caster, caster:GetOwner(), caster:GetTeamNumber())

	local caster_level = caster:GetLevel()
	for i = 2, caster_level do
		image:HeroLevelUp(false)
	end

	local non_transfer = {
		["item_smoke_of_deceit"] = true,
		["item_ward_observer"] = true,
		["item_ward_sentry"] = true,
	}

	-- Copy Abilities
	for ability_id = 0, DOTA_MAX_ABILITIES - 1 do
		local ability = image:GetAbilityByIndex(ability_id)
		if ability then
			if not non_transfer[ability:GetAbilityName()] then
				local caster_ability = caster:FindAbilityByName(ability:GetAbilityName())
				if caster_ability then
					ability:SetLevel(caster_ability:GetLevel())
				end
			end
		end
	end

	-- Copy Items
	for item_id = 0, 5 do
		local item_in_caster = caster:GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			if not non_transfer[item_in_caster:GetName()] then
				local item_created = CreateItem (item_in_caster:GetName(), image, image)
				image:AddItem(item_created)
				item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges())
			end
		end
	end
	-- Copy Neutral Item
	local neutral_item = caster:GetItemInSlot(16)
	if neutral_item ~= nil then
		if not non_transfer[neutral_item:GetName()] then
			local neutral_item_created = CreateItem (neutral_item:GetName(), image, image)
			image:AddItem(neutral_item_created)
			neutral_item_created:SetCurrentCharges(neutral_item:GetCurrentCharges())
		end
	end

	-- Copy Modifiers
	local caster_modifiers = caster:FindAllModifiers()
	for _,modifier in pairs(caster_modifiers) do
		if modifier then
--			local ModifierDuration = modifier:GetDuration()
--			if ModifierDuration > 0 then
				image:AddNewModifier(modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), {duration = modifier:GetRemainingTime()})
--			end
		end
	end

	image:SetAbilityPoints(0)

	image:SetHasInventory(false)
	image:SetCanSellItems(false)

	image:AddNewModifier(caster, self, "modifier_mows_image", {duration = duration})
	image:AddNewModifier(caster, self, "modifier_mows_remove_as_limit", {duration = duration})

	local modifier_handler = image:AddNewModifier(caster, self, "modifier_mows_slasher", {duration = duration})
	
	if modifier_handler then
		modifier_handler.original_caster = caster
	end

	FindClearSpaceForUnit(image, target:GetAbsOrigin() + RandomVector(128), false)

	image:EmitSound("Hero_Juggernaut.OmniSlash")

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			if image:GetUnitName() == "npc_dota_hero_juggernaut" then
				StartAnimation(image, {activity = ACT_DOTA_OVERRIDE_ABILITY_4, rate = 1, duration = duration})
			end
		end
	end)

	caster:RemoveModifierByName("modifier_mows_remove_as_limit")

	if target:TriggerSpellAbsorb(self) then return end

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			local current_position = image:GetAbsOrigin()
	
			image:PerformAttack(target, true, true, true, true, false, false, false)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, image)
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, current_position)
			ParticleManager:ReleaseParticleIndex(trail_pfx)
		end
	end)
end


-- Sword bonuses
modifier_mows = class({})
function modifier_mows:IsHidden() return true end
function modifier_mows:IsPurgable() return false end
function modifier_mows:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_mows:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_mows:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_mows:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_mows:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_ms") end
end
function modifier_mows:GetModifierAttackRangeBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_range") end
end
function modifier_mows:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_as") end
end
function modifier_mows:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
end
function modifier_mows:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
end
function modifier_mows:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
end


-- Illusion Modifier
modifier_mows_image = modifier_mows_image or class ({})
function modifier_mows_image:IsHidden() return true end
function modifier_mows_image:IsPurgable() return false end
function modifier_mows_image:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_mows_image:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

function modifier_mows_image:OnCreated()
	if not IsServer() then return end
	if self:GetParent():HasModifier("modifier_aegis_buff") then
		self:GetParent():RemoveModifierByName("modifier_aegis_buff")
	end
	self:StartIntervalThink(0.5)
end

function modifier_mows_image:OnIntervalThink()
	if not IsServer() then return end

	if not self:GetParent():HasModifier("modifier_mows_slasher") then
		self:Destroy()
	end
end


modifier_mows_slasher = modifier_mows_slasher or class({})
function modifier_mows_slasher:IsHidden() return false end
function modifier_mows_slasher:IsPurgable() return false end
function modifier_mows_slasher:IsDebuff() return false end
--function modifier_mows_slasher:StatusEffectPriority() return 20 end
function modifier_mows_slasher:GetStatusEffectName() return "particles/status_fx/status_effect_omnislash.vpcf" end

function modifier_mows_slasher:OnCreated()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.last_enemy = nil

	if not self:GetAbility() then self:Destroy() return end

	if IsServer() then
		if self.caster:GetPrimaryAttribute() == 0 then
			self.MaxHealth = self.parent:GetMaxHealth()
		else
			self.MaxHealth = 0
		end
--		Timers:CreateTimer(FrameTime(), function()
			if (not self.parent:IsNull()) then
				
				self.bounce_range = self:GetAbility():GetSpecialValueFor("bounce_range")
				
--				self:GetAbility():SetRefCountsModifiers(false)

				self:BounceAndSlaughter(true)
				
				local slash_rate = 0.125--self.caster:GetSecondsPerAttack() / (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier"), 1))

				self:StartIntervalThink(slash_rate)
			end
--		end)
	end
end

function modifier_mows_slasher:OnDestroy()
	if IsServer() then
		self.parent:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
		
		self.parent:MoveToPositionAggressive(self.parent:GetAbsOrigin())

		if self.parent:HasModifier("modifier_mows_image") then
			local ability = self:GetAbility()
			local image_team = self.parent:GetTeamNumber()
			local image_loc = self.parent:GetAbsOrigin()
			local damage = self.parent:GetAttackDamage()
			local radius = 2000
			local repeat_times = 1 + (2 * math.floor(self.parent:GetLevel() / 40))
			if self.caster:GetPrimaryAttribute() == 0 then
				if self.caster:GetStrength() >= 7500 then
					DMGflags = DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
				else
					DMGflags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
				end
			end
			
			local nearby_enemies = FindUnitsInRadius(image_team, image_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

			for i = 1, repeat_times do
				Timers:CreateTimer(0.1 * i, function()
					if ability then
						for _,enemy in pairs(nearby_enemies) do
							ApplyDamage({
								victim = enemy,
								attacker = self.caster,
								ability = ability,
								damage = damage,
								damage_type = DAMAGE_TYPE_PHYSICAL,
								damage_flags = DMGflags,
							})
						end
						if i == 1 or (i + 1 % 3 == 0) then
							local burst = ParticleManager:CreateParticle("particles/items3_fx/blink_overwhelming_burst.vpcf", PATTACH_WORLDORIGIN, self.caster)
							ParticleManager:SetParticleControl(burst, 0, image_loc)
							ParticleManager:SetParticleControl(burst, 1, Vector(radius, 500, 500))
							ParticleManager:ReleaseParticleIndex(burst)
							EmitSoundOnLocationWithCaster(image_loc, "Blink_Layer.Overwhelming", self.caster)
						end
					end
				end)
			end

			self.parent:MakeIllusion()
			self.parent:RemoveModifierByName("modifier_mows_image")

			for item_id = 0, 5 do
				local item_in_caster = self.parent:GetItemInSlot(item_id)
				if item_in_caster ~= nil then
					UTIL_Remove(item_in_caster)
				end
			end
			local neutral_item = self.parent:GetItemInSlot(16)
			if neutral_item ~= nil then
				UTIL_Remove(neutral_item)
			end

			local caster_modifiers = self.parent:FindAllModifiers()
			for _,modifier in pairs(caster_modifiers) do
				if modifier then
					UTIL_Remove(modifier)
				end
			end

			if (not self:GetParent():IsNull()) then
				UTIL_Remove(self.parent)
			end
		end
	end
end

function modifier_mows_slasher:OnIntervalThink()
	if not self:GetAbility() then self:Destroy() return end
	self:BounceAndSlaughter()
	
	local slash_rate = 0.125--self.caster:GetSecondsPerAttack() / (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier"), 1))

	self:StartIntervalThink(slash_rate)
end

function modifier_mows_slasher:BounceAndSlaughter(first_slash)
	local order = FIND_ANY_ORDER
	
	if first_slash then
		order = FIND_CLOSEST
	end
	
	self.nearby_enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.bounce_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, order, false)
	
	for count = #self.nearby_enemies, 1, -1 do
		if self.nearby_enemies[count] and (self.nearby_enemies[count]:GetName() == "npc_dota_unit_undying_zombie" or self.nearby_enemies[count]:GetName() == "npc_dota_elder_titan_ancestral_spirit") then
			table.remove(self.nearby_enemies, count)
		end
	end

	if #self.nearby_enemies >= 1 then
		for _,enemy in pairs(self.nearby_enemies) do
			local previous_position = self.parent:GetAbsOrigin()
			FindClearSpaceForUnit(self.parent, enemy:GetAbsOrigin() + RandomVector(100), false)
			
			if not self:GetAbility() then break end

			local current_position = self.parent:GetAbsOrigin()

			self.parent:FaceTowards(enemy:GetAbsOrigin())
			
			AddFOWViewer(self:GetCaster():GetTeamNumber(), enemy:GetAbsOrigin(), 200, 1, false)
			
			if first_slash and enemy:TriggerSpellAbsorb(self:GetAbility()) then
				break
			else
				self.parent:PerformAttack(enemy, true, true, true, true, false, false, false)
			end

--			enemy:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
			enemy:EmitSound("Hero_Juggernaut.BladeFuryStop")

			local hit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControl(hit_pfx, 0, current_position)
			ParticleManager:SetParticleControl(hit_pfx, 1, current_position)
			ParticleManager:ReleaseParticleIndex(hit_pfx)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, self.parent)
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, current_position)
			ParticleManager:ReleaseParticleIndex(trail_pfx)

			if self.last_enemy ~= enemy then
				local dash_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_dash.vpcf", PATTACH_ABSORIGIN, self.parent)
				ParticleManager:SetParticleControl(dash_pfx, 0, previous_position)
				ParticleManager:SetParticleControl(dash_pfx, 2, current_position)
				ParticleManager:ReleaseParticleIndex(dash_pfx)
			end

			self.last_enemy = enemy

			if self.parent:HasModifier("modifier_mows_image") then
				self.previous_pos = previous_position
				self.current_pos = current_position
			end

			break
		end
	else
		self:Destroy()
	end
end

function modifier_mows_slasher:DeclareFunctions()
	if not IsServer() then return end
	if self:GetParent():GetUnitName() == "npc_dota_hero_juggernaut" then
		return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
	end
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_mows_slasher:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_4 end
function modifier_mows_slasher:GetModifierPreAttack_BonusDamage() return self.MaxHealth end

function modifier_mows_slasher:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ROOTED] = true
	}
end


modifier_mows_remove_as_limit = class({})
function modifier_mows_remove_as_limit:IsHidden() return true end
function modifier_mows_remove_as_limit:IsPurgable() return false end
function modifier_mows_remove_as_limit:RemoveOnDeath() return false end
function modifier_mows_remove_as_limit:DeclareFunctions()
	return {MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT}
end
function modifier_mows_remove_as_limit:GetModifierAttackSpeed_Limit()
	return 1
end

