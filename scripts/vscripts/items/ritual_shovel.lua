LinkLuaModifier("modifier_ritual_shovel", "items/ritual_shovel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shovel_curse", "items/ritual_shovel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tome_str_bonus", "items/tomes.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tome_agi_bonus", "items/tomes.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tome_int_bonus", "items/tomes.lua", LUA_MODIFIER_MOTION_NONE)
local chen_first_spawn = true
item_ritual_shovel = item_ritual_shovel or class({})
function item_ritual_shovel:IsMuted()
	if not self:GetCaster():IsRealHero() then
		return true
	end
	return false
end
function item_ritual_shovel:GetCastRange(location, target)
	return 250 - self:GetCaster():GetCastRangeBonus()
end
function item_ritual_shovel:GetIntrinsicModifierName() return "modifier_ritual_shovel" end
function item_ritual_shovel:OnSpellStart()
	if not IsServer() then return end
	self.ultra_rare = self:GetSpecialValueFor("ultra_rare_chance")
	self.rare = self:GetSpecialValueFor("rare_chance") + self.ultra_rare
	self.rune = self:GetSpecialValueFor("rune_chance") + self.rare
	self.book_of_stats = self:GetSpecialValueFor("book_chance") + self.rune
	self.kobold = self:GetSpecialValueFor("kobold_chance") + self.book_of_stats
	self.pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/shovel_dig.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.pfx, 0, self:GetCursorPosition())
	EmitSoundOn("SeasonalConsumable.TI9.Shovel.Dig", self:GetCaster())
end
function item_ritual_shovel:OnChannelThink(fInterval) if not IsServer() then return end end
function item_ritual_shovel:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	local hp_loss = self:GetSpecialValueFor("hp_loss")
	local hp_per_stack = self:GetSpecialValueFor("hp_per_stack")
	hp_loss = (hp_loss + (hp_per_stack * self:GetCaster():FindModifierByName("modifier_shovel_curse"):GetStackCount()))-- * (1 + self:GetCaster():GetSpellAmplification(false))
	ApplyDamage({victim = self:GetCaster(), attacker = self:GetCaster(), ability = self, damage = hp_loss, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	create_popup({target = self:GetCaster(), value = hp_loss, color = Vector(255, 40, 40), type = "poison", pos = 4})

	-- UP: Holy Locket
	local up_chance = self:GetSpecialValueFor("up_chance")
	local up = false
	for itemSlot = 0, 5 do
		local item = self:GetParent():GetItemInSlot(itemSlot)
		if item and item:GetName() == "item_holy_locket" then
			if item:GetCurrentCharges() >= 15 then
				if RollPseudoRandom(up_chance, self) then
					up = true
					break
				end
			end
		end
	end
	if not up then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_shovel_curse", {})
	end
	------------------

	local blood_fx = ParticleManager:CreateParticle("particles/custom/items/ritual_shovel/curse_blood.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(blood_fx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(blood_fx)
	local mana = hp_loss / 2
	self:GetCaster():GiveMana(mana)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self:GetCaster(), mana, nil)
	if not bInterrupted then
		local random_int = RandomInt(1, 100)
		if random_int > 0 and random_int <= self.ultra_rare then
			local ultra_rare = RandomInt(1, 100)
			if ultra_rare > 0 and ultra_rare <= 5 then
				SpawnItem("item_enchanter", self:GetCursorPosition(), ITEM_FULLY_SHAREABLE, false)
			elseif ultra_rare > 5 and ultra_rare <= 30 then
				SpawnItem("item_edible_fragment", self:GetCursorPosition(), ITEM_FULLY_SHAREABLE, false)
			elseif ultra_rare > 30 and ultra_rare <= 100 then
				local atr = RandomInt(1, 3)
				local TomeAttributes = 200
				if atr == 1 then
					self:GetParent():ModifyStrength(TomeAttributes)
					Add_Attributes(self:GetParent(), "modifier_tome_str_bonus", TomeAttributes)
				elseif atr == 2 then
					self:GetParent():ModifyAgility(TomeAttributes)
					Add_Attributes(self:GetParent(), "modifier_tome_agi_bonus", TomeAttributes)
				elseif atr == 3 then
					self:GetParent():ModifyIntellect(TomeAttributes)
					Add_Attributes(self:GetParent(), "modifier_tome_int_bonus", TomeAttributes)
				end
			end
		elseif random_int > self.ultra_rare and random_int <= self.rare then
			local rare = RandomInt(1, 100)
			if rare > 0 and rare <= 5 then
				SpawnItem("item_philosophers_stone2", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
			elseif rare > 5 and rare <= 10 then
				SpawnItem("item_removed_skill", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
			elseif rare > 10 and rare <= 30 then
				SpawnItem("item_aghanims_fragment", self:GetCursorPosition(), ITEM_FULLY_SHAREABLE, false)
			elseif rare > 30 and rare <= 50 then
				local item = CreateItem("item_tome_of_knowledge", nil, nil)
				self:GetParent():AddItem(item)
				self:GetParent():FindItemInInventory("item_tome_of_knowledge"):EndCooldown()
			elseif rare > 50 and rare <= 100 then
				local atr = RandomInt(1, 3)
				local TomeAttributes = 50
				if atr == 1 then
					self:GetParent():ModifyStrength(TomeAttributes)
					Add_Attributes(self:GetParent(), "modifier_tome_str_bonus", TomeAttributes)
				elseif atr == 2 then
					self:GetParent():ModifyAgility(TomeAttributes)
					Add_Attributes(self:GetParent(), "modifier_tome_agi_bonus", TomeAttributes)
				elseif atr == 3 then
					self:GetParent():ModifyIntellect(TomeAttributes)
					Add_Attributes(self:GetParent(), "modifier_tome_int_bonus", TomeAttributes)
				end
			end
		elseif random_int > self.rare and random_int <= self.rune then
			local random_rune = RandomInt(1, 7)
			if random_rune == 1 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_DOUBLEDAMAGE)
			elseif random_rune == 2 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_HASTE)
			elseif random_rune == 3 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_SHIELD)
			elseif random_rune == 4 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_ARCANE)
			elseif random_rune == 5 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_INVISIBILITY)
			elseif random_rune == 6 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_XP)
			elseif random_rune == 7 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_BOUNTY)
			end
		elseif random_int > self.rune and random_int <= self.book_of_stats then
			SpawnItem("item_primary_attribute_book", self:GetCursorPosition(), ITEM_FULLY_SHAREABLE, true)
		elseif random_int > self.book_of_stats and random_int <= self.kobold then
			if chen_first_spawn and self:GetCaster():GetName() == "npc_dota_hero_chen" then
				chen_first_spawn = false
				local huskar = CreateUnitByName("npc_dota_custom_creep_28_3", self:GetCursorPosition(), true, nil, nil, DOTA_TEAM_BADGUYS)
				local lvl = self:GetCaster():GetLevel()
				huskar:SetBaseDamageMax(lvl * 500)
				if lvl > 65 then
					lvl = lvl * 10
				end
				huskar:SetBaseMaxHealth(lvl * 1000)
				
			elseif RollPseudoRandom(80, self) then
				CreateUnitByName("npc_dota_neutral_kobold", self:GetCursorPosition(), true, nil, nil, DOTA_TEAM_BADGUYS)
			else
				local random_ultracreep = RandomInt(1, 2)
				if random_ultracreep <= 1 then
					local huskar = CreateUnitByName("npc_dota_custom_creep_28_3", self:GetCursorPosition(), true, nil, nil, DOTA_TEAM_BADGUYS)
					local lvl = self:GetCaster():GetLevel()
					huskar:SetBaseDamageMax(lvl * 500)
					if lvl > 65 then
						lvl = lvl * 10
					end
					huskar:SetBaseMaxHealth(lvl * 1000)
				elseif random_ultracreep == 2 then
					CreateUnitByName("npc_dota_inv_warrior", self:GetCursorPosition(), true, nil, nil, DOTA_TEAM_BADGUYS)
				end
			end
		end
		local pfx2 = ParticleManager:CreateParticle("particles/econ/events/ti9/shovel_revealed_generic.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(pfx2, 0, self:GetCursorPosition())
		ParticleManager:ReleaseParticleIndex(pfx2)
	end
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	StopSoundOn("SeasonalConsumable.TI9.Shovel.Dig", self:GetCaster())
end
function SpawnItem(ItemName, Pos, Share, Sell)
	local item = CreateItem(ItemName, nil, nil)
--	item:SetSellable(Sell)
	item:SetShareability(Share)
	item:SetPurchaseTime(0)
	CreateItemOnPositionSync(Pos, item)
end
function Add_Attributes(caster, modifier_name, count)
	if caster:HasModifier(modifier_name) then
		local modifier = caster:FindModifierByName(modifier_name)
		modifier:SetStackCount(modifier:GetStackCount() + count)
	else
		caster:AddNewModifier(caster, self, modifier_name, {})
		caster:FindModifierByName(modifier_name):SetStackCount(count)
	end
end

modifier_ritual_shovel = modifier_ritual_shovel or class({})
function modifier_ritual_shovel:IsHidden() return true end
function modifier_ritual_shovel:IsPurgable() return false end
function modifier_ritual_shovel:IsPurgeException() return false end
function modifier_ritual_shovel:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_shovel_curse") then self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shovel_curse", {}) end
end
function modifier_ritual_shovel:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_ritual_shovel:GetModifierHealthBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp") end end
function modifier_ritual_shovel:GetModifierBonusStats_Strength() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str") end end
function modifier_ritual_shovel:GetModifierPhysicalArmorBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("armor") end end
function modifier_ritual_shovel:CheckState() return {[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true} end


modifier_shovel_curse = class({})
function modifier_shovel_curse:IsHidden() return false end
function modifier_shovel_curse:IsDebuff() return false end
function modifier_shovel_curse:IsPurgable() return false end
function modifier_shovel_curse:RemoveOnDeath() return false end
function modifier_shovel_curse:OnCreated() if not IsServer() then return end self:SetStackCount(0) end
function modifier_shovel_curse:OnRefresh() if not IsServer() then return end self:IncrementStackCount() end
function modifier_shovel_curse:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function modifier_shovel_curse:OnTooltip() return self:GetAbility():GetSpecialValueFor("hp_loss") + (self:GetStackCount() * 50) end
