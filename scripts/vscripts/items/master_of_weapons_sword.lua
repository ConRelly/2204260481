LinkLuaModifier("modifier_mows", "items/master_of_weapons_sword", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mows_slasher", "items/master_of_weapons_sword", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mows_image", "items/master_of_weapons_sword", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mows_remove_as_limit", "items/master_of_weapons_sword", LUA_MODIFIER_MOTION_NONE)

if item_master_of_weapons_sword == nil then item_master_of_weapons_sword = class({}) end


item_master_of_weapons_sword2 = class(item_master_of_weapons_sword)
item_master_of_weapons_sword3 = class(item_master_of_weapons_sword)
item_master_of_weapons_sword4 = class(item_master_of_weapons_sword)
item_master_of_weapons_sword5 = class(item_master_of_weapons_sword)


function item_master_of_weapons_sword2:GetIntrinsicModifierName() return "modifier_mows" end
function item_master_of_weapons_sword3:GetIntrinsicModifierName() return "modifier_mows" end
function item_master_of_weapons_sword4:GetIntrinsicModifierName() return "modifier_mows" end
function item_master_of_weapons_sword5:GetIntrinsicModifierName() return "modifier_mows" end

function item_master_of_weapons_sword:GetIntrinsicModifierName()
	return "modifier_mows"
end

function item_master_of_weapons_sword:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_dzzl_good_juju") then
		if self then
			return (self:GetSpecialValueFor("good_juju_cd") / self:GetCaster():GetCooldownReduction()) / 0.58
		end	
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end

function item_master_of_weapons_sword:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster() then return end
	if not self:GetCaster():IsRealHero() then return end
	if self:GetCaster():HasModifier("modifier_courier_invincibility") then return end
		
	local target = self:GetCursorTarget()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {})
	local additional_duration = math.floor(self:GetCaster():GetDisplayAttackSpeed() / 1500)
--	print("Print DisplayAttackSpeed", self:GetCaster():GetDisplayAttackSpeed())
--	print("Print additional_duration", additional_duration)
	local duration = self:GetSpecialValueFor("duration") + (additional_duration * 1)

	local previous_position = self:GetCaster():GetAbsOrigin()
	
	self:GetCaster():Purge(false, true, false, false, false)

	local image = CreateUnitByName(self:GetCaster():GetUnitName(), target:GetAbsOrigin(), true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber())

	local caster_level = self:GetCaster():GetLevel()
	for i = 2, caster_level do
		image:HeroLevelUp(false)
	end

	local non_transfer = {
		["item_smoke_of_deceit"] = true,
		["item_ward_observer"] = true,
		["item_ward_sentry"] = true,
		["item_all_essence"] = true,
		["item_thunder_hammer"] = true,
		["item_thunder_gods_might"] = true,
		["item_thunder_gods_might2"] = true,
	}

	-- Copy Abilities
	local ability_count = self:GetCaster():GetAbilityCount()
	for ability_id = 0, ability_count - 1 do
		local ability = image:GetAbilityByIndex(ability_id)
		if ability then
			if not non_transfer[ability:GetAbilityName()] then
				local caster_ability = self:GetCaster():FindAbilityByName(ability:GetAbilityName())
				if caster_ability and caster_ability:IsTrained() then
					ability:SetLevel(caster_ability:GetLevel())
				end
			end
		end
	end

	-- Copy Items
	for item_id = 0, 5 do
		local item_in_caster = self:GetCaster():GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			if not non_transfer[item_in_caster:GetName()] then
				local item_created = CreateItem(item_in_caster:GetName(), image, image)
				image:AddItem(item_created)
				item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges())
			end
		end
	end
	image:AddItemByName("item_moon_shard")
	image:AddItemByName("item_moon_shard")

	-- Copy Neutral Item
	local neutral_item = self:GetCaster():GetItemInSlot(16)
	if neutral_item ~= nil then
		if not non_transfer[neutral_item:GetName()] then
			local neutral_item_created = CreateItem(neutral_item:GetName(), image, image)
			image:AddItem(neutral_item_created)
			neutral_item_created:SetCurrentCharges(neutral_item:GetCurrentCharges())
		end
	end

	-- Copy Modifiers
	local ignored_modifiers = {
		["modifier_wind_rapier_agility_buff"] = true,
		["modifier_item_pharaoh_crown"] = true,
		["modifier_item_pharaoh_crown_initiate"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_item_aghanims_shard"] = true,
		["modifier_mows_remove_as_limit"] = true,
		["modifier_thunder_gods_might"] = true,
		["modifier_thunder_gods_might2"] = true,
		["modifier_thunder_hammer"] = true,
		["modifier_item_thunder_god_might_aura"] = true,
		["modifier_item_thunder_god_might_aura2"] = true,		
		["modifier_totem_aura_effect"] = true,
		["modifier_totem_aura"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_grimstroke_custom_soulstore"] = true,
		["modifier_invoker_quas_instance"] = true,
		["modifier_invoker_wex_instance"] = true,

	}
	
	local caster_modifiers = self:GetCaster():FindAllModifiers()
	for _, modifier in pairs(caster_modifiers) do
		if modifier and not ignored_modifiers[modifier:GetName()] then
			local added_modifier = image:AddNewModifier(modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), {duration = modifier:GetDuration()})
			if modifier:GetStackCount() > 0 then
				if added_modifier then
					added_modifier:SetStackCount(modifier:GetStackCount())
				end
			end
		end
	end

	image:SetAbilityPoints(0)

	image:SetHasInventory(false)
	image:SetCanSellItems(false)

	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_image", {duration = duration})
	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {duration = duration})

	local modifier_handler = image:AddNewModifier(self:GetCaster(), self, "modifier_mows_slasher", {duration = duration})
	
	if modifier_handler then
		modifier_handler.original_caster = self:GetCaster()
	end

	FindClearSpaceForUnit(image, target:GetAbsOrigin() + RandomVector(128), false)

	image:EmitSound("Hero_Juggernaut.OmniSlash")

	self:GetCaster():RemoveModifierByName("modifier_mows_remove_as_limit")

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			if image:GetUnitName() == "npc_dota_hero_juggernaut" then
				StartAnimation(image, {activity = ACT_DOTA_OVERRIDE_ABILITY_4, rate = 1, duration = duration})
			end
		end
	end)

	if target:TriggerSpellAbsorb(self) then return end

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			image:PerformAttack(target, true, true, true, true, false, false, false)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, image)
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, image:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(trail_pfx)
		end
	end)
end

--sword2
function item_master_of_weapons_sword2:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_dzzl_good_juju") then
		if self then
			return (self:GetSpecialValueFor("good_juju_cd") / self:GetCaster():GetCooldownReduction()) / 0.58
		end	
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end

function item_master_of_weapons_sword2:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster() then return end
	if not self:GetCaster():IsRealHero() then return end
	if self:GetCaster():HasModifier("modifier_courier_invincibility") then return end
	local target = self:GetCursorTarget()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {})
	local additional_duration = math.floor(self:GetCaster():GetDisplayAttackSpeed() / 1500)
--	print("Print DisplayAttackSpeed", self:GetCaster():GetDisplayAttackSpeed())
--	print("Print additional_duration", additional_duration)
	local duration = self:GetSpecialValueFor("duration") + (additional_duration * 1)

	local previous_position = self:GetCaster():GetAbsOrigin()
	
	self:GetCaster():Purge(false, true, false, false, false)

	local image = CreateUnitByName(self:GetCaster():GetUnitName(), target:GetAbsOrigin(), true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber())

	local caster_level = self:GetCaster():GetLevel()
	for i = 2, caster_level do
		image:HeroLevelUp(false)
	end

	local non_transfer = {
		["item_smoke_of_deceit"] = true,
		["item_ward_observer"] = true,
		["item_ward_sentry"] = true,
		["item_all_essence"] = true,
		["item_thunder_hammer"] = true,
		["item_thunder_gods_might"] = true,
		["item_thunder_gods_might2"] = true,
	}

	-- Copy Abilities , use caster:GetAbilityCount() - 1
	local ability_count = self:GetCaster():GetAbilityCount()
	for ability_id = 0, ability_count - 1 do
		local ability = image:GetAbilityByIndex(ability_id)
		if ability then
			if not non_transfer[ability:GetAbilityName()] then
				local caster_ability = self:GetCaster():FindAbilityByName(ability:GetAbilityName())
				if caster_ability and caster_ability:IsTrained() then
					ability:SetLevel(caster_ability:GetLevel())
				end
			end
		end
	end

	-- Copy Items
	for item_id = 0, 5 do
		local item_in_caster = self:GetCaster():GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			if not non_transfer[item_in_caster:GetName()] then
				local item_created = CreateItem(item_in_caster:GetName(), image, image)
				image:AddItem(item_created)
				item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges())
			end
		end
	end
	image:AddItemByName("item_moon_shard")
	image:AddItemByName("item_moon_shard")	
	-- Copy Neutral Item
	local neutral_item = self:GetCaster():GetItemInSlot(16)
	if neutral_item ~= nil then
		if not non_transfer[neutral_item:GetName()] then
			local neutral_item_created = CreateItem(neutral_item:GetName(), image, image)
			image:AddItem(neutral_item_created)
			neutral_item_created:SetCurrentCharges(neutral_item:GetCurrentCharges())
		end
	end

	-- Copy Modifiers
	local ignored_modifiers = {
		["modifier_wind_rapier_agility_buff"] = true,
		["modifier_item_pharaoh_crown"] = true,
		["modifier_item_pharaoh_crown_initiate"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_item_aghanims_shard"] = true,
		["modifier_mows_remove_as_limit"] = true,
		["modifier_thunder_gods_might"] = true,
		["modifier_thunder_gods_might2"] = true,
		["modifier_thunder_hammer"] = true,
		["modifier_item_thunder_god_might_aura"] = true,
		["modifier_item_thunder_god_might_aura2"] = true,		
		["modifier_totem_aura_effect"] = true,
		["modifier_totem_aura"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_grimstroke_custom_soulstore"] = true,
		["modifier_invoker_quas_instance"] = true,
		["modifier_invoker_wex_instance"] = true,
	}

	local caster_modifiers = self:GetCaster():FindAllModifiers()
	for _, modifier in pairs(caster_modifiers) do
		if modifier and not ignored_modifiers[modifier:GetName()] then
			local added_modifier = image:AddNewModifier(modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), {duration = modifier:GetDuration()})
			if modifier:GetStackCount() > 0 then
				if added_modifier then
					added_modifier:SetStackCount(modifier:GetStackCount())
				end
			end
		end
	end

	image:SetAbilityPoints(0)

	image:SetHasInventory(false)
	image:SetCanSellItems(false)

	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_image", {duration = duration})
	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {duration = duration})

	local modifier_handler = image:AddNewModifier(self:GetCaster(), self, "modifier_mows_slasher", {duration = duration})
	
	if modifier_handler then
		modifier_handler.original_caster = self:GetCaster()
	end

	FindClearSpaceForUnit(image, target:GetAbsOrigin() + RandomVector(128), false)

	image:EmitSound("Hero_Juggernaut.OmniSlash")

	self:GetCaster():RemoveModifierByName("modifier_mows_remove_as_limit")

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			if image:GetUnitName() == "npc_dota_hero_juggernaut" then
				StartAnimation(image, {activity = ACT_DOTA_OVERRIDE_ABILITY_4, rate = 1, duration = duration})
			end
		end
	end)

	if target:TriggerSpellAbsorb(self) then return end

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			image:PerformAttack(target, true, true, true, true, false, false, false)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, image)
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, image:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(trail_pfx)
		end
	end)
end

--sword3
function item_master_of_weapons_sword3:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_dzzl_good_juju") then
		if self then
			return (self:GetSpecialValueFor("good_juju_cd") / self:GetCaster():GetCooldownReduction()) / 0.58
		end	
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end

function item_master_of_weapons_sword3:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster() then return end
	if not self:GetCaster():IsRealHero() then return end
	if self:GetCaster():HasModifier("modifier_courier_invincibility") then return end
	local target = self:GetCursorTarget()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {})
	local additional_duration = math.floor(self:GetCaster():GetDisplayAttackSpeed() / 1500)
--	print("Print DisplayAttackSpeed", self:GetCaster():GetDisplayAttackSpeed())
--	print("Print additional_duration", additional_duration)
	local duration = self:GetSpecialValueFor("duration") + (additional_duration * 1)

	local previous_position = self:GetCaster():GetAbsOrigin()
	
	self:GetCaster():Purge(false, true, false, false, false)

	local image = CreateUnitByName(self:GetCaster():GetUnitName(), target:GetAbsOrigin(), true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber())

	local caster_level = self:GetCaster():GetLevel()
	for i = 2, caster_level do
		image:HeroLevelUp(false)
	end

	local non_transfer = {
		["item_smoke_of_deceit"] = true,
		["item_ward_observer"] = true,
		["item_ward_sentry"] = true,
		["item_all_essence"] = true,
		["item_thunder_hammer"] = true,
		["item_thunder_gods_might"] = true,
		["item_thunder_gods_might2"] = true,
	}

	-- Copy Abilities
	local ability_count = self:GetCaster():GetAbilityCount()
	for ability_id = 0, ability_count - 1 do
		local ability = image:GetAbilityByIndex(ability_id)
		if ability then
			if not non_transfer[ability:GetAbilityName()] then
				local caster_ability = self:GetCaster():FindAbilityByName(ability:GetAbilityName())
				if caster_ability and caster_ability:IsTrained() then
					ability:SetLevel(caster_ability:GetLevel())
				end
			end
		end
	end
	image:AddItemByName("item_moon_shard")
	image:AddItemByName("item_moon_shard")
	-- Copy Items
	for item_id = 0, 5 do
		local item_in_caster = self:GetCaster():GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			if not non_transfer[item_in_caster:GetName()] then
				local item_created = CreateItem(item_in_caster:GetName(), image, image)
				image:AddItem(item_created)
				item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges())
			end
		end
	end
	-- Copy Neutral Item
	local neutral_item = self:GetCaster():GetItemInSlot(16)
	if neutral_item ~= nil then
		if not non_transfer[neutral_item:GetName()] then
			local neutral_item_created = CreateItem(neutral_item:GetName(), image, image)
			image:AddItem(neutral_item_created)
			neutral_item_created:SetCurrentCharges(neutral_item:GetCurrentCharges())
		end
	end

	-- Copy Modifiers
	local ignored_modifiers = {
		["modifier_wind_rapier_agility_buff"] = true,
		["modifier_item_pharaoh_crown"] = true,
		["modifier_item_pharaoh_crown_initiate"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_item_aghanims_shard"] = true,
		["modifier_mows_remove_as_limit"] = true,
		["modifier_thunder_gods_might"] = true,
		["modifier_thunder_gods_might2"] = true,
		["modifier_thunder_hammer"] = true,
		["modifier_item_thunder_god_might_aura"] = true,
		["modifier_item_thunder_god_might_aura2"] = true,		
		["modifier_totem_aura_effect"] = true,
		["modifier_totem_aura"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_grimstroke_custom_soulstore"] = true,
		["modifier_invoker_quas_instance"] = true,
		["modifier_invoker_wex_instance"] = true,
	}

	local caster_modifiers = self:GetCaster():FindAllModifiers()
	for _, modifier in pairs(caster_modifiers) do
		if modifier and not ignored_modifiers[modifier:GetName()] then
			local added_modifier = image:AddNewModifier(modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), {duration = modifier:GetDuration()})
			if modifier:GetStackCount() > 0 then
				if added_modifier then
					added_modifier:SetStackCount(modifier:GetStackCount())
				end
			end
		end
	end

	image:SetAbilityPoints(0)

	image:SetHasInventory(false)
	image:SetCanSellItems(false)

	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_image", {duration = duration})
	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {duration = duration})

	local modifier_handler = image:AddNewModifier(self:GetCaster(), self, "modifier_mows_slasher", {duration = duration})
	
	if modifier_handler then
		modifier_handler.original_caster = self:GetCaster()
	end

	FindClearSpaceForUnit(image, target:GetAbsOrigin() + RandomVector(128), false)

	image:EmitSound("Hero_Juggernaut.OmniSlash")

	self:GetCaster():RemoveModifierByName("modifier_mows_remove_as_limit")

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			if image:GetUnitName() == "npc_dota_hero_juggernaut" then
				StartAnimation(image, {activity = ACT_DOTA_OVERRIDE_ABILITY_4, rate = 1, duration = duration})
			end
		end
	end)

	if target:TriggerSpellAbsorb(self) then return end

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			image:PerformAttack(target, true, true, true, true, false, false, false)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, image)
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, image:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(trail_pfx)
		end
	end)
end

--sword4
function item_master_of_weapons_sword4:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_dzzl_good_juju") then
		if self then
			return (self:GetSpecialValueFor("good_juju_cd") / self:GetCaster():GetCooldownReduction()) / 0.58
		end	
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end

function item_master_of_weapons_sword4:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster() then return end
	if not self:GetCaster():IsRealHero() then return end
	if self:GetCaster():HasModifier("modifier_courier_invincibility") then return end
	local target = self:GetCursorTarget()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {})
	local additional_duration = math.floor(self:GetCaster():GetDisplayAttackSpeed() / 1500)
--	print("Print DisplayAttackSpeed", self:GetCaster():GetDisplayAttackSpeed())
--	print("Print additional_duration", additional_duration)
	local duration = self:GetSpecialValueFor("duration") + (additional_duration * 1)

	local previous_position = self:GetCaster():GetAbsOrigin()
	
	self:GetCaster():Purge(false, true, false, false, false)

	local image = CreateUnitByName(self:GetCaster():GetUnitName(), target:GetAbsOrigin(), true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber())

	local caster_level = self:GetCaster():GetLevel()
	for i = 2, caster_level do
		image:HeroLevelUp(false)
	end

	local non_transfer = {
		["item_smoke_of_deceit"] = true,
		["item_ward_observer"] = true,
		["item_ward_sentry"] = true,
		["item_all_essence"] = true,
		["item_thunder_hammer"] = true,
		["item_thunder_gods_might"] = true,
		["item_thunder_gods_might2"] = true,
	}

	-- Copy Abilities
	local ability_count = self:GetCaster():GetAbilityCount()
	for ability_id = 0, ability_count - 1 do
		local ability = image:GetAbilityByIndex(ability_id)
		if ability then
			if not non_transfer[ability:GetAbilityName()] then
				local caster_ability = self:GetCaster():FindAbilityByName(ability:GetAbilityName())
				if caster_ability and caster_ability:IsTrained() then
					ability:SetLevel(caster_ability:GetLevel())
				end
			end
		end
	end

	-- Copy Items
	for item_id = 0, 5 do
		local item_in_caster = self:GetCaster():GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			if not non_transfer[item_in_caster:GetName()] then
				local item_created = CreateItem(item_in_caster:GetName(), image, image)
				image:AddItem(item_created)
				item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges())
			end
		end
	end
	image:AddItemByName("item_moon_shard")
	image:AddItemByName("item_moon_shard")	
	-- Copy Neutral Item
	local neutral_item = self:GetCaster():GetItemInSlot(16)
	if neutral_item ~= nil then
		if not non_transfer[neutral_item:GetName()] then
			local neutral_item_created = CreateItem(neutral_item:GetName(), image, image)
			image:AddItem(neutral_item_created)
			neutral_item_created:SetCurrentCharges(neutral_item:GetCurrentCharges())
		end
	end

	-- Copy Modifiers
	local ignored_modifiers = {
		["modifier_wind_rapier_agility_buff"] = true,
		["modifier_item_pharaoh_crown"] = true,
		["modifier_item_pharaoh_crown_initiate"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_item_aghanims_shard"] = true,
		["modifier_mows_remove_as_limit"] = true,
		["modifier_thunder_gods_might"] = true,
		["modifier_thunder_gods_might2"] = true,
		["modifier_thunder_hammer"] = true,
		["modifier_item_thunder_god_might_aura"] = true,
		["modifier_item_thunder_god_might_aura2"] = true,		
		["modifier_totem_aura_effect"] = true,
		["modifier_totem_aura"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_grimstroke_custom_soulstore"] = true,
		["modifier_invoker_quas_instance"] = true,
		["modifier_invoker_wex_instance"] = true,
	}

	local caster_modifiers = self:GetCaster():FindAllModifiers()
	for _, modifier in pairs(caster_modifiers) do
		if modifier and not ignored_modifiers[modifier:GetName()] then
			local added_modifier = image:AddNewModifier(modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), {duration = modifier:GetDuration()})
			if modifier:GetStackCount() > 0 then
				if added_modifier then
					added_modifier:SetStackCount(modifier:GetStackCount())
				end
			end
		end
	end

	image:SetAbilityPoints(0)

	image:SetHasInventory(false)
	image:SetCanSellItems(false)

	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_image", {duration = duration})
	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {duration = duration})

	local modifier_handler = image:AddNewModifier(self:GetCaster(), self, "modifier_mows_slasher", {duration = duration})
	
	if modifier_handler then
		modifier_handler.original_caster = self:GetCaster()
	end

	FindClearSpaceForUnit(image, target:GetAbsOrigin() + RandomVector(128), false)

	image:EmitSound("Hero_Juggernaut.OmniSlash")

	self:GetCaster():RemoveModifierByName("modifier_mows_remove_as_limit")

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			if image:GetUnitName() == "npc_dota_hero_juggernaut" then
				StartAnimation(image, {activity = ACT_DOTA_OVERRIDE_ABILITY_4, rate = 1, duration = duration})
			end
		end
	end)

	if target:TriggerSpellAbsorb(self) then return end

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			image:PerformAttack(target, true, true, true, true, false, false, false)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, image)
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, image:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(trail_pfx)
		end
	end)
end

--sword5
function item_master_of_weapons_sword5:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_dzzl_good_juju") then
		if self then
			return (self:GetSpecialValueFor("good_juju_cd") / self:GetCaster():GetCooldownReduction()) / 0.58
		end	
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end

function item_master_of_weapons_sword5:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster() then return end
	if not self:GetCaster():IsRealHero() then return end
	if self:GetCaster():HasModifier("modifier_courier_invincibility") then return end
	local target = self:GetCursorTarget()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {})
	local additional_duration = math.floor(self:GetCaster():GetDisplayAttackSpeed() / 1500)
--	print("Print DisplayAttackSpeed", self:GetCaster():GetDisplayAttackSpeed())
--	print("Print additional_duration", additional_duration)
	local duration = self:GetSpecialValueFor("duration") + (additional_duration * 1)

	local previous_position = self:GetCaster():GetAbsOrigin()
	
	self:GetCaster():Purge(false, true, false, false, false)

	local image = CreateUnitByName(self:GetCaster():GetUnitName(), target:GetAbsOrigin(), true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber())

	local caster_level = self:GetCaster():GetLevel()
	for i = 2, caster_level do
		image:HeroLevelUp(false)
	end

	local non_transfer = {
		["item_smoke_of_deceit"] = true,
		["item_ward_observer"] = true,
		["item_ward_sentry"] = true,
		["item_all_essence"] = true,
		["item_thunder_hammer"] = true,
		["item_thunder_gods_might"] = true,
		["item_thunder_gods_might2"] = true,
	}

	-- Copy Abilities
	local ability_count = self:GetCaster():GetAbilityCount()
	for ability_id = 0, ability_count - 1 do
		local ability = image:GetAbilityByIndex(ability_id)
		if ability then
			if not non_transfer[ability:GetAbilityName()] then
				local caster_ability = self:GetCaster():FindAbilityByName(ability:GetAbilityName())
				if caster_ability and caster_ability:IsTrained() then
					ability:SetLevel(caster_ability:GetLevel())
				end
			end
		end
	end

	-- Copy Items
	for item_id = 0, 5 do
		local item_in_caster = self:GetCaster():GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			if not non_transfer[item_in_caster:GetName()] then
				local item_created = CreateItem(item_in_caster:GetName(), image, image)
				image:AddItem(item_created)
				item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges())
			end
		end
	end
	image:AddItemByName("item_moon_shard")
	image:AddItemByName("item_moon_shard")	
	-- Copy Neutral Item
	local neutral_item = self:GetCaster():GetItemInSlot(16)
	if neutral_item ~= nil then
		if not non_transfer[neutral_item:GetName()] then
			local neutral_item_created = CreateItem(neutral_item:GetName(), image, image)
			image:AddItem(neutral_item_created)
			neutral_item_created:SetCurrentCharges(neutral_item:GetCurrentCharges())
		end
	end

	-- Copy Modifiers
	local ignored_modifiers = {
		["modifier_wind_rapier_agility_buff"] = true,
		["modifier_item_pharaoh_crown"] = true,
		["modifier_item_pharaoh_crown_initiate"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_item_aghanims_shard"] = true,
		["modifier_mows_remove_as_limit"] = true,
		["modifier_thunder_gods_might"] = true,
		["modifier_thunder_gods_might2"] = true,
		["modifier_thunder_hammer"] = true,
		["modifier_item_thunder_god_might_aura"] = true,
		["modifier_item_thunder_god_might_aura2"] = true,		
		["modifier_totem_aura_effect"] = true,
		["modifier_totem_aura"] = true,
		["modifier_custom_no_heal_effect"] = true,
		["modifier_grimstroke_custom_soulstore"] = true,
		["modifier_invoker_quas_instance"] = true,
		["modifier_invoker_wex_instance"] = true,
	}

	local caster_modifiers = self:GetCaster():FindAllModifiers()
	for _, modifier in pairs(caster_modifiers) do
		if modifier and not ignored_modifiers[modifier:GetName()] then
			local added_modifier = image:AddNewModifier(modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), {duration = modifier:GetDuration()})
			if modifier:GetStackCount() > 0 then
				if added_modifier then
					added_modifier:SetStackCount(modifier:GetStackCount())
				end
			end
		end
	end


	image:SetAbilityPoints(0)

	image:SetHasInventory(false)
	image:SetCanSellItems(false)

	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_image", {duration = duration})
	image:AddNewModifier(self:GetCaster(), self, "modifier_mows_remove_as_limit", {duration = duration})

	local modifier_handler = image:AddNewModifier(self:GetCaster(), self, "modifier_mows_slasher", {duration = duration})
	
	if modifier_handler then
		modifier_handler.original_caster = self:GetCaster()
	end

	FindClearSpaceForUnit(image, target:GetAbsOrigin() + RandomVector(128), false)

	image:EmitSound("Hero_Juggernaut.OmniSlash")

	self:GetCaster():RemoveModifierByName("modifier_mows_remove_as_limit")

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			if image:GetUnitName() == "npc_dota_hero_juggernaut" then
				StartAnimation(image, {activity = ACT_DOTA_OVERRIDE_ABILITY_4, rate = 1, duration = duration})
			end
		end
	end)

	if target:TriggerSpellAbsorb(self) then return end

	Timers:CreateTimer(FrameTime(), function()
		if (not image:IsNull()) then
			image:PerformAttack(target, true, true, true, true, false, false, false)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, image)
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, image:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(trail_pfx)
		end
	end)
end

-- Sword bonuses
modifier_mows = class({})
function modifier_mows:IsHidden() return self:GetStackCount() == 0 end
function modifier_mows:IsPurgable() return false end

--function modifier_mows:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_mows:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		if self:GetCaster():FindAbilityByName("gifted_weapon") then
			self:GetCaster():FindAbilityByName("gifted_weapon"):SetLevel(1)
			self:GetCaster():FindAbilityByName("gifted_weapon"):SetHidden(false)
		end
	end
end
function modifier_mows:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
function modifier_mows:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetStackCount() * (self:GetParent():GetLevel() * self:GetAbility():GetSpecialValueFor("bonus_attack_lvl")) end
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
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") * self:GetParent():GetLevel() end
end
function modifier_mows:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") * self:GetParent():GetLevel() end
end
function modifier_mows:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") * self:GetParent():GetLevel() end
end
function modifier_mows:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() * (self:GetParent():GetLevel() * self:GetAbility():GetSpecialValueFor("bonus_attack_lvl") ) end
	return self:GetStackCount() * (self:GetParent():GetLevel() * 1)
end
function modifier_mows:GetModifierOverrideAbilitySpecial(params)
	if self:GetParent() == nil or params.ability == nil then return 0 end
	if self:GetParent():HasModifier("modifier_mows_slasher") then
		if params.ability:GetAbilityName() == "item_fire_rapier" and params.ability_special_value == "proc_chance" then
			return 1
		end
	end

	return 0
end
function modifier_mows:GetModifierOverrideAbilitySpecialValue(params) 
	if self:GetParent():HasModifier("modifier_mows_slasher") then
		if params.ability:GetAbilityName() == "item_fire_rapier" and params.ability_special_value == "proc_chance" then
			if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("fire_rapier_chance") end 
		end
	end

	return 0
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
	self.last_enemy = nil
	if not self:GetAbility() then self:Destroy() return end
	if IsServer() then
		if self:GetCaster():GetPrimaryAttribute() == 0 then
			self.MaxHealth = self:GetParent():GetMaxHealth()
		else
			self.MaxHealth = 0
		end
		if (not self:GetParent():IsNull()) then
			self.bounce_range = self:GetAbility():GetSpecialValueFor("bounce_range")
			self:BounceAndSlaughter(true)
			local AttacksNumber = 3
			local BaseInterval = 0.4
			local slash_rate = self:GetAbility():GetSpecialValueFor("slash_rate") --self:GetCaster():GetSecondsPerAttack(false) / (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier"), 1))
			self:StartIntervalThink(slash_rate)
		end
	end
end

function modifier_mows_slasher:OnDestroy()
	if IsServer() then
		self:GetParent():FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_4)

		if self:GetParent():HasModifier("modifier_mows_image") and self:GetCaster() then
			local caster = self:GetCaster()
			local ability = self:GetAbility()
			local image_team = self:GetParent():GetTeamNumber()
			local image_loc = self:GetParent():GetAbsOrigin()
			local damage = caster:GetAverageTrueAttackDamage(caster) * ability:GetSpecialValueFor("attack_asdmg_multiplier")
			local radius = ability:GetSpecialValueFor("radius_expl")
			local repeat_times = 1 + (2 * math.floor(self:GetParent():GetLevel() / 20))
			--if self:GetParent():GetPrimaryAttribute() == 0 then
			if self:GetParent():GetStrength() >= 10000 then
				DMGflags = DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
			else
				DMGflags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
			end
			--end
			
			local expl_bonus_dmg = 0
			
			local nearby_enemies = FindUnitsInRadius(image_team, image_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

			for i = 1, repeat_times do
				Timers:CreateTimer(0.1 * i, function()
					if ability then
						for _,enemy in pairs(nearby_enemies) do
							ApplyDamage({
								victim = enemy,
								attacker = caster,
								ability = ability,
								damage = damage,
								damage_type = DAMAGE_TYPE_PHYSICAL,
								damage_flags = DMGflags,
							})
							if expl_bonus_dmg < 320 then
								if caster:IsAlive() then
									if caster:HasModifier("modifier_mows") then
										local stacks = caster:FindModifierByName("modifier_mows")
										stacks:SetStackCount(stacks:GetStackCount() + 1)
										expl_bonus_dmg = expl_bonus_dmg + 40
									end	
								end	
							end
						end
						if i == 1 or i == repeat_times then
							local burst = ParticleManager:CreateParticle("particles/items3_fx/blink_overwhelming_burst.vpcf", PATTACH_WORLDORIGIN, caster)
							ParticleManager:SetParticleControl(burst, 0, image_loc)
							ParticleManager:SetParticleControl(burst, 1, Vector(radius, 500, 500))
							ParticleManager:DestroyParticle(burst, false)
							ParticleManager:ReleaseParticleIndex(burst)
							EmitSoundOnLocationWithCaster(image_loc, "Blink_Layer.Overwhelming", caster)
						end
					end
				end)
			end
			
			self:GetParent():MakeIllusion()
			self:GetParent():RemoveModifierByName("modifier_mows_image")

			for item_id = 0, 5 do
				local item_in_caster = self:GetParent():GetItemInSlot(item_id)
				if item_in_caster ~= nil then
					UTIL_Remove(item_in_caster)
				end
			end
			local neutral_item = self:GetParent():GetItemInSlot(16)
			if neutral_item ~= nil then
				UTIL_Remove(neutral_item)
			end

			local caster_modifiers = self:GetParent():FindAllModifiers()
			for _,modifier in pairs(caster_modifiers) do
				if modifier then
					UTIL_Remove(modifier)
				end
			end

			if (not self:GetParent():IsNull()) then
				-- Workaround for Invoker losing buffs by simulating ability use based on instances
				if self:GetCaster() and self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
					local caster = self:GetCaster()
					local quas_count = 0
					local wex_count = 0

					-- Count Quas and Wex instances on the caster BEFORE removing the illusion and its modifiers
					local caster_modifiers = caster:FindAllModifiers()
					for _, modifier in pairs(caster_modifiers) do
						if modifier and modifier:GetName() == "modifier_invoker_quas_instance" then
							quas_count = quas_count + 1
						elseif modifier and modifier:GetName() == "modifier_invoker_wex_instance" then
							wex_count = wex_count + 1
						end
					end

					local exort_ability = caster:FindAbilityByName("invoker_exort")
					if exort_ability then
						local exort_to_add = 3 - (quas_count + wex_count)
						for i = 1, exort_to_add do
							caster:CastAbilityImmediately(exort_ability, caster:GetPlayerID())
						end
					end
				end
				UTIL_Remove(self:GetParent())
			end
		end
	end
end

function modifier_mows_slasher:OnIntervalThink()
	if not self:GetAbility() then self:Destroy() return end
	self:BounceAndSlaughter()
	
	local AttacksNumber = 3
	local BaseInterval = 0.4 
	local slash_rate = self:GetAbility():GetSpecialValueFor("slash_rate")

	self:StartIntervalThink(slash_rate)
end

function modifier_mows_slasher:BounceAndSlaughter(first_slash)
	local order = FIND_ANY_ORDER
	
	if first_slash then
		order = FIND_CLOSEST
	end
	
	self.nearby_enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.bounce_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, order, false)
	
	for count = #self.nearby_enemies, 1, -1 do
		if self.nearby_enemies[count] and (self.nearby_enemies[count]:GetName() == "npc_dota_unit_undying_zombie" or self.nearby_enemies[count]:GetName() == "npc_dota_elder_titan_ancestral_spirit") then
			table.remove(self.nearby_enemies, count)
		end
	end

	if #self.nearby_enemies >= 1 then
		for _,enemy in pairs(self.nearby_enemies) do
			local previous_position = self:GetParent():GetAbsOrigin()
			FindClearSpaceForUnit(self:GetParent(), enemy:GetAbsOrigin() + RandomVector(100), false)
			
			if not self:GetAbility() then break end

			local current_position = self:GetParent():GetAbsOrigin()

			self:GetParent():FaceTowards(enemy:GetAbsOrigin())
			
			AddFOWViewer(self:GetCaster():GetTeamNumber(), enemy:GetAbsOrigin(), 200, 1, false)
			
			if first_slash and enemy:TriggerSpellAbsorb(self:GetAbility()) then
				break
			else
				self:GetParent():PerformAttack(enemy, true, true, true, true, false, false, false)
			end

--			enemy:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
			enemy:EmitSound("Hero_Juggernaut.BladeFuryStop")

			local hit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControl(hit_pfx, 0, current_position)
			ParticleManager:SetParticleControl(hit_pfx, 1, current_position)
			ParticleManager:ReleaseParticleIndex(hit_pfx)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, current_position)
			ParticleManager:ReleaseParticleIndex(trail_pfx)

			if self.last_enemy ~= enemy then
				local dash_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_dash.vpcf", PATTACH_ABSORIGIN, self:GetParent())
				ParticleManager:SetParticleControl(dash_pfx, 0, previous_position)
				ParticleManager:SetParticleControl(dash_pfx, 2, current_position)
				ParticleManager:ReleaseParticleIndex(dash_pfx)
			end

			self.last_enemy = enemy

			if self:GetParent():HasModifier("modifier_mows_image") then
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
		return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
	end
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_mows_slasher:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_4 end
function modifier_mows_slasher:GetModifierBaseAttack_BonusDamage() return self.MaxHealth end

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
function modifier_mows_remove_as_limit:GetModifierAttackSpeed_Limit() return 1 end
