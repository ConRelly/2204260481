----------------------------
-- Spellbook: Destruction --
----------------------------
LinkLuaModifier("modifier_spellbook_destruction", "items/book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellbook_destruction_burn", "items/book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellbook_destruction_mana_drain", "items/book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellbook_destruction_burn_stacks", "items/book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellbook_destruction_pierce_evasion", "items/book.lua", LUA_MODIFIER_MOTION_NONE)

item_spellbook_destruction = class({})
modifier_spellbook_destruction = class({})
modifier_spellbook_destruction_burn = class({})
modifier_spellbook_destruction_mana_drain = class({})
modifier_spellbook_destruction_pierce_evasion = class({})


-- make so the cooldown does not go below 30 seconds
function item_spellbook_destruction:GetCooldown(level)
    local baseCooldown = self.BaseClass.GetCooldown(self, level)
    local caster = self:GetCaster()
    local minCooldown = 30 -- The minimum cooldown you want to set
	local adjustedCooldown = baseCooldown
    if caster and caster:HasModifier("modifier_dzzl_good_juju") then
		--a separate cdr for items skill
		local cdAfterReduction = (baseCooldown * caster:GetCooldownReduction()) * 0.58
		if cdAfterReduction < minCooldown then 
			adjustedCooldown = minCooldown / caster:GetCooldownReduction() / 0.58
		end		
		return adjustedCooldown  
    end
    local cdAfterReduction = baseCooldown * caster:GetCooldownReduction()
    if cdAfterReduction < minCooldown then 
        adjustedCooldown = minCooldown / caster:GetCooldownReduction() 
    end
    return adjustedCooldown 
end


function item_spellbook_destruction:GetIntrinsicModifierName() return "modifier_spellbook_destruction" end
function modifier_spellbook_destruction:IsHidden() return true end
function modifier_spellbook_destruction:IsPurgable() return false end
function modifier_spellbook_destruction:IsDebuff() return false end
function item_spellbook_destruction:GetAOERadius()
	return self:GetSpecialValueFor("impact_radius") + (self:GetCaster():GetMaxMana()/30)
end
--modif pierce evasion--
function modifier_spellbook_destruction_pierce_evasion:IsHidden() return true end
function modifier_spellbook_destruction_pierce_evasion:IsPurgable() return false end
function modifier_spellbook_destruction_pierce_evasion:IsDebuff() return false end


function item_spellbook_destruction:Explosion_book(attacker, target, ability, dmg_dealt)
	if not IsServer() then return end
	local attackerPlayerId = attacker:GetPlayerOwnerID()
	local victim = target
	local victim_name = victim:GetUnitName()
	local damageTable = {
		entindex_victim_const = victim:entindex(),
		damage = dmg_dealt,
		damagetype_const = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		entindex_attacker_const = attacker:entindex(),
		entindex_inflictor_const = ability:entindex()
	}
	if attackerPlayerId and victim and victim:IsAlive() and victim:GetDayTimeVisionRange() ~= 1337 and attackerPlayerId >= 0 and attacker:IsOpposingTeam(victim:GetTeam()) then
		local victim_hp = victim:GetHealth() --get victim curent healt so we make sure we don't record overkill dps
		if dmg_dealt > victim_hp and victim_name ~= "npc_dota_dummy_misha" then --exception
			dmg_dealt = victim_hp
		end	
		player_data_modify_value(attackerPlayerId, "bossDamage", dmg_dealt)
		gHeroDamage:ModifyValue(attackerPlayerId, "bossDamage", dmg_dealt)
		gHeroDamage:OnDamageDealt(attackerPlayerId, damageTable, dmg_dealt, attacker, victim )
		AOHGameMode._puredamage[attackerPlayerId] = AOHGameMode._puredamage[attackerPlayerId] + dmg_dealt
		local sethp_victim = math.ceil( victim:GetHealth() - dmg_dealt)
		victim:ModifyHealth(sethp_victim, ability, false, DOTA_DAMAGE_FLAG_HPLOSS)
	end
end



function item_spellbook_destruction:OnSpellStart()
	self.ImpactRadius = self:GetSpecialValueFor("impact_radius") + (self:GetCaster():GetMaxMana()*0.03)
	self.ImpactRadius_particle = (self.ImpactRadius / 20) + 300
	if self:GetCaster():HasModifier("modifier_arc_warden_tempest_double") then return end
	-- Level 4 (and above?) pierces magic immunity
	self.targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	self.cursor_position = self:GetCursorPosition()
	if not IsServer() then return end
	self:GetCaster():EmitSound("DOTA_Item.MeteorHammer.Channel")
	AddFOWViewer(self:GetCaster():GetTeam(), self.cursor_position, self.ImpactRadius, 8.0, false)

	self.particle = ParticleManager:CreateParticleForTeam("particles/custom/items/spellbook/destruction/spellbook_destruction_cast_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeam())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(self.ImpactRadius_particle, 1, 1))
	self.particle2 = ParticleManager:CreateParticle("particles/custom/items/spellbook/destruction/spellbook_destruction_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_spellbook_destruction_mana_drain", {})

	self:GetCaster():StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
end
function item_spellbook_destruction:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local modif_mana_burn = caster:FindModifierByName("modifier_spellbook_destruction_mana_drain")
	if modif_mana_burn then
		modif_mana_burn:Destroy()
	end
	caster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

	if bInterrupted then
		caster:StopSound("DOTA_Item.MeteorHammer.Channel")
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:DestroyParticle(self.particle2, true)
		self:EndCooldown()
		self:StartCooldown(5)	
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
			
				GridNav:DestroyTreesAroundPoint(self.cursor_position, self.ImpactRadius * 2, true)
				local amplitude = math.floor(self.ImpactRadius / 5)
				local fregventy = 1
				if amplitude < 100 then
					amplitude = 100
				elseif amplitude > 500 then
					amplitude = 500	
					fregventy = 2
				elseif amplitude > 300 then
					fregventy = 2					
				end
				EmitSoundOnLocationWithCaster(self.cursor_position, "DOTA_Item.MeteorHammer.Impact", self:GetCaster())
				EmitSoundOnLocationWithCaster(self.cursor_position, "PudgeWarsClassic.echo_slam", self:GetCaster())
				EmitSoundOnLocationWithCaster(self.cursor_position, "PudgeWarsClassic.echo_slam", self:GetCaster())
				EmitSoundOnLocationWithCaster(self.cursor_position, "Hero_Phoenix.SuperNova.Explode", self:GetCaster())
				EmitSoundOnLocationWithCaster(self.cursor_position, "Hero_Phoenix.SuperNova.Explode", self:GetCaster())
				ScreenShake( self.cursor_position, 600, amplitude, fregventy, 9999, 0, true)
				local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self.ImpactRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				for _, enemy in pairs(enemies) do
					if enemy and enemy:IsAlive() then
						enemy:EmitSound("DOTA_Item.MeteorHammer.Damage")
						enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration") * (1 - enemy:GetStatusResistance())})
						enemy:AddNewModifier(self:GetCaster(), self, "modifier_spellbook_destruction_burn", {duration = self:GetSpecialValueFor("burn_duration")})

						local impactDamage = (self:GetCaster():GetMaxMana() * 5) + (mana_left * 10)
						local damageTable = {
							victim = enemy,
							damage = impactDamage,
							damage_type = DAMAGE_TYPE_PURE,
							damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
							attacker = self:GetCaster(),
							ability = self
						}
						
						local amp = self:GetCaster():GetSpellAmplification(false) * 0.01 
						if amp > 0.17 then
							amp = 0.17
						end
						local hp_removal = math.ceil( enemy:GetHealth() * amp )
						--apply modif pierce evasion on enemy
						enemy:AddNewModifier(self:GetCaster(), self, "modifier_spellbook_destruction_pierce_evasion", {duration = 0.03})
						ApplyDamage(damageTable)
						--remode pierce evasion on enemy
						if enemy and enemy:IsAlive() and enemy:HasModifier("modifier_spellbook_destruction_pierce_evasion") then
							enemy:RemoveModifierByName("modifier_spellbook_destruction_pierce_evasion")
							--reduce enemy current hp base on caster's spell amp (max 20%)
							self:Explosion_book(self:GetCaster(), enemy, self, hp_removal)
						end
						
					end
				end
			end
--		end)
		self:GetCaster():SetMana(0)
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_elder_titan_echo_stomp", {duration = self:GetSpecialValueFor("mana_drain_sleep")})
	end
	ParticleManager:ReleaseParticleIndex(self.particle)
	ParticleManager:ReleaseParticleIndex(self.particle2)
end

----------------------------------------
-- Spellbook: Destruction Burn Stacks Modifier --

modifier_spellbook_destruction_burn_stacks = class({})
function modifier_spellbook_destruction_burn_stacks:IsHidden() return false end
function modifier_spellbook_destruction_burn_stacks:IsPurgable() return false end
function modifier_spellbook_destruction_burn_stacks:RemoveOnDeath() return false end
function modifier_spellbook_destruction_burn_stacks:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOOLTIP
	}
	return funcs
end
function modifier_spellbook_destruction_burn_stacks:OnTooltip()
	if self:GetAbility() then
		return self:GetStackCount() * self:GetAbility():GetCurrentCharges()
	end
end

------------------------------------------
-- Spellbook: Destruction Burn Modifier --
------------------------------------------
function modifier_spellbook_destruction_burn:GetEffectName() return "particles/custom/items/spellbook/destruction/spellbook_destruction_debuff.vpcf" end
function modifier_spellbook_destruction_burn:IgnoreTenacity() return true end
function modifier_spellbook_destruction_burn:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spellbook_destruction_burn:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		if not caster:HasModifier("modifier_spellbook_destruction_burn_stacks") then
			caster:AddNewModifier(caster, ability, "modifier_spellbook_destruction_burn_stacks", {})
			local modif = caster:FindModifierByName("modifier_spellbook_destruction_burn_stacks")
			if modif then
				modif:SetStackCount(10)
			end
		end
		self.burn_dps = ability:GetCurrentCharges() * caster:FindModifierByName("modifier_spellbook_destruction_burn_stacks"):GetStackCount() or 1	
		self.damageTable = {
			victim = self:GetParent(),
			damage = self.burn_dps,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			attacker = self:GetCaster(),
			ability = ability
			}
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("burn_interval"))
	end
end
function modifier_spellbook_destruction_burn:OnIntervalThink()
	if not IsServer() then return end
	local ability = self:GetAbility()
	if not ability then self:Destroy() return end
	local caster = self:GetCaster()
	local modif = caster:FindModifierByName("modifier_spellbook_destruction_burn_stacks")
	if not modif then return end
	local sec_charges = modif:GetStackCount()
	
	self.burn_dps = ability:GetCurrentCharges() * sec_charges 
	self.damageTable.damage = self.burn_dps
	ApplyDamage(self.damageTable)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.burn_dps, nil)
	modif:SetStackCount(sec_charges + ability:GetSpecialValueFor("sec_charges"))
end
function modifier_spellbook_destruction_burn:CheckState()
	local state = {}
	-- Level 2 and above applies Break
	state = {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
	return state
end
function modifier_spellbook_destruction_burn:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_spellbook_destruction_burn:GetModifierSpellAmplify_Percentage()
	-- Level 3 and above reduces spell amp
	
	return self:GetAbility():GetSpecialValueFor("spell_reduction_pct") * (-1)
end

-------------------------------------
-- Spellbook: Destruction Modifier --
-------------------------------------
function modifier_spellbook_destruction:IsHidden() return true end
function modifier_spellbook_destruction:IsPurgable() return false end
function modifier_spellbook_destruction:RemoveOnDeath() return false end
function modifier_spellbook_destruction:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_spellbook_destruction:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
	end
end
function modifier_spellbook_destruction:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK}
end

function modifier_spellbook_destruction:GetModifierBonusStats_Strength()
	local ability = self:GetAbility()
	if ability then
		local stacks = ability:GetCurrentCharges()
		return stacks * ability:GetSpecialValueFor("bonus_strength")
	end
	return 0
end 
function modifier_spellbook_destruction:GetModifierBonusStats_Intellect()
	local ability = self:GetAbility()
	if ability then
		local stacks = ability:GetCurrentCharges()
		return stacks * ability:GetSpecialValueFor("bonus_intellect")
	end
	return 0
end
function modifier_spellbook_destruction:GetModifierConstantHealthRegen()
	local ability = self:GetAbility()
	if ability then
		local stacks = ability:GetCurrentCharges()
		return stacks * ability:GetSpecialValueFor("bonus_health_regen")
	end
	return 0
end
function modifier_spellbook_destruction:GetModifierConstantManaRegen()
	local ability = self:GetAbility()
	if ability then
		local stacks = ability:GetCurrentCharges()
		return stacks * ability:GetSpecialValueFor("bonus_mana_regen")	
	end
	return 0
end
function modifier_spellbook_destruction:GetModifierSpellAmplify_Percentage()
	local ability = self:GetAbility()
	if ability then
		local stacks = ability:GetCurrentCharges()
		return stacks * ability:GetSpecialValueFor("bonus_spell_amplify")
	end
	return 0
end
------------------------------------------------
-- Spellbook: Destruction Drain Caster's Mana --
------------------------------------------------
function modifier_spellbook_destruction_mana_drain:IsHidden() return false end
function modifier_spellbook_destruction_mana_drain:IsPurgable() return false end
function modifier_spellbook_destruction_mana_drain:RemoveOnDeath() return false end
function modifier_spellbook_destruction_mana_drain:GetAttributes() return MODIFIER_ATTRIBUTE_NONE end
function modifier_spellbook_destruction_mana_drain:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.mana_drain_interval = self:GetAbility():GetSpecialValueFor("mana_drain_interval")
		self.mana_drain_sec = self:GetCaster():GetMaxMana() * (self:GetAbility():GetSpecialValueFor("mana_drain_pct_sec") / 100)
		self:StartIntervalThink(self.mana_drain_interval)
	end
end
function modifier_spellbook_destruction_mana_drain:OnIntervalThink()
	if IsServer() then
		if self:GetCaster() and self:GetAbility() then
			if self:GetCaster():GetManaPercent() < 1 then
				if self.particle then
					ParticleManager:DestroyParticle(self.particle,true)
					ParticleManager:ReleaseParticleIndex(self.particle)
					self.particle = nil				
				end
				self:SetStackCount(0)
				self:GetCaster():Stop()
				self:Destroy()
				return
			end
			local mana_drain_per_interval = self.mana_drain_sec * self.mana_drain_interval
			local mana_regen_red = self:GetCaster():GetManaRegen() * self.mana_drain_interval
			self:GetCaster():Script_ReduceMana(mana_drain_per_interval + (mana_regen_red * 0.90), self:GetAbility())

			-- Particle channeling
			local interval = self.mana_drain_interval
			local parent = self:GetParent()
			local parent_location = parent:GetOrigin()

			
			if not self.particle then
				self.particle = ParticleManager:CreateParticle("particles/econ/generic/generic_progress_meter/generic_progress_circle.vpcf",0,parent)
				-- ParticleManager:SetParticleControl( self.particle,1,Vector(100,0,0) )
				ParticleManager:SetParticleControl( self.particle,0,parent_location + Vector(0,0,450) )
			end
			self:IncrementStackCount()
			--ParticleManager:SetParticleControl( self.particle,1, Vector(100,self:GetStackCount()/50,0 ) )
			ParticleManager:SetParticleControl( self.particle,1, Vector(100,self:GetStackCount() * interval / 5,0 ) )
			AddFOWViewer(DOTA_TEAM_GOODGUYS, parent_location, 600, 6.0, false)
			if (self:GetStackCount() * interval)>= 5 then -- need to match stacks with 5 sec
				if self.particle then
					ParticleManager:DestroyParticle(self.particle,true)
					ParticleManager:ReleaseParticleIndex(self.particle)
					self.particle = nil
					self:SetStackCount(0)
				end
			end
		end
	end
end
function modifier_spellbook_destruction_mana_drain:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_spellbook_destruction_mana_drain:GetEffectName() return "particles/custom/items/pipe_of_dezun/pipe_of_dezun_magic_immune_avatar.vpcf" end
function modifier_spellbook_destruction_mana_drain:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return self:GetParent():GetManaPercent() * (-1) end
end
function modifier_spellbook_destruction_mana_drain:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end
function modifier_spellbook_destruction_mana_drain:OnDestroy()
	if IsServer()then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle,true)
			ParticleManager:ReleaseParticleIndex(self.particle)
			self.particle = nil
		end
	end
end	
