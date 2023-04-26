function OnUnequip(keys)
	local item = keys.ability
	local caster = keys.caster
	local vLocation = caster:GetAbsOrigin()
	local vRandomVector = RandomVector(50)
	local container = item:GetContainer()
	if container then
		container:SetRenderColor(139,69,13)
		--item:LaunchLoot(false, 150, 0.5, vLocation + vRandomVector)
	end
end

function CheckForStats(keys)
	local item = keys.ability
	local caster = keys.caster
	local vLocation = caster:GetAbsOrigin()
--[[
	local stats_required = item:GetSpecialValueFor("stats_required")
	GameRules:SendCustomMessage("stats_required:"..stats_required,0,0)
	local item_stats_sum = item:GetSpecialValueFor("rapier_str") + item:GetSpecialValueFor("rapier_agi") + item:GetSpecialValueFor("rapier_int")
	local stats_sum = caster:GetStrength() + caster:GetAgility() + caster:GetIntellect()
	local hero_stats_sum = stats_sum - item_stats_sum

	GameRules:SendCustomMessage("stats_sum:"..stats_sum,0,0)
	GameRules:SendCustomMessage("item_stats_sum:"..item_stats_sum,0,0)
	GameRules:SendCustomMessage("hero_stats_sum:"..hero_stats_sum,0,0)
]]
	if not caster:HasModifier("modifier_arc_warden_tempest_double")and caster:IsRealHero() then
		if 	caster:HasModifier("modifier_fire_rapier_passive_bonus") or
			caster:HasModifier("modifier_wind_rapier_passive_bonus") or
			caster:HasModifier("modifier_item_imba_skadi") then

			GameRules:SendCustomMessage("#Game_notification_earth_rapier_request_message1",0,0)
			Timers:CreateTimer(0.001, function() caster:DropItemAtPositionImmediate(item, vLocation) end)
		end
--[[
		if stats_required > hero_stats_sum then
			Timers:CreateTimer(0.001, function() caster:DropItemAtPositionImmediate(item, vLocation) end)
			GameRules:SendCustomMessage("#Game_notification_earth_rapier_request_message",0,0)
			GameRules:SendCustomMessage("<font color='#FFD700'>NOT ENOUGH </font><font color='#8B4513'>".. stats_required-hero_stats_sum .."</font>",0,0)
		end
]]
	end
end
