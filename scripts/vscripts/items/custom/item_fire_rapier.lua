LinkLuaModifier("modifier_fire_rapier_fire_power_buff_penalty", "items/custom/item_fire_rapier.lua", LUA_MODIFIER_MOTION_NONE)

function OnUnequip(keys)
	
	local item = keys.ability
	local caster = keys.caster
	local vLocation = caster:GetAbsOrigin()
	local vRandomVector = RandomVector(50)
	local container = item:GetContainer()
	if container then
		container:SetRenderColor(255,69,0)
		item:LaunchLoot(false, 150, 0.5, vLocation + vRandomVector, nil)
	end
	if caster:HasModifier("modifier_fire_rapier_fire_power_buff") then
		caster:RemoveModifierByName("modifier_fire_rapier_fire_power_buff")
	end	
end

function CheckForStats (keys)
	local item = keys.ability
	local caster = keys.caster
	local vLocation = caster:GetAbsOrigin()
	
	local stats_required = item:GetSpecialValueFor("stats_required")
--	GameRules:SendCustomMessage("stats_required:"..stats_required,0,0)
	local item_stats_sum = item:GetSpecialValueFor("rapier_str") + item:GetSpecialValueFor("rapier_agi") + item:GetSpecialValueFor("rapier_int")
	local stats_sum = caster:GetStrength() + caster:GetAgility() + caster:GetIntellect(false)
	local hero_stats_sum = stats_sum - item_stats_sum
	
--	GameRules:SendCustomMessage("stats_sum:"..stats_sum,0,0)
--	GameRules:SendCustomMessage("item_stats_sum:"..item_stats_sum,0,0)
--	GameRules:SendCustomMessage("hero_stats_sum:"..hero_stats_sum,0,0)
	if not caster:HasModifier("modifier_arc_warden_tempest_double")and caster:IsRealHero() then
		if 	--caster:HasModifier("modifier_fire_rapier_passive_bonus") or
			caster:HasModifier("modifier_wind_rapier_passive_bonus") or
			caster:HasModifier("modifier_earth_rapier_passive_bonus") or
			caster:HasModifier("modifier_item_imba_skadi") then

			GameRules:SendCustomMessage("#Game_notification_fire_rapier_request_message1",0,0)
			Timers:CreateTimer(0.001, function() caster:DropItemAtPositionImmediate(item, vLocation) end)
		end
		if stats_required > hero_stats_sum then
			Timers:CreateTimer(0.001, function() caster:DropItemAtPositionImmediate(item, vLocation) end)
			GameRules:SendCustomMessage("#Game_notification_fire_rapier_request_message",0,0)
			GameRules:SendCustomMessage("<font color='#FFD700'>NOT ENOUGH </font><font color='#FF4500'>".. stats_required-hero_stats_sum .."</font>",0,0)
		end
	end
end

function OnSpellStart(keys)
	local item = keys.ability
	local caster = keys.caster
	local buff_duration = item:GetSpecialValueFor("buff_duration")
	caster:AddNewModifier(caster, item, "modifier_fire_rapier_fire_power_buff_penalty", {Duration = buff_duration})
end

--[[function AttackLanded(data)
	if IsServer() then
		local caster = data.caster
		local target = data.target
		local attacker = data.attacker
		local ability = data.ability
		local dmgMultiply = ability:GetSpecialValueFor("dmg_perc")/100 or 0
		local cleaveStRadius = 100
		local cleaveEndRadius = 500
		local cleaveDistance = 700
		caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
		local damage = dmgMultiply * caster:GetAverageTrueAttackDamage(caster)
		local damage = dmgMultiply * caster:GetAttackDamage()
		local particle = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf"
		DoCleaveAttack(caster, target, ability, damage, cleaveStRadius, cleaveEndRadius, cleaveDistance, particle)
	end
end]]

--------------------------------------------------------------------------------
modifier_fire_rapier_fire_power_buff_penalty = class({})
function modifier_fire_rapier_fire_power_buff_penalty:DeclareFunctions() return {MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR} end
function modifier_fire_rapier_fire_power_buff_penalty:GetModifierIgnorePhysicalArmor() return 1 end
function modifier_fire_rapier_fire_power_buff_penalty:IsHidden() return false end
function modifier_fire_rapier_fire_power_buff_penalty:RemoveOnDeath() return true end
