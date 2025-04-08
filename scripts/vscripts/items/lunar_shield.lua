----------------
--LUNAR SHIELD--
----------------
LinkLuaModifier("modifier_lunar_shield", "items/lunar_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lunar_shield_absorb", "items/lunar_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lunar_shield_cd", "items/lunar_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lunar_recovery", "items/lunar_shield.lua", LUA_MODIFIER_MOTION_NONE)
-- Removed LinkLuaModifier for modifier_lunar_shield_check
if item_lunar_shield == nil then item_lunar_shield = class({}) end
function item_lunar_shield:GetIntrinsicModifierName() return "modifier_lunar_shield" end
function item_lunar_shield:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	end
	return self.BaseClass.GetBehavior(self)
end
function item_lunar_shield:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_lunar_shield_absorb")
	caster:RemoveModifierByName("modifier_lunar_shield_cd")
	caster:RemoveModifierByName("modifier_lunar_recovery")
	caster:AddNewModifier(caster, self, "modifier_lunar_shield_absorb", {})
end
if modifier_lunar_shield == nil then modifier_lunar_shield = class({}) end
function modifier_lunar_shield:IsHidden() return true end
function modifier_lunar_shield:IsPurgable() return false end
function modifier_lunar_shield:RemoveOnDeath() return false end
function modifier_lunar_shield:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() self:GetCaster():SetMaxHealth(self:GetCaster():GetBaseMaxHealth()) self:GetCaster():Heal(self:GetCaster():GetBaseMaxHealth(), self:GetCaster()) end
		local caster = self:GetCaster()
		-- Removed AddNewModifier for modifier_lunar_shield_check
		self:StartIntervalThink(0.15)
		-- Apply a very short initial cooldown to ensure state is stable before shield appears
		if not caster:HasModifier("modifier_lunar_shield_cd") and not caster:HasModifier("modifier_lunar_shield_absorb") then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_lunar_shield_cd", { duration = 0.1 })
		end
	end
end
function modifier_lunar_shield:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		-- Reapply absorb modifier if missing, respecting Super Scepter cooldown bypass
		if not caster:HasModifier("modifier_lunar_shield_absorb") then
			-- Reapply if:
			--cooldown modifier is NOT present
			if not caster:HasModifier("modifier_lunar_shield_cd") then
				-- Pass initial shield value if reapplying
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_lunar_shield_absorb", {})
			end
		end
		if caster:HasItemInInventory("item_life_greaves") and caster:HasScepter() and caster:GetHealth() < (caster:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("threshold") / 100) and self:GetAbility():IsCooldownReady() then
			-- Only trigger if the item is not on cooldown
			print("passing threshold check")
			caster:FindItemInInventory("item_lunar_shield"):OnSpellStart()
			self:GetAbility():UseResources(true, true, false, true)
		end

	end
end
function modifier_lunar_shield:OnDestroy()
	if IsServer() then
		self:GetCaster():SetMaxHealth(self:GetCaster():GetBaseMaxHealth())
		self:GetCaster():Heal(self:GetCaster():GetBaseMaxHealth(), self:GetCaster())
		self:GetCaster():RemoveModifierByName("modifier_lunar_shield_absorb")
	end
end
function modifier_lunar_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end
function modifier_lunar_shield:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		local caster = self:GetCaster()
		return self:GetAbility():GetSpecialValueFor("all_stats_lvl") * caster:GetLevel()
	end
	return 0 -- Return 0 if ability is not found
end
function modifier_lunar_shield:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		local caster = self:GetCaster()
		return self:GetAbility():GetSpecialValueFor("all_stats_lvl") * caster:GetLevel()
	end
	return 0 -- Return 0 if ability is not found
end
function modifier_lunar_shield:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		local caster = self:GetCaster()
		return self:GetAbility():GetSpecialValueFor("all_stats_lvl") * caster:GetLevel()
	end
	return 0 -- Return 0 if ability is not found
end
function modifier_lunar_shield:GetModifierIncomingDamage_Percentage()
	if not self:GetParent():HasModifier("modifier_lunar_shield_absorb") then
		return self:GetAbility():GetSpecialValueFor("inc_dmg")
	end
	return 0
end
function modifier_lunar_shield:GetModifierExtraHealthPercentage()
	if self:GetAbility() then
		if self:GetCaster():HasModifier("modifier_lier_scarlet_t") or self:GetCaster():HasModifier("modifier_lier_scarlet_m") or self:GetCaster():HasModifier("modifier_lier_scarlet_b") then
			return (self:GetAbility():GetSpecialValueFor("hp_red_pct") / 2) * (-1)
		end
		return self:GetAbility():GetSpecialValueFor("hp_red_pct") * (-1)
	end
end
-----------------------
--LUNAR SHIELD ABSORB-- 
-----------------------
modifier_lunar_shield_absorb = modifier_lunar_shield_absorb or class({})
function modifier_lunar_shield_absorb:IsDebuff() return false end
function modifier_lunar_shield_absorb:IsHidden() return false end
function modifier_lunar_shield_absorb:IsPurgable() return false end
function modifier_lunar_shield_absorb:IsPurgeException() return false end

function modifier_lunar_shield_absorb:OnCreated(params)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	if not self.ability then self:Destroy() return end

	self.shield_regen_pct = 0.15 -- 15% max shield per second for Super Scepter
	self.interval = 0.15 -- Interval for regeneration check

	-- Initialize shield values to 0 temporarily
	self.max_shield = 0
	self.current_shield = 0

	if IsServer() then
		-- Use custom transmitter data for client sync
		self:SetHasCustomTransmitterData(true)

		-- Delay shield calculation and initial refresh by one frame
		Timers:CreateTimer(0, function()
			if IsValidEntity(self.parent) and self.ability and not self.ability:IsNull() then
				-- Calculate max shield based on parent's health (should be correct now)
				local shield_durability = self.ability:GetSpecialValueFor("shield_durability")
				self.max_shield = (self.parent:GetMaxHealth()) * (shield_durability / 100)

				-- Initialize current shield (use passed value if available, e.g., from OnSpellStart, otherwise max)
				-- Note: params might be nil here if created via CD:OnDestroy, default to max_shield
				self.current_shield = (params and params.initial_shield) or self.max_shield

				self:SendBuffRefreshToClients() -- Send initial data after calculation
			end
			return nil -- Run once
		end)

		-- Start interval think immediately (it will use the delayed shield values once calculated)
		self:StartIntervalThink(self.interval)
		-- Apply particle effect
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetAbsOrigin())
		self:AddParticle(self.particle, false, false, -1, false, false)
	end
end

function modifier_lunar_shield_absorb:OnRefresh(params)
	-- This function is generally called when the modifier is reapplied.
	-- We might receive specific parameters here, but the primary max HP sync
	-- is now handled in OnIntervalThink for better reliability on HP changes.
	-- We can still force a refresh if needed.
	if IsServer() then
		-- Optionally recalculate here if params indicate a specific need,
		-- otherwise OnIntervalThink will handle it.
		-- For now, just ensure client data is up-to-date on refresh.
		self:SendBuffRefreshToClients()
	end
end

function modifier_lunar_shield_absorb:OnDestroy()
	if IsServer() then
		-- If ability no longer exists (item sold/dropped), skip cooldown application
		if not self.ability or self.ability:IsNull() then return end

		-- Apply cooldown ONLY if shield broke
		if self.current_shield <= 0 then
			local shield_cd = self.ability:GetSpecialValueFor("shield_cd")
			if not self.parent:HasModifier("modifier_lunar_shield_cd") then
				self.parent:AddNewModifier(self.parent, self.ability, "modifier_lunar_shield_cd", {duration = shield_cd})
			end
		end
		-- Stop particle effect
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, false)
			ParticleManager:ReleaseParticleIndex(self.particle)
		end
	end
end

-- Transmitter data for client sync
function modifier_lunar_shield_absorb:AddCustomTransmitterData()
	return {
		current_shield = self.current_shield,
		max_shield = self.max_shield,
	}
end

function modifier_lunar_shield_absorb:HandleCustomTransmitterData(data)
	self.current_shield = data.current_shield
	self.max_shield = data.max_shield
	-- Update stack count on client for UI display
	self:SetStackCount(math.floor(self.current_shield))
end

-- Interval Effects
function modifier_lunar_shield_absorb:OnIntervalThink()
	if IsServer() then
		-- Ensure parent and ability are valid
		if not IsValidEntity(self.parent) or not self.ability or self.ability:IsNull() then
			self:Destroy()
			return
		end
		-- Check if the parent still has the base item modifier. If not, destroy this modifier.
		if not self.parent:HasModifier("modifier_lunar_shield") then
			self:Destroy()
			return
		end

		local caster = self.parent
		local has_super_scepter = caster:HasModifier("modifier_super_scepter")
		local is_in_recovery = caster:HasModifier("modifier_lunar_recovery") -- Check for recovery debuff
		local needs_refresh = false -- Flag to track if refresh is needed

		-- 1. Check and update max shield based on current max HP
		local shield_durability = self.ability:GetSpecialValueFor("shield_durability")
		local current_max_hp = self.parent:GetMaxHealth()
		local new_max_shield = current_max_hp * (shield_durability / 100)

		if self.max_shield ~= new_max_shield then
			local ratio = 1 -- Default to full if max_shield was 0 or invalid
			if self.max_shield > 0 then
				-- Preserve the current shield percentage
				ratio = self.current_shield / self.max_shield
			end
			self.max_shield = new_max_shield
			-- Clamp current shield to the new max shield value
			self.current_shield = math.min(self.max_shield * ratio, self.max_shield)
			needs_refresh = true
			-- print("Lunar Shield: Max shield updated to: " .. self.max_shield) -- Optional debug print
		end

		-- 2. Check if shield is broken (can happen after max shield update)
		if self.current_shield <= 0 then
			-- If max shield changed, ensure client gets the update before destruction
			if needs_refresh then
				self:SendBuffRefreshToClients()
			end
			self:Destroy() -- Cooldown logic is in OnDestroy
			return -- Exit early
		end

		-- 3. Handle Regeneration
		-- Apply Super Scepter constant regen (always active if scepter is held and shield exists)
		if has_super_scepter then
			local regen_amount = self.max_shield * self.shield_regen_pct * self.interval
			local new_shield_value = math.min(self.current_shield + regen_amount, self.max_shield)
			if new_shield_value > self.current_shield then -- Regen only if below max
				self.current_shield = new_shield_value
				needs_refresh = true -- Mark for refresh if regen happened
			end
		end

		-- Add base regeneration logic here if needed.
		-- IMPORTANT: If base regen exists, it *should* likely check 'not is_in_recovery'.
		-- Example:
		--[[
		if not has_super_scepter and not is_in_recovery then -- Only apply base regen if Super Scepter is NOT active and not in recovery
			local base_regen_pct = 0.02 -- Base regen: 2% max shield per second
			local base_regen_amount = self.max_shield * base_regen_pct * self.interval
			local new_shield_base = math.min(self.current_shield + base_regen_amount, self.max_shield)
			if new_shield_base > self.current_shield then
				self.current_shield = new_shield_base
				needs_refresh = true
			end
		end
		--]]

		-- 4. Send data refresh to clients if anything changed
		if needs_refresh then
			self:SendBuffRefreshToClients()
		end
	end
end

-- Modifier Effects
function modifier_lunar_shield_absorb:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT }
end

function modifier_lunar_shield_absorb:GetModifierIncomingDamageConstant(params)
	-- Client-side reporting for UI
	if not IsServer() then
		if params.report_max then
			return self.max_shield or 0
		else
			return self.current_shield or 0
		end
	end

	-- Server-side damage blocking
	if self.current_shield <= 0 then return 0 end -- Shield already broken

	-- Cache super scepter check
	local has_super_scepter = self.parent:HasModifier("modifier_super_scepter")

	-- Calculate how much damage the shield *actually* takes
	local damage_to_deduct_from_shield = has_super_scepter and params.damage * 0.25 or params.damage
	local actual_deduction = math.min(damage_to_deduct_from_shield, self.current_shield)

	-- Calculate how much damage is *prevented* from hitting HP
	-- This should be based on the original damage, up to the shield's current value *before* deduction
	local damage_to_block_from_hp = math.min(params.damage, self.current_shield)

	-- Apply the deduction to the shield
	self.current_shield = self.current_shield - actual_deduction

	-- Trigger recovery debuff if any damage was blocked/deducted
	if actual_deduction > 0 then -- Changed condition slightly, if shield takes damage, trigger recovery
		local shield_recovery_duration = self.ability:GetSpecialValueFor("shield_recovery")
		-- Halve duration if Super Scepter is active
		if has_super_scepter then
			shield_recovery_duration = shield_recovery_duration / 2
		end
		-- Apply/refresh recovery modifier
		self.parent:AddNewModifier(self.parent, self.ability, "modifier_lunar_recovery", {duration = shield_recovery_duration})
	end

	-- Refresh client data
	self:SendBuffRefreshToClients()

	-- Check if shield broke AFTER applying damage
	if self.current_shield <= 0 then
		self:Destroy()
		-- Return the amount that was blocked from HP before the shield broke
		return -damage_to_block_from_hp
	end

	-- Return the amount blocked from HP
	return -damage_to_block_from_hp
end


--Modifier Shield CD
modifier_lunar_shield_cd = modifier_lunar_shield_cd or class({})
function modifier_lunar_shield_cd:IsDebuff() return true end
function modifier_lunar_shield_cd:IsHidden() return false end
function modifier_lunar_shield_cd:IsPurgable() return false end

function modifier_lunar_shield_cd:OnDestroy()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        -- When the initial short CD ends, or the real CD ends, try to apply the absorb modifier
        -- Check if the base modifier still exists and ability is valid
        if caster:HasModifier("modifier_lunar_shield") and ability and not ability:IsNull() then
             -- Check again for absorb modifier in case it was applied by other means (e.g., OnSpellStart)
            if not caster:HasModifier("modifier_lunar_shield_absorb") then
                caster:AddNewModifier(caster, ability, "modifier_lunar_shield_absorb", {})
            end
        end
    end
end

--Modifier Shield Recovery
modifier_lunar_recovery = modifier_lunar_recovery or class({})
function modifier_lunar_recovery:IsDebuff() return false end -- Should maybe be true if it prevents regen? User preference.
function modifier_lunar_recovery:IsHidden() return false end
function modifier_lunar_recovery:IsPurgable() return false end
function modifier_lunar_recovery:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end -- Apply even if invulnerable?

function modifier_lunar_recovery:OnCreated(params)
	if IsServer() then
		-- Optional: Add particle effect to indicate recovery state
		-- self.particle_fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		-- ParticleManager:SetParticleControl(self.particle_fx, 0, self:GetParent():GetAbsOrigin())
		-- self:AddParticle(self.particle_fx, false, false, -1, false, false)
	end
end

function modifier_lunar_recovery:OnDestroy()
	if IsServer() then
		-- Optional: Destroy particle effect
		-- if self.particle_fx then
		-- 	ParticleManager:DestroyParticle(self.particle_fx, false)
		-- 	ParticleManager:ReleaseParticleIndex(self.particle_fx)
		-- end

		local caster = self:GetCaster()
		local ability = self:GetAbility()

		-- Recovery period ended. Check if shield is NOT on cooldown.
		if not caster:HasModifier("modifier_lunar_shield_cd") then
			local absorb_modifier = caster:FindModifierByName("modifier_lunar_shield_absorb")

			if absorb_modifier then
				-- Shield exists but wasn't broken, fully restore it (or start regen if preferred)
				-- Option 1: Full Restore
				absorb_modifier.current_shield = absorb_modifier.max_shield
				absorb_modifier:SendBuffRefreshToClients() -- Update UI

				-- Option 2: Just allow regen to resume (remove Option 1 line if using this)
				-- No action needed here, OnIntervalThink will handle regen if applicable
			else
				-- Shield was broken during recovery (or just before), reapply it if CD is off
				-- This case might be redundant if absorb:OnDestroy handles the CD correctly
				-- but acts as a safeguard.
				if not caster:HasModifier("modifier_lunar_shield_cd") then
					caster:AddNewModifier(caster, ability, "modifier_lunar_shield_absorb", {})
				end
			end
		end
		-- Note: The main shield cooldown (modifier_lunar_shield_cd) is applied in
		-- modifier_lunar_shield_absorb:OnDestroy when the shield breaks.
		-- This recovery logic only handles what happens AFTER the recovery debuff expires.
	end
end
