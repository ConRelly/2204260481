require("lib/illusion")
LinkLuaModifier("modifier_cancels_count", "heroes/hero_piety/divine_cancel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_divine_cancel", "heroes/hero_piety/divine_cancel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_divinity_activated", "heroes/hero_piety/divine_cancel", LUA_MODIFIER_MOTION_NONE)

PurgeUnpurgable = {
-- Items
--[[
	["modifier_item_plain_ring_invincibility"] = true,
	["modifier_item_plain_ring_perma_invincibility"] = true,
	["modifier_spirit_guardian_heal"] = true,
	["modifier_mana_blade_debuff"] = true,
	["modifier_mana_blade_dispel"] = true,
	["modifier_item_bloodstone_active"] = true,
	["modifier_item_mjz_bloodstone_active"] = true,
	["modifier_heavens_halberd_debuff"] = true,
	["modifier_disarmed"] = true,
	["modifier_force_boots_active"] = true,
	["modifier_item_phase_boots_active"] = true,
	["modifier_item_high_tech_boots_active"] = true,
	["modifier_item_high_tech_boots2_active"] = true,
	["modifier_item_speed_orb_consumed"] = true,
	["modifier_tome_str_bonus"] = true,
	["modifier_tome_agi_bonus"] = true,
	["modifier_tome_int_bonus"] = true,
]]

-- Abilities
	["modifier_kill"] = true,
	["modifier_skeleton_king_vampiric_aura_summon"] = true,
	["modifier_hw_sharpshooter"] = true,
	["modifier_life_stealer_infest"] = true,
	["modifier_wisp_tether"] = true,
	["modifier_wisp_spirits"] = true,
	["modifier_tiny_tree_grab"] = true,

-- Bosses
	["modifier_custom_antimage_revenge"] = true,
	["god_overvoid_thinker"] = true,
	["god_overvoid_modifier"] = true,
	["god_overvoid_modifier_jump"] = true,
}
TargetUntargetable = {
	["npc_dota_invisible_vision_source"] = true,
	["npc_conduit"] = true,
	["npc_dota_aether_remnant"] = true,
	["npc_dota_stormspirit_remnant"] = true,
	["npc_dota_ember_spirit_remnant"] = true,
	["npc_dota_earth_spirit_stone"] = true,
	["npc_dota_beastmaster_axe"] = true,

-- Bosses
	["npc_dota_boss_aghanim_crystal"] = true,
	["npc_dota_creature_aghanim_minion"] = true,
	["npc_dota_boss_aghanim_spear"] = true,
}
local IgnoreOnsecond = {
	["modifier_spirit_guardian_heal_cd"] = true,
}
-------------------
-- Lesser Cancel --
-------------------
lesser_cancel = class({})
function lesser_cancel:IsHiddenWhenStolen() return true end
function lesser_cancel:ProcsMagicStick() return false end
function lesser_cancel:IsRefreshable() return false end
function lesser_cancel:GetCastRange(location, target) return self.BaseClass.GetCastRange(self, location, target) end
function lesser_cancel:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:GetCursorCastTarget()
--	local radius = self:GetSpecialValueFor("radius")
	local upgrade_count = self:GetSpecialValueFor("upgrade_count")
--	local particle = ParticleManager:CreateParticle("particles/custom/abilities/divine_cancel/divine_cancel_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
--	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	caster:EmitSoundParams("Divine_Cancel", 1, 0.5, 0)

--	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)

--	local util_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)

--	for _, target in pairs(targets) do
		if target and target:IsAlive() then
			if target:HasModifier("modifier_chen_custom_holy_persuasion_buff") then return end
			if target:HasModifier("modifier_infinite_health") then return end
			target:Purge(true, true, false, true, false)
			for _, modifier in pairs(target:FindAllModifiers()) do
				local ModifierName = modifier:GetName()
				local ModifierDuration = modifier:GetDuration()
				if ModifierDuration > 0 then
					if modifier:IsNull() then return end
					modifier:Destroy()
				elseif PurgeUnpurgable[ModifierName] then
					if modifier:IsNull() then return end
					modifier:Destroy()
				end
			end
			for i = 0, 14 do
				local Item = target:GetItemInSlot(i)
				if Item and Item:GetToggleState() then
					Item:ToggleAbility()
				end
			end
			for i = 0, target:GetAbilityCount() - 1 do
				local Ability = target:GetAbilityByIndex(i)
				if Ability and Ability:GetToggleState() then
					if not string.find(Ability:GetAbilityName(), "autocast") and Ability:GetName() ~= "medusa_mana_shield" then
						Ability:ToggleAbility()
					end	
				end
			end
			if target:IsIllusion() then kill_illusion(target) end
			target:AddNewModifier(caster, self, "modifier_divine_cancel", {duration = FrameTime()})
			ProjectileManager:ProjectileDodge(target)
		end
--	end
--	for _, target in pairs(util_units) do
		if target then
			if target:HasModifier("modifier_chen_custom_holy_persuasion_buff") then return end
			if target:HasModifier("modifier_infinite_health") then return end
			for _, modifier in pairs(target:FindAllModifiers()) do
				local ModifierName = modifier:GetName()
				if not IgnoreOnsecond[ModifierName] then				
					local ModifierDuration = modifier:GetDuration()
					if ModifierDuration > 0 then
						if modifier:IsNull() then return end
						modifier:Destroy()
					elseif PurgeUnpurgable[ModifierName] then
						if modifier:IsNull() then return end
						modifier:Destroy()
					end
				end	
			end
			local UnitName = target:GetUnitName()
			if TargetUntargetable[UnitName] or target:IsOther() then
				target:ForceKill(false)
			end
		end
--	end
	caster:AddNewModifier(caster, self, "modifier_cancels_count", {})
	local cancels_count = caster:FindModifierByName("modifier_cancels_count")
	if cancels_count:GetStackCount() >= upgrade_count - 1 then
		caster:AddAbility("divine_cancel")
		caster:FindAbilityByName("divine_cancel"):SetLevel(self:GetLevel())
		caster:SwapAbilities("lesser_cancel", "divine_cancel", false, true)
		caster:RemoveAbility("lesser_cancel")
		caster:RemoveModifierByName("modifier_cancels_count")
	else
		cancels_count:SetStackCount(cancels_count:GetStackCount() + 1)
	end
end


-------------------
-- Divine Cancel --
-------------------
divine_cancel = class({})
function divine_cancel:IsHiddenWhenStolen() return true end
function divine_cancel:ProcsMagicStick() return false end
--function divine_cancel:IsRefreshable() return false end
function divine_cancel:OnSpellStart()
--	if IsServer() then
		local caster = self:GetCaster()
		local particle = ParticleManager:CreateParticle("particles/custom/abilities/divine_cancel/divine_cancel_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
--		EmitSoundOn("Divine_Cancel.Effect", caster)
--		EmitSoundOn("Divine_Cancel", caster)
		EmitGlobalSound("Divine_Cancel.Effect")

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)

		local util_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)

		for _, target in pairs(targets) do
			if target and target:IsAlive() then
				if target:HasModifier("modifier_chen_custom_holy_persuasion_buff") then return end
				if target:HasModifier("modifier_infinite_health") then return end
				target:Purge(true, true, false, true, false)
				for _, modifier in pairs(target:FindAllModifiers()) do
					local ModifierName = modifier:GetName()
					local ModifierDuration = modifier:GetDuration()
					if ModifierDuration > 0 then
						if modifier:IsNull() then return end
						modifier:Destroy()
					elseif PurgeUnpurgable[ModifierName] then
						if modifier:IsNull() then return end
						modifier:Destroy()
					end
				end
				for i = 0, 8 do
					local Item = target:GetItemInSlot(i)
					if Item and Item:GetToggleState() then
						Item:ToggleAbility()
					end
				end
				for i = 0, target:GetAbilityCount() - 1 do
					local Ability = target:GetAbilityByIndex(i)
					if Ability and Ability:GetToggleState() then 
						if not string.find(Ability:GetAbilityName(), "autocast") and Ability:GetName() ~= "medusa_mana_shield" then
							Ability:ToggleAbility()
						end	
					end
				end
				if target:IsIllusion() then kill_illusion(target) end
				target:AddNewModifier(caster, self, "modifier_divine_cancel", {duration = FrameTime()})
				ProjectileManager:ProjectileDodge(target)
--				EmitSoundOnClient("Divine_Cancel.Effect", target:GetPlayerOwner())
			end
		end
		for _, target in pairs(util_units) do
			if target then
				if target:HasModifier("modifier_chen_custom_holy_persuasion_buff") then return end
				if target:HasModifier("modifier_infinite_health") then return end
				for _, modifier in pairs(target:FindAllModifiers()) do
					local ModifierName = modifier:GetName()
					if not IgnoreOnsecond[ModifierName] then
						local ModifierDuration = modifier:GetDuration()
						if ModifierDuration > 0 then
							if modifier:IsNull() then return end
							modifier:Destroy()
						elseif PurgeUnpurgable[ModifierName] then
							if modifier:IsNull() then return end
							modifier:Destroy()
						end
					end	
				end
			end
			if target then
				local UnitName = target:GetUnitName()
				if TargetUntargetable[UnitName] or target:IsOther() then
					target:Kill(nil,nil)
				end
			end
		end
		Timers:RemoveTimers(true)
--	end
end

--------------------
-- Lesser Counter --
--------------------
modifier_cancels_count = class({})
function modifier_cancels_count:IsHidden() return false end
function modifier_cancels_count:IsPurgable() return false end
function modifier_cancels_count:IsBuff() return true end
function modifier_cancels_count:RemoveOnDeath() return false end
function modifier_cancels_count:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_cancels_count:OnTooltip() return self:GetAbility():GetSpecialValueFor("upgrade_count") - self:GetStackCount() end

---------------------
-- Cancel Modifier --
---------------------
modifier_divine_cancel = class({})
function modifier_divine_cancel:IsHidden() return true end
function modifier_divine_cancel:IsPurgable() return false end
function modifier_divine_cancel:IsStunDebuff() return true end
function modifier_divine_cancel:OnCreated()
	local particle = ParticleManager:CreateParticle("particles/custom/abilities/divine_cancel/divine_cancel_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
end
function modifier_divine_cancel:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
    return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_BLIND] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_HEXED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_FEARED] = true,
	}
end


--------------
-- Divinity --
--------------
modifier_divinity_activated = class({})
function modifier_divinity_activated:IsHidden() return false end
function modifier_divinity_activated:IsPurgable() return false end
function modifier_divinity_activated:RemoveOnDeath() return false end
function modifier_divinity_activated:GetTexture()
	return "custom/abilities/divinity"
end
function modifier_divinity_activated:GetEffectName()
	return "particles/custom/abilities/divine_cancel/divinity.vpcf"
end
function modifier_divinity_activated:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_divinity_activated:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local player = PlayerResource:GetPlayer(caster:GetPlayerID())
		screen_pfx = ParticleManager:CreateParticleForPlayer("particles/custom/abilities/divine_cancel/divinity_screen.vpcf", PATTACH_ABSORIGIN, caster, player)
		ParticleManager:SetParticleControl(screen_pfx, 1, Vector(1, 0, 0))
	end
end
function modifier_divinity_activated:OnDestroy()
	if IsServer() then
		if screen_pfx then
			ParticleManager:DestroyParticle(screen_pfx, false)
			ParticleManager:ReleaseParticleIndex(screen_pfx)
		end
	end
end
