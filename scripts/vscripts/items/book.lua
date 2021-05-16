----------------------------
-- Spellbook: Destruction --
----------------------------
LinkLuaModifier("modifier_spellbook_destruction", "items/book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellbook_destruction_burn", "items/book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellbook_destruction_mana_drain", "items/book.lua", LUA_MODIFIER_MOTION_NONE)

item_spellbook_destruction = class({})
modifier_spellbook_destruction = class({})
modifier_spellbook_destruction_burn = class({})
modifier_spellbook_destruction_mana_drain = class({})

function item_spellbook_destruction:GetIntrinsicModifierName() return "modifier_spellbook_destruction" end
function item_spellbook_destruction:GetAOERadius()
	return self:GetSpecialValueFor("impact_radius") + (self:GetCaster():GetMaxMana()/30)
end
function item_spellbook_destruction:OnSpellStart()
	self.ImpactRadius = self:GetSpecialValueFor("impact_radius") + (self:GetCaster():GetMaxMana()/30)
	-- Level 4 (and above?) pierces magic immunity
	if self:GetLevel() >= 4 then
		self.targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	else
		self.targetFlag = DOTA_UNIT_TARGET_FLAG_NONE
	end
	if not IsServer() then return end
	self:GetCaster():EmitSound("DOTA_Item.MeteorHammer.Channel")
--	AddFOWViewer(self:GetCaster():GetTeam(), self:GetCursorPosition(), self.ImpactRadius, 3.8, false)

	self.particle = ParticleManager:CreateParticleForTeam("particles/custom/items/spellbook/destruction/spellbook_destruction_cast_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeam())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(self.ImpactRadius, 1, 1))
	self.particle2 = ParticleManager:CreateParticle("particles/custom/items/spellbook/destruction/spellbook_destruction_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_spellbook_destruction_mana_drain", {})

	self:GetCaster():StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
end
function item_spellbook_destruction:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	self:GetCaster():RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
	self:GetCaster():RemoveModifierByName("modifier_spellbook_destruction_mana_drain")
	if bInterrupted then
		self:GetCaster():StopSound("DOTA_Item.MeteorHammer.Channel")
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:DestroyParticle(self.particle2, true)
	else
		self:GetCaster():EmitSound("DOTA_Item.MeteorHammer.Cast")

		local mana_left = self:GetCaster():GetMana()
--		Timers:CreateTimer(2, function()
			if not self:IsNull() then
				self.particle3	= ParticleManager:CreateParticle("particles/custom/items/spellbook/destruction/spellbook_destruction_impact.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
				ParticleManager:SetParticleControl(self.particle3, 0, self:GetCursorPosition() + Vector(0, 0, 0))
				ParticleManager:SetParticleControl(self.particle3, 1, self:GetCursorPosition())
				ParticleManager:SetParticleControl(self.particle3, 2, Vector(self.ImpactRadius, 1, 1))
				ParticleManager:ReleaseParticleIndex(self.particle3)
			
				GridNav:DestroyTreesAroundPoint(self:GetCursorPosition(), self.ImpactRadius, true)

				EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "DOTA_Item.MeteorHammer.Impact", self:GetCaster())

				local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self.ImpactRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				for _, enemy in pairs(enemies) do
					enemy:EmitSound("DOTA_Item.MeteorHammer.Damage")
					enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration") * (1 - enemy:GetStatusResistance())})
					enemy:AddNewModifier(self:GetCaster(), self, "modifier_spellbook_destruction_burn", {duration = self:GetSpecialValueFor("burn_duration")})

					local impactDamage = (self:GetCaster():GetMaxMana() * 2) + (mana_left * 2)
					local damageTable = {
						victim = enemy,
						damage = impactDamage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						damage_flags = DOTA_DAMAGE_FLAG_NONE,
						attacker = self:GetCaster(),
						ability = self
					}
					ApplyDamage(damageTable)
				end
			end
--		end)
		self:GetCaster():SetMana(0)
	end
	ParticleManager:ReleaseParticleIndex(self.particle)
	ParticleManager:ReleaseParticleIndex(self.particle2)
end

------------------------------------------
-- Spellbook: Destruction Burn Modifier --
------------------------------------------
function modifier_spellbook_destruction_burn:GetEffectName() return "particles/custom/items/spellbook/destruction/spellbook_destruction_debuff.vpcf" end
function modifier_spellbook_destruction_burn:IgnoreTenacity() return true end
function modifier_spellbook_destruction_burn:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spellbook_destruction_burn:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.burn_dps = self:GetAbility():GetSpecialValueFor("burn_dps")
		self.damageTable = {
			victim = self:GetParent(),
			damage = self.burn_dps,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			attacker = self:GetCaster(),
			ability = self:GetAbility()
			}
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("burn_interval"))
	end
end
function modifier_spellbook_destruction_burn:OnIntervalThink()
	if not IsServer() then return end
	ApplyDamage(self.damageTable)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.burn_dps, nil)
end
function modifier_spellbook_destruction_burn:CheckState()
	local state = {}
	-- Level 2 and above applies Break
	if self ~= nil and self:GetAbility() ~= nil and not self:GetAbility():IsNull() and self:GetAbility():GetLevel() >= 2 then
		state = {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
	end
	return state
end
function modifier_spellbook_destruction_burn:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_spellbook_destruction_burn:GetModifierSpellAmplify_Percentage()
	-- Level 3 and above reduces spell amp
	if self ~= nil and self:GetAbility() ~= nil and not self:GetAbility():IsNull() and self:GetAbility():GetLevel() >= 3 then
		return self:GetAbility():GetSpecialValueFor("spell_reduction_pct") * (-1)
	end
	return 0
end
-- particles/items_fx/abyssal_blade_crimson_impact_sparks.vpcf -- for break?

-------------------------------------
-- Spellbook: Destruction Modifier --
-------------------------------------
function modifier_spellbook_destruction:IsHidden() return true end
function modifier_spellbook_destruction:IsPurgable() return false end
function modifier_spellbook_destruction:RemoveOnDeath() return false end
function modifier_spellbook_destruction:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spellbook_destruction:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		if self:GetAbility() == nil then return end
		self.bonus_strength = self:GetAbility():GetSpecialValueFor("bonus_strength")
		self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
		self.bonus_health_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
		self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	end
end
function modifier_spellbook_destruction:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_EVENT_ON_ATTACK}
end
function modifier_spellbook_destruction:OnAttack(keys)
	if IsServer() then
		local owner = self:GetCaster()
		local target = keys.target
		if keys.attacker:GetTeamNumber() == owner:GetTeamNumber() and owner == target then
			owner:RemoveModifierByName("modifier_elder_titan_echo_stomp")
		end
	end
end
function modifier_spellbook_destruction:CheckState()
	if self:GetCaster():HasModifier("modifier_elder_titan_echo_stomp") then
		return {[MODIFIER_STATE_SPECIALLY_DENIABLE] = true}
	end
	return nil
end
function modifier_spellbook_destruction:GetModifierBonusStats_Strength() return self.bonus_strength end
function modifier_spellbook_destruction:GetModifierBonusStats_Intellect() return self.bonus_intellect end
function modifier_spellbook_destruction:GetModifierConstantHealthRegen() return self.bonus_health_regen end
function modifier_spellbook_destruction:GetModifierConstantManaRegen() return self.bonus_mana_regen end

------------------------------------------------
-- Spellbook: Destruction Drain Caster's Mana --
------------------------------------------------
function modifier_spellbook_destruction_mana_drain:IsHidden() return true end
function modifier_spellbook_destruction_mana_drain:IsPurgable() return false end
function modifier_spellbook_destruction_mana_drain:RemoveOnDeath() return false end
function modifier_spellbook_destruction_mana_drain:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spellbook_destruction_mana_drain:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local mana_drain_interval = self:GetAbility():GetSpecialValueFor("mana_drain_interval")
		local mana_drain_sec = self:GetCaster():GetMaxMana() * (self:GetAbility():GetSpecialValueFor("mana_drain_pct_sec") / 100)
		self.mana_drain_per_interval = mana_drain_sec * mana_drain_interval
		self:StartIntervalThink(mana_drain_interval)
	end
end
function modifier_spellbook_destruction_mana_drain:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():GetManaPercent() == 0 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_elder_titan_echo_stomp", {duration = self:GetAbility():GetSpecialValueFor("mana_drain_sleep")})
		end
		self:GetCaster():ReduceMana(self.mana_drain_per_interval)
	end
end
function modifier_spellbook_destruction_mana_drain:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end
