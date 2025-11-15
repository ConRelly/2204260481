LinkLuaModifier("modifier_gifted_weapon", "heroes/hero_master_of_weapons/gifted_weapon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gifted_weapon_slasher", "heroes/hero_master_of_weapons/gifted_weapon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gifted_weapon_remove_as_limit", "heroes/hero_master_of_weapons/gifted_weapon", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_gifted_weapon_no_damage", "heroes/hero_master_of_weapons/gifted_weapon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gifted_weapon_invul", "heroes/hero_master_of_weapons/gifted_weapon", LUA_MODIFIER_MOTION_NONE)

gifted_weapon = class({})
function gifted_weapon:ProcsMagicStick() return false end
--[[
function gifted_weapon:Spawn()
	if IsServer() then
		self:SetLevel(1)
	end
end
]]
function gifted_weapon:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_dzzl_good_juju") then
		return 9 / self:GetCaster():GetCooldownReduction()
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end
function gifted_weapon:GetIntrinsicModifierName() if self:IsTrained() then return "modifier_gifted_weapon" end end

function gifted_weapon:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:AddNewModifier(caster, self, "modifier_gifted_weapon_remove_as_limit", {})
	local additional_duration = math.floor(caster:GetDisplayAttackSpeed() / 1500)
--	print("Print DisplayAttackSpeed", caster:GetDisplayAttackSpeed())
--	print("Print additional_duration", additional_duration)
	local duration = self:GetSpecialValueFor("duration") + (additional_duration * 1.5)

	local previous_position = caster:GetAbsOrigin()
	
	caster:Purge(false, true, false, false, false)

	caster:AddNewModifier(caster, self, "modifier_gifted_weapon_remove_as_limit", {duration = duration})

	local modifier_handler = caster:AddNewModifier(caster, self, "modifier_gifted_weapon_slasher", {duration = duration})
	
	if modifier_handler then
		modifier_handler.original_caster = caster
	end

	FindClearSpaceForUnit(caster, target:GetAbsOrigin() + RandomVector(128), false)

	caster:EmitSound("Hero_Juggernaut.OmniSlash")

	caster:RemoveModifierByName("modifier_gifted_weapon_remove_as_limit")

	if target:TriggerSpellAbsorb(self) then return end

	Timers:CreateTimer(FrameTime(), function()
		if (not caster:IsNull()) then
			caster:PerformAttack(target, true, true, true, true, false, false, false)

			local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
			ParticleManager:SetParticleControl(trail_pfx, 1, caster:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(trail_pfx)
		end
	end)
end


-- Sword bonuses
modifier_gifted_weapon = class({})
function modifier_gifted_weapon:IsHidden() return self:GetStackCount() == 0 end
function modifier_gifted_weapon:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		Timers:CreateTimer(0.1, function()
			if self:GetCaster():FindItemInInventory("item_master_of_weapons_sword") then
				--self:GetCaster():RemoveItem(self:GetCaster():FindItemInInventory("item_master_of_weapons_sword"))
				self:GetCaster():TakeItem(self:GetCaster():FindItemInInventory("item_master_of_weapons_sword"))
			end
		end)
	end
end
function modifier_gifted_weapon:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
function modifier_gifted_weapon:GetModifierPreAttack_BonusDamage() return self:GetStackCount() * 50 end
function modifier_gifted_weapon:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_gifted_weapon:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_ms") end
end
function modifier_gifted_weapon:GetModifierAttackRangeBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_range") end
end
function modifier_gifted_weapon:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_as") end
end
function modifier_gifted_weapon:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
end
function modifier_gifted_weapon:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
end
function modifier_gifted_weapon:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") + (math.floor(self:GetStackCount() / 4) * 30) end
end
function modifier_gifted_weapon:GetModifierOverrideAbilitySpecial(params)
	if self:GetParent() == nil or params.ability == nil then return 0 end

	if self:GetParent():HasModifier("modifier_gifted_weapon_slasher") then
		if params.ability:GetAbilityName() == "item_fire_rapier" and params.ability_special_value == "proc_chance" then
			return 1
		end
	end

	return 0
end
function modifier_gifted_weapon:GetModifierOverrideAbilitySpecialValue(params)
	if self:GetParent():HasModifier("modifier_gifted_weapon_slasher") then
		if params.ability:GetAbilityName() == "item_fire_rapier" and params.ability_special_value == "proc_chance" then
			local nSpecialLevel = params.ability_special_level
			return 60--params.ability:GetLevelSpecialValueNoOverride("proc_chance", nSpecialLevel)
		end
	end

	return 0
end


modifier_gifted_weapon_slasher = modifier_gifted_weapon_slasher or class({})
function modifier_gifted_weapon_slasher:IsHidden() return false end
function modifier_gifted_weapon_slasher:IsPurgable() return false end
function modifier_gifted_weapon_slasher:IsDebuff() return false end
--function modifier_gifted_weapon_slasher:StatusEffectPriority() return 20 end
function modifier_gifted_weapon_slasher:GetStatusEffectName() return "particles/status_fx/status_effect_omnislash.vpcf" end
function modifier_gifted_weapon_slasher:OnCreated()
	self.last_enemy = nil
	if not self:GetAbility() then self:Destroy() return end
	if IsServer() then
		self.MaxHealth = self:GetParent():GetMaxHealth()
		if (not self:GetParent():IsNull()) then
			self.bounce_range = self:GetAbility():GetSpecialValueFor("bounce_range")
			self:BounceAndSlaughter(true)
			local AttacksNumber = 5
			local BaseInterval = 0.3
			local slash_rate = BaseInterval / AttacksNumber--self:GetCaster():GetSecondsPerAttack(false) / (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier"), 1))
			self:StartIntervalThink(slash_rate)
		end
	end
end

function modifier_gifted_weapon_slasher:OnDestroy()
	if IsServer() then
		self:GetParent():FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
		
		--self:GetParent():MoveToPositionAggressive(self:GetParent():GetAbsOrigin())

		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local image_team = self:GetParent():GetTeamNumber()
		local image_loc = self:GetParent():GetAbsOrigin()
		local damage = caster:GetAttackDamage()
		local radius = 2000
		local repeat_times = 1 + (2 * math.floor(self:GetParent():GetLevel() / 40))
		if self:GetParent():GetPrimaryAttribute() == 0 then
			if self:GetParent():GetStrength() >= 7500 then
				DMGflags = DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
			else
				DMGflags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
			end
		end
		
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
						
						if enemy:GetUnitLabel() == "randomskill" then
							duration = 5
						else
							duration = 8
						end
						
						enemy:AddNewModifier(caster, ability, "modifier_silence", {duration = duration})
						
						if expl_bonus_dmg < 500 then
							local stacks = caster:FindModifierByName("modifier_gifted_weapon")
							stacks:SetStackCount(stacks:GetStackCount() + 1)
							expl_bonus_dmg = expl_bonus_dmg + 50
						end
					end
					if i == 1 or i == repeat_times then	--(i + 1 % 3 == 0)
						local burst = ParticleManager:CreateParticle("particles/items3_fx/blink_overwhelming_burst.vpcf", PATTACH_WORLDORIGIN, caster)
						ParticleManager:SetParticleControl(burst, 0, image_loc)
						ParticleManager:SetParticleControl(burst, 1, Vector(radius, 500, 500))
						ParticleManager:ReleaseParticleIndex(burst)
						EmitSoundOnLocationWithCaster(image_loc, "Blink_Layer.Overwhelming", caster)
					end
				end
			end)
		end
		caster:AddNewModifier(caster, ability, "modifier_gifted_weapon_no_damage", {duration = 4})
	end
end

function modifier_gifted_weapon_slasher:OnIntervalThink()
	if not self:GetAbility() then self:Destroy() return end
	self:BounceAndSlaughter()
	
	local AttacksNumber = 5
	local BaseInterval = 0.3
	local slash_rate = BaseInterval / AttacksNumber--self:GetCaster():GetSecondsPerAttack(false) / (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier"), 1))

	self:StartIntervalThink(slash_rate)
end

function modifier_gifted_weapon_slasher:BounceAndSlaughter(first_slash)
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
			break
		end
	else
		self:Destroy()
	end
end

function modifier_gifted_weapon_slasher:DeclareFunctions()
	if not IsServer() then return end
	if self:GetParent():GetUnitName() == "npc_dota_hero_juggernaut" then
		return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
	end
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_gifted_weapon_slasher:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_4 end
function modifier_gifted_weapon_slasher:GetModifierPreAttack_BonusDamage() return self.MaxHealth end
function modifier_gifted_weapon_slasher:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ROOTED] = true
	}
end



modifier_gifted_weapon_remove_as_limit = class({})
function modifier_gifted_weapon_remove_as_limit:IsHidden() return true end
function modifier_gifted_weapon_remove_as_limit:IsPurgable() return false end
function modifier_gifted_weapon_remove_as_limit:RemoveOnDeath() return false end
function modifier_gifted_weapon_remove_as_limit:DeclareFunctions()
	return {MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT}
end
function modifier_gifted_weapon_remove_as_limit:GetModifierAttackSpeed_Limit() return 1 end



modifier_gifted_weapon_no_damage = class({})
function modifier_gifted_weapon_no_damage:GetTexture() return "modifier_invulnerable" end
function modifier_gifted_weapon_no_damage:IsPurgable() return false end
function modifier_gifted_weapon_no_damage:RemoveOnDeath() return false end
function modifier_gifted_weapon_no_damage:OnDestroy()
	if not IsServer() then return end
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_gifted_weapon_invul", {duration = 2})
end
function modifier_gifted_weapon_no_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE}
end
function modifier_gifted_weapon_no_damage:GetAbsoluteNoDamageMagical(params) return 1 end
function modifier_gifted_weapon_no_damage:GetAbsoluteNoDamagePhysical(params) return 1 end
function modifier_gifted_weapon_no_damage:GetAbsoluteNoDamagePure(params) return 1 end



modifier_gifted_weapon_invul = class({})
function modifier_gifted_weapon_invul:GetTexture() return "modifier_invulnerable" end
function modifier_gifted_weapon_invul:IsPurgable() return false end
function modifier_gifted_weapon_invul:RemoveOnDeath() return false end
function modifier_gifted_weapon_invul:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true}
end
