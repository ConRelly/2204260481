LinkLuaModifier("modifier_zanto_gari", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_debuff", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_crit", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_invis", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_armor_pierce", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_grace_time", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_grace_time_shift", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_bonus_dmg", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanto_gari_ss_echo_stacks", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE) -- Renamed
LinkLuaModifier("modifier_zanto_gari_ss_slash_internal_cd", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
----------------
-- Zanto Gari --
----------------

-- Note: Using global HasSuperScepter(caster) defined elsewhere, which checks for modifier_super_scepter.

zanto_gari = zanto_gari or class({})
function zanto_gari:GetIntrinsicModifierName() return "modifier_zanto_gari" end
if modifier_zanto_gari == nil then modifier_zanto_gari = class({}) end
function modifier_zanto_gari:IsHidden() return true end
function modifier_zanto_gari:IsPurgable() return false end
function modifier_zanto_gari:RemoveOnDeath() return false end
function modifier_zanto_gari:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_zanto_gari:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() return end
		self:StartIntervalThink(FrameTime())
--		local ability = self:GetCaster():FindAbilityByName("zanto_gari")
--		ability:SetCurrentAbilityCharges(10)
	end
end
function modifier_zanto_gari:OnIntervalThink()
	if IsServer() then
		local as = GameRules:GetGameModeEntity():GetMaximumAttackSpeed()
		self:SetStackCount(as)
	end
end
function zanto_gari:GetManaCost(level)
	if self:GetCaster():HasScepter() then
		return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_cost_scepter") / 100
	end
	return self.BaseClass.GetManaCost(self, level)
end
--[[
function zanto_gari:GetCooldown(level)
	if self:GetCaster():HasScepter() then
		local cooldown = self.BaseClass.GetCooldown(self, level) - 5
		return cooldown
	end
	return self.BaseClass.GetCooldown(self, level)
end
]]
function zanto_gari:GetCastRange(location, target)
	return self:GetSpecialValueFor("max_travel_distance")
end

function zanto_gari:GetBehavior()
	local behavior = self.BaseClass.GetBehavior(self)
	if self:GetCaster():HasScepter() then
		behavior = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
	return behavior
end

-- Reusable function containing the core slash logic
function ExecuteZantoGariSlash(caster, ability, start_position, target_position, cast_distance, is_extra_slash, original_target, caster_original_position) -- Added caster_original_position
	local bHeroHit = false
	local self_target = false
	local slash_radius = ability:GetSpecialValueFor("radius")
	local final_position = target_position

	-- Determine target flags
	local target_flag = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if caster:HasScepter() and caster:HasShard() and ability:GetLevel() == 7 then
		target_flag = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	-- Handle self-cast/short distance case (only for initial cast)
	if not is_extra_slash and cast_distance <= 50 and caster:HasScepter() then
		slash_radius = ability:GetSpecialValueFor("max_travel_distance") / 2
		self_target = true
	end

	-- Caster should already be at start_position due to OnSpellStart or the teleport in PerformExtraZantoSlash.
	-- Initial facing might be set here if needed, or handled per-attack

	-- Particles and Sound for the movement/slash initiation
	if not is_extra_slash then caster:EmitSound("Hero_VoidSpirit.AstralStep.Start") end -- Only initial cast makes start sound
	if self_target then
		local particle = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_around.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 2, Vector(slash_radius, slash_radius, slash_radius))
		ParticleManager:ReleaseParticleIndex(particle)
	else
		local step_particle = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(step_particle, 0, start_position)
		ParticleManager:SetParticleControl(step_particle, 1, final_position)
		ParticleManager:ReleaseParticleIndex(step_particle)
	end

	-- Find units and apply effects
	for _, enemy in pairs(FindUnitsInLine(caster:GetTeamNumber(), start_position, final_position, nil, slash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, target_flag)) do
		local impact_particle = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:SetParticleControlEnt(impact_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(impact_particle)

		-- Face the specific enemy being attacked, if they are not too close to the start point
		local face_dir = enemy:GetAbsOrigin() - start_position
		if face_dir:Length2D() > 1.0 then -- Check if direction is valid/significant
			caster:SetForwardVector(face_dir:Normalized())
		end

		-- Perform the attack (caster is still logically at start_position for this)
		caster:PerformAttack(enemy, false, true, true, false, false, false, is_extra_slash) -- Last param might differentiate attack types if needed

		-- Apply Debuff and other modifiers
		local attack_speed_multi = ability:GetSpecialValueFor("attack_speed_multi")
		local shard_as = ability:GetSpecialValueFor("shard_as")
		if caster:HasShard() then
			attack_speed_multi = ability:GetSpecialValueFor("attack_speed_multi") + (shard_as / 100)
		end
		local grace_time_as = (1 / caster:GetAttackSpeed(false)) / attack_speed_multi
		local grace_time_duration = GameRules:GetGameModeEntity():GetMaximumAttackSpeed() / 10
		local duration = ability:GetSpecialValueFor("pop_damage_delay")
		local shift_duration = duration * 0.85

		caster:AddNewModifier(caster, ability, "modifier_zanto_gari_grace_time_shift", {duration = shift_duration})
		if not caster:HasModifier("modifier_item_echo_wand") and HasSuperScepter(caster) then
			-- Apply bonus damage buff only on initial cast, not echoes? Or always? Let's apply always for now.
			caster:AddNewModifier(caster, ability, "modifier_zanto_gari_bonus_dmg", {duration = grace_time_duration})
		end
		enemy:AddNewModifier(caster, ability, "modifier_zanto_gari_debuff", {
			duration = duration,
			grace_time_as = grace_time_as,
			grace_time_duration = grace_time_duration,
			-- Determine the correct distance to store in the debuff for future extra slashes
			actual_distance = (function()
				if self_target then
					-- Use half max travel distance for self-cast AoE hits
					return ability:GetSpecialValueFor("max_travel_distance") / 2
				elseif not is_extra_slash and caster_original_position then
					-- Manual slash: Use distance from original caster pos to this specific enemy
					return (enemy:GetAbsOrigin() - caster_original_position):Length2D()
				else
					-- Extra slash or fallback: Use the distance passed down (originated from manual slash)
					return cast_distance
				end
			end)()
		})

		if not bHeroHit then bHeroHit = true end
	end

	-- Move caster to final position after hitting all units
	FindClearSpaceForUnit(caster, final_position, false)

	-- End sounds
	if not is_extra_slash then caster:EmitSound("Hero_VoidSpirit.AstralStep.End") end
	if bHeroHit then caster:EmitSound("Zanto_Gari.Swift") end -- Swift sound on hit

	-- Projectile Dodge (only on initial cast?)
	if not is_extra_slash and caster:HasScepter() then
		ProjectileManager:ProjectileDodge(caster)
	end

	return bHeroHit -- Return if any hero was hit
end


function zanto_gari:OnSpellStart(recastVector, warpVector, Interrupted)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self

		-- Determine initial positions based on cast type
		local original_position = caster:GetAbsOrigin()
		local target_position
		local cast_distance
		local caster_original_position = caster:GetAbsOrigin() -- Store caster's starting position for manual cast

		if recastVector then -- Recast logic (if applicable)
			target_position = caster:GetAbsOrigin() + recastVector
			cast_distance = recastVector:Length2D()
		elseif warpVector then -- Warp logic (if applicable)
			target_position = GetGroundPosition(caster:GetAbsOrigin() + warpVector, nil)
			cast_distance = warpVector:Length2D()
			-- For warp, maybe execute from original position but target the warp end?
			-- Or just treat it like a normal cast to the warp point? Let's treat as normal cast for now.
			original_position = caster:GetAbsOrigin() -- Keep original start for warp
		else -- Normal point target cast
			if caster:GetCursorPosition() == original_position then -- Avoid zero vector
				caster:SetCursorPosition(original_position + caster:GetForwardVector())
			end
			local max_dist = ability:GetSpecialValueFor("max_travel_distance") + caster:GetCastRangeBonus()
			local min_dist = ability:GetSpecialValueFor("min_travel_distance")
			local target_point = caster:GetCursorPosition()
			cast_distance = math.max(math.min(((target_point - original_position) * Vector(1, 1, 0)):Length2D(), max_dist), min_dist)
			local raw_distance = ((target_point - original_position) * Vector(1, 1, 0)):Length2D()

			-- Check for self-cast BEFORE clamping to min_dist
			if caster:HasScepter() and raw_distance <= 50 then
				cast_distance = raw_distance -- Use the small raw distance to trigger self-cast logic
				target_position = original_position -- Target position is self for AoE
			else
				-- Not a self-cast, apply clamping
				cast_distance = math.max(math.min(raw_distance, max_dist), min_dist)
				target_position = original_position + ((target_point - original_position):Normalized() * cast_distance)
			end
		end

		-- Execute the core slash logic
		ExecuteZantoGariSlash(caster, ability, original_position, target_position, cast_distance, false, nil, caster_original_position) -- Pass original position for manual cast

		-- Note: Original OnSpellStart had some specific logic for self-cast particle and original_vector storage,
		-- which might need adjustment if those specific behaviors are crucial outside the core slash execution.
		-- The FindClearSpaceForUnit call is now inside ExecuteZantoGariSlash.
		-- The Invis application logic was commented out, remains so.
	end
end

-----------------------
-- Zanto Gari Debuff --
-----------------------
modifier_zanto_gari_debuff = modifier_zanto_gari_debuff or class({})
function modifier_zanto_gari_debuff:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_zanto_gari_debuff:OnCreated(keys)
	if IsServer() then if not self:GetAbility() then self:Destroy() return end
		self.grace_time_duration = keys.grace_time_duration
		self.grace_time_as = keys.grace_time_as
		self.actual_distance = keys.actual_distance or self:GetAbility():GetSpecialValueFor("max_travel_distance") -- Store distance, fallback to max range
		self:GetCaster():EmitSound("Zanto_Gari.Prepare")
	end
end
function modifier_zanto_gari_debuff:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		if not caster or not parent or not ability then return end -- Safety check
		--will make damage be the speciall value or caster lvl * 10000 (witch one is higher) if ability is lvl 7 or higher
		local damage = ability:GetSpecialValueFor("pop_damage")
		if ability:GetLevel() >= 7 then
			damage = math.max(ability:GetSpecialValueFor("pop_damage"), caster:GetLevel() * 10000)
		end
		if caster:HasTalent("special_bonus_zanto_gari_dmg") then
			damage = damage + (caster:GetAttackDamage() * caster:FindTalentValue("special_bonus_zanto_gari_dmg") / 100)
		end
		local prepare = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_slash_prepare.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:ReleaseParticleIndex(prepare)

		local dmg_type = DAMAGE_TYPE_MAGICAL
		local ability_level = ability:GetLevel()
		if ability_level >= 7 then
			dmg_type = DAMAGE_TYPE_PURE
		end
		ApplyDamage({
			victim 			= parent,
			damage 			= damage,
			damage_type		= dmg_type,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= caster,
			ability 		= ability
		})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, parent, damage, nil)

		-- Super Scepter Extra Slash Logic
		if HasSuperScepter(caster) then
			-- 1% chance to gain an echo stack
			if RollPseudoRandomPercentage(1, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, caster) then
				-- print("Gained Echo Stack!") -- Optional debug print
				local stack_modifier = caster:FindModifierByName("modifier_zanto_gari_ss_echo_stacks")
				if stack_modifier then
					stack_modifier:IncrementStackCount()
				else -- Apply if missing (should have been applied by bonus_dmg modifier, but safety check)
					caster:AddNewModifier(caster, ability, "modifier_zanto_gari_ss_echo_stacks", {}):SetStackCount(1)
				end
			end

			-- Check if autocast is ON for extra slash mode
			if ability:GetAutoCastState() then
				-- Check if internal cooldown modifier is active
				if not caster:HasModifier("modifier_zanto_gari_ss_slash_internal_cd") then
					local echo_stacks = 0
					local stack_modifier = caster:FindModifierByName("modifier_zanto_gari_ss_echo_stacks")
					if stack_modifier then echo_stacks = stack_modifier:GetStackCount() end

					-- Calculate proc chance
					local level_chance = math.min( caster:GetLevel() / 2, 60 )
					local stack_chance = echo_stacks
					local total_chance = math.min( level_chance + stack_chance, 80 )
					--for test fixed chance to 90%
					--total_chance = 90
					-- Roll for proc
					if RollPseudoRandomPercentage(total_chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, caster) then
						-- Apply internal cooldown (e.g., 0.1 seconds)
						caster:AddNewModifier(caster, ability, "modifier_zanto_gari_ss_slash_internal_cd", { duration = 0.1 })
						-- Perform the extra slash
						PerformExtraZantoSlash(caster, parent, self.actual_distance)
					end
				end
			end
		end

		-- Apply grace time slashes if target is still alive
		if parent:IsAlive() then
			parent:AddNewModifier(caster, ability, "modifier_zanto_gari_grace_time", {duration = self.grace_time_duration, grace_time_as = self.grace_time_as})
		end

		-- Original kill logic (charge restore, etc.)
		if not parent:IsAlive() and caster:HasScepter() and caster:HasShard() then
			local impact_kill = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_impact_kill.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControlEnt(impact_kill, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(impact_kill)

			local charges = ability:GetCurrentAbilityCharges()
			if charges < 2 then -- Assuming max charges is 2 or more based on original code
				ability:SetCurrentAbilityCharges(charges + 1)
			end
			ability:EndCooldown()
			caster:EmitSound("Zanto_Gari.Impact")
		else
			-- Normal impact particle if target didn't die or conditions not met
			local impact = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControlEnt(impact, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(impact)
		end
	end
end

-----------------------------
-- Zanto Gari Armor Pierce --
-----------------------------
modifier_zanto_gari_armor_pierce = modifier_zanto_gari_armor_pierce or class({})
function modifier_zanto_gari_armor_pierce:IsHidden() return true end
function modifier_zanto_gari_armor_pierce:IsPurgable() return false end
function modifier_zanto_gari_armor_pierce:DeclareFunctions() return {MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR} end
function modifier_zanto_gari_armor_pierce:GetModifierIgnorePhysicalArmor() return 0 end

---------------------------------
-- Zanto Gari Grace Time Shift --
---------------------------------
modifier_zanto_gari_grace_time_shift = modifier_zanto_gari_grace_time_shift or class({})
function modifier_zanto_gari_grace_time_shift:IsHidden() return true end
function modifier_zanto_gari_grace_time_shift:IsPurgable() return false end
function modifier_zanto_gari_grace_time_shift:RemoveOnDeath() return false end
function modifier_zanto_gari_grace_time_shift:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_zanto_gari_grace_time_shift:GetOverrideAnimation() return ACT_DOTA_CAST_ABILITY_2 end
function modifier_zanto_gari_grace_time_shift:OnCreated()
	if IsServer() then
		self:GetCaster():EmitSound("Zanto_Gari.Grace_Time")
		local pfx = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_slash_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, self:GetCaster():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
	end
end
function modifier_zanto_gari_grace_time_shift:OnDestroy()
	if IsServer() then
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
	end
end
function modifier_zanto_gari_grace_time_shift:CheckState()
	return {[MODIFIER_STATE_FROZEN] = true,[MODIFIER_STATE_STUNNED] = true}
end

---------------------------
-- Zanto Gari Grace Time --
---------------------------
modifier_zanto_gari_grace_time = modifier_zanto_gari_grace_time or class({})
function modifier_zanto_gari_grace_time:IsHidden() return false end
function modifier_zanto_gari_grace_time:IsPurgable() return false end
function modifier_zanto_gari_grace_time:RemoveOnDeath() return false end
function modifier_zanto_gari_grace_time:OnCreated(keys)
	if IsServer() then
		self.grace_time_as = keys.grace_time_as
		Attack(self:GetParent(), self:GetCaster())
		self:StartIntervalThink(self.grace_time_as)
	end
end
function modifier_zanto_gari_grace_time:OnIntervalThink()
	if not self:GetParent():IsAlive() then self:Destroy() end
	Attack(self:GetParent(), self:GetCaster())
end
function modifier_zanto_gari_grace_time:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_zanto_gari_grace_time:GetModifierMoveSpeedBonus_Percentage() return self:GetCaster():FindAbilityByName("zanto_gari"):GetSpecialValueFor("movement_slow_pct") * (-1) end
function modifier_zanto_gari_grace_time:OnDestroy() if IsServer() then end end

function Attack(target, caster)
	caster:PerformAttack(target, false, false, true, false, false, false, true)
	local hit_pfx = ParticleManager:CreateParticle("particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(hit_pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(hit_pfx, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(hit_pfx)
end

--------------------------
-- Zanto Gari Bonus Dmg --
--------------------------
modifier_zanto_gari_bonus_dmg = modifier_zanto_gari_bonus_dmg or class({})
function modifier_zanto_gari_bonus_dmg:IsPurgable() return false end

function modifier_zanto_gari_bonus_dmg:OnCreated(keys)
    if IsServer() then
        self.is_extra_slash_mode = false -- Default to invulnerable mode
        if HasSuperScepter(self:GetCaster()) then
            -- Ensure the echo stacks modifier exists
            if not self:GetCaster():HasModifier("modifier_zanto_gari_ss_echo_stacks") then
                self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_zanto_gari_ss_echo_stacks", {})
            end

            -- Check autocast state to determine mode
            if self:GetAbility() and self:GetAbility():GetAutoCastState() then
                self.is_extra_slash_mode = true
            end
        end
    end
end

function modifier_zanto_gari_bonus_dmg:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
	-- Only grant invulnerability if not in extra slash mode
	if not self.is_extra_slash_mode then
		state[MODIFIER_STATE_INVULNERABLE] = true
	end
	return state
end

function modifier_zanto_gari_bonus_dmg:GetEffectName() return "particles/custom/abilities/heroes/juggernaut_zanto_gari/zanto_gari_vibr.vpcf" end
function modifier_zanto_gari_bonus_dmg:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_zanto_gari_bonus_dmg:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_zanto_gari_bonus_dmg:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetCaster():FindAbilityByName("zanto_gari"):GetSpecialValueFor("pt_base_attack")
end

---------------------
-- Zanto Gari Crit --
---------------------
modifier_zanto_gari_crit = modifier_zanto_gari_crit or class({})
function modifier_zanto_gari_crit:IsPurgable() return false end
function modifier_zanto_gari_crit:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_INVULNERABLE] = true}
end
function modifier_zanto_gari_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_zanto_gari_crit:GetModifierPreAttack_CriticalStrike()
	if self:GetCaster():HasTalent("special_bonus_zanto_gari_dmg") then
		return self:GetCaster():FindTalentValue("special_bonus_zanto_gari_dmg")
	end
end
function modifier_zanto_gari_crit:GetModifierTotalDamageOutgoing_Percentage(keys)
	if not keys.no_attack_cooldown and keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and keys.damage_flags == DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION then
		return -100
	end
end

----------------------
-- Zanto Gari Invis --
----------------------
modifier_zanto_gari_invis = modifier_zanto_gari_invis or class({})
function modifier_zanto_gari_invis:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true} end
function modifier_zanto_gari_invis:DeclareFunctions() return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_zanto_gari_invis:GetModifierInvisibilityLevel() return 1 end

------------------------------------
-- Zanto Gari SS Echo Stacks --
------------------------------------
modifier_zanto_gari_ss_echo_stacks = modifier_zanto_gari_ss_echo_stacks or class({}) -- Renamed class

function modifier_zanto_gari_ss_echo_stacks:IsHidden() return false end
function modifier_zanto_gari_ss_echo_stacks:IsPurgable() return false end
function modifier_zanto_gari_ss_echo_stacks:RemoveOnDeath() return false end
function modifier_zanto_gari_ss_echo_stacks:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end -- Allow multiple instances if needed, though likely only one per hero

function modifier_zanto_gari_ss_echo_stacks:OnCreated(keys)
	if IsServer() then
		-- Initialize stacks if not already set (e.g., on first Super Scepter acquire)
		if self:GetStackCount() == 0 then
			self:SetStackCount(0)
		end
	end
end

function modifier_zanto_gari_ss_echo_stacks:DeclareFunctions()
	return { MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_zanto_gari_ss_echo_stacks:OnTooltip()
	-- Returns the calculated chance as a number for localization %fMODIFIER_PROPERTY_TOOLTIP%
	
	local caster = self:GetCaster()
	if not caster then return 0 end

	local echo_stacks = self:GetStackCount()
	local level_chance = math.min( caster:GetLevel() / 2, 60 )
	local stack_chance = echo_stacks
	local total_chance = math.min( level_chance + stack_chance, 80 )

	return total_chance
end

---------------------------------------------
-- Zanto Gari SS Slash Internal Cooldown --
---------------------------------------------
modifier_zanto_gari_ss_slash_internal_cd = modifier_zanto_gari_ss_slash_internal_cd or class({})

function modifier_zanto_gari_ss_slash_internal_cd:IsHidden() return true end
function modifier_zanto_gari_ss_slash_internal_cd:IsPurgable() return false end
function modifier_zanto_gari_ss_slash_internal_cd:RemoveOnDeath() return true end -- Can remove on death

--------------------------------
-- Perform Extra Zanto Slash -- (Now calls the reusable function)
--------------------------------
function PerformExtraZantoSlash(caster, target, cast_distance)
	if not IsServer() or not caster or not target or not target:IsAlive() then return end

	local ability = caster:FindAbilityByName("zanto_gari")
	if not ability then return end

	-- Clamp the extra slash distance to a maximum of 1300
	local max_extra_slash_distance = 1300
	local effective_cast_distance = math.min(cast_distance, max_extra_slash_distance)

	-- Calculate random start position based on the clamped distance, relative to the TARGET
	local direction = RandomVector(1):Normalized() -- Random horizontal direction
	local start_pos = target:GetAbsOrigin() + direction * effective_cast_distance -- Use target's position as the origin
	start_pos = GetGroundPosition(start_pos, caster) -- Ensure it's on the ground

	-- Calculate the final position for the pass-through effect using the clamped distance
	-- The end point should be opposite the start point relative to the target
	local target_origin = target:GetAbsOrigin()
	local final_pos = target_origin - direction * effective_cast_distance -- Mirror the start offset
	final_pos = GetGroundPosition(final_pos, caster) -- Ensure the end point is also on the ground

	-- Visually teleport the caster to the start position before executing the slash
	FindClearSpaceForUnit(caster, start_pos, false)

	-- Execute the core slash logic after a tiny delay to allow the teleport to render
	Timers:CreateTimer(FrameTime(), function()
		if caster and caster:IsAlive() and ability then -- Check if entities are still valid
			-- The 'target_position' argument for ExecuteZantoGariSlash determines where the hero *ends* the dash.
			-- Pass the *clamped* distance to the core function for consistency in particle/logic if needed, though the actual movement is already determined by start/final_pos.
			-- Pass nil for caster_original_position as it's not needed for calculating the debuff distance applied *by* the extra slash (it uses the passed 'cast_distance' which is now clamped).
			ExecuteZantoGariSlash(caster, ability, start_pos, final_pos, effective_cast_distance, true, target, nil)
		end
	end)
end


---------------------
-- TALENT HANDLERS --
---------------------
LinkLuaModifier("modifier_special_bonus_zanto_gari_cooldown", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_special_bonus_zanto_gari_dmg", "heroes/hero_juggernaut/zanto_gari.lua", LUA_MODIFIER_MOTION_NONE)
modifier_special_bonus_zanto_gari_cooldown	= modifier_special_bonus_zanto_gari_cooldown or class({})
modifier_special_bonus_zanto_gari_dmg = modifier_special_bonus_zanto_gari_dmg or class({})

function modifier_special_bonus_zanto_gari_cooldown:IsHidden() return true end
function modifier_special_bonus_zanto_gari_cooldown:IsPurgable() return false end
function modifier_special_bonus_zanto_gari_cooldown:RemoveOnDeath() return false end

function modifier_special_bonus_zanto_gari_dmg:IsHidden() return true end
function modifier_special_bonus_zanto_gari_dmg:IsPurgable() return false end
