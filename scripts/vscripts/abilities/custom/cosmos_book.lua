----------------------------
-- Cosmos Spellbook: Destruction --
----------------------------
LinkLuaModifier("modifier_spellbook_destruction_boss", "abilities/custom/cosmos_book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellbook_destruction_burn_boss", "abilities/custom/cosmos_book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellbook_destruction_mana_drain_boss", "abilities/custom/cosmos_book.lua", LUA_MODIFIER_MOTION_NONE)

cosmos_book = class({})
modifier_spellbook_destruction_boss = class({})
modifier_spellbook_destruction_burn_boss = class({})
modifier_spellbook_destruction_mana_drain_boss = class({})

function cosmos_book:GetIntrinsicModifierName() return "modifier_spellbook_destruction_boss" end
function cosmos_book:GetAOERadius()
	return self:GetSpecialValueFor("impact_radius") + (self:GetCaster():GetMaxMana()/30)
end
--[[ function cosmos_book:OnSpellStart()
	self.ImpactRadius = self:GetSpecialValueFor("impact_radius") + (self:GetCaster():GetMaxMana()*0.035)
	self.targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	if not IsServer() then return end
	self:GetCaster():EmitSound("DOTA_Item.MeteorHammer.Channel")
	AddFOWViewer(self:GetCaster():GetTeam(), self:GetCursorPosition(), self.ImpactRadius, 3.8, false)

	self.particle = ParticleManager:CreateParticleForTeam("particles/custom/items/spellbook/destruction/spellbook_destruction_cast_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeam())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(self.ImpactRadius, 1, 1))
	self.particle2 = ParticleManager:CreateParticle("particles/custom/items/spellbook/destruction/spellbook_destruction_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_spellbook_destruction_mana_drain_boss", {})

	self:GetCaster():StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
end
function cosmos_book:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	self:GetCaster():RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
	self:GetCaster():RemoveModifierByName("modifier_spellbook_destruction_mana_drain_boss")
	if bInterrupted then
		self:GetCaster():StopSound("DOTA_Item.MeteorHammer.Channel")
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:DestroyParticle(self.particle2, true)
	else
		self:GetCaster():EmitSound("DOTA_Item.MeteorHammer.Cast")

		local mana_left = self:GetCaster():GetMana()
			if not self:IsNull() then
				self.particle3	= ParticleManager:CreateParticle("particles/custom/items/spellbook/destruction/spellbook_destruction_impact.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
				ParticleManager:SetParticleControl(self.particle3, 0, self:GetCursorPosition() + Vector(0, 0, 0))
				ParticleManager:SetParticleControl(self.particle3, 1, self:GetCursorPosition())
				ParticleManager:SetParticleControl(self.particle3, 2, Vector(self.ImpactRadius * 4, 1, 1))
				ParticleManager:ReleaseParticleIndex(self.particle3)
			
				GridNav:DestroyTreesAroundPoint(self:GetCursorPosition(), self.ImpactRadius * 4, true)

				EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "DOTA_Item.MeteorHammer.Impact", self:GetCaster())

				local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self.ImpactRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				for _, enemy in pairs(enemies) do
					enemy:EmitSound("DOTA_Item.MeteorHammer.Damage")
					enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration") * (1 - enemy:GetStatusResistance())})
					enemy:AddNewModifier(self:GetCaster(), self, "modifier_spellbook_destruction_burn_boss", {duration = self:GetSpecialValueFor("burn_duration")})

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
		self:GetCaster():SetMana(0)
	end
	ParticleManager:ReleaseParticleIndex(self.particle)
	ParticleManager:ReleaseParticleIndex(self.particle2)
end ]]

--new test
function cosmos_book:OnSpellStart()
	self.ImpactRadius = self:GetSpecialValueFor("impact_radius") + (self:GetCaster():GetMaxMana()*0.05)
	self.targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_spellbook_destruction_mana_drain_boss", {duration = 7})
	self:GetCaster():StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
	if _G.cosmos_state and _G.cosmos_state == 1 then
		self:OnChannelFinish(true)
	end	
end

function cosmos_book:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self
	if not caster then return end
	if not caster:IsAlive() then return end 
	self.cursor_position = caster:GetAbsOrigin()
	caster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
	if caster:HasModifier("modifier_spellbook_destruction_mana_drain_boss") then
		caster:RemoveModifierByName("modifier_spellbook_destruction_mana_drain_boss")
	end

	-- Random delay for the animation to start
	local delay = RandomFloat(2, 7)

	-- Start a timer for the animation
	Timers:CreateTimer(delay, function()
		if self:IsNull() then return end
		if not caster then return end
		if not caster:IsAlive() then return end 
		self.cursor_position = caster:GetAbsOrigin()
		caster:EmitSound("DOTA_Item.MeteorHammer.Channel")
		AddFOWViewer(caster:GetTeam(), self.cursor_position, self.ImpactRadius, 12, false)

		self.particle = ParticleManager:CreateParticle("particles/custom/items/spellbook/destruction/spellbook_destruction_cast_aoe.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(self.particle, 0, self.cursor_position)
		ParticleManager:SetParticleControl(self.particle, 1, Vector(self.ImpactRadius, 1, 1))
		self.particle2 = ParticleManager:CreateParticle("particles/custom/items/spellbook/destruction/spellbook_destruction_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)


		-- Start a timer for the actual spell effect after full channel time
		local r_time = RandomFloat(7, 10)
		Timers:CreateTimer(r_time, function()
			if self:IsNull() then 
				ParticleManager:ReleaseParticleIndex(self.particle)
				ParticleManager:ReleaseParticleIndex(self.particle2)
				return
			end
			if not caster then
				ParticleManager:ReleaseParticleIndex(self.particle)
				ParticleManager:ReleaseParticleIndex(self.particle2)	
				return
			end
			if not caster:IsAlive() then
				ParticleManager:ReleaseParticleIndex(self.particle)
				ParticleManager:ReleaseParticleIndex(self.particle2)
				return
			end 
			caster:EmitSound("DOTA_Item.MeteorHammer.Cast")
			caster:EmitSound("DOTA_Item.MeteorHammer.Cast")

			local mana_left = caster:GetMana()

			if not self:IsNull() then
				self.particle3	= ParticleManager:CreateParticle("particles/custom/items/spellbook/destruction/spellbook_destruction_impact.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(self.particle3, 0, self.cursor_position + Vector(0, 0, 0))
				ParticleManager:SetParticleControl(self.particle3, 1, self.cursor_position)
				ParticleManager:SetParticleControl(self.particle3, 2, Vector(self.ImpactRadius * 4, 1, 1))
				ParticleManager:ReleaseParticleIndex(self.particle3)
			
				GridNav:DestroyTreesAroundPoint(self.cursor_position, self.ImpactRadius * 4, true)

				EmitSoundOnLocationWithCaster(self.cursor_position, "DOTA_Item.MeteorHammer.Impact", caster)
				EmitSoundOnLocationWithCaster(self.cursor_position, "DOTA_Item.MeteorHammer.Impact", caster)
				EmitSoundOnLocationWithCaster(self.cursor_position, "PudgeWarsClassic.echo_slam", caster)
				EmitSoundOnLocationWithCaster(self.cursor_position, "PudgeWarsClassic.echo_slam", caster)
				EmitSoundOnLocationWithCaster(self.cursor_position, "Hero_Phoenix.SuperNova.Explode", caster)
				EmitSoundOnLocationWithCaster(self.cursor_position, "Hero_Phoenix.SuperNova.Explode", caster)
				ScreenShake( self.cursor_position, 600, 600, 2, 9999, 0, true)
				local caster_missing_hp = caster:GetHealthDeficit()
				local extra_dmg = math.ceil(self:GetSpecialValueFor("missing_hp") * caster_missing_hp * 0.01)
				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), self.cursor_position, nil, self.ImpactRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

				for _, enemy in pairs(enemies) do
					if enemy and enemy:IsAlive() and not enemy:HasModifier("modifier_cosmos_space_mist_debuff") then
						enemy:EmitSound("DOTA_Item.MeteorHammer.Damage")
						enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration") * (1 - enemy:GetStatusResistance())})
						enemy:AddNewModifier(caster, self, "modifier_spellbook_destruction_burn_boss", {duration = self:GetSpecialValueFor("burn_duration")})

						local impactDamage = (caster:GetMaxMana() * 5) + (mana_left * 8) + (extra_dmg * 3)
						local damageTable = {
							victim = enemy,
							damage = impactDamage,
							damage_type = DAMAGE_TYPE_MAGICAL,
							damage_flags = DOTA_DAMAGE_FLAG_NONE,
							attacker = caster,
							ability = self
						}
						ApplyDamage(damageTable)
					end
				end
			end

			ParticleManager:ReleaseParticleIndex(self.particle)
			ParticleManager:ReleaseParticleIndex(self.particle2)
		end)
	end)
end

----


------------------------------------------
-- Spellbook: Destruction Burn Modifier --
------------------------------------------
function modifier_spellbook_destruction_burn_boss:GetEffectName() return "particles/custom/items/spellbook/destruction/spellbook_destruction_debuff.vpcf" end
function modifier_spellbook_destruction_burn_boss:IgnoreTenacity() return true end
function modifier_spellbook_destruction_burn_boss:IsDebuff() return true end
function modifier_spellbook_destruction_burn_boss:IsHidden() return false end
function modifier_spellbook_destruction_burn_boss:IsPurgable() return false end
function modifier_spellbook_destruction_burn_boss:IsPurgeException() return true end
function modifier_spellbook_destruction_burn_boss:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spellbook_destruction_burn_boss:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local parent = self:GetParent()
		if parent and parent:IsAlive() and self:GetCaster() then
			local caster = self:GetCaster()
			local parent_missing_hp = caster:GetHealthDeficit()
			local extra_dmg = math.ceil(self:GetSpecialValueFor("missing_hp") * parent_missing_hp * 0.0025)  
			self.burn_dps = self:GetAbility():GetSpecialValueFor("burn_dps") + extra_dmg
			self.damageTable = {
				victim = parent,
				damage = self.burn_dps,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
				attacker = caster,
				ability = self:GetAbility()
				}
			self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("burn_interval"))
		end
	end
end
function modifier_spellbook_destruction_burn_boss:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility() then self:Destroy() end
	if not self:GetParent() then self:Destroy() end
	if not self:GetCaster() and not self:GetCaster():IsAlive() then self:Destroy() end
	ApplyDamage(self.damageTable)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.burn_dps, nil)
end
function modifier_spellbook_destruction_burn_boss:CheckState()
	local state = {}
	-- Level 2 and above applies Break
	state = {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
	return state
end
function modifier_spellbook_destruction_burn_boss:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_spellbook_destruction_burn_boss:GetModifierSpellAmplify_Percentage()
	-- Level 3 and above reduces spell amp
	
	return self:GetAbility():GetSpecialValueFor("spell_reduction_pct") * (-1)
end

-------------------------------------
-- Spellbook: Destruction Modifier --
-------------------------------------
function modifier_spellbook_destruction_boss:IsHidden() return true end
function modifier_spellbook_destruction_boss:IsPurgable() return false end
function modifier_spellbook_destruction_boss:RemoveOnDeath() return false end
function modifier_spellbook_destruction_boss:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spellbook_destruction_boss:OnCreated()
end


------------------------------------------------
-- Spellbook: Destruction Drain Caster's Mana --
------------------------------------------------
function modifier_spellbook_destruction_mana_drain_boss:IsHidden() return true end
function modifier_spellbook_destruction_mana_drain_boss:IsPurgable() return false end
function modifier_spellbook_destruction_mana_drain_boss:RemoveOnDeath() return false end
function modifier_spellbook_destruction_mana_drain_boss:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spellbook_destruction_mana_drain_boss:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.mana_drain_interval = self:GetAbility():GetSpecialValueFor("mana_drain_interval")
		self.mana_drain_sec = self:GetCaster():GetMaxMana() * (self:GetAbility():GetSpecialValueFor("mana_drain_pct_sec") / 100)
		self:StartIntervalThink(self.mana_drain_interval)
	end
end
function modifier_spellbook_destruction_mana_drain_boss:OnIntervalThink()
	if IsServer() then
		if self:GetCaster() and self:GetAbility() then
			local mana_drain_per_interval = self.mana_drain_sec * self.mana_drain_interval
			local mana_regen_red = self:GetCaster():GetManaRegen() * self.mana_drain_interval
			self:GetCaster():Script_ReduceMana(mana_drain_per_interval + (mana_regen_red * 0.90), self:GetAbility())
		end
	end
end

