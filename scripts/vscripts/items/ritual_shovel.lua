LinkLuaModifier("modifier_ritual_shovel", "items/ritual_shovel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shovel_curse", "items/ritual_shovel", LUA_MODIFIER_MOTION_NONE)

item_ritual_shovel = item_ritual_shovel or class({})
function item_ritual_shovel:GetIntrinsicModifierName() return "modifier_ritual_shovel" end
function item_ritual_shovel:OnSpellStart()
	if not IsServer() then return end
	self.portal = self:GetSpecialValueFor("portal_chance")
	self.powerup = self:GetSpecialValueFor("powerup_rune_chance") + self.portal
	self.bounty = self:GetSpecialValueFor("bounty_rune_chance") + self.powerup
	self.flask = self:GetSpecialValueFor("flask_chance") + self.bounty
	self.kobold = self:GetSpecialValueFor("kobold_chance") + self.flask
	self.pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/shovel_dig.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.pfx, 0, self:GetCursorPosition())
	EmitSoundOn("SeasonalConsumable.TI9.Shovel.Dig", self:GetCaster())
end
function item_ritual_shovel:OnChannelThink(fInterval) if not IsServer() then return end end
function item_ritual_shovel:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	local hp_loss = self:GetSpecialValueFor("hp_loss")
	local hp_per_stack = self:GetSpecialValueFor("hp_per_stack")
	hp_loss = (hp_loss + (hp_per_stack * self:GetCaster():FindModifierByName("modifier_shovel_curse"):GetStackCount())) * (1 + self:GetCaster():GetSpellAmplification(false))
	ApplyDamage({victim = self:GetCaster(), attacker = self:GetCaster(), ability = self, damage = hp_loss, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
	create_popup({target = self:GetCaster(), value = hp_loss, color = Vector(255, 40, 40), type = "poison", pos = 4})

	-- UP: Holy Locket
	local up_chance = self:GetSpecialValueFor("up_chance")
	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
		local item = self:GetParent():GetItemInSlot(i)
		if item then
			if item:GetAbilityName() == "item_holy_locket" then
				if item:GetCurrentCharges() >= 15 then
					if RollPseudoRandom(up_chance, self) then
						self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_shovel_curse", {})
					end
				else
					self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_shovel_curse", {})
				end
			else
				self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_shovel_curse", {})
			end
		end
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
		if random_int > 0 and random_int <= self.portal then
			local portal = RandomInt(1, 70)
			if portal > 0 and portal <= 25 then
				SpawnItem("item_portal_1", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
--				SpawnItem("item_portal", self:GetAbsOrigin(), ITEM_NOT_SHAREABLE, false)
			elseif portal > 25 and portal <= 43 then
				SpawnItem("item_portal_2", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
--				SpawnItem("item_portal", self:GetAbsOrigin(), ITEM_NOT_SHAREABLE, false)
			elseif portal > 43 and portal <= 55 then
				SpawnItem("item_portal_3", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
--				SpawnItem("item_portal", self:GetAbsOrigin(), ITEM_NOT_SHAREABLE, false)
			elseif portal > 55 and portal <= 63 then
				SpawnItem("item_portal_4", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
--				SpawnItem("item_portal", self:GetAbsOrigin(), ITEM_NOT_SHAREABLE, false)
			elseif portal > 63 and portal <= 67 then
				SpawnItem("item_portal_5", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
--				SpawnItem("item_portal", self:GetAbsOrigin(), ITEM_NOT_SHAREABLE, false)
			elseif portal > 67 and portal <= 69 then
				SpawnItem("item_portal_6", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
--				SpawnItem("item_portal", self:GetAbsOrigin(), ITEM_NOT_SHAREABLE, false)
			elseif portal == 70 then
				SpawnItem("item_portal_7", self:GetCursorPosition(), ITEM_NOT_SHAREABLE, false)
--				SpawnItem("item_portal", self:GetAbsOrigin(), ITEM_NOT_SHAREABLE, false)
			end
		end
		if random_int > self.portal and random_int <= self.powerup then
			local random_rune = RandomInt(1, 5)
			if random_rune == 1 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_DOUBLEDAMAGE)
			elseif random_rune == 2 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_HASTE)
			elseif random_rune == 3 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_ILLUSION)
			elseif random_rune == 4 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_REGENERATION)
			elseif random_rune == 5 then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_ARCANE)
			end
		elseif random_int > self.powerup and random_int <= self.bounty then
			if RollPseudoRandom(50, self) then
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_BOUNTY)
			else
				CreateRune(self:GetCursorPosition(), DOTA_RUNE_WATER)
			end
		elseif random_int > self.bounty and random_int <= self.flask then
			SpawnItem("item_flask", self:GetCursorPosition(), ITEM_FULLY_SHAREABLE, true)
		elseif random_int > self.flask and random_int <= self.kobold then
			CreateUnitByName("npc_dota_neutral_kobold", self:GetCursorPosition(), true, nil, nil, DOTA_TEAM_NEUTRALS)
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
